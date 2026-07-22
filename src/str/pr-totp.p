block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: pr-totp.p $
$Archive: str/pr-totp.p $

Расчет сумм по документу переоценки

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06


*/

define input parameter d-num like ub.price-doc.doc-num.  /* номер обрабатываемой переоценки */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: pr-totp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/pr-totp.p $":U .
define variable vss-description as character no-undo init "Расчет сумм по документу переоценки".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ str/pr-lattr.i }
{ gbl/waitfram.i }



define buffer  sub-list for ub.price-list.            /* буфер для спеццены */
define buffer  sub-code for ub.bar-code.              /* код для спеццены */
define buffer  buf_price-list for ub.price-list.
define buffer  buf_bar-code for  ub.bar-code.
define buffer  buf_goods for ub.goods.
define buffer  buf_gds-obj for ub.gds-obj.
define buffer  Buf_prt-obj for ub.prt-obj.

define variable var-pr-r-b as character no-undo .
{ gbl/curr-r-b.i  var-pr-r-b }

/* количество строк в переоценке:
   в  1-м цикле - общее кол-во (по всем строкам)
   во 2-м цикле - количество главных цен */
define variable v-price-list-total             as integer no-undo .

define variable v-avrg-r-b                     as decimal no-undo .
define variable v-last-r-b                     as decimal no-undo .
define variable v-doc-qnty                     as decimal no-undo .
define variable v-price-sale                   as decimal no-undo . /* сумма переоценки = стало - было */
define variable v-rest-sale                    as decimal no-undo .

