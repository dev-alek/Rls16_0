block-level on error undo, throw.
/*

$Revision: a61e6bb0c7e0, 2871, rls $
$Author: SSlivenko $
$Date: Пн ноя 22 19:49:10 2021 +0300 $
$Workfile: ut-stk.p $
$Archive: utl/ut-stk.p $

Утилита вывода в файл остатков и расхода товаров по фирме

Автор: Белоусов Илья Александрович
Дата создания: 09/15/05
Author: Ilia Belousov
Creation date: 09/15/05

Input:

Output:

В качестве расхода выгружается по каждому товару:
(Расход внешний + Расход внешний через кассу) - (Возврат внешний + Возврат внешний через кассу)

(по заказу ТАТИ)

*/

define input parameter p-mainmenu-handle    as handle           no-undo.

define variable vss-revision    as character no-undo init "$Revision: a61e6bb0c7e0, 2871, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Пн ноя 22 19:49:10 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ut-stk.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ut-stk.p $":U .
define variable vss-description as character no-undo init "Утилита вывода в файл остатков и расхода товаров по фирме".
{ cmp/vssrevis.i }

{ cmp/trg-def.i     }
{ cmp/library.i     }
{ str/lib-trn.i  }
{ gbl/temphost.i    }
{ str/get-pr.i def  }
{ bge/bge-xml.i     }
{ gbl/dtm.i         }
{ str/writelog.i def "''"}
    define variable parparentproc    as handle       no-undo.
    assign
        parparentproc = p-mainmenu-handle
    .
{ gbl/getcntxt.i def    }

    define variable v-date-from             as date                     no-undo.
    define variable v-date-to               as date                     no-undo.

    define variable v-file-name             as char                     no-undo.

    define variable v-fact-order-from       like ub.stk-tot.fact-order     no-undo.
    define variable v-fact-order-to         like ub.stk-tot.fact-order     no-undo.
    define variable v-fo-from               like ub.stk-tot.fact-order     no-undo.
    define variable v-fo-to                 like ub.stk-tot.fact-order     no-undo.
    define variable v-docs-exists           as logical                  no-undo.
    define variable v-last-tmp-obj          as logical                  no-undo.
    define variable v-temp-exists           as logical                  no-undo.
    define variable v-first-in-gds-obj      as logical  init yes        no-undo.
    define variable v-bar-code              like ub.bar-code.b-code        no-undo.

    define variable v-doc-num               as character                no-undo.
    define variable v-price-sale            like ub.stk-line.sum-base      no-undo.
    define variable v-road-tax              like ub.stk-line.road-tax-base no-undo.
    define variable v-excise                like ub.stk-line.excise-base   no-undo.

    define variable v-last-sum              like ub.stk-line.sum-base      no-undo.
    define variable v-last-qnty             like ub.stk-line.fact-qnty     no-undo.

    define variable v-good-counter          as int          init 0      no-undo.     /*счетчик количества товаров*/

    define variable v-was-changed           as logical      init no     no-undo.     /*для проверки захода в циклы for each*/
    define variable v-today                 as date                     no-undo.
    define variable v-time                  as integer                  no-undo.

    define variable v-void-logical          as logical                  no-undo.
    define variable v-void-integer          as integer                  no-undo.
    define variable v-void-character        as character                no-undo.

        define variable v-g-ut-stk-host-code    as integer      no-undo.
        define variable v-g-ut-stk-store-type   as character    no-undo.
        define variable v-g-ut-stk-store-code   as integer      no-undo.


    define stream out-stream.

    define temp-table temp-fact-ord no-undo
        field obj-type         like ub.stk-tot.obj-type
        field obj-code         like ub.stk-tot.obj-code
        field min-fact-order   like ub.stk-tot.fact-order
        field max-fact-order   like ub.stk-tot.fact-order
        index fo is primary unique obj-type obj-code
    .

    define temp-table temp-good no-undo
        field gds-code          like ub.goods.gds-code
        field artic             like ub.goods.artic
        field prod-type         like ub.goods.prod-type
        field prod-code         like ub.goods.prod-code
        field gds-name          like ub.goods.gds-name
        field current-price     like ub.stk-line.sum-base
        field qnty-first        like ub.stk-line.fact-qnty
        field sum-first         like ub.stk-line.sum-base
        field qnty-last         like ub.stk-line.fact-qnty
        field sum-last          like ub.stk-line.sum-base
        field qnty-ras-vnesh    like ub.stk-line.fact-qnty
        field sum-ras-vnesh     like ub.stk-line.sum-base
        index gd is primary unique gds-code
    .
    define variable v-archive-ok        as logical      no-undo.
    define variable v-comment           as character    no-undo.
    define variable v-pay-type-list     as character    no-undo.

    define buffer buf_goods   for ub.goods.
    define buffer buf_gds-obj for ub.gds-obj.
