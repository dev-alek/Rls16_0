block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ini-supp.p $
$Archive: utl/ini-supp.p $

Инициализация остатков по поставщику

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 03/21/06

количеств и суммовые остатки в учетных ценах (базовая валюта и р_у_бли)

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ini-supp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ini-supp.p $":U .
define variable vss-description as character no-undo init "Инициализация остатков по поставщику".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ trg/partslib.i }
{ gbl/waitfram.i }

define temp-table temp-cli-gds no-undo
  field temp-cli-type  like ub.cli-gds.cli-type
  field temp-cli-code  like ub.cli-gds.cli-code
  field temp-host-code like ub.cli-gds.host-code
  field temp-artic     like ub.cli-gds.artic
  field temp-prod-type like ub.cli-gds.prod-type
  field temp-prod-code like ub.cli-gds.prod-code

  field new-supp-qnty  like ub.cli-gds.supp-qnty
  field new-supp-base  like ub.cli-gds.supp-base
  field new-supp-rubl  like ub.cli-gds.supp-rubl

  field old-supp-qnty  like ub.cli-gds.supp-qnty
  field old-supp-base  like ub.cli-gds.supp-base
  field old-supp-rubl  like ub.cli-gds.supp-rubl

  index pi temp-cli-type temp-cli-code temp-host-code temp-artic temp-prod-type temp-prod-code
.

define variable v-num       as integer   no-undo .
define variable v-ind       as integer   no-undo .
define variable v-all-goods as logical   no-undo .
define variable v-gds-code  as integer   no-undo .


do
on error undo, return error return-value
:
  run gbl/d-askw.w
    (input "Вопрос"
    ,input "Товарный архив по контрагентам." + {&new-line}
          + "Рассчет остатков по поставщикам"
    ,input "|^"
    ,input "Все товары^confirm|Выбрать товар|Отмена"
    ,input "|"
        + "|"
        + ""
    ,input 1
    ,input 3
    ,output v-num
    ).

  case v-num
  :
    when 1
    then do:
      assign
        v-all-goods = true
      .
    end.
    when 2
    then do:
      define variable rid-list as character no-undo.
      run ref/gds-ref.p (
                       input parparentproc
                      ,input "{&lookup},b-sel"
                      ,input ?                /*p-stat */
                      ,input ?                /*p-list  */
                      ,input ?                /*p-cond  */
                      ,input ?                /*p-rec   */
                      ,input ?                /*p-grp   */
                      ,input ?                /*p-cli-type */
                      ,input ?                /*p-cli-code  */
                      ,input ?                /*p-obj-type  */
                      ,input ?                 /*p-obj-code  */
                      ,input ?                /*p-other     */
                      ,output rid-list).
      find ub.goods no-lock
        where recid(ub.goods) = integer(rid-list)
        no-error
        .
      if not available ub.goods
      then do:
        message
          "Товар не выбран"
          view-as alert-box information.
        return .
      end.
      else do:
        assign
          v-all-goods = false
          v-gds-code  = goods.gds-code
        .
      end.
    end.
    when 3
    then do:
      return .
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Неизвестное значение v-num" v-num skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.

  define query q-goods for goods .

  if v-all-goods
  then do:
    open query q-goods
      for each ub.goods no-lock
        where ub.goods.gds-type = {&gds-goods}
    .
  end.
  else do:
    open query q-goods
      for each ub.goods no-lock
        where ub.goods.gds-type = {&gds-goods}
          and ub.goods.gds-code = v-gds-code
    .
  end.

  repeat
  :
    do
    on error undo, next
    on stop undo, return
    :
      get next q-goods .
      if not available goods
      then do:
        leave .
      end.

      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input waitfram-join-function(vss-description
                                      ,substitute("Артикул: &1 &2 &3"
                                                  ,goods.artic
                                                  ,goods.prod-type
                                                  ,goods.prod-code
                                                  )
                                      ,substitute("Обработано: &1"
                                                  , v-ind
                                                  )
                                      )
          ).
      end.

      run calc-supp-by-parts in this-procedure
        (input  ub.goods.gds-code /* p-gds-code*/
        ) .
    end.
  end.

  run waitfram-hide in this-procedure .

  if v-all-goods = false
  then do:
    message
      vss-description "для товара "
      string(v-gds-code)
      "завершен"
      view-as alert-box .
  end.
  else do:
    message
      vss-description "завершен"
      view-as alert-box .
  end.
end.


