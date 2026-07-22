block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание документов внутреннего перемещения.

Автор: Чернова Светлана Александровна
Дата создания: 05/08/07
Author: Svetlana Chernova
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 11/11/99


Создает документ внутреннего прихода по документу внутреннего расхода.
  ПРИ <<<--- РАС

Создает документ внутреннего возврата по документу внутреннего прихода.
  ВОЗВРАТ <<<--- ПРИ

Общее правило для таблиц doc-line, gds-dtl, parts:
  fact-qnty должно быть больше нуля.
  fact-qnty должно быть меньше или равно doc-qnty.

При перемещении с объекта, где признаки выключены
на объект, где признаки включены
  информация на новом объекте записывается в первый терминальный признак

При перемещении с объекте, где признаки включены
на объект, где признаки выключены
  информация на новом объекте записывается в корневой признак.
  Если признаков было несколько, то их продажная цена усредняется.


Пользователь имеет возможность проставить любые количества
для любых признаков gds-dtl.fact-qnty,
а значит gds-dtl.fact-qnty может быть больше gds-dtl.doc-qnty.

*/
using Progress.Lang.*.
using ibs.th.gbl.*.
using ibs.th.gbl.sys.*.

define input parameter v-doc-code like ub.trn-doc.doc-code no-undo .

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Создание документов внутреннего перемещения":U .

{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ str/lib-trn.i  }
{ str/doc-code.i }
{ str/trdcalib.i }
{ cmp/library.i  }
{ gbl/lineattr.i }
{ ref/gds-attr.i }

define variable same_db as logical   no-undo initial no . /* при внутренних перемещениях в одной и той же УБД */
define variable v-today as date      no-undo.

/* включены или выключены признаки на объекте, куда происходит перемещение */
/* yes - признаки включены */
/* no  - признаки выключены */
define variable cli_doc-prt as logical   no-undo .

/* включены или выключены признаки на объекте, с которого происходит перемещение */
/* yes - признаки включены */
/* no  - признаки выключены */
define variable obj_doc-prt as logical   no-undo .

define variable n_str       as integer   no-undo .

define variable v-base-code         like ub.currency.curr-code no-undo .
define variable v-doc-line-chg-qnty like ub.doc-line.doc-qnty  no-undo .
define variable l-goods-twounit     as logical   no-undo .
define variable var-ok-assort-pol   as logical   no-undo .
define variable var-mess-assort-pol as character no-undo .
define variable v-doc-pl-rowid      as rowid     no-undo .
define variable v-event-code as character no-undo .
define variable is-petrolium               as logical   no-undo .
define variable is-pieces                  as logical   no-undo .
    define variable v-gds-attr-value-old as character no-undo .
    define variable v-gds-attr-type      as character no-undo .
define variable v-ext-doc-type as character no-undo .

define variable v-country-code as integer   no-undo .

define buffer buf_trn-doc       for ub.trn-doc .
define buffer buf_doc-line      for ub.doc-line .
define buffer buf_gds-dtl       for ub.gds-dtl .
define buffer buf_parts         for ub.parts .
define buffer buf_parts-attr    for ub.parts-attr .
define buffer new_parts-attr    for ub.parts-attr .
define buffer buf_doc-pl        for ub.doc-pl .
define buffer buf_doc-pl-attr   for ub.doc-pl-attr .
define buffer buf-first_trn-doc for ub.trn-doc .
define buffer buf-first_parts   for ub.parts .
define buffer doc-obj           for ub.clients .
define buffer buf_cliobj        for ub.clients .

{ gbl/objsrv.i }

{ str/in-vatp.i def }