do
for buf_goods
  , buf_gds-obj
on error undo, return error
:
    if log-file-name <> ""
    then do:
        os-delete value( log-file-name ).
    end.

    run init-temphost in this-procedure.

    run bge/bge-dper.w (
          input p-mainmenu-handle
        , input 0                           /* p-output-type       */
        , input ""                          /* p-init-doc-type-list*/
        , output v-date-from                /* date_exp_from      */
        , output v-date-to                  /* date_exp_to        */
        , output v-void-integer             /* p-range            */
        , output v-void-integer             /* p-host-code        */
        , output v-void-character           /* p-obj-list         */
        , OUTPUT v-pay-type-list            /* p-pay-type-list    */
        , output v-void-character           /* p-doc-type-list    */
        , output v-void-logical             /* p-pay-code         */
        , output v-void-logical             /* p-cst              */
        , output v-void-logical             /* p-parts            */
        , output v-void-logical             /* p-chk-pay-code     */
        , output v-void-logical             /* p-pay-desk         */
        , output v-void-logical             /* p-cancel           */
        , output v-void-logical             /* p-pay-desk         */
        , output v-void-logical             /* p-chk              */
        , output v-void-logical             /* p-doc-rvs          */
        , output v-void-logical             /* p-cancel           */
    ).
    if v-date-from = ? or v-date-to = ? then return error. /* отказ */
    run writelog in this-procedure ( log-file-name, 1,
                               "Диапазон дат ( "  + string(v-date-from) + " - " + string(v-date-to) + " )"
                                        ).

/*---START----- Вычисление диапазона fact-order ----------------*/

        { gbl/getcntxt.i get }
        assign
            v-g-ut-stk-host-code   = v-cntxt-host-code-obj
            v-g-ut-stk-store-type  = v-cntxt-obj-type
            v-g-ut-stk-store-code  = v-cntxt-obj-code
        .
        { gbl/hostcode.i
            v-g-ut-stk-store-type
            v-g-ut-stk-store-code
            v-g-ut-stk-host-code
        }
    object-on-this-firm:
    for each temp-obj
       where temp-obj.host-code = v-g-ut-stk-host-code
    :
        run bge/bge-ahz.p (
              input parparentproc
            , input temp-obj.obj-type
            , input temp-obj.obj-code
            , input yes
            , input no
            , input no
            , input v-date-from
            , input v-date-to
            , output v-archive-ok
            , output v-comment
        ) no-error.
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Ошибка проверки архивов на объекте."
            skip "Тип объекта:" temp-obj.obj-type
            skip "Код объекта:" temp-obj.obj-code
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
        run rep/get-fo.p (
                          input  temp-obj.obj-type
                        , input  temp-obj.obj-code
                        , input  v-date-from
                        , input  v-date-to
                        , output v-fo-from
                        , output v-fo-to
                        , output v-docs-exists
                     ).

        if v-docs-exists = no                  /*Нет документов за этот интервал времени*/
        then do:
            next object-on-this-firm.
        end.
        else do:
            create temp-fact-ord.
            assign
                temp-fact-ord.obj-type          = temp-obj.obj-type
                temp-fact-ord.obj-code          = temp-obj.obj-code
                temp-fact-ord.min-fact-order    = v-fo-from
                temp-fact-ord.max-fact-order    = v-fo-to
            .
        end.
        run writelog in this-procedure ( log-file-name, 1,
                                                    temp-fact-ord.obj-type
                                                    + "   " + dtm-char( string(temp-fact-ord.obj-code) )
                                                    + "   " + dtm-char( string(temp-fact-ord.min-fact-order) )
                                                    + "   " + dtm-char( string(temp-fact-ord.max-fact-order) )
                                            ).
    end.


