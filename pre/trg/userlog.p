block-level on error undo, throw.
define input parameter p-action         as character        no-undo.
define input parameter p-tbl-name       as character        no-undo.
define input parameter p-table-handle  as handle           no-undo.
define input parameter p-video-action  as integer           no-undo.
define input parameter p-video-param   as longchar          no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Процедура заполнения таблицы истории пользователя.".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable vss-include-info0 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_userlog-bush no-undo
  field ulb-key       as integer
  field ulbType       as integer
  field ulbParentKey  as integer
  field ulbTableName  as character
  field ulbTwoKey     as character
  field ulbParentDesc as character
  field ulbDesc       as character
  field selected      as logical
  index pi is primary unique
  ulb-key
  index utbl
  ulbType
  ulbParentKey
  ulbTableName
  index tbl
  ulbType
  ulbTableName
  ulbTwoKey
  index sel
  selected
  .
define variable v-userlog-0-ulb-key as integer no-undo.
procedure userlog-hist-table-init :
  define input parameter p-table-name     as character        no-undo.
  define buffer buf_temp_userlog-bush        for temp_userlog-bush.
  define buffer buf_parent_temp_userlog-bush for temp_userlog-bush.
  do
    for buf_temp_userlog-bush
    , buf_parent_temp_userlog-bush
    on error undo, return error
    :
    run userlog-hist-table-init-all in this-procedure .
    for each buf_temp_userlog-bush
      where buf_temp_userlog-bush.ulbTableName = p-table-name
      :
      assign
        buf_temp_userlog-bush.selected = yes
        .
      find first buf_parent_temp_userlog-bush
        where buf_parent_temp_userlog-bush.ulb-key = buf_temp_userlog-bush.ulbParentKey
        no-error.
        if available buf_parent_temp_userlog-bush
        then do:
            assign
                buf_parent_temp_userlog-bush.selected = yes
            .
        end.
    end.
    for each buf_temp_userlog-bush
       where buf_temp_userlog-bush.selected = no
    :
        delete buf_temp_userlog-bush.
    end.
