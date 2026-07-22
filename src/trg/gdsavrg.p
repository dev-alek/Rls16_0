block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура определения средней учетной цены товара по различным схемам

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06


Схемы реализованные на данный момент:
  p-price-type = {&pr-calc-cost}
    для товара: средняя учетная цена товара на фирме
                (с учетом товара зарезервированного за незакрытыми документами)
    для услуги: учетная цена услуги на фирме неопределена

  p-price-type = {&pr-calc-costobj}
    для товара: средняя учетная цена товара на объекте
                (c учетом товара зарезервированного
                за незакрытыми документами -
                 и партии свободной зоны, и резерв документов)
    для услуги: возвращается учетная цена по объекту

  p-price-type = {&pr-calc-rsrv}
    для товара: средняя учетная цена товара на объекте
                (без учета товара зарезервированного
                за незакрытыми документами - только партии свободной зоны)
    для услуги: возвращается учетная цена по объекту

  p-price-type = {&pr-calc-last}
    для товара: цену последнего прихода по фирме
    для услуги: цена последнего прихода услуги по фирме не определена

  p-price-type = {&pr-calc-lastobj}
    для товара: цену последнего прихода по объекту
    для услуги: цена последнего прихода услуги по объекту не определена

Параметры:
  p-host-code - необязательный параметр
    вместо него можно передавать 0
    можно передавать его для ускорения программы

*/

define input parameter  p-price-type as character no-undo .
define input parameter  p-obj-type   like ub.gds-obj.obj-type   no-undo .
define input parameter  p-obj-code   like ub.gds-obj.obj-code   no-undo .
define input parameter  p-host-code  like ub.gds-obj.host-code no-undo .
define input parameter  p-artic      like ub.gds-obj.artic      no-undo .
define input parameter  p-prod-type  like ub.gds-obj.prod-type  no-undo .
define input parameter  p-prod-code  like ub.gds-obj.prod-code  no-undo .
define output parameter p-price-base like ub.gds-obj.avrg-base no-undo .
define output parameter p-price-rubl like ub.gds-obj.avrg-rubl no-undo .
define output parameter p-tax-road-base like ub.gds-obj.avrg-base no-undo .
define output parameter p-tax-road-rubl like ub.gds-obj.avrg-rubl no-undo .



define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Процедура определения средней учетной цены товара по различным схемам".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

define buffer buf_goods   for ub.goods .
define buffer buf_gds-obj for ub.gds-obj .

define variable v-total-avrg-base as decimal no-undo .
define variable v-total-avrg-rubl as decimal no-undo .
define variable v-total-avrg-qnty as decimal no-undo .
define variable v-last-in-code  like ub.gds-obj.in-code  no-undo .
define variable v-last-obj-type like ub.gds-obj.obj-type no-undo .
define variable v-last-obj-code like ub.gds-obj.obj-code no-undo .

find first buf_goods no-lock
  where buf_goods.artic     = p-artic
    and buf_goods.prod-type = p-prod-type
    and buf_goods.prod-code = p-prod-code
  no-error .
if not available buf_goods then do:
  message
    vss-workfile vss-revision vss-description skip
    "Не найден товар" skip
    "Артикул" p-artic p-prod-type p-prod-code skip
    view-as alert-box .
  undo, return error .
end.


