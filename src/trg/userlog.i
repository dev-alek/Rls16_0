/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека истории пользователя.

Автор: Белоусов Илья Александрович
Дата создания: 03/25/08
Author: Ilia Belousov
Creation date: 03/25/08

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
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

define variable v-userlog-{&vssseq}-ulb-key as integer no-undo.

&global-define userlog-type-bush 0
&global-define userlog-type-simple 1


/*==========================================================================*/
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
end procedure. /* userlog-hist-table-init */

/*==========================================================================*/
procedure userlog-hist-table-init-all :

  define variable v-success as logical   no-undo.
  define variable v-err-msg as character no-undo.
  do
    on error undo, return error
    :
    assign
      v-err-msg = "":U
      .
    /* Таблицы истории, связанные в кусты ================================================================================================================================================*/
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-gds-hist               ":U, input "c-gds-obj-attr              ":U, input "                                                ", input "атрибута товара на объекте                                        ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-gds-hist               ":U, input "c-gds-host-attr             ":U, input "                                                ", input "атрибута товара на фирме                                          ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-gds-hist               ":U, input "c-goods-attr                ":U, input "                                                ", input "атрибута товара                                                   ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-gds-hist               ":U, input "c-goods                     ":U, input "                                                ", input "товара                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-gds-hist               ":U, input "c-fbr-gds-obj               ":U, input "                                                ", input "товара для производства на объекте                                ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-gds-hist               ":U, input "c-s-coeff                   ":U, input "                                                ", input "сезонного коэффициента                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-gds-hist               ":U, input "c-prod-bc                   ":U, input "                                                ", input "дополнительного бар-кода производител                             ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-gds-hist               ":U, input "c-bar-code                  ":U, input "                                                ", input "бар-кода                                                          ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-gds-hist               ":U, input "c-varianty-delivery-gds-obj ":U, input "                                                ", input "варианта доставки товара на объект                                ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-gds-hist               ":U, input "c-gds-season                ":U, input "                                                ", input "сезонных характеристик товара                                     ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-gds-hist               ":U, input "tax-rate-gds                ":U, input "                                                ", input "ставки налога для товара                                          ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-gds-hist               ":U, input "c-assortment-matrix-goods   ":U, input "                                                ", input "товара ассортиментной матрицы                                     ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-gds-hist               ":U, input "c-gds-obj-prop              ":U, input "                                                ", input "свойства товара на объекте                                        ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-gds-hist               ":U, input "c-pl-gds                    ":U, input "                                                ", input "хранения товара на складском месте                                ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-gds-hist               ":U, input "c-pl-gds-attr               ":U, input "                                                ", input "атрибута хранения товара на складском месте                       ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-gds-hist               ":U, input "c-pl-gds-pump               ":U, input "                                                ", input "поиска контейнера через товар и ТРК (бензин)                      ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-gds-hist               ":U, input "c-dis-gds-rule              ":U, input "                                                ", input "правила скидок на товар                                           ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-gds-hist               ":U, input "c-ext-artic                 ":U, input "                                                ", input "внешнего артикула                                                 ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-gds-hist               ":U, input "c-sert                      ":U, input "                                                ", input "сертификата                                                       ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-gds-hist               ":U, input "c-recipe                    ":U, input "                                                ", input "рецепта производства                                              ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-gds-hist               ":U, input "c-recipe-gds                ":U, input "                                                ", input "товара рецепта производства                                       ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-cli-hist               ":U, input "c-clients                   ":U, input "                                                ", input "клиента                                                           ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-cli-hist               ":U, input "c-clients-attr              ":U, input "                                                ", input "атрибута клиента                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-cli-hist               ":U, input "c-sysconf                   ":U, input "                                                ", input "системных настроек                                                ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-cli-hist               ":U, input "c-person                    ":U, input "                                                ", input "справочника физических лиц                                        ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-cli-hist               ":U, input "c-firm                      ":U, input "                                                ", input "организации                                                       ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-cli-hist               ":U, input "c-shop                      ":U, input "                                                ", input "магазина                                                          ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-cli-hist               ":U, input "c-store                     ":U, input "                                                ", input "склада                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-cli-hist               ":U, input "c-staff                     ":U, input "                                                ", input "персонала                                                         ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-cli-hist               ":U, input "c-dis-thbj-rule             ":U, input "                                                ", input "нетоварной скидки по объекту                                      ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-cli-hist               ":U, input "c-thbj-attr                 ":U, input "                                                ", input "параметра объекта TH                                              ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-dc-hist                ":U, input "c-dis-card                  ":U, input "                                                ", input "дисконтной карты                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-dc-hist                ":U, input "c-dis-obj                   ":U, input "                                                ", input "итогов для дисконтной карты на объекте                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-dc-hist                ":U, input "c-dis-host                  ":U, input "                                                ", input "итогов для дисконтной карты на фирме                              ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-dc-hist                ":U, input "c-dis-card-property         ":U, input "                                                ", input "свойств дисконтной карты                                          ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-dc-hist                ":U, input "c-dis-dc-rule               ":U, input "                                                ", input "скидок по отдельной дисконтной карте                              ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-tax-hist               ":U, input "c-tax-hist                  ":U, input "                                                ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-tax-hist               ":U, input "c-tax                       ":U, input "                                                ", input "налога                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-tax-hist               ":U, input "c-tax-rate                  ":U, input "                                                ", input "ставки налога                                                     ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-tax-hist               ":U, input "tax-rate-value              ":U, input "                                                ", input "значения ставки налога                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-tax-hist               ":U, input "c-tax-units                 ":U, input "                                                ", input "налога для типов товара в соответствии с ед.изм                   ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-gds-grp-hist           ":U, input "c-gds-grp                   ":U, input "                                                ", input "групп товаров                                                     ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-gds-grp-hist           ":U, input "c-gds-grp-attr              ":U, input "                                                ", input "атрибутов групп товаров                                           ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-gds-grp-hist           ":U, input "c-gds-grp-obj               ":U, input "                                                ", input "параметров групп товаров на объектах и фирмах                     ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-gds-grp-hist           ":U, input "c-tax-rate-gds-grp          ":U, input "                                                ", input "налоги группы товаров на объектах и фирмах                        ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-gds-grp-hist           ":U, input "c-dis-grp-rule              ":U, input "                                                ", input "правил скидок по группе товаров                                   ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-wth-hist               ":U, input "c-wealth                    ":U, input "                                                ", input "справочника матценности                                           ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-wth-hist               ":U, input "c-wth-par                   ":U, input "                                                ", input "номиналов матценностей                                            ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-fbr-gds-grp-hist       ":U, input "c-fbr-gds-grp               ":U, input "                                                ", input "группы товара производства                                        ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-fbr-gds-grp-hist       ":U, input "c-fbr-gds-grp-attr          ":U, input "                                                ", input "атрибута группы товара производства                               ":U, input v-err-msg, output v-err-msg ).