/*    if   v-fact-order-from >= v-fact-order-to*/
/*      or v-fact-order-to = 0*/
/*    then do:*/
/*        message*/
/*             v-fact-order-from*/
/*        skip v-fact-order-to*/
/*        skip "В указанном диапазоне дат не было движения товаров"*/
/*        view-as alert-box information.*/
/*        return.*/
/*    end.*/

/*---END------- Вычисление диапазона fact-order ----------------*/

    { gbl/working.i }
    run cur-time in this-procedure ( output v-today
                                   , output v-time
                                   ).
    assign
        v-file-name = "g_" + substring(string(year(v-today)),3,2) + string(month(v-today)) + string(day(v-today))
    .

    os-delete value(v-file-name + ".txt").

    output stream out-stream to value(v-file-name + ".txt") convert target "1251" append.

/*    { rep/repfrm.i on}*/

    good-on-object:
    for each buf_gds-obj no-lock
    break by buf_gds-obj.gds-code
    :
        if first-of( buf_gds-obj.gds-code )
        then do:
            assign
                v-last-tmp-obj = no
                v-temp-exists  = no
                v-last-qnty    = 0
                v-last-sum     = 0
            .
        end.
        if last-of( buf_gds-obj.gds-code )
        then do:
            assign
                v-last-tmp-obj = yes
            .
        end.
/*        { rep/repfrm.i disp 100 buf_gds-obj.artic}*/
/*---START--------- Не было движения по этому объекту ---------------------*/
        find first temp-fact-ord
             where temp-fact-ord.obj-type = buf_gds-obj.obj-type
               and temp-fact-ord.obj-code = buf_gds-obj.obj-code
        no-error.
        if not available temp-fact-ord
        then do:
/*            run writelog in this-procedure ( log-file-name, 3,*/
/*                                                            "По объекту движения товаров не было"*/
/*            ).*/
            if v-last-tmp-obj = yes and v-temp-exists = yes
            then do:
                run eval-sum-and-write-result in this-procedure (
                      input buf_gds-obj.obj-type
                    , input buf_gds-obj.obj-code
                    , input buf_gds-obj.artic
                    , input buf_gds-obj.prod-type
                    , input buf_gds-obj.prod-code
                ).
            end.
            next good-on-object.
        end.
/*---END----------- Не было движения по этому объекту ---------------------*/
/*---START--------- Этот gds-obj не с текущей фирмы ---------------------*/
        find first temp-obj
             where temp-obj.host-code = v-g-ut-stk-host-code
               and temp-obj.obj-type  = buf_gds-obj.obj-type
               and temp-obj.obj-code  = buf_gds-obj.obj-code
        no-error.
        if not available temp-obj
        then do:
/*            run writelog in this-procedure ( log-file-name, 3,*/
/*                                                            "Объект не принадлежит текущей фирме"*/
/*            ).*/
            if v-last-tmp-obj = yes and v-temp-exists = yes
            then do:
                run eval-sum-and-write-result in this-procedure (
                      input buf_gds-obj.obj-type
                    , input buf_gds-obj.obj-code
                    , input buf_gds-obj.artic
                    , input buf_gds-obj.prod-type
                    , input buf_gds-obj.prod-code
                ).
            end.
            next good-on-object.
        end.
/*---END----------- Этот gds-obj не с текущей фирмы ---------------------*/
        find first buf_goods no-lock
             where buf_goods.gds-code = buf_gds-obj.gds-code
        .
/*---START--------- Не было движения за этот интервал на этом объекте ---------------------*/
        if    buf_gds-obj.last-doc  < v-date-from
           or buf_gds-obj.first-doc > v-date-to
        then do:
/*            run writelog in this-procedure ( log-file-name, 3,*/
/*                                                            "Не было движения этого товара по объекту"*/
/*            ).*/
            if v-temp-exists = no
            then do:
                run create-temp-good in this-procedure (
                      input buf_gds-obj.obj-type
                    , input buf_gds-obj.obj-code
                    , input buf_gds-obj.artic
                    , input buf_gds-obj.prod-type
                    , input buf_gds-obj.prod-code
                    , input buf_goods.gds-name
                ).
            end.
            if buf_gds-obj.last-doc  < v-date-from
            then do:
                for each ub.stk-line
                where ub.stk-line.obj-type  = buf_gds-obj.obj-type
                    and ub.stk-line.obj-code  = buf_gds-obj.obj-code
                    and ub.stk-line.artic     = buf_gds-obj.artic
                    and ub.stk-line.prod-type = buf_gds-obj.prod-type
                    and ub.stk-line.prod-code = buf_gds-obj.prod-code
                    and ub.stk-line.sum-type  = {&arh-cost}
                    and ub.stk-line.cat-id    = '##,##'
                    and ub.stk-line.fact-order <= temp-fact-ord.max-fact-order
                break by ub.stk-line.fact-order descending
                :
                    assign
                        v-last-qnty          = v-last-qnty  + ub.stk-line.fact-qnty
                        v-last-sum           = v-last-sum   + ub.stk-line.sum-rubl
                    .
                    leave.
                end.
            end.
            if v-last-tmp-obj = yes and v-temp-exists = yes
            then do:
                run eval-sum-and-write-result in this-procedure (
                      input buf_gds-obj.obj-type
                    , input buf_gds-obj.obj-code
                    , input buf_gds-obj.artic
                    , input buf_gds-obj.prod-type
                    , input buf_gds-obj.prod-code
                ).
            end.
            next good-on-object.
        end.
/*---END----------- Не было движения за этот интервал на этом объекте ---------------------*/

        find first temp-good no-lock
             where temp-good.gds-code = buf_gds-obj.gds-code
        no-error.
        if not available temp-good
        then do:
            run create-temp-good in this-procedure (
                  input buf_gds-obj.obj-type
                , input buf_gds-obj.obj-code
                , input buf_gds-obj.artic
                , input buf_gds-obj.prod-type
                , input buf_gds-obj.prod-code
                , input buf_goods.gds-name
            ).
/*            run writelog in this-procedure ( log-file-name, 3,*/
/*                                            "Создали временную запись для товара ( "  + string(buf_gds-obj.artic)*/
/*                                            + " ) на объекте ( " + buf_gds-obj.obj-type + string(buf_gds-obj.obj-code)*/
/*                                            + " )"*/
/*            ).*/
        end.


        for each ub.stk-line
           where ub.stk-line.obj-type  = buf_gds-obj.obj-type
             and ub.stk-line.obj-code  = buf_gds-obj.obj-code
             and ub.stk-line.artic     = buf_gds-obj.artic
             and ub.stk-line.prod-type = buf_gds-obj.prod-type
             and ub.stk-line.prod-code = buf_gds-obj.prod-code
             and ub.stk-line.sum-type  = {&arh-cost}
             and ub.stk-line.cat-id    = '##,##'
             and ub.stk-line.fact-order <= temp-fact-ord.max-fact-order
        break by ub.stk-line.fact-order descending
        :
            assign
                temp-good.qnty-last  = temp-good.qnty-last + ub.stk-line.fact-qnty
                temp-good.sum-last = temp-good.sum-last + /*( v-price-sale * ub.stk-line.fact-qnty )*/ ub.stk-line.sum-rubl
            .
            leave.
        end.
/*        run writelog in this-procedure ( log-file-name, 3,*/
/*                                   "Сумма по товару на конец периода ( " + dtm-char( string( temp-good.sum-last ) )*/
/*                                   + " )"*/
/*                                            ).*/


        for each ub.stk-line
           where ub.stk-line.obj-type  = buf_gds-obj.obj-type
             and ub.stk-line.obj-code  = buf_gds-obj.obj-code
             and ub.stk-line.artic     = buf_gds-obj.artic
             and ub.stk-line.prod-type = buf_gds-obj.prod-type
             and ub.stk-line.prod-code = buf_gds-obj.prod-code
             and ub.stk-line.sum-type  = {&arh-cost}
             and ub.stk-line.cat-id    = '##,##'
             and ub.stk-line.fact-order <= temp-fact-ord.min-fact-order
        break by ub.stk-line.fact-order descending
        :
            assign
                temp-good.qnty-first    = temp-good.qnty-first + ub.stk-line.fact-qnty
                temp-good.sum-first     = temp-good.sum-first + /*v-price-sale * ub.stk-line.fact-qnty*/ ub.stk-line.sum-rubl
            .
            leave.
        end.