do
for buf_trn-doc, buf_doc-line, buf_gds-dtl, buf_parts, buf_doc-pl, doc-obj, buf_cliobj
transaction
on error undo, return error return-value
:

  find first ub.trn-doc
    where ub.trn-doc.doc-code = v-doc-code
    no-error .
  if not available ub.trn-doc then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден документ" skip
      "Документ " v-doc-code
      view-as alert-box .
    undo, return error .
  end.

  define variable v-host-code like ub.trn-doc.host-code no-undo .

  /* определяем код фирмы для объекта */
  { gbl/hostcode.i
    ub.trn-doc.obj-type
    ub.trn-doc.obj-code
    v-host-code
    no-error
  }
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении кода фирмы для объекта с которого происходит перемещение" skip
      "Документ внутреннего перемещения" ub.trn-doc.doc-code skip
      "Объект" ub.trn-doc.obj-type ub.trn-doc.obj-code skip
      view-as alert-box error .
    undo, return error .
  end.

  /* определяем код базовой валюты для фирмы */
  { gbl/basecode.i
    v-host-code
    v-base-code
    no-error
  }
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении кода базовой валюты для фирмы" skip
      "Документ внутреннего перемещения" ub.trn-doc.doc-code skip
      "Объект" ub.trn-doc.obj-type ub.trn-doc.obj-code skip
      view-as alert-box error .
    undo, return error .
  end.

  /* определяем код фирмы для объекта на который происходит перемещение */
  define variable v-cli-host-code like ub.trn-doc.host-code no-undo .
  { gbl/hostcode.i
    ub.trn-doc.cli-type
    ub.trn-doc.cli-code
    v-cli-host-code
    no-error
  }
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении кода фирмы для объекта на который происходит перемещение" skip
      "Документ внутреннего перемещения" ub.trn-doc.doc-code skip
      "Объект" ub.trn-doc.cli-type ub.trn-doc.cli-code skip
      view-as alert-box error .
    undo, return error .
  end.

  if v-cli-host-code <> v-host-code then do:
    message
      vss-workfile vss-revision vss-description skip
      "Документ " v-doc-code skip
      "Фирма объекта откуда происходит перемещение" skip
      "не совпадает с фирмой, куда происходит перемещение" skip
      "v-host-code"     v-host-code     skip
      "v-cli-host-code" v-cli-host-code skip
      "Закрытие документа невозможно" skip
      view-as alert-box error .
    undo, return error .
  end.

  find ub.clients no-lock
    where ub.clients.obj-type = ub.trn-doc.cli-type
      and ub.clients.obj-code = ub.trn-doc.cli-code
    no-error .
  if not available ub.clients then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестный клиент" skip
      "Документ " v-doc-code skip
      "Объект" ub.trn-doc.obj-type ub.trn-doc.obj-code skip
      "Клиент" ub.trn-doc.cli-code ub.trn-doc.cli-type skip
      view-as alert-box .
    undo, return error .
  end.

  if  ub.trn-doc.cli-type <> {&stock}
  and ub.trn-doc.cli-type <> {&shop}
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Клиент документа внутреннего перемещения не является объектом"
      "Документ " v-doc-code skip
      "Объект" ub.trn-doc.obj-type ub.trn-doc.obj-code skip
      "Клиент" ub.trn-doc.cli-code ub.trn-doc.cli-type skip
      view-as alert-box error .
    undo, return error .
  end.

  find doc-obj no-lock
    where doc-obj.obj-type = ub.trn-doc.obj-type
      and doc-obj.obj-code = ub.trn-doc.obj-code
    no-error .
  if not available doc-obj then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестный объект" skip
      "Документ " v-doc-code skip
      "Объект" ub.trn-doc.obj-type ub.trn-doc.obj-code skip
      "Клиент" ub.trn-doc.cli-code ub.trn-doc.cli-type skip
      view-as alert-box .
    undo, return error .
  end.

  if  ub.trn-doc.obj-type <> {&stock}
  and ub.trn-doc.obj-type <> {&shop}
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Объект документа внутреннего перемещения не является объектом"
      "Документ " v-doc-code skip
      "Объект" ub.trn-doc.obj-type ub.trn-doc.obj-code skip
      "Клиент" ub.trn-doc.cli-code ub.trn-doc.cli-type skip
      view-as alert-box error .
    undo, return error .
  end.

  if doc-obj.db-num = clients.db-num
  and clients.db-num > 0 then do:
    assign
      same_db = yes
    .
  end.

  if  ub.trn-doc.status_  = {&fact}
  and lookup(ub.trn-doc.doc-type, {&expense_income}) > 0
  and ub.trn-doc.internal = yes
  and ub.trn-doc.discnt-type <> {&manufactured} then do:
    /* правильный документ */
  end.
  else do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "В качестве параметра можно передавать только документы" skip
      "внутреннего прихода, внутреннего расход" skip
      "закрытые до статуса" {&fact} skip
      "Документ" ub.trn-doc.doc-code skip
      "Тип документа" ub.trn-doc.doc-type skip
      "Внутренний" ub.trn-doc.internal skip
      "discnt-type" ub.trn-doc.discnt-type skip
      "Статус" ub.trn-doc.status_ skip
      view-as alert-box error .
    undo, return error .
  end.



  if (g#db-num = 0 and same_db = no )
  or (g#db-num > 0 and same_db = yes)
  then do:
    /* необходимо создавать документ прихода/возврата */
  end.
  else do:
    /* не надо порождать документ */
    return.  /* --->>>--- */
  end.

  /* определяем, учитываются ли признаки на объекте */
  /* ОТКУДА происходит перемещение */
  { gbl/objat.i
    ub.trn-doc.obj-type
    ub.trn-doc.obj-code
    "'doc-prt=request':u"
    obj_doc-prt
    no-error
  }
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении атрибута объекта" skip
      "Документ внутреннего перемещения" ub.trn-doc.doc-code skip
      "Объект" ub.trn-doc.obj-type ub.trn-doc.obj-code skip
      'doc-prt=request':u skip
      error-status:get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.

  /* определяем, учитываются ли признаки на объекте */
  /* КУДА происходит перемещение */
  { gbl/objat.i
    ub.trn-doc.cli-type
    ub.trn-doc.cli-code
    "'doc-prt=request':u"
    cli_doc-prt
    no-error
  }
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении атрибута объекта" skip
      "Документ внутреннего перемещения" ub.trn-doc.doc-code skip
      "Объект" ub.trn-doc.cli-type ub.trn-doc.cli-code skip
      "doc-prt=request" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.
  if ub.trn-doc.doc-type = {&expense}  then do:
    define variable vardoc-code as character no-undo .

    run doc-code in this-procedure
      (input  "pair",
      input  ub.trn-doc.obj-type,
      input  ub.trn-doc.obj-code,
      input  ub.trn-doc.doc-code,
      output vardoc-code  ) no-error.
    if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при генерации номера документа" skip
        return-value skip
        trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        trim(error-status :get-message(4))
        trim(error-status :get-message(5)) skip
        view-as alert-box error.
      undo, return error .
    end.
  end.
  else do:
    run doc-code in this-procedure
      (input  "trio",
      input  ub.trn-doc.obj-type,
      input  ub.trn-doc.obj-code,
      input  ub.trn-doc.doc-code,
      output vardoc-code) no-error.
    if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при генерации номера документа." skip
        return-value skip
        trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        trim(error-status :get-message(4))
        trim(error-status :get-message(5)) skip
        view-as alert-box error.
      undo, return error .
    end.
  end.
find first buf_cliobj no-lock
  where buf_cliobj.obj-type = ub.trn-doc.obj-type
    and buf_cliobj.obj-code = ub.trn-doc.obj-code
  .
case ub.trn-doc.ext-doc-type :
    when {&TDEDT_Pri_Perem} then v-ext-doc-type = {&TDEDT_Vozvrat_Perem}  .
    when {&TDEDT_Ras_Perem} then v-ext-doc-type = {&TDEDT_Pri_Perem} .
    when {&TDEDT_Ras_Object} then v-ext-doc-type = {&TDEDT_Pri_Object} .
end case . 
{ gbl/curobjdt.i ub.trn-doc.obj-type ub.trn-doc.obj-code v-today }
{ str/crtrndoc.i
  ?
  ?
  ub.trn-doc.base-rate
  ub.trn-doc.base-scale
  ub.trn-doc.obj-code
  ub.trn-doc.obj-type
  buf_cliobj.obj-name
  ub.clients.db-num
  ub.trn-doc.creid
  ub.trn-doc.discnt-type
  vardoc-code
  v-today
  "(if ub.trn-doc.doc-type = {&expense} then {&income} else {&return})"
  false
  ub.trn-doc.host-code
  ub.trn-doc.internal
  ub.trn-doc.cli-code
  ub.trn-doc.cli-type
  ub.trn-doc.office
  ub.trn-doc.pay-code
  "''"
  no
  ?
  {&wayb}
  ?
  v-ext-doc-type
  ?
  no-error
  }
  if error-status :error then do:
      message
      vss-workfile vss-revision vss-description skip
      "Ошибка при создании документа внутреннего перемещения" skip
      "Документ внутреннего перемещения" ub.trn-doc.doc-code skip
      "Объект" ub.trn-doc.cli-type ub.trn-doc.cli-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error.
  end.
  find buf_trn-doc where buf_trn-doc.doc-code = vardoc-code.
  assign
    buf_trn-doc.exch-date     = ub.trn-doc.doc-date       /* курсы на дату РН */
    buf_trn-doc.exch-rate     = ub.trn-doc.base-rate      /* ! */
    buf_trn-doc.out-code      = ub.trn-doc.doc-code       /* ! */
    buf_trn-doc.ship-num      = ub.trn-doc.ship-num
    buf_trn-doc.ship-date     = ub.trn-doc.ship-date
    buf_trn-doc.ord-num       = ub.trn-doc.ord-num
    buf_trn-doc.exch-scale    = ub.trn-doc.base-scale     /* ! */
    buf_trn-doc.exch-code     = v-base-code               /* валюта клиента - базовая */
    buf_trn-doc.fact-num      = 0
    buf_trn-doc.fact-date     = if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Object} then ub.trn-doc.fact-date else ?
    buf_trn-doc.print-rubl    = ub.trn-doc.print-rubl
    buf_trn-doc.wrkr          = if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Object} then ub.trn-doc.wrkr else ?                         /* ! */
    buf_trn-doc.agnt          = ub.trn-doc.agnt           /* ! */
    buf_trn-doc.boss          = ub.trn-doc.boss           /* ! */
    buf_trn-doc.reason-code   = ub.trn-doc.reason-code
  .
  if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Object} then do :
      assign
        buf_trn-doc.shift-date = ub.trn-doc.shift-date
        buf_trn-doc.shift-name = ub.trn-doc.shift-name
        buf_trn-doc.shift-num  = ub.trn-doc.shift-num
      .
  end.

  assign
    n_str = 0
  .

  /* копируем некоторые атрибуты документа */
  define variable v-attr-exist as logical   no-undo .
  define variable v-attr-value as character no-undo .
  define variable v-attr-type  as character no-undo .

  { str/tdat-xst.i
      ub.trn-doc.doc-code
      {&trdcattr-purchlimit}
      v-attr-exist
  }
  if v-attr-exist = true
  then do:
    { str/tdat-val.i
        ub.trn-doc.doc-code
        {&trdcattr-purchlimit}
        v-attr-value
        v-attr-type
    }
    { str/tdat-wrt.i
        buf_trn-doc.doc-code
        {&trdcattr-purchlimit}
        v-attr-value
    }
  end.

  { str/tdat-xst.i
      ub.trn-doc.doc-code
      {&trdcattr-purchcodelist}
      v-attr-exist
  }
  if v-attr-exist = true
  then do:
    { str/tdat-val.i
        ub.trn-doc.doc-code
        {&trdcattr-purchcodelist}
        v-attr-value
        v-attr-type
    }
    { str/tdat-wrt.i
        buf_trn-doc.doc-code
        {&trdcattr-purchcodelist}
        v-attr-value
    }
  end.
  
