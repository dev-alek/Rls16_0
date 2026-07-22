block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: incligds.p $
$Archive: utl/incligds.p $

Расчет Итоговых значени  по товарам (приход, расход, возврат) по контрагентам

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 05/31/04

*/

define input  parameter parparentproc       as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: incligds.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/incligds.p $":U .
define variable vss-description as character no-undo init "Расчет товарного архива (приход, расход, возврат) по контрагентам" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

define temp-table temp-trn-doc no-undo
  field doc-code as character

  index xpk is primary unique doc-code
.


define variable v-ind       as integer   no-undo .
define variable v-action    as character no-undo .
define variable v-firm-name as character no-undo .
define variable v-rid-list  as character no-undo .

define buffer in-doc for ub.trn-doc .

define frame a
  v-firm-name format "x(30)"       label "Фирма" skip
  v-action    format "x(30)"       no-label            skip
  v-ind       format ">>>,>>>,>>9" label "Обработано"  skip
  with three-d view-as dialog-box centered side-labels
  title "Итоговые значения по товарам по контрагентам"
  .

/* задание фирмы */
define variable v-select-firm as logical   no-undo .
define variable v-host-code   as integer   no-undo .
define variable v-num         as integer   no-undo .

define buffer buf_dis-card     for ub.dis-card  .
define buffer buf_shop         for ub.shop      .
define buffer buf_chk-doc      for ub.chk-doc   .
define buffer buf_trn-doc      for ub.trn-doc   .

{ cmp/cli-list.i cli-list def "new shared" }

