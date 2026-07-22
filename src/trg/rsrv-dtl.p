block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура резервирования товара

Автор: Чернова Светлана Александровна
Дата создания: 02/14/07
Author: Svetlana Chernova
Creation date: 02/14/07


create: Перваков Михаил Сергеевич
Дата создания: 09/16/05

p-action - параметры резервировани
  rsrv-dtl_action_reserv             - резервирование
  rsrv-dtl_action_reserv-sozdanie    - создание резервов для инвентаризации

  rsrv-dtl_no-message        - не выдавать сообщения на экран
                                за исключением вопроса об отрицательных остатках
                                (см. параметр rsrv-dtl_negative-check),
                                запроса о подтверждении цены порожденной партии
                                и сообщения при отсутствии прав
                                  создания порожденной партии


  rsrv-dtl_no-msg-create     - не выдавать сообщения на экран
                                за исключением вопроса об отрицательных остатках
                                (см. параметр rsrv-dtl_negative-check),
                                и сообщения при отсутствии прав
                                  создания порожденной партии

  rsrv-dtl_no-msg-no-chk-acta-cr
                             - не выдавать сообщения на экран
                                за исключением вопроса об отрицательных остатках
                                (см. параметр rsrv-dtl_negative-check),
                               ,не проверять права на создание порожденной партии

  rsrv-dtl_pl-code           - резервирование по складскому месту

  rsrv-dtl_copy-cst          - копировать параметры указанной партии

  rsrv-dtl_cst-code          - задать код ГТД для партии

  rsrv-dtl_ps                - задать комментарий для партии

  rsrv-dtl_dop               - задать поле dop для партии

  rsrv-dtl_contract-code     - код договора

  rsrv-dtl_rsrv-single-part  - резервировать одну партию с указанным кодом
  rsrv-dtl_rsrv-in-code        в случае указания любого из полей следует
  rsrv-dtl_rsrv-part-code      задавать одновременно все три пол

  rsrv-dtl_old-part-code     - старое значение кода партии
                               если он задан - то ищется партия с таким кодом
                               и переименовывается в партию с кодом cre-part-code

  rsrv-dtl_cre-part-code     - значение кода партии по умолчанию для создаваемых партий

  rsrv-dtl_cli-qnty          - количество по клиенту для создаваемой партии

  rsrv-dtl_hold-code-parent  - код родительского документа межфирменного перемещени
  rsrv-dtl_part-code-parent  - коди родительской партии документа межфирменного перемещени

  rsrv-dtl_negative-check    - действие в случае ухода товара в отрицательные остатки
                               При этом не задается вопрос, а производитс
                               указанное действие
                               1 - зарезервировать товар (и увести товар в отрицательные остатки)
                               2 - зарезервировать положительное количество
                               3 - отказаться от резервирования товара в случае ухода
                                   товара в отрицательные остатки

  rsrv-dtl_sale-negative-check-on - включить стандартную проверку на уход в отрицательные остатки для продажи


  rsrv-dtl_purch-code-list   - список типов приобретения .
                               если он задан, то резервируются только товары
                               обладающие типом приобретения из указанного списка

  rsrv-dtl_last-date         - дата годен до
                               используется для заполнения поля last-date
                               для вновь создаваемых партий
  rsrv-dtl_hold-date         - дата создания МФ прихода
                               используется для заполнения поля hold-date


rsrv-gds-dtl  буфер gds-dtl
  Никак не изменяется в программе r s r v - d t l . p и в других программах,
  которые вызываются из нее.
  Используется только для указания признака товара, который необходимо
  резервировать.
  Обновление записи gds-dtl должно производиться вызывающей программой
  после возвращения из r s r v - d t l . p

chg-qnty    Запрашиваемое количество

cost-base   Учетная цена в валюте

cost-rubl   Учетная цена в р_у_блях

p-b-code    b-code на партию

*/
using ibs.th.str.alcohol.*.
using ibs.th.gbl.storage.*.

define input        parameter parparentproc as widget-handle no-undo.
define input        parameter p-action      as character no-undo .
define parameter    buffer    rsrv-gds-dtl  for ub.gds-dtl .
define input-output parameter chg-qnty      as   decimal no-undo .
define input-output parameter cost-base     as   decimal no-undo .
define input-output parameter cost-rubl     as   decimal no-undo .
define input        parameter p-b-code      as   integer no-undo .
define input        parameter p-mark        as   character  no-undo .


define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Процедура резервирования товара".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7|&8|&9',p-action,rsrv-gds-dtl.artic,rsrv-gds-dtl.prod-type,rsrv-gds-dtl.prod-code,rsrv-gds-dtl.prt-code,chg-qnty,cost-base,cost-rubl,p-b-code)" }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/getsect.i  def }
{ str/lib-trn.i  }

define stream alc-rsrv .
define stream tobacco-rsrv .

{ trg/partrqst.i }
{ trg/rsrgdsck.i }
{ trg/partscr.i  }
{ str/plgdsfnd.i }
{ trg/trndocrs.i }
{ cmp/strcodec.i }
{ cmp/trg-def.i  }
{ gbl/lineattr.i }
{ ref/gds-attr.i }
{ str/is-gas.i   }
{ trg/rsrv-doc.i }
{ trg/rsrvincr.i }
{ trg/partrsrv.i }
{ str/hvrdtax.i  }
{ gbl/key-rec.i  }
{ trg/partcopy.i }
{ str/trdcalib.i }
{ trg/holdprts.i }
{ trg/partlist.i }

{ gbl/objsrv.i }
/* что резервируем: документ, товар, признак, объект */
define variable v-obj-type   like ub.gds-dtl.obj-type  no-undo .
define variable v-obj-code   like ub.gds-dtl.obj-code  no-undo .
define variable v-doc-code   like ub.gds-dtl.doc-code  no-undo .
define variable v-artic      like ub.gds-dtl.artic     no-undo .
define variable v-prod-type  like ub.gds-dtl.prod-type no-undo .
define variable v-prod-code  like ub.gds-dtl.prod-code no-undo .
define variable v-prt-code   like ub.gds-dtl.prt-code  no-undo .
define variable v-cli-qnty   like ub.doc-line.cli-qnty no-undo initial ? .
define variable v-input-qnty as decimal   no-undo . /* сколько запрашивали для резервирования */
define variable chg-cli-qnty as decimal   no-undo .

