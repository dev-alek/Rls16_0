block-level on error undo, throw.
define input parameter p-mode           as character    no-undo .
define input parameter p-node-code      as integer      no-undo .
define input parameter p-upper-code     as integer      no-undo .
define input parameter p-node-name      as character    no-undo .
define input parameter p-host-code      as integer      no-undo .
define input parameter p-obj-type       as character    no-undo .
define input parameter p-obj-code       as integer      no-undo .
define variable vss-revision    as character no-undo init "$Revision: 8d6ad4ee6014, 1102, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:52 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: impgrptx.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/impgrptx.p $":U .
define variable vss-description as character no-undo init "Создание или изменение группы товара.".
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
    define variable v-node-code         as integer      no-undo.
    define variable v-upper-code        as integer      no-undo.
    define variable v-gds-grp-recid     as recid        no-undo.
do
on error undo, return error
:
            assign
                v-node-code  = p-node-code
                v-upper-code = p-upper-code
            .
            run ref/gdsgrp01.p (
                  input p-mode
                , input no
                , input (if p-mode = 'ДОБАВЛЕНИЕ':U then yes else no)
                , input no
                , input-output v-node-code
                , input-output v-upper-code
                , input p-node-name
                , input entry( 9, 'Учетная,Учет-резерв,Накладная,Накл-безНДС,Учет-безНДС,Учет+накл,Уч+накл-НДС,Не-считать,Производит,Произв-НДС,ПорогПр-НДС,ПорогПр+НДС,Спецификация':U )
                , input 0
                , input ""
                , input entry( 5, '9-окончание,9-99окончание,Без-дробных,Произвольно,Вверх,Коэффициент,Отключено':U )
                , input 0
                , output v-gds-grp-recid
            ) no-error.
            if error-status :error
            then do:
                message
                         vss-workfile vss-revision vss-description
                    skip(1)
                    skip "Ошибка создания или изменения группы товаров."
                    skip return-value
                    skip trim(error-status :get-message(1))
                         trim(error-status :get-message(2))
                         trim(error-status :get-message(3))
                view-as alert-box error.
                undo, return error .
            end.
            if p-mode = 'ДОБАВЛЕНИЕ':U
            then do:
                run ref/dtaxgrps.p (
                      input 0
                    , input p-upper-code
                    , input p-host-code
                    , input p-obj-type
                    , input p-obj-code
                ) no-error.
                if error-status :error
                then do:
                    message
                             vss-workfile vss-revision vss-description
                        skip(1)
                        skip "Ошибка заполнения таблицы налогов для групп товаров."
                        skip return-value
                        skip trim(error-status :get-message(1))
                             trim(error-status :get-message(2))
                             trim(error-status :get-message(3))
                    view-as alert-box error.
                    undo, return error .
                end.
            end.
            else do:
                for each tt-tax:
                    delete tt-tax.
                end.
            end.
            run ref/dtaxgrpu.p (
                  input p-node-code
                , input p-upper-code
                , input yes
                , input p-host-code
                , input p-obj-type
                , input p-obj-code
            ) no-error.
            if error-status :error
            then do:
                message
                         vss-workfile vss-revision vss-description
                    skip(1)
                    skip "Ошибка привязки налогов к группе товаров."
                    skip return-value
                    skip trim(error-status :get-message(1))
                         trim(error-status :get-message(2))
                         trim(error-status :get-message(3))
                view-as alert-box error.
                undo, return error .
            end.
end.
