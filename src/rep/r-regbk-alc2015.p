block-level on error undo, throw.


/*------------------------------------------------------------------------
$Revision: 7596fb7dbb2f, 3446, rls $
$Author: EShklyar $
$Date: 2023/10/16 15:13:33 $
$Workfile: r-regbk-alc2015.p $
$Archive: rep/r-regbk-alc2015.p $

Журнал учёта объёма розничной продажи алкогольной и спиртосодержащей продукции

Автор: Шаланин Сергей Владимирович
Дата создания: 11/12/15
Author: Shalanin Sergey
Creation date: 11/12/15
ТН-15.0
  ----------------------------------------------------------------------*/
  
DEFINE INPUT PARAMETER parParentProc AS HANDLE NO-UNDO.

DEFINE VARIABLE vss-revision    AS CHARACTER NO-UNDO INIT "$Revision: 7596fb7dbb2f, 3446, rls $":U .
DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INIT "$Author: EShklyar $":U .
DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INIT "$Date: 2023/10/16 15:13:33 $":U .
DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INIT "$Workfile: r-regbk-alc2015.p $":U .
DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INIT "$Archive: rep/r-regbk-alc2015.p $":U .
DEFINE VARIABLE vss-description AS CHARACTER NO-UNDO INIT "Журнал учёта розничной продажи алкогольной продукции".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
/*{ cmp/r-pril.i new }*/
{ cmp/r-page1.i  } /* Внутри вложен { cmp/obj-list.i {1}}, в котором формируется таблица obj-list. */
{ str/trdcalib.i }
{ gbl/attr-lib.i }
{ ref/gds-attr.i }
{ trg/factord.i  }
/*{ gbl/paramls.i  }*/
{ rep/fmtcli.i   }
{ cmp/r-pril.i new  } 
{ gbl/prn-lib.i }
{ gbl/clntattr.i }
{ rep/r-pychk0.i defalgo }
define variable v-grp-code like ub.gds-grp.node-code no-undo.
define variable v-grp-name like ub.goods.grp-name no-undo.
define variable ii-grp as integer no-undo.
define variable v-found as logical no-undo.

DEFINE VARIABLE egais-name            AS CHAR no-undo.
DEFINE VARIABLE v-qnty                AS DECIMAL no-undo.
DEFINE VARIABLE v-par-val             AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-par-type            AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-fact-order-start    AS DECIMAL   NO-UNDO.
DEFINE VARIABLE v-fact-order-end      AS DECIMAL   NO-UNDO.
DEFINE VARIABLE v-begin-date          AS DATE      NO-UNDO.
DEFINE VARIABLE v-end-date            AS DATE      NO-UNDO.
DEFINE VARIABLE v-addres              AS CHARACTER no-undo.
DEFINE VARIABLE v-search              AS CHARACTER no-undo.
DEFINE VARIABLE v-cntxt-host-name-obj AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-cntxt-host-code-obj AS INTEGER no-undo.
DEFINE VARIABLE v-report-name         AS CHARACTER NO-UNDO.         /* Наименование отчёта */
DEFINE VARIABLE v-period              AS CHARACTER NO-UNDO.              /* Период за который формируется отчёт */
DEFINE VARIABLE v-short-obj-list      AS CHARACTER NO-UNDO.      /* Перечень выбранных объектов "в одну строку" */
DEFINE VARIABLE v-choice-gds          AS CHARACTER NO-UNDO. /* Список выбранных товаров. Вывод - в шапке отчёта */
DEFINE VARIABLE v-choice-obj          AS CHARACTER NO-UNDO. /* Выбранный пользователем параметр "Выбор объекта" (в окне параметров). Вывод в шапке отчёта */
DEFINE VARIABLE v-full-path-RepView   AS CHARACTER NO-UNDO.   /* Полный путь к файлу Просмотровщика (отчётов) */
DEFINE VARIABLE v-file-name-rep-htm   AS CHARACTER NO-UNDO.   /* Полный путь к файлу отчёта */
DEFINE VARIABLE v-file-name           AS CHARACTER NO-UNDO .
DEFINE VARIABLE g#report-num          AS INTEGER   NO-UNDO.
DEFINE VARIABLE v-user-action         AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-printed             AS LOGICAL   NO-UNDO.
DEFINE VARIABLE v-cnt-line            AS INTEGER   NO-UNDO.
DEFINE VARIABLE v-cnt-line2           AS INTEGER   NO-UNDO.
DEFINE VARIABLE v-alc-type-name       AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-alc-type-code       AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-doc-code            AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-attr-type           AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-attr-value          AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-attr-doc-data       AS DATE      NO-UNDO.
DEFINE VARIABLE v-attr-doc-code       AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-name-ext-doc-type   AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-fill-path-RepView   AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-temp-id             AS INTEGER   NO-UNDO.
DEFINE VARIABLE v-sub-store-on        AS LOGICAL   NO-UNDO.
DEFINE VARIABLE v-obj-code            AS INTEGER   NO-UNDO.
DEFINE VARIABLE v-obj-type            AS CHAR      NO-UNDO.
DEFINE VARIABLE v-out-qnty-tot        AS DECIMAL   INITIAL 0 NO-UNDO.
DEFINE VARIABLE v-out-litres-tot      AS DECIMAL   INITIAL 0 NO-UNDO.
define VARIABLE v-attr-mark-value as character no-undo .
define VARIABLE v-value as character no-undo .
define VARIABLE ii as integer no-undo .

define buffer buf_chk-gds-attr for ub.chk-gds-attr .
        
DEFINE TEMP-TABLE tt-rep1
    FIELD obj-code                AS INTEGER
    FIELD obj-type                AS CHARACTER 
    FIELD cnt-line                AS INTEGER                                               /* 1.  "№ п/п."                                         Поступления. */
    FIELD alc-type-name           LIKE ub.alc-type.alc-type-name                      /* 2.  "Вид и наименование продукции"                   Поступления. */ /* По Rлассификатору алк прод. */
    FIELD alc-type-code           LIKE ub.alc-type.alc-type-code                      /* 3.  "Код вида продукции"                             Поступления. */
    FIELD cli-obj-name            LIKE ub.clients.obj-name                             /* 4.  "Наименование организации" (Поставщика)          Поступления. */
    FIELD inn                     LIKE ub.firm.inn                                              /* 5.  "ИНН" (Поставщика)                               Поступления. */
    FIELD date-trn                AS DATE                                                  /* 6.  "Дата" (Накл. Поставщика)                        Поступления. */ /* Из атрибутов прихода внешнего, если нет, то дата дата факт документа. Дата факт расхода внеш между фирм для межфирм перемещ. */
    FIELD doc-line-code           LIKE ub.doc-line.doc-code                           /* -   Служебное поле(не для вывода на экран) */
    FIELD doc-line-fact-order     LIKE ub.doc-line.fact-order                   /* -   Служебное поле. */
    FIELD doc-code                LIKE ub.doc-line.doc-code                                /* 7.  "Номер" (Накл. Поставщика)                       Поступления. */ /* Из атрибутов прихода внешнего, если нет, то пусто. Номер расхода внеш между фирм для межфирм перемещ. */
    FIELD volume-piece-litres     LIKE ub.goods.ms-base /* ">>,>>9,999" */      /* 8.  "Ёмкость тары(упаковки) (л)" (Накл. Поставщика)  Поступления. */ /* Определение: Объём одной минимальной(не делимой) штуки в литрах (ub.goods.ms-base). Т.е. это скажем, бутылка. */
    FIELD fact-qnty               LIKE doc-line.fact-qnty /* "->>,>>>,>>9,<<<" */         /* 9.  "Количество тары(упаковки)" (Накл. Поставщика)   Поступления. */ /* Определение: Кол-во минимальной тары(не делимой) по накладной. (doc-line.fact-qnty) Т.е. кол-во скажем, бутылок. */
    FIELD inc-total-quontity      LIKE doc-line.fact-qnty                        /* 10. "Итого поступило за отчётный период"             Поступления. */ /* Выводим литры тары: (doc-line.fact-qnty * goods.ms-base (т.е. факт_кол-во * объём_штуки)). Выводим штуки тары: факт_кол-во */
    FIELD exp-categoryes-prod     AS CHARACTER                                  /* 11. "Содержание записи"                              Расход.      */ /* Определение: продажа; списание - с указанием основания документа; перемещение - расход внутренний; недостача - инвентаризация; арестованная продукция изъятая из оборота; конфискованная продукция по решению суда. */
    FIELD exp-alc-type-name       LIKE ub.alc-type.alc-type-name                  /* 12. "Вид и наименование продукции"                Расход.      */ /* Вид и наимен продукции по Классификатору алк прод по каждой строке пт.11 */
    FIELD exp-alc-type-code       LIKE ub.alc-type.alc-type-code                 /* -   Служебное поле(не для вывода на экран) */
    FIELD exp-doc-line-code       LIKE ub.doc-line.doc-code                      /* -   Служебное поле(не для вывода на экран) */
    FIELD exp-td-fact-date        AS DATE                                         /* -   Служебное поле(не для вывода на экран) */
    FIELD exp-fact-order          LIKE ub.doc-line.fact-order                       /* -   Служебное поле. */
    FIELD exp-volume-piece-litres LIKE ub.goods.ms-base /* ">>,>>9,999" */  /* 13. "Ёмкость тары(упаковки) (л)"                     Расход.      */ 
    FIELD exp-fact-qnty           LIKE doc-line.fact-qnty /* "->>,>>>,>>9,<<<" */     /* 14. "Количество тары(упаковки)"                      Расход.      */
    FIELD exp-total-quontity      LIKE doc-line.fact-qnty                        /* 15. "Итого расход за отчётный период"                Расход.      */ /* Подобно п.10 */
    FIELD itog_ii                 AS INTEGER
    FIELD exp-time                AS INTEGER
    FIELD exp-name                AS CHAR
    FIELD gds-code                AS INTEGER
    FIELD itog_volume             AS INTEGER
    FIELD exp-doc-type            LIKE doc-line.ext-doc-type
    field alc-mark                as character
    INDEX pi IS PRIMARY alc-type-code       doc-line-code volume-piece-litres alc-mark
    INDEX fact_order    doc-line-fact-order
    .


