block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определить последнюю учётную цену товара на основании партий

Автор: Чернова Светлана Александровна
Дата создания: 09/24/07
Author: Svetlana Chernova
Creation date: 09/24/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 03/04/05

*/

define input  parameter p-obj-type        as character no-undo .
define input  parameter p-obj-code        as integer   no-undo .
define input  parameter p-gds-code        as integer   no-undo .
define input  parameter p-base-rate       as decimal   no-undo .
define input  parameter p-base-scale      as decimal   no-undo .
define output parameter p-last-price-base as decimal   no-undo .
define output parameter p-last-price-rubl as decimal   no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Определить последнюю учётную цену товара на основании партий".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5':u,p-obj-type,p-obj-code,p-gds-code,p-base-rate,p-base-scale)" }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/prl-vat.i  }
{ gbl/getsect.i def }

define buffer buf_goods   for ub.goods .
define buffer buf_db      for ub.db .
define buffer buf_clients for ub.clients .
define buffer buf_parts   for ub.parts .

do
on error undo, return error return-value
:

  find first buf_goods no-lock
    where buf_goods.gds-code = p-gds-code
    no-error .
  if not available buf_goods
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден товар" skip
      "Объект" p-obj-type p-obj-code skip
      "Код товара" p-gds-code
      view-as alert-box error .
    undo, return error return-value .
  end.

  find last buf_parts no-lock
    where buf_parts.obj-type  = p-obj-type
      and buf_parts.obj-code  = p-obj-code
      and buf_parts.artic     = buf_goods.artic
      and buf_parts.prod-type = buf_goods.prod-type
      and buf_parts.prod-code = buf_goods.prod-code
    use-index FIFO
    no-error.
  if available buf_parts
  then do:
    assign
      p-last-price-base = buf_parts.price-base
      p-last-price-rubl = buf_parts.price-rubl
    .
  end.
 /*   закоментарено 19.10.2013.  История файлов показала, что подход, когда учетная цена определяется не по текущему магазину, а по целиком по базе, присутствовал с самого создания файла.
      Однако на практике  это не позволяет отслеживать порождение партий по товарам, которых никогда не было на объекте, но было движение по другим объектам базы.
  else do:
    block_search :
    do:
      for each buf_db no-lock
      on error undo, return error return-value
      :
        for each buf_clients no-lock
          where buf_clients.db-num = buf_db.db-num
        on error undo, return error return-value
        :
          find last buf_parts no-lock
            where buf_parts.obj-type  = buf_clients.obj-type
              and buf_parts.obj-code  = buf_clients.obj-code
              and buf_parts.artic     = buf_goods.artic
              and buf_parts.prod-type = buf_goods.prod-type
              and buf_parts.prod-code = buf_goods.prod-code
            use-index FIFO
            no-error.
          if available buf_parts
          then do:
            assign
              p-last-price-base = buf_parts.price-base
              p-last-price-rubl = buf_parts.price-rubl
            .
            leave block_search .
          end.
        end.
      end.
    end.
  end.
*/ 
  if p-last-price-base = 0
  or p-last-price-rubl = 0
  then do:
    define variable v-rb-is-base                     as logical   no-undo .
    define variable v-host-code                      as integer   no-undo .
    define variable v-b-code                         as integer   no-undo .
    define variable v-price-list-recid               as recid     no-undo .
    define variable v-cli-base-rate                  as decimal   no-undo .
    define variable v-prsalpr-value                  as character no-undo .
    define variable v-prsalpr-type                   as character no-undo .
    define variable v-price-rubl-with-tax-saleprl    as decimal   no-undo .
    define variable v-price-base-with-tax-saleprl    as decimal   no-undo .
    define variable v-price-rubl-without-tax-saleprl as decimal   no-undo .
    define variable v-price-base-without-tax-saleprl as decimal   no-undo .
    define variable v-vat-base-saleprl               as decimal   no-undo .
    define variable v-vat-rubl-saleprl               as decimal   no-undo .
    define variable v-vat-base-buyerprl              as decimal   no-undo .
    define variable v-vat-rubl-buyerprl              as decimal   no-undo .
    define variable v-slt-base-saleprl               as decimal   no-undo .
    define variable v-slt-rubl-saleprl               as decimal   no-undo .
    define variable v-road-tax-base-saleprl          as decimal   no-undo .
    define variable v-road-tax-rubl-saleprl          as decimal   no-undo .
    define variable v-excise-base-saleprl            as decimal   no-undo .
    define variable v-excise-rubl-saleprl            as decimal   no-undo .
    define variable v-discnt-base-saleprl            as decimal   no-undo .
    define variable v-discnt-rubl-saleprl            as decimal   no-undo .

    { gbl/hostcode.i
      p-obj-type
      p-obj-code
      v-host-code
    }

{ gbl/getsect.i run p-obj-type p-obj-code  {&attr-rezerv-obj} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'prsalpr'  then v-prsalpr-value  = string( thbjattr_thbj-attr.property-value-logical).
end.

    if lookup(v-prsalpr-value, 'yes,true':u) > 0
    then do:
      { gbl/gdsbcode.i
        p-gds-code
        ?
        v-b-code
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при поиске первичного бар-кода товара" skip
          "Код товара" p-gds-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      { gbl/bcodepls.i
        p-obj-type
        p-obj-code
        v-b-code
        0
        0
        v-price-list-recid
        v-cli-base-rate
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении цены бар-кода" skip
          "Объект" p-obj-type p-obj-code skip
          "Бар-код" v-b-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      if v-price-list-recid <> ?
      then do:
        run prl-vat in this-procedure
          (input  v-price-list-recid
          ,output v-price-rubl-with-tax-saleprl
          ,output v-price-base-with-tax-saleprl
          ,output v-price-rubl-without-tax-saleprl
          ,output v-price-base-without-tax-saleprl
          ,output v-vat-base-saleprl
          ,output v-vat-rubl-saleprl
          ,output v-vat-base-buyerprl
          ,output v-vat-rubl-buyerprl
          ,output v-slt-base-saleprl
          ,output v-slt-rubl-saleprl
          ,output v-road-tax-base-saleprl
          ,output v-road-tax-rubl-saleprl
          ,output v-excise-base-saleprl
          ,output v-excise-rubl-saleprl
          ,output v-discnt-base-saleprl
          ,output v-discnt-rubl-saleprl
          ) no-error .

        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процеды prl-vat" skip
            "Объект" p-obj-type p-obj-code skip
            "Бар-код" v-b-code skip
            "Код строки переоценки" v-price-list-recid skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.

        { gbl/rbisbase.i
          v-rb-is-base
        }

        if v-rb-is-base = true
        then do:
          assign
            p-last-price-base = v-price-base-without-tax-saleprl
            p-last-price-rubl = v-price-base-without-tax-saleprl
                              * p-base-rate
                              / p-base-scale
          .
        end.
        else do:
          assign
            p-last-price-base = v-price-rubl-without-tax-saleprl
                              / p-base-rate
                              * p-base-scale
            p-last-price-rubl = v-price-rubl-without-tax-saleprl
          .
        end.
      end.
    end.
  end.
end.