/*  { str/tdat-xst.i                    */
/*      ub.trn-doc.doc-code             */
/*      {&trdcattr-doc-num-in-ext-sys}  */
/*      v-attr-exist                    */
/*  }                                   */
/*  if v-attr-exist = true              */
/*  then do:                            */
/*    { str/tdat-val.i                  */
/*        ub.trn-doc.doc-code           */
/*        {&trdcattr-doc-num-in-ext-sys}*/
/*        v-attr-value                  */
/*        v-attr-type                   */
/*    }                                 */
/*    { str/tdat-wrt.i                  */
/*        buf_trn-doc.doc-code          */
/*        {&trdcattr-doc-num-in-ext-sys}*/
/*        v-attr-value                  */
/*    }                                 */
/*  end.                                */
  
  if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Object} then do :
        for each buf_doc-pl no-lock where
                 buf_doc-pl.obj-type    = buf_trn-doc.obj-type and
                 buf_doc-pl.obj-code    = buf_trn-doc.obj-code and
                 buf_doc-pl.out-code    = buf_trn-doc.out-code :
            find first  buf_doc-pl-attr exclusive-lock
                  where buf_doc-pl-attr.obj-type    = buf_doc-pl.obj-type
                    and buf_doc-pl-attr.obj-code    = buf_doc-pl.obj-code
                    and buf_doc-pl-attr.pl-code     = buf_doc-pl.pl-code
                    and buf_doc-pl-attr.out-code    = buf_doc-pl.out-code            
                    and buf_doc-pl-attr.gds-code    = buf_doc-pl.gds-code
                    and buf_doc-pl-attr.attr-code   = 'place2' no-error .
            if not available buf_doc-pl-attr then do :
                return error return-value .
            end.
            create ub.doc-pl .
            buffer-copy buf_doc-pl to ub.doc-pl
            assign
                ub.doc-pl.out-code = buf_trn-doc.doc-code
                ub.doc-pl.pl-code = integer(buf_doc-pl-attr.attr-value)
            .       
        end.   
  end.
  for each ub.doc-line
    where ub.doc-line.doc-code = ub.trn-doc.doc-code use-index line-num
  on error undo, return error substitute("&1 (ub.doc-line). &3&2&4", vss-workfile, {&new-line}, error-status :get-message(1), return-value  )
  :
    find first ub.goods no-lock
      where ub.goods.artic     = ub.doc-line.artic
        and ub.goods.prod-type = ub.doc-line.prod-type
        and ub.goods.prod-code = ub.doc-line.prod-code
      .

    { gbl/gdsat.i
      ub.goods.artic
      ub.goods.prod-type
      ub.goods.prod-code
      "'twounit=request':u"
      l-goods-twounit
      no-error
    }
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара" skip
        "Документ внутреннего перемещения" ub.trn-doc.doc-code skip
        "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    { str/is-petrl.i
      ub.goods.artic
      ub.goods.prod-type
      ub.goods.prod-code
      is-petrolium
      is-pieces
      no-error
    }
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара (petrolium)" skip
        "Документ внутреннего перемещения" ub.trn-doc.doc-code skip
        "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    assign
      v-doc-line-chg-qnty = 0
    .

    if ub.doc-line.fact-qnty < 0 then do:
      message
        vss-workfile vss-revision vss-description skip
        "В документе внутреннего перемещения" skip
        "фактическое количество в линии не может быть отрицательным" skip
        "Документ внутреннего перемещения" ub.trn-doc.doc-code skip
        "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
        "Фактическое количество" ub.doc-line.fact-qnty skip
        view-as alert-box error .
      undo, return error .
    end.

    if ub.doc-line.fact-qnty > ub.doc-line.doc-qnty then do:
      message
        vss-workfile vss-revision vss-description skip
        "В документе внутреннего перемещения" skip
        "фактическое количество в линии" skip
        "не может превышать количество по документу" skip
        "Документ внутреннего перемещения" ub.trn-doc.doc-code skip
        "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
        view-as alert-box error .
      undo, return error .
    end.

    if ub.trn-doc.doc-type = {&expense}
    and ub.doc-line.fact-qnty  <> 0
    then do:
      assign
        v-doc-line-chg-qnty = ub.doc-line.fact-qnty
      .
    end.

    if  ub.trn-doc.doc-type = {&income}
    and ub.doc-line.fact-qnty < ub.doc-line.doc-qnty then do:
      assign
        v-doc-line-chg-qnty = ub.doc-line.doc-qnty - ub.doc-line.fact-qnty
      .
    end.

    if v-doc-line-chg-qnty = 0 then do:
      next. /* --->>>--- */
    end.

    assign
      n_str = n_str + 1
    .
    create buf_doc-line.
    assign
      buf_doc-line.doc-code       = buf_trn-doc.doc-code
      buf_doc-line.obj-type       = buf_trn-doc.obj-type
      buf_doc-line.obj-code       = buf_trn-doc.obj-code
      buf_doc-line.artic          = ub.doc-line.artic
      buf_doc-line.prod-type      = ub.doc-line.prod-type
      buf_doc-line.prod-code      = ub.doc-line.prod-code

      buf_doc-line.fact-qnty      = v-doc-line-chg-qnty
      buf_doc-line.price-rubl     = ub.doc-line.price-rubl
      buf_doc-line.price-base     = ub.doc-line.price-base
      buf_doc-line.price-cli      = ub.doc-line.price-base
      buf_doc-line.SLT-pc         = ub.doc-line.SLT-pc
      buf_doc-line.VAT-pc         = ub.doc-line.VAT-pc
      buf_doc-line.cons-vat-pc    = ub.doc-line.cons-vat-pc
      buf_doc-line.road-tax       = ub.doc-line.road-tax
      buf_doc-line.excise         = ub.doc-line.excise
      buf_doc-line.transport-base = ub.doc-line.transport-base
      buf_doc-line.transport-rubl = ub.doc-line.transport-rubl
      buf_doc-line.other-base     = ub.doc-line.other-base
      buf_doc-line.other-rubl     = ub.doc-line.other-rubl
      buf_doc-line.unit-cli       = ( if ub.doc-line.fact-density > 0.00 and ub.doc-line.fact-density < 1.00
                                      then ub.goods.unit-cli
                                      else ub.goods.unit-base ) /* ! */
      buf_doc-line.doc-qnty       = v-doc-line-chg-qnty    /* ожидается расх. факт */
      buf_doc-line.prt-root       = ub.doc-line.prt-root
      buf_doc-line.prt-OK         = yes                    /* а то как же */
      buf_doc-line.fact-order     = 0                      /* еще не факт */
      buf_doc-line.cli-qnty       = v-doc-line-chg-qnty * ( if ub.doc-line.fact-density > 0.00 and ub.doc-line.fact-density < 1.00
                                                            then ub.doc-line.fact-density
                                                            else 1 ) /* ! */
      buf_doc-line.doc-density    = ub.doc-line.fact-density

      /* уже НЕ ВСЕГДА одинаковые едизмы */
      buf_doc-line.cli-base-rate  = ub.doc-line.cli-base-rate

      /* количество мест и вес брутто копируется из исходной накладной */
      buf_doc-line.num-place      = ub.doc-line.num-place * v-doc-line-chg-qnty / ub.doc-line.fact-qnty
      buf_doc-line.wt-brutto      = ub.doc-line.wt-brutto * v-doc-line-chg-qnty / ub.doc-line.fact-qnty
    .
    if buf_doc-line.cli-base-rate = ? then do: assign buf_doc-line.cli-base-rate = 1.00. end.
    if buf_doc-line.doc-density   = ? then do: assign buf_doc-line.doc-density   = 1.00. end.

    assign
      buf_doc-line.fact-density  = buf_doc-line.doc-density
    .

    define variable v-part-chg-qnty as decimal no-undo .

    define variable v-total-parts-cli-qnty as decimal   no-undo .

    assign
      v-total-parts-cli-qnty = 0
    .

    /* создаем партии */
    for each ub.parts
      where ub.parts.obj-type  = ub.doc-line.obj-type
        and ub.parts.obj-code  = ub.doc-line.obj-code
        and ub.parts.artic     = ub.doc-line.artic
        and ub.parts.prod-type = ub.doc-line.prod-type
        and ub.parts.prod-code = ub.doc-line.prod-code
        and ub.parts.out-code  = ub.doc-line.doc-code
    on error undo, return error
    :
      assign
        v-part-chg-qnty = 0
      .

      if ub.parts.fact-qnty < 0 then do:
        message
          vss-workfile vss-revision vss-description skip
          "В документе внутреннего перемещения" skip
          "фактическое количество в партии не может быть отрицательным" skip
          view-as alert-box error .
        undo, return error .
      end.

      if ub.parts.fact-qnty > ub.parts.qnty then do:
        message
          vss-workfile vss-revision vss-description skip
          "В документе внутреннего перемещения" skip
          "фактическое количество в партии" skip
          "не может превышать количество в партии по документу" skip
          view-as alert-box error .
        undo, return error .
      end.

      if l-goods-twounit = true then do:
        if ub.parts.fact-qnty <> ub.parts.qnty
        and ub.parts.fact-qnty <> 0
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "В документе внутреннего перемещения фактическое количество в партии" skip
            "должно или равняться количеству по документу" skip
            "или быть равным нулю" skip
            view-as alert-box error .
          undo, return error .
        end.

        if ub.parts.cli-qnty <> 1
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "В документе внутреннего перемещения количество в ед.изм. поставщика" skip
            "должно должно равняться единице" skip
            view-as alert-box error .
          undo, return error .
        end.
      end.


      if ub.trn-doc.doc-type = {&expense}
      and ub.parts.fact-qnty  <> 0
      then do:
        assign
          v-part-chg-qnty = ub.parts.fact-qnty
        .
      end.

      if  ub.trn-doc.doc-type = {&income}
      and ub.parts.fact-qnty < ub.parts.qnty then do:
        assign
          v-part-chg-qnty = ub.parts.qnty - ub.parts.fact-qnty
        .
      end.

      if v-part-chg-qnty = 0 then do:
        next. /* --->>>--- */
      end.

      if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Object} then do : 
          find first ub.goods no-lock
               where ub.goods.artic     = ub.doc-line.artic
                 and ub.goods.prod-type = ub.doc-line.prod-type
                 and ub.goods.prod-code = ub.doc-line.prod-code .
          find first buf_doc-pl no-lock 
               where buf_doc-pl.obj-type = ub.trn-doc.obj-type
                 and buf_doc-pl.obj-code = ub.trn-doc.obj-code
                 and buf_doc-pl.out-code = ub.trn-doc.doc-code
                 and buf_doc-pl.gds-code = ub.goods.gds-code
                 and buf_doc-pl.pl-code  = ub.parts.pl-code no-error .
          if available buf_doc-pl then do :
              find first  buf_doc-pl-attr exclusive-lock
                    where buf_doc-pl-attr.obj-type    = buf_doc-pl.obj-type
                      and buf_doc-pl-attr.obj-code    = buf_doc-pl.obj-code
                      and buf_doc-pl-attr.pl-code     = buf_doc-pl.pl-code
                      and buf_doc-pl-attr.out-code    = buf_doc-pl.out-code            
                      and buf_doc-pl-attr.gds-code    = buf_doc-pl.gds-code
                      and buf_doc-pl-attr.attr-code   = 'place2' no-error .
              if not available buf_doc-pl-attr then do :
                  undo, return error ("Ошибка! " + return-value) .
              end.
          end.
      end.
      
      
      find first ub.goods no-lock where ub.goods.artic      = ub.parts.artic
                                    and ub.goods.prod-type  = ub.parts.prod-type
                                    and ub.goods.prod-code  = ub.parts.prod-code .
      
      find first ub.alc-type-gds no-lock
        where ub.alc-type-gds.gds-code = ub.goods.gds-code and
        ub.alc-type-gds.create-user-db-num = 0 no-error.

      create buf_parts .
      buffer-copy ub.parts to buf_parts
      assign
        buf_parts.out-code  = buf_trn-doc.doc-code
        buf_parts.obj-type  = buf_trn-doc.obj-type
        buf_parts.obj-code  = buf_trn-doc.obj-code
        buf_parts.status_   = no
        buf_parts.rsrv-free = ?
        buf_parts.pl-code   = if available buf_doc-pl-attr then integer(buf_doc-pl-attr.attr-value) else 0

        buf_parts.qnty      = v-part-chg-qnty
        buf_parts.fact-qnty = buf_parts.qnty
        buf_parts.cli-qnty  = 0
        buf_parts.part-code = if available buf_doc-pl-attr then buf_doc-pl-attr.attr-value 
          else (if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem} and available (ub.alc-type-gds) then buf_parts.out-code + "," + ub.parts.part-code else ub.parts.part-code)
      .
          /*определение атрибута товара на маркирование*/

    define buffer buf_marking for ub.marking .
    define buffer buf_marking-lines for ub.marking-lines .

    RUN gds-attr-value (
                        INPUT ub.goods.gds-code,
                        INPUT {&attr-mark-type},
                        OUTPUT v-gds-attr-value-old,
                        OUTPUT v-gds-attr-type
                        ).
                            
    if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(ub.parts.obj-type, ub.parts.obj-code):GetIsMarkingForType(v-gds-attr-value-old) then do:
      for each ub.marking-lines no-lock where ub.marking-lines.gds-code = ub.goods.gds-code
                                            and ub.marking-lines.part-code = ub.parts.part-code
                                            and ub.marking-lines.prt-code = ub.parts.prt-code
                                            and ub.marking-lines.in-code = ub.parts.in-code
                                            and ub.marking-lines.out-code = ub.parts.out-code
                                            and ub.marking-lines.obj-code = ub.parts.obj-code
                                            and ub.marking-lines.obj-type = ub.parts.obj-type,
            first buf_marking exclusive-lock where buf_marking.mark = ub.marking-lines.mark:
    
            find first buf_marking-lines no-lock where buf_marking-lines.in-code    = buf_parts.in-code
                                                   and buf_marking-lines.out-code   = buf_parts.out-code
                                                   and buf_marking-lines.part-code  = buf_parts.part-code
                                                   and buf_marking-lines.prt-code   = buf_parts.prt-code
                                                   and buf_marking-lines.obj-code   = buf_parts.obj-code
                                                   and buf_marking-lines.obj-type   = buf_parts.obj-type
                                                   and buf_marking-lines.gds-code   = ub.marking-lines.gds-code
                                                   and buf_marking-lines.mark       = ub.marking-lines.mark
                                                   no-error .
            if buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Perem} then do: /*Если внутренний возврат*/
                if not ub.marking-lines.sts = ObjSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB then do:  /*Если марка не проверена*/
                    if not available buf_marking-lines then do :
                      create buf_marking-lines .
                      buffer-copy ub.marking-lines to buf_marking-lines
                      assign
                        buf_marking-lines.out-code = buf_parts.out-code
                        buf_marking-lines.obj-code = buf_parts.obj-code
                        buf_marking-lines.obj-type = buf_parts.obj-type
                      .
                    end .                                                    
                    assign
                      buf_marking.obj-code = buf_trn-doc.obj-code
                      buf_marking.obj-type = buf_trn-doc.obj-type
                      buf_marking.sts      = ObjSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB
                    .
                end.
            end.
            else do:
                if not available buf_marking-lines  then do :
                  create buf_marking-lines .
                  buffer-copy ub.marking-lines to buf_marking-lines
                  assign
                    buf_marking-lines.out-code = buf_parts.out-code
                    buf_marking-lines.obj-code = buf_parts.obj-code
                    buf_marking-lines.obj-type = buf_parts.obj-type
                    buf_marking-lines.sts = ObjSrv:Env:Marking:Sts:Mark:PendingVerification:KeyIntDB
                  .
                end .                                       
                assign
                  buf_marking.obj-code = buf_trn-doc.obj-code
                  buf_marking.obj-type = buf_trn-doc.obj-type
                  buf_marking.sts      = ObjSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB
                .
                run str/callnews.p                                         
                  (input {&table_marking}
                  ,input (buffer buf_marking :handle)
                  ) no-error .
                if error-status:error then 
                do:
                end.
            end.  
        end.  /* for each ub.marking-lines */
    end.
           
    
      if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Object} or (buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem} and available (ub.alc-type-gds)) then do :
          find first ub.goods no-lock where ub.goods.artic      = buf_parts.artic
                                        and ub.goods.prod-type  = buf_parts.prod-type
                                        and ub.goods.prod-code  = buf_parts.prod-code .
          find first buf_parts-attr no-lock
               where buf_parts-attr.in-code   = buf_parts.in-code
                 and buf_parts-attr.gds-code  = ub.goods.gds-code
                 and buf_parts-attr.part-code = buf_parts.part-code
                 no-error .
          if not available buf_parts-attr then do :
                run get-country-code in this-procedure
                  (input  buf_trn-doc.doc-code     /* p-doc-code     */
                  ,input  buf_trn-doc.ext-doc-type /* p-ext-doc-type */
                  ,input  ub.goods.gds-code               /* p-gds-code     */
                  ,output v-country-code           /* p-country-code */
                  ) .
              
                create new_parts-attr .

                assign
                  new_parts-attr.in-code              = buf_parts.in-code
                  new_parts-attr.gds-code             = ub.goods.gds-code
                  new_parts-attr.part-code            = buf_parts.part-code
                  new_parts-attr.orig-in-code         = buf_parts.in-code
                  new_parts-attr.orig-gds-code        = ub.goods.gds-code
                  new_parts-attr.orig-part-code       = buf_parts.part-code
                  new_parts-attr.income-in-code       = buf_parts.in-code
                  new_parts-attr.income-gds-code      = ub.goods.gds-code
                  new_parts-attr.income-part-code     = buf_parts.part-code
                  new_parts-attr.supp-type            = buf_parts.supp-type
                  new_parts-attr.supp-code            = buf_parts.supp-code
                  new_parts-attr.pay-code             = buf_parts.pay-code
                  new_parts-attr.purch-code           = buf_parts.purch-code
                  new_parts-attr.cli-qnty             = buf_parts.cli-qnty
                  new_parts-attr.price-cli            = buf_parts.price-cli
                  new_parts-attr.unit-cli             = buf_doc-line.unit-cli
                  new_parts-attr.exch-code            = buf_parts.exch-code
                  new_parts-attr.exch-rate            = buf_trn-doc.exch-rate
                  new_parts-attr.exch-scale           = buf_trn-doc.exch-scale
                  new_parts-attr.cli-base-rate        = buf_parts.cli-base-rate
                  new_parts-attr.doc-qnty             = buf_parts.qnty
                  new_parts-attr.fact-qnty            = buf_parts.fact-qnty
                  new_parts-attr.real-qnty            = buf_parts.real-qnty
                  new_parts-attr.price-base           = buf_parts.price-base
                  new_parts-attr.price-rubl           = buf_parts.price-rubl
                  new_parts-attr.base-rate            = buf_trn-doc.base-rate
                  new_parts-attr.base-scale           = buf_trn-doc.base-scale
                  new_parts-attr.vat-type             = buf_parts.vat-type
                  new_parts-attr.vat-pc               = buf_parts.vat-pc
                  new_parts-attr.SLT-type             = buf_parts.SLT-type
                  new_parts-attr.SLT-pc               = buf_parts.SLT-pc
                  new_parts-attr.road-tax-base        = buf_parts.road-tax-base
                  new_parts-attr.road-tax-rubl        = buf_parts.road-tax-rubl
                  new_parts-attr.transport-base       = buf_parts.transport-base
                  new_parts-attr.transport-rubl       = buf_parts.transport-rubl
                  new_parts-attr.other-base           = buf_parts.other-base
                  new_parts-attr.other-rubl           = buf_parts.other-rubl
                  new_parts-attr.density              = buf_doc-line.doc-density
                  new_parts-attr.temperature          = buf_doc-line.temperature
                  new_parts-attr.is-supp              = buf_parts.is-supp
                  new_parts-attr.cst-code             = buf_parts.cst-code
                  new_parts-attr.last-date            = buf_parts.last-date
                  new_parts-attr.line-cli-qnty        = buf_doc-line.cli-qnty
                  new_parts-attr.line-doc-qnty        = buf_doc-line.doc-qnty
                  new_parts-attr.line-fact-qnty       = buf_doc-line.fact-qnty
                  new_parts-attr.wt-brutto            = buf_doc-line.wt-brutto
                  new_parts-attr.num-place            = buf_doc-line.num-place
                  new_parts-attr.country-code         = v-country-code
                  new_parts-attr.obj-type             = buf_trn-doc.obj-type
                  new_parts-attr.obj-code             = buf_trn-doc.obj-code
                  new_parts-attr.PS                   = buf_parts.PS
                  new_parts-attr.fact-date            = ub.trn-doc.fact-date
                  new_parts-attr.fact-time            = ub.trn-doc.fact-time
                  new_parts-attr.fact-order           = ub.trn-doc.fact-order
                  new_parts-attr.shift-num            = buf_trn-doc.shift-num
                  new_parts-attr.shift-name           = buf_trn-doc.shift-name
                  new_parts-attr.shift-date           = buf_trn-doc.shift-date
                  new_parts-attr.ext-doc-type         = buf_trn-doc.ext-doc-type
                  new_parts-attr.wrkr                 = buf_trn-doc.wrkr
                  new_parts-attr.agnt                 = buf_trn-doc.agnt
                  new_parts-attr.boss                 = buf_trn-doc.boss
                  new_parts-attr.creid                = buf_trn-doc.creid
                  new_parts-attr.out-code             = buf_trn-doc.out-code
                  new_parts-attr.inv-num              = buf_trn-doc.inv-num
                  new_parts-attr.cli-name             = buf_trn-doc.cli-name
                  new_parts-attr.ord-num              = buf_trn-doc.ord-num
                  new_parts-attr.is-back-date         = buf_trn-doc.is-back-date
                  new_parts-attr.is-corr              = buf_trn-doc.is-corr
                  new_parts-attr.is-del               = buf_trn-doc.is-del
                  new_parts-attr.contract-code        = buf_parts.contract-code
                  new_parts-attr.hold-doc-code-child  = buf_trn-doc.hold-doc-code-child
                  new_parts-attr.hold-doc-code-parent = buf_trn-doc.hold-doc-code-parent
                .
    
                { str/in-vatp.i calc-parts buf_parts. " " loc}
    
                assign
                  new_parts-attr.vat-base         = vat-base-loc
                  new_parts-attr.vat-rubl         = vat-rubl-loc
                  new_parts-attr.slt-base         = slt-base-loc
                  new_parts-attr.slt-rubl         = slt-rubl-loc
                  new_parts-attr.discnt-base      = 0
                  new_parts-attr.discnt-rubl      = 0
                .
          end.
      end.

      if l-goods-twounit = true
        or ( is-petrolium = true
             and is-pieces = false
           )
      then do:
        assign
          buf_parts.cli-qnty = ub.parts.cli-qnty
        .
        assign
          v-total-parts-cli-qnty = buf_parts.cli-qnty
        .
      end.

      if buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Perem}
        and is-petrolium = true
        and is-pieces = false
      then do:
        if num-entries( buf_parts.part-code, {&part-split} ) > 1 then do:
          run trg/partjoin.p
            ( input buf_parts.obj-type
             ,input buf_parts.obj-code
             ,input buf_parts.artic
             ,input buf_parts.prod-type
             ,input buf_parts.prod-code
             ,input buf_parts.in-code
             ,input buf_parts.out-code
             ,input buf_parts.part-code
            ) no-error.
          if error-status :error then do:
            undo, return error substitute( "&1 (partjoin). Не удалось объединить партию с номером &2!&3&4&3&5", vss-workfile, buf_parts.part-code, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
          end.
        end.
      end.
    end. /* for each parts ...  */

    if buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Perem}
      and is-petrolium = true
      and is-pieces = false
    then do:
      undo, return error substitute( "&1. Запрещено создание возврата топливного товара.", vss-workfile ).
