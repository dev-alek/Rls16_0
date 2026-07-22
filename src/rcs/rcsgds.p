block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rcsgds.p $
$Archive: rcs/rcsgds.p $

Создание или изменение карточки товара.

Автор: Гюнтнер Виктор Арнольдович
Дата создания: 04/12/06
Author: Victor Guntner
Creation date: 04/12/06

Input:

Output:

*/

define input parameter parparentproc        AS WIDGET-HANDLE NO-UNDO.
define input parameter par-mode             as character no-undo . /*{&add-def} или {&update}*/
define input parameter par-copymode         as logical no-undo . /*копирование с другого товара - тогда par-copy-rec - должен быть задан*/
define input parameter par-alt-bc-mode      as integer no-undo . /*нужно ли вводить ДОП БК вместе с товаром*/
define input parameter par-manual           as logical no-undo . /*мз карточки товара - yes*/
define input parameter par-silence          as logical no-undo . /*ругаемся вслух или ?*/
define input parameter par-file             as logical no-undo . /*идет импоррт из файла - из карточки товара*/
define input parameter par-single-record    as logical no-undo . /*надо сохранить только одну запись - потом выход в справ*/
define input parameter par-host-code        like ub.sysconf.host-code no-undo .
define input parameter par-obj-type         like ub.clients.obj-type no-undo .
define input parameter par-obj-code         like ub.clients.obj-code no-undo .
define input parameter is-goods             as logical no-undo . /*товар - yes услуга no*/
define input parameter par-copy-rec         as recid no-undo. /*recid записи с которой копируем*/
define input parameter par-artic            like ub.goods.artic no-undo .
define input parameter par-prod-type        like ub.goods.prod-type no-undo .
define input parameter par-prod-code        like ub.goods.prod-code no-undo .
define input parameter par-node-code        like ub.gds-prt.node-code no-undo .
define input parameter par-grp-code         like ub.gds-grp.node-code no-undo .
define input parameter par-gds-name         like ub.goods.gds-name no-undo .
define input parameter par-saved-name       like ub.goods.gds-name no-undo .
define input parameter par-engl-name        like ub.goods.engl-name no-undo .
define input parameter par-label-name       like ub.goods.label-name no-undo .
define input parameter par-chk-name         like ub.goods.chk-name no-undo .
define input parameter par-alpha1           like ub.goods.alpha1 no-undo .
define input parameter par-unit-base        like ub.goods.unit-base no-undo .
define input parameter par-unit-cli         like ub.goods.unit-cli no-undo .
define input parameter par-max-rate         like ub.goods.max-rate no-undo .
define input parameter par-min-rate         like ub.goods.min-rate no-undo .
define input parameter par-cli-base-rate    like ub.goods.cli-base-rate no-undo .
define input parameter par-qnty-cart        like ub.goods.qnty-cart no-undo .
define input parameter par-ms-base          like ub.goods.ms-base no-undo .
define input parameter par-wt-base          like ub.goods.wt-base no-undo .
define input parameter par-ms-cart          like ub.goods.ms-cart no-undo .
define input parameter par-wt-cart          like ub.goods.wt-cart no-undo .
define input parameter par-calc-method      like ub.goods.calc-method no-undo .
define input parameter par-increase-pc      like ub.goods.increase-pc no-undo .
define input parameter par-NegRest          as logical no-undo .
define input parameter par-obj-price-base   like ub.gds-obj.price-base no-undo .
define input parameter par-obj-price-rubl   like ub.gds-obj.price-rubl no-undo .
define input parameter par-okdp             like ub.goods.okdp no-undo .
define input parameter par-destin           like ub.goods.destin no-undo .
define input parameter par-attrib           like ub.goods.attrib  no-undo .
define input parameter par-user-rule        like ub.goods.user-rule no-undo .
define input parameter par-sert             like ub.goods.sert no-undo .
define input parameter par-struct           like ub.goods.struct no-undo .
define input parameter par-deadline         like ub.goods.deadline no-undo .
define input parameter par-cond-keep-code   like ub.goods.cond-keep-code no-undo .
define input parameter par-sort             like ub.goods.sort no-undo .
define input parameter par-proof            like ub.goods.proof no-undo .
define input parameter par-normal-wastage   like ub.goods.normal-wastage no-undo .
define input parameter par-normal-waste     like ub.goods.normal-waste no-undo .
define input parameter par-tnved            like ub.goods.tnved no-undo .
define input parameter par-nationality      like ub.goods.nationality no-undo .
define input parameter par-unit-cst         like ub.goods.unit-cst no-undo .
define input parameter par-cst-base-rate    like ub.goods.cst-base-rate no-undo .
define input parameter par-fbr-grp-code     like ub.goods.fbr-grp-code no-undo .
define input parameter par-PS               like ub.goods.ps no-undo .
define input parameter par-unq-artc         as logical no-undo . /*настройка*/
define input parameter par-is-jwlr          as logical no-undo . /*в системе разрешены ювелирные изделия*/
define input parameter par-is-bttl          as logical no-undo . /*в системе разрешена стеклотара */
define input parameter par-is-ptrl          as logical no-undo . /*в системе разрешено топливо */
define input parameter par-custvalue        as character no-undo . /*в системе разрешена таможня */
define input parameter par-dif-nam1         as logical no-undo . /*настройка*/
define input parameter par-dif-nam2         as logical no-undo . /*настройка*/
define input parameter par-ArtDis           as logical no-undo . /*автоматический артикул*/
define input parameter par-BarDis           as logical no-undo . /*главный код товара берется из артикула*/
define input-output parameter par-rec       as recid no-undo .
define output parameter par-nbc             like ub.bar-code.b-code no-undo . /*gds-code*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rcsgds.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rcs/rcsgds.p $":U .
define variable vss-description as character no-undo init "Создание или изменение карточки товара.".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ str/tt-tax.i "new shared" tt-tax full }
define new shared buffer goods for ub.goods.

do
on error undo, return error
:

            if par-mode = {&add-def}
            then do:
                run ref/dtaxgdss.p (
                      input no
                    , input par-unit-base
                    , input par-node-code
                    , input ?
                    , input ?
                    , input par-host-code
                    , input par-obj-type
                    , input par-obj-code
                ).
            end.
            else do:
                for each tt-tax:
                    delete tt-tax.
                end.
            end.
            run ref/goods01.p (
                  input parparentproc
                , input par-mode           /*{&add-def} или {&update}*/
                , input par-copymode       /*копирование с другого товара - тогда par-copy-rec - должен быть задан*/
                , input par-alt-bc-mode    /*нужно ли вводить ДОП БК вместе с товаром*/
                , input par-manual         /*мз карточки товара - yes*/
                , input par-silence        /*ругаемся вслух или ?*/
                , input yes                /*import*/
                , input par-file           /*идет импоррт из файла - из карточки товара*/
                , input par-single-record  /*надо сохранить только одну запись - потом выход в справ*/
                , input par-host-code
                , input par-obj-type
                , input par-obj-code
                , input is-goods           /*товар - yes услуга no*/
                , input par-copy-rec       /*recid записи с которой копируем*/
                , input 0
                , input par-artic
                , input par-prod-type
                , input par-prod-code
                , input par-node-code
                , input par-grp-code
                , input par-gds-name
                , input par-saved-name     /* par-saved-name */
                , input par-engl-name
                , input par-label-name
                , input par-chk-name
                , input par-alpha1
                , input par-unit-base
                , input par-unit-cli
                , input par-max-rate
                , input par-min-rate
                , input par-cli-base-rate
                , input par-qnty-cart      /* par-qnty-cart */
                , input par-ms-base        /* par-ms-cart */
                , input par-wt-base        /* par-wt-cart */
                , input par-ms-cart        /* par-ms-cart */
                , input par-wt-cart        /* par-wt-cart */
                , input par-calc-method
                , input par-increase-pc
                , input par-NegRest        /* par-NegRest */
                , input par-obj-price-base /* par-obj-price-base */
                , input par-obj-price-rubl /* par-obj-price-rubl */
                , input par-okdp           /* par-okdp */
                , input par-destin         /* par-destin          */
                , input par-attrib         /* par-attrib          */
                , input par-user-rule      /* par-user-rule       */
                , input par-sert           /* par-sert            */
                , input par-struct         /* par-struct          */
                , input par-deadline       /* par-deadline        */
                , input par-cond-keep-code /* par-cond-keep-code  */
                , input par-sort           /* par-sort            */
                , input par-proof          /* par-proof           */
                , input par-normal-wastage /* par-normal-wastage  */
                , input par-normal-waste   /* par-normal-waste    */
                , input par-tnved          /* par-tnved           */
                , input par-nationality    /* par-nationality     */
                , input par-unit-cst       /* par-unit-cst        */
                , input par-cst-base-rate  /* par-cst-base-rate   */
                , input par-PS             /* par-PS              */
                , input par-fbr-grp-code   /* par-fbr-grp-code    */
                , input par-unq-artc       /* par-unq-artc настройка*/
                , input par-is-jwlr        /* par-is-jwlr в системе разрешены ювелирные изделия */
                , input par-is-bttl        /* par-is-bttl в системе разрешена стеклотара        */
                , input par-is-ptrl        /* par-is-ptrl в системе разрешено топливо           */
                , input par-custvalue      /*в системе разрешена таможня */
                , input par-dif-nam1       /*настройка*/
                , input par-dif-nam2       /*настройка*/
                , input par-ArtDis         /*автоматический артикул*/
                , input (if par-BarDis then 1 else 0)        /*главный код товара берется из артикула*/
                , input-output par-rec
                , output par-nbc           /*gds-code*/
            ) no-error .
            if error-status :error
            then do:
                message
                         vss-workfile vss-revision vss-description
                    skip "Ошибка создания или изменения карточки товара."
                    skip return-value
                    skip trim(error-status :get-message(1))
                         trim(error-status :get-message(2))
                         trim(error-status :get-message(3))
                view-as alert-box error.
                undo, return error .
            end.

end.