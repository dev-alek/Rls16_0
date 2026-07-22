/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Рассчет информации в gds-obj - сумма в учетных ценах

Автор: Перваков Михаил Сергеевич
Дата создания: 04/11/06
Author: Mikhail Pervakov
Creation date: 04/11/06

TODO - вычислять free-qnty, fact-cli-qnty

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure gdsobjcl :

  /* расчет записи товар на объекте */

  define input parameter p-gds-obj-recid    as recid no-undo .
  define input parameter p-update-fact-qnty as logical   no-undo .

  define variable vss-description as character no-undo init "$Workfile$ gdsobjcl: расчет записи товар на объекте ".

  define buffer buf_parts for ub.parts .

  define variable v-total-avrg-base as decimal no-undo .
  define variable v-total-avrg-rubl as decimal no-undo .
  define variable v-total-avrg-qnty as decimal no-undo .
  define variable v-parts-avrg-qnty as decimal no-undo .
  define variable v-total-fact-base as decimal no-undo .
  define variable v-total-fact-rubl as decimal no-undo .
  define variable v-total-fact-qnty as decimal no-undo .
  define variable v-parts-fact-qnty as decimal   no-undo .

  define buffer buf_gds-obj for ub.gds-obj .
  define buffer buf_prt-obj for ub.prt-obj .
  define buffer buf_gds-prt for ub.gds-prt .

  do
  on error undo, return error return-value
  :
    find first buf_gds-obj exclusive-lock
      where recid(buf_gds-obj) = p-gds-obj-recid
      no-error .
    if not available buf_gds-obj
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найдена запись товар на объекте" skip
        "Код записи (recid)" p-gds-obj-recid skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    assign
      v-total-avrg-base = 0
      v-total-avrg-rubl = 0
      v-total-avrg-qnty = 0
      v-total-fact-base = 0
      v-total-fact-rubl = 0
      v-total-fact-qnty = 0
    .

    for each buf_parts no-lock
      where buf_parts.obj-type  = buf_gds-obj.obj-type
        and buf_parts.obj-code  = buf_gds-obj.obj-code
        and buf_parts.artic     = buf_gds-obj.artic
        and buf_parts.prod-type = buf_gds-obj.prod-type
        and buf_parts.prod-code = buf_gds-obj.prod-code
        and buf_parts.status_   = no
        and buf_parts.rsrv-free = yes  /* все партии свободной зоны */
        and buf_parts.in-code   <> buf_parts.out-code
        and buf_parts.doc-type  <> {&act-overvalue}
    on error undo, return error return-value
    :
      assign
        v-parts-avrg-qnty = 0
        v-parts-fact-qnty = 0
      .
      if buf_parts.out-code = {&free-code}
      then do:
        if buf_parts.fact-qnty > 0
        then do:
          assign
            v-parts-avrg-qnty = buf_parts.qnty
          .
        end.
        assign
          v-parts-fact-qnty = buf_parts.qnty
        .
      end.
      else do:
        assign
          v-parts-avrg-qnty = abs(buf_parts.qnty)
          v-parts-fact-qnty = abs(buf_parts.qnty)
        .
      end.

      assign
        v-total-avrg-base = v-total-avrg-base
                          + (buf_parts.price-base * v-parts-avrg-qnty)
        v-total-avrg-rubl = v-total-avrg-rubl
                          + (buf_parts.price-rubl * v-parts-avrg-qnty)
        v-total-avrg-qnty = v-total-avrg-qnty
                          + v-parts-avrg-qnty
        v-total-fact-base = v-total-fact-base
                          + (buf_parts.price-base * v-parts-fact-qnty)
        v-total-fact-rubl = v-total-fact-rubl
                          + (buf_parts.price-rubl * v-parts-fact-qnty)
        v-total-fact-qnty = v-total-fact-qnty
                          + v-parts-fact-qnty
      .
    end.

    if v-total-avrg-qnty < 0
    or v-total-avrg-qnty = ?
    then do:
      undo, return error
        vss-description + {&new-line}
        + "Количество положительных партий в свободной зоне не может быть отрицательным или неопределенным" + {&new-line}
        + "v-total-avrg-qnty " + (if v-total-avrg-qnty <> ? then string(v-total-avrg-qnty) else "?")
        .
    end.


    if v-total-fact-base = ?
    or v-total-fact-rubl = ?
    then do:
      undo, return error
        vss-description + {&new-line}
        + "Сумма учетных цен по товару на объекте не может иметь неопределенное значение" + {&new-line}
        + "v-total-fact-base " + (if v-total-fact-base <> ? then string(v-total-fact-base) else "?") + {&new-line}
        + "v-total-fact-rubl " + (if v-total-fact-rubl <> ? then string(v-total-fact-rubl) else "?") + {&new-line}
        .
    end.

    /* обновляем общее количество положительных партий */
    assign
      buf_gds-obj.avrg-qnty = v-total-avrg-qnty
      buf_gds-obj.fact-base = v-total-fact-base
      buf_gds-obj.fact-rubl = v-total-fact-rubl
    .

    if p-update-fact-qnty
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров"
        "В данной версии обновление фактического количества не реализовано" skip
        "p-update-fact-qnty" p-update-fact-qnty skip
        view-as alert-box error .
      undo, return error return-value .
      /* todo */