/*      пока запрещено, это коментарим*/
/*      find first buf-first_trn-doc no-lock*/
/*        where buf-first_trn-doc.doc-code = ub.trn-doc.out-code*/
/*        .*/
/*      for each buf-first_parts no-lock*/
/*        where buf-first_parts.obj-type  = buf-first_trn-doc.obj-type*/
/*          and buf-first_parts.obj-code  = buf-first_trn-doc.obj-code*/
/*          and buf-first_parts.artic     = ub.goods.artic*/
/*          and buf-first_parts.prod-type = ub.goods.prod-type*/
/*          and buf-first_parts.prod-code = ub.goods.prod-code*/
/*          and buf-first_parts.out-code  = buf-first_trn-doc.doc-code*/
/*      on error undo, return error return-value*/
/*      :*/
/*        find first buf_parts*/
/*          where buf_parts.obj-type  = buf_doc-line.obj-type*/
/*            and buf_parts.obj-code  = buf_doc-line.obj-code*/
/*            and buf_parts.artic     = buf_doc-line.artic*/
/*            and buf_parts.prod-type = buf_doc-line.prod-type*/
/*            and buf_parts.prod-code = buf_doc-line.prod-code*/
/*            and buf_parts.in-code   = buf-first_parts.in-code*/
/*            and buf_parts.out-code  = buf_doc-line.doc-code*/
/*            and buf_parts.part-code = buf-first_parts.part-code*/
/*          no-error .*/
/*        if available buf_parts then do:*/
/*          assign*/
/*            buf_parts.pl-code = buf-first_parts.pl-code*/
/*          .*/
/*          { str/crdocpl.i*/
/*            buf_trn-doc.doc-code*/
/*            ub.goods.gds-code*/
/*            buf_parts.pl-code*/
/*            buf_trn-doc.obj-type*/
/*            buf_trn-doc.obj-code*/
/*            v-doc-pl-rowid*/
/*            no-error*/
/*          }*/
/*          if error-status:error then do:*/
/*            undo, return error substitute("&1. В документе &3 для товара &4 не удалось создать строку для места хранения &5&2&6&7"*/
/*                                          , vss-workfile*/
/*                                          , {&new-line}*/
/*                                          , buf_trn-doc.doc-code*/
/*                                          , ub.goods.gds-code*/
/*                                          , buf_parts.pl-code*/
/*                                          , return-value*/
/*                                          , error-status :get-message( error-status :num-messages )*/
/*                                          ).*/
/*          end.*/
/*          find first buf_doc-pl*/
/*            where rowid(buf_doc-pl) = v-doc-pl-rowid*/
/*            .*/
/*          assign*/
/*            buf_doc-pl.cli-qnty      = buf_doc-pl.cli-qnty      + buf_parts.qnty / buf_doc-line.cli-base-rate*/
/*            buf_doc-pl.doc-qnty      = buf_doc-pl.doc-qnty      + buf_parts.qnty*/
/*            buf_doc-pl.cli-doc-qnty  = buf_doc-pl.cli-doc-qnty  + buf_parts.qnty * buf_doc-line.doc-density*/
/*            buf_doc-pl.fact-qnty     = buf_doc-pl.fact-qnty     + buf_parts.fact-qnty*/
/*            buf_doc-pl.cli-fact-qnty = buf_doc-pl.cli-fact-qnty + buf_parts.fact-qnty * buf_doc-line.fact-density*/
/*          .*/
/*        end.*/
/*      end.*/
    end.

    if l-goods-twounit = true then do:
      assign
        buf_doc-line.cli-qnty = v-total-parts-cli-qnty
      .
      if buf_doc-line.cli-qnty <> 0 then do:
        assign
          buf_doc-line.cli-base-rate = buf_doc-line.doc-qnty / buf_doc-line.cli-qnty
        .
      end.
    end.

    /* вычисляем среднюю учетную цену */
    define variable v-total-parts-qnty as decimal no-undo .
    define variable v-total-price-base as decimal no-undo .
    define variable v-total-price-rubl as decimal no-undo .

    assign
      v-total-parts-qnty = 0
      v-total-price-base = 0
      v-total-price-rubl = 0
    .

    for each ub.parts
      where ub.parts.obj-type  = buf_doc-line.obj-type
        and ub.parts.obj-code  = buf_doc-line.obj-code
        and ub.parts.artic     = buf_doc-line.artic
        and ub.parts.prod-type = buf_doc-line.prod-type
        and ub.parts.prod-code = buf_doc-line.prod-code
        and ub.parts.out-code  = buf_doc-line.doc-code
    on error undo, return error
    :
      assign
        v-total-parts-qnty = v-total-parts-qnty + parts.fact-qnty
        v-total-price-base = v-total-price-base + parts.fact-qnty * parts.price-base
        v-total-price-rubl = v-total-price-rubl + parts.fact-qnty * parts.price-rubl
      .
    end.

    if v-doc-line-chg-qnty <> v-total-parts-qnty then do:
      message
        vss-workfile vss-revision vss-description skip
        "Количество в партиях не совпадает с количеством в строке документа." skip
        "Количество по документу = " v-doc-line-chg-qnty skip
        "Количество по партиям = " v-total-parts-qnty skip
        view-as alert-box .
      undo, return error.
    end.

    if v-total-parts-qnty <> 0 then do:
      assign
        buf_doc-line.price-rubl = v-total-price-rubl / v-total-parts-qnty
        buf_doc-line.price-base = v-total-price-base / v-total-parts-qnty
        buf_doc-line.price-cli  = v-total-price-base / v-total-parts-qnty
      .
    end.

    define variable v-prt-create-n-c like ub.gds-prt.node-code no-undo .

    if cli_doc-prt <> obj_doc-prt then do:
      /* атрибуты "признаки включены/выключены" отличаются для объектов
        необходимо преобразование gds-dtl
      */
      /* если на объекте, куда мы перемещаем товар - выключены признаки
            то gds-dtl необходимо привязать к корню
        если на объекте, куда мы перемещаем товар - включены признаки
            то gds-dtl необходимо привязать к первому терминальному признаку
      */

      /* ищем корневой признак для товара */
      { gbl/rootnode.i
        ub.goods.artic
        ub.goods.prod-type
        ub.goods.prod-code
        v-prt-create-n-c
      }
      if cli_doc-prt = true then do:
        /* признаки включены - ищем первый терминальный признак */
        { gbl/termnode.i
          v-prt-create-n-c
          v-prt-create-n-c
        }
      end.
    end.

    define variable v-gds-dtl-chg-qnty   as decimal no-undo .
    define variable v-total-gds-dtl-qnty as decimal no-undo .
    define variable v-create-n-c like ub.gds-prt.node-code no-undo .

    assign
      v-total-gds-dtl-qnty = 0
    .

    for each ub.gds-dtl no-lock
      where ub.gds-dtl.doc-code  = ub.doc-line.doc-code
        and ub.gds-dtl.prod-type = ub.doc-line.prod-type
        and ub.gds-dtl.prod-code = ub.doc-line.prod-code
        and ub.gds-dtl.artic     = ub.doc-line.artic
    on error undo, return error
    :
      assign
        v-gds-dtl-chg-qnty = 0
      .

      if ub.gds-dtl.fact-qnty < 0 then do:
        message
          vss-workfile vss-revision vss-description skip
          "В документе внутреннего перемещения в строке признака" skip
          "не может быть задано отрицательное количество" skip
          view-as alert-box error .
        undo, return error .
      end.

      if ub.trn-doc.doc-type = {&expense}
      and ub.gds-dtl.fact-qnty  <> 0
      then do:
        assign
          v-gds-dtl-chg-qnty = ub.gds-dtl.fact-qnty
        .
      end.

      if ub.trn-doc.doc-type = {&income} then do:
        if  cli_doc-prt = no
        and obj_doc-prt = yes then do:
          /* перемещение происходило с объекта, где признаки выключены
            на объект, где признаки включены
            fact-qnty может быть больше, чем doc-qnty
          */
          if ub.gds-dtl.fact-qnty <> ub.gds-dtl.doc-qnty then do:
            assign
              v-gds-dtl-chg-qnty = ub.gds-dtl.doc-qnty - ub.gds-dtl.fact-qnty
            .
          end.
        end.
        else do:
          if ub.gds-dtl.fact-qnty > ub.gds-dtl.doc-qnty then do:
            message
              vss-workfile vss-revision vss-description skip
              "В приходном документе в строке признака" skip
              "фактическое количество не может быть больше, чем количество по документу" skip
              view-as alert-box error .
            undo, return error .
          end.
          if ub.gds-dtl.fact-qnty < ub.gds-dtl.doc-qnty then do:
            assign
              v-gds-dtl-chg-qnty = ub.gds-dtl.doc-qnty - ub.gds-dtl.fact-qnty
            .
          end.
        end.
      end.

      if v-gds-dtl-chg-qnty = 0 then do:
        next. /* --->>>--- */
      end.

      if cli_doc-prt = obj_doc-prt then do:
        assign
          v-create-n-c = ub.gds-dtl.prt-code
        .
      end.
      else do:
        assign
          v-create-n-c = v-prt-create-n-c
        .
      end.

      find first buf_gds-dtl
        where buf_gds-dtl.doc-code    = buf_trn-doc.doc-code
          and buf_gds-dtl.artic       = ub.doc-line.artic
          and buf_gds-dtl.prod-type   = ub.doc-line.prod-type
          and buf_gds-dtl.prod-code   = ub.doc-line.prod-code
          and buf_gds-dtl.prt-code    = v-create-n-c
        no-error .
      if not available buf_gds-dtl then do:
        create buf_gds-dtl.
        assign
          buf_gds-dtl.doc-code    = buf_trn-doc.doc-code
          buf_gds-dtl.artic       = ub.doc-line.artic
          buf_gds-dtl.prod-type   = ub.doc-line.prod-type
          buf_gds-dtl.prod-code   = ub.doc-line.prod-code
          buf_gds-dtl.prt-code    = v-create-n-c
          buf_gds-dtl.obj-type    = buf_trn-doc.obj-type
          buf_gds-dtl.obj-code    = buf_trn-doc.obj-code
        .

        if cli_doc-prt = obj_doc-prt then do:
          assign
            buf_gds-dtl.discnt-base = ub.gds-dtl.discnt-base
            buf_gds-dtl.discnt-rubl = ub.gds-dtl.discnt-rubl
            buf_gds-dtl.discnt-pc   = ub.gds-dtl.discnt-pc
            buf_gds-dtl.discnt-type = ub.gds-dtl.discnt-type
          .
        end.
        else do:
          /* ??? что это означает
            мы игнорируем скидку, если производим перемещение на объект,
            с противоположным атрибутом "признаки включены/выключены"
            */
          assign
            buf_gds-dtl.discnt-base = 0
            buf_gds-dtl.discnt-rubl = 0
            buf_gds-dtl.discnt-pc   = 0
            buf_gds-dtl.discnt-type = ?
          .
        end.
      end.
      assign
        buf_gds-dtl.price-base     = ( buf_gds-dtl.price-base * buf_gds-dtl.fact-qnty
                                  + ub.gds-dtl.price-base * v-gds-dtl-chg-qnty )
                                  / (buf_gds-dtl.fact-qnty + v-gds-dtl-chg-qnty)
        buf_gds-dtl.price-rubl     = ( buf_gds-dtl.price-rubl * buf_gds-dtl.fact-qnty
                                  + ub.gds-dtl.price-rubl * v-gds-dtl-chg-qnty )
                                  / (buf_gds-dtl.fact-qnty + v-gds-dtl-chg-qnty)
        buf_gds-dtl.new-price-sale = ub.gds-dtl.new-price-sale
        buf_gds-dtl.ov             = yes
        buf_gds-dtl.fact-qnty      = buf_gds-dtl.fact-qnty + v-gds-dtl-chg-qnty
        buf_gds-dtl.doc-qnty       = buf_gds-dtl.doc-qnty  + v-gds-dtl-chg-qnty
        v-total-gds-dtl-qnty       = v-total-gds-dtl-qnty + v-gds-dtl-chg-qnty
      .
    end.


    if v-total-gds-dtl-qnty <> v-doc-line-chg-qnty then do:
      message
        vss-workfile vss-revision vss-description skip
        "Количество в признаках не совпадает с количеством в строке документа." skip
        "Количество по документу = " v-doc-line-chg-qnty skip
        "Количество по признакам = " v-total-gds-dtl-qnty skip
        view-as alert-box .
      undo, return error.
    end.
  end.

  if not can-find(first ub.doc-line
    where ub.doc-line.doc-code = buf_trn-doc.doc-code)
  then do:
    /* не было создано ни одной линии */
    /* удаляем документ */
    delete buf_trn-doc.
    return .
  end.

  assign
    buf_trn-doc.PS          = '@  Строк в документе : ' + string(n_str) + (if substring(ub.trn-doc.ps, 1, 1) = '@' then '' else {&new-line} + ub.trn-doc.ps)
    buf_trn-doc.fact-base   = ?
    buf_trn-doc.fact-rubl   = ?
  .

  /* рассчитываем шапку накладной */
  run gbl/calc-trn.p (input ? , INPUT RECID(buf_trn-doc)).
  /* создадим если надо поставку ранье чем уйдет в новости */

  run cus/oo-mkrcv.p (
        buffer ub.trn-doc ,
        buffer buf_trn-doc )
        no-error .
   if error-status :error then
   message vss-workfile vss-revision vss-description skip
          "Ошибка oo-mkrcv.p  " skip
           skip
           error-status :get-message(1) skip
           error-status :get-message(2) skip
           return-value skip
           view-as alert-box error
   .

  /* закрываем накладную       */
  /* она должна уйти в новости */
  assign
    buf_trn-doc.flag_ = yes
  .
  /* Ассортиментная политика */
  /* Проверка ассортиментной политики */
  for each buf_doc-line where buf_doc-line.doc-code = buf_trn-doc.doc-code on error undo, return error return-value :
    find first ub.goods where
              ub.goods.artic     = buf_doc-line.artic     and
              ub.goods.prod-type = buf_doc-line.prod-type and
              ub.goods.prod-code = buf_doc-line.prod-code no-lock.
    var-ok-assort-pol = true .
    if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem} then do:
       v-event-code = substitute("&1" , buf_trn-doc.ext-doc-type ) .
        { gbl/goassizt.i
          v-event-code
          ub.goods.gds-code
          buf_trn-doc.obj-type
          buf_trn-doc.obj-code
          false
          var-ok-assort-pol
          var-mess-assort-pol
        }
    end.
    if var-ok-assort-pol = false then do:
        buf_trn-doc.PS = buf_trn-doc.PS + {&new-line} + var-mess-assort-pol .
    end.
  end.
  /* рассчитываем шапку накладной */
  run gbl/calc-trn.p (input ? /*parparentproc*/ , input recid(buf_trn-doc)) no-error.
  if error-status :error then do:
    undo, return error return-value.
  end.
  
  

  /*  if  g#news*/
  /*  and doc-obj.db-num <> 0 or clients.db-num <> 0 then do:*/
  /*    /* маршрутизируем документ для отправки в УБД */*/
  /*    /* здесь обрабатывается случай  */*/
  /*  теперь все должно уходить стандартно, так же как и с обычными документами!!! */
  /*    run str/callnews.p*/
  /*      ( input "trn-doc"*/
  /*       ,input (buffer buf_trn-doc:handle)*/
  /*      ) no-error .*/
  /*    if error-status :error*/
  /*    then do:*/
  /*      message*/
  /*        vss-workfile vss-revision vss-description skip*/
  /*        "Ошибка при отправке документа в новости" skip*/
  /*        "Документ внутреннего перемещения" buf_trn-doc.doc-code skip*/
  /*        "Объект" buf_trn-doc.obj-type buf_trn-doc.obj-code skip*/
  /*        view-as alert-box error .*/
  /*      undo, return error return-value .*/
  /*    end.*/
  /*  end.*/

  /*обнуляем фактическое кол-во для приходной накладной, для продукции маркированной*/


  define variable v-qnty as decimal no-undo .
  if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(buf_trn-doc.obj-type, buf_trn-doc.obj-code):GetIsMarkingForType(v-gds-attr-value-old) then 
  do:
    if buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Perem} then 
    do: /*Если внутренний возврат*/
      for each ub.doc-line no-lock where ub.doc-line.doc-code = buf_trn-doc.doc-code: 

        for each ub.marking-lines no-lock where ub.marking-lines.gds-code = ub.goods.gds-code
          and ub.marking-lines.out-code = ub.trn-doc.doc-code
          and ub.marking-lines.obj-code = ub.trn-doc.obj-code
          and ub.marking-lines.obj-type = ub.trn-doc.obj-type,
          first buf_marking exclusive-lock where buf_marking.mark = ub.marking-lines.mark:
        
          if ub.marking-lines.sts = ObjSrv:Env:Marking:Sts:Mark:UnknowSts:KeyIntDB then 
          do:

                                             
            assign
              buf_marking.sts = ObjSrv:Env:Marking:Sts:Mark:UnknowSts:KeyIntDB
              .
          end.

        end.
      end.
    end.
    if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem} then 
    do:
      for each buf_doc-line exclusive-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code,
        first buf_gds-dtl exclusive-lock where buf_gds-dtl.doc-code = buf_doc-line.doc-code and buf_gds-dtl.artic = buf_doc-line.artic and
        buf_gds-dtl.prod-code = buf_doc-line.prod-code and buf_gds-dtl.prod-type = buf_doc-line.prod-type:
        /*проверять на маркирование?*/
        v-qnty = v-qnty + buf_doc-line.fact-qnty .
        buf_doc-line.fact-qnty = 0 .
        buf_gds-dtl.fact-qnty = buf_doc-line.fact-qnty .
        for first buf_parts exclusive-lock where buf_parts.out-code = buf_doc-line.doc-code and buf_parts.artic = buf_doc-line.artic and
          buf_parts.prod-code = buf_doc-line.prod-code and buf_parts.prod-type = buf_doc-line.prod-type and buf_parts.obj-code = buf_doc-line.obj-code and
          buf_parts.obj-type = buf_doc-line.obj-type:
          buf_parts.fact-qnty = buf_doc-line.fact-qnty .
        end.  
      end.
      buf_trn-doc.fact-qnty = buf_trn-doc.fact-qnty - v-qnty .
    end.   
  end.