/*    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-plc-hist               ":U, input "c-place                     ":U, input "                                                ", input "складского места                                                  ":U, input v-err-msg, output v-err-msg ).*/
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-plc-hist               ":U, input "c-pl-level                  ":U, input "                                                ", input "градуировочной таблицы по резервуару                              ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-plc-hist               ":U, input "c-place-attr                ":U, input "                                                ", input "атрибута складского места                                         ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-plc-hist               ":U, input "c-pl-gds                    ":U, input "                                                ", input "хранения товара на складском месте                                ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-plc-hist               ":U, input "c-pl-gds-pump               ":U, input "                                                ", input "поиска контейнера через товар и ТРК (бензин)                      ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-plc-hist               ":U, input "c-pl-pump                   ":U, input "                                                ", input "соответствия ТРК контейнеру (складскому месту)                    ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-plc-hist               ":U, input "c-pl-pump-nozzle            ":U, input "                                                ", input "соответствия пистолета и ТРК                                      ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-plc-hist               ":U, input "c-pl-gds-attr               ":U, input "                                                ", input "атрибута хранения товара на складском месте                       ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-pmp-hist               ":U, input "c-pump                      ":U, input "                                                ", input "ТРК                                                               ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-pmp-hist               ":U, input "c-pump-attr                 ":U, input "                                                ", input "атрибутов ТРК                                                     ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-pmp-hist               ":U, input "c-pump-nozzle               ":U, input "                                                ", input "пистолетов ТРК на объекте                                         ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-pmp-hist               ":U, input "c-pl-gds-pump               ":U, input "                                                ", input "поиска контейнера через товар и ТРК (бензин)                      ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-pmp-hist               ":U, input "c-pl-pump                   ":U, input "                                                ", input "соответствия ТРК контейнеру (складскому месту)                    ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-pmp-hist               ":U, input "c-pl-pump-nozzle            ":U, input "                                                ", input "соответствия пистолета и ТРК                                      ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-nzl-hist               ":U, input "c-nozzle                    ":U, input "                                                ", input "пистолета ТРК                                                     ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-nzl-hist               ":U, input "c-nozzle-attr               ":U, input "                                                ", input "атрибута пистолета ТРК                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-nzl-hist               ":U, input "c-pump-nozzle               ":U, input "                                                ", input "пистолетов ТРК на объекте                                         ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-nzl-hist               ":U, input "c-pl-pump-nozzle            ":U, input "                                                ", input "соответствия пистолета и ТРК                                      ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-sht-hist               ":U, input "c-shift-obj                 ":U, input "                                                ", input "смены                                                             ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-sht-hist               ":U, input "c-shift-staff               ":U, input "                                                ", input "персонала смены на объекте                                        ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-recipe-hist            ":U, input "c-recipe                    ":U, input "                                                ", input "рецепта производства                                              ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-recipe-hist            ":U, input "c-recipe-gds                ":U, input "                                                ", input "товара рецепта производства                                       ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-recipe-hist            ":U, input "c-recipe-develop            ":U, input "                                                ", input "актов проработки                                                  ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-auto-tank              ":U, input "c-auto-tank                 ":U, input "                                                ", input "цистерны                                                          ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-cash-desk              ":U, input "c-cash-desk                 ":U, input "                                                ", input "справочника касс                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-cash-desk              ":U, input "c-cash-desk-attr            ":U, input "                                                ", input "атрибута справочника касс                                         ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-cash-pay               ":U, input "c-cash-pay                  ":U, input "                                                ", input "типа платежа                                                      ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-cash-pay               ":U, input "c-dis-cp-rule               ":U, input "                                                ", input "cкидки на платёж                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-cash-pay               ":U, input "c-cash-pay-attr             ":U, input "                                                ", input "атрибута типа платежа                                             ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-dis-card-type          ":U, input "c-dis-card-type             ":U, input "                                                ", input "типа дисконтной карты                                             ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-dis-card-type          ":U, input "c-dis-card-type-attr        ":U, input "                                                ", input "атрибута типа дисконтной карты                                    ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-dis-card-type          ":U, input "c-dis-card-mask             ":U, input "                                                ", input "маски дисконтной карты                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-dis-card-type          ":U, input "c-rp-by-call                ":U, input "                                                ", input "привязки профайла к месту                                         ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-dis-card-type          ":U, input "c-rule-by-call              ":U, input "                                                ", input "алгоритма обработки                                               ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-dis-card-type          ":U, input "c-rule-call-param           ":U, input "                                                ", input "параметра вызова правил                                           ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-dis-card-type          ":U, input "c-dis-dct-rule              ":U, input "                                                ", input "скидки по типу дисконтных карт                                    ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-dis-card-type          ":U, input "c-hist-nws-option           ":U, input "                                                ", input "опций создания истории и маршрутизации                            ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-fbr-prn                ":U, input "c-fbr-prn                   ":U, input "                                                ", input "принтера производства                                             ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-fbr-prn                ":U, input "c-fbr-prn-gds               ":U, input "                                                ", input "товаров принтера производства                                     ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-fbr-prn                ":U, input "c-fbr-prn-grp               ":U, input "                                                ", input "группы товаров принтера производства                              ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-prop-head              ":U, input "c-prop-head                 ":U, input "                                                ", input "декларации свойств                                                ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-prop-head              ":U, input "c-pscript-ruleset           ":U, input "                                                ", input "связи свойства объекта<->набор правил                             ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-prop-head              ":U, input "c-prop-script               ":U, input "                                                ", input "скриптов для объектов                                             ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-prop-head              ":U, input "c-prop-ruleset              ":U, input "                                                ", input "объектов - наборов правил                                         ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-prop-head              ":U, input "c-prop-ref                  ":U, input "                                                ", input "типов срезов хранилища                                            ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-rule                   ":U, input "c-rule                      ":U, input "                                                ", input "правила                                                           ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-rule                   ":U, input "c-rule-by-set               ":U, input "                                                ", input "привязки правила к наборам                                        ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-rule-profile           ":U, input "c-rule-profile              ":U, input "                                                ", input "профайла                                                          ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-rule-profile           ":U, input "c-rule-by-profile           ":U, input "                                                ", input "привязки правила к профайлу                                       ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-ruledict               ":U, input "c-ruledict                  ":U, input "                                                ", input "словаря правил                                                    ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-ruledict               ":U, input "c-ruledict-param            ":U, input "                                                ", input "параметров статей словаря правил                                  ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-scales                 ":U, input "c-scales                    ":U, input "                                                ", input "весов                                                             ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-scales                 ":U, input "c-scales-attr               ":U, input "                                                ", input "атрибутов весов                                                   ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-scales                 ":U, input "c-scales-gds                ":U, input "                                                ", input "товара на весах                                                   ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-scales                 ":U, input "c-scales-grp                ":U, input "                                                ", input "связи группы товара и весов                                       ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-bush}, input "c-sert                   ":U, input "c-sert                      ":U, input "                                                ", input "сертификата                                                       ":U, input v-err-msg, output v-err-msg ).




    /* Несвязанные таблицы истории  ==========================================================================================================================================================*/                                                                                                                                        .

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-add-doc              ":U, input "c-add-doc                   ":U, input "документа дополнительных расходов               ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-add-doc              ":U, input "c-add-line                  ":U, input "документа дополнительных расходов               ", input "строки                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-add-doc              ":U, input "c-parts-add                 ":U, input "документа дополнительных расходов               ", input "суммы доп.расхода в учетной цене партии                           ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-add-doc              ":U, input "c-gds-add-charges           ":U, input "документа дополнительных расходов               ", input "по товарам                                                        ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-add-doc              ":U, input "c-gds-add-charges-attr      ":U, input "документа дополнительных расходов               ", input "атрибутов по товарам                                              ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-alc-sale-lic         ":U, input "c-alc-sale-lic              ":U, input "лицензии на продажу алкоголя                    ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-alc-sale-lic         ":U, input "c-alc-sale-lic-attr         ":U, input "лицензии на продажу алкоголя                    ", input "атрибута                                                          ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-alc-sale-lic         ":U, input "c-alc-sale-lic-type         ":U, input "лицензии на продажу алкоголя                    ", input "типа                                                              ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-alc-supp-lic         ":U, input "c-alc-supp-lic              ":U, input "лицензии на поставку алкоголя                   ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-alc-supp-lic         ":U, input "c-alc-supp-lic-attr         ":U, input "лицензии на поставку алкоголя                   ", input "атрибута                                                          ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-alc-supp-lic         ":U, input "c-alc-supp-lic-type         ":U, input "лицензии на поставку алкоголя                   ", input "типа                                                              ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-alc-type             ":U, input "c-alc-type                  ":U, input "вида алкогольной продукции                      ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-alc-type             ":U, input "c-alc-type-attr             ":U, input "вида алкогольной продукции                      ", input "атрибута                                                          ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-alc-type             ":U, input "c-alc-type-gds              ":U, input "вида алкогольной продукции                      ", input "товара                                                            ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-action-role          ":U, input "c-action-role               ":U, input "группы прав                                     ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "action-role            ":U, input "action-role                 ":U, input "группы прав                                     ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-action-role-item     ":U, input "c-action-role-item          ":U, input "пунктов группы прав                             ", input "                                                                   ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "action-role-item       ":U, input "action-role-item            ":U, input "пунктов группы прав                             ", input "                                                                   ":U, input v-err-msg, output v-err-msg ).
    
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-assortment-matrix    ":U, input "c-assortment-matrix         ":U, input "ассортиментной матрицы                          ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-cbr-bank             ":U, input "c-cbr-bank                  ":U, input "банка из списков ЦБ РФ                          ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-cd-clu               ":U, input "c-cd-clu                    ":U, input "кода клиента на кассе                           ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-cd-dlu               ":U, input "c-cd-dlu                    ":U, input "дисконтной карты на кассе                       ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-cd-doc               ":U, input "c-cd-doc                    ":U, input "документа на кассе                              ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-cd-doc               ":U, input "c-cd-doc-line               ":U, input "документа на кассе                              ", input "строки                                                            ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-cd-grp               ":U, input "c-cd-grp                    ":U, input "группы на кассе                                 ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-cd-plu               ":U, input "c-cd-plu                    ":U, input "кода товара на кассе                            ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "chk-doc                ":U, input "chk-doc                     ":U, input "кассового чека                                  ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-chk-doc              ":U, input "c-chk-doc                   ":U, input "кассового чека                                  ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-chk-doc              ":U, input "c-chk-discnt                ":U, input "кассового чека                                  ", input "скидки                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-chk-doc              ":U, input "c-chk-pay                   ":U, input "кассового чека                                  ", input "оплаты                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-chk-doc              ":U, input "c-chk-gds                   ":U, input "кассового чека                                  ", input "товара                                                            ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-chk-doc-attr         ":U, input "c-chk-doc-attr              ":U, input "кассового чека или кассового чека МЦ            ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-chk-title            ":U, input "c-chk-title                 ":U, input "кассового чека матценностей                     ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-chk-title            ":U, input "c-chk-inst                  ":U, input "кассового чека матценностей                     ", input "строки                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-chk-title            ":U, input "c-chk-par                   ":U, input "кассового чека матценностей                     ", input "купюрности матценности                                            ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-cli-grp              ":U, input "c-cli-grp                   ":U, input "                                                ", input "группы клиентов                                                   ":U, input v-err-msg, output v-err-msg ).
    
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "clients                ":U, input "clients                     ":U, input "                                                ", input "справочника клиентов                                              ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "cli-grp                ":U, input "cli-grp                     ":U, input "                                                ", input "группы клиентов                                                   ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "auto-tank              ":U, input "auto-tank                   ":U, input "                                                ", input "автотранспорта                                                    ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-condition-keeping    ":U, input "c-condition-keeping         ":U, input "                                                ", input "условий хранени                                                   ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-config               ":U, input "c-config                    ":U, input "                                                ", input "конфигурации или настроек системы                                 ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "config                 ":U, input "config                      ":U, input "                                                ", input "конфигурации или настроек системы                                 ":U, input v-err-msg, output v-err-msg ).
    
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "clob-bind              ":U, input "clob-bind                   ":U, input "                                                ", input "средства измерения                                                ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-contract             ":U, input "c-contract                  ":U, input "договора с контрагентами                        ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-contract             ":U, input "c-contract-line             ":U, input "договора с контрагентами                        ", input "строки                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-contract             ":U, input "c-contract-specif           ":U, input "договора с контрагентами                        ", input "спецификации товара                                               ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-country              ":U, input "c-country                   ":U, input "                                                ", input "страны                                                            ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-curr-accnt           ":U, input "c-curr-accnt                ":U, input "                                                ", input "биржевых курсов валют                                             ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-curr-bank            ":U, input "c-curr-bank                 ":U, input "                                                ", input "курсов валют системы                                              ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-currency             ":U, input "c-currency                  ":U, input "                                                ", input "валюты                                                            ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-global-state         ":U, input "c-global-state              ":U, input "глобальных настроек ценообразования             ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-global-state         ":U, input "c-global-state-attr         ":U, input "глобальных настроек ценообразования             ", input "атрибутов                                                         ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-grp-obj-price        ":U, input "c-grp-obj-price             ":U, input "группы объектов для ценообразования             ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-grp-obj-price        ":U, input "c-db-grp-obj-price          ":U, input "группы объектов для ценообразования             ", input "БД                                                                ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-grp-obj-price        ":U, input "c-host-grp-obj-price        ":U, input "группы объектов для ценообразования             ", input "фирмы                                                             ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-grp-obj-price        ":U, input "c-obj-grp-obj-price         ":U, input "группы объектов для ценообразования             ", input "объекта                                                           ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-qnty-group           ":U, input "c-qnty-group                ":U, input "количественной группы                           ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-qnty-group           ":U, input "c-qnty-in-qnty-group        ":U, input "количественной группы                           ", input "количества                                                        ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-sum-group            ":U, input "c-sum-group                 ":U, input "суммовой группы                                 ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-sum-group            ":U, input "c-sum-in-sum-group          ":U, input "суммовой группы                                 ", input "суммы                                                             ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-buyer-group          ":U, input "c-buyer-group               ":U, input "группы покупателей                              ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-buyer-group          ":U, input "c-buyer-in-buyer-group      ":U, input "группы покупателей                              ", input "покупателя                                                        ":U, input v-err-msg, output v-err-msg ).


    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-turnover-group       ":U, input "c-turnover-group            ":U, input "группы оборотов                                 ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-tnv-in-turnover-group":U, input "c-tnv-in-turnover-group     ":U, input "разбивки оборотов по покупателям                ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "dis-card                ":U, input "dis-card                   ":U, input "дисконтных карт                                 ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "dis-card-type           ":U, input "dis-card-type              ":U, input "типов дисконтных карт                           ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-dis-rule             ":U, input "c-dis-rule                  ":U, input "правила скидок                                  ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-dis-time-rule        ":U, input "c-dis-time-rule             ":U, input "расписани                                       ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-trn-doc              ":U, input "c-trn-doc                   ":U, input "складского документа                            ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-trn-doc              ":U, input "c-trn-doc-sum               ":U, input "складского документа                            ", input "сумм по документу                                                 ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-trn-doc              ":U, input "c-doc-attr                  ":U, input "складского документа                            ", input "атрибута                                                          ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-trn-doc              ":U, input "c-doc-fbr-gds               ":U, input "складского документа                            ", input "товаров для автопроизводства                                      ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-trn-doc              ":U, input "c-doc-line                  ":U, input "складского документа                            ", input "строки                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-trn-doc              ":U, input "c-doc-line-attr             ":U, input "складского документа                            ", input "атрибута строки                                                   ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-trn-doc              ":U, input "c-doc-line-sum              ":U, input "складского документа                            ", input "сумм по строке документа                                          ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-trn-doc              ":U, input "c-doc-pl                    ":U, input "складского документа                            ", input "количества по строке из данного складского места                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-trn-doc              ":U, input "c-doc-pl-pump               ":U, input "складского документа                            ", input "количества по строке из данного складского места и конкретной трк ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-trn-doc              ":U, input "c-doc-prts                  ":U, input "складского документа                            ", input "требования на резервирование партии в накладной                   ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-trn-doc              ":U, input "c-gds-dtl                   ":U, input "складского документа                            ", input "признака строки                                                   ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-trn-doc              ":U, input "c-inv-line                  ":U, input "складского документа                            ", input "доп. информации по строкам инвентаризации                         ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-trn-doc              ":U, input "c-parts                     ":U, input "складского документа                            ", input "партии                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-trn-doc              ":U, input "c-parts-attr                ":U, input "складского документа                            ", input "атрибута партии                                                   ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-trn-doc              ":U, input "c-parts-root                ":U, input "складского документа                            ", input "порождающих партий                                                ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-trn-doc              ":U, input "c-clc-sum                   ":U, input "складского документа                            ", input "сумм в расчетах по накладной                                      ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "trn-doc                ":U, input "trn-doc                     ":U, input "складского документа                            ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-sr-izmerenia         ":U, input "c-sr-izmerenia               ":U, input "средства измерения                              ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "goods                   ":U, input "goods                       ":U, input "товара                                         ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "gds-grp                 ":U, input "gds-grp                     ":U, input "группы товара                                  ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-ext-system           ":U, input "c-ext-system                ":U, input "внешней системы OpenXML                         ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-ext-system           ":U, input "c-esys-datatype-exp         ":U, input "внешней системы OpenXML                         ", input "типа данных экспорта                                              ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-ext-system           ":U, input "c-esys-datatype-imp         ":U, input "внешней системы OpenXML                         ", input "типа данных импорта                                               ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-ex-mark              ":U, input "c-ex-mark                   ":U, input "акцизных и специальных марок                    ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-ext-classif          ":U, input "c-ext-classif               ":U, input "внешнего классификатора                         ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "fbr-doc                ":U, input "fbr-doc                     ":U, input "документа производства                          ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-fbr-doc              ":U, input "c-fbr-doc                   ":U, input "документа производства                          ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-fbr-doc              ":U, input "c-fbr-line                  ":U, input "документа производства                          ", input "строки                                                            ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-sht-hist             ":U, input "c-sht-hist                  ":U, input "смены                                           ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-sht-hist             ":U, input "c-sht-hist-line             ":U, input "смены                                           ", input "строки                                                            ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "shift-obj              ":U, input "shift-obj                   ":U, input "смены                                           ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "shift-obj              ":U, input "shift-staff                 ":U, input "смены                                           ", input "персонала                                                         ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add        in this-procedure ( input {&userlog-type-simple}, input "c-usr-hist             ":U, input "c-usr-hist                  ":U,                                         input "времени входа                                   ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-twokey-add in this-procedure ( input {&userlog-type-simple}, input "c-usr-hist             ":U, input "c-user-login                ":U, input "user-password               ":U, input "пароля                                          ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-twokey-add in this-procedure ( input {&userlog-type-simple}, input "c-usr-hist             ":U, input "c-user-login                ":U, input "adm                         ":U, input "прав администратора                             ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add        in this-procedure ( input {&userlog-type-simple}, input "c-usr-hist             ":U, input "c-user-account              ":U,                                         input "пользователя системы                            ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add        in this-procedure ( input {&userlog-type-simple}, input "c-usr-hist             ":U, input "c-user-login                ":U,                                         input "логина пользователя системы                     ", input "строки                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-twokey-add in this-procedure ( input {&userlog-type-simple}, input "c-usr-hist             ":U, input "user-account                ":U, input "SuperAdm                    ":U, input "права супер администратора                      ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add        in this-procedure ( input {&userlog-type-simple}, input "c-usr-hist             ":U, input "user-account                ":U,                                         input "пользователя системы                            ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add        in this-procedure ( input {&userlog-type-simple}, input "c-usr-hist             ":U, input "user-obj                    ":U,                                         input "объекта пользователя                            ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add        in this-procedure ( input {&userlog-type-simple}, input "c-usr-hist             ":U, input "user-host                   ":U,                                         input "фирмы пользователя                              ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add        in this-procedure ( input {&userlog-type-simple}, input "c-usr-hist             ":U, input "user-login-action-item      ":U,                                         input "права пользователя системы                            ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add        in this-procedure ( input {&userlog-type-simple}, input "c-usr-hist             ":U, input "user-login-action-role      ":U,                                         input "группа прав пользователя системы                            ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add        in this-procedure ( input {&userlog-type-simple}, input "c-usr-hist             ":U, input "user-menu-group             ":U,                                         input "меню пользователя системы                            ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-fbr-pln              ":U, input "c-fbr-pln                   ":U, input "документа план-меню                             ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-fbr-pln              ":U, input "c-fbr-pln-line              ":U, input "документа план-меню                             ", input "строки                                                            ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-fin-bank             ":U, input "c-fin-bank                  ":U, input "реквизитов банка                                ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "fin-bank               ":U, input "fin-bank                    ":U, input "реквизитов банка                                ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-fin-code-an-uchet    ":U, input "c-fin-code-an-uchet         ":U, input "кодов аналитического учёта                      ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-fin-code-cel-nazn    ":U, input "c-fin-code-cel-nazn         ":U, input "кодов целевого назначения                       ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-fin-code-cor-acc     ":U, input "c-fin-code-cor-acc          ":U, input "корреспондирующих счетов                        ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-fin-doc              ":U, input "c-fin-doc                   ":U, input "финансового документа                           ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-fin-doc              ":U, input "c-fin-connect               ":U, input "финансового документа                           ", input "связи с финансовыми обязательствами                               ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-fin-doc              ":U, input "c-fin-doc-attr              ":U, input "финансового документа                           ", input "атрибутов                                                         ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-fin-doc              ":U, input "c-fin-doc-tax               ":U, input "финансового документа                           ", input "налогов                                                           ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-fin-ob               ":U, input "c-fin-ob                    ":U, input "финансового обязательства                       ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-fin-ob               ":U, input "c-fin-ob-attr               ":U, input "финансового обязательства                       ", input "атрибутов                                                         ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-fin-ob               ":U, input "c-fin-ob-tax                ":U, input "финансового обязательства                       ", input "налогов                                                           ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-fin-ob               ":U, input "c-fin-gds-part              ":U, input "финансового обязательства                       ", input "партий                                                            ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-fin-schet            ":U, input "c-fin-schet                 ":U, input "финансовых реквизитов                           ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-fin-statement        ":U, input "c-fin-statement             ":U, input "банковских выписок                              ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-fin-statement        ":U, input "c-fin-statement-attr        ":U, input "банковских выписок                              ", input "атрибутов                                                         ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-fin-statement        ":U, input "c-fin-statement-line        ":U, input "банковских выписок                              ", input "строк                                                             ":U, input v-err-msg, output v-err-msg ).
    
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-gds-prt              ":U, input "c-gds-prt                   ":U, input "признаков товаров                               ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-group-period-validity":U, input "c-group-period-validity     ":U, input "группы сроков хранения                          ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-inkas                ":U, input "c-inkas                     ":U, input "кассового отчёта                                ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-inkas                ":U, input "c-inkas-pay                 ":U, input "кассового отчёта                                ", input "по видам оплаты                                                   ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-inkas                ":U, input "c-inkas-pay-desk            ":U, input "кассового отчёта                                ", input "выручки по кассам                                                 ":U, input v-err-msg, output v-err-msg ).
    
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "ord-doc                ":U, input "ord-doc                     ":U, input "заказа поставщикам и покупателям                ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-ord-doc              ":U, input "c-ord-doc                   ":U, input "заказа поставщикам и покупателям                ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-ord-doc              ":U, input "c-ord-doc-attr              ":U, input "заказа поставщикам и покупателям                ", input "атрибутов                                                         ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-ord-doc              ":U, input "c-ord-dtl                   ":U, input "заказа поставщикам и покупателям                ", input "признаков по товарам                                              ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-ord-doc              ":U, input "c-ord-line                  ":U, input "заказа поставщикам и покупателям                ", input "строки                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-ord-doc              ":U, input "c-ord-line-attr             ":U, input "заказа поставщикам и покупателям                ", input "атрибутов строки                                                  ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-pay-type             ":U, input "c-pay-type                  ":U, input "вида оплаты                                     ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "pay-type               ":U, input "pay-type                    ":U, input "вида оплаты                                     ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-place-io             ":U, input "c-place-io                  ":U, input "места отгрузки/приёмки                          ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "place                  ":U, input "place                       ":U, input "складского места                                ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-place                ":U, input "c-place                     ":U, input "складского места                                ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "pl-level               ":U, input "pl-level                    ":U, input "градуировочной таблицы                          ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "pl-pump-nozzle         ":U, input "pl-pump-nozzle              ":U, input "соответствия пистолета и ТРК                    ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "pl-gds                 ":U, input "pl-gds                      ":U, input "товара на складском месте                       ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "pl-pump                ":U, input "pl-pump                     ":U, input "соответствия ТРК контейнеру (складскому месту)  ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "pl-gds-pump            ":U, input "pl-gds-pump                 ":U, input "поиска контейнера через товар и ТРК (бензин)    ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-plc-hist             ":U, input "c-plc-hist                  ":U, input "хранения товара на складском месте              ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-point-io             ":U, input "c-point-io                  ":U, input "пункта отгрузки/доставки                        ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-price-doc            ":U, input "c-price-doc                 ":U, input "документа переоценки                            ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-price-doc            ":U, input "c-price-list                ":U, input "документа переоценки                            ", input "строки                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-price-doc            ":U, input "c-price-list-attr           ":U, input "документа переоценки                            ", input "атрибута строки                                                   ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "price-doc              ":U, input "price-doc                   ":U, input "документа переоценки                            ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-price-list-type      ":U, input "c-price-list-type           ":U, input "типа прайс-листа                                ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-price-list-type      ":U, input "c-price-list-type-attr      ":U, input "типа прайс-листа                                ", input "атрибута                                                          ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-price-list-type      ":U, input "c-price-list-type-cash-pay  ":U, input "типа прайс-листа                                ", input "ограничения по типам кассовых платежей                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-price-list-type      ":U, input "c-price-list-type-cassa     ":U, input "типа прайс-листа                                ", input "связи с кассами                                                   ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-price-list-type      ":U, input "c-price-list-type-gds-grp   ":U, input "типа прайс-листа                                ", input "ограничения по группам товаров                                    ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-price-list-type      ":U, input "c-price-list-type-pay-type  ":U, input "типа прайс-листа                                ", input "ограничения по типам платежа                                      ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "price-doc-forming      ":U, input "price-doc-forming           ":U, input "документа формирования цены                     ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).          
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-price-doc-forming    ":U, input "c-price-doc-forming         ":U, input "документа формирования цены                     ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-price-doc-forming    ":U, input "c-price-doc-forming-attr    ":U, input "документа формирования цены                     ", input "атрибута                                                          ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-price-doc-forming    ":U, input "c-price-doc-forming-gds     ":U, input "документа формирования цены                     ", input "товара                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-price-doc-forming    ":U, input "c-price-doc-forming-gds-qnty":U, input "документа формирования цены                     ", input "товара по количеству                                              ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-price-doc-forming    ":U, input "c-price-doc-forming-gds-sum ":U, input "документа формирования цены                     ", input "товара по сумме                                                   ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-price-doc-forming    ":U, input "c-price-doc-forming-gds-tnv ":U, input "документа формирования цены                     ", input "товара по обороту                                                 ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-price-doc-forming    ":U, input "c-price-doc-forming-gdsattr ":U, input "документа формирования цены                     ", input "атрибута товара                                                   ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-regions              ":U, input "c-regions                   ":U, input "региона                                         ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "cash-pay               ":U, input "cash-pay                    ":U, input "типов кассовых платежей                         ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "cash-desk              ":U, input "cash-desk                    ":U, input "справочника касс                               ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-rvs-doc              ":U, input "c-rvs-doc                   ":U, input "документа сверки                                ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-rvs-doc              ":U, input "c-rvs-line                  ":U, input "документа сверки                                ", input "строки                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-rvs-doc              ":U, input "c-rvs-line-pump             ":U, input "документа сверки                                ", input "нформации с ТРК по баку                                           ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-sale-doc             ":U, input "c-sale-doc                  ":U, input "документа продажи                               ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-schet-fact-doc       ":U, input "c-schet-fact-doc            ":U, input "счёта-фактуры                                   ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-schet-fact-doc       ":U, input "c-schet-fact-line           ":U, input "счёта-фактуры                                   ", input "строки                                                            ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-season               ":U, input "c-season                    ":U, input "справочника сезонов                             ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-stop-list            ":U, input "c-stop-list                 ":U, input "стоплиста                                       ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-stop-list            ":U, input "c-stop-list-line            ":U, input "стоплиста                                       ", input "строки                                                            ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-sum-grp              ":U, input "c-sum-grp                   ":U, input "группы для суммовых чеков                       ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-sum-grp-obj          ":U, input "c-sum-grp-obj               ":U, input "группы товаров на кассе на объекте              ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-trn-reason           ":U, input "c-trn-reason                ":U, input "основания создания документа                    ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-trn-reason           ":U, input "c-trn-rsn-attr              ":U, input "основания создания документа                    ", input "атрибутов                                                         ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-trn-reason           ":U, input "c-trn-reason-host           ":U, input "основания создания документа                    ", input "по умолчанию на фирме                                             ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-trn-reason           ":U, input "c-trn-reason-obj            ":U, input "основания создания документа                    ", input "по умолчанию на объекте                                           ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-units                ":U, input "c-units                     ":U, input "единиц измерения                                ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "units                  ":U, input "units                       ":U, input "единиц измерения                                ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-wth-doc              ":U, input "c-wth-doc                   ":U, input "документа перемещения матценностей              ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-wth-doc              ":U, input "c-wth-dtl                   ":U, input "документа перемещения матценностей              ", input "разбивки                                                          ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-wth-doc              ":U, input "c-wth-line                  ":U, input "документа перемещения матценностей              ", input "строки                                                            ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-wth-doc              ":U, input "c-wth-parts                 ":U, input "документа перемещения матценностей              ", input "партии                                                            ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-wth-gds              ":U, input "c-wth-gds                   ":U, input "связи матценности с товаром                     ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-wth-gds              ":U, input "c-wth-gds-attr              ":U, input "связи матценности с товаром                     ", input "атрибутов                                                         ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-wth-obj              ":U, input "c-wth-obj                   ":U, input "матценностей на объекте                         ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-wth-place            ":U, input "c-wth-place                 ":U, input "места хранения матценностей                     ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-wth-pobj             ":U, input "c-wth-pobj                  ":U, input "остатков матценностей на месте хранения (объект)", input "                                                                  ":U, input v-err-msg, output v-err-msg ).

    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-wth-ser              ":U, input "c-wth-ser                   ":U, input "маски (серии) матценностей                      ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "c-wth-ser              ":U, input "c-wth-ser-attr              ":U, input "маски (серии) матценностей                      ", input "атрибутов                                                         ":U, input v-err-msg, output v-err-msg ).
    
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "rvs-doc                ":U, input "rvs-doc                     ":U, input "документа сверки                                ", input "                                                                  ":U, input v-err-msg, output v-err-msg ).
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "rvs-doc                ":U, input "rvs-line                    ":U, input "документа сверки                                ", input " строки                                                               ":U, input v-err-msg, output v-err-msg ).
    
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "thbj-attr              ":U, input "thbj-attr                   ":U, input "параметра объекта TH                            ", input "                                                                ":U, input v-err-msg, output v-err-msg ).
    
    run userlog-hist-table-add in this-procedure ( input {&userlog-type-simple}, input "staff                  ":U, input "staff                       ":U, input "данные персонала                                ", input "данные персонала                                                  ":U, input v-err-msg, output v-err-msg ).
    

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
end procedure. /* userlog-hist-table-init-all */