/*      assign*/
/*        buf_gds-obj.fact-qnty = */
/*        buf_gds-obj.free-qnty =*/
/*      .*/
    end.

    if buf_gds-obj.fact-qnty <> v-total-fact-qnty
    then do:
      undo, return error
        vss-description + {&new-line}
        + "Не совпадает общее количество по партиям и фактическое количество по товару на объекте" + {&new-line}
        + "buf_gds-obj.fact-qnty " + (if buf_gds-obj.fact-qnty <> ? then string(buf_gds-obj.fact-qnty) else "?") + {&new-line}
        + "v-total-fact-qnty "     + (if v-total-fact-qnty     <> ? then string(v-total-fact-qnty)     else "?") + {&new-line}
        .
    end.

    /* обновляем среднюю цену положительных партий */
    if v-total-avrg-qnty > 0
    then do:
      assign
        buf_gds-obj.avrg-base = v-total-avrg-base / v-total-avrg-qnty
        buf_gds-obj.avrg-rubl = v-total-avrg-rubl / v-total-avrg-qnty
      .
    end.
    else do:
      if  buf_gds-obj.last-base > 0
      and buf_gds-obj.last-rubl > 0
      then do:
        /* При нулевом количестве положительных партий
          в качестве новой средней учетной цены используется цену последнего прихода.
          Если она не задана - то среднюю учетную цену не меняем.
        */
        assign
          buf_gds-obj.avrg-base = buf_gds-obj.last-base
          buf_gds-obj.avrg-rubl = buf_gds-obj.last-rubl
        .
      end.
    end.

    define variable v-total-sale-fact-qnty as decimal   no-undo .
    define variable v-total-fact-sale      as decimal   no-undo .

    assign
      v-total-sale-fact-qnty = 0
      v-total-fact-sale      = 0
    .

    /* вычисляем сумму остатка в продажных ценах */
    for each buf_prt-obj
      where buf_prt-obj.obj-type  = buf_gds-obj.obj-type
        and buf_prt-obj.obj-code  = buf_gds-obj.obj-code
        and buf_prt-obj.artic     = buf_gds-obj.artic
        and buf_prt-obj.prod-type = buf_gds-obj.prod-type
        and buf_prt-obj.prod-code = buf_gds-obj.prod-code
        and buf_prt-obj.is-term   = true
    on error undo, return error return-value
    :
      assign
        v-total-sale-fact-qnty  = v-total-sale-fact-qnty
                                + buf_prt-obj.fact-qnty
        v-total-fact-sale       = v-total-fact-sale
                                + buf_prt-obj.fact-qnty * buf_prt-obj.price-sale
      .
    end.

    if v-total-fact-sale = ?
    then do:
      undo, return error
        vss-description + {&new-line}
        + "Сумма продажных цен по товару на объекте не может иметь неопределенное значение" + {&new-line}
        + "v-total-fact-sale " + (if v-total-fact-sale <> ? then string(v-total-fact-sale) else "?") + {&new-line}
        .
    end.

    if buf_gds-obj.fact-qnty <> v-total-sale-fact-qnty
    then do:
      undo, return error
        vss-description + {&new-line}
        + "Не совпадает общее количество по признакам и фактическое количество по товару на объекте" + {&new-line}
        + "buf_gds-obj.fact-qnty "  + (if buf_gds-obj.fact-qnty <> ?  then string(buf_gds-obj.fact-qnty)  else "?") + {&new-line}
        + "v-total-sale-fact-qnty " + (if v-total-sale-fact-qnty <> ? then string(v-total-sale-fact-qnty) else "?") + {&new-line}
        .
    end.

    assign
      buf_gds-obj.fact-sale = v-total-fact-sale
    .
  end.

end procedure .

procedure gdsobjcl-calc-goods :

  /* расчет всех записей товар на объекте для указанного товара */

  define input parameter p-artic     like ub.goods.artic     no-undo .
  define input parameter p-prod-type like ub.goods.prod-type no-undo .
  define input parameter p-prod-code like ub.goods.prod-code no-undo .

  define variable vss-description as character no-undo init "$Workfile$ gdsobjcl-calc-goods".

  do
  on error undo, return error return-value
  :

    define buffer buf_gds-obj for ub.gds-obj .
    define buffer buf_prt-obj for ub.prt-obj .

    do
    on error undo, return error return-value
    :
      for each buf_prt-obj
        where buf_prt-obj.artic     = p-artic
          and buf_prt-obj.prod-type = p-prod-type
          and buf_prt-obj.prod-code = p-prod-code
      on error undo, return error return-value
      :
        { gbl/prtobjup.i
          buf_prt-obj
          no-error
        }
        if error-status :error
        then do:
          undo, return error
            "объект "  + string(buf_prt-obj.obj-type) + " " + string(buf_prt-obj.obj-code) + {&new-line}
            + "артикул " + string(buf_prt-obj.artic) + " " + string(buf_prt-obj.prod-type) + " " + string(buf_prt-obj.prod-code) + {&new-line}
            + "признак " + string(buf_prt-obj.prt-code) + {&new-line}
            + return-value .
        end.
      end.

      for each buf_gds-obj
        where buf_gds-obj.artic     = p-artic
          and buf_gds-obj.prod-type = p-prod-type
          and buf_gds-obj.prod-code = p-prod-code
      on error undo, return error return-value
      :
        run gdsobjcl in this-procedure
          (input recid(buf_gds-obj) /* p-gds-obj-recid    */
          ,input false              /* p-update-fact-qnty */
          ) no-error .
        if error-status :error
        then do:
          undo, return error
            "объект " + string(buf_gds-obj.obj-type) + " " + string(buf_gds-obj.obj-code) + {&new-line}
            + return-value .
        end.
      end.
    end.
  end.

end procedure. /* gdsobjcl-calc-goods */



/* $Workfile$ e n d */