end.
end procedure.
procedure userlog-hist-table-init-all :
  define variable v-success as logical   no-undo.
  define variable v-err-msg as character no-undo.
  do
    on error undo, return error
    :
    assign
      v-err-msg = "":U
      .
    run userlog-hist-table-add in this-procedure ( input 0, input "c-gds-hist               ":U, input "c-gds-obj-attr              ":U, input "                                                ", input "атрибута товара на объекте                                        ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-gds-hist               ":U, input "c-gds-host-attr             ":U, input "                                                ", input "атрибута товара на фирме                                          ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-gds-hist               ":U, input "c-goods-attr                ":U, input "                                                ", input "атрибута товара                                                   ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-gds-hist               ":U, input "c-goods                     ":U, input "                                                ", input "товара                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-gds-hist               ":U, input "c-fbr-gds-obj               ":U, input "                                                ", input "товара для производства на объекте                                ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-gds-hist               ":U, input "c-s-coeff                   ":U, input "                                                ", input "сезонного коэффициента                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-gds-hist               ":U, input "c-prod-bc                   ":U, input "                                                ", input "дополнительного бар-кода производител                             ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-gds-hist               ":U, input "c-bar-code                  ":U, input "                                                ", input "бар-кода                                                          ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-gds-hist               ":U, input "c-varianty-delivery-gds-obj ":U, input "                                                ", input "варианта доставки товара на объект                                ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-gds-hist               ":U, input "c-gds-season                ":U, input "                                                ", input "сезонных характеристик товара                                     ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-gds-hist               ":U, input "tax-rate-gds                ":U, input "                                                ", input "ставки налога для товара                                          ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-gds-hist               ":U, input "c-assortment-matrix-goods   ":U, input "                                                ", input "товара ассортиментной матрицы                                     ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-gds-hist               ":U, input "c-gds-obj-prop              ":U, input "                                                ", input "свойства товара на объекте                                        ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-gds-hist               ":U, input "c-pl-gds                    ":U, input "                                                ", input "хранения товара на складском месте                                ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-gds-hist               ":U, input "c-pl-gds-attr               ":U, input "                                                ", input "атрибута хранения товара на складском месте                       ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-gds-hist               ":U, input "c-pl-gds-pump               ":U, input "                                                ", input "поиска контейнера через товар и ТРК (бензин)                      ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-gds-hist               ":U, input "c-dis-gds-rule              ":U, input "                                                ", input "правила скидок на товар                                           ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-gds-hist               ":U, input "c-ext-artic                 ":U, input "                                                ", input "внешнего артикула                                                 ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-gds-hist               ":U, input "c-sert                      ":U, input "                                                ", input "сертификата                                                       ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-gds-hist               ":U, input "c-recipe                    ":U, input "                                                ", input "рецепта производства                                              ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-gds-hist               ":U, input "c-recipe-gds                ":U, input "                                                ", input "товара рецепта производства                                       ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-cli-hist               ":U, input "c-clients                   ":U, input "                                                ", input "клиента                                                           ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-cli-hist               ":U, input "c-clients-attr              ":U, input "                                                ", input "атрибута клиента                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-cli-hist               ":U, input "c-sysconf                   ":U, input "                                                ", input "системных настроек                                                ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-cli-hist               ":U, input "c-person                    ":U, input "                                                ", input "справочника физических лиц                                        ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-cli-hist               ":U, input "c-firm                      ":U, input "                                                ", input "организации                                                       ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-cli-hist               ":U, input "c-shop                      ":U, input "                                                ", input "магазина                                                          ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-cli-hist               ":U, input "c-store                     ":U, input "                                                ", input "склада                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-cli-hist               ":U, input "c-staff                     ":U, input "                                                ", input "персонала                                                         ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-cli-hist               ":U, input "c-dis-thbj-rule             ":U, input "                                                ", input "нетоварной скидки по объекту                                      ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-cli-hist               ":U, input "c-thbj-attr                 ":U, input "                                                ", input "параметра объекта TH                                              ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-dc-hist                ":U, input "c-dis-card                  ":U, input "                                                ", input "дисконтной карты                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-dc-hist                ":U, input "c-dis-obj                   ":U, input "                                                ", input "итогов для дисконтной карты на объекте                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-dc-hist                ":U, input "c-dis-host                  ":U, input "                                                ", input "итогов для дисконтной карты на фирме                              ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-dc-hist                ":U, input "c-dis-card-property         ":U, input "                                                ", input "свойств дисконтной карты                                          ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-dc-hist                ":U, input "c-dis-dc-rule               ":U, input "                                                ", input "скидок по отдельной дисконтной карте                              ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-tax-hist               ":U, input "c-tax-hist                  ":U, input "                                                ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-tax-hist               ":U, input "c-tax                       ":U, input "                                                ", input "налога                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-tax-hist               ":U, input "c-tax-rate                  ":U, input "                                                ", input "ставки налога                                                     ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-tax-hist               ":U, input "tax-rate-value              ":U, input "                                                ", input "значения ставки налога                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-tax-hist               ":U, input "c-tax-units                 ":U, input "                                                ", input "налога для типов товара в соответствии с ед.изм                   ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-gds-grp-hist           ":U, input "c-gds-grp                   ":U, input "                                                ", input "групп товаров                                                     ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-gds-grp-hist           ":U, input "c-gds-grp-attr              ":U, input "                                                ", input "атрибутов групп товаров                                           ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-gds-grp-hist           ":U, input "c-gds-grp-obj               ":U, input "                                                ", input "параметров групп товаров на объектах и фирмах                     ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-gds-grp-hist           ":U, input "c-tax-rate-gds-grp          ":U, input "                                                ", input "налоги группы товаров на объектах и фирмах                        ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-gds-grp-hist           ":U, input "c-dis-grp-rule              ":U, input "                                                ", input "правил скидок по группе товаров                                   ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-wth-hist               ":U, input "c-wealth                    ":U, input "                                                ", input "справочника матценности                                           ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-wth-hist               ":U, input "c-wth-par                   ":U, input "                                                ", input "номиналов матценностей                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-fbr-gds-grp-hist       ":U, input "c-fbr-gds-grp               ":U, input "                                                ", input "группы товара производства                                        ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-fbr-gds-grp-hist       ":U, input "c-fbr-gds-grp-attr          ":U, input "                                                ", input "атрибута группы товара производства                               ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-plc-hist               ":U, input "c-pl-level                  ":U, input "                                                ", input "градуировочной таблицы по резервуару                              ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-plc-hist               ":U, input "c-place-attr                ":U, input "                                                ", input "атрибута складского места                                         ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-plc-hist               ":U, input "c-pl-gds                    ":U, input "                                                ", input "хранения товара на складском месте                                ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-plc-hist               ":U, input "c-pl-gds-pump               ":U, input "                                                ", input "поиска контейнера через товар и ТРК (бензин)                      ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-plc-hist               ":U, input "c-pl-pump                   ":U, input "                                                ", input "соответствия ТРК контейнеру (складскому месту)                    ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-plc-hist               ":U, input "c-pl-pump-nozzle            ":U, input "                                                ", input "соответствия пистолета и ТРК                                      ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-plc-hist               ":U, input "c-pl-gds-attr               ":U, input "                                                ", input "атрибута хранения товара на складском месте                       ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-pmp-hist               ":U, input "c-pump                      ":U, input "                                                ", input "ТРК                                                               ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-pmp-hist               ":U, input "c-pump-attr                 ":U, input "                                                ", input "атрибутов ТРК                                                     ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-pmp-hist               ":U, input "c-pump-nozzle               ":U, input "                                                ", input "пистолетов ТРК на объекте                                         ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-pmp-hist               ":U, input "c-pl-gds-pump               ":U, input "                                                ", input "поиска контейнера через товар и ТРК (бензин)                      ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-pmp-hist               ":U, input "c-pl-pump                   ":U, input "                                                ", input "соответствия ТРК контейнеру (складскому месту)                    ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-pmp-hist               ":U, input "c-pl-pump-nozzle            ":U, input "                                                ", input "соответствия пистолета и ТРК                                      ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-nzl-hist               ":U, input "c-nozzle                    ":U, input "                                                ", input "пистолета ТРК                                                     ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-nzl-hist               ":U, input "c-nozzle-attr               ":U, input "                                                ", input "атрибута пистолета ТРК                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-nzl-hist               ":U, input "c-pump-nozzle               ":U, input "                                                ", input "пистолетов ТРК на объекте                                         ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-nzl-hist               ":U, input "c-pl-pump-nozzle            ":U, input "                                                ", input "соответствия пистолета и ТРК                                      ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-sht-hist               ":U, input "c-shift-obj                 ":U, input "                                                ", input "смены                                                             ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-sht-hist               ":U, input "c-shift-staff               ":U, input "                                                ", input "персонала смены на объекте                                        ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-recipe-hist            ":U, input "c-recipe                    ":U, input "                                                ", input "рецепта производства                                              ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-recipe-hist            ":U, input "c-recipe-gds                ":U, input "                                                ", input "товара рецепта производства                                       ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-recipe-hist            ":U, input "c-recipe-develop            ":U, input "                                                ", input "актов проработки                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-auto-tank              ":U, input "c-auto-tank                 ":U, input "                                                ", input "цистерны                                                          ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-cash-desk              ":U, input "c-cash-desk                 ":U, input "                                                ", input "справочника касс                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-cash-desk              ":U, input "c-cash-desk-attr            ":U, input "                                                ", input "атрибута справочника касс                                         ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-cash-pay               ":U, input "c-cash-pay                  ":U, input "                                                ", input "типа платежа                                                      ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-cash-pay               ":U, input "c-dis-cp-rule               ":U, input "                                                ", input "cкидки на платёж                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-cash-pay               ":U, input "c-cash-pay-attr             ":U, input "                                                ", input "атрибута типа платежа                                             ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-dis-card-type          ":U, input "c-dis-card-type             ":U, input "                                                ", input "типа дисконтной карты                                             ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-dis-card-type          ":U, input "c-dis-card-type-attr        ":U, input "                                                ", input "атрибута типа дисконтной карты                                    ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-dis-card-type          ":U, input "c-dis-card-mask             ":U, input "                                                ", input "маски дисконтной карты                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-dis-card-type          ":U, input "c-rp-by-call                ":U, input "                                                ", input "привязки профайла к месту                                         ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-dis-card-type          ":U, input "c-rule-by-call              ":U, input "                                                ", input "алгоритма обработки                                               ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-dis-card-type          ":U, input "c-rule-call-param           ":U, input "                                                ", input "параметра вызова правил                                           ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-dis-card-type          ":U, input "c-dis-dct-rule              ":U, input "                                                ", input "скидки по типу дисконтных карт                                    ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-dis-card-type          ":U, input "c-hist-nws-option           ":U, input "                                                ", input "опций создания истории и маршрутизации                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-fbr-prn                ":U, input "c-fbr-prn                   ":U, input "                                                ", input "принтера производства                                             ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-fbr-prn                ":U, input "c-fbr-prn-gds               ":U, input "                                                ", input "товаров принтера производства                                     ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-fbr-prn                ":U, input "c-fbr-prn-grp               ":U, input "                                                ", input "группы товаров принтера производства                              ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-prop-head              ":U, input "c-prop-head                 ":U, input "                                                ", input "декларации свойств                                                ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-prop-head              ":U, input "c-pscript-ruleset           ":U, input "                                                ", input "связи свойства объекта<->набор правил                             ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-prop-head              ":U, input "c-prop-script               ":U, input "                                                ", input "скриптов для объектов                                             ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-prop-head              ":U, input "c-prop-ruleset              ":U, input "                                                ", input "объектов - наборов правил                                         ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-prop-head              ":U, input "c-prop-ref                  ":U, input "                                                ", input "типов срезов хранилища                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-rule                   ":U, input "c-rule                      ":U, input "                                                ", input "правила                                                           ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-rule                   ":U, input "c-rule-by-set               ":U, input "                                                ", input "привязки правила к наборам                                        ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-rule-profile           ":U, input "c-rule-profile              ":U, input "                                                ", input "профайла                                                          ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-rule-profile           ":U, input "c-rule-by-profile           ":U, input "                                                ", input "привязки правила к профайлу                                       ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-ruledict               ":U, input "c-ruledict                  ":U, input "                                                ", input "словаря правил                                                    ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-ruledict               ":U, input "c-ruledict-param            ":U, input "                                                ", input "параметров статей словаря правил                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-scales                 ":U, input "c-scales                    ":U, input "                                                ", input "весов                                                             ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-scales                 ":U, input "c-scales-attr               ":U, input "                                                ", input "атрибутов весов                                                   ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-scales                 ":U, input "c-scales-gds                ":U, input "                                                ", input "товара на весах                                                   ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-scales                 ":U, input "c-scales-grp                ":U, input "                                                ", input "связи группы товара и весов                                       ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 0, input "c-sert                   ":U, input "c-sert                      ":U, input "                                                ", input "сертификата                                                       ":U, input v-err-msg, output v-err-msg ).
                                                                                                                                            .
    run userlog-hist-table-add in this-procedure ( input 1, input "c-add-doc              ":U, input "c-add-doc                   ":U, input "документа дополнительных расходов               ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-add-doc              ":U, input "c-add-line                  ":U, input "документа дополнительных расходов               ", input "строки                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-add-doc              ":U, input "c-parts-add                 ":U, input "документа дополнительных расходов               ", input "суммы доп.расхода в учетной цене партии                           ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-add-doc              ":U, input "c-gds-add-charges           ":U, input "документа дополнительных расходов               ", input "по товарам                                                        ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-add-doc              ":U, input "c-gds-add-charges-attr      ":U, input "документа дополнительных расходов               ", input "атрибутов по товарам                                              ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-alc-sale-lic         ":U, input "c-alc-sale-lic              ":U, input "лицензии на продажу алкоголя                    ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-alc-sale-lic         ":U, input "c-alc-sale-lic-attr         ":U, input "лицензии на продажу алкоголя                    ", input "атрибута                                                          ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-alc-sale-lic         ":U, input "c-alc-sale-lic-type         ":U, input "лицензии на продажу алкоголя                    ", input "типа                                                              ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-alc-supp-lic         ":U, input "c-alc-supp-lic              ":U, input "лицензии на поставку алкоголя                   ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-alc-supp-lic         ":U, input "c-alc-supp-lic-attr         ":U, input "лицензии на поставку алкоголя                   ", input "атрибута                                                          ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-alc-supp-lic         ":U, input "c-alc-supp-lic-type         ":U, input "лицензии на поставку алкоголя                   ", input "типа                                                              ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-alc-type             ":U, input "c-alc-type                  ":U, input "вида алкогольной продукции                      ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-alc-type             ":U, input "c-alc-type-attr             ":U, input "вида алкогольной продукции                      ", input "атрибута                                                          ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-alc-type             ":U, input "c-alc-type-gds              ":U, input "вида алкогольной продукции                      ", input "товара                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-action-role          ":U, input "c-action-role               ":U, input "группы прав                                     ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "action-role            ":U, input "action-role                 ":U, input "группы прав                                     ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-action-role-item     ":U, input "c-action-role-item          ":U, input "пунктов группы прав                             ", input "                                                                   ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "action-role-item       ":U, input "action-role-item            ":U, input "пунктов группы прав                             ", input "                                                                   ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-assortment-matrix    ":U, input "c-assortment-matrix         ":U, input "ассортиментной матрицы                          ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-cbr-bank             ":U, input "c-cbr-bank                  ":U, input "банка из списков ЦБ РФ                          ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-cd-clu               ":U, input "c-cd-clu                    ":U, input "кода клиента на кассе                           ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-cd-dlu               ":U, input "c-cd-dlu                    ":U, input "дисконтной карты на кассе                       ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-cd-doc               ":U, input "c-cd-doc                    ":U, input "документа на кассе                              ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-cd-doc               ":U, input "c-cd-doc-line               ":U, input "документа на кассе                              ", input "строки                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-cd-grp               ":U, input "c-cd-grp                    ":U, input "группы на кассе                                 ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-cd-plu               ":U, input "c-cd-plu                    ":U, input "кода товара на кассе                            ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "chk-doc                ":U, input "chk-doc                     ":U, input "кассового чека                                  ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-chk-doc              ":U, input "c-chk-doc                   ":U, input "кассового чека                                  ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-chk-doc              ":U, input "c-chk-discnt                ":U, input "кассового чека                                  ", input "скидки                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-chk-doc              ":U, input "c-chk-pay                   ":U, input "кассового чека                                  ", input "оплаты                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-chk-doc              ":U, input "c-chk-gds                   ":U, input "кассового чека                                  ", input "товара                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-chk-doc-attr         ":U, input "c-chk-doc-attr              ":U, input "кассового чека или кассового чека МЦ            ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-chk-title            ":U, input "c-chk-title                 ":U, input "кассового чека матценностей                     ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-chk-title            ":U, input "c-chk-inst                  ":U, input "кассового чека матценностей                     ", input "строки                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-chk-title            ":U, input "c-chk-par                   ":U, input "кассового чека матценностей                     ", input "купюрности матценности                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-cli-grp              ":U, input "c-cli-grp                   ":U, input "                                                ", input "группы клиентов                                                   ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "clients                ":U, input "clients                     ":U, input "                                                ", input "справочника клиентов                                              ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "cli-grp                ":U, input "cli-grp                     ":U, input "                                                ", input "группы клиентов                                                   ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "auto-tank              ":U, input "auto-tank                   ":U, input "                                                ", input "автотранспорта                                                    ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-condition-keeping    ":U, input "c-condition-keeping         ":U, input "                                                ", input "условий хранени                                                   ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-config               ":U, input "c-config                    ":U, input "                                                ", input "конфигурации или настроек системы                                 ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "config                 ":U, input "config                      ":U, input "                                                ", input "конфигурации или настроек системы                                 ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "clob-bind              ":U, input "clob-bind                   ":U, input "                                                ", input "средства измерения                                                ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-contract             ":U, input "c-contract                  ":U, input "договора с контрагентами                        ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-contract             ":U, input "c-contract-line             ":U, input "договора с контрагентами                        ", input "строки                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-contract             ":U, input "c-contract-specif           ":U, input "договора с контрагентами                        ", input "спецификации товара                                               ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-country              ":U, input "c-country                   ":U, input "                                                ", input "страны                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-curr-accnt           ":U, input "c-curr-accnt                ":U, input "                                                ", input "биржевых курсов валют                                             ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-curr-bank            ":U, input "c-curr-bank                 ":U, input "                                                ", input "курсов валют системы                                              ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-currency             ":U, input "c-currency                  ":U, input "                                                ", input "валюты                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-global-state         ":U, input "c-global-state              ":U, input "глобальных настроек ценообразования             ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-global-state         ":U, input "c-global-state-attr         ":U, input "глобальных настроек ценообразования             ", input "атрибутов                                                         ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-grp-obj-price        ":U, input "c-grp-obj-price             ":U, input "группы объектов для ценообразования             ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-grp-obj-price        ":U, input "c-db-grp-obj-price          ":U, input "группы объектов для ценообразования             ", input "БД                                                                ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-grp-obj-price        ":U, input "c-host-grp-obj-price        ":U, input "группы объектов для ценообразования             ", input "фирмы                                                             ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-grp-obj-price        ":U, input "c-obj-grp-obj-price         ":U, input "группы объектов для ценообразования             ", input "объекта                                                           ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-qnty-group           ":U, input "c-qnty-group                ":U, input "количественной группы                           ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-qnty-group           ":U, input "c-qnty-in-qnty-group        ":U, input "количественной группы                           ", input "количества                                                        ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-sum-group            ":U, input "c-sum-group                 ":U, input "суммовой группы                                 ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-sum-group            ":U, input "c-sum-in-sum-group          ":U, input "суммовой группы                                 ", input "суммы                                                             ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-buyer-group          ":U, input "c-buyer-group               ":U, input "группы покупателей                              ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-buyer-group          ":U, input "c-buyer-in-buyer-group      ":U, input "группы покупателей                              ", input "покупателя                                                        ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-turnover-group       ":U, input "c-turnover-group            ":U, input "группы оборотов                                 ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-tnv-in-turnover-group":U, input "c-tnv-in-turnover-group     ":U, input "разбивки оборотов по покупателям                ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "dis-card                ":U, input "dis-card                   ":U, input "дисконтных карт                                 ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "dis-card-type           ":U, input "dis-card-type              ":U, input "типов дисконтных карт                           ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-dis-rule             ":U, input "c-dis-rule                  ":U, input "правила скидок                                  ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-dis-time-rule        ":U, input "c-dis-time-rule             ":U, input "расписани                                       ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-trn-doc              ":U, input "c-trn-doc                   ":U, input "складского документа                            ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-trn-doc              ":U, input "c-trn-doc-sum               ":U, input "складского документа                            ", input "сумм по документу                                                 ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-trn-doc              ":U, input "c-doc-attr                  ":U, input "складского документа                            ", input "атрибута                                                          ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-trn-doc              ":U, input "c-doc-fbr-gds               ":U, input "складского документа                            ", input "товаров для автопроизводства                                      ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-trn-doc              ":U, input "c-doc-line                  ":U, input "складского документа                            ", input "строки                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-trn-doc              ":U, input "c-doc-line-attr             ":U, input "складского документа                            ", input "атрибута строки                                                   ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-trn-doc              ":U, input "c-doc-line-sum              ":U, input "складского документа                            ", input "сумм по строке документа                                          ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-trn-doc              ":U, input "c-doc-pl                    ":U, input "складского документа                            ", input "количества по строке из данного складского места                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-trn-doc              ":U, input "c-doc-pl-pump               ":U, input "складского документа                            ", input "количества по строке из данного складского места и конкретной трк ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-trn-doc              ":U, input "c-doc-prts                  ":U, input "складского документа                            ", input "требования на резервирование партии в накладной                   ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-trn-doc              ":U, input "c-gds-dtl                   ":U, input "складского документа                            ", input "признака строки                                                   ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-trn-doc              ":U, input "c-inv-line                  ":U, input "складского документа                            ", input "доп. информации по строкам инвентаризации                         ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-trn-doc              ":U, input "c-parts                     ":U, input "складского документа                            ", input "партии                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-trn-doc              ":U, input "c-parts-attr                ":U, input "складского документа                            ", input "атрибута партии                                                   ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-trn-doc              ":U, input "c-parts-root                ":U, input "складского документа                            ", input "порождающих партий                                                ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-trn-doc              ":U, input "c-clc-sum                   ":U, input "складского документа                            ", input "сумм в расчетах по накладной                                      ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "trn-doc                ":U, input "trn-doc                     ":U, input "складского документа                            ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-sr-izmerenia         ":U, input "c-sr-izmerenia               ":U, input "средства измерения                              ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "goods                   ":U, input "goods                       ":U, input "товара                                         ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "gds-grp                 ":U, input "gds-grp                     ":U, input "группы товара                                  ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-ext-system           ":U, input "c-ext-system                ":U, input "внешней системы OpenXML                         ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-ext-system           ":U, input "c-esys-datatype-exp         ":U, input "внешней системы OpenXML                         ", input "типа данных экспорта                                              ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-ext-system           ":U, input "c-esys-datatype-imp         ":U, input "внешней системы OpenXML                         ", input "типа данных импорта                                               ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-ex-mark              ":U, input "c-ex-mark                   ":U, input "акцизных и специальных марок                    ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-ext-classif          ":U, input "c-ext-classif               ":U, input "внешнего классификатора                         ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "fbr-doc                ":U, input "fbr-doc                     ":U, input "документа производства                          ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-fbr-doc              ":U, input "c-fbr-doc                   ":U, input "документа производства                          ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-fbr-doc              ":U, input "c-fbr-line                  ":U, input "документа производства                          ", input "строки                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-sht-hist             ":U, input "c-sht-hist                  ":U, input "смены                                           ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-sht-hist             ":U, input "c-sht-hist-line             ":U, input "смены                                           ", input "строки                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "shift-obj              ":U, input "shift-obj                   ":U, input "смены                                           ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "shift-obj              ":U, input "shift-staff                 ":U, input "смены                                           ", input "персонала                                                         ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add        in this-procedure ( input 1, input "c-usr-hist             ":U, input "c-usr-hist                  ":U,                                         input "времени входа                                   ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-twokey-add in this-procedure ( input 1, input "c-usr-hist             ":U, input "c-user-login                ":U, input "user-password               ":U, input "пароля                                          ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-twokey-add in this-procedure ( input 1, input "c-usr-hist             ":U, input "c-user-login                ":U, input "adm                         ":U, input "прав администратора                             ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add        in this-procedure ( input 1, input "c-usr-hist             ":U, input "c-user-account              ":U,                                         input "пользователя системы                            ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add        in this-procedure ( input 1, input "c-usr-hist             ":U, input "c-user-login                ":U,                                         input "логина пользователя системы                     ", input "строки                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-twokey-add in this-procedure ( input 1, input "c-usr-hist             ":U, input "user-account                ":U, input "SuperAdm                    ":U, input "права супер администратора                      ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add        in this-procedure ( input 1, input "c-usr-hist             ":U, input "user-account                ":U,                                         input "пользователя системы                            ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add        in this-procedure ( input 1, input "c-usr-hist             ":U, input "user-obj                    ":U,                                         input "объекта пользователя                            ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add        in this-procedure ( input 1, input "c-usr-hist             ":U, input "user-host                   ":U,                                         input "фирмы пользователя                              ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add        in this-procedure ( input 1, input "c-usr-hist             ":U, input "user-login-action-item      ":U,                                         input "права пользователя системы                            ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add        in this-procedure ( input 1, input "c-usr-hist             ":U, input "user-login-action-role      ":U,                                         input "группа прав пользователя системы                            ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add        in this-procedure ( input 1, input "c-usr-hist             ":U, input "user-menu-group             ":U,                                         input "меню пользователя системы                            ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-fbr-pln              ":U, input "c-fbr-pln                   ":U, input "документа план-меню                             ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-fbr-pln              ":U, input "c-fbr-pln-line              ":U, input "документа план-меню                             ", input "строки                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-fin-bank             ":U, input "c-fin-bank                  ":U, input "реквизитов банка                                ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "fin-bank               ":U, input "fin-bank                    ":U, input "реквизитов банка                                ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-fin-code-an-uchet    ":U, input "c-fin-code-an-uchet         ":U, input "кодов аналитического учёта                      ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-fin-code-cel-nazn    ":U, input "c-fin-code-cel-nazn         ":U, input "кодов целевого назначения                       ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-fin-code-cor-acc     ":U, input "c-fin-code-cor-acc          ":U, input "корреспондирующих счетов                        ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-fin-doc              ":U, input "c-fin-doc                   ":U, input "финансового документа                           ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-fin-doc              ":U, input "c-fin-connect               ":U, input "финансового документа                           ", input "связи с финансовыми обязательствами                               ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-fin-doc              ":U, input "c-fin-doc-attr              ":U, input "финансового документа                           ", input "атрибутов                                                         ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-fin-doc              ":U, input "c-fin-doc-tax               ":U, input "финансового документа                           ", input "налогов                                                           ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-fin-ob               ":U, input "c-fin-ob                    ":U, input "финансового обязательства                       ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-fin-ob               ":U, input "c-fin-ob-attr               ":U, input "финансового обязательства                       ", input "атрибутов                                                         ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-fin-ob               ":U, input "c-fin-ob-tax                ":U, input "финансового обязательства                       ", input "налогов                                                           ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-fin-ob               ":U, input "c-fin-gds-part              ":U, input "финансового обязательства                       ", input "партий                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-fin-schet            ":U, input "c-fin-schet                 ":U, input "финансовых реквизитов                           ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-fin-statement        ":U, input "c-fin-statement             ":U, input "банковских выписок                              ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-fin-statement        ":U, input "c-fin-statement-attr        ":U, input "банковских выписок                              ", input "атрибутов                                                         ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-fin-statement        ":U, input "c-fin-statement-line        ":U, input "банковских выписок                              ", input "строк                                                             ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-gds-prt              ":U, input "c-gds-prt                   ":U, input "признаков товаров                               ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-group-period-validity":U, input "c-group-period-validity     ":U, input "группы сроков хранения                          ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-inkas                ":U, input "c-inkas                     ":U, input "кассового отчёта                                ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-inkas                ":U, input "c-inkas-pay                 ":U, input "кассового отчёта                                ", input "по видам оплаты                                                   ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-inkas                ":U, input "c-inkas-pay-desk            ":U, input "кассового отчёта                                ", input "выручки по кассам                                                 ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "ord-doc                ":U, input "ord-doc                     ":U, input "заказа поставщикам и покупателям                ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-ord-doc              ":U, input "c-ord-doc                   ":U, input "заказа поставщикам и покупателям                ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-ord-doc              ":U, input "c-ord-doc-attr              ":U, input "заказа поставщикам и покупателям                ", input "атрибутов                                                         ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-ord-doc              ":U, input "c-ord-dtl                   ":U, input "заказа поставщикам и покупателям                ", input "признаков по товарам                                              ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-ord-doc              ":U, input "c-ord-line                  ":U, input "заказа поставщикам и покупателям                ", input "строки                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-ord-doc              ":U, input "c-ord-line-attr             ":U, input "заказа поставщикам и покупателям                ", input "атрибутов строки                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-pay-type             ":U, input "c-pay-type                  ":U, input "вида оплаты                                     ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "pay-type               ":U, input "pay-type                    ":U, input "вида оплаты                                     ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-place-io             ":U, input "c-place-io                  ":U, input "места отгрузки/приёмки                          ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "place                  ":U, input "place                       ":U, input "складского места                                ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-place                ":U, input "c-place                     ":U, input "складского места                                ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "pl-level               ":U, input "pl-level                    ":U, input "градуировочной таблицы                          ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "pl-pump-nozzle         ":U, input "pl-pump-nozzle              ":U, input "соответствия пистолета и ТРК                    ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "pl-gds                 ":U, input "pl-gds                      ":U, input "товара на складском месте                       ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "pl-pump                ":U, input "pl-pump                     ":U, input "соответствия ТРК контейнеру (складскому месту)  ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "pl-gds-pump            ":U, input "pl-gds-pump                 ":U, input "поиска контейнера через товар и ТРК (бензин)    ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-plc-hist             ":U, input "c-plc-hist                  ":U, input "хранения товара на складском месте              ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-point-io             ":U, input "c-point-io                  ":U, input "пункта отгрузки/доставки                        ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-price-doc            ":U, input "c-price-doc                 ":U, input "документа переоценки                            ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-price-doc            ":U, input "c-price-list                ":U, input "документа переоценки                            ", input "строки                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-price-doc            ":U, input "c-price-list-attr           ":U, input "документа переоценки                            ", input "атрибута строки                                                   ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "price-doc              ":U, input "price-doc                   ":U, input "документа переоценки                            ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-price-list-type      ":U, input "c-price-list-type           ":U, input "типа прайс-листа                                ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-price-list-type      ":U, input "c-price-list-type-attr      ":U, input "типа прайс-листа                                ", input "атрибута                                                          ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-price-list-type      ":U, input "c-price-list-type-cash-pay  ":U, input "типа прайс-листа                                ", input "ограничения по типам кассовых платежей                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-price-list-type      ":U, input "c-price-list-type-cassa     ":U, input "типа прайс-листа                                ", input "связи с кассами                                                   ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-price-list-type      ":U, input "c-price-list-type-gds-grp   ":U, input "типа прайс-листа                                ", input "ограничения по группам товаров                                    ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-price-list-type      ":U, input "c-price-list-type-pay-type  ":U, input "типа прайс-листа                                ", input "ограничения по типам платежа                                      ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "price-doc-forming      ":U, input "price-doc-forming           ":U, input "документа формирования цены                     ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-price-doc-forming    ":U, input "c-price-doc-forming         ":U, input "документа формирования цены                     ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-price-doc-forming    ":U, input "c-price-doc-forming-attr    ":U, input "документа формирования цены                     ", input "атрибута                                                          ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-price-doc-forming    ":U, input "c-price-doc-forming-gds     ":U, input "документа формирования цены                     ", input "товара                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-price-doc-forming    ":U, input "c-price-doc-forming-gds-qnty":U, input "документа формирования цены                     ", input "товара по количеству                                              ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-price-doc-forming    ":U, input "c-price-doc-forming-gds-sum ":U, input "документа формирования цены                     ", input "товара по сумме                                                   ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-price-doc-forming    ":U, input "c-price-doc-forming-gds-tnv ":U, input "документа формирования цены                     ", input "товара по обороту                                                 ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-price-doc-forming    ":U, input "c-price-doc-forming-gdsattr ":U, input "документа формирования цены                     ", input "атрибута товара                                                   ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-regions              ":U, input "c-regions                   ":U, input "региона                                         ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "cash-pay               ":U, input "cash-pay                    ":U, input "типов кассовых платежей                         ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "cash-desk              ":U, input "cash-desk                    ":U, input "справочника касс                               ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-rvs-doc              ":U, input "c-rvs-doc                   ":U, input "документа сверки                                ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-rvs-doc              ":U, input "c-rvs-line                  ":U, input "документа сверки                                ", input "строки                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-rvs-doc              ":U, input "c-rvs-line-pump             ":U, input "документа сверки                                ", input "нформации с ТРК по баку                                           ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-sale-doc             ":U, input "c-sale-doc                  ":U, input "документа продажи                               ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-schet-fact-doc       ":U, input "c-schet-fact-doc            ":U, input "счёта-фактуры                                   ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-schet-fact-doc       ":U, input "c-schet-fact-line           ":U, input "счёта-фактуры                                   ", input "строки                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-season               ":U, input "c-season                    ":U, input "справочника сезонов                             ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-stop-list            ":U, input "c-stop-list                 ":U, input "стоплиста                                       ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-stop-list            ":U, input "c-stop-list-line            ":U, input "стоплиста                                       ", input "строки                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-sum-grp              ":U, input "c-sum-grp                   ":U, input "группы для суммовых чеков                       ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-sum-grp-obj          ":U, input "c-sum-grp-obj               ":U, input "группы товаров на кассе на объекте              ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-trn-reason           ":U, input "c-trn-reason                ":U, input "основания создания документа                    ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-trn-reason           ":U, input "c-trn-rsn-attr              ":U, input "основания создания документа                    ", input "атрибутов                                                         ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-trn-reason           ":U, input "c-trn-reason-host           ":U, input "основания создания документа                    ", input "по умолчанию на фирме                                             ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-trn-reason           ":U, input "c-trn-reason-obj            ":U, input "основания создания документа                    ", input "по умолчанию на объекте                                           ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-units                ":U, input "c-units                     ":U, input "единиц измерения                                ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "units                  ":U, input "units                       ":U, input "единиц измерения                                ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-wth-doc              ":U, input "c-wth-doc                   ":U, input "документа перемещения матценностей              ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-wth-doc              ":U, input "c-wth-dtl                   ":U, input "документа перемещения матценностей              ", input "разбивки                                                          ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-wth-doc              ":U, input "c-wth-line                  ":U, input "документа перемещения матценностей              ", input "строки                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-wth-doc              ":U, input "c-wth-parts                 ":U, input "документа перемещения матценностей              ", input "партии                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-wth-gds              ":U, input "c-wth-gds                   ":U, input "связи матценности с товаром                     ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-wth-gds              ":U, input "c-wth-gds-attr              ":U, input "связи матценности с товаром                     ", input "атрибутов                                                         ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-wth-obj              ":U, input "c-wth-obj                   ":U, input "матценностей на объекте                         ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-wth-place            ":U, input "c-wth-place                 ":U, input "места хранения матценностей                     ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-wth-pobj             ":U, input "c-wth-pobj                  ":U, input "остатков матценностей на месте хранения (объект)", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-wth-ser              ":U, input "c-wth-ser                   ":U, input "маски (серии) матценностей                      ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "c-wth-ser              ":U, input "c-wth-ser-attr              ":U, input "маски (серии) матценностей                      ", input "атрибутов                                                         ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "rvs-doc                ":U, input "rvs-doc                     ":U, input "документа сверки                                ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "rvs-doc                ":U, input "rvs-line                    ":U, input "документа сверки                                ", input " строки                                                               ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "thbj-attr              ":U, input "thbj-attr                   ":U, input "параметра объекта TH                            ", input "                                                                ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input 1, input "staff                  ":U, input "staff                       ":U, input "данные персонала                                ", input "данные персонала                                                  ":U, input v-err-msg, output v-err-msg ).
    if v-err-msg <> "":U
      then
    do:
      message
        vss-workfile vss-revision vss-description
        skip(1)
        skip
        "Ошибка вычисления дерева таблиц истории пользователя."
        skip(1)
        skip v-err-msg
        view-as alert-box error.
      undo, return error.
    end.
  end.
end procedure.
procedure userlog-get-table-name :
  define input parameter p-ulb-key        as integer          no-undo.
  define output parameter p-table-name    as character        no-undo.
  define buffer buf_temp_userlog-bush for temp_userlog-bush.
  do
    for buf_temp_userlog-bush
    on error undo, return error
    :
    find first buf_temp_userlog-bush
      where buf_temp_userlog-bush.ulb-key = p-ulb-key
      no-error.
    if available buf_temp_userlog-bush
      then
    do:
      assign
        p-table-name = buf_temp_userlog-bush.ulbTableName
        .
    end.
    else
    do:
      assign
        p-table-name = "":U
        .
    end.
  end.
end procedure.
procedure userlog-hist-table-add :
  define input  parameter i-ulbType            as integer          no-undo.
  define input  parameter i-ParentTableName    as character        no-undo.
  define input  parameter i-TableName          as character        no-undo.
  define input  parameter i-ParentDesc         as character        no-undo.
  define input  parameter i-Desc               as character        no-undo.
  define input  parameter i-in-err-msg         as character        no-undo.
  define output parameter o-out-err-msg       as character        no-undo.
   run userlog-hist-table-twokey-add(input  i-ulbType,
                                     input  i-ParentTableName,
                                     input  i-TableName,
                                     input  "",
                                     input  i-ParentDesc,
                                     input  i-Desc,
                                     input  i-in-err-msg,
                                     output o-out-err-msg).
end.
procedure userlog-hist-table-twokey-add :
  define input parameter p-ulbType            as integer          no-undo.
  define input parameter p-ParentTableName    as character        no-undo.
  define input parameter p-TableName          as character        no-undo.
  define input parameter i-Twokey             as character        no-undo.
  define input parameter p-ParentDesc         as character        no-undo.
  define input parameter p-Desc               as character        no-undo.
  define input parameter p-in-err-msg         as character        no-undo.
  define output parameter p-out-err-msg       as character        no-undo.
  define variable v-err-msg    as character no-undo.
  define variable v-success    as logical   no-undo.
  define variable v-found      as logical   no-undo.
  define variable v-parent-key as integer   no-undo.
  define buffer buf_temp_userlog-bush        for temp_userlog-bush.
  define buffer buf_parent-temp_userlog-bush for temp_userlog-bush.
  do
    for buf_temp_userlog-bush
    , buf_parent-temp_userlog-bush
    on error undo, return error
    :
    assign
      v-success         = no
      p-out-err-msg     = p-in-err-msg
      p-ParentTableName = trim( p-ParentTableName   )
      p-TableName       = trim( p-TableName         )
      i-Twokey          = trim( i-Twokey            )
      p-Desc            = trim( p-Desc              )
      p-ParentDesc      = trim( p-ParentDesc        )
      .
    if p-ulbType <> 1
      and p-ulbType <> 0
      then
    do:
      assign
        v-success = no
        v-err-msg = "Неизвестный тип истории пользователя."
        .
    end.
    else
    do:
      if p-ParentTableName = "":U
        or p-ParentTableName = p-TableName
        then
      do:
        assign
          v-success    = yes
          v-err-msg    = "":U
          v-parent-key = 0
          .
        if p-ulbType = 0
          then
        do:
          run userlog-create-userlog-bush in this-procedure (
            input p-ulbType
            , input 0
            , input p-ParentTableName
            , input i-Twokey
            , input p-ParentTableName
            , input "":U
            ) no-error.
          if error-status :error
            then
          do:
            assign
              v-success = no
              v-err-msg = substitute( "Ошибка создания корневой записи. &1 &2", return-value, trim( error-status :get-message( 1 ) ) )
              .
          end.
          else
          do:
            find first buf_parent-temp_userlog-bush
              where buf_parent-temp_userlog-bush.ulbParentKey = 0
              and buf_parent-temp_userlog-bush.ulbTableName = p-ParentTableName
              no-error.
            if not available buf_parent-temp_userlog-bush
              then
            do:
              assign
                v-success = no
                v-err-msg = "Не удалось создать корневую запись."
                .
            end.
            else
            do:
              assign
                v-success    = yes
                v-err-msg    = "":U
                v-parent-key = buf_parent-temp_userlog-bush.ulb-key
                .
            end.
          end.
        end.
      end.
      else
      do:
        find first buf_parent-temp_userlog-bush
          where buf_parent-temp_userlog-bush.ulbParentKey = 0
          and buf_parent-temp_userlog-bush.ulbTableName = p-ParentTableName
          no-error.
        if not available buf_parent-temp_userlog-bush
          then
        do:
          if p-ulbType = 0
            then
          do:
            run userlog-create-userlog-bush in this-procedure (
              input p-ulbType
              , input 0
              , input p-ParentTableName
              , input i-Twokey
              , input p-ParentTableName
              , input "":U
              ) no-error.
            if error-status :error
              then
            do:
              assign
                v-success = no
                v-err-msg = substitute( "Ошибка создания записи. &1 &2", return-value, trim( error-status :get-message( 1 ) ) )
                .
            end.
            else
            do:
              find first buf_parent-temp_userlog-bush
                where buf_parent-temp_userlog-bush.ulbParentKey = 0
                and buf_parent-temp_userlog-bush.ulbTableName = p-ParentTableName
                no-error.
              if not available buf_parent-temp_userlog-bush
                then
              do:
                assign
                  v-success = no
                  v-err-msg = "Не удалось создать корневую запись."
                  .
              end.
              else
              do:
                assign
                  v-success    = yes
                  v-err-msg    = "":U
                  v-parent-key = buf_parent-temp_userlog-bush.ulb-key
                  .
              end.
            end.
          end.
          else
          do:
            assign
              v-success = no
              v-err-msg = "Неверно указан корневой узел."
              .
          end.
        end.
        else
        do:
          assign
            v-success    = yes
            v-err-msg    = "":U
            v-parent-key = buf_parent-temp_userlog-bush.ulb-key
            .
        end.
      end.
      if v-success       = yes
        then
      do:
        run userlog-create-userlog-bush in this-procedure (
          input p-ulbType
          , input v-parent-key
          , input p-TableName
          , input i-Twokey
          , input p-ParentDesc
          , input p-Desc
          ) no-error.
        if error-status :error
          then
        do:
          assign
            v-success = no
            v-err-msg = substitute( "Ошибка создания записи. &1 &2", return-value, trim( error-status :get-message( 1 ) ) )
            .
        end.
        else
        do:
          assign
            v-success = yes
            v-err-msg = "":U
            .
        end.
      end.
    end.
    if v-success = no
      then
    do:
      assign
        p-out-err-msg = substitute( "&1&2 &3. Тип: '&4'. Таблица: '&5'. Родитель: '&6'.":U
                                        , p-out-err-msg
                                        , ( if p-out-err-msg = "":U then "":U else chr(10) )
                                        , v-err-msg
                                        , p-ulbType
                                        , p-ParentTableName
                                        , p-TableName
                                        )
        .
    end.
  end.
end procedure.
procedure userlog-create-userlog-bush :
  define input parameter p-ulbType            as integer          no-undo.
  define input parameter p-parent-key         as integer          no-undo.
  define input parameter p-TableName          as character        no-undo.
  define input parameter i-TwoKey          as character        no-undo.
  define input parameter p-ParentDesc         as character        no-undo.
  define input parameter p-Desc               as character        no-undo.
  define buffer buf_temp_userlog-bush for temp_userlog-bush.
  do
    for buf_temp_userlog-bush
    on error undo, return error
    :
    assign
      v-userlog-0-ulb-key = v-userlog-0-ulb-key + 1
      .
    create buf_temp_userlog-bush.
    assign
      buf_temp_userlog-bush.ulb-key       = v-userlog-0-ulb-key
      buf_temp_userlog-bush.ulbType       = p-ulbType
      buf_temp_userlog-bush.ulbParentKey  = p-parent-key
      buf_temp_userlog-bush.ulbTableName  = p-TableName
      buf_temp_userlog-bush.ulbTwoKey     = i-TwoKey
      buf_temp_userlog-bush.ulbParentDesc = p-ParentDesc
      buf_temp_userlog-bush.ulbDesc       = p-Desc
      buf_temp_userlog-bush.selected      = no
      .
  end.
end procedure.
define variable vss-include-info1 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure schemlib-get-index-fields :
define input parameter p-table-name     as character        no-undo.
define output parameter p-field-list    as character        no-undo.
    define variable v-table-handle          as handle       no-undo.
    define variable v-field-handle          as handle       no-undo.
    define variable v-index-info            as character    no-undo.
    define variable v-counter               as integer      no-undo.
    define variable v-index-fields-amount   as integer      no-undo.
do
on error undo, return error
:
    if p-table-name = ?
    or p-table-name = "":U
    then do:
        return error substitute( "&1 (get-index-fields). Ошибка задания входных параметров. Задано пустое имя таблицы.", vss-workfile ).
    end.
    create buffer v-table-handle for table p-table-name no-error.
    if error-status :error
    then do:
        return error substitute( "&1 (get-index-fields). Ошибка задания входных параметров. Неверно задано имя таблицы '&2'.", vss-workfile, p-table-name ).
    end.
    assign
        v-counter       = 1
        v-index-info    = v-table-handle :index-information( v-counter )
    .
    do while v-index-info <> ?
    and entry( 3, v-index-info ) <> "1":U
    on error undo, return error
    :
        assign
            v-counter       = v-counter + 1
            v-index-info    = v-table-handle :index-information( v-counter )
        .
    end.
    if v-index-info = ?
    or LC( entry( 1, v-index-info ) ) = "default":U
    or entry( 3, v-index-info ) <> "1":U
    then do:
        return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-workfile, p-table-name ).
    end.
    else do:
        assign
            v-index-fields-amount = num-entries( v-index-info ) - 4
            p-field-list          = "":U
        .
        if v-index-fields-amount < 2
        then do:
            return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-workfile, v-index-info, p-table-name ).
        end.
        do v-counter = 1 to v-index-fields-amount by 2
        on error undo, return error
        :
            assign
                v-field-handle  = v-table-handle :buffer-field( entry( 4 + v-counter, v-index-info ) ).
            .
            assign
                p-field-list    = substitute( "&1&2&3":U
                                    , p-field-list
                                    , ( if p-field-list = "":U then "":U else ",":U )
                                    , v-field-handle :name
                                    )
            .
        end.
    end.
end.
end procedure.
procedure schemlib-set-buffer :
define input parameter p-table-name     as character        no-undo.
define input parameter p-field-list     as character        no-undo.
define input parameter p-value-list     as character        no-undo.
define output parameter p-buffer-handle as handle           no-undo.
    define variable v-query-handle      as handle       no-undo.
    define variable v-query-string      as character    no-undo.
    define variable v-field-handle      as handle       no-undo.
    define variable v-field-name        as character    no-undo.
    define variable v-field-value       as character    no-undo.
    define variable v-field-counter     as integer      no-undo.
    define variable v-counter           as integer      no-undo.
    define variable v-field-type        as character    no-undo.
do
on error undo, return error
:
    assign
        v-field-counter = num-entries( p-field-list )
    .
    if v-field-counter <> num-entries( p-value-list )
    then do:
        undo, return error substitute( "schemlib-set-buffer. Указан список значений '&1', не соответствующий списку полей '&2'."
                    , p-value-list
                    , p-field-list ).
    end.
    create buffer p-buffer-handle for table p-table-name.
    create query v-query-handle.
    v-query-handle :set-buffers( p-buffer-handle ).
    assign
        v-query-string  = substitute( "for each &1 no-lock":U, p-table-name )
    .
    do v-counter = 1 to v-field-counter
    on error undo, return error
    :
        assign
            v-field-name  = entry( v-counter, p-field-list )
            v-field-value = entry( v-counter, p-value-list )
        .
        assign
            v-field-handle = p-buffer-handle :buffer-field( v-field-name )
        .
        if not valid-handle( v-field-handle )
        then do:
            undo, return error substitute( "schemlib-set-buffer. Не найдено поле '&1' в таблице '&2'."
                    , v-field-name
                    , p-table-name ).
        end.
        assign
            v-field-type = v-field-handle :data-type
        .
        assign
            v-query-string  = substitute( "&1&2&3.&4=&5&6&5":U
                , v-query-string
                , ( if v-counter = 1 then " where ":U else " and ":U )
                , p-table-name
                , v-field-name
                , ( if v-field-type = "character":U then '"':U else "":U )
                , v-field-value
                )
        .
    end.
    v-query-handle :query-prepare( v-query-string ).
    v-query-handle :query-open.
    v-query-handle :get-first( no-lock ).
    delete object v-query-handle.
end.
end procedure.
def var vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info2 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info2, p-tbl-name ).
    end.
    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info2, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info2, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
        .
      end.
    end.
    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info2, p-tbl-name ).
    end.
  end.
  return.
end procedure.
procedure gen-where-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character  no-undo.
  define input  parameter p-key-rec    as character  no-undo.
  define input  parameter p-key-handle as handle     no-undo .
  define input  parameter p-db-name    as character  no-undo .
  define input  parameter p-tt-handle  as handle     no-undo .
  define output parameter o-Where      as character  no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable vTable           as character no-undo.
    define variable bh_tbl-key       as handle    no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do:
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info2 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info2, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info2 ).
      end.
    end.
    assign
      vTable = entry( 1 , p-key-rec, chr(3) )
    .
    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info2, vTable, chr(10) ).
    end.
    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info2, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info2, v-inform, vTable ).
    end.
    assign
      o-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    if i-tablekey ne "" and i-tablekey ne ?
    then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tablekey )
      .
      create buffer bh_tbl-key for table v-full-tbl-name .
    end.
    if i-tableSerach ne "" and i-tableSerach ne ?
    then do:
      delete object bh_tbl-name no-error.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.
      define variable VfieldKeyTable as handle no-undo.
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
      if     bh_tbl-key ne ?
      then do:
         VfieldKeyTable = bh_tbl-key:buffer-field( v-field-name ) no-error.
         if VfieldKeyTable eq ?
         then next block_where.
      end.
      if v-full-tbl-name ne "" and v-full-tbl-name ne ?
      then
         o-where = substitute( "&1 &2 &3.&4 =", o-where, v-word-link,v-full-tbl-name, v-field-name ).
      else
         o-where = substitute( "&1 &2 &3 =", o-where, v-word-link, v-field-name ).
      if p-key-handle = ? then do:
        assign
          v-field-val = replace (entry( v-count-fld + 1 , p-key-rec, chr(3) ),chr(2) + chr(9) + chr (2),chr(3))
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          delete object bh_tbl-name.
          if     bh_tbl-key ne ?
          then
             delete object bh_tbl-key.
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info2, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.
      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        o-where = substitute( "&1 &2", o-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    delete object bh_tbl-name.
    if     bh_tbl-key ne ?
    then
       delete object bh_tbl-key.
    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info2, vTable ).
    end.
  end.