/*        buf_gds-dtl.fact-qnty = 0 .*/
end.

procedure get-country-code :

  define input  parameter p-trn-doc      as character no-undo .
  define input  parameter p-ext-doc-type as character no-undo .
  define input  parameter p-gds-code     as integer   no-undo .
  define output parameter p-country-code as integer   no-undo .

  define buffer buf_goods   for ub.goods .
  define buffer buf_country for ub.country .

  define variable v-read-default-code as logical   no-undo .
  define variable v-attr-value        as character no-undo .
  define variable v-attr-type         as character no-undo .

  do
  on error undo, return error return-value
  :
    assign
      v-read-default-code = true
    .

    if p-ext-doc-type = {&TDEDT_Pri_Vnesh}
    then do:
      run lineattr-value in this-procedure
        (input  p-trn-doc               /* p-doc-code */
        ,input  p-gds-code               /* p-gds-code */
        ,input  {&lineattr-country-code} /* p-code     */
        ,output v-attr-value             /* p-value    */
        ,output v-attr-type              /* p-type     */
        ) .
      if v-attr-value <> ""
      then do:
        assign
          v-read-default-code = false
          p-country-code      = integer(v-attr-value)
        .
      end.
    end.

    if v-read-default-code = true
    then do:
      find first buf_goods no-lock
        where buf_goods.gds-code = p-gds-code
        no-error .
      find first buf_country no-lock
        where buf_country.alpha1 = buf_goods.alpha1
        no-error .
      if available buf_country
      then do:
        assign
          p-country-code = buf_country.num-code
        .
      end.
      else do:
        assign
          p-country-code = 0
        .
      end.
    end.
  end.

end procedure. /* get-country-code */