/*define temp-table itog-rep  */
/*field itog-name as character*/
/*field fact-qnty as decimal  */
/*field fact-date as date     */
/*field fact-volume as decimal*/
/*field obj-code as integer   */
/*field obj-type as char      */
/*                            */
/*                            */

DEFINE BUFFER buf_tt      FOR tt-rep1.
DEFINE BUFFER buf_tt-rep1 FOR tt-rep1.
DEFINE BUFFER buf_trn-doc FOR ub.trn-doc.
/*define buffer buf_obj-list  for obj-list.*/
/*define buffer buf2_obj-list for obj-list.*/
DEFINE BUFFER buf_itog    FOR tt-rep1.
DEFINE STREAM Out-Stream.
DEFINE STREAM OutStr-html.
DEFINE STREAM MyWatch-strm.

/* ************************  Function Prototypes ********************** */

FUNCTION fnc-DD-MM-YYYY RETURNS CHARACTER 
    (INPUT p-dat-date AS DATE) FORWARD.

FUNCTION fnc-fmt-dec-tc-litres RETURNS CHARACTER 
    (INPUT p-num AS DECIMAL) FORWARD.

FUNCTION fnc-fmt-dec-tc-qnty RETURNS CHARACTER 
    (INPUT p-num AS DECIMAL) FORWARD.

/* ***************************  Main Block  *************************** */



/*procedure ConvertStr-ext-doc-type: /* Получение наименования код_вида_расходов по полученному элементу из списка наименований */*/
/*    /********************************/                                                                                          */
/*    define input parameter p-ext-doc-type as character no-undo.                                                                 */
/*    define output parameter p-name-ext-doc-type as character no-undo.                                                           */
/*    define variable v-num-element as integer no-undo.                                                                           */
/*                                                                                                                                */
/*    /* Код_вида_расходов. Получение номера элемента в списке кодов */                                                           */
/*    v-num-element = lookup(p-ext-doc-type, {&TDEDT_List}).                                                                      */
/*                                                                                                                                */
/*    /* Получение наименования код_вида_расходов по полученному элементу из списка наименований */                               */
/*    p-name-ext-doc-type = entry(v-num-element, {&TDEDT_List-full}).                                                             */
/*    if p-ext-doc-type <> "" and v-num-element = 0 then                                                                          */
/*    do:                                                                                                                         */
/*        message "Ошибка 115." view-as alert-box.                                                                                */
/*        return.                                                                                                                 */
/*    end.                                                                                                                        */
/*                                                                                                                                */
/*end procedure.                                                                                                                  */

/*procedure prc-create-file:                                                                             */
/*    /* ******************** */                                                                         */
/*    define input parameter p-rep-num as integer no-undo.                                               */
/*    /* Создаём временные файлы. */                                                                     */
/*    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ).       */
/*    output close.                                                                                      */
/*    output to value( string( session:temp-directory + {&DF_Name} + string( g#report-num ) ) + ".txl" ).*/
/*    output close.                                                                                      */
/*/* ******************** */                                                                             */
/*                                                                                                       */
/*/*/* Найти файл */                                                           */                        */
/*/*define variable v-full-file-name as character no-undo.                     */                        */
/*/*define variable v-shot-file-name as character no-undo.                     */                        */
/*/*v-shot-file-name = {&DF_Name} + string(g#report-num).                      */                        */
/*/*message "Ищем файл v-shot-file-name = " v-shot-file-name view-as alert-box.*/                        */
/*/*v-full-file-name = search(session:temp-directory + v-shot-file-name).      */                        */
/*/*message "Ищем файл v-full-file-name = " v-full-file-name view-as alert-box.*/                        */
/*                                                                                                       */
/*end procedure.                                                                                         */



/* ************************  Function Implementations ***************** */

FUNCTION fnc-fmt-dec-tc-litres RETURNS CHARACTER 
    (INPUT p-number AS DECIMAL):

    DEFINE VARIABLE result AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-str1 AS CHARACTER NO-UNDO.

    v-str1 = TRIM(REPLACE(STRING(p-number,'>>>>9.999<'), ".", ",")).

    RETURN v-str1.
        
END FUNCTION.

FUNCTION fnc-fmt-dec-tc-qnty RETURNS CHARACTER
    (INPUT p-number AS DECIMAL):

    DEFINE VARIABLE result AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-str1 AS CHARACTER NO-UNDO.

    v-str1 = TRIM(REPLACE(STRING(p-number,'->>>>>>>9.999<<'), ".", ",")).

    RETURN v-str1.

END FUNCTION.