end procedure.
procedure gen-hn-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character no-undo.
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  define variable v-full-tbl-name as character no-undo.
  define variable v-where         as character no-undo.
  define variable bh_tbl-name     as handle    no-undo.
  define variable vTable          as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile ):
      run gen-where-keyr-tab(i-tableSerach,
                             i-tablekey,
                             p-key-rec,
                             p-key-handle,
                             p-db-name,
                             p-tt-handle,
                             output v-where).
      if i-tableSerach ne "" and i-tableSerach ne ?
      then do:
         v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach ).
         create buffer bh_tbl-name for table v-full-tbl-name .
      end.
      else do:
         if p-tt-handle = ? then do:
            assign
               vTable = entry( 1 , p-key-rec, chr(3) )
            .
            v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable ).
            create buffer bh_tbl-name for table v-full-tbl-name .
         end.
         else do:
            create buffer bh_tbl-name for table p-tt-handle:table-handle .
         end.
      end.
      if p-tt-handle = ? then do:
         bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
      end.
      else do:
         bh_tbl-name:find-first( v-where ) no-error .
      end.
      o-hn = bh_tbl-name.
   end.
end procedure.
procedure gen-hn-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output o-hn).
end.
procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  define variable vHn as handle no-undo.
    run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output vHn).
    p-tbl-row = if vHn:available then vHn:rowid else ?.
    p-tbl-name =  vHn:table.
    delete object vHn no-error.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info2, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure.
procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info2 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info2 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info2, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info2, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info2, v-tbl-name ).
    end.
  end.
end procedure.
procedure gen-key-field :
  define input  parameter p-table      as character no-undo .
  define output parameter p-field-list as character no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-table = ?
      or p-table = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info2 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info2 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info2, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info2, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      v-delim-key  = "":U
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U ).
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
  end.
end procedure.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function usrnickf returns character ( input p-user-id as character):
   define variable v-nick      as character    no-undo.
   if p-user-id = ?
   OR p-user-id = "":U
   then do:
      return '':U .
   end.
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrnick in g#library
  (input  p-user-id
  ,output v-nick
  ) no-error .
   if error-status :error
   then do:
      return p-user-id.
   end.
   else do:
      return v-nick.
   end.
end function.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure db-attr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-value :
  define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
  define output parameter p-value     like ub.db-attr.attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-value in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-write :
  define input parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input parameter p-code      like ub.db-attr.attr-code  no-undo .
  define input parameter p-value     like ub.db-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-write in g#attr-lib
      (input p-db-num
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-exist :
  define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-exist in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-delete :
  define input  parameter p-db-num   like ub.db-attr.db-num     no-undo .
  define input  parameter p-code     like ub.db-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-delete in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
    define variable v-field-handle          as handle       no-undo.
    define variable v-corr-user-db-num      as integer      no-undo.
    define variable v-parent-name           as character    no-undo.
    define variable v-field-list            as character    no-undo.
    define variable v-value-list            as character    no-undo.
    define variable v-field-counter         as integer      no-undo.
    define variable v-counter               as integer      no-undo.
    define variable v-parent-buffer-handle  as handle       no-undo.
    define variable v-parent-unique-key-rec as character    no-undo.
    define variable v-unique-key-rec        as character    no-undo.
    define variable v-corr-date             as date         no-undo.
    define variable v-corr-time             as integer      no-undo.
    define variable v-corr-user-name        as character    no-undo.
    define variable v-db-attr-value         as character    no-undo .
    define variable v-db-attr-type          as character    no-undo .
    define variable v-mess-id               as integer      no-undo .
    define buffer buf_user-login            for ub.user-login .
    define buffer buf_c-user-log            for c-user-log.
    define buffer buf_temp_userlog-bush     for temp_userlog-bush.
    define variable par-type as character no-undo .
    define variable par-is-cctv as character no-undo .
    define variable is-cctv as logical no-undo .
    define variable v-action-type   as character no-undo .
do
for buf_c-user-log
  , buf_temp_userlog-bush
on error undo, return error
:
   find last  buf_c-user-log where buf_c-user-log.corr-user-db-num = g#db-num
   no-lock no-error.
   if     avail buf_c-user-log
      and buf_c-user-log.cusr-id          > current-value( s-user-history )
   then
      current-value( s-user-history ) = buf_c-user-log.cusr-id.
   release buf_c-user-log.
   if p-action = 'report':U then do:
        run cur-time in this-procedure(output v-corr-date, output v-corr-time).
        create buf_c-user-log.
        assign
            buf_c-user-log.corr-user-db-num = g#db-num
            buf_c-user-log.cusr-id          = next-value( s-user-history )
            buf_c-user-log.chip-num         = 0
            buf_c-user-log.corr-date        = v-corr-date
            buf_c-user-log.corr-time        = v-corr-time
            buf_c-user-log.corr-user-name   = g#userid
            buf_c-user-log.des              = "Отчет " + entry(1,p-tbl-name,chr(3))
            buf_c-user-log.have-screen      = yes
            buf_c-user-log.head-table-key   = 'report:':U + chr(3) + entry(2,p-tbl-name,chr(3))
            buf_c-user-log.head-table       = 'report':U
            buf_c-user-log.uniq-key-rec     = 'report:':U + chr(3) + entry(2,p-tbl-name,chr(3))
         no-error.
        return.
    end.
    if p-action = 'utl':U then do:
        run cur-time in this-procedure(output v-corr-date, output v-corr-time).
        create buf_c-user-log.
        assign
            buf_c-user-log.corr-user-db-num = g#db-num
            buf_c-user-log.cusr-id          = next-value( s-user-history )
            buf_c-user-log.chip-num         = 0
            buf_c-user-log.corr-date        = v-corr-date
            buf_c-user-log.corr-time        = v-corr-time
            buf_c-user-log.corr-user-name   = g#userid
            buf_c-user-log.des              = entry(1,p-tbl-name,chr(3))
            buf_c-user-log.have-screen      = yes
            buf_c-user-log.head-table-key   = 'utl:':U + chr(3) + entry(2,p-tbl-name,chr(3))
            buf_c-user-log.head-table       = 'utl':U
            buf_c-user-log.uniq-key-rec     = 'utl:':U + chr(3) + entry(2,p-tbl-name,chr(3))
         no-error.
        return.
    end.
    if p-action = 'atd-alarm-sched':U then do:
        run cur-time in this-procedure(output v-corr-date, output v-corr-time).
        create buf_c-user-log.
        assign
            buf_c-user-log.corr-user-db-num = g#db-num
            buf_c-user-log.cusr-id          = next-value( s-user-history )
            buf_c-user-log.chip-num         = 0
            buf_c-user-log.corr-date        = v-corr-date
            buf_c-user-log.corr-time        = v-corr-time
            buf_c-user-log.corr-user-name   = g#userid
            buf_c-user-log.des              = entry(1,p-tbl-name,chr(3))
            buf_c-user-log.have-screen      = yes
            buf_c-user-log.head-table-key   = entry(2,p-tbl-name,chr(3))
            buf_c-user-log.head-table       = 'atd-alarm-sched':U
            buf_c-user-log.uniq-key-rec     = entry(2,p-tbl-name,chr(3))
         no-error.
        return.
    end.
    if p-action = 'schedule':U then do:
        run cur-time in this-procedure(output v-corr-date, output v-corr-time).
        create buf_c-user-log.
        assign
            buf_c-user-log.corr-user-db-num = g#db-num
            buf_c-user-log.cusr-id          = next-value( s-user-history )
            buf_c-user-log.chip-num         = 0
            buf_c-user-log.corr-date        = v-corr-date
            buf_c-user-log.corr-time        = v-corr-time
            buf_c-user-log.corr-user-name   = g#userid
            buf_c-user-log.des              = entry(1,p-tbl-name,chr(3))
            buf_c-user-log.have-screen      = yes
            buf_c-user-log.head-table-key   = entry(2,p-tbl-name,chr(3))
            buf_c-user-log.head-table       = 'schedule':U
            buf_c-user-log.uniq-key-rec     = entry(2,p-tbl-name,chr(3))
         no-error.
        return.
    end.
    if p-action = 'rvd-reasons':U then do:
        run cur-time in this-procedure(output v-corr-date, output v-corr-time).
        create buf_c-user-log.
        assign
            buf_c-user-log.corr-user-db-num = g#db-num
            buf_c-user-log.cusr-id          = next-value( s-user-history )
            buf_c-user-log.chip-num         = 0
            buf_c-user-log.corr-date        = v-corr-date
            buf_c-user-log.corr-time        = v-corr-time
            buf_c-user-log.corr-user-name   = g#userid
            buf_c-user-log.des              = entry(1,p-tbl-name,chr(3))
            buf_c-user-log.have-screen      = yes
            buf_c-user-log.head-table-key   = entry(2,p-tbl-name,chr(3))
            buf_c-user-log.head-table       = 'rvd-reasons':U
            buf_c-user-log.uniq-key-rec     = entry(2,p-tbl-name,chr(3))
         no-error.
        return.
    end.
    if p-action = 'mi-change':U
    or p-action = 'mi-change-1C':U
    then do:
        run cur-time in this-procedure(output v-corr-date, output v-corr-time).
        create buf_c-user-log.
        assign
            buf_c-user-log.corr-user-db-num = g#db-num
            buf_c-user-log.cusr-id          = next-value( s-user-history )
            buf_c-user-log.chip-num         = 0
            buf_c-user-log.corr-date        = v-corr-date
            buf_c-user-log.corr-time        = v-corr-time
            buf_c-user-log.corr-user-name   = g#userid
            buf_c-user-log.des              = entry(1,p-tbl-name,chr(3))
            buf_c-user-log.have-screen      = yes
            buf_c-user-log.head-table-key   = entry(2,p-tbl-name,chr(3))
            buf_c-user-log.head-table       = p-action
            buf_c-user-log.uniq-key-rec     = entry(2,p-tbl-name,chr(3))
         no-error.
        return.
    end.
    if p-action = 'printdoc':U then do:
        run cur-time in this-procedure(output v-corr-date, output v-corr-time).
        create buf_c-user-log.
        assign
            buf_c-user-log.corr-user-db-num = g#db-num
            buf_c-user-log.cusr-id          = next-value( s-user-history )
            buf_c-user-log.chip-num         = 0
            buf_c-user-log.corr-date        = v-corr-date
            buf_c-user-log.corr-time        = v-corr-time
            buf_c-user-log.corr-user-name   = g#userid
            buf_c-user-log.des              = entry(1,p-tbl-name,chr(3))
            buf_c-user-log.have-screen      = yes
            buf_c-user-log.head-table-key   = 'prtdoc:':U + chr(3) + substring(p-tbl-name,index(p-tbl-name,chr(3)) + 1)
            buf_c-user-log.head-table       = 'prtdoc':U
            buf_c-user-log.uniq-key-rec     = 'prtdoc:':U + chr(3) + substring(p-tbl-name,index(p-tbl-name,chr(3)) + 1)
         no-error.
        return.
    end.
    if   p-action = 'tech-prol-pwd':U then do:
        run cur-time in this-procedure(output v-corr-date, output v-corr-time).
        create buf_c-user-log.
        assign
            buf_c-user-log.corr-user-db-num = g#db-num
            buf_c-user-log.cusr-id          = next-value( s-user-history )
            buf_c-user-log.chip-num         = 0
            buf_c-user-log.corr-date        = v-corr-date
            buf_c-user-log.corr-time        = v-corr-time
            buf_c-user-log.corr-user-name   = g#userid
            buf_c-user-log.des              = entry(1,p-tbl-name,chr(3))
            buf_c-user-log.have-screen      = yes
            buf_c-user-log.head-table-key   = 'tech-prol-pwd:':U + chr(3) + entry(2,p-tbl-name,chr(3))
            buf_c-user-log.head-table       = 'tech-prol-pwd':U
            buf_c-user-log.uniq-key-rec     = 'tech-prol-pwd:':U + chr(3) + entry(2,p-tbl-name,chr(3))
         no-error.
        return.
    end.
    if   p-action = 'run-proc':U then do:
       define variable mproc as character no-undo.
       define variable mparam as character no-undo.
       mparam = ";" + entry(3,p-tbl-name,chr(3)) no-error.
        mproc = entry(2,p-tbl-name,chr(3)).
        if search (mproc)  ne ?
        then
           mproc = search (mproc).
        run cur-time in this-procedure(output v-corr-date, output v-corr-time).
        create buf_c-user-log.
        assign
            buf_c-user-log.corr-user-db-num = g#db-num
            buf_c-user-log.cusr-id          = next-value( s-user-history )
            buf_c-user-log.chip-num         = 0
            buf_c-user-log.corr-date        = v-corr-date
            buf_c-user-log.corr-time        = v-corr-time
            buf_c-user-log.corr-user-name   = g#userid
            buf_c-user-log.des              = entry(1,p-tbl-name,chr(3))
            buf_c-user-log.have-screen      = yes
            buf_c-user-log.head-table-key   = mproc + mparam
            buf_c-user-log.head-table       = 'run-proc':U
            buf_c-user-log.uniq-key-rec     = mproc + mparam
         no-error.
        return.
    end.
    if   p-action = 'sysadm-pwd':U then do:
        run cur-time in this-procedure(output v-corr-date, output v-corr-time).
        create buf_c-user-log.
        assign
            buf_c-user-log.corr-user-db-num = g#db-num
            buf_c-user-log.cusr-id          = next-value( s-user-history )
            buf_c-user-log.chip-num         = 0
            buf_c-user-log.corr-date        = v-corr-date
            buf_c-user-log.corr-time        = v-corr-time
            buf_c-user-log.corr-user-name   = g#userid
            buf_c-user-log.des              = entry(1,p-tbl-name,chr(3))
            buf_c-user-log.have-screen      = yes
            buf_c-user-log.head-table-key   = entry(2,p-tbl-name,chr(3))
            buf_c-user-log.head-table       = 'sysadm-pwd':U
            buf_c-user-log.uniq-key-rec     = entry(2,p-tbl-name,chr(3))
         no-error.
        return.
    end.
    if   p-action = 'one-pwd':U then do:
        run cur-time in this-procedure(output v-corr-date, output v-corr-time).
        create buf_c-user-log.
        assign
            buf_c-user-log.corr-user-db-num = g#db-num
            buf_c-user-log.cusr-id          = next-value( s-user-history )
            buf_c-user-log.chip-num         = 0
            buf_c-user-log.corr-date        = v-corr-date
            buf_c-user-log.corr-time        = v-corr-time
            buf_c-user-log.corr-user-name   = g#userid
            buf_c-user-log.des              = entry(1,p-tbl-name,chr(3))
            buf_c-user-log.have-screen      = yes
            buf_c-user-log.head-table-key   = entry(2,p-tbl-name,chr(3))
            buf_c-user-log.head-table       = 'one-pwd':U
            buf_c-user-log.uniq-key-rec     = entry(2,p-tbl-name,chr(3))
         no-error.
        return.
    end.
    if   p-action = 'MEASURER_PAR':U then do:
        run cur-time in this-procedure(output v-corr-date, output v-corr-time).
        create buf_c-user-log.
        assign
            buf_c-user-log.corr-user-db-num = g#db-num
            buf_c-user-log.cusr-id          = next-value( s-user-history )
            buf_c-user-log.chip-num         = 0
            buf_c-user-log.corr-date        = v-corr-date
            buf_c-user-log.corr-time        = v-corr-time
            buf_c-user-log.corr-user-name   = g#userid
            buf_c-user-log.des              = entry(1,p-tbl-name,chr(3))
            buf_c-user-log.have-screen      = yes
            buf_c-user-log.head-table-key   = entry(2,p-tbl-name,chr(3))
            buf_c-user-log.head-table       = 'MEASURER_PAR':U
            buf_c-user-log.uniq-key-rec     = entry(2,p-tbl-name,chr(3))
         no-error.
        return.
    end.
    define variable m-two-key as character no-undo.
    if num-entries (p-tbl-name,chr(3)) > 1
    then assign
       m-two-key  = entry(2,p-tbl-name,chr(3))
       p-tbl-name = entry(1,p-tbl-name,chr(3))
    .
    case p-action :
        when 'delete':U      then v-action-type = "Удаление" .
        when 'create':U      then v-action-type = "Создание" .
        when 'update':U      then v-action-type = "Изменение" .
        when 'update_err':U  then v-action-type = "Изменение ОШ." .
        when 'delete_err':U  then v-action-type = "Удаление ОШ." .
    end case.
    if not p-table-handle :available
    then do:
        undo, return error substitute( "&1. Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-description, p-tbl-name ).
    end.
    run gen-key-rec in this-procedure (
          input p-tbl-name
        , input p-table-handle
        , output v-unique-key-rec
    ) no-error.
    if error-status :error
    then do:
        return error substitute( "&1. Ошибка при генерации уникального ключа. &2. Имя таблицы &3.", vss-workfile, return-value, p-tbl-name ).
    end.
    if v-unique-key-rec = ?
    or v-unique-key-rec = ""
    then do:
        return error substitute( "&1. Уникальный ключ имеет неопределенное значение. Имя таблицы &2.", vss-workfile, p-tbl-name ).
    end.
    assign
        v-corr-user-db-num = p-table-handle :buffer-field( "corr-user-db-num":U ) :buffer-value
        v-corr-date        = p-table-handle :buffer-field( "corr-date":U ) :buffer-value
        v-corr-time        = p-table-handle :buffer-field( "corr-time":U ) :buffer-value
        v-corr-user-name   = p-table-handle :buffer-field( "corr-user-name":U ) :buffer-value no-error
    .
    if error-status :error then
    do:
        if not p-tbl-name begins "c-"
        then
        do:
            run cur-time in this-procedure(output v-corr-date, output v-corr-time).
            assign
                v-corr-user-db-num = g#db-num
                v-corr-date        = v-corr-date
                v-corr-time        = v-corr-time
                v-corr-user-name   = g#userid .
        end.
        else
        do:
            undo, return error substitute( "Ошибка структуры c-таблицы  &2 ", vss-description, p-tbl-name ).
        end.
    end.
    if v-corr-user-db-num   = ?
    or v-corr-date          = ?
    or v-corr-time          = ?
    or v-corr-user-name     = ?
    then do:
        undo, return .
    end.
    run userlog-hist-table-init (
          input p-tbl-name
    ).
    block-userlog-type-simple:
    for each buf_temp_userlog-bush
       where buf_temp_userlog-bush.ulbType = 1
         and buf_temp_userlog-bush.ulbTableName = p-tbl-name
    on error undo, return error
    :
       if m-two-key ne buf_temp_userlog-bush.ulbTwoKey
       then
          next block-userlog-type-simple.
        if buf_temp_userlog-bush.ulbParentKey = 0
        then do:
            assign
                v-parent-unique-key-rec = v-unique-key-rec
                v-parent-name           = p-tbl-name
            .
        end.
        else do:
            run userlog-get-table-name in this-procedure (
                  input buf_temp_userlog-bush.ulbParentKey
                , output v-parent-name
            ).
            if v-parent-name = p-tbl-name
            then do:
                assign
                    v-parent-unique-key-rec = v-unique-key-rec
                .
            end.
            else do:
               if p-tbl-name = "user-obj" or
                  p-tbl-name = "user-host" or
                  p-tbl-name = "user-login-action-role" or
                  p-tbl-name = "user-login-action-item" or
                  p-tbl-name = "user-menu-group"
                  then do:
                  v-field-list = "user-id" .
               end.
               else do:
                run schemlib-get-index-fields in this-procedure (
                    input v-parent-name
                    , output v-field-list
                ) no-error.
                end.
                if error-status :error
                or v-field-list = "":U
                then do:
                    undo, return error substitute( "&1. Ошибка вычисления первичного ключа родительской таблицы '&2' для таблицы '&3'", vss-description, v-parent-name, p-tbl-name ).
                end.
                assign
                    v-field-counter = num-entries( v-field-list )
                .
                do v-counter = 1 to v-field-counter
                on error undo, return error
                :
                    assign
                        v-field-handle = p-table-handle :buffer-field( entry( v-counter, v-field-list ) )
                    .
                    if not valid-handle( v-field-handle )
                    then do:
                        undo, return error substitute( "&1. В таблице '&2' нет поля, соответствующего полю '&3' в родительской таблице '&4'"
                            , vss-description
                            , v-parent-name
                            , entry( v-counter, v-field-list )
                            , v-parent-name
                        ).
                    end.
                    assign
                        v-value-list = substitute( "&1&2&3":U
                                        , v-value-list
                                        , ( if v-value-list = "":U then "":U else ",":U )
                                        , v-field-handle :buffer-value
                                        )
                    .
                end.
                run schemlib-set-buffer in this-procedure (
                    input v-parent-name
                    , input v-field-list
                    , input v-value-list
                    , output v-parent-buffer-handle
                ) no-error.
                if error-status:error
                then
                   return error return-value.
                run gen-key-rec in this-procedure (
                    input v-parent-name
                    , input v-parent-buffer-handle
                    , output v-parent-unique-key-rec
                ) no-error.
                if error-status :error
                then do:
                    return error substitute( "&1. Ошибка при генерации уникального ключа. &2. Имя таблицы &3.", vss-workfile, return-value, v-parent-name ).
                end.
                if v-parent-unique-key-rec = ?
                or v-parent-unique-key-rec = ""
                then do:
                    return error substitute( "&1. Уникальный ключ имеет неопределенное значение. Имя таблицы &2.", vss-workfile, v-parent-name ).
                end.
            end.
        end.
        create buf_c-user-log.
        assign
            buf_c-user-log.corr-user-db-num = v-corr-user-db-num
            buf_c-user-log.cusr-id          = next-value( s-user-history )
            buf_c-user-log.chip-num         = 0
            buf_c-user-log.des              = substitute( "&1 &2 &3":U
                                                , v-action-type
                                                , buf_temp_userlog-bush.ulbDesc
                                                , buf_temp_userlog-bush.ulbParentDesc
                                            )
            buf_c-user-log.have-screen      = yes
            buf_c-user-log.head-table-key   = v-parent-unique-key-rec
            buf_c-user-log.head-table       = v-parent-name
            buf_c-user-log.uniq-key-rec     = v-unique-key-rec
        .
        assign
        buf_c-user-log.corr-date        = p-table-handle :buffer-field( "corr-date":U ) :buffer-value
        buf_c-user-log.corr-time        = p-table-handle :buffer-field( "corr-time":U ) :buffer-value
        buf_c-user-log.corr-user-name   = p-table-handle :buffer-field( "corr-user-name":U ) :buffer-value no-error.
        if error-status :error then
        do:
            assign
                buf_c-user-log.corr-date      = v-corr-date
                buf_c-user-log.corr-time      = v-corr-time
                buf_c-user-log.corr-user-name = g#userid.
        end.
        if buf_c-user-log.corr-user-name = "" then do:
          assign
            buf_c-user-log.corr-user-name = p-table-handle :buffer-field( "user-id":U ) :buffer-value no-error.
        end.
    end.
    block-userlog-type-bush:
    for each buf_temp_userlog-bush
       where buf_temp_userlog-bush.ulbType      = 0
         and buf_temp_userlog-bush.ulbTableName = p-tbl-name
         and buf_temp_userlog-bush.ulbParentKey <> 0
    on error undo, return error
    :
       if m-two-key ne buf_temp_userlog-bush.ulbTwoKey
       then
          next block-userlog-type-bush.
        run userlog-get-table-name in this-procedure (
              input buf_temp_userlog-bush.ulbParentKey
            , output v-parent-name
        ).
        if v-parent-name = p-tbl-name
        then do:
        end.
        else do:
            run schemlib-get-index-fields in this-procedure (
                  input v-parent-name
                , output v-field-list
            ) no-error.
            if error-status :error
            or v-field-list = "":U
            then do:
                undo, return error substitute( "&1. Ошибка вычисления первичного ключа родительской таблицы '&2' для таблицы '&3'", vss-description, v-parent-name, p-tbl-name ).
            end.
        if not valid-handle( p-table-handle :buffer-field( "subject":U ) )
            then
        do:
            assign
                v-value-list = string(p-tbl-name)
            .
            undo, return error substitute( "&1. Ошибка структуры c-таблицы. В таблице &2 нет поля subject", vss-description, p-tbl-name ).
        end.
        else do:
            assign
                v-value-list = string( p-table-handle :buffer-field("subject":U ) :buffer-value )
            .
        end.
            run schemlib-set-buffer in this-procedure (
                  input v-parent-name
                , input v-field-list
                , input v-value-list
                , output v-parent-buffer-handle
            ).
            run gen-key-rec in this-procedure (
                  input v-parent-name
                , input v-parent-buffer-handle
                , output v-parent-unique-key-rec
            ) no-error.
            if error-status :error
            then do:
                return error substitute( "&1. Ошибка при генерации уникального ключа. &2. Имя таблицы &3.", vss-workfile, return-value, v-parent-name ).
            end.
            create buf_c-user-log.
            assign
                buf_c-user-log.corr-user-db-num = v-corr-user-db-num
                buf_c-user-log.cusr-id          = next-value( s-user-history )
                buf_c-user-log.chip-num         = 0
                buf_c-user-log.corr-date        = p-table-handle :buffer-field( "corr-date":U ) :buffer-value
                buf_c-user-log.corr-time        = p-table-handle :buffer-field( "corr-time":U ) :buffer-value
                buf_c-user-log.corr-user-name   = p-table-handle :buffer-field( "corr-user-name":U ) :buffer-value
                buf_c-user-log.des              = substitute( "&1 &2 &3":U
                                                    , v-action-type
                                                    , buf_temp_userlog-bush.ulbDesc
                                                    , buf_temp_userlog-bush.ulbParentDesc
                                                )
                buf_c-user-log.have-screen      = yes
                buf_c-user-log.head-table-key   = v-parent-unique-key-rec
                buf_c-user-log.head-table       = v-parent-name
                buf_c-user-log.uniq-key-rec     = v-unique-key-rec
            .
        end.
    end.
    if valid-handle( v-parent-buffer-handle )
    then do:
        delete object v-parent-buffer-handle.
    end.
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-cctv'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output par-is-cctv
  ,output par-type
  ) no-error .
is-cctv = lookup(par-is-cctv, "true,yes":U) > 0 .
return-value = "".
if p-video-action <> 0 and p-video-action <> ? and is-cctv
    then
do :
    define variable v-vid-ok  as logical   no-undo .
    define variable v-vid-mes as character no-undo .
    if not p-video-param begins "Login=" then
    do :
        find first buf_user-login no-lock
            where buf_user-login.db-num  = g#db-num
            and buf_user-login.user-id = g#userid
            no-error .
        if available buf_user-login
            then
        do:
            assign
                p-video-param = p-video-param + chr(4) +
                            "Login=" + buf_user-login.user-login + chr(4) +
                            "THname=" + usrnickf(buf_user-login.user-id)
                .
        end.
    end.
    run db-attr-value in this-procedure ( input g#db-num
                                          , input 'mess-id-video':U
                                          , output v-db-attr-value
                                          , output v-db-attr-type
                                          ) no-error .
    assign
      v-mess-id = integer (v-db-attr-value) no-error.
    if v-mess-id = ?
      then v-mess-id = 0.
    p-video-param = p-video-param + chr(4) +
      "MESSAGE_ID=" + string (v-mess-id)
    .
    v-mess-id = v-mess-id + 1.
    run db-attr-write in this-procedure ( input g#db-num
                                        , input 'mess-id-video':U
                                        , input string (v-mess-id)
                                        ) no-error .
    run trg/video-action.p (input p-video-action,
        input p-video-param,
        output v-vid-ok,
        output v-vid-mes) .
end.