/*==========================================================================
    Имя таблицы по коду.
*/
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
end procedure. /* userlog-get-table-name */


/*==========================================================================*/
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
    if p-ulbType <> {&userlog-type-simple}
      and p-ulbType <> {&userlog-type-bush}
      then 
    do:
      assign
        v-success = no
        v-err-msg = "Неизвестный тип истории пользователя."
        .
    end.        /* if p-ulbType <> {&userlog-type-simple} */
    else 
    do:
      if p-ParentTableName = "":U
        or p-ParentTableName = p-TableName
        then 
      do:        /* Головная таблица куста */
        assign
          v-success    = yes
          v-err-msg    = "":U
          v-parent-key = 0
          .
        if p-ulbType = {&userlog-type-bush}
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
      end.        /* if p-ParentTableName = "":U */
      else 
      do:
        find first buf_parent-temp_userlog-bush
          where buf_parent-temp_userlog-bush.ulbParentKey = 0
          and buf_parent-temp_userlog-bush.ulbTableName = p-ParentTableName
          no-error.
        if not available buf_parent-temp_userlog-bush
          then 
        do:
          if p-ulbType = {&userlog-type-bush}
            then 
          do:        /* Головная таблица куста работает только как связка. В комментарий пишется имя таблицы. */
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
        end.        /* not available buf_parent-temp_userlog-bush */
        else 
        do:
          assign
            v-success    = yes
            v-err-msg    = "":U
            v-parent-key = buf_parent-temp_userlog-bush.ulb-key
            .
        end.        /* available buf_parent-temp_userlog-bush */
      end.        /* if p-ParentTableName <> "":U */
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
    end.        /* if p-ulbType = {&userlog-type-simple} */
    if v-success = no
      then 
    do:
      assign
        p-out-err-msg = substitute( "&1&2 &3. Тип: '&4'. Таблица: '&5'. Родитель: '&6'.":U
                                        , p-out-err-msg
                                        , ( if p-out-err-msg = "":U then "":U else {&new-line} )
                                        , v-err-msg
                                        , p-ulbType
                                        , p-ParentTableName
                                        , p-TableName
                                        )
        .
    end.
  end.
end procedure. /* userlog-hist-table-add */


/*==========================================================================*/
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
      v-userlog-{&vssseq}-ulb-key = v-userlog-{&vssseq}-ulb-key + 1
      .
    create buf_temp_userlog-bush.
    assign
      buf_temp_userlog-bush.ulb-key       = v-userlog-{&vssseq}-ulb-key
      buf_temp_userlog-bush.ulbType       = p-ulbType
      buf_temp_userlog-bush.ulbParentKey  = p-parent-key
      buf_temp_userlog-bush.ulbTableName  = p-TableName
      buf_temp_userlog-bush.ulbTwoKey     = i-TwoKey
      buf_temp_userlog-bush.ulbParentDesc = p-ParentDesc
      buf_temp_userlog-bush.ulbDesc       = p-Desc
      buf_temp_userlog-bush.selected      = no
      .

  end.
end procedure. /* userlog-create-userlog-bush */

/* $Workfile$ e n d */