/*        run writelog in this-procedure ( log-file-name, 3,*/
/*                                   "Сумма по товару на начало периода ( " + dtm-char( string( temp-good.sum-last ) )*/
/*                                   + " )"*/
/*        ).*/
        if v-last-tmp-obj = yes and v-temp-exists = yes
        then do:
            run eval-sum-and-write-result in this-procedure (
                  input buf_gds-obj.obj-type
                , input buf_gds-obj.obj-code
                , input buf_gds-obj.artic
                , input buf_gds-obj.prod-type
                , input buf_gds-obj.prod-code
            ).
        end.
    end.
/*    { rep/repfrm.i off}*/
    { gbl/stopwork.i }
    message
      "Экспорт остатков завершен. Файл с результатами находится в каталоге запуска Trade House"
    view-as alert-box.

end.






  /*==========================================================================*/
  procedure eval-sum-and-write-result :
  define input parameter p-obj-type   as character        no-undo.
  define input parameter p-obj-code   as integer          no-undo.
  define input parameter p-artic      as character        no-undo.
  define input parameter p-prod-type  as character        no-undo.
  define input parameter p-prod-code  as integer          no-undo.


    define buffer buf_gds-obj       for ub.gds-obj.
do
for buf_gds-obj
on error undo, return error
:
    find first buf_gds-obj no-lock
         where buf_gds-obj.obj-type     = p-obj-type
           and buf_gds-obj.obj-code     = p-obj-code
           and buf_gds-obj.artic        = p-artic
           and buf_gds-obj.prod-type    = p-prod-type
           and buf_gds-obj.prod-code    = p-prod-code
    .
        assign
            temp-good.qnty-first    = temp-good.qnty-first  + v-last-qnty
            temp-good.sum-first     = temp-good.sum-first   + v-last-sum
            temp-good.qnty-last    = temp-good.qnty-last    + v-last-qnty
            temp-good.sum-last     = temp-good.sum-last     + v-last-sum
        .
            for each temp-obj no-lock
               where temp-obj.host-code = v-g-ut-stk-host-code
              , each ub.ot-line no-lock
               where ub.ot-line.obj-type   = temp-obj.obj-type
                 and ub.ot-line.obj-code   = temp-obj.obj-code
                 and ub.ot-line.artic      = buf_gds-obj.artic
                 and ub.ot-line.prod-type  = buf_gds-obj.prod-type
                 and ub.ot-line.prod-code  = buf_gds-obj.prod-code
                 and ub.ot-line.sum-type   = {&arh-sale}
/*                 and ub.ot-line.cat-id     = "##,##"*/
                 and ub.ot-line.fact-order >= temp-fact-ord.min-fact-order
                 and ub.ot-line.fact-order <= temp-fact-ord.max-fact-order
            :

                if   ub.ot-line.ext-doc-type = {&TDEDT_Ras_Vnesh}
                  or ub.ot-line.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}
                  or ub.ot-line.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}
                  or ub.ot-line.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
                then do:
                    assign
                        temp-good.qnty-ras-vnesh = temp-good.qnty-ras-vnesh + ub.ot-line.fact-qnty
                        temp-good.sum-ras-vnesh  = temp-good.sum-ras-vnesh  + ub.ot-line.sum-rubl
                    .
                    run writelog in this-procedure ( log-file-name, 4,
                                               "Расходный документ ( " + dtm-char( string( ub.ot-line.doc-code ) )
                                               + " ). Количество ( " + dtm-char( string( temp-good.qnty-ras-vnesh ) )
                                               + " ). Сумма ( " + dtm-char( string( temp-good.sum-ras-vnesh ) )
                                               + " )"
                                                        ).
                end.
            end.
            if      temp-good.qnty-ras-vnesh <> 0
                or  temp-good.sum-ras-vnesh <> 0
            then do:
                run writelog in this-procedure ( log-file-name, 3,
                                    "Количество ( " + dtm-char( string( temp-good.qnty-ras-vnesh ) )
                                    + " ) и сумма ( " + dtm-char( string( temp-good.sum-ras-vnesh ) )
                                    + " ) по расходу за период"
                                                    ).
            end.

            if      temp-good.qnty-first <> 0
                or  temp-good.qnty-last <> 0
                or  temp-good.sum-first <> 0
                or  temp-good.sum-last <> 0
                or  temp-good.qnty-ras-vnesh <> 0
                or  temp-good.sum-ras-vnesh <> 0     /*Если нет изменений и движения по товару, то нечего и выводить*/
            then do:
                for each temp-fact-ord
                :