define buffer Buf_parts-free for ub.parts  .
define variable v-cur-dn as character no-undo .
define variable v-parts-price-sale  as decimal   no-undo .
define variable v-cur-rt  as decimal   no-undo .
define variable v-cur-ex as decimal   no-undo .


  v-price-list-total       = 0.

  run waitfram-show in this-procedure  ("Расчет строк по документу переоценки. Ждите ...").

  find price-doc exclusive-lock where
       price-doc.doc-num = d-num.

  /* проверяем правильность всех цен, считаем общее число строк,
     инициируем количество = 0 для основных цен - на случай если потом не найдем Buf_gds-obj */
  chk-prices :
  for each  Buf_price-list where
            Buf_price-list.doc-num = d-num,
      first Buf_bar-code no-lock where
            Buf_bar-code.b-code = Buf_price-list.b-code,
      first Buf_goods no-lock where
            Buf_goods.gds-code = Buf_bar-code.gds-code
      on error undo chk-prices, return error:
    if Buf_price-list.price-sale <= 0 or
       Buf_price-list.price-sale = ? then do:
      message
        "Цена не должна быть меньше или равна 0, или равна ?." skip
        "Артикул: " Buf_goods.artic Buf_goods.gds-name
        view-as alert-box error.
      run waitfram-hide in this-procedure .
      undo chk-prices, return error.
    end.

      run create-price-list-attr in this-procedure
      ( "full-price-sale":U ,
        Buf_price-list.price-sale    ,
        Buf_price-list.b-code ,
        Buf_price-list.doc-num ,
        Buf_price-list.price-type  ).

    if Buf_goods.unit-base = Buf_bar-code.unit-cli then
      /* основная цена - инициируем */
      Buf_price-list.doc-qnty = 0.
      v-price-list-total = v-price-list-total + 1.
  end.

  /* примечание */
  if price-doc.status_ = {&g___new} and
     substr ( price-doc.PS, 1, 1 ) = "@" then
    price-doc.PS = "@  Строк в приказе: " + string ( v-price-list-total, ">>>>>9").

  assign
    v-price-list-total       = 0
    v-avrg-r-b               = 0
    v-last-r-b               = 0
    v-doc-qnty               = 0
    v-price-sale             = 0
    v-rest-sale              = 0
    .

  /* считаем количества и суммы по переоценке
     идем по главным ценам - они должны быть для всех строк
     товар не будет обработан, если нет Buf_gds-obj - такой не может повлиять на сумму документа */

  run waitfram-show in this-procedure ("Расчет итогов по документу переоценки. Ждите ...") .

  clc-tot :
  for each  Buf_price-list where
            Buf_price-list.doc-num = d-num and
            Buf_price-list.main-price = yes,
      first Buf_bar-code no-lock where
            Buf_bar-code.b-code = Buf_price-list.b-code,
      first Buf_gds-obj where
            Buf_gds-obj.gds-code = Buf_bar-code.gds-code and
            Buf_gds-obj.obj-type = Buf_price-list.obj-type and
            Buf_gds-obj.obj-code = Buf_price-list.obj-code,
      first Buf_goods no-lock where
            Buf_goods.gds-code = Buf_bar-code.gds-code
      on error undo clc-tot, return error
      :

        v-price-list-total = v-price-list-total + 1.
        if v-price-list-total modulo 100 = 0 then
          run waitfram-show in this-procedure ("Расчет итогов. Главных цен: " +
                          string (v-price-list-total)).

        /* количество по строке - без учета количеств по спецценам */
        Buf_price-list.doc-qnty = Buf_gds-obj.fact-qnty.

        /* ????? - есть ли Buf_prt-obj, если этого признака не было на объекте и спеццены на него не было? */
        /*for each  sub-list where
                  sub-list.doc-num    = d-num and
                  sub-list.main-price = no and
                  sub-list.artic      = Buf_price-list.artic and
                  sub-list.prod-type  = Buf_price-list.prod-type and
                  sub-list.prod-code  = Buf_price-list.prod-code,
            each  sub-code no-lock where
                  sub-code.b-code = sub-list.b-code,
            each  Buf_prt-obj no-lock where
                  Buf_prt-obj.artic     = Buf_price-list.artic and
                  Buf_prt-obj.prod-type = Buf_price-list.prod-type and
                  Buf_prt-obj.prod-code = Buf_price-list.prod-code and
                  Buf_prt-obj.prt-code  = sub-code.node-code and
                  Buf_prt-obj.obj-type  = Buf_price-list.obj-type and
                  Buf_prt-obj.obj-code  = Buf_price-list.obj-code
        on error undo clc-tot, return error
        on stop undo clc-tot, return error:

          /* проверяем, что это основной едизм - иначе пропускаем */
          if sub-code.unit-cli <> Buf_goods.unit-base then
            next.

          assign
            /* количество по строке спеццены */
            sub-list.doc-qnty = Buf_prt-obj.fact-qnty
            /* некорневая цена - корректируем количество по корневой */
            Buf_price-list.doc-qnty = Buf_price-list.doc-qnty - sub-list.doc-qnty
            /* считаем сумму переоценки по спецценам */
            v-price-sale = v-price-sale
                        /* (новая спеццена - текущая (спец?)цена) * кол-во по спеццене */
                        + ( sub-list.price-sale - Buf_prt-obj.price-sale) * sub-list.doc-qnty
            .
        end.
        */

        /* по партиям */
        for each  sub-list where
                  sub-list.doc-num    = d-num and
                  sub-list.main-price = no and
                  sub-list.artic      = Buf_price-list.artic and
                  sub-list.prod-type  = Buf_price-list.prod-type and
                  sub-list.prod-code  = Buf_price-list.prod-code,
            each  sub-code no-lock where
                  sub-code.b-code = sub-list.b-code,
            each  Buf_parts-free no-lock where
                  Buf_parts-free.artic     = Buf_price-list.artic and
                  Buf_parts-free.prod-type = Buf_price-list.prod-type and
                  Buf_parts-free.prod-code = Buf_price-list.prod-code and
                  Buf_parts-free.part-code = sub-code.part-code and
                  Buf_parts-free.in-code   = sub-code.in-code and
                  Buf_parts-free.out-code  = {&free-code} and
                  Buf_parts-free.obj-type  = Buf_price-list.obj-type and
                  Buf_parts-free.obj-code  = Buf_price-list.obj-code
        on error undo clc-tot, return error
        on stop undo clc-tot, return error:

          /* проверяем, что это основной едизм - иначе пропускаем */
          if sub-code.unit-cli <> Buf_goods.unit-base then
            next.

           { gbl/bcodeprc.i
              Buf_price-list.obj-type
              Buf_price-list.obj-code
              sub-code.b-code
              0
              0
              v-cur-dn
              v-parts-price-sale
              v-cur-rt
              v-cur-ex
              no-error }
              if error-status :error then .
              if v-parts-price-sale = ? then v-parts-price-sale = 0 .

          assign
            /* количество по строке спеццены */
            sub-list.doc-qnty = Buf_parts-free.fact-qnty
            /* некорневая цена - корректируем количество по корневой */
            Buf_price-list.doc-qnty = Buf_price-list.doc-qnty - sub-list.doc-qnty
            /* считаем сумму переоценки по спецценам */
            v-price-sale = v-price-sale
                        /* (новая спеццена - текущая (спец?)цена) * кол-во по спеццене */
                        + ( sub-list.price-sale - v-parts-price-sale) * sub-list.doc-qnty
            .
        end.


    assign
      /* уже посчитанная сумма в учетных ценах по товару по объекту */
      v-avrg-r-b   = v-avrg-r-b
                   +  ( if var-pr-r-b = "rubl" then Buf_gds-obj.fact-rubl else Buf_gds-obj.fact-base )
      /* уже посчитанное количество по товару по объекту */
      v-doc-qnty   = v-doc-qnty
                   + Buf_gds-obj.fact-qnty
        /* считаем сумму переоценки по главным ценам */
      v-price-sale = v-price-sale
                     /* (новая цена - текущая цена) * кол-во по гл.цене */
                   + ( buf_price-list.price-sale - Buf_gds-obj.price-sale) * Buf_price-list.doc-qnty
      /* уже посчитанная с учетом спеццен сумма в продажных ценах по товару */
      v-rest-sale  = v-rest-sale
                   + Buf_gds-obj.fact-sale
      .
    if Buf_goods.gds-type = {&gds-goods} then
      /* для услуг в последних ценах не считаем - для них не бывает прихода */
      /* уже посчитанная сумма в последних приходных ценах по товару по объекту */
       if var-pr-r-b = "rubl" then
           v-last-r-b   = v-last-r-b
                        + Buf_gds-obj.last-rubl * Buf_gds-obj.fact-qnty.
          else
           v-last-r-b   = v-last-r-b
                        + Buf_gds-obj.last-base * Buf_gds-obj.fact-qnty.

  end.

  assign
    /* сумма в последних приходных ценах */
    price-doc.rest-last     = v-last-r-b
    /* сумма в средних учетных ценах */
    price-doc.rest-base     = v-avrg-r-b
    /* сумма в продажных ценах до переоценки */
    price-doc.rest-sale     = v-rest-sale
    /* сумма в продажных ценах по документу */
    price-doc.sale-base     = v-price-sale
    /* количество по переоценке */
    price-doc.rest-qnty     = v-doc-qnty
    .
  release price-doc.
  run waitfram-hide in this-procedure .