do
on error undo, return error return-value
:

  run gbl/d-askw.w
    (input "Вопрос"
    ,input "Инициализация расчета Итоговых значений по товарам по контрагентам  (приход, расход, возврат)" + {&new-line}
    ,input "|^"
    ,input "Все фирмы^confirm|Выбрать фирму|Отмена"
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
        v-select-firm = false
      .
    end.
    when 2
    then do:
      assign
        v-select-firm = true
      .
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

  if v-select-firm = true
  then do:
    run adm/sconfs.w
      (input  parparentproc         /* parparentproc    */
      ,input  'b-sel':U             /* bttns            */
      ,input  no                    /* p-lock-self-host */
      ,input  v-cntxt-host-code-obj /* p-curr-host-code */
      ,output v-host-code           /* p-out-host-code  */
      ,input-output v-rid-list      /* p-rid-list       */
      ) no-error.
    if error-status :error
    or v-host-code = 0
    or v-host-code = ?
    then do:
      /* отмена выбора фирмы */
      return .
    end.
  end.

  /* выбор контрагента */
  define variable v-select-clients as logical   no-undo .
  define variable v-select-ok      as logical   no-undo .

  run gbl/d-askw.w
    (input "Вопрос"
    ,input "Инициализация расчета Итоговых значений по товарам по контрагентам  (приход, расход, возврат)" + {&new-line}
    ,input "|^"
    ,input "Все контрагенты^confirm|Выбрать контрагентов|Отмена"
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
        v-select-clients = false
      .
    end.
    when 2
    then do:
      assign
        v-select-clients = true
      .
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
  for each cli-list:
    delete cli-list.
  end.
  if v-select-clients = true
  then do:
    run str/cli-list.w (
                    input parparentproc
                    ,input v-cntxt-host-code-obj
                    ,input v-cntxt-obj-type
                    ,input v-cntxt-obj-code
      ) .
    if not can-find(first cli-list)
    then do:
      message
      "Не выбрано ни одного контрагента"
      view-as alert-box .
      /* отмена выбора контрагента */
      return .
    end.
  end.
  else do:
    create cli-list.
  end.

  define variable v-ok as logical no-undo .
  assign
    v-ok = true
  .
  message
    "Вы хотите пересчитать Итоговые значения  по контрагентам" skip
    "Выбраны" skip
    "Фирмы:      " (if v-select-firm
                    then "код " + string(v-host-code)
                    else "ВСЕ"
                    ) skip
    "Контрагенты:" (if v-select-clients
                    then "по списку"
                    else "ВСЕ"
                    ) skip
    "Суммы оборота по контрагенту будут рассчитаны на основании складских документов" skip
    "Внимание!" skip
    "На обрезанной базе данных суммы оборота будут отражать не реальный оборот по контрагенту" skip
    "а суммарный оборот по всем документам, которые имеются в базе данных" skip
    "" skip
    "Продолжить?" skip
    view-as alert-box question buttons yes-no update v-ok .
  if v-ok <> true
  then do:
    return .
  end.

  view frame a.

  for each ub.sysconf no-lock
    where v-select-firm = false
      or ( ub.sysconf.host-code = v-host-code)
  :
    define buffer buf_clients for ub.clients .
    find buf_clients no-lock
      where buf_clients.obj-type = {&cmp}
        and buf_clients.obj-code = ub.sysconf.host-code
      .
    assign
      v-firm-name = buf_clients.obj-name
    .

    for each cli-list no-lock ,
      first ub.clients no-lock where
            v-select-clients = false
            or (ub.clients.obj-type = cli-list.obj-type
                and
                ub.clients.obj-code = cli-list.obj-code)
    :
      assign
        v-action = "Очистка ..."
      .
      /* очищается текущая информация */
      for each ub.cli-gds exclusive-lock
        where ub.cli-gds.host-code = ub.sysconf.host-code
          and ub.cli-gds.cli-type  = ub.clients.obj-type
          and ub.cli-gds.cli-code  = ub.clients.obj-code
      :
        assign
          v-ind = v-ind + 1
        .
        if v-ind modulo 10 = 0
        then do:
          display
            v-ind
            v-action
            v-firm-name
            with frame a.
        end.

        assign
          ub.cli-gds.in-code    = ""
          ub.cli-gds.price-cli  = 0
          ub.cli-gds.exch-code  = 0
          ub.cli-gds.unit-cli   = ""
          ub.cli-gds.in-rubl    = 0
          ub.cli-gds.in-base    = 0
          ub.cli-gds.in-qnty    = 0
          ub.cli-gds.out-sum    = 0
          ub.cli-gds.out-discnt = 0
          ub.cli-gds.out-qnty   = 0
          ub.cli-gds.ret-sum    = 0
          ub.cli-gds.ret-discnt = 0
          ub.cli-gds.ret-qnty   = 0
        .
      end.
    end.

    /* подготавливаем список документов */
    assign
      v-action = "Обработка документов"
      v-ind    = 0
    .

    /* все внешние документы по фирме с указанными контрагентами */
    if v-select-clients = true
    then do:
      for each buf_trn-doc no-lock
        where buf_trn-doc.host-code = ub.sysconf.host-code
          and buf_trn-doc.status_   = {&fact}
          and buf_trn-doc.internal  = no
          and buf_trn-doc.doc-type  <> {&inventory}
          and buf_trn-doc.cli-type  = ub.clients.obj-type
          and buf_trn-doc.cli-code  = ub.clients.obj-code
      use-index host-date
      :
        assign
          v-ind = v-ind + 1
        .
        if v-ind modulo 10 = 0
        then do:
          display
            v-ind
            v-action
            v-firm-name
            with frame a.
        end.

        run trg/trn-supp.p
          (input  buf_trn-doc.doc-code /* p-doc-code       */
          ,input  true                 /* p-trn-doc-close  */
          ,input  false                /* p-update-supp    */
          ,input  false                /* p-update-chk-doc */
          ) .
      end.

      /* все дисконтные карты по указанному клиенту */
      for each buf_dis-card no-lock
        where buf_dis-card.cli-type = ub.clients.obj-type
          and buf_dis-card.cli-code = ub.clients.obj-code
      on error undo, return error return-value
      :
        _buf_chk-doc:
        for each buf_shop no-lock
          where buf_shop.host-code = ub.sysconf.host-code
        ,each buf_chk-doc no-lock
          where buf_chk-doc.obj-type = {&shop}
            and buf_chk-doc.obj-code = buf_shop.obj-code
            and buf_chk-doc.d-card   = buf_dis-card.d-card
        :
          /* обновляем информацию на основании дисконтных карт */
          if lookup(string(buf_chk-doc.chk-type), {&no-d-card-receipt-codes}) > 0 then NEXT _buf_chk-doc.
          run str/trnsupds.p
            (input buf_chk-doc.doc-code /* p-doc-code      */
            ,input true                 /* p-trn-doc-close */
            ) .
        end.
      end.
    end.
    else do:
      for each buf_trn-doc no-lock
        where buf_trn-doc.host-code = ub.sysconf.host-code
          and buf_trn-doc.status_   = {&fact}
          and buf_trn-doc.internal  = no
          and buf_trn-doc.doc-type  <> {&inventory}
      use-index host-date
      :
        assign
          v-ind = v-ind + 1
        .
        if v-ind modulo 10 = 0
        then do:
          display
            v-ind
            v-action
            v-firm-name
            with frame a.
        end.

        run trg/trn-supp.p
          (input  buf_trn-doc.doc-code /* p-doc-code      */
          ,input  true                 /* p-trn-doc-close */
          ,input  false                /* p-update-supp   */
          ,input  true                 /* p-update-chk-doc */
          ) .
      end.
    end.
  end.

  message
    "Итоговые значения (приход, расход, возврат) по контрагентам" skip
    "Выбраны" skip
    "Фирмы:      " (if v-select-firm
                    then "код " + string(v-host-code)
                    else "ВСЕ"
                    ) skip
    "Контрагенты:" (if v-select-clients
                    then "по списку"
                    else "ВСЕ"
                    ) skip
    "" skip
    "Инициализация приходов, расходов, возвратов закончена успешно." skip
    view-as alert-box information .

end.