procedure calc-supp-by-parts :

  define input  parameter p-gds-code as integer   no-undo .

  define buffer buf_goods        for ub.goods     .
  define buffer buf_gds-obj      for ub.gds-obj   .
  define buffer buf_cli-gds      for ub.cli-gds   .
  define buffer buf_temp-cli-gds for temp-cli-gds .
  define buffer buf_temp-parts   for temp-parts   .

  do transaction
  on error undo, return error return-value
  :
    find first buf_goods no-lock
      where buf_goods.gds-code = p-gds-code
      .

    /* очищаем временную таблицу */
    for each buf_temp-cli-gds
    on error undo, return error
    :
      delete buf_temp-cli-gds .
    end.

    /* сохраняем старые значения */
    for each buf_cli-gds exclusive-lock
      where buf_cli-gds.artic     = buf_goods.artic
        and buf_cli-gds.prod-type = buf_goods.prod-type
        and buf_cli-gds.prod-code = buf_goods.prod-code
    on error undo, return error return-value
    :
      create buf_temp-cli-gds .

      assign
        buf_temp-cli-gds.temp-cli-type  = buf_cli-gds.cli-type
        buf_temp-cli-gds.temp-cli-code  = buf_cli-gds.cli-code
        buf_temp-cli-gds.temp-host-code = buf_cli-gds.host-code
        buf_temp-cli-gds.temp-artic     = buf_cli-gds.artic
        buf_temp-cli-gds.temp-prod-type = buf_cli-gds.prod-type
        buf_temp-cli-gds.temp-prod-code = buf_cli-gds.prod-code
      .

      assign
        buf_temp-cli-gds.old-supp-qnty = buf_cli-gds.supp-base
        buf_temp-cli-gds.old-supp-base = buf_cli-gds.supp-rubl
        buf_temp-cli-gds.old-supp-rubl = buf_cli-gds.supp-qnty
      .
    end.

    /* вычисляем новые значения */
    for each buf_gds-obj exclusive-lock
      where buf_gds-obj.gds-code = p-gds-code
    on error undo, return error
    :
      /* определяем код фирмы для объекта */
      define variable v-host-code like ub.cli-gds.host-code no-undo .
      { gbl/hostcode.i
        buf_gds-obj.obj-type
        buf_gds-obj.obj-code
        v-host-code
      }

      run partslib-init-temp-parts in this-procedure
        (input buf_gds-obj.obj-type  /* p-obj-type  */
        ,input buf_gds-obj.obj-code  /* p-obj-code  */
        ,input buf_gds-obj.artic     /* p-artic     */
        ,input buf_gds-obj.prod-type /* p-prod-type */
        ,input buf_gds-obj.prod-code /* p-prod-code */
        ) .

      for each buf_temp-parts
      on error undo, return error return-value
      :
        find first buf_temp-cli-gds
          where buf_temp-cli-gds.temp-cli-type  = buf_temp-parts.supp-type
            and buf_temp-cli-gds.temp-cli-code  = buf_temp-parts.supp-code
            and buf_temp-cli-gds.temp-host-code = v-host-code
            and buf_temp-cli-gds.temp-artic     = buf_temp-parts.artic
            and buf_temp-cli-gds.temp-prod-type = buf_temp-parts.prod-type
            and buf_temp-cli-gds.temp-prod-code = buf_temp-parts.prod-code
          no-error .
        if not available buf_temp-cli-gds
        then do:
          create buf_temp-cli-gds .
          assign
            buf_temp-cli-gds.temp-cli-type  = buf_temp-parts.supp-type
            buf_temp-cli-gds.temp-cli-code  = buf_temp-parts.supp-code
            buf_temp-cli-gds.temp-host-code = v-host-code
            buf_temp-cli-gds.temp-artic     = buf_temp-parts.artic
            buf_temp-cli-gds.temp-prod-type = buf_temp-parts.prod-type
            buf_temp-cli-gds.temp-prod-code = buf_temp-parts.prod-code
          .
        end.

        assign
          buf_temp-cli-gds.new-supp-qnty = buf_temp-cli-gds.new-supp-qnty
                                         + buf_temp-parts.fact-qnty
          buf_temp-cli-gds.new-supp-base = buf_temp-cli-gds.new-supp-base
                                         + (buf_temp-parts.price-base * buf_temp-parts.fact-qnty )
          buf_temp-cli-gds.new-supp-rubl = buf_temp-cli-gds.new-supp-rubl
                                         + (buf_temp-parts.price-rubl * buf_temp-parts.fact-qnty )
        .
      end.
    end.

    /* обновляем только те записи, которые не соответствуют действительности */
    for each buf_temp-cli-gds
      where (buf_temp-cli-gds.new-supp-qnty <> buf_temp-cli-gds.old-supp-qnty)
         or (buf_temp-cli-gds.new-supp-base <> buf_temp-cli-gds.old-supp-base)
         or (buf_temp-cli-gds.new-supp-rubl <> buf_temp-cli-gds.old-supp-rubl)
    on error undo, return error
    :

      { gbl/cligdscr.i
        buf_temp-cli-gds.temp-cli-type
        buf_temp-cli-gds.temp-cli-code
        buf_temp-cli-gds.temp-host-code
        buf_temp-cli-gds.temp-artic
        buf_temp-cli-gds.temp-prod-type
        buf_temp-cli-gds.temp-prod-code
        buf_cli-gds
      }

      find current buf_cli-gds exclusive-lock .

      assign
        buf_cli-gds.supp-qnty = buf_temp-cli-gds.new-supp-qnty
        buf_cli-gds.supp-base = buf_temp-cli-gds.new-supp-base
        buf_cli-gds.supp-rubl = buf_temp-cli-gds.new-supp-rubl
      .
    end.
  end.

end procedure. /* calc-supp-by-parts */