/*                    { gbl/gdsbcode.i buf_gds-obj.gds-code ? v-bar-code no-error}.*/
/*                    if error-status :error*/
/*                    then do:*/
/*                        put stream out-stream*/
/*                            "Ошибка при определении основного бар-кода товара" buf_gds-obj.artic buf_goods.gds-name*/
/*                        .*/
/*                    end.*/
/*                    run writelog in this-procedure ( log-file-name, 3, "Старая текущая цена ( "*/
/*                                        + dtm-char( string(temp-good.current-price) )*/
/*                                        + " ) для товара ( "  + string(buf_gds-obj.artic)*/
/*                                        + " ) на объекте ( " + buf_gds-obj.obj-type + string(buf_gds-obj.obj-code)*/
/*                                        + " )"*/
/*                    ).*/

                    { str/get-pr.i calc temp-fact-ord.obj-type temp-fact-ord.obj-code buf_gds-obj.gds-code ? } /*Текущая цена*/

                    if temp-good.current-price = ? or temp-good.current-price <  gp-price-sale
                    then do:
                        assign
                            temp-good.current-price =  gp-price-sale
                        .
                    end.

                    run writelog in this-procedure ( log-file-name, 3,
                                "Определили максимальную текущую цену ( " + dtm-char( string(temp-good.current-price) )
                                + " ) для товара ( "  + string(buf_gds-obj.artic)
                                + " ) на объекте ( " + temp-fact-ord.obj-type + string(temp-fact-ord.obj-code)
                                + " )"
                    ).
                end.
                export stream out-stream delimiter ";"
                    temp-good
                .
                assign
                    v-good-counter = v-good-counter + 1
                .
            end.
            else do:
                delete temp-good.
            end.
/*            { rep/repfrm.i disp v-good-counter}*/
end.
end procedure. /* eval-sum-and-write-result */









/*==========================================================================*/
procedure create-temp-good :
define input parameter p-obj-type   as character        no-undo.
define input parameter p-obj-code   as integer          no-undo.
define input parameter p-artic      as character        no-undo.
define input parameter p-prod-type  as character        no-undo.
define input parameter p-prod-code  as integer          no-undo.
define input parameter p-gds-name   as character        no-undo.

    define buffer buf_gds-obj       for ub.gds-obj.
do
for buf_gds-obj
on error undo, return error
:
    find first buf_gds-obj no-lock
         where buf_gds-obj.obj-type     = p-obj-type
           and buf_gds-obj.obj-code     = p-obj-code
           and buf_gds-obj.artic        = p-artic
           and buf_gds-obj.prod-type    = p-prod-type
           and buf_gds-obj.prod-code    = p-prod-code
    .
        for each temp-good
        :
            delete temp-good.
        end.
        create temp-good.
        assign
            temp-good.gds-code          = buf_gds-obj.gds-code
            temp-good.artic             = buf_gds-obj.artic
            temp-good.prod-type         = buf_gds-obj.prod-type
            temp-good.prod-code         = buf_gds-obj.prod-code
            temp-good.gds-name          = p-gds-name
            temp-good.current-price     = ?
            temp-good.qnty-first        = 0
            temp-good.sum-first         = 0
            temp-good.qnty-last         = 0
            temp-good.sum-last          = 0
            temp-good.qnty-ras-vnesh    = 0
            temp-good.sum-ras-vnesh     = 0
        .
        assign
            v-temp-exists = yes
        .
end.
end procedure. /* create-temp-good */