DO: /* S */

    DO:  /* Нач_Иниц */
        /* Начальная инициализация таблицы */
        FOR EACH tt-rep1 NO-LOCK:
            DELETE tt-rep1.
        END.
    
        /* Поиск нач fact-order */
        RUN day-begin-fact-order IN this-procedure ( INPUT X-Date-Start /*v-begin-date*/
            , OUTPUT v-fact-order-start
            ).
        /* Поиск посл fact-order */
        RUN factord-end-day IN this-procedure ( INPUT X-Date-End /*v-end-date*/
            , OUTPUT v-fact-order-end
            ).



    END. /* Нач_Иниц */
    DO:

        FOR EACH tt-rep1 NO-LOCK:
            DELETE tt-rep1.
        END.

        /*        /* ТН-3371 18.02.2015 Арн. Если включена галочка "Текущий объект" в параметрах Закладка-1, то отчёт будет касаться связки Маг + Скл БЕЗ ВНУТРЕННИХ операций по прих/расх/возвр... между ними!!! */                                                                              */
        /*        if x-SelectObject = {&obj-currency} then                                                                                                                                                                                                                                        */
        /*        do:                                                                                                                                                                                                                                                                             */
        /*            find first buf_obj-list no-error.                                                                                                                                                                                                                                           */
        /*            if available buf_obj-list then                                                                                                                                                                                                                                              */
        /*            do:                                                                                                                                                                                                                                                                         */
        /*                /* Для этого во первых - найдём есть ли связка НашТекОбъект + Склад? */                                                                                                                                                                                                 */
        /*                find first ub.shop where                                                                                                                                                                                                                                                */
        /*                    ub.shop.obj-code = buf_obj-list.obj-code and                                                                                                                                                                                                                        */
        /*                    ub.shop.sub-store-on = yes and           /* Включена/выключена подвязка Склада для тек объекта. */                                                                                                                                                                  */
        /*                    ub.shop.sub-store-type <> '':U and       /* Здесь должен храниться тип объекта подвязанного как склад */                                                                                                                                                            */
        /*                    ub.shop.sub-store-code <> 0              /* Здесь должен храниться код объекта подвязанного как склад, 0 - объект не задан! */                                                                                                                                      */
        /*                    no-error.                                                                                                                                                                                                                                                           */
        /*                if available ub.shop then /* Если связка Маг+Скл есть (только для режима "Текущий объект" Закладка-1), то кроме Тек Объекта- добавляем в листинг формируемых для отчёта объектов (а это задаётся в obj-list) - Объект Склад и обрабатываем два объекта: Маг и Скл !!! */*/
        /*                do:                                                                                                                                                                                                                                                                     */
        /*                                                                                                                                                                                                                                                                                        */
        /*                    /* Для добавления данных в obj-list - обязательно заполняется его поле id. Значит найдём последнее знач id и инкрементируем его. Но попутно, по образцу в сущ коде, заполним obj-list полнее (номер бд, имя объекта) */                                             */
        /*                    find first ub.clients where                                                                                                                                                                                                                                         */
        /*                        ub.clients.obj-type = ub.shop.sub-store-type and                                                                                                                                                                                                                */
        /*                        ub.clients.obj-code = ub.shop.sub-store-code                                                                                                                                                                                                                    */
        /*                        no-lock no-error.                                                                                                                                                                                                                                               */
        /*                    if available ub.clients then                                                                                                                                                                                                                                        */
        /*                    do:                                                                                                                                                                                                                                                                 */
        /*                        find last buf_obj-list use-index pi no-error.                                                                                                                                                                                                                   */
        /*                        if available buf_obj-list then                                                                                                                                                                                                                                  */
        /*                        do:                                                                                                                                                                                                                                                             */
        /*                            v-temp-id = buf_obj-list.obj-id + 1.                                                                                                                                                                                                                        */
        /*                        end.                                                                                                                                                                                                                                                            */
        /*                        else                                                                                                                                                                                                                                                            */
        /*                        do:                                                                                                                                                                                                                                                             */
        /*                            v-temp-id = 1.                                                                                                                                                                                                                                              */
        /*                        end.                                                                                                                                                                                                                                                            */
        /*                                                                                                                                                                                                                                                                                        */
        /*                        create buf_obj-list.                                                                                                                                                                                                                                            */
        /*                                                                                                                                                                                                                                                                                        */
        /*                        assign                                                                                                                                                                                                                                                          */
        /*                            v-sub-store-on        = yes                        /* Флаг уточнённой проверки на предмет того, что есть связка Маг+Скл и она НЕ ПУСТАЯ! Ниже обратимся к объекту Склад для "изъятия" внутренних движений товаров между Маг и Склад */                      */
        /*                            buf_obj-list.obj-type = ub.clients.obj-type                                                                                                                                                                                                                 */
        /*                            buf_obj-list.obj-code = ub.clients.obj-code                                                                                                                                                                                                                 */
        /*                            buf_obj-list.obj-id   = v-temp-id                                                                                                                                                                                                                           */
        /*                            buf_obj-list.db-num   = ub.clients.db-num                                                                                                                                                                                                                   */
        /*                            buf_obj-list.obj-name = ub.clients.obj-name                                                                                                                                                                                                                 */
        /*                                                                                                                                                                                                                                                                                        */
        /*                            .                                                                                                                                                                                                                                                           */
        /*                    end.                                                                                                                                                                                                                                                                */
        /*                end.                                                                                                                                                                                                                                                                    */
        /*            end.                                                                                                                                                                                                                                                                        */
        /*        end.                                                                                                                                                                                                                                                                            */


        FOR EACH obj-list NO-LOCK: /* А. Тело_Отчёта */
        
         
 
            RUN rep/rpychk0.p (INPUT "r-shftc2"
                ,INPUT obj-list.obj-type
                ,INPUT obj-list.obj-code
                ,INPUT ?                    /*p-date-from*/
                ,INPUT ?                    /*p-date-to*/
                ,INPUT X-date-start         /*p-shift-date-from*/
                ,INPUT X-date-end           /*p-shift-date-to*/
                ,INPUT 0                 /*p-shift-num-start*/
                ,INPUT 99                /*p-shift-num-end*/
                ,INPUT ?                    /*p-inkas-code*/
                ) NO-ERROR.

            IF ERROR-STATUS:ERROR THEN
            DO:
                MESSAGE ERROR-STATUS:GET-MESSAGE(1) VIEW-AS ALERT-BOX.
            END.
            
            
            /*            { gbl/working.i }*/
            RUN gbl/conf-rd.p ( /* Запрашиваем - есть ли в текущей БД в указанном объекте(маг,скл...) параметр "алкоголь"?  */
                "alcohol":U,
                "":U,
                obj-list.obj-type,
                obj-list.obj-code,
                "":U,
                "":U,
                "":U,
                YES,
                OUTPUT v-par-val,
                OUTPUT v-par-type
                ) NO-ERROR.
            IF v-par-val <> "yes" THEN /* Если в текущей БД в указанном объекте параметр "алкоголь" = no тогда смотрим следующий объект(маг,склад...) */
            DO:
                NEXT.
            END. 
            ELSE
            DO: /* Если в указанном объекте(маг,склад...) найден установленный в yes параметр "алкоголь", то... */
                         _alc:  FOR EACH ub.gds-obj WHERE                               /* Смотрим все связки Товар-Объект (Т-О) по известному объекту(obj-type;obj-code) находим КодТовара */
                    ub.gds-obj.obj-type = obj-list.obj-type AND
                    ub.gds-obj.obj-code = obj-list.obj-code
                    NO-LOCK
                    :
                       
                   find   FIRST goods WHERE
                       goods.gds-code = gds-obj.gds-code no-lock no-error.
                        
                       
                   case x-SelectGood: 
        
     
                       when {&g-all}  then 
                           do: /* все товары */
          
                                         
                           end.
                
                       when {&g-grp} then 
                           do :
                               if available goods then 
                               do: 
                                   assign
                                       v-grp-name = ""
                                       v-found    = no
                                       .
                   
                                   _ii-grp: do ii-grp = 1 to num-entries(goods.grp-name, {&delim-grp}) - 1     /* 1 */ /* где {&delim-grp} = CHR(47) = "/". Фактически это уровни вложенности данной группы товаров */
                                       :
                                       assign
                                           v-grp-name = v-grp-name + entry(ii-grp, goods.grp-name, {&delim-grp}) + {&delim-grp} /* Вытаскиваем из полной цепочки - имя каждой группы для каждого уровня. Цепочка от корня до тек группы. */
                                           .
                                       if can-find(first tmp#grp no-lock where
                                           tmp#grp.grp-name = v-grp-name) then
                                       do:
                                           assign 
                                               v-found = yes.
                                           leave _ii-grp.
                                       end.
                                   end. /* 1 */                                                                    /* 1 */

                                   if not v-found then next _alc.
                               end.
                           end.
                       otherwise 
                       do:     /*список товаров*/
                           find  first gds-list no-lock
                               where goods.artic     = gds-list.artic
                               and goods.prod-type = gds-list.prod-type
                               and goods.prod-code = gds-list.prod-code no-error .
                           if not available  gds-list then next.
                
                       end.
                   end case.
                        
        
                    RUN gds-attr-value(
                        ub.gds-obj.gds-code,
                        {&attr-alcohol-prod},
                        OUTPUT v-par-val,
                        OUTPUT v-par-type
                        ).

                    IF v-par-val <> "" AND
                        v-par-val <> "no" THEN
                    DO: /* 1 */
                        v-alc-type-name = "".
                        v-alc-type-code = "".
                        FOR FIRST ub.alc-type-gds WHERE /* F Подготовка для определения Вид_Алкогольной_Продукции. */
                            ub.alc-type-gds.gds-code = ub.gds-obj.gds-code NO-LOCK
                            : 
                            DO: /* U */
                                FOR FIRST ub.alc-type WHERE /* Определение Вид_Алкогольной_Продукции. */
                                    ub.alc-type.alc-type-inner-code = ub.alc-type-gds.alc-type-inner-code NO-LOCK
                                    :
                                    DO: /* M */
                                        RUN gds-attr-value (alc-type-gds.gds-code ,
                                            {&attr-egais-name},
                                            OUTPUT v-par-val,
                                            OUTPUT v-par-type
                                            ).
                                        egais-name =   (IF v-par-val = ? OR v-par-val = ""  THEN   goods.gds-name ELSE v-par-val).
                                        ASSIGN
                                            v-alc-type-name = ub.alc-type.alc-type-name /* Запись Вид_Алкогольной_Продукции во временную переменную. */
                                            v-alc-type-code = ub.alc-type.alc-type-code /* Запись Код_Вида_Продукции во временную переменную. */
                                            .
                                        /*                                            find  first ub.bar-code where bar-code.gds-code =  alc-type-gds.gds-code  no-lock no-error.*/
                                        FOR EACH   ub.bar-code WHERE bar-code.gds-code =  alc-type-gds.gds-code AND bar-code.part-code = "" AND bar-code.node-code = 1 : 

                                            FOR EACH ub.chk-gds-pay WHERE 
                                                ub.chk-gds-pay.obj-type = obj-list.obj-type AND
                                                ub.chk-gds-pay.obj-code = obj-list.obj-code AND
                                                chk-gds-pay.algo-num = {&current-algo-1} AND 
                                                ub.chk-gds-pay.chk-date >= X-date-Start AND
                                                ub.chk-gds-pay.chk-date <= X-date-End AND
                                                ub.chk-gds-pay.b-code  = ub.bar-code.b-code
                                           
                                                NO-LOCK
                                          
                                                :
                                                /*                                                                                                                                                                                             */
                                                /*                                            if (lookup(ub.doc-line.ext-doc-type, {&TDEDT_out_list}) > 0) or (ub.doc-line.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass-full}) then /* Если работаем с Расходом (список кодов расхода содержится в TDEDT_out_list) */*/
                                                /*                                            do:                                                                                                                                                                                                                 */
                                                /*                                                  if doc-line.ext-doc-type = {&TDEDT_Ras_Vnesh} or doc-line.ext-doc-type = {&TDEDT_Vozvrat_Vnesh} then do:*/
                                                       

                                                /*                                                if v-sub-store-on = yes then /* Если работаем с гарантированно существующим объектом Склад... */                                                                                                                     */
                                                /*                                                do:                                                                                                                                                                                                                  */
                                                /*                                                    /* ТН-3371 17.02.2015 Арн. По концепции (и по ТЗ) - не включать в отчёт типы док: "приход/расход/возврат ВНУТРЕННИЕ", т.е. имеющие место ТОЛЬКО МЕЖДУ связанными МАГ и СКЛ (остальные внутр док - учитываются) */*/
                                                /*                                                    if (can-find(first obj-list no-lock where                                                                                                                                                                        */
                                                /*                                                        obj-list.obj-type = buf_trn-doc.cli-type and                                                                                                                                                                 */
                                                /*                                                        obj-list.obj-code = buf_trn-doc.cli-code))                                                                                                                                                                   */
                                                /*                                                        and                                                                                                                                                                                                          */
                                                /*                                                        (ub.doc-line.ext-doc-type = {&TDEDT_Pri_Perem} or       /* Приход внутренний - обрабатываем в разделе "Приход" (см. выше) */                                                                                 */
                                                /*                                                        ub.doc-line.ext-doc-type = {&TDEDT_Ras_Perem}  or       /* Расход внутренний */                                                                                                                              */
                                                /*                                                        ub.doc-line.ext-doc-type = {&TDEDT_Vozvrat_Perem})     /* Возврат внутренний - обрабатываем в разделе "Приход" (см. выше) */                                                                                 */
                                                /*                                                        then                                                                                                                                                                                                         */
                                                /*                                                        next.                                                                                                                                                                                                        */
                                                /*                                                end.                                                                                                                                                                                                                 */
                                                RUN gds-attr-value (
                                                    INPUT alc-type-gds.gds-code,
                                                    INPUT {&attr-mark},
                                                    OUTPUT v-attr-mark-value,
                                                    OUTPUT v-value
                                                    ).

                                                /*крепкие напитки*/      
                                                if v-attr-mark-value = "yes" then 
                                                do:
                                                    find first buf_chk-gds-attr no-lock where buf_chk-gds-attr.doc-code = ub.chk-gds-pay.doc-code 
                                                                                          and buf_chk-gds-attr.line-num = ub.chk-gds-pay.line-num 
                                                                                          and buf_chk-gds-attr.attr-code = "mark-code" no-error .
                                                    if AVAILABLE buf_chk-gds-attr then do:
                                                        do ii = 1 to NUM-ENTRIES (buf_chk-gds-attr.attr-value,","):
                                                            CREATE tt-rep1.
                                                            /*                                  v-cnt-line = v-cnt-line + 1.*/
                                                            /*                                                run ConvertStr-ext-doc-type (input ub.doc-line.ext-doc-type, output v-name-ext-doc-type).*/
                                                            ASSIGN
                                                                tt-rep1.obj-code                = obj-list.obj-code
                                                                tt-rep1.obj-type                = obj-list.obj-type
                                               
                                                                tt-rep1.exp-doc-line-code       = chk-gds-pay.doc-code           /* Служебное поле (не на экран) */
                                                                tt-rep1.exp-alc-type-code       = v-alc-type-code             /* Служебное поле (не на экран) */
                                                                tt-rep1.exp-time                = chk-gds-pay.chk-time
                                                                tt-rep1.exp-td-fact-date        = chk-gds-pay.chk-date        /* Служебное поле (не на экран) */
                                                                /*                                                tt-rep1.doc-line-fact-order     = chk-gds-pay.chk-date       /* Служебное поле (не на экран) */*/
                                                                /*                                                    tt-rep1.exp-categoryes-prod     = v-name-ext-doc-type       /* 11 */*/
                                                                tt-rep1.gds-code                = goods.gds-code
                                                                tt-rep1.exp-name                = egais-name 
                                                                tt-rep1.exp-alc-type-name       = v-alc-type-name       /* 12 */
                                                                tt-rep1.exp-volume-piece-litres = goods.ms-base   
                                                                tt-rep1.cnt-line                = tt-rep1.cnt-line + 1 
                                                                tt-rep1.exp-fact-qnty           = if chk-gds-pay.eff-doc-qnty < 0 then -1 else 1
                                                                /*-                                                    (if      = ? then 0 else        chk-gds-pay.eff-doc-qnty)*/
                                                                tt-rep1.alc-mark                = trim(entry(ii, buf_chk-gds-attr.attr-value,","),"-")                                            
                                                                .

                                                            
                                                        end.    
                                                    end.      
                                                end.
                                                /*пиво*/ 
                                                else 
                                                do:
                                                    CREATE tt-rep1.
                                                    /*                                  v-cnt-line = v-cnt-line + 1.*/
                                                    /*                                                run ConvertStr-ext-doc-type (input ub.doc-line.ext-doc-type, output v-name-ext-doc-type).*/
                                                    ASSIGN
                                                        tt-rep1.obj-code                = obj-list.obj-code
                                                        tt-rep1.obj-type                = obj-list.obj-type
                                               
                                                        tt-rep1.exp-doc-line-code       = chk-gds-pay.doc-code           /* Служебное поле (не на экран) */
                                                        tt-rep1.exp-alc-type-code       = v-alc-type-code             /* Служебное поле (не на экран) */
                                                        tt-rep1.exp-time                = chk-gds-pay.chk-time
                                                        tt-rep1.exp-td-fact-date        = chk-gds-pay.chk-date        /* Служебное поле (не на экран) */
                                                        /*                                                tt-rep1.doc-line-fact-order     = chk-gds-pay.chk-date       /* Служебное поле (не на экран) */*/
                                                        /*                                                    tt-rep1.exp-categoryes-prod     = v-name-ext-doc-type       /* 11 */*/
                                                        tt-rep1.gds-code                = goods.gds-code
                                                        tt-rep1.exp-name                = egais-name 
                                                        tt-rep1.exp-alc-type-name       = v-alc-type-name       /* 12 */
                                                        tt-rep1.exp-volume-piece-litres = goods.ms-base   
                                                        tt-rep1.cnt-line                = tt-rep1.cnt-line + 1 
                                                        tt-rep1.exp-fact-qnty           = tt-rep1.exp-fact-qnty +    chk-gds-pay.eff-doc-qnty
                                                        /*-                                                    (if      = ? then 0 else        chk-gds-pay.eff-doc-qnty)*/
                                            
                                                        .


                                                end.    
                                            /*                                           message tt-rep1.exp-name chk-gds-pay.chk-date view-as alert-box.*/
                                            END.
                                        END.                        
                                    END. /* M */
                                END.
                            END. /* U */
                        END. /* F */
                    END. /* 1 */
                END.
            END.

 FOR EACH tt-rep1  WHERE tt-rep1.obj-type = obj-list.obj-type AND tt-rep1.obj-code = obj-list.obj-code BREAK BY  tt-rep1.exp-td-fact-date   BY tt-rep1.exp-alc-type-code  : 
    
                
                IF  first-of(tt-rep1.exp-alc-type-code ) THEN 
                DO: 

                    v-qnty = 0.
                END.

                v-qnty = v-qnty + tt-rep1.exp-fact-qnty.

                IF  LAST-OF(tt-rep1.exp-alc-type-code )   THEN 
                DO:
                    
                    FIND FIRST buf_tt WHERE 
                    buf_tt.obj-code = obj-list.obj-code AND     
                    buf_tt.obj-type = obj-list.obj-type AND 
                    buf_tt.exp-td-fact-date =   tt-rep1.exp-td-fact-date AND
/*                        buf_tt.exp-volume-piece-litres = tt-rep1.exp-volume-piece-litres AND*/
                        buf_tt.itog_volume = 100 AND 
                        buf_tt.exp-alc-type-code =  tt-rep1.exp-alc-type-code NO-LOCK NO-ERROR .
                    IF NOT AVAILABLE buf_tt THEN 
                    DO:
                        CREATE buf_tt.
                         buf_tt.obj-code = obj-list.obj-code. 
                    buf_tt.obj-type = obj-list.obj-type .
                         buf_tt.itog_volume = 100 .
                        buf_tt.exp-td-fact-date =   tt-rep1.exp-td-fact-date .
                        buf_tt.exp-alc-type-code =  tt-rep1.exp-alc-type-code .
                 
                    END.     
                                            buf_tt.exp-volume-piece-litres = tt-rep1.exp-volume-piece-litres.   
                    
                      buf_tt.cnt-line = 0.
                    buf_tt.exp-alc-type-name = tt-rep1.exp-alc-type-name.
               buf_tt.exp-fact-qnty = v-qnty.
                END.  
            END.

/*                 for each tt-rep1  where tt-rep1.obj-type = obj-list.obj-type and tt-rep1.obj-code = obj-list.obj-code break by  tt-rep1.exp-td-fact-date   by  tt-rep1.exp-volume-piece-litres by tt-rep1.gds-code  :*/
/*                                                                                                                                                                                                                      */
/*                                                                                                                                                                                                                      */
/*                        if  first-of(tt-rep1.gds-code ) then                                                                                                                                                          */
/*                        do:                                                                                                                                                                                           */
/*                                                                                                                                                                                                                      */
/*                            v-qnty = 0.                                                                                                                                                                               */
/*                        end.                                                                                                                                                                                          */
/*                                                                                                                                                                                                                      */
/*                        v-qnty = v-qnty + tt-rep1.exp-fact-qnty.                                                                                                                                                      */
/*                                                                                                                                                                                                                      */
/*                        if  last-of(tt-rep1.gds-code )   then                                                                                                                                                         */
/*                        do:                                                                                                                                                                                           */
/*                                                                                                                                                                                                                      */
/*                            find first buf_tt where                                                                                                                                                                   */
/*                            buf_tt.obj-code = obj-list.obj-code and                                                                                                                                                   */
/*                            buf_tt.obj-type = obj-list.obj-type and                                                                                                                                                   */
/*                            buf_tt.exp-td-fact-date =   tt-rep1.exp-td-fact-date and                                                                                                                                  */
/*                                buf_tt.exp-volume-piece-litres = tt-rep1.exp-volume-piece-litres and                                                                                                                  */
/*                                buf_tt.itog_volume = 1 and                                                                                                                                                            */
/*                                buf_tt.gds-code = tt-rep1.gds-code                                                                                                                                                    */
/*                                and                                                                                                                                                                                   */
/*                                buf_tt.exp-alc-type-code =  tt-rep1.exp-alc-type-code no-lock no-error .                                                                                                              */
/*                            if not available buf_tt then                                                                                                                                                              */
/*                            do:                                                                                                                                                                                       */
/*                                create buf_tt.                                                                                                                                                                        */
/*                                 buf_tt.obj-code = obj-list.obj-code.                                                                                                                                                 */
/*                            buf_tt.obj-type = obj-list.obj-type .                                                                                                                                                     */
/*                                 buf_tt.itog_volume = 1 .                                                                                                                                                             */
/*                                 buf_tt.gds-code = tt-rep1.gds-code .                                                                                                                                                 */
/*                                buf_tt.exp-td-fact-date =   tt-rep1.exp-td-fact-date .                                                                                                                                */
/*                                buf_tt.exp-alc-type-code =  tt-rep1.exp-alc-type-code .                                                                                                                               */
/*                                buf_tt.exp-volume-piece-litres = tt-rep1.exp-volume-piece-litres.                                                                                                                     */
/*                                                                                                                                                                                                                      */
/*                            end.                                                                                                                                                                                      */
/*                                buf_tt.exp-alc-type-name    = tt-rep1.exp-alc-type-name .                                                                                                                             */
/*                              buf_tt.cnt-line = tt-rep1.cnt-line.                                                                                                                                                     */
/*                            buf_tt.exp-name = tt-rep1.exp-name.                                                                                                                                                       */
/*                       buf_tt.exp-fact-qnty = v-qnty.                                                                                                                                                                 */
/*                        end.                                                                                                                                                                                          */
/*                    end.                                                                                                                                                                                              */

        END. /* А. Тело_Отчёта */

        /*procedure tt-itog:                             */
        /*define input parameter p-obj-code as integer.  */
        /*define input parameter p-obj-type as character.*/
        /*define variable v-fact-qnty as decimal.        */
        /*                                               */
             
            
           
            
        /* BUFFER-COPY buf_tt to tt-rep1.*/
 

        /*end.*/

        /*        do:  /* B Присвоение в поля таблицы="№ п/п" номеров по порядку, так будет выглядеть порядок в отчёте. */*/
        /*                                                                                                                */
        /*            /*FF*****************************************************************************/                  */
        DEFINE VARIABLE v-inc-litres-line AS DECIMAL   INITIAL 0 NO-UNDO.
        DEFINE VARIABLE v-out-litres-line AS DECIMAL   INITIAL 0 NO-UNDO.
        DEFINE VARIABLE v-inc-litres-tot  AS DECIMAL   INITIAL 0 NO-UNDO.
        DEFINE VARIABLE v-fact-qnty       AS DECIMAL.
        DEFINE VARIABLE v-inc-qnty-tot    AS DECIMAL   INITIAL 0 NO-UNDO.
        DEFINE VARIABLE v-name            AS CHARACTER .
        DEFINE VARIABLE v-liters          AS DECIMAL.
        DEFINE VARIABLE itog_ii           AS INTEGER .
        DEFINE VARIABLE v-dec             AS CHARACTER NO-UNDO.
        /*            v-cnt-line = 0.                                                                                     */
        /*                                                                                                                */
        /*            for each tt-rep1 no-lock                                                                            */
        /*                /*        by tt-rep1.alc-type-code*/                                                            */
        /*                /*        by tt-rep1.date-trn*/                                                                 */
        /*                by tt-rep1.doc-line-fact-order                                                                  */
        /*                /*        by tt-rep1.exp-alc-type-code*/                                                        */
        /*                by tt-rep1.exp-td-fact-date                                                                     */
        /*                :                                                                                               */
        /*                                                                                                                */
        /*                                                                                                                */
        /*                /* Для РАСХОДА */                                                                               */
        /*                v-cnt-line = v-cnt-line + 1.                                                                    */
        /*                tt-rep1.cnt-line = v-cnt-line.                                                                  */
        /*                v-out-litres-line =                                                                             */
        /*                    if ((tt-rep1.exp-volume-piece-litres * tt-rep1.exp-fact-qnty) / 10) = ? then 0              */
        /*                else ((tt-rep1.exp-volume-piece-litres * tt-rep1.exp-fact-qnty) / 10).                          */
        /*                v-out-litres-tot =                                                                              */
        /*                    (if v-out-litres-tot = ? then 0 else v-out-litres-tot) +                                    */
        /*                    (if v-out-litres-line = ? then 0 else v-out-litres-line). /* 15/1 */                        */
        /*                v-out-qnty-tot =                                                                                */
        /*                    (if v-out-qnty-tot = ? then 0 else v-out-qnty-tot) +                                        */
        /*                    (if tt-rep1.exp-fact-qnty = ? then 0 else tt-rep1.exp-fact-qnty). /* 15/2 */                */
        /*            end.                                                                                                */
        /*            v-cnt-line = 0.                                                                                     */
        /*        end. /* B */                                                                                            */

        FIND FIRST tt-rep1 NO-LOCK NO-ERROR.
        IF ERROR-STATUS:ERROR THEN
        DO:
            MESSAGE "Для установленных параметров отчета" SKIP 
                "- данные отсутствуют!" VIEW-AS ALERT-BOX WARNING.
        END.
        
        
        
    
        
        
    END. /* CMD-1 */
END.

/*создание итогов по каждому дню*/




RUN get-full-path-RepViewer(OUTPUT v-full-path-RepView).   
  
RUN get-report-num IN parParentProc(OUTPUT g#report-num).
/*if  x-SelectObject = {&o-choice} then do:*/
FOR EACH obj-list : 
   
    RUN define-full-path-Report(INPUT g#report-num, INPUT obj-list.obj-code , OUTPUT v-file-name-rep-htm).
    RUN create-file(v-file-name-rep-htm).       
        
    FOR EACH tt-rep1 NO-LOCK WHERE tt-rep1.obj-code = obj-list.obj-code AND tt-rep1.obj-type = obj-list.obj-type AND tt-rep1.cnt-line <> 0 
        BREAK BY   tt-rep1.exp-name BY  tt-rep1.exp-td-fact-date BY tt-rep1.exp-name : 
                
        /*if first-of*/


        
        IF FIRST-OF (tt-rep1.exp-td-fact-date) THEN 
        DO: 
            v-fact-qnty = 0.
            v-liters = 0.
            v-name = "".
            
        END.
        
        v-name = tt-rep1.exp-name.
        v-liters =  tt-rep1.exp-volume-piece-litres.
      v-fact-qnty = v-fact-qnty + tt-rep1.exp-fact-qnty.        
  
         
        IF LAST-OF ( tt-rep1.exp-td-fact-date )  THEN  
        DO:
            itog_ii = itog_ii + 1 .
            FIND FIRST buf_itog  WHERE  
                buf_itog.gds-code  =  tt-rep1.gds-code   AND 
                buf_itog.obj-code =  obj-list.obj-code AND 
                buf_itog.obj-type = obj-list.obj-type AND
                buf_itog.exp-volume-piece-litres = 0
                AND
                buf_itog.exp-td-fact-date = tt-rep1.exp-td-fact-date 
                AND
                buf_itog.cnt-line  = 0 
                     NO-LOCK NO-ERROR .
                    
            IF NOT  AVAILABLE buf_itog THEN 
            DO: 
             
                CREATE buf_itog.
                ASSIGN 
                    buf_itog.exp-td-fact-date        = tt-rep1.exp-td-fact-date
                    buf_itog.exp-volume-piece-litres = 0
                    buf_itog.gds-code                = tt-rep1.gds-code
                    buf_itog.obj-code                = obj-list.obj-code  
                    buf_itog.obj-type                = obj-list.obj-type
                    buf_itog.cnt-line                = 0 .
            END.
        
            buf_itog.exp-name    =  v-name.
            buf_itog.itog_ii = itog_ii .
            buf_itog.exp-alc-type-code = tt-rep1.exp-alc-type-code.
            buf_itog.exp-volume-piece-litres =  v-liters.
            buf_itog.exp-fact-qnty  =  v-fact-qnty .
        END.
     
    END.
      

     
    RUN fmtcli-get-client IN this-procedure (
        INPUT obj-list.obj-type,
        INPUT obj-list.obj-code
        ).
    v-addres = v-fmtcli-addres.
        
    RUN proc-create-HTML (INPUT v-addres, INPUT v-inc-qnty-tot, INPUT v-inc-litres-tot, INPUT v-out-qnty-tot , INPUT v-out-litres-tot, INPUT obj-list.obj-name, INPUT obj-list.obj-code, INPUT obj-list.obj-type).

    v-search = v-search + " "  + v-file-name-rep-htm.
    v-search = trim(v-search," ") .
END.
    run prn-lib-reportviewer in this-procedure (
        input parParentProc
        ,input v-search
        ,input "" 
        ) no-error.
    if error-status:error then
    do:
        return .
    end.



PROCEDURE my-watch-table: /* Процедура для моей ОТЛАДКИ! Арн. */
    /* Запись наблюдаемых таблиц в файл */
&scope tt-table tt-rep1
    /*&scope tt-table gds-list*/
    /*&scope tt-table X_dis-card*/
    /*    define input parameter p-str1 as character no-undo.*/
    /*    define input parameter p-table-name as character no-undo.*/

    DEFINE VARIABLE v-full-file-name   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-message          AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-table-handle     AS HANDLE    NO-UNDO.
    DEFINE VARIABLE v-cnt-field        AS INTEGER   NO-UNDO.
    DEFINE VARIABLE v-list-field-name  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-list-field-label AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-list-field-type  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-ii               AS INTEGER   NO-UNDO.

    DEFINE BUFFER {&tt-table} FOR {&tt-table}.
    /*    define buffer buf5_dcards for {&tt-table}.*/
    /*    define variable tt-handle as handle no-undo.*/

    /* Получаем:
       спискок полей таблицы - name;
       спискок полей таблицы - label;
       спискок типов полей таблицы - type. */
    v-table-handle = BUFFER {&tt-table}:HANDLE.
    v-cnt-field = v-table-handle:NUM-FIELDS.
    DO v-ii = 1 TO v-cnt-field:
        v-list-field-name =
            (IF v-list-field-name <> "" THEN
            v-list-field-name + "$" + v-table-handle:BUFFER-FIELD(v-ii):name
            ELSE
            v-table-handle:BUFFER-FIELD(v-ii):name).
        v-list-field-label =
            (IF v-list-field-label <> "" THEN
            v-list-field-label + "$" + v-table-handle:BUFFER-FIELD(v-ii):label
            ELSE
            v-table-handle:BUFFER-FIELD(v-ii):label).
        v-list-field-type =
            (IF v-list-field-type <> "" THEN
            v-list-field-type + "$" + v-table-handle:BUFFER-FIELD(v-ii):data-type
            ELSE
            v-table-handle:BUFFER-FIELD(v-ii):data-type).
    END.

    /*    tt-handle:name = p-table-name.*/
    /*    tt-handle = handle(p-table-name).*/
    /*    tt-handle = handle(p-table-name).*/
    /*    tt-handle = buffer dc-list:handle.*/
    /*    tt-handle = buf_tt.a:get-buffer-handle(p-table-name).*/
    /*    tt-handle = tt-handle:get-buffer-handle(p-table-name):handle.*/
    /*    tt-handle = tt-handle:get-buffer-handle(p-table-name).*/
    /*    tt-table = dc-list:get-buffer-handle(p-table-name).*/
    /*    tt-handle = buffer tt-table:handle.*/
    /*{ Zadachi+Test_Arn/my-include-001.i point-A p-table-name }*/

    /* Задаём жёстко имя файла и полный путь */
    /*    v-full-file-name = "C:\work15_0\my-watch-table.txt".*/
    v-full-file-name = "C:\work15_0\my-watch2-{&tt-table}.txt".

    IF SEARCH(v-full-file-name) = ? THEN
    DO:
        MESSAGE "Не найден файл отчёта: " v-full-file-name VIEW-AS ALERT-BOX ERROR.
    END.

    /* Сохранение потока в созданный файл my-watch-table.txt */
    OUTPUT stream MyWatch-strm to value(v-full-file-name) /*append*/ /*no-convert*/ convert target "utf-8".
    PUT STREAM MyWatch-strm UNFORMATTED
        TODAY FORMAT "99.99.9999" " " STRING(TIME, "HH:MM") " " "Исследуемая таблица: " "{&tt-table}" "." SKIP /* Для вывода текста, отдельных слов - только пробел, не ставить "+" */
        v-list-field-label SKIP
        v-list-field-name SKIP
        v-list-field-type SKIP
        .
    IF NOT CAN-FIND(FIRST {&tt-table}) THEN
    DO:
        v-message = "Исследуемая таблица {&tt-table} пуста!".
        PUT STREAM MyWatch-strm UNFORMATTED
            v-message
            .
        MESSAGE "My-watch-table: " v-message VIEW-AS ALERT-BOX INFORMATION.
    END.

    FOR EACH /*buf5_dcards*/ {&tt-table} NO-LOCK:
        EXPORT STREAM MyWatch-strm DELIMITER "$" /*buf5_dcards*/ {&tt-table}. /* Вставляем сюда вручную свою таблицу!!! */
    END.
    OUTPUT stream MyWatch-strm close.
END PROCEDURE.


PROCEDURE proc-create-HTML:
    /*************************/
    DEFINE VARIABLE v-volume-piece-litres     AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-fact-qnty               AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-inc-total-quontity      AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-exp-volume-piece-litres AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-exp-fact-qnty           AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-exp-total-quontity      AS CHARACTER NO-UNDO.
    /* Итоговые данные */
    DEFINE INPUT PARAMETER p-addres AS CHARACTER.
    DEFINE INPUT PARAMETER p-inc-qnty-tot AS DECIMAL NO-UNDO.
    DEFINE INPUT PARAMETER p-inc-litres-tot AS DECIMAL NO-UNDO.
    DEFINE INPUT PARAMETER p-out-qnty-tot AS DECIMAL NO-UNDO.
    DEFINE INPUT PARAMETER p-out-litres-tot AS DECIMAL NO-UNDO.
    /*    define variable*/
    DEFINE INPUT PARAMETER p-obj-name AS CHARACTER.
    DEFINE INPUT PARAMETER p-obj-code AS INTEGER NO-UNDO.
    DEFINE INPUT PARAMETER p-obj-type AS CHAR NO-UNDO.  
    DEFINE VARIABLE v-kpp             AS CHAR.
    DEFINE VAR      v-inn             AS CHAR.
    DEFINE VARIABLE var-type          AS CHAR.
    DEFINE VARIABLE v-inc-litres-tot2 AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-out-litres-tot2 AS CHARACTER NO-UNDO.
    DEFINE BUFFER buf_tt-itog-lvl FOR tt-rep1.
    DEFINE BUFFER buf_tt          FOR tt-rep1.
    DEFINE BUFFER buf_tt-itog     FOR tt-rep1.
    v-inc-litres-tot2 = fnc-fmt-dec-tc-litres(p-inc-litres-tot).
    v-out-litres-tot2 = fnc-fmt-dec-tc-litres(p-out-litres-tot).
    /*   run fmtcli-get-client in this-procedure (*/
    /*                input p-obj-type,           */
    /*                input p-obj-code            */
    /*                ).                          */
                
    { gbl/hostname.i p-obj-type p-obj-code v-cntxt-host-code-obj v-cntxt-host-name-obj }
                
    RUN fmtcli-get-client IN this-procedure (
        INPUT {&cmp},
        INPUT v-cntxt-host-code-obj
        ).
                
    RUN clntattr-value IN THIS-PROCEDURE
        (INPUT p-obj-type,
        INPUT p-obj-code,
        INPUT {&attr-kpp},
        OUTPUT v-kpp,
        OUTPUT var-type).
    /*                                                 */
    /*             RUN clntattr-value IN THIS-PROCEDURE*/
    /*    (INPUT p-obj-type,                           */
    /*     INPUT p-obj-code,                           */
    /*     input {&attr-inn},                          */
    /*     OUTPUT v-inn,                               */
    /*     OUTPUT var-type).                           */
     
     
    DO:
        OUTPUT stream OutStr-html to value(v-file-name-rep-htm) append convert target 'UTF-8'.
        PUT STREAM OutStr-html UNFORMATTED
            "<!DOCTYPE HTML>" SKIP
            ' <html>' SKIP
            '  <head>' SKIP
            '   <meta charset="utf-8">' SKIP
            '    <style type="text/css">' SKIP
              
            '      table ' + chr(123) + ' border-collapse: collapse; font-size:9pt; font-family:Calibri; table-layout: fixed; width: 540px; hight:  padding: 8px;  ' + chr(125) SKIP
            '      td ' + chr(123) ' border: 1px black solid; word-wrap:break-word; ' + chr(125) SKIP
            '      htm' SKIP
            '      .rotate ' + chr(123) SKIP
            '        -webkit-transform: rotate(-90deg);' SKIP
            '        -moz-transform: rotate(-90deg);' SKIP
            '        -ms-transform: rotate(-90deg);' SKIP
            '        -o-transform: rotate(-90deg);' SKIP
            '        transform: rotate(-90deg);' SKIP


            '        -webkit-transform-origin: 50% 50%;' SKIP
            '        -moz-transform-origin: 50% 50%;' SKIP
            '        -ms-transform-origin: 50% 50%;' SKIP
            '        -o-transform-origin: 50% 50%;' SKIP
            '        transform-origin: 50% 50%;' SKIP


            '        filter: progid:DXImageTransform.Microsoft.BasicImage(rotation=3);' SKIP
            '          ' + chr(125) SKIP
            '            th' + ' ' + chr(123) SKIP
            '            border: 1px black solid;' SKIP
            '            word-wrap: break-word;' SKIP
            '          ' + chr(125) SKIP
            '   </style>' SKIP
            '  </head>' SKIP
            . 
    END. 

            
    PUT STREAM OutStr-html UNFORMATTED
        ' <body>' SKIP
        '   <table name="Лист1" fit_to_page="true" orientation="Portrait" outline_below="false">' SKIP
        
       
        '     <thead>' SKIP
        '       <tr class="set_columns">' SKIP                 
        '         <td style="width: 41px; border: none;"></td>' SKIP  
        '         <td style="width: 74px; border: none;"></td>' SKIP   
        '         <td style="width: 560px; border: none;"></td>' SKIP     
        '         <td style="width: 100px; border: none;"></td>' SKIP    
        '         <td style="width: 77px; border: none;"></td>' SKIP 
        '         <td style="width: 70px; border: none;"></td>' SKIP  
        '         <td style="width: 77px; border: none;"></td>' SKIP  
        '       </tr>' SKIP
        .
        
    DO:  
     
        PUT STREAM OutStr-html UNFORMATTED
      
      
            '       <tr>' SKIP
            '         <td style="border: none;"></td>' SKIP
            '         <td style="border: none;"></td>' SKIP
              '         <td style="border: none;"></td>' SKIP
            '         <td style="border: none;"></td>' SKIP
            '         <td style="border: none;"></td>' SKIP
            '         <td colspan="2" style="border: none;  text-align: left;  font-size: 12pt;">Приложение №1</td>' SKIP

            '</tr>' SKIP
      
            '       <tr>' SKIP
            '         <td style="border: none;"></td>' SKIP
            '         <td style="border: none;"></td>' SKIP
            '         <td style="border: none;"></td>' SKIP
                '         <td style="border: none;"></td>' SKIP
            '         <td style="border: none;"></td>' SKIP
            '         <td colspan="2" style="border: none; text-align: left;  font-size: 12pt;">к приказу Федеральной службы</td>' SKIP

            '</tr>' SKIP
            
            '       <tr>' SKIP
            '         <td style="border: none;"></td>' SKIP
            '         <td style="border: none;"></td>' SKIP
                '         <td style="border: none;"></td>' SKIP
            '         <td style="border: none;"></td>' SKIP
            '         <td style="border: none;"></td>' SKIP
            '         <td colspan="2" style="border: none;text-align: left;  font-size: 12pt;">по регулированию алкогольного рынка</td>' SKIP

            '</tr>' SKIP
            
            '       <tr>' SKIP
            '         <td style="border: none;"></td>' SKIP
            '         <td style="border: none;"></td>' SKIP
            '         <td style="border: none;"></td>' SKIP
              '         <td style="border: none;"></td>' SKIP
            '         <td style="border: none;"></td>' SKIP
            '         <td colspan="2" style="border: none;   text-align: left;  font-size: 12pt;">от 19.06.2015 № 164</td>' SKIP

            '</tr>' SKIP
            
            
           
            '       <tr>' SKIP
            '         <td style="border: none;"></td>' SKIP
            '         <td style="border: none;"></td>' SKIP
            '         <td style="border: none;"></td>' SKIP
            '         <td style="border: none;"></td>' SKIP
            '         <td style="border: none;"></td>' SKIP
            '         <td style="border: none;"></td>' SKIP
            '         <td style="border: none;"></td>' SKIP
            '</tr>' SKIP

            
            
            '       <tr>' SKIP
            '         <td style="border: none;"></td>' SKIP
            '         <td style="border: none;"></td>' SKIP
            '         <td style="border: none;"></td>' SKIP
            '         <td style="border: none;"></td>' SKIP
            '         <td style="border: none;"></td>' SKIP
            '         <td style="border: none;"></td>' SKIP
            '         <td style="border: none;"></td>' SKIP
            '</tr>' SKIP
            
            
            
            '       <tr>' SKIP
            '         <td colspan="7" style="border: none;   text-align: center;  font-size: 12pt;  font-weight: bold;">Журнал учета объема розничной продажи алкогольной и спиртосодержащей продукции</td>' SKIP
            
            '</tr>' SKIP
            
/*                                                                                                                                                                          */
/*            '       <tr>' SKIP                                                                                                                                            */
/*            '         <td colspan="7" style="border: none;  text-align: center;  font-size: 12pt;  font-weight: bold;">алкогольной и спиртосодержащей продукции</td>' SKIP*/
/*                                                                                                                                                                          */
/*            '</tr>' SKIP                                                                                                                                                  */
            
            
            
            '       <tr>' SKIP
            '         <td style="border: none;"></td>' SKIP
            '         <td style="border: none;"></td>' SKIP
            '         <td style="border: none;"></td>' SKIP
            '         <td style="border: none;"></td>' SKIP
            '         <td style="border: none;"></td>' SKIP
            '         <td style="border: none;"></td>' SKIP
            '         <td style="border: none;"></td>' SKIP
            '</tr>' SKIP
             
             
             
            '       <tr style="height: 60px;">' SKIP
            '         <td text_wrap="true" colspan="3" style="border: none;  text-align: left;  font-size: 12pt;">Наименование организации, Ф.И.О. индивидуального предпринимателя</td>' SKIP
            '         <td colspan="4" style="border: none; border-bottom: 1px solid black; height: 14px;  text-align: left; font-weight: bold; font-size: 12pt;">' + p-obj-name   + '</td>' SKIP
            
            '</tr>' SKIP
     
             
            '       <tr style="height: 40px;">' SKIP
            '         <td text_wrap="true" colspan="3" style="border: none; text-align: left;  font-size: 12pt;">ИНН/КПП организации, ИНН индивидуального предпринимателя</td>' SKIP
            '         <td colspan="4" style="border: none; border-bottom: 1px solid black; height: 14px;  text-align: left;  font-weight: bold; font-size: 12pt;">' + v-fmtcli-inn + "/"+  v-kpp + '</td>' SKIP
            
            '</tr>' SKIP
            
            
    
             
             
            '       <tr style="height: 60px;">' SKIP
            '         <td text_wrap="true" colspan="3" style="border: none;  text-align: left;  font-size: 12pt;">Адрес места осуществления деятельности организацией, индивидуальным предпринимателем</td>' SKIP
            '         <td colspan="4" style="border: none; border-bottom: 1px solid black; height: 14px;  text-align: left; font-weight: bold; font-size: 12pt;">' + p-addres + '</td>' SKIP
            
            '</tr>' SKIP
             
             
            '        <tr style="height: 30px;">' SKIP
            '         <td style="border: none;"></td>' SKIP
            '         <td style="border: none;"></td>' SKIP
            '         <td style="border: none;"></td>' SKIP
            '         <td style="border: none;"></td>' SKIP
            '         <td style="border: none;"></td>' SKIP
            '         <td style="border: none;"></td>' SKIP
            '         <td style="border: none;"></td>' SKIP
            '</tr>' SKIP
            '</thead>' SKIP
            .
          
    END.

    DO:
        PUT STREAM OutStr-html UNFORMATTED
/*                '     <thead>' skip               */
/*            '       <tr class="set_columns">' skip*/
        
/*            '     <tbody>' SKIP                     */
            '       <tr style="height: 60px;">' SKIP


            '         <td text_wrap="true"  style="background-color:#ffffcc; font-weight: bold; text-align: center; border: 1px solid black;">№ п/п</td>' SKIP
            '         <td  text_wrap="true" style="background-color:#ffffcc; font-weight: bold; text-align: center;border: 1px solid black;">Дата розничной продажи</td>' SKIP
            '         <td text_wrap="true" style="background-color:#ffffcc; font-weight: bold; text-align: center;border: 1px solid black;">Штриховой код</td>' SKIP
            '         <td  text_wrap="true" style="background-color:#ffffcc; font-weight: bold; text-align: center;border: 1px solid black;">Наименование продукции</td>' SKIP
            '         <td  text_wrap="true" style="background-color:#ffffcc; font-weight: bold; text-align: center;border: 1px solid black;">Код вида продукции</td>' SKIP
            '         <td  text_wrap="true" style="background-color:#ffffcc; font-weight: bold; text-align: center;border: 1px solid black;">Емкость (л)</td>' SKIP
            '         <td  text_wrap="true" style="background-color:#ffffcc; font-weight: bold; text-align: center;border: 1px solid black;">Количество (штук)</td>' SKIP

            '</tr>' SKIP
            '       <tr>' SKIP
            '         <td   style="background-color:#ffffcc; text-align: center;border: 1px solid black;">1</td>' SKIP
            '         <td     style="background-color:#ffffcc; text-align: center; border: 1px solid black;">2</td>' SKIP
            '         <td  style="background-color:#ffffcc; text-align: center;border: 1px solid black;">3</td>' SKIP
            '         <td  style="background-color:#ffffcc; text-align: center;border: 1px solid black;">4</td>' SKIP
            '         <td  style="background-color:#ffffcc; text-align: center;border: 1px solid black;">5</td>' SKIP
            '         <td  style="background-color:#ffffcc; text-align: center;border: 1px solid black;">6</td>' SKIP
            '         <td  style="background-color:#ffffcc; text-align: center;border: 1px solid black;">7</td>' SKIP

            '</tr>' SKIP
            .
        OUTPUT stream OutStr-html close.
    END.
    DEFINE VARIABLE v-kol AS INTEGER.
    DEFINE BUFFER buf_code-tt FOR tt-rep1.
DEFINE VARIABLE p-number AS INTEGER INIT 0.
    DEFINE VARIABLE n_itog AS INTEGER.
    DEFINE VARIABLE n      AS INTEGER INIT 0.
    DO:
        OUTPUT stream OutStr-html to value(v-file-name-rep-htm) append convert target 'UTF-8'.
        FOR EACH buf_tt NO-LOCK WHERE buf_tt.obj-code = p-obj-code AND buf_tt.obj-type = p-obj-type  AND  buf_tt.cnt-line <> 0  BREAK BY buf_tt.exp-td-fact-date   BY buf_tt.exp-time  :
         v-kol = 0.   
            v-exp-volume-piece-litres = IF buf_tt.exp-volume-piece-litres = 0 AND buf_tt.exp-fact-qnty = 0 THEN "" ELSE fnc-fmt-dec-tc-litres(buf_tt.exp-volume-piece-litres).
            n = n + 1 .
            
            PUT STREAM OutStr-html UNFORMATTED
                /*        for each buf_tt no-lock where buf_tt.obj-code = p-obj-code and buf_tt.obj-type = p-obj-type  and   buf_tt.cnt-line <> 0 break by buf_tt.exp-td-fact-date  by buf_tt.exp-time :*/
                /*            v-exp-volume-piece-litres = if buf_tt.exp-volume-piece-litres = 0 and buf_tt.exp-fact-qnty = 0 then "" else fnc-fmt-dec-tc-litres(buf_tt.exp-volume-piece-litres).        */
                /*            put stream OutStr-html unformatted                                                                                                                                        */
                '       <tr>' SKIP
                '         <td style="display: yes; text-align: right;border: 1px solid black;">'  +  string(n) + '</td>' SKIP
                '         <td style="display: yes; text-align:  right;border: 1px solid black;">' + IF buf_tt.exp-td-fact-date = ? THEN "" ELSE fnc-DD-MM-YYYY(DATE(STRING(buf_tt.exp-td-fact-date,"99.99.9999"))) +  '</td>' SKIP
                '         <td style="display: yes; text-align:  left;border: 1px solid black;">' + buf_tt.alc-mark + '</td>' SKIP
                '         <td text_wrap="true" style="display: yes; text-align:  left;border: 1px solid black;">'  +    buf_tt.exp-name + '</td>'  SKIP
                '         <td style="display: yes; text-align:  right;border: 1px solid black;">'  +      buf_tt.exp-alc-type-code  + '</td>'  SKIP
                '         <td style="display: yes; text-align:  right;border: 1px solid black;">'  +       v-exp-volume-piece-litres + '</td>'  SKIP
                '         <td style="display: yes; text-align:  right;border: 1px solid black;">'  +       IF buf_tt.exp-fact-qnty = 0 AND buf_tt.exp-volume-piece-litres = 0 THEN ""  ELSE STRING(fnc-fmt-dec-tc-qnty(buf_tt.exp-fact-qnty))     + '</td>'  SKIP
                '</tr>' SKIP
                .
              
               IF LAST-OF (buf_tt.exp-td-fact-date) THEN 
            DO: 
        FOR EACH buf_tt-itog-lvl WHERE buf_tt-itog-lvl.obj-code = p-obj-code  AND buf_tt-itog-lvl.obj-type = p-obj-type  AND buf_tt-itog-lvl.cnt-line = 0 AND  buf_tt-itog-lvl.exp-td-fact-date = buf_tt.exp-td-fact-date :
            p-number = p-number + 1.
            END.
        
/*         put stream OutStr-html unformatted                                                                                                                               */
/*                                                                                                                                                                          */
/*            '       <tr>' skip                                                                                                                                            */
/*                                                                                                                                                                          */
/*                                                                                                                                                                          */
/*            '         <td rowspan = "' +   string(p-number + 1) +  '"   style="display: yes; vertical-align:  middle; font-weight: bold; text-align:  right;"> </td>' skip*/
/*            .                                                                                                                                                             */
/*                                                                                                                                                                          */
        
/*        find last buf_tt-itog-lvl where buf_tt-itog-lvl.obj-code = p-obj-code  and buf_tt-itog-lvl.obj-type = p-obj-type  and buf_tt-itog-lvl.cnt-line = 0 and  buf_tt-itog-lvl.exp-td-fact-date = buf_tt.exp-td-fact-date no-lock no-error.*/
    
    
    FOR EACH buf_code-tt WHERE buf_code-tt.obj-code = p-obj-code   AND buf_code-tt.obj-type = p-obj-type   AND buf_code-tt.cnt-line = 0   AND buf_code-tt.itog_volume = 100 AND buf_tt.exp-td-fact-date  = buf_code-tt.exp-td-fact-date:
       
        
               PUT STREAM OutStr-html UNFORMATTED       
               
            '       <tr>' SKIP
                    
                        
            '         <td    colspan = "6" style="display: yes; vertical-align:  middle; border: none; border-bottom : none; border-left: 1px solid black;  font-weight: bold; text-align:  right;"> Итого по коду ' +  buf_code-tt.exp-alc-type-code  + '</td>' SKIP
              
/*                '         <td text_wrap="true" style="display: yes; font-weight: bold; text-align: left;">' +  buf_code-tt.exp-name  + '</td>' skip          */
/*                             '         <td style="display: yes; font-weight: bold; text-align:  right;">'  +   buf_code-tt.exp-alc-type-code  + '</td>'  skip*/
/*                '         <td style="display: yes; font-weight: bold; text-align:  right;"></td>'  skip                                                      */
                '         <td style="display: yes; font-weight: bold; text-align:  right;border: 1px solid black;">'  +   IF buf_code-tt.exp-fact-qnty = 0 AND buf_code-tt.exp-volume-piece-litres = 0 THEN ""  ELSE STRING(fnc-fmt-dec-tc-qnty(buf_code-tt.exp-fact-qnty))  + '</td>'  SKIP
                '</tr>' SKIP
                .
        
        
        END.

       
        FOR EACH buf_tt-itog WHERE buf_tt-itog.obj-code = p-obj-code  AND buf_tt-itog.obj-type = p-obj-type AND  buf_tt-itog.exp-td-fact-date =  buf_tt.exp-td-fact-date  AND  buf_tt-itog.cnt-line = 0 AND buf_tt-itog.itog_volume <> 100 :  
          
          v-kol = v-kol +  buf_tt-itog.exp-fact-qnty.
            PUT STREAM OutStr-html UNFORMATTED   
            
            '       <tr>' SKIP
                    
                        
            '         <td colspan = "6" style="display: yes; vertical-align:  middle; font-weight: bold; border: none; border-bottom : none; border-left: 1px solid black; text-align:  right;"> Итого по наименованию ' +  buf_tt-itog.exp-name  + '</td>' SKIP
            
/*                '         <td text_wrap="true" style="display: yes; font-weight: bold; text-align: left;">'  +    buf_tt-itog.exp-name  + '</td>'  skip*/
/*                '         <td style="display: yes; font-weight: bold; text-align:  right;">'  +      buf_tt-itog.exp-alc-type-code  + '</td>'  skip    */
/*                '         <td style="display: yes; font-weight: bold; text-align:  right;"></td>'  skip                                                */
                '         <td style="display: yes; font-weight: bold; text-align:  right;border: 1px solid black;">'  +       IF buf_tt-itog.exp-fact-qnty = 0 AND buf_tt-itog.exp-volume-piece-litres = 0 THEN ""  ELSE STRING(fnc-fmt-dec-tc-qnty(buf_tt-itog.exp-fact-qnty))  + '</td>'  SKIP
                '</tr>' SKIP
                .
        END.
        
         PUT STREAM OutStr-html UNFORMATTED   
            
            '       <tr>' SKIP
                    
                        
            '         <td colspan = "6" style="display: yes; vertical-align:  middle; font-weight: bold; border-left: 1px solid black; border-bottom: 1px solid black; border-top: none; text-align:  right;"> Итого по количеству (штук)</td>' SKIP
            
/*                '         <td text_wrap="true" style="display: yes; font-weight: bold; text-align: left;">'  +    buf_tt-itog.exp-name  + '</td>'  skip*/
/*                '         <td style="display: yes; font-weight: bold; text-align:  right;">'  +      buf_tt-itog.exp-alc-type-code  + '</td>'  skip    */
/*                '         <td style="display: yes; font-weight: bold; text-align:  right;"></td>'  skip                                                */
                '         <td style="display: yes; font-weight: bold; text-align:  right;border: 1px solid black; border-bottom: 1px solid black;">'  +  string(fnc-fmt-dec-tc-qnty(v-kol))  + '</td>'  skip
                '</tr>' skip
                .
        
    END.
    p-number = 0.
END.
    
    
END.
DO: 
    PUT STREAM OutStr-html UNFORMATTED  
        '</tbody>'
        '   </table>' SKIP
        '  </body>' SKIP
        ' </html>' SKIP
        . /* Точка для закрытия Put */
    OUTPUT stream OutStr-html close.
END.
    
END PROCEDURE.


   
    
FUNCTION fnc-DD-MM-YYYY RETURNS CHARACTER 
    (INPUT p-dat-date AS DATE):
    /* Преобразование даты в формат: "01.01.2014" */

    DEFINE VARIABLE result     AS CHARACTER NO-UNDO.
    DEFINE VARIABLE p-str-date AS CHARACTER NO-UNDO.

    p-str-date = REPLACE(STRING(p-dat-date,'99.99.9999'), "/", ".").

    RETURN p-str-date.

END FUNCTION.
    
    
PROCEDURE get-full-path-RepViewer:  /* Получение полного пути к исполняемому файлу RV.exe (output Полный_путь_имя_файла_RV.exe) */
    /* Получение полного пути к exe-файлу просмотровщика отчётов */
    DEFINE OUTPUT PARAMETER p-fill-path-RepView AS CHARACTER NO-UNDO.

    IF SEARCH("exe\ReportViewer\reportviewer.exe") <> ? THEN
    DO:
        p-fill-path-RepView = SEARCH("exe\ReportViewer\reportviewer.exe").
    END.
    ELSE
    DO:
        MESSAGE "Не найдена программа просмотра отчёта!" VIEW-AS ALERT-BOX ERROR.
    END.
END PROCEDURE.


PROCEDURE search-full-path-Report:  /* Только проверка, есть файл отчёта HTML или нет(тогда вывод сбщ-ош) */
    /* Поиск файла */  
    DEFINE INPUT PARAMETER p-file-name AS CHARACTER NO-UNDO.

    IF SEARCH(p-file-name) = ? THEN
    DO:
        MESSAGE "Не найден файл отчёта: " p-file-name VIEW-AS ALERT-BOX ERROR.
    END.
    ELSE
    DO:
        p-file-name = SEARCH(p-file-name).
    END.

END PROCEDURE.


PROCEDURE create-file:              /* СоздЛюбогоФайлаНаДиске(input полный_путь_с_именем) */
    /* Создание пустого файла (во входном параметре: полный путь и имя файла) */
    DEFINE INPUT PARAMETER p-file-name AS CHARACTER NO-UNDO.
    OUTPUT to value(STRING(p-file-name)).
    OUTPUT close.

END PROCEDURE.


PROCEDURE define-full-path-Report:  /* Получение полного пути к отчёту html (input №Отчёта, output Полный_путь_имя_файла_отчHTML) */
    /* Получение полного пути к отчёту html */
    DEFINE INPUT PARAMETER p-rep-num AS INTEGER NO-UNDO.
    DEFINE INPUT PARAMETER name-obj AS INTEGER.
    DEFINE OUTPUT PARAMETER p-file-name-rep-htm AS CHARACTER NO-UNDO.

    p-file-name-rep-htm = SESSION:TEMP-DIRECTORY +   "Объект" + string(name-obj) + ".html".

END PROCEDURE.


PROCEDURE Report-Viewer:            /* Запуск на выполнение RV (input Полный_путь_имя_файла_RV, input Полный_путь_имя_файла_отчHTML) */
    /* Запуск программы "Просмотровщик Отчётов" - ReportViewer. */
    DEFINE INPUT PARAMETER p-full-path-RepView AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER p-search AS CHARACTER NO-UNDO.

    OS-COMMAND NO-WAIT VALUE(p-full-path-RepView + " true " + p-search).

END PROCEDURE.


