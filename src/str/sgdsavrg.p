block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: sgdsavrg.p $
$Archive: str/sgdsavrg.p $

ѕроцедура определени€ средней учетной цены товара по различным схемам дл€ группы объектов

јвтор: „ернова —ветлана јлександровна
ƒата создани€: 02/17/06
Author: Svetlana Chernova
Creation date: 02/17/06


*/
define temp-table x_obj-group no-undo like ub.clients  .

define input parameter  p-price-type as character no-undo .
define input parameter  table for x_obj-group .
define input  parameter p-b-code as integer   no-undo .
define input parameter  p-artic      like ub.gds-obj.artic      no-undo .
define input parameter  p-prod-type  like ub.gds-obj.prod-type  no-undo .
define input parameter  p-prod-code  like ub.gds-obj.prod-code  no-undo .

define output parameter p-price-base like ub.gds-obj.avrg-base no-undo .
define output parameter p-price-rubl like ub.gds-obj.avrg-rubl no-undo .
define output parameter p-tax-road-base like ub.gds-obj.avrg-base no-undo .
define output parameter p-tax-road-rubl like ub.gds-obj.avrg-rubl no-undo .



def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: sgdsavrg.p $":U .
def var vss-archive     as character no-undo init "$Archive: str/sgdsavrg.p $":U .
def var vss-description as character no-undo init "ѕроцедура определени€ средней учетной цены товара по различным схемам".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ str/lib-trn.i  }

{ cmp/croslist.i }
{ str/hvrdtax.i  }
{ str/lastincs.i }

define buffer buf_goods   for ub.goods .
define buffer buf_gds-obj for ub.gds-obj .

def var v-total-avrg-base as decimal no-undo .
def var v-total-avrg-rubl as decimal no-undo .
def var v-total-avrg-qnty as decimal no-undo .
def var v-last-in-code  like ub.gds-obj.in-code  no-undo .
def var v-last-obj-type like ub.gds-obj.obj-type no-undo .
def var v-last-obj-code like ub.gds-obj.obj-code no-undo .

find first buf_goods no-lock
  where buf_goods.artic     = p-artic
    and buf_goods.prod-type = p-prod-type
    and buf_goods.prod-code = p-prod-code
  no-error .
if not available buf_goods then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ќе найден товар" skip
    "јртикул" p-artic p-prod-type p-prod-code skip
    view-as alert-box .
  undo, return error .
end.


case p-price-type :
  when {&pr-calc-cost-gr} then do:
    if buf_goods.gds-type = {&gds-goods} then do:
      /* была запрошена учетна€ цена по фирме */
      /* возвращаетс€ средн€€ учетна€ цена партий по фирме
          (с учетом партий зарезервированных за незакрытыми документами)
        */

      assign
        v-total-avrg-base = 0
        v-total-avrg-rubl = 0
        v-total-avrg-qnty = 0
      .
      for each x_obj-group ,
        each buf_gds-obj no-lock
        where buf_gds-obj.obj-type  = x_obj-group.obj-type
          and buf_gds-obj.obj-code  = x_obj-group.obj-code
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

      /* возвращаем среднюю учетную цену товара на S */
      if v-total-avrg-qnty > 0 then do:
        assign
          p-price-base = v-total-avrg-base / v-total-avrg-qnty
          p-price-rubl = v-total-avrg-rubl / v-total-avrg-qnty
        .
      end.
      else do:
        /* в случае отсутстви€ товара возвращаем цену последнего прихода по S */
        run last-incom-S in this-procedure
        ( input   p-artic ,
          input   p-prod-type,
          input   p-prod-code ,
          output  v-last-in-code,
          output  v-last-obj-type,
          output  v-last-obj-code ).

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
    else do:
      /* учетна€ цена по фирме дл€ услуги не определена */
      assign
        p-price-base = ?
        p-price-rubl = ?
      .
    end.
  end.

  when {&pr-calc-rsrv-gr} then do:
    if buf_goods.gds-type = {&gds-goods} then do:
      define buffer buf_parts for ub.parts .

      /* товар учитываетс€ по парти€м */

      /*
        возвращаетс€ средн€€ учетна€ цена положительных партий свободной зоны по объекту
        не учитываютс€ партии зарезервированные за незакрытыми документами
      */
       /*message "ј это по парти€м" . */
      for each x_obj-group ,
        each buf_parts no-lock
        where buf_parts.obj-type  = x_obj-group.obj-type
          and buf_parts.obj-code  = x_obj-group.obj-code
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
        run last-incom-S in this-procedure
        ( input   p-artic ,
          input   p-prod-type,
          input   p-prod-code ,
          output  v-last-in-code,
          output  v-last-obj-type,
          output  v-last-obj-code ).

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
    else do:
      /* дл€ услуг - возвращаем учетную цену услуги */
      assign
        p-price-base = ?
        p-price-rubl = ?
      .
      for each  x_obj-group ,
       first buf_gds-obj no-lock
        where buf_gds-obj.obj-type  = x_obj-group.obj-type
          and buf_gds-obj.obj-code  = x_obj-group.obj-code
          and buf_gds-obj.artic     = p-artic
          and buf_gds-obj.prod-type = p-prod-type
          and buf_gds-obj.prod-code = p-prod-code :
        assign
          p-price-base = buf_gds-obj.price-base
          p-price-rubl = buf_gds-obj.price-rubl
        .
      end.
    end.
  end.

  when {&pr-calc-last-gr} then do:
    /* получить цену последнего прихода по S */
    /* просматриваютс€ все объекты S */
    /* и возвращаетс€ цена последнего прихода по S */
    if buf_goods.gds-type = {&gds-goods} then do:
        run last-incom-S in this-procedure
        ( input   p-artic ,
          input   p-prod-type,
          input   p-prod-code ,
          output  v-last-in-code,
          output  v-last-obj-type,
          output  v-last-obj-code ).

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
  otherwise do:
    message
      vss-workfile vss-revision vss-description skip
      "ќшибка задани€ входных параметров" skip
      "Ќедопустимое значение аргумента p-price-type" p-price-type skip
      "јртикул" p-artic p-prod-type p-prod-code skip
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

/* провер€ем что либо обе цены заданы, либо обе цены не заданы */
if (p-price-base = ?) <> (p-price-rubl = ?) then do:
  message
    vss-workfile vss-revision vss-description skip
    "”четна€ цена в одной из валют не задана" skip
    "p-price-base" p-price-base skip
    "p-price-rubl" p-price-rubl skip
    view-as alert-box error .
  undo, return error .
end.