case p-price-type :
  when {&pr-calc-cost} then do:
    if buf_goods.gds-type = {&gds-goods} then do:
      /* была запрошена учетная цена по фирме */
      /* возвращается средняя учетная цена партий по фирме
          (с учетом партий зарезервированных за незакрытыми документами)
        */
      if p-host-code = 0
      or p-host-code = ? then do:
        /* определяем код фирмы для объекта */
        { gbl/hostcode.i
          p-obj-type
          p-obj-code
          p-host-code
          no-error
        }
        if error-status:error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно найти фирму для объекта " p-obj-type p-obj-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
      end.

      assign
        v-total-avrg-base = 0
        v-total-avrg-rubl = 0
        v-total-avrg-qnty = 0
      .

      for each buf_gds-obj no-lock
        where buf_gds-obj.host-code = p-host-code
          and buf_gds-obj.artic     = p-artic
          and buf_gds-obj.prod-type = p-prod-type
          and buf_gds-obj.prod-code = p-prod-code
      on error undo, return error
      :
        if buf_gds-obj.avrg-base > 0 then do:
          assign
            v-total-avrg-base = v-total-avrg-base
                              + (buf_gds-obj.avrg-base * buf_gds-obj.avrg-qnty)
            v-total-avrg-rubl = v-total-avrg-rubl
                              + (buf_gds-obj.avrg-rubl * buf_gds-obj.avrg-qnty)
            v-total-avrg-qnty = v-total-avrg-qnty
                              + buf_gds-obj.avrg-qnty
          .
        end.
      end.

      /* возвращаем среднюю учетную цену товара на фирме */
      if v-total-avrg-qnty > 0 then do:
        assign
          p-price-base = v-total-avrg-base / v-total-avrg-qnty
          p-price-rubl = v-total-avrg-rubl / v-total-avrg-qnty
        .
      end.
      else do:
        /* в случае отсутствия товара возвращаем цену последнего прихода по фирме */
        { trg/lastindc.i
          p-host-code
          p-artic
          p-prod-type
          p-prod-code
          v-last-in-code
          v-last-obj-type
          v-last-obj-code
        }
        find first buf_gds-obj no-lock
          where buf_gds-obj.obj-type  = v-last-obj-type
            and buf_gds-obj.obj-code  = v-last-obj-code
            and buf_gds-obj.artic     = p-artic
            and buf_gds-obj.prod-type = p-prod-type
            and buf_gds-obj.prod-code = p-prod-code
          no-error .
        if available buf_gds-obj then do:
          assign
            p-price-base = buf_gds-obj.last-base
            p-price-rubl = buf_gds-obj.last-rubl
          .
        end.
        else do:
              find first buf_gds-obj no-lock
                where buf_gds-obj.obj-type  = p-obj-type
                  and buf_gds-obj.obj-code  = p-obj-code
                  and buf_gds-obj.artic     = p-artic
                  and buf_gds-obj.prod-type = p-prod-type
                  and buf_gds-obj.prod-code = p-prod-code
                no-error .
              if available buf_gds-obj then do:
                assign
                  p-price-base = buf_gds-obj.last-base
                  p-price-rubl = buf_gds-obj.last-rubl
                .
              end.
        end.
      end.
    end.
    else do:
      /* учетная цена по фирме для услуги не определена */
      assign
        p-price-base = ?
        p-price-rubl = ?
      .
    end.
  end.
  when {&pr-calc-costobj} then do:
    find first buf_gds-obj no-lock
      where buf_gds-obj.obj-type  = p-obj-type
        and buf_gds-obj.obj-code  = p-obj-code
        and buf_gds-obj.artic     = p-artic
        and buf_gds-obj.prod-type = p-prod-type
        and buf_gds-obj.prod-code = p-prod-code
      no-error .
    if available buf_gds-obj then do:
      if buf_goods.gds-type = {&gds-goods} then do:
        if buf_gds-obj.avrg-qnty > 0 then do:
          assign
            p-price-base = buf_gds-obj.avrg-base
            p-price-rubl = buf_gds-obj.avrg-rubl
          .
        end.
        else do:
          assign
            p-price-base = buf_gds-obj.last-base
            p-price-rubl = buf_gds-obj.last-rubl
          .
        end.
      end.
      else do:
        assign
          p-price-base = buf_gds-obj.price-base
          p-price-rubl = buf_gds-obj.price-rubl
        .
      end.
    end.
  end.

  when {&pr-calc-rsrv} then do:
    if buf_goods.gds-type = {&gds-goods} then do:
      define buffer buf_parts for ub.parts .

      /* товар учитывается по партиям */

      /*
        возвращается средняя учетная цена положительных партий свободной зоны по объекту
        не учитываются партии зарезервированные за незакрытыми документами
      */
       /*message "А это по партиям" . */
      for each buf_parts no-lock
        where buf_parts.obj-type  = p-obj-type
          and buf_parts.obj-code  = p-obj-code
          and buf_parts.artic     = p-artic
          and buf_parts.prod-type = p-prod-type
          and buf_parts.prod-code = p-prod-code
          and buf_parts.status_   = no
          and buf_parts.out-code  = {&free-code}  /* только партии свободной зоны */
          and buf_parts.qnty      > 0   /* только положительные партии */
      on error undo, return error
      :
        /*message 'тип партиии ' buf_parts.out-code .*/
          assign
          v-total-avrg-base = v-total-avrg-base
                            + (buf_parts.price-base * buf_parts.qnty)
          v-total-avrg-rubl = v-total-avrg-rubl
                            + (buf_parts.price-rubl * buf_parts.qnty)
          v-total-avrg-qnty = v-total-avrg-qnty
                            + buf_parts.qnty
        .
      end.

      if v-total-avrg-qnty > 0 then do:
        assign
          p-price-base = v-total-avrg-base / v-total-avrg-qnty
          p-price-rubl = v-total-avrg-rubl / v-total-avrg-qnty
        .
      end.
      else do:
        find first buf_gds-obj no-lock
          where buf_gds-obj.obj-type  = p-obj-type
            and buf_gds-obj.obj-code  = p-obj-code
            and buf_gds-obj.artic     = p-artic
            and buf_gds-obj.prod-type = p-prod-type
            and buf_gds-obj.prod-code = p-prod-code
          no-error .
        if available buf_gds-obj then do:
          /* возвращаем цену последнего прихода */
          assign
            p-price-base = buf_gds-obj.last-base
            p-price-rubl = buf_gds-obj.last-rubl
          .
        end.
      end.
    end.
    else do:
      /* для услуг - возвращаем учетную цену услуги */
      find first buf_gds-obj no-lock
        where buf_gds-obj.obj-type  = p-obj-type
          and buf_gds-obj.obj-code  = p-obj-code
          and buf_gds-obj.artic     = p-artic
          and buf_gds-obj.prod-type = p-prod-type
          and buf_gds-obj.prod-code = p-prod-code
        no-error .
      if available buf_gds-obj then do:
        assign
          p-price-base = buf_gds-obj.price-base
          p-price-rubl = buf_gds-obj.price-rubl
        .
      end.
      else do:
        assign
          p-price-base = ?
          p-price-rubl = ?
        .
      end.
    end.
  end.
  when {&pr-calc-last} then do:
    /* получить цену последнего прихода по фирме */
    /* просматриваются все объекты фирмы, находящиеся в данной базе данных */
    /* и возвращается цена последнего прихода по фирме */
    if buf_goods.gds-type = {&gds-goods} then do:
      { trg/lastindc.i
        p-host-code
        p-artic
        p-prod-type
        p-prod-code
        v-last-in-code
        v-last-obj-type
        v-last-obj-code
      }
      find first buf_gds-obj no-lock
        where buf_gds-obj.obj-type  = v-last-obj-type
          and buf_gds-obj.obj-code  = v-last-obj-code
          and buf_gds-obj.artic     = p-artic
          and buf_gds-obj.prod-type = p-prod-type
          and buf_gds-obj.prod-code = p-prod-code
        no-error .
      if available buf_gds-obj then do:
        assign
          p-price-base = buf_gds-obj.last-base
          p-price-rubl = buf_gds-obj.last-rubl
        .
      end.
    end.
  end.
  when {&pr-calc-lastobj} then do:
    if buf_goods.gds-type = {&gds-goods} then do:
      find first buf_gds-obj no-lock
        where buf_gds-obj.obj-type  = p-obj-type
          and buf_gds-obj.obj-code  = p-obj-code
          and buf_gds-obj.artic     = p-artic
          and buf_gds-obj.prod-type = p-prod-type
          and buf_gds-obj.prod-code = p-prod-code
        no-error .
      if available buf_gds-obj then do:
        assign
          p-price-base = buf_gds-obj.last-base
          p-price-rubl = buf_gds-obj.last-rubl
        .
      end.
      else do:
        assign
          p-price-base = ?
          p-price-rubl = ?
        .
      end.
    end.
    else do:
      assign
        p-price-base = ?
        p-price-rubl = ?
      .
    end.
  end.
  otherwise do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Недопустимое значение аргумента p-price-type" p-price-type skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      view-as alert-box error .
    undo, return error . /* --->>>--- */
  end.
end case. /* p-price-type */


/* если цена не задана, то возвращаем неопределенную цену */
if p-price-base = 0 then do:
  assign
    p-price-base = ?
  .
end.

if p-price-rubl = 0 then do:
  assign
    p-price-rubl = ?
  .
end.

/* проверяем что либо обе цены заданы, либо обе цены не заданы */
if (p-price-base = ?) <> (p-price-rubl = ?) then do:
  message
    vss-workfile vss-revision vss-description skip
    "Учетная цена в одной из валют не задана" skip
    "p-price-base" p-price-base skip
    "p-price-rubl" p-price-rubl skip
    view-as alert-box error .
  undo, return error .
end.