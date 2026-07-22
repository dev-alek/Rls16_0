block-level on error undo, throw.
define input parameter parparentproc        AS WIDGET-HANDLE NO-UNDO.
define input parameter par-mode             as character no-undo .
define input parameter par-copymode         as logical no-undo .
define input parameter par-alt-bc-mode      as integer no-undo .
define input parameter par-manual           as logical no-undo .
define input parameter par-silence          as logical no-undo .
define input parameter par-file             as logical no-undo .
define input parameter par-single-record    as logical no-undo .
define input parameter par-host-code        like ub.sysconf.host-code no-undo .
define input parameter par-obj-type         like ub.clients.obj-type no-undo .
define input parameter par-obj-code         like ub.clients.obj-code no-undo .
define input parameter is-goods             as logical no-undo .
define input parameter par-copy-rec         as recid no-undo.
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
define input parameter par-unq-artc         as logical no-undo .
define input parameter par-is-jwlr          as logical no-undo .
define input parameter par-is-bttl          as logical no-undo .
define input parameter par-is-ptrl          as logical no-undo .
define input parameter par-custvalue        as character no-undo .
define input parameter par-dif-nam1         as logical no-undo .
define input parameter par-dif-nam2         as logical no-undo .
define input parameter par-ArtDis           as logical no-undo .
define input parameter par-BarDis           as logical no-undo .
define input-output parameter par-rec       as recid no-undo .
define output parameter par-nbc             like ub.bar-code.b-code no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rcsgds.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rcs/rcsgds.p $":U .
define variable vss-description as character no-undo init "Создание или изменение карточки товара.".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
  define new shared temp-table  tt-tax no-undo
field tax-code    like ub.tax.tax-code
FIELD individual  like ub.tax.individual
FIELD tax-name    like ub.tax.tax-name format "X(12)" column-label "Налог"
field rate-code   like ub.tax-rate.rate-code
FIELD rate-name   like ub.tax-rate.rate-name FORMAT "X(12)"
FIELD tax-type    like ub.tax.tax-type
field rate-value  like ub.tax-rate-value.rate-value
FIELD tax-rate-gds-rc  as recid
FIELD to-cashdesk like ub.tax.to-cashdesk
FIELD fact-date like ub.tax-rate-value.fact-date
FIELD fact-order like ub.tax-rate-value.fact-order
FIELD next-order like ub.tax-rate-value.fact-order
FIELD corr-user-name like ub.tax-rate-gds.corr-user-name
FIELD corr-user-db-num   like ub.tax-rate-gds.corr-user-db-num
FIELD corr-date like ub.tax-rate-gds.corr-date
FIELD corr-time like ub.tax-rate-gds.corr-time
index tax-code is unique primary tax-code fact-order descending rate-code.
define new shared buffer goods for ub.goods.
do
on error undo, return error
:
            if par-mode = 'ДОБАВЛЕНИЕ':U
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
                , input par-mode
                , input par-copymode
                , input par-alt-bc-mode
                , input par-manual
                , input par-silence
                , input yes
                , input par-file
                , input par-single-record
                , input par-host-code
                , input par-obj-type
                , input par-obj-code
                , input is-goods
                , input par-copy-rec
                , input 0
                , input par-artic
                , input par-prod-type
                , input par-prod-code
                , input par-node-code
                , input par-grp-code
                , input par-gds-name
                , input par-saved-name
                , input par-engl-name
                , input par-label-name
                , input par-chk-name
                , input par-alpha1
                , input par-unit-base
                , input par-unit-cli
                , input par-max-rate
                , input par-min-rate
                , input par-cli-base-rate
                , input par-qnty-cart
                , input par-ms-base
                , input par-wt-base
                , input par-ms-cart
                , input par-wt-cart
                , input par-calc-method
                , input par-increase-pc
                , input par-NegRest
                , input par-obj-price-base
                , input par-obj-price-rubl
                , input par-okdp
                , input par-destin
                , input par-attrib
                , input par-user-rule
                , input par-sert
                , input par-struct
                , input par-deadline
                , input par-cond-keep-code
                , input par-sort
                , input par-proof
                , input par-normal-wastage
                , input par-normal-waste
                , input par-tnved
                , input par-nationality
                , input par-unit-cst
                , input par-cst-base-rate
                , input par-PS
                , input par-fbr-grp-code
                , input par-unq-artc
                , input par-is-jwlr
                , input par-is-bttl
                , input par-is-ptrl
                , input par-custvalue
                , input par-dif-nam1
                , input par-dif-nam2
                , input par-ArtDis
                , input (if par-BarDis then 1 else 0)
                , input-output par-rec
                , output par-nbc
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