/* параметры вызова rsrv-dtl */
define variable v-option-no-message    as logical   no-undo initial false .
define variable v-partscr-prompt-price as character no-undo .
define variable v-rename-part-code     as logical   no-undo init false .
define variable v-old-part-code        as character no-undo .
define variable v-create-part-code     as character no-undo initial "" .
define variable was-created-part-code  as logical   no-undo initial ? .
define variable v-create-cst-code      as character no-undo initial "" .
define variable v-create-ps            as character no-undo init "" .
define variable v-create-dop           as character no-undo init "" .
define variable v-partsupd-action      as character no-undo initial "" .
define variable v-contract-code        as integer   no-undo .
define variable v-reserv-single-part   as logical   no-undo .
define variable v-in-code              as character no-undo .
define variable v-part-code            as character no-undo .
define variable v-pl-code              as integer   no-undo initial 0 .
define variable v-hold-code-parent     as character no-undo .
define variable v-hold-part-code       as character no-undo .
define variable v-purch-code-list      as character no-undo .
define variable v-use-partlist         as logical   no-undo .
define variable v-last-date            as date      no-undo .
define variable v-hold-date            as date      no-undo .
define variable v-negative-check       as integer   no-undo initial 0 .
define variable v-option-sale-negative-check-on as logical no-undo init false .
define variable v-error-message        as character no-undo .
define variable v-real-chg-qnty        as decimal   no-undo .
define variable v-need-rsrv            as logical no-undo .
define variable v-neg-ask as logical   no-undo .
define variable v-mark                 as logical no-undo .
do
on error undo, return error return-value
:
  /* свойства товара */
  define variable v-root-node          like ub.gds-prt.node-code no-undo .
  define variable v-goods-serial       as logical no-undo .
  define variable v-goods-twounit      as logical no-undo .
  define variable v-reserv-pl-code     as logical no-undo initial ? .
  define variable v-density            as decimal no-undo .
  define variable v-sign               as decimal no-undo .

  define buffer buf_doc-pl for ub.doc-pl .

  if (valid-handle(parparentproc) <> true)
  or lookup( "mainmenu_getcntxt", parparentproc:internal-entries ) = 0
  then do:
        assign
        v-cntxt-db-num = g#db-num
        v-cntxt-userid = g#userid
        .
  end.
  else do:
    { gbl/getcntxt.i get }
  end.

  /* проверка входных параметров */
  if not available rsrv-gds-dtl
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не задан буфер признака строки (gds-dtl)" skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  assign
    v-doc-code   = rsrv-gds-dtl.doc-code
    v-artic      = rsrv-gds-dtl.artic
    v-prod-type  = rsrv-gds-dtl.prod-type
    v-prod-code  = rsrv-gds-dtl.prod-code
    v-prt-code   = rsrv-gds-dtl.prt-code
    v-input-qnty = chg-qnty
  .

  find ub.trn-doc no-lock
    where ub.trn-doc.doc-code = v-doc-code
    no-error .
  if not available ub.trn-doc
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найден документ" skip
      "Документ" v-doc-code skip
      "Артикул" v-artic v-prod-type v-prod-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  assign
    v-obj-type  = ub.trn-doc.obj-type
    v-obj-code  = ub.trn-doc.obj-code
  .
  v-mark = yes .
  run check-input-parameters in this-procedure
    ( buffer ub.trn-doc
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке входных параметров" skip
      "Документ" v-doc-code skip
      "Артикул" v-artic v-prod-type v-prod-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  /* количество, которое было запрошено для коррекции */
  define variable first-qnty as decimal no-undo .

  find ub.goods no-lock
    where ub.goods.artic     = v-artic
      and ub.goods.prod-type = v-prod-type
      and ub.goods.prod-code = v-prod-code
    no-error .
  if not available ub.goods
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись товар" skip
      "Документ" v-doc-code skip
      "Артикул" v-artic v-prod-type v-prod-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if ub.goods.cost-calc <> {&fifo}
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Механизм расчета учетной цены товара отличается от" {&fifo} skip
      "Резервирование товара недопустимо" skip
      "Документ" v-doc-code skip
      "Артикул" v-artic v-prod-type v-prod-code skip
      "Метод расчета" ub.goods.cost-calc skip
      view-as alert-box error .
    assign
      chg-qnty = 0
    .
    undo, return error return-value .
  end.

  { gbl/gdsat.i
    ub.goods.artic
    ub.goods.prod-type
    ub.goods.prod-code
    "'serial=request':u"
    v-goods-serial
    no-error
  }
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении атрибута товара" skip
      "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
      'serial=request':u skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.


  { gbl/gdsat.i
    ub.goods.artic
    ub.goods.prod-type
    ub.goods.prod-code
    "'twounit=request':u"
    v-goods-twounit
    no-error
  }
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении атрибута товара" skip
      "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
      'twounit=request':u skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  /* Определяем корневой признак товара */
  { gbl/rootnode.i
    v-artic
    v-prod-type
    v-prod-code
    v-root-node
    no-error
  }
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении корневого признака" skip
      "Артикул" v-artic v-prod-type v-prod-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  /*
    создаются записи:
        товар на фирме
        товар на объекте
        корневой признак на объекте
  */
  { gbl/gdscr.i
    v-obj-type
    v-obj-code
    v-artic
    v-prod-type
    v-prod-code
    v-root-node
    ub.gds-obj
    ub.prt-obj
    no-error
  }
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при создании информации о товаре на фирме" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  /* проверяем целостность товара
      gds-obj совпадает с корневым prt-obj  и
      с партиями свободной зоны и зарезервированными из свободной зоны
  */
  
  if not v-mark then do:
  { gbl/gdscheck.i
    v-obj-type
    v-obj-code
    v-artic
    v-prod-type
    v-prod-code
    v-root-node
    "''"
    no-error
  }
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке целостности товара" skip
      "Объект" v-obj-type v-obj-code skip
      "Артикул" v-artic v-prod-type v-prod-code skip
      "Проверка целостности товара до резервирования" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  end.

  find ub.doc-line no-lock
    where ub.doc-line.doc-code  = v-doc-code
      and ub.doc-line.artic     = v-artic
      and ub.doc-line.prod-type = v-prod-type
      and ub.doc-line.prod-code = v-prod-code
    .

  define variable v-reserv-base as decimal no-undo initial 0 .
  define variable v-reserv-rubl as decimal no-undo initial 0 .

  /* редактирование запроса - позволяем "резервировать" любые количества */
  if ub.trn-doc.status_ = {&inquiry}
  then do:
    return .
  end.

  /* Не заполняем поля Учетная цена и цена последнего прихода */
  /* они будут заполнены при закрытии документа */
  /* Но для резервирования будем использовать учетную цену в случае
      если это внешний приход или приход по производству */
  if ub.trn-doc.doc-type = {&income}
  and (ub.trn-doc.internal = no
        or (ub.trn-doc.internal        = yes
            and ub.trn-doc.discnt-type = {&manufactured}
          )
      )
  and cost-base > 0
  and cost-rubl > 0
  then do:
    assign
      v-reserv-base = cost-base
      v-reserv-rubl = cost-rubl
    .
  end.
  else do:
    if ub.goods.gds-type <> {&gds-goods}
    then do:
      /* учетная цена услуг фиксирована и берется из информации товара на объекте */
      assign
        v-reserv-base = ub.gds-obj.price-base
        v-reserv-rubl = ub.gds-obj.price-rubl
      .
    end.
    else do:
      if  ub.gds-obj.last-base > 0
      and ub.gds-obj.last-rubl > 0
      then do:
        assign
          v-reserv-base = ub.gds-obj.last-base
          v-reserv-rubl = ub.gds-obj.last-rubl
        .
      end.
    end.
  end.

  if v-reserv-base = ?
  then do:
    assign
      v-reserv-base = 0
    .
  end.

  if v-reserv-rubl = ?
  then do:
    assign
      v-reserv-rubl = 0
    .
  end.

  /* Проверяем что штучный или серийный товар резервируется всегда на целое число */
  /* В инвентаризации разрешаем резервировать дробное количество товара
    для коррекции ошибок в базе данных */
  /* В инвентаризации необходимо проверять в интерфейсе,
    что после закрытия накладной у нас будет целое количество */
  if ub.trn-doc.ext-doc-type <> {&TDEDT_Inv}
  then do:

    /* проверяем допустимое количество для партии товара */
    { gbl/unitqnty.i
      "''"
      ub.goods.artic
      ub.goods.prod-type
      ub.goods.prod-code
      "''"
      chg-qnty
      no-error
    }
    if error-status :error
    then do:
      if v-option-no-message = false
      then do:
        message
          "Не прошел контроль количества товара" skip
          "Попробуйте ввести другое количество" skip
          "Для штучного и серийного товаров резервируемое количество должно быть целым" skip
          "Документ" v-doc-code skip
          "Артикул" v-artic v-prod-type v-prod-code skip
          ub.goods.gds-name skip
          "Запрошено количество для резервирования" chg-qnty skip
          view-as alert-box information .
      end.
      assign
        chg-qnty = 0
      .
      return .
    end.
  end.

  /* для внешнего прихода обновляем информацию в партиях */
  /* в соответствии со складским документом              */
  if  ub.trn-doc.doc-type = {&income}
  and ub.trn-doc.internal = no
  then do:
    if  v-rename-part-code = true
    and v-old-part-code <> v-create-part-code
    then do:
      run rename-part-code in this-procedure
        (input ub.doc-line.obj-type  /* p-obj-type      */
        ,input ub.doc-line.obj-code  /* p-obj-code      */
        ,input ub.doc-line.artic     /* p-artic         */
        ,input ub.doc-line.prod-type /* p-prod-type     */
        ,input ub.doc-line.prod-code /* p-prod-code     */
        ,input ub.doc-line.doc-code  /* p-in-code       */
        ,input ub.doc-line.doc-code  /* p-out-code      */
        ,input v-old-part-code       /* p-old-part-code */
        ,input v-create-part-code    /* p-new-part-code */
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры rename-part-code" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.

    run trg/partsupd.p
      (input parparentproc
      ,input ub.doc-line.doc-code  /* p-doc-code        */
      ,input ub.doc-line.obj-type  /* p-obj-type        */
      ,input ub.doc-line.obj-code  /* p-obj-code        */
      ,input ub.doc-line.artic     /* p-artic           */
      ,input ub.doc-line.prod-type /* p-prod-type       */
      ,input ub.doc-line.prod-code /* p-prod-code       */
      ,input false                 /* v-update-doc-line */
      ,input v-partsupd-action     /* p-update-parts-info */
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

  /* запрошено зарезервировать нулевое количество - ничего не делаем
  * в случае снятия резервов - продолжаем выполнение программы
  */
  if  chg-qnty = 0
  and p-action = {&rsrv-dtl_action_reserv}
  and v-goods-twounit = false
  then do:
    run cost-calc in this-procedure
      no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка расчета средней учетной цены" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    return .
  end.

  /* для всех документов, кроме "разрешен +"
    необходимо проверить, что товар не находится в инвентаризации
    (что отсутствуют документы в статусе "разрешен +"
  */

  define variable v-can-edit-inv-on as character no-undo .
  { gbl/trnat.i
    ub.trn-doc.doc-type
    ub.trn-doc.internal
    ub.trn-doc.discnt-type
    ub.trn-doc.status_
    ub.trn-doc.flag_
    ub.trn-doc.ext-doc-type
    "'can-edit-inv-on=request'"
    v-can-edit-inv-on
    no-error
  }
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Невозможно запросить признак складского документа" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if v-can-edit-inv-on <> "true":u
  then do:
    define variable v-inv-on as logical no-undo .

    /* проверяем, что можно создавать резервы для товара */
    /* это возможно, если отсутствуют документы инвентаризации */
    { gbl/gdsobjat.i
      v-obj-type
      v-obj-code
      v-artic
      v-prod-type
      v-prod-code
      "'inv-on=request'"
      v-inv-on
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Невозможно запросить признаки товара на объекте" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if v-inv-on = true
    then do:
      if v-option-no-message = false
      then do:
        message
          "Артикул" v-artic v-prod-type v-prod-code skip
          ub.goods.gds-name skip
          "сейчас находится в инвентаризации" skip
          "Редактирование резервов невозможно" skip
          view-as alert-box .
      end.
      assign
        chg-qnty = 0
      .
      return .
    end.
  end.

  /* для услуг средняя учетная цена должна быть задана */
  if ub.goods.gds-type <> {&gds-goods}
  then do:
    if  v-reserv-base > 0
    and v-reserv-rubl > 0
    then do:
      /* учетная цена определена и положительна */
      assign
        cost-base = v-reserv-base
        cost-rubl = v-reserv-rubl
      .
      return .
    end.
    else do:
      if v-option-no-message = false
      then do:
        message
          "Не определена учетная цена для услуги." skip
          "Артикул" ub.goods.artic ub.goods.gds-name skip
          "производитель" ub.goods.prod-type ub.goods.prod-code skip
          "Резервирование услуги с нулевой учетной ценой невозможно." skip
          view-as alert-box information .
      end.
      assign
        chg-qnty = 0
      .
      undo, return error "Не определена учетная цена для услуги." + {&new-line}
                        + substitute("Артикул &1 &2", ub.goods.artic, ub.goods.gds-name) + {&new-line}
                        + substitute("производитель &1 &2", ub.goods.prod-type, ub.goods.prod-code) + {&new-line}
                        + "Резервирование услуги с нулевой учетной ценой невозможно." + {&new-line}
        .
    end.
  end.

  /* здесь происходит собственно процедура резервирования */
  &scop partrqst-prefix v-total-parts-
  {&partrqst-var}

  &scop partrqst-prefix v-new-total-parts-
  {&partrqst-var}

  define variable v-free-parts-qnty       as decimal no-undo .
  define variable v-free-parts-fact-qnty  as decimal no-undo .
  define variable v-free-parts-cli-qnty   as decimal no-undo .
  define variable v-free-parts-price-base as decimal no-undo .
  define variable v-free-parts-price-rubl as decimal no-undo .
  define variable v-out-parts-qnty        as decimal no-undo .
  define variable v-out-parts-fact-qnty   as decimal no-undo .
  define variable v-out-parts-cli-qnty    as decimal no-undo .
  define variable v-out-parts-price-base  as decimal no-undo .
  define variable v-out-parts-price-rubl  as decimal no-undo .

  define variable v-new-free-parts-qnty       as decimal no-undo .
  define variable v-new-free-parts-fact-qnty  as decimal no-undo .
  define variable v-new-free-parts-cli-qnty   as decimal no-undo .
  define variable v-new-free-parts-price-base as decimal no-undo .
  define variable v-new-free-parts-price-rubl as decimal no-undo .
  define variable v-new-out-parts-qnty        as decimal no-undo .
  define variable v-new-out-parts-fact-qnty   as decimal no-undo .
  define variable v-new-out-parts-cli-qnty    as decimal no-undo .
  define variable v-new-out-parts-price-base  as decimal no-undo .
  define variable v-new-out-parts-price-rubl  as decimal no-undo .


  assign
    first-qnty = chg-qnty
  .

  define variable free-prt      as decimal no-undo .

  case p-action :
    when {&rsrv-dtl_action_reserv}
    then do:

      run partrqst in this-procedure
        (input  ub.doc-line.doc-code        /* p-doc-code               */
        ,input  ub.doc-line.obj-type        /* p-obj-type               */
        ,input  ub.doc-line.obj-code        /* p-obj-code               */
        ,input  ub.doc-line.artic           /* p-artic                  */
        ,input  ub.doc-line.prod-type       /* p-prod-type              */
        ,input  ub.doc-line.prod-code       /* p-prod-code              */
        &scop partrqst-prefix v-total-parts-
        {&partrqst-param}
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при сборе информации по партиям" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      run rsrgdsck in this-procedure
        (input  ub.doc-line.doc-code         /* p-doc-code              */
        ,input  ub.trn-doc.doc-type          /* p-doc-type              */
        ,input  ub.doc-line.obj-type         /* p-obj-type              */
        ,input  ub.doc-line.obj-code         /* p-obj-code              */
        ,input  ub.doc-line.artic            /* p-artic                 */
        ,input  ub.doc-line.prod-type        /* p-prod-type             */
        ,input  ub.doc-line.prod-code        /* p-prod-code             */
        ,output v-free-parts-qnty         /* p-free-parts-qnty       */
        ,output v-free-parts-fact-qnty    /* p-free-parts-fact-qnty  */
        ,output v-free-parts-cli-qnty     /* p-free-parts-cli-qnty   */
        ,output v-free-parts-price-base   /* p-free-parts-price-base */
        ,output v-free-parts-price-rubl   /* p-free-parts-price-rubl */
        ,output v-out-parts-qnty          /* p-out-parts-qnty        */
        ,output v-out-parts-fact-qnty     /* p-out-parts-fact-qnty   */
        ,output v-out-parts-cli-qnty      /* p-out-parts-cli-qnty    */
        ,output v-out-parts-price-base    /* p-out-parts-price-base  */
        ,output v-out-parts-price-rubl    /* p-out-parts-price-rubl  */
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при проверке зарезервированных количеств" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      if can-do({&expense_write-off}, ub.trn-doc.doc-type)
      and ub.goods.gds-type       = {&gds-goods}
      and ((ub.trn-doc.status_    = {&wayb}
            and ub.trn-doc.flag_  = no)
            or ub.trn-doc.status_ = {&cash-desk}
          )
      then do:
        /* проверка свободного количества производится в тот же момент, что и
            резервирование свободного количества.
            при редактировании по факту проверку свободного количества не производим
          */
        define variable v-need-check-free-qnty as logical no-undo .

        /* для продажи в магазине отрицательные остатки не проверяются */
        /* так как документ продажи состоит из двух документов: расход, возврат */
        /* и там реализована своя собственная проверка отрицательного количества */
        assign
          v-need-check-free-qnty = (ub.trn-doc.discnt-type <> {&cash-desk}
                                    or
                                    v-option-sale-negative-check-on
                                    )
        .


        if v-need-check-free-qnty
        then do:
          /* создаем корневой признак на объекте */
          { gbl/prtobjcr.i
            v-obj-type
            v-obj-code
            v-artic
            v-prod-type
            v-prod-code
            v-prt-code
            ub.prt-obj
            no-error
          }
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Невозможно найти признак на объекте" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            free-prt = ub.prt-obj.free-qnty
          .

          /* определяем количество, которое может быть зарезервировано по партиям */
          /* резервирование по признакам будет произведено только один раз */
          /* после резервирования по партиям */
          /* сравниваем свободное количество */
          /* ??? это условие надо пересмотреть в случае резервирования по инвентаризации */
          if free-prt < first-qnty
          then do:
            define variable v-action as integer no-undo .

            if first-qnty > 0
            then do:
              assign
                v-action = 3 /* отказ от резервирования */
              .
            end.
            else do:
              assign
                v-action = 1 /* позволяем резервировать */
              .
            end.

            define variable v-can-fix        as logical no-undo .
            define variable v-fix-first-qnty as decimal no-undo .

            assign
              v-can-fix        = false
              v-fix-first-qnty = 0
            .

            if  free-prt < 0
            and v-total-parts-fact-qnty > abs(free-prt)
            then do:
              assign
                v-action         = 2 /* резервируем такое количество */
                                     /* чтобы после резервирования были неотрицательные остатки */
                v-can-fix        = true
                v-fix-first-qnty = free-prt
              .
            end.

            if  free-prt   >= 0
            and first-qnty >= 0
            then do:
              assign
                v-action         = 2 /* резервируем такое количество */
                                     /* чтобы после резервирования были неотрицательные остатки */
                v-can-fix        = true
                v-fix-first-qnty = min(free-prt, first-qnty)
              .
            end.

            if ub.goods.negative-rest = true
            then do:
              if v-negative-check = 0
              then do:
                run gbl/d-askw.w
                  (input  "Проверка отрицательных остатков"
                  ,input  "Артикул " + string(ub.goods.artic) + " "
                            + string(ub.goods.prod-type) + " " + string(ub.goods.prod-code) + {&new-line}
                          + string(ub.goods.gds-name) + {&new-line}
                          + "Свободно " + string(free-prt) + {&new-line}
                          + "После резервирования товар уйдет в отрицательные остатки" + {&new-line}
                          + substitute("Объект &1 &2", v-obj-type, v-obj-code) + {&new-line}
                  ,input "|^"
                  ,input  "Резерв" + "|"
                          + "Положительное"
                            + (if v-can-fix then "" else "^disable") + "|"
                          + "Отмена"
                  ,input  "Зарезервировать " + string(first-qnty) + {&new-line}
                            + "После резервирования:" + {&new-line}
                            + " Свободное количество составит "
                            + string(free-prt - first-qnty) + {&new-line}
                            + " Количество по документу составит "
                            + string(v-total-parts-fact-qnty + first-qnty)
                            + "|"
                          + (if v-can-fix then
                              "Зарезервировать " + string(v-fix-first-qnty) + {&new-line}
                              + "После резервирования:" + {&new-line}
                              + "Свободное количество составит "
                              + string(free-prt - v-fix-first-qnty) + {&new-line}
                              + "Количество по документу составит "
                              + string(v-total-parts-fact-qnty + v-fix-first-qnty)
                              else "Даже если удалить строчку документа" + {&new-line}
                                  + "свободное количество будет отрицательным" ) + "|"
                          + "Отмена резервирования" + {&new-line}
                            + "Свободное количество составит "
                            + string(free-prt) + {&new-line}
                            + "Количество по документу составит "
                            + string(v-total-parts-fact-qnty)
                  ,input 2
                  ,input 3
                  ,output v-action
                  ).
              end.
              else do:
                case v-negative-check
                :
                  when 1
                  then do:
                    assign
                      v-action = 1
                    .
                  end.
                  when 2
                  then do:
                    if v-can-fix = true
                    then do:
                      assign
                        v-action = 2
                      .
                    end.
                    else do:
                      assign
                        v-action = 3
                      .
                    end.
                  end.
                  when 3
                  then do:
                    assign
                      v-action = 3
                    .
                  end.
                  otherwise do:
                    message
                      vss-workfile vss-revision vss-description skip
                      "Внутренняя ошибка" skip
                      "Неизвестное значение v-negative-check" v-negative-check skip
                      view-as alert-box error .
                    undo, return error return-value .
                  end.
                end.
              end.
            end.
            else do:
              if v-action = 2 and first-qnty <> v-fix-first-qnty then do:
                  { gbl/getsect.i run ub.trn-doc.obj-type ub.trn-doc.obj-code {&attr-nakl_par} }
                      for each thbjattr_thbj-attr :
                          if thbjattr_thbj-attr.prop-code = 'neg-ask' then v-neg-ask = thbjattr_thbj-attr.property-value-logical .
                      end.
                  if v-neg-ask = true then do:
                     message "По товару запрещены отрицательные остатки, "  Skip
                     "нельзя зарезирвировать полностью указанное количество!"
                     view-as alert-box information .
                  end.
              end.
            end.

            case v-action :
              when 1
              then do:
                /* не корректировать запрошенное количество */
                /* пользователь действительно хочет зарезервировать */
              end.

              when 2
              then do:
                /* откорректировать количество для резервирования */
                assign
                  first-qnty = v-fix-first-qnty
                .
              end.

              when 3
              then do:
                /* отказаться от резервирования */
                assign
                  first-qnty = 0
                .
              end.

              otherwise do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Неизвестное значение переменной v-action" v-action skip
                  view-as alert-box error .
                undo, return error return-value .
              end.
            end case .
          end.
        end.
      end.

      assign
        chg-qnty = first-qnty
      .

      define variable v-rsrv-type as character no-undo .
      /* определяем тип резервирования */
      { gbl/rsrvtype.i
        ub.trn-doc.doc-code
        v-rsrv-type
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении типа резервирования" skip
          "Документ" ub.trn-doc.doc-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      /* производим резервирование */
      case v-rsrv-type :
        when {&rsrvtype_pri-doc}
        then do:
          run rsrv-pri-doc in this-procedure
            no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при вызове процедуры rsrv-pri-doc" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end.
        when {&rsrvtype_pri-fact}
        then do:
          run rsrv-pri-fact in this-procedure
            no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при вызове процедуры rsrv-pri-fact" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end.
        when {&rsrvtype_doc}
        then do:
          if v-reserv-pl-code = ?
          then do:
            run plgdsfnd in this-procedure
              (input  true              /* p-chk-and-chs    */
              ,input  v-obj-type        /* p-obj-type       */
              ,input  v-obj-code        /* p-obj-code       */
              ,input  ub.goods.gds-code /* p-gds-code       */
              ,output v-reserv-pl-code  /* p-reserv-pl-code */
              ,output v-pl-code         /* p-pl-code        */
              ) no-error .
            if error-status :error
            then do:
              if error-status :get-message(1) <> ""
              or v-option-no-message = false
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Ошибка при вызове процедуры plgdsfnd" skip
                  error-status :get-message(1) skip
                  return-value skip
                  view-as alert-box error .
              end.
              undo, return error return-value .
            end.
          end.

          run rsrv-doc in this-procedure
            (input  parparentproc
            ,input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  recid(ub.trn-doc)       /* p-trn-doc-recid       */
            ,input  recid(ub.doc-line)      /* p-doc-line-recid      */
            ,input  v-reserv-base           /* p-reserv-base         */
            ,input  v-reserv-rubl           /* p-reserv-rubl         */
            ,input  v-partscr-prompt-price  /* p-partscr-promt-price */
            ,input  ub.trn-doc.ext-doc-type /* p-extended-doc-type   */
            ,input  v-reserv-single-part    /* p-reserv-single-part  */
            ,input  v-in-code               /* p-in-code             */
            ,input  v-part-code             /* p-part-code           */
            ,input  v-reserv-pl-code        /* p-reserv-pl-code      */
            ,input  v-pl-code               /* p-pl-code             */
            ,input  v-goods-serial          /* p-goods-serial        */
            ,input  v-goods-twounit         /* p-goods-twounit       */
            ,input  v-purch-code-list       /* p-purch-code-list     */
            ,input  chg-qnty                /* p-chg-qnty            */
            ,input  (ub.trn-doc.doc-type = {&inventory}) /* p-unreserv-other-sign */
            ,output v-real-chg-qnty         /* p-real-chg-qnty       */
            ) no-error .
          if error-status :error
          then do:
            if error-status :get-message(1) <> ""
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры rsrv-doc" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
            end.
            undo, return error return-value .
          end.
          assign
            v-error-message = return-value
          .
        end.
        when {&rsrvtype_fact}
        then do:
          run rsrv-fact in this-procedure
            no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при вызове процедуры rsrv-fact" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестное значение метода резервирования" skip
            "v-rsrv-type" v-rsrv-type skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end case . /* v-rsrv-type */


      run partrqst in this-procedure
        (input  ub.doc-line.doc-code         /* p-doc-code               */
        ,input  ub.doc-line.obj-type         /* p-obj-type               */
        ,input  ub.doc-line.obj-code         /* p-obj-code               */
        ,input  ub.doc-line.artic            /* p-artic                  */
        ,input  ub.doc-line.prod-type        /* p-prod-type              */
        ,input  ub.doc-line.prod-code        /* p-prod-code              */
        &scop partrqst-prefix v-new-total-parts-
        {&partrqst-param}
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при сборе информации по партиям" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      assign
        chg-qnty = v-new-total-parts-fact-qnty - v-total-parts-fact-qnty
      .

      if chg-qnty <> first-qnty
      and v-option-no-message = false
      then do:
        assign
          v-error-message = substitute( "Артикул: &1 (&2)&3", ub.goods.artic, ub.goods.gds-name, {&new-line} )
                            + substitute( "производитель: &1 &2&3", ub.goods.prod-type, ub.goods.prod-code, {&new-line} )
                            + substitute( "баркод: &1 &2 ", p-b-code, {&new-line} )
                            + (if v-pl-code <> ? and v-pl-code <> 0 then substitute( "Место хранения: &1&2", v-pl-code, {&new-line} ) else "" )
                            + substitute( "&2Количество &1 недоступно.&2", first-qnty, {&new-line} )
                            + substitute( "Удалось зарезервировать &1.&2&2", chg-qnty, {&new-line} )
                            + substitute( "&1", v-error-message )
        .
        message
          v-error-message skip
          view-as alert-box information .
      end.

      run trndocrs-need-rsrv in this-procedure
        (input  ub.trn-doc.doc-type   /* p-doc-type     */
        ,input  ub.doc-line.artic     /* p-artic        */
        ,input  ub.doc-line.prod-type /* p-prod-type    */
        ,input  ub.doc-line.prod-code /* p-prod-code    */
        ,output v-need-rsrv           /* p-need-rsrv    */
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры trndocrs-need-rsrv" skip
          "Документ" ub.trn-doc.doc-type skip
          "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      if  v-need-rsrv
      and ((ub.trn-doc.status_    = {&wayb}
            and ub.trn-doc.flag_  = no)
            or ub.trn-doc.status_ = {&cash-desk}
          )
      then do:
        /* получаем новые зарезервированные количества */
        run rsrgdsck in this-procedure
          (input  ub.doc-line.doc-code             /* p-doc-code              */
          ,input  ub.trn-doc.doc-type              /* p-doc-type              */
          ,input  ub.doc-line.obj-type             /* p-obj-type              */
          ,input  ub.doc-line.obj-code             /* p-obj-code              */
          ,input  ub.doc-line.artic                /* p-artic                 */
          ,input  ub.doc-line.prod-type            /* p-prod-type             */
          ,input  ub.doc-line.prod-code            /* p-prod-code             */
          ,output v-new-free-parts-qnty         /* p-free-parts-qnty       */
          ,output v-new-free-parts-fact-qnty    /* p-free-parts-fact-qnty  */
          ,output v-new-free-parts-cli-qnty     /* p-free-parts-cli-qnty   */
          ,output v-new-free-parts-price-base   /* p-free-parts-price-base */
          ,output v-new-free-parts-price-rubl   /* p-free-parts-price-rubl */
          ,output v-new-out-parts-qnty          /* p-out-parts-qnty        */
          ,output v-new-out-parts-fact-qnty     /* p-out-parts-fact-qnty   */
          ,output v-new-out-parts-cli-qnty      /* p-out-parts-cli-qnty    */
          ,output v-new-out-parts-price-base    /* p-out-parts-price-base  */
          ,output v-new-out-parts-price-rubl    /* p-out-parts-price-rubl  */
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при проверке зарезервированных количеств" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.

        /* узнаем, сколько было зарезервировано из свободной зоны */
        assign
          chg-qnty = (v-new-free-parts-qnty - v-free-parts-qnty )
        .

        run trndocrs-clear in this-procedure
          .

        run trndocrs-gds-dtl-accum in this-procedure
          (input v-prt-code
          ,input chg-qnty
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при изменении зарезервированных количеств trndocrs-gds-dtl-accum" skip
            "Документ ub.trn-doc.doc-code: " ub.trn-doc.doc-code skip
            "Артикул" ub.goods.artic ub.goods.gds-name skip
            "производитель" ub.goods.prod-type ub.goods.prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          assign
            chg-qnty = 0
          .
          undo, return error return-value .
        end.

        if v-reserv-pl-code = true then do:
          find first buf_doc-pl
            where buf_doc-pl.obj-type = ub.doc-line.obj-type
              and buf_doc-pl.obj-code = ub.doc-line.obj-code
              and buf_doc-pl.pl-code  = v-pl-code
              and buf_doc-pl.out-code = ub.doc-line.doc-code
              and buf_doc-pl.gds-code = ub.goods.gds-code
            no-error .
          if not available buf_doc-pl then do:
            message
              vss-workfile vss-revision vss-description skip
              "В документе отсутствует место хранения." skip
              "Документ ub.trn-doc.doc-code: " ub.trn-doc.doc-code skip
              "Артикул" ub.goods.artic ub.goods.gds-name skip
              "производитель" ub.goods.prod-type ub.goods.prod-code skip
              "место хранения" v-pl-code
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            assign
              chg-qnty = 0
            .
            undo, return error return-value .
          end.

          if absolute( buf_doc-pl.doc-qnty ) <> absolute( v-input-qnty ) and not is-gas(ub.goods.gds-code) then do:
            /* резервировать можно только полное кол-во по doc-pl, никакого дорезервирования */
            message
              "Артикул" ub.goods.artic ub.goods.gds-name skip
              "производитель" ub.goods.prod-type ub.goods.prod-code skip
              "Резервировать можно только полное кол-во по doc-pl." skip
              "Дорезервирование не допускается!" skip
              view-as alert-box error .
            assign
              chg-qnty = 0
            .
            undo, return error return-value .
          end.

          if chg-qnty <> v-input-qnty then do:
            /* пока ставим так, что по местам хранения можно резервировать либо все, либо ничего */
            /* т.к. нет возможности узнать кол-во кг при частичном резервировании */
            if v-option-no-message = false then do:
              message
                "Артикул" ub.goods.artic ub.goods.gds-name skip
                "производитель" ub.goods.prod-type ub.goods.prod-code skip
                "Количество " v-input-qnty " недоступно." skip
                view-as alert-box error .
            end.
            assign
              chg-qnty = 0
            .
            undo, return error return-value .
          end.

          if ub.trn-doc.doc-type = {&inventory} then do:
            assign
              chg-cli-qnty = buf_doc-pl.cli-doc-qnty * buf_doc-pl.doc-qnty / v-input-qnty
            .
          end.
          else do:
/*            if lookup( ub.doc-line.ext-doc-type, {&TDEDT_out_list} ) > 0 then do:*/
/*              assign*/
/*                v-sign = -1.0*/
/*              .*/
/*            end.*/
/*            else do:*/
/*              /* оставляем все как есть */*/
/*              assign*/
/*                v-sign = 1.0*/
/*              .*/
/*              if lookup( ub.doc-line.ext-doc-type, {&TDEDT_in_list} ) = 0 then do:*/
/*                undo, return error substitute( '&1. Тип "&2" не внесен в списки документов уменьшающих(увеличивающих) остатки!', vss-workfile, ub.doc-line.ext-doc-type).*/
/*              end.*/
/*            end.*/

            assign
              chg-cli-qnty = buf_doc-pl.cli-doc-qnty /* * v-sign */ * absolute(v-input-qnty) / v-input-qnty
            .
          end.

/*          if v-input-qnty <> chg-qnty*/
/*            and v-input-qnty <> 0.0*/
/*          then do:*/
/*            assign*/
/*              v-chg-cli-qnty = v-chg-cli-qnty * chg-qnty / v-input-qnty*/
/*            .*/
/*          end.*/

          run trndocrs-pl-gds-accum in this-procedure
            ( input v-pl-code
             ,input chg-qnty
             ,input chg-cli-qnty
             ,input 0.0
             ,input 0.0
            ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при изменении зарезервированных количеств trndocrs-pl-gds-accum" skip
              "Документ ub.trn-doc.doc-code: " ub.trn-doc.doc-code skip
              "Артикул" ub.goods.artic ub.goods.gds-name skip
              "производитель" ub.goods.prod-type ub.goods.prod-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            assign
              chg-qnty = 0
            .
            undo, return error return-value .
          end.
        end.

        run trndocrs in this-procedure
          (input ub.doc-line.doc-code
          ,input ub.doc-line.obj-type
          ,input ub.doc-line.obj-code
          ,input ub.doc-line.artic
          ,input ub.doc-line.prod-type
          ,input ub.doc-line.prod-code
          ,input chg-qnty
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при изменении зарезервированных количеств trndocrs" skip
            "Документ ub.trn-doc.doc-code: " ub.trn-doc.doc-code skip
            "Артикул" ub.goods.artic ub.goods.gds-name skip
            "производитель" ub.goods.prod-type ub.goods.prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          assign
            chg-qnty = 0
          .
          undo, return error return-value .
        end.
      end.
    end.
    when {&rsrv-dtl_action_reserv-sozdanie}
    then do:
      if ub.trn-doc.doc-type <> {&inventory}
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Создание резервов компенсации отрицательных партий возможно только для документа инвентаризации." skip
          "Документ ub.trn-doc.doc-code: " ub.trn-doc.doc-code skip
          "Тип документа ub.trn-doc.doc-type:" ub.trn-doc.doc-type skip
          "Действие p-action:" p-action skip
          view-as alert-box .
        assign
          chg-qnty = 0
        .
        undo, return error return-value .
      end.
      assign
        chg-qnty = 0
      .
      define variable v-abs-reserv-qnty as decimal no-undo .

      { gbl/gdsobjat.i
        v-obj-type
        v-obj-code
        v-artic
        v-prod-type
        v-prod-code
        "'place-rsrv=request'"
        v-reserv-pl-code
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении атрибута на объекта" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      run rsrvincr in this-procedure
        (input  parparentproc
        ,input  v-cntxt-db-num
        ,input  v-cntxt-userid
        ,input  recid(ub.trn-doc)      /* p-trn-doc-recid        */
        ,input  recid(ub.doc-line)     /* p-doc-line-recid       */
        ,input  v-reserv-base          /* p-reserv-base          */
        ,input  v-reserv-rubl          /* p-reserv-rubl          */
        ,input  v-partscr-prompt-price /* p-partscr-prompt-price */
        ,input  ub.trn-doc.ext-doc-type /* p-extended-doc-type    */
        ,input  v-reserv-single-part   /* p-reserv-single-part   */
        ,input  v-in-code              /* p-in-code              */
        ,input  v-part-code            /* p-part-code            */
        ,input  v-reserv-pl-code       /* p-reserv-pl-code       */
        ,input  v-pl-code              /* p-pl-code              */
        ,input  v-goods-serial         /* p-goods-serial         */
        ,input  v-goods-twounit        /* p-goods-twounit        */
        ,output v-abs-reserv-qnty      /* p-abs-rsrv-qnty        */
        ) no-error.
      if error-status :error
      then do:
        undo, return error return-value .
      end.
      assign
        chg-qnty = v-abs-reserv-qnty
      .
    end.
  end.

  /* удаляем партии с нулевыми количествами */
  run delete-empty-parts in this-procedure .

  /* для внешнего прихода обновляем информацию в партиях */
  /* в соответствии со складским документом              */
  if  ub.trn-doc.doc-type = {&income}
  and ub.trn-doc.internal = no
  then do:
    run trg/partsupd.p
      (input parparentproc
      ,input ub.doc-line.doc-code  /* p-doc-code        */
      ,input ub.doc-line.obj-type  /* p-obj-type        */
      ,input ub.doc-line.obj-code  /* p-obj-code        */
      ,input ub.doc-line.artic     /* p-artic           */
      ,input ub.doc-line.prod-type /* p-prod-type       */
      ,input ub.doc-line.prod-code /* p-prod-code       */
      ,input false                 /* v-update-doc-line */
      ,input v-partsupd-action     /* p-update-parts-info */
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

  /* вычисляем новую среднюю учетную цену */
  run cost-calc in this-procedure .

  /* проверяем целостность товара
      gds-obj совпадает с корневым prt-obj  и
      с партиями свободной зоны и зарезервированными из свободной зоны
  */
  { gbl/gdscheck.i
    v-obj-type
    v-obj-code
    v-artic
    v-prod-type
    v-prod-code
    v-root-node
    "''"
    no-error
  }
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке целостности товара" skip
      "Объект" v-obj-type v-obj-code skip
      "Артикул" v-artic v-prod-type v-prod-code skip
      "Проверка целостности товара после резервирования" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end.


procedure rename-part-code :

  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define input  parameter p-artic         as character no-undo .
  define input  parameter p-prod-type     as character no-undo .
  define input  parameter p-prod-code     as integer   no-undo .
  define input  parameter p-in-code       as character no-undo .
  define input  parameter p-out-code      as character no-undo .
  define input  parameter p-old-part-code as character no-undo .
  define input  parameter p-new-part-code as character no-undo .

  define buffer buf_new_parts for ub.parts .
  define buffer buf_old_parts for ub.parts .

  do
  on error undo, return error return-value
  :
    /* проверяем, что партии с новым кодом нет */
    find first buf_new_parts
      where buf_new_parts.obj-type   = p-obj-type
        and buf_new_parts.obj-code   = p-obj-code
        and buf_new_parts.artic      = p-artic
        and buf_new_parts.prod-type  = p-prod-type
        and buf_new_parts.prod-code  = p-prod-code
        and buf_new_parts.in-code    = p-in-code
        and buf_new_parts.out-code   = p-out-code
        and buf_new_parts.part-code  = p-new-part-code
      no-error .
    if available buf_new_parts
    then do:
      undo, return error substitute("Уже существует партия с кодом &1"
                                   ,p-new-part-code
                                   )
        .
    end.

    find first buf_old_parts
      where buf_old_parts.obj-type   = p-obj-type
        and buf_old_parts.obj-code   = p-obj-code
        and buf_old_parts.artic      = p-artic
        and buf_old_parts.prod-type  = p-prod-type
        and buf_old_parts.prod-code  = p-prod-code
        and buf_old_parts.in-code    = p-in-code
        and buf_old_parts.out-code   = p-out-code
        and buf_old_parts.part-code  = p-old-part-code
      no-error .
    if not available buf_old_parts
    then do:
      undo, return error substitute("Не найдена партия с кодом &1"
                                   ,p-old-part-code
                                   )
        .
    end.

    assign
      buf_old_parts.part-code = p-new-part-code
    .
  end.

end procedure. /* rename-part-code */


procedure delete-empty-parts :

  define buffer buf_parts        for ub.parts .
  define buffer buf_free-parts   for ub.parts .
  define buffer buf_output-parts for ub.parts .

  do
  on error undo, return error return-value
  :
    /* все партии с нулевыми количествами должны быть удалены */
    /* делаем это единственный раз после резервирования */
    for each buf_parts
      where buf_parts.obj-type  = ub.doc-line.obj-type
        and buf_parts.obj-code  = ub.doc-line.obj-code
        and buf_parts.artic     = ub.doc-line.artic
        and buf_parts.prod-type = ub.doc-line.prod-type
        and buf_parts.prod-code = ub.doc-line.prod-code
        and buf_parts.out-code  = ub.doc-line.doc-code
    on error undo, return error return-value
    :
      find first buf_free-parts
        where buf_free-parts.obj-type   = buf_parts.obj-type
          and buf_free-parts.obj-code   = buf_parts.obj-code
          and buf_free-parts.artic      = buf_parts.artic
          and buf_free-parts.prod-type  = buf_parts.prod-type
          and buf_free-parts.prod-code  = buf_parts.prod-code
          and buf_free-parts.in-code    = buf_parts.in-code
          and buf_free-parts.out-code   = {&free-code}
          and buf_free-parts.part-code  = buf_parts.part-code
        no-error .

      find first buf_output-parts
        where buf_output-parts.obj-type   = buf_parts.obj-type
          and buf_output-parts.obj-code   = buf_parts.obj-code
          and buf_output-parts.artic      = buf_parts.artic
          and buf_output-parts.prod-type  = buf_parts.prod-type
          and buf_output-parts.prod-code  = buf_parts.prod-code
          and buf_output-parts.in-code    = buf_parts.in-code
          and buf_output-parts.out-code   = {&output-code}
          and buf_output-parts.part-code  = buf_parts.part-code
        no-error .

      if  available buf_free-parts
      and buf_free-parts.qnty      = 0
      and buf_free-parts.fact-qnty = 0
      then do:
        delete buf_free-parts .
      end.

      if available buf_output-parts
      and buf_output-parts.qnty      = 0
      and buf_output-parts.fact-qnty = 0
      then do:
        delete buf_output-parts .
      end.

      if  buf_parts.qnty        = 0
      and buf_parts.fact-qnty   = 0
      then do:
        delete buf_parts .
      end.
    end.
  end.

end procedure. /* delete-empty-parts */


procedure rsrv-pri-doc :

  define variable v-vat-type as character no-undo .
  define variable v-vat-pc   as decimal   no-undo .
  define variable v-slt-type as character no-undo .
  define variable v-slt-pc   as decimal   no-undo .
  define variable out-rest   as decimal   no-undo .

  do
  on error undo, return error return-value
  :
    if v-goods-serial = true
    then do:
      return .
    end.

    /* производим перерезервирование */
    if (chg-qnty > 0
    or v-goods-twounit = true)
    and not is-gas(ub.goods.gds-code)
    then do:
      if v-goods-twounit = true
      then do:
        if v-cli-qnty = ?
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка задания входных параметров" skip
            "Для ювелирных изделий необходимо задать клиентское количество" skip
            "Документ" v-doc-code skip
            "Артикул" v-artic v-prod-type v-prod-code skip
            "v-cli-qnty" v-cli-qnty skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.

      run partscr_get-default-values in this-procedure
        (buffer ub.doc-line /* buf_doc-line */
        ,output v-vat-type  /* p-vat-type   */
        ,output v-vat-pc    /* p-vat-pc     */
        ,output v-slt-type  /* p-slt-type   */
        ,output v-slt-pc    /* p-slt-pc     */
        ) .
      if v-vat-type = {&without-VAT} then
      assign
        ub.doc-line.vat-pc = 0
        v-vat-pc = 0
      .
      if v-slt-type = {&without-SLT} then
      assign
        ub.doc-line.slt-pc = 0
        v-slt-pc = 0
      .

      run partscr in this-procedure
        (input  parparentproc
        ,input  v-cntxt-db-num
        ,input  v-cntxt-userid
        ,input  { trg/partsprm.i "supp-type" "ub.trn-doc." } /* p-supp-type        */
        ,input  { trg/partsprm.i "supp-code" "ub.trn-doc." } /* p-supp-code        */
        ,input  v-create-part-code     /* p-part-code        */
        ,input  v-create-cst-code      /* p-cst-code         */
        ,input  v-create-ps            /* p-ps               */
        ,input  v-create-dop           /* p-dop              */
        ,input  v-reserv-base          /* v-part-reserv-base */
        ,input  v-reserv-rubl          /* v-part-reserv-rubl */
        ,input  v-vat-type             /* p-vat-type         */
        ,input  v-vat-pc               /* p-vat-pc           */
        ,input  v-slt-type             /* p-slt-type         */
        ,input  v-slt-pc               /* p-slt-pc           */
        ,input  chg-qnty               /* chg-qnty           */
        ,input  v-partscr-prompt-price /* p-prompt-price     */
        ,input  v-cli-qnty             /* p-cli-qnty         */
        ,input  v-last-date            /* p-last-date        */
        ,input  v-hold-date            /* p-hold-date        */
        ,input  v-pl-code              /* p-pl-code          */
        ,buffer ub.doc-line            /* buf_doc-line       */
        ,buffer ub.parts               /* buf_parts          */
        ) no-error .
      if error-status :error
      then do:
        if error-status :get-message(1) <> ""
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при создании партии" skip
            "Документ" ub.doc-line.doc-code skip
            "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        end.
        undo, return error return-value .
      end.

      if v-hold-code-parent <> ""
      then do:
        /* это документ перемещения между фирмами */
        run holdprts-create-parts-supp in this-procedure
          (input v-hold-code-parent
          ,input v-hold-part-code
          ,input ub.parts.in-code
          ,input ub.parts.artic
          ,input ub.parts.prod-type
          ,input ub.parts.prod-code
          ,input ub.parts.part-code
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при копировании атрибутов партии" skip
            "Документ" ub.doc-line.doc-code skip
            "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
    end.
    else do:
      if was-created-part-code = yes then do:
        find first ub.parts
             where ub.parts.obj-type  = ub.doc-line.obj-type
               and ub.parts.obj-code  = ub.doc-line.obj-code
               and ub.parts.artic     = ub.doc-line.artic
               and ub.parts.prod-type = ub.doc-line.prod-type
               and ub.parts.prod-code = ub.doc-line.prod-code
               and ub.parts.in-code   = ub.doc-line.doc-code
               and ub.parts.out-code  = ub.doc-line.doc-code
               and ub.parts.part-code = v-create-part-code    no-error.
        if available ub.parts then do:
          assign
            out-rest = abs( chg-qnty )
          .
          if ub.parts.qnty      >= abs( chg-qnty ) and
             ub.parts.fact-qnty >= abs( chg-qnty ) then do:
            assign
              ub.parts.qnty      = ub.parts.qnty - out-rest
              ub.parts.fact-qnty = ub.parts.qnty
              chg-qnty           = chg-qnty      + out-rest
            .
            { gbl/qntycalc.i
              "'cli-qnty'"
              ub.parts.cli-base-rate
              ub.parts.cli-qnty
              ub.parts.qnty
              ub.parts.cli-qnty
              ub.parts.qnty
              no-error
            }
            if error-status :error
            then do:
              message
                "Невозможно пересчитать количество по ТТН" skip
                "Документ" ub.parts.out-code skip
                "Артикул" ub.parts.artic ub.parts.prod-type ub.parts.prod-code skip
                "Партия" ub.parts.part-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error return-value .
            end.
          end. /* ub.parts.fact-qnty >= abs( chg-qnty ) */
          else do:
            message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
                    "Невозможно выполнить резервирование по партии" skip( 0 )
                    "Объект" ub.parts.obj-type ub.parts.obj-code skip( 0 )
                    "Документ" ub.parts.out-code skip( 0 )
                    "Артикул" ub.parts.artic ub.parts.prod-type ub.parts.prod-code skip( 0 )
                    "Партия" ub.parts.part-code "  (" ub.parts.in-code ")" skip( 0 )
                    "Запрошенное количество для резервирования:" chg-qnty skip( 0 )
                    "Количество товара в партии:" ub.parts.fact-qnty skip( 1 )
            view-as alert-box error .
            undo, return error return-value .
          end.
        end. /* if available ub.parts */
      end. /* if was-created-part-code = yes */
      if abs( chg-qnty ) > 0 then do:
        for each ub.parts
          where ub.parts.obj-type  = ub.doc-line.obj-type
            and ub.parts.obj-code  = ub.doc-line.obj-code
            and ub.parts.artic     = ub.doc-line.artic
            and ub.parts.prod-type = ub.doc-line.prod-type
            and ub.parts.prod-code = ub.doc-line.prod-code
            and ub.parts.in-code   = ub.doc-line.doc-code
            and ub.parts.out-code  = ub.doc-line.doc-code
        on error undo, return error return-value
        :
          assign
            out-rest = min(ub.parts.qnty, abs(chg-qnty) )
          .
          assign
            ub.parts.qnty      = ub.parts.qnty - out-rest
            ub.parts.fact-qnty = ub.parts.qnty
            chg-qnty           = chg-qnty      + out-rest
          .

          { gbl/qntycalc.i
            "'cli-qnty'"
            ub.parts.cli-base-rate
            ub.parts.cli-qnty
            ub.parts.qnty
            ub.parts.cli-qnty
            ub.parts.qnty
            no-error
          }
          if error-status :error
          then do:
            message
              "Невозможно пересчитать количество по ТТН" skip
              "Документ" ub.parts.out-code skip
              "Артикул" ub.parts.artic ub.parts.prod-type ub.parts.prod-code skip
              "Партия" + string(ub.parts.part-code) skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.

          if chg-qnty = 0
          then do:
            leave. /* --->>>--- */
          end.
        end. /* for each ub.parts */
      end. /* if abs( chg-qnty ) > 0 */
    end.
  end. /* on error */

end procedure. /* rsrv-pri-doc */


procedure rsrv-pri-fact :

  define variable v-vat-type as character no-undo .
  define variable v-vat-pc   as decimal   no-undo .
  define variable v-slt-type as character no-undo .
  define variable v-slt-pc   as decimal   no-undo .
  define variable out-rest   as decimal   no-undo .

  do
  on error undo, return error return-value
  :

    if chg-qnty = 0
    then do:
      return.
    end.

    if v-goods-serial = true
    then do:
      return .
    end.

    if v-goods-twounit = true
    then do:
      /* позволяем менять фактическое количество в ноль */
    end.

    if chg-qnty > 0
    then do:
      for each ub.parts
        where ub.parts.obj-type  = ub.doc-line.obj-type
          and ub.parts.obj-code  = ub.doc-line.obj-code
          and ub.parts.artic     = ub.doc-line.artic
          and ub.parts.prod-type = ub.doc-line.prod-type
          and ub.parts.prod-code = ub.doc-line.prod-code
          and ub.parts.in-code   = ub.doc-line.doc-code
          and ub.parts.out-code  = ub.doc-line.doc-code
          and ub.parts.fact-qnty < ub.parts.qnty
      on error undo, return error return-value
      :
        if  v-reserv-pl-code = yes
        and v-pl-code <> ?
        and v-pl-code <> 0
        and v-pl-code <> ub.parts.pl-code
        then do:
          next .
        end.
        assign
          out-rest = min(ub.parts.qnty - ub.parts.fact-qnty, abs(chg-qnty))
        .
        assign
          ub.parts.fact-qnty = ub.parts.fact-qnty + out-rest
          chg-qnty           = chg-qnty           - out-rest
        .
        if chg-qnty = 0
        then do:
          leave.
        end.
      end.
      

      if chg-qnty > 0
      and not is-gas(ub.goods.gds-code)
      then do:
        run partscr_get-default-values in this-procedure
          (buffer ub.doc-line /* buf_doc-line */
          ,output v-vat-type  /* p-vat-type   */
          ,output v-vat-pc    /* p-vat-pc     */
          ,output v-slt-type  /* p-slt-type   */
          ,output v-slt-pc    /* p-slt-pc     */
          ) .
        run partscr in this-procedure
          (input  parparentproc
          ,input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  { trg/partsprm.i "supp-type" "ub.trn-doc." } /* p-supp-type        */
          ,input  { trg/partsprm.i "supp-code" "ub.trn-doc." } /* p-supp-code        */
          ,input  v-create-part-code     /* p-part-code        */
          ,input  v-create-cst-code      /* p-cst-code         */
          ,input  v-create-ps            /* p-ps               */
          ,input  v-create-dop           /* p-dop              */
          ,input  v-reserv-base          /* v-part-reserv-base */
          ,input  v-reserv-rubl          /* v-part-reserv-rubl */
          ,input  v-vat-type             /* p-vat-type         */
          ,input  v-vat-pc               /* p-vat-pc           */
          ,input  v-slt-type             /* p-slt-type         */
          ,input  v-slt-pc               /* p-slt-pc           */
          ,input  chg-qnty               /* chg-qnty           */
          ,input  v-partscr-prompt-price /* p-prompt-price     */
          ,input  0                      /* p-cli-qnty         */
          ,input  v-last-date            /* p-last-date        */
          ,input  v-hold-date            /* p-hold-date        */
          ,input  v-pl-code              /* p-pl-code          */
          ,buffer ub.doc-line            /* buf_doc-line       */
          ,buffer ub.parts               /* buf_parts          */
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при создании партии" skip
            "Документ" ub.doc-line.doc-code skip
            "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
    end.
    else do:
      for each ub.parts
        where ub.parts.obj-type  = ub.doc-line.obj-type
          and ub.parts.obj-code  = ub.doc-line.obj-code
          and ub.parts.artic     = ub.doc-line.artic
          and ub.parts.prod-type = ub.doc-line.prod-type
          and ub.parts.prod-code = ub.doc-line.prod-code
          and ub.parts.in-code   = ub.doc-line.doc-code
          and ub.parts.out-code  = ub.doc-line.doc-code
          and ub.parts.fact-qnty > 0
      on error undo, return error return-value
      :
        if  v-reserv-pl-code = yes
        and v-pl-code <> ?
        and v-pl-code <> 0
        and v-pl-code <> ub.parts.pl-code
        then do:
          next .
        end.
        assign
          out-rest = min(ub.parts.fact-qnty, abs(chg-qnty))
        .
        assign
          ub.parts.fact-qnty = ub.parts.fact-qnty - out-rest
          chg-qnty           = chg-qnty           + out-rest
        .
        if chg-qnty = 0
        then do:
          leave.
        end.
      end.
    end.
  end.
end procedure. /* rsrv-pri-fact */


procedure cost-calc :

  &scop partrqst-prefix v-total-parts-
  {&partrqst-var}

  do
  on error undo, return error return-value
  :
    run partrqst in this-procedure
      (input  ub.doc-line.doc-code         /* p-doc-code               */
      ,input  ub.doc-line.obj-type         /* p-obj-type               */
      ,input  ub.doc-line.obj-code         /* p-obj-code               */
      ,input  ub.doc-line.artic            /* p-artic                  */
      ,input  ub.doc-line.prod-type        /* p-prod-type              */
      ,input  ub.doc-line.prod-code        /* p-prod-code              */
      &scop partrqst-prefix v-total-parts-
      {&partrqst-param}
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при сборе информации по партиям" skip
        "Документ" ub.doc-line.doc-code skip
        "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if v-total-parts-fact-qnty <> 0
    then do:
      assign
        cost-base = v-total-parts-price-base / v-total-parts-fact-qnty
        cost-rubl = v-total-parts-price-rubl / v-total-parts-fact-qnty
      .
    end.
    else do:
      assign
        cost-base = v-reserv-base
        cost-rubl = v-reserv-rubl
      .
    end.
  end.

end procedure. /* cost-calc */


procedure rsrv-fact :

  do
  on error undo, return error return-value
  :
    if chg-qnty = 0
    then do:
      return.
    end.

    if chg-qnty < 0
    then do:
    /* уменьшение fact-qnty */
      for each ub.parts
        where ub.parts.obj-type  = ub.doc-line.obj-type
          and ub.parts.obj-code  = ub.doc-line.obj-code
          and ub.parts.artic     = ub.doc-line.artic
          and ub.parts.prod-type = ub.doc-line.prod-type
          and ub.parts.prod-code = ub.doc-line.prod-code
          and ub.parts.out-code  = ub.doc-line.doc-code
          and ub.parts.status_ = no
          and ub.parts.fact-qnty > ub.parts.qnty
      /* ??? условие может быть в случае открытия внутр. прихода */
      on error undo, return error return-value
      :
        if  v-reserv-pl-code = yes
        and v-pl-code <> ?
        and v-pl-code <> 0
        and v-pl-code <> ub.parts.pl-code
        then do:
          next . /* --->>>--- */
        end.
        if ub.parts.fact-qnty - ub.parts.qnty >= abs(chg-qnty)
        then do:
          assign
            ub.parts.fact-qnty = ub.parts.fact-qnty - abs(chg-qnty)
            chg-qnty           = 0
          .
          if v-goods-twounit <> true
          then do:
            if ub.parts.cli-base-rate <> 0
            then do:
              assign
                ub.parts.cli-qnty = ub.parts.fact-qnty / ub.parts.cli-base-rate
              .
            end.
            else do:
              assign
                ub.parts.cli-qnty = 0
              .
            end.
          end.
          return.  /* --->>>--- */
        end.
        else do:
          assign
            chg-qnty           = chg-qnty  + ( ub.parts.fact-qnty - ub.parts.qnty)
            ub.parts.fact-qnty = ub.parts.qnty
          .
          if v-goods-twounit <> true
          then do:
            if ub.parts.cli-base-rate <> 0
            then do:
              assign
                ub.parts.cli-qnty = ub.parts.fact-qnty / ub.parts.cli-base-rate
              .
            end.
            else do:
              assign
                ub.parts.cli-qnty = 0
              .
            end.
          end.
        end.
      end.

      if  v-reserv-pl-code = yes
      and v-pl-code <> ?
      and v-pl-code <> 0
      then do:
        find last ub.parts
          where ub.parts.obj-type  = ub.doc-line.obj-type
            and ub.parts.obj-code  = ub.doc-line.obj-code
            and ub.parts.artic     = ub.doc-line.artic
            and ub.parts.prod-type = ub.doc-line.prod-type
            and ub.parts.prod-code = ub.doc-line.prod-code
            and ub.parts.out-code  = ub.doc-line.doc-code
            and ub.parts.pl-code   = v-pl-code
            and ub.parts.status_   = no
            and ub.parts.fact-qnty > 0
        use-index pi
        no-error .
      end.
      else do:
        release ub.parts .
      end.
      if not available ub.parts
      then do:
        find last ub.parts
          where ub.parts.obj-type  = ub.doc-line.obj-type
            and ub.parts.obj-code  = ub.doc-line.obj-code
            and ub.parts.artic     = ub.doc-line.artic
            and ub.parts.prod-type = ub.doc-line.prod-type
            and ub.parts.prod-code = ub.doc-line.prod-code
            and ub.parts.out-code  = ub.doc-line.doc-code
            and ub.parts.status_   = no
            and ub.parts.fact-qnty > 0
          use-index pi
          .
      end.
      do while chg-qnty < 0
      :
        if ub.parts.fact-qnty >= abs(chg-qnty)
        then do:
          assign
            ub.parts.fact-qnty = ub.parts.fact-qnty - abs(chg-qnty)
            chg-qnty           = 0
          .
          if v-goods-twounit <> true
          then do:
            if ub.parts.cli-base-rate <> 0
            then do:
              assign
                ub.parts.cli-qnty = ub.parts.fact-qnty / ub.parts.cli-base-rate
              .
            end.
            else do:
              assign
                ub.parts.cli-qnty = 0
              .
            end.
          end.
          leave. /* --->>>--- */
        end.
        else do:
          assign
            chg-qnty           = chg-qnty  + ub.parts.fact-qnty
            ub.parts.fact-qnty = 0
          .
          if v-goods-twounit <> true
          then do:
            if ub.parts.cli-base-rate <> 0
            then do:
              assign
                ub.parts.cli-qnty = ub.parts.fact-qnty / ub.parts.cli-base-rate
              .
            end.
            else do:
              assign
                ub.parts.cli-qnty = 0
              .
            end.
          end.
        end.

        if  v-reserv-pl-code = yes
        and v-pl-code <> ?
        and v-pl-code <> 0
        then do:
          find prev ub.parts
            where ub.parts.obj-type  = ub.doc-line.obj-type
              and ub.parts.obj-code  = ub.doc-line.obj-code
              and ub.parts.artic     = ub.doc-line.artic
              and ub.parts.prod-type = ub.doc-line.prod-type
              and ub.parts.prod-code = ub.doc-line.prod-code
              and ub.parts.out-code  = ub.doc-line.doc-code
              and ub.parts.pl-code   = v-pl-code
              and ub.parts.status_   = no
              and ub.parts.fact-qnty > 0
            use-index pi
            no-error .
        end.
        else do:
          release ub.parts .
        end.
        if not available ub.parts
        then do:
          find prev ub.parts
            where ub.parts.obj-type  = ub.doc-line.obj-type
              and ub.parts.obj-code  = ub.doc-line.obj-code
              and ub.parts.artic     = ub.doc-line.artic
              and ub.parts.prod-type = ub.doc-line.prod-type
              and ub.parts.prod-code = ub.doc-line.prod-code
              and ub.parts.out-code  = ub.doc-line.doc-code
              and ub.parts.status_   = no
              and ub.parts.fact-qnty > 0
            use-index pi
            .
        end.
      end.
    end.
    else do:
      if  v-reserv-pl-code = yes
      and v-pl-code <> ?
      and v-pl-code <> 0
      then do:
        find first ub.parts
          where ub.parts.obj-type  = ub.doc-line.obj-type
            and ub.parts.obj-code  = ub.doc-line.obj-code
            and ub.parts.artic     = ub.doc-line.artic
            and ub.parts.prod-type = ub.doc-line.prod-type
            and ub.parts.prod-code = ub.doc-line.prod-code
            and ub.parts.out-code  = ub.doc-line.doc-code
            and ub.parts.pl-code   = v-pl-code
            and ub.parts.status_   = no
            and ub.parts.fact-qnty < ub.parts.qnty
        use-index pi
        no-error .
      end.
      else do:
        find first ub.parts
          where ub.parts.obj-type  = ub.doc-line.obj-type
            and ub.parts.obj-code  = ub.doc-line.obj-code
            and ub.parts.artic     = ub.doc-line.artic
            and ub.parts.prod-type = ub.doc-line.prod-type
            and ub.parts.prod-code = ub.doc-line.prod-code
            and ub.parts.out-code  = ub.doc-line.doc-code
            and ub.parts.status_   = no
            and ub.parts.fact-qnty < ub.parts.qnty
          use-index pi
          no-error.
      end.
      if available parts
      then do:
        do while chg-qnty > 0
        :
          if ub.parts.qnty - ub.parts.fact-qnty >= chg-qnty
          then do:
            assign
              ub.parts.fact-qnty = ub.parts.fact-qnty + chg-qnty
              chg-qnty           = 0
            .
            if v-goods-twounit <> true
            then do:
              if ub.parts.cli-base-rate <> 0
              then do:
                assign
                  ub.parts.cli-qnty = ub.parts.fact-qnty / ub.parts.cli-base-rate
                .
              end.
              else do:
                assign
                  ub.parts.cli-qnty = 0
                .
              end.
            end.
            leave. /* --->>>--- */
          end.
          else do:
            assign
              chg-qnty           = chg-qnty  - (ub.parts.qnty - ub.parts.fact-qnty)
              ub.parts.fact-qnty = ub.parts.qnty
            .
            if v-goods-twounit <> true
            then do:
              if ub.parts.cli-base-rate <> 0
              then do:
                assign
                  ub.parts.cli-qnty = ub.parts.fact-qnty / ub.parts.cli-base-rate
                .
              end.
              else do:
                assign
                  ub.parts.cli-qnty = 0
                .
              end.
            end.
          end.
          if  v-reserv-pl-code = yes
          and v-pl-code <> ?
          and v-pl-code <> 0
          then do:
            find next ub.parts
              where ub.parts.obj-type  = ub.doc-line.obj-type
                and ub.parts.obj-code  = ub.doc-line.obj-code
                and ub.parts.artic     = ub.doc-line.artic
                and ub.parts.prod-type = ub.doc-line.prod-type
                and ub.parts.prod-code = ub.doc-line.prod-code
                and ub.parts.out-code  = ub.doc-line.doc-code
                and ub.parts.pl-code   = v-pl-code
                and ub.parts.status_   = no
                and ub.parts.fact-qnty < ub.parts.qnty
              use-index pi
              no-error .
          end.
          else do:
            find next ub.parts
              where ub.parts.obj-type  = ub.doc-line.obj-type
                and ub.parts.obj-code  = ub.doc-line.obj-code
                and ub.parts.artic     = ub.doc-line.artic
                and ub.parts.prod-type = ub.doc-line.prod-type
                and ub.parts.prod-code = ub.doc-line.prod-code
                and ub.parts.out-code  = ub.doc-line.doc-code
                and ub.parts.status_   = no
                and ub.parts.fact-qnty < ub.parts.qnty
              use-index pi
              no-error.
          end.
          if not available ub.parts
          then do:
            leave. /* --->>>--- */
          end.
        end.
      end.
      if chg-qnty > 0
      then do:
        /* для внутр прих с выкл признаками на объект с включ */
        if  v-reserv-pl-code = yes
        and v-pl-code <> ?
        and v-pl-code <> 0
        then do:
          find first ub.parts
            where ub.parts.obj-type  = ub.doc-line.obj-type
              and ub.parts.obj-code  = ub.doc-line.obj-code
              and ub.parts.artic     = ub.doc-line.artic
              and ub.parts.prod-type = ub.doc-line.prod-type
              and ub.parts.prod-code = ub.doc-line.prod-code
              and ub.parts.out-code  = ub.doc-line.doc-code
              and ub.parts.pl-code   = v-pl-code
              and ub.parts.status_   = no
            use-index pi
            .
        end.
        else do:
          find first ub.parts
            where ub.parts.obj-type  = ub.doc-line.obj-type
              and ub.parts.obj-code  = ub.doc-line.obj-code
              and ub.parts.artic     = ub.doc-line.artic
              and ub.parts.prod-type = ub.doc-line.prod-type
              and ub.parts.prod-code = ub.doc-line.prod-code
              and ub.parts.out-code  = ub.doc-line.doc-code
              and ub.parts.status_   = no
            use-index pi
            .
        end.
        assign
          parts.fact-qnty = parts.fact-qnty + chg-qnty
          chg-qnty        = 0
        .
        if v-goods-twounit <> true
        then do:
          if ub.parts.cli-base-rate <> 0
          then do:
            assign
              ub.parts.cli-qnty = ub.parts.fact-qnty / ub.parts.cli-base-rate
            .
          end.
          else do:
            assign
              ub.parts.cli-qnty = 0
            .
          end.
        end.
      end.
    end.
  end.

end procedure. /* rsrv-fact */


procedure check-input-parameters :

  /* проверка входных параметров */

  define parameter buffer buf_trn-doc for ub.trn-doc .

  do
  on error undo, return error return-value
  :

    define variable ind                    as integer no-undo .
    define variable v-num-entries-p-action as integer no-undo .

    if p-action = ""
    or p-action = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при задании параметров вызова резервирования" skip
        "Не задан параметр вызова p-action." skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    /* параметры создаваемой партии по умолчанию */
    assign
      v-create-part-code = ""
      v-create-cst-code  = buf_trn-doc.cst-code
      v-partscr-prompt-price = 'prompt=enable':u
    .

    assign
      v-reserv-single-part = false
      v-in-code            = ""
      v-part-code          = ""
    .

    /* значение по умолчанию - список типов приобретения для резервирования */
    define variable v-purch-code-list-type as character no-undo .

    { str/tdat-val.i
        buf_trn-doc.doc-code
        {&trdcattr-purchcodelist}
        v-purch-code-list
        v-purch-code-list-type
    }
    if v-purch-code-list = {&purchase-codes}
    then do:
      /* если заданы все типы приобретения - то резервируем без ограничений */
      assign
        v-purch-code-list = "":u
      .
    end.

    define variable v-rsrv-doc-list      as character no-undo .
    define variable v-rsrv-doc-list-type as character no-undo .

    { str/tdat-val.i
        buf_trn-doc.doc-code
        {&trdcattr-rsrv-doc-list}
        v-rsrv-doc-list
        v-rsrv-doc-list-type
    }
    if v-rsrv-doc-list = ''
    then do:
      run partlist_use-set in this-procedure
        (input  false
        ) .
    end.
    else do:
      run partlist_use-set in this-procedure
        (input  true
        ) .
      run partlist_clear in this-procedure
        .
      define variable v-rsrv-doc-list-index       as integer   no-undo .
      define variable v-rsrv-doc-list-num-entries as integer   no-undo .

      assign
        v-rsrv-doc-list-num-entries = num-entries(v-rsrv-doc-list, {&comma-char})
      .

      do v-rsrv-doc-list-index = 1 to v-rsrv-doc-list-num-entries
      :
        define buffer rsrv_buf_trn-doc for ub.trn-doc .
        find first rsrv_buf_trn-doc no-lock
          where rsrv_buf_trn-doc.doc-code = entry(v-rsrv-doc-list-index
                                                 ,v-rsrv-doc-list
                                                 ,{&comma-char}
                                                 )
          no-error .
        if not available rsrv_buf_trn-doc
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при анализе входящих параметров" skip
            "В списке документов задан несуществующий документ" skip
            "Документ" buf_trn-doc.doc-code skip
            "Атрибут" {&trdcattr-rsrv-doc-list} skip
            "Номер элемента" v-rsrv-doc-list-index skip
            "Документ для резервирования" entry(v-rsrv-doc-list-index
                                                 ,v-rsrv-doc-list
                                                 ,{&comma-char}
                                                 ) skip
          view-as alert-box error .
          undo, return error return-value .
        end.

        define buffer rsrv_buf_doc-line for ub.doc-line .
        find first rsrv_buf_doc-line no-lock
          where rsrv_buf_doc-line.doc-code  = rsrv_buf_trn-doc.doc-code
            and rsrv_buf_doc-line.artic     = v-artic
            and rsrv_buf_doc-line.prod-type = v-prod-type
            and rsrv_buf_doc-line.prod-code = v-prod-code
          no-error .
        if available rsrv_buf_doc-line
        then do:
          define buffer rsrv_buf_parts for ub.parts .
          for each rsrv_buf_parts no-lock
            where rsrv_buf_parts.obj-type  = rsrv_buf_trn-doc.obj-type
              and rsrv_buf_parts.obj-code  = rsrv_buf_trn-doc.obj-code
              and rsrv_buf_parts.artic     = rsrv_buf_doc-line.artic
              and rsrv_buf_parts.prod-type = rsrv_buf_doc-line.prod-type
              and rsrv_buf_parts.prod-code = rsrv_buf_doc-line.prod-code
              and rsrv_buf_parts.out-code  = rsrv_buf_trn-doc.doc-code
          on error undo, return error return-value
          :
            /* todo задавать какой-либо определенный порядок партий в документе */
            if rsrv_buf_parts.fact-qnty > 0
            then do:
              run partlist_append_part in this-procedure
                (input  rsrv_buf_parts.in-code
                ,input  rsrv_buf_parts.part-code
                ,input  rsrv_buf_parts.qnty
                ) .
            end.
          end.
        end.
      end.
    end.

    assign
      v-last-date = ?
    .

    assign
      v-num-entries-p-action = num-entries(p-action)
    .

    do ind = 2 to v-num-entries-p-action
    :
      define variable v-option       as character no-undo .
      define variable v-option-key   as character no-undo .
      define variable v-option-value as character no-undo .

      assign
        v-option = entry(ind, p-action)
      .
      if v-option = ""
      or v-option = ?
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при задании параметров вызова резервирования" skip
          "В качестве параметров резервирования задана пустая или неопределенная опция" skip
          "v-option" v-option skip
          "p-action" p-action skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      assign
        v-option-key = entry(1, v-option, "=" )
      .

      case v-option-key :
        when {&rsrv-dtl_no-message}
        then do:
          assign
            v-option-no-message = true
            v-partscr-prompt-price = 'prompt=disable-reject':u
          .
        end.
        when {&rsrv-dtl_no-msg-create}
        then do:
          assign
            v-option-no-message = true
            v-partscr-prompt-price = 'prompt=disable-create':u
          .
        end.
        when {&rsrv-dtl_no-msg-no-chk-acta-cr}
        then do:
          assign
            v-option-no-message = true
            v-partscr-prompt-price = 'prompt=disable-create,check-right=false':u
          .
        end.
        when {&rsrv-dtl_pl-code}
        then do:
          if num-entries(v-option, "=") <> 2
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Для указания складского места необходимо указать строку" skip
              "" {&rsrv-dtl_pl-code} + "=<plcode>" skip
              "v-option" v-option skip
              "p-action" p-action skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          define variable s-pl-code as character no-undo .
          assign
            s-pl-code = entry(2, v-option, "=" )
          .

          { gbl/gdsobjat.i
            v-obj-type
            v-obj-code
            v-artic
            v-prod-type
            v-prod-code
            "'place-rsrv=request'"
            v-reserv-pl-code
            no-error
          }
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при определении атрибута на объекта" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.

          if v-reserv-pl-code = false
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка задания параметров вызова резервирования" skip
              "Товар не привязан к местам хранения" skip
              "Но для товара задано место хранения" skip
              "pl-code" s-pl-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.

          assign
            v-reserv-pl-code = true
            v-pl-code        = integer(s-pl-code) no-error
          .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Для указания складского места необходимо указать строку" skip
              "" {&rsrv-dtl_pl-code} + "=<plcode>" skip
              "" s-pl-code + "не может быть преобразовано к целому числу" skip
              "v-option" v-option skip
              "p-action" p-action skip
              error-status :get-message(1) skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end.
        when {&rsrv-dtl_copy-cst}
        then do:
          /* todo - необходимо удалить этот режим */
          if num-entries(v-option, "=") <> 2
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Для указания параметров партии (ГТД, код партии) необходимо указать строку" skip
              "" {&rsrv-dtl_copy-cst} + "=<recid_исходной_партии>" skip
              "v-option" v-option skip
              "p-action" p-action skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-option-value = entry(2, v-option, "=" )
          .
          define buffer buf_orig-parts for ub.parts .
          find first buf_orig-parts no-lock
            where recid(buf_orig-parts) = integer(v-option-value)
            no-error .
          if not available buf_orig-parts
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Было запрошено копирование параметров параметров партии (ГТД, код партии)" skip
              "Исходная партия с указателем" v-option-value "не была найдена" skip
              "v-option" v-option skip
              "p-action" p-action skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-create-part-code = buf_orig-parts.part-code
            v-create-cst-code  = buf_orig-parts.cst-code
          .
          /* автоматическая генерация кода партии */
          /* сделано для обеспечения уникальности партий */
          /* при копировании из расходного документа в приходный документ */
          if  v-create-part-code = ""
          then do:
            define buffer buf_orig-trn-doc for ub.trn-doc .

            find first buf_orig-trn-doc no-lock
              where buf_orig-trn-doc.doc-code = buf_orig-parts.out-code
              no-error .
            if not available buf_orig-trn-doc
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при задании параметров вызова резервирования" skip
                "Было запрошено копирование параметров параметров партии (ГТД, код партии)" skip
                "Задана партия с номером" recid(buf_orig-parts) skip
                "Не найден документ к которому привязана партия" skip
                "Документ" buf_orig-parts.out-code skip
                "v-option" v-option skip
                "p-action" p-action skip
                view-as alert-box error .
              undo, return error return-value .
            end.

            if buf_orig-trn-doc.ext-doc-type <> {&TDEDT_Pri_Vnesh}
            then do:
              assign
                v-create-part-code = "#":U + buf_orig-parts.in-code
              .
            end.
          end.
        end.
        when {&rsrv-dtl_cst-code}
        then do:
          if num-entries(v-option, "=") <> 2
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Для указания кода ГТД необходимо указать строку" skip
              "" {&rsrv-dtl_cst-code} + "=Код ГТД" skip
              "v-option" v-option skip
              "p-action" p-action skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-option-value = entry(2, v-option, "=" )
          .
          assign
            v-create-cst-code = str-decode(v-option-value, "")
          .
        end.
        when {&rsrv-dtl_ps}
        then do:
          if num-entries(v-option, "=") <> 2
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Для указания кода ГТД необходимо указать строку" skip
              "" {&rsrv-dtl_cst-code} + "=Код ГТД" skip
              "v-option" v-option skip
              "p-action" p-action skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-option-value = entry(2, v-option, "=" )
          .
          assign
            v-create-ps = str-decode(v-option-value, "")
          .
          assign
            v-partsupd-action = v-partsupd-action
                              + (if v-partsupd-action <> "" then "," else "")
                              + v-option
          .
        end.
        when {&rsrv-dtl_dop}
        then do:
          if num-entries(v-option, "=") <> 2
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Для указания DOP необходимо указать строку" skip
              "" {&rsrv-dtl_cst-code} + "=цена производителя" skip
              "v-option" v-option skip
              "p-action" p-action skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-option-value = entry(2, v-option, "=" )
          .
          assign
            v-create-dop = str-decode(v-option-value, "")
          .
          assign
            v-partsupd-action = v-partsupd-action
                              + (if v-partsupd-action <> "" then "," else "")
                              + v-option
          .
        end.

        when {&rsrv-dtl_contract-code}
        then do:
          if num-entries(v-option, "=") <> 2
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Для указания кода контракта необходимо указать строку" skip
              "" {&rsrv-dtl_contract-code} + "=Код контракта" skip
              "v-option" v-option skip
              "p-action" p-action skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-option-value = entry(2, v-option, "=" )
          .
          assign
            v-contract-code = integer(v-option-value)
          .

          assign
            v-partsupd-action = v-partsupd-action
                              + (if v-partsupd-action <> "" then "," else "")
                              + v-option
          .
        end.
        when {&rsrv-dtl_rsrv-single-part}
        then do:
          if num-entries(v-option, "=") <> 1
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Для указания кода документа необходимо указать строку" skip
              "" {&rsrv-dtl_rsrv-single-part} skip
              "v-option" v-option skip
              "p-action" p-action skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-reserv-single-part = true
          .
        end.
        when {&rsrv-dtl_rsrv-in-code}
        then do:
          if num-entries(v-option, "=") <> 2
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Для указания кода документа необходимо указать строку" skip
              "" {&rsrv-dtl_rsrv-in-code} + "=Код документа" skip
              "v-option" v-option skip
              "p-action" p-action skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-option-value = entry(2, v-option, "=" )
          .
          assign
            v-in-code = str-decode(v-option-value, "")
          .
        end.
        when {&rsrv-dtl_rsrv-part-code}
        then do:
          if num-entries(v-option, "=") <> 2
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Для указания кода партии необходимо указать строку" skip
              "" {&rsrv-dtl_rsrv-part-code} + "=Код партии" skip
              "v-option" v-option skip
              "p-action" p-action skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-option-value = entry(2, v-option, "=" )
          .
          assign
            v-part-code = str-decode(v-option-value, "")
          .
        end.
        when {&rsrv-dtl_old-part-code}
        then do:
          if num-entries(v-option, "=") <> 2
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Для указания кода партии необходимо указать строку" skip
              "" {&rsrv-dtl_old-part-code} + "=Код партии" skip
              "v-option" v-option skip
              "p-action" p-action skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-option-value = entry(2, v-option, "=" )
          .
          assign
            v-rename-part-code = true
            v-old-part-code    = str-decode(v-option-value, "")
          .
        end.
        when {&rsrv-dtl_cre-part-code}
        then do:
          if num-entries(v-option, "=") <> 2
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Для указания кода партии необходимо указать строку" skip
              "" {&rsrv-dtl_cre-part-code} + "=Код партии" skip
              "v-option" v-option skip
              "p-action" p-action skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-option-value = entry(2, v-option, "=" )
          .
          assign
            v-create-part-code = str-decode(v-option-value, "")
            was-created-part-code = yes
          .
        end.
        when {&rsrv-dtl_cli-qnty}
        then do:
          if num-entries(v-option, "=") <> 2
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Для указания клиентского количества необходимо указать строку" skip
              "" {&rsrv-dtl_cst-code} + "=Код ГТД" skip
              "v-option" v-option skip
              "p-action" p-action skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-option-value = entry(2, v-option, "=" )
          .
          assign
            v-cli-qnty = decimal(v-option-value)
          .
        end.
        when {&rsrv-dtl_hold-code-parent}
        then do:
          if num-entries(v-option, "=") <> 2
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Для указания кода партии необходимо указать строку" skip
              "" {&rsrv-dtl_hold-code-parent} + "=Код партии" skip
              "v-option" v-option skip
              "p-action" p-action skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-option-value = entry(2, v-option, "=" )
          .
          assign
            v-hold-code-parent = str-decode(v-option-value, "")
          .
          if v-hold-code-parent <> ""
          then do:
            /* создание партии документа межфирменного перемещения */
            run holdprts-get-part-code in this-procedure
              (input  buf_trn-doc.doc-code
              ,output v-create-part-code
              ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при определении номера партии" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error return-value .
            end.
          end.
        end.
        when {&rsrv-dtl_part-code-parent}
        then do:
          if num-entries(v-option, "=") <> 2
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Для указания кода партии необходимо указать строку" skip
              "" {&rsrv-dtl_part-code-parent} + "=Код партии" skip
              "v-option" v-option skip
              "p-action" p-action skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-option-value = entry(2, v-option, "=" )
          .
          assign
            v-hold-part-code = str-decode(v-option-value, "")
          .
        end.
        when {&rsrv-dtl_purch-code-list}
        then do:
          if num-entries(v-option, "=") <> 2
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Для указания списка типов приобретения необходимо указать строку" skip
              "" {&rsrv-dtl_purch-code-list} + "=Список типов приобретения" skip
              "v-option" v-option skip
              "p-action" p-action skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-option-value = entry(2, v-option, "=" )
          .
          assign
            v-purch-code-list = str-decode(v-option-value, "")
          .
        end.
        when {&rsrv-dtl_last-date}
        then do:
          if num-entries(v-option, "=") <> 2
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Для указания списка типов приобретения необходимо указать строку" skip
              "" {&rsrv-dtl_last-date} + "=Дата срока годности до" skip
              "v-option" v-option skip
              "p-action" p-action skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-option-value = entry(2, v-option, "=" )
          .
          assign
            v-last-date = date(v-option-value)
          .
        end.
        when {&rsrv-dtl_hold-date}
        then do:
          if num-entries(v-option, "=") <> 2
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Для указания списка типов приобретения необходимо указать строку" skip
              "" {&rsrv-dtl_hold-date} + "=Дата прихода МФ" skip
              "v-option" v-option skip
              "p-action" p-action skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-option-value = entry(2, v-option, "=" )
          .
          assign
            v-hold-date = date(v-option-value)
          .
        end.
        when {&rsrv-dtl_negative-check}
        then do:
          if num-entries(v-option, "=") <> 2
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Для указания типа отрицательной проверки необходимо указать строку" skip
              "" {&rsrv-dtl_part-code-parent} + "=Тип проверки" skip
              "v-option" v-option skip
              "p-action" p-action skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-option-value = entry(2, v-option, "=" )
          .
          define variable v-ind as integer   no-undo .

          if  v-option-value <> "1"
          and v-option-value <> "2"
          and v-option-value <> "3"
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Неизвестное значение типа отрицательной проверки" skip
              "Допустимые значения 1,2,3" skip
              "" {&rsrv-dtl_part-code-parent} + "=Тип проверки" skip
              "v-option" v-option skip
              "p-action" p-action skip
              view-as alert-box error .
            undo, return error return-value .
          end.

          assign
            v-negative-check = integer(v-option-value)
          .
        end.
        when {&rsrv-dtl_sale-negative-check-on}
        then do:
          assign
            v-option-sale-negative-check-on = true
          .
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при задании параметров вызова резервирования" skip
            "Неизвестная опция." v-option skip
            "p-action" p-action skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
    end.

    if  p-b-code <> ?
    and p-b-code <> 0
    and p-b-code <> -1
    then do:
      find ub.bar-code no-lock
        where ub.bar-code.b-code = p-b-code
        no-error.
      if not available ub.bar-code
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при задании параметров вызова резервирования" skip
          "Недопустимый параметр вызова бар-код партии." skip
          "Документ" v-doc-code skip
          "Артикул" v-artic v-prod-type v-prod-code skip
          "b-code" p-b-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      /* Если задан бар-код - то рассматриваем только партии для указанного бар-кода */
      assign
        v-reserv-single-part = true
        v-in-code            = ub.bar-code.in-code
        v-part-code          = ub.bar-code.part-code
      .

      /*Найдем самый ориг in-code для bar-code */
      define buffer buf_parts-attr for ub.parts-attr  .
          find first buf_parts-attr no-lock where
               buf_parts-attr.gds-code  = ub.bar-code.gds-code  and
               buf_parts-attr.part-code = ub.bar-code.part-code  and
               buf_parts-attr.in-code =   ub.bar-code.in-code
               no-error .
                if error-status :error then DO:
                    message
                      vss-workfile vss-revision vss-description skip
                      error-status :get-message(1) skip
                      return-value skip
                      "Нет атрибута партиии для"
                      ub.bar-code.gds-code  skip
                      ub.bar-code.part-code skip
                      ub.bar-code.in-code   skip
                      view-as alert-box error
                    .
                end.
           else do:
           assign
            v-in-code   = buf_parts-attr.orig-in-code
            v-part-code = buf_parts-attr.orig-part-code
           .
           end.
    end.

    assign
      p-action = entry(1, p-action)
    .
    if  p-action <> {&rsrv-dtl_action_reserv}
    and p-action <> {&rsrv-dtl_action_reserv-sozdanie}
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при задании параметров вызова резервирования" skip
        "Недопустимый параметр вызова p-action." skip
        "Значение p-action: "  p-action  skip
        "Допустимые значения:" skip
        "" {&rsrv-dtl_action_reserv} skip
        "" {&rsrv-dtl_action_reserv-sozdanie} skip
        view-as alert-box error .
      assign
        chg-qnty = 0
      .
      undo, return error return-value .
    end.

    /* проверка того, что не было передано "дробное" количество для резервирования */
    /* точность передаваемого количества должна быть не выше, чем точность
      количества в документах
    */
    if chg-qnty = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при задании параметров вызова резервирования" skip
        "Количество для резервирования имеет неопределенное значение" skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    define variable v-check-qnty like ub.doc-line.doc-qnty no-undo .

    assign
      v-check-qnty = chg-qnty
    .

    if v-check-qnty <> chg-qnty
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при задании параметров вызова резервирования" skip
        "Запрошено резервирование дробного количества" skip
        "Запрошено резервирование" chg-qnty skip
        "После округления это составит" v-check-qnty skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.

end procedure. /* check-input-parameters */