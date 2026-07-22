block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Снятие резервирования по строке для любого документа

Автор: Чернова Светлана Александровна
Дата создания: 03/24/08
Author: Svetlana Chernova
Creation date: 03/24/08

Автор1: Суслов Алексей Юрьевич
Дата создания: 09/19/05

TODO - добавить проверки, что нельзя удалять документы перемещени

Для удаления любого документа необходимо сначала снять резервы,
а затем удалить строку документа.

*/

using ibs.th.str.alcohol.*.

define input  parameter p-doc-code  like ub.doc-line.doc-code  no-undo .
define input  parameter p-artic     like ub.doc-line.artic     no-undo .
define input  parameter p-prod-type like ub.doc-line.prod-type no-undo .
define input  parameter p-prod-code like ub.doc-line.prod-code no-undo .

define variable chg-qnty      as   decimal no-undo .

define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Снятие резервирования по строке для любого документа":U.

{ cmp/vssrevis.i "substitute( '&1|&2|&3|&4', p-doc-code, p-artic, p-prod-type, p-prod-code )" }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ str/hvrdtax.i  }
{ trg/partrqst.i }
{ gbl/key-rec.i  }
{ trg/partcopy.i }
{ trg/trndocrs.i }
{ trg/rsrvindl.i }
{ trg/partslib.i }
{ trg/factord.i  }

define variable v-need-rsrv       as logical   no-undo .
define variable v-reserv-pl-code  as logical   no-undo .
define variable v-total-doc-qnty  as decimal   no-undo .
define variable r-rec-inv-line    as recid     no-undo .
define variable v-before-cli-qnty like ub.inv-line.before-cli-qnty   no-undo .

define buffer buf_doc-line    for ub.doc-line .
define buffer buf_trn-doc     for ub.trn-doc .
define buffer buf_gds-dtl     for ub.gds-dtl .
define buffer buf_gds-obj     for ub.gds-obj .
define buffer buf_prt-obj     for ub.prt-obj .
define buffer buf_parts       for ub.parts .
define buffer buf_doc-prts    for ub.doc-prts .
define buffer buf_doc-pl      for ub.doc-pl .
define buffer buf_doc-pl-pump for ub.doc-pl-pump .
define buffer buf_doc-fbr-gds for ub.doc-fbr-gds .
define buffer buf_inv-line    for ub.inv-line .
define buffer buf_marking-lines for ub.marking-lines .
define buffer buf_marking     for ub.marking .
define variable part-key-rec as character no-undo .
 
do transaction
on error undo, return error return-value
:

  find first buf_doc-line exclusive-lock
    where buf_doc-line.doc-code  = p-doc-code
      and buf_doc-line.artic     = p-artic
      and buf_doc-line.prod-type = p-prod-type
      and buf_doc-line.prod-code = p-prod-code
    no-error .
  if not available buf_doc-line
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Документ" p-doc-code skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      view-as alert-box error .
    undo, return error .
  end.

  find first buf_trn-doc no-lock
    where buf_trn-doc.doc-code = buf_doc-line.doc-code
    no-error .
  if not available buf_trn-doc
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найден документ для строки документа" skip
      "Документ" p-doc-code skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      view-as alert-box error .
    undo, return error .
  end.

  find first buf_inv-line no-lock where
             buf_inv-line.doc-code  = buf_doc-line.doc-code  and
             buf_inv-line.artic     = buf_doc-line.artic     and
             buf_inv-line.prod-type = buf_doc-line.prod-type and
             buf_inv-line.prod-code = buf_doc-line.prod-code no-error .
  if available buf_inv-line
  then do:
    assign
      r-rec-inv-line = recid( buf_inv-line )
    .
    find first buf_inv-line exclusive-lock where recid( buf_inv-line ) = r-rec-inv-line.
  end.

  if buf_trn-doc.status_ = {&inquiry}
  then do:
    /* для запросов не нужно производить снятие резервов */
    message
      vss-workfile vss-revision vss-description skip
      "Для запроса недопустима операция снятия резерва" skip
      "Документ" p-doc-code skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      "Статус документа" buf_trn-doc.status_ skip
      view-as alert-box error .
    undo, return error .
  end.

  if buf_doc-line.obj-type <> buf_trn-doc.obj-type
  or buf_doc-line.obj-code <> buf_trn-doc.obj-code
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Строка документа не соответствует документу" skip
      "Не совпадают объекты" skip
      "Документ" p-doc-code skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      "Объект документа" buf_trn-doc.obj-type buf_trn-doc.obj-code skip
      "Объект строки" buf_doc-line.obj-type buf_doc-line.obj-code skip
      view-as alert-box error .
    undo, return error .
  end.

  define variable v-root-node as integer   no-undo .
  define variable v-gds-code  as integer   no-undo .

  /* Определяем корневой признак товара */
  { gbl/rootnode.i
    buf_doc-line.artic
    buf_doc-line.prod-type
    buf_doc-line.prod-code
    v-root-node
    no-error
  }
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении корневого признака" skip
      "Документ" p-doc-code skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      view-as alert-box error .
    undo, return error .
  end.

  { gbl/gds-code.i
    buf_doc-line.artic
    buf_doc-line.prod-type
    buf_doc-line.prod-code
    v-gds-code
    no-error
  }
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при кода товара" skip
      "Документ" p-doc-code skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      view-as alert-box error .
    undo, return error .
  end.


  /* инициализация движения товара на объекте */
  { gbl/gdscr.i
    buf_doc-line.obj-type
    buf_doc-line.obj-code
    buf_doc-line.artic
    buf_doc-line.prod-type
    buf_doc-line.prod-code
    v-root-node
    buf_gds-obj
    buf_prt-obj
    no-error
  }
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при начале движения товара на объекте" skip
      "Документ" p-doc-code skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.

  /* проверяем целостность товара */
  { gbl/gdscheck.i
    buf_doc-line.obj-type
    buf_doc-line.obj-code
    buf_doc-line.artic
    buf_doc-line.prod-type
    buf_doc-line.prod-code
    v-root-node
    "''"
    no-error
  }
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке целостности товара" skip
      "Документ" p-doc-code skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
      "Проверка целостности товара до удаления резервов" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.

  if buf_trn-doc.doc-type = {&income}
  then do:
    /* приходы удаляются без снятия резервов */
    for each buf_parts
      where buf_parts.out-code  = buf_doc-line.doc-code
        and buf_parts.obj-type  = buf_doc-line.obj-type
        and buf_parts.obj-code  = buf_doc-line.obj-code
        and buf_parts.artic     = buf_doc-line.artic
        and buf_parts.prod-type = buf_doc-line.prod-type
        and buf_parts.prod-code = buf_doc-line.prod-code
    on error undo, return error return-value
    :
      run gen-key-rec IN THIS-PROCEDURE (  input {&table_parts}
                                        ,input (buffer buf_parts:handle)
                                        ,output part-key-rec).
      for each ub.gen-attr where ub.gen-attr.table-name = {&excise-mark}
                                     and ub.gen-attr.p-key =  part-key-rec
      on error undo, return error substitute( "&1&2&3", vss-workfile, {&new-line}, return-value )
      :
          delete ub.gen-attr.
      end.
      
      define variable vsds as class ibs.th.str.mercury.vsdsubs no-undo.
      define variable vsdstr as class ibs.th.gbl.storage.vsdtostorage no-undo.
      define variable ii as integer no-undo.
      vsds = new ibs.th.str.mercury.vsdsubs ().
      vsdstr = new ibs.th.gbl.storage.vsdtostorage ().
      vsds = vsdstr:getVSDsubs(input "part-key", input part-key-rec).
      do ii = 1 to vsds:GetItem(ii):
        vsdstr:deleteDB(vsds:VsdObjCurr).
      end.
      delete object vsds no-error.
      delete object vsdstr no-error.
      
      for each buf_marking-lines exclusive-lock where buf_marking-lines.gds-code = v-gds-code
                                                  and buf_marking-lines.obj-type = buf_parts.obj-type
                                                  and buf_marking-lines.obj-code = buf_parts.obj-code
                                                  and buf_marking-lines.in-code  = buf_parts.in-code
                                                  and buf_marking-lines.out-code = buf_parts.out-code
                                                  and buf_marking-lines.part-code = buf_parts.part-code
                                                  and buf_marking-lines.prt-code = buf_parts.prt-code:
/*        for first buf_marking exclusive-lock where buf_marking.mark = buf_marking-lines.mark :*/
/*            assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB .          */
/*        end .                                                                                 */
        delete buf_marking-lines .
      end.
      delete buf_parts .
    end.


    /* удаляем информацию о резервировании партий по строке */
    for each buf_doc-prts exclusive-lock
      where buf_doc-prts.out-code = buf_trn-doc.doc-code
        and buf_doc-prts.gds-code = v-gds-code
    on error undo, return error
    :
      delete buf_doc-prts .
    end.

    /* удаляем информацию о резервировании товара по складским местам */
    for each buf_doc-pl exclusive-lock
      where buf_doc-pl.out-code = buf_doc-line.doc-code
        and buf_doc-pl.gds-code = v-gds-code
    on error undo, return error
    :
      delete buf_doc-pl.
    end.

    for each buf_doc-pl-pump exclusive-lock
      where buf_doc-pl-pump.out-code = buf_doc-line.doc-code
        and buf_doc-pl-pump.gds-code = v-gds-code
    on error undo, return error
    :
      delete buf_doc-pl-pump.
    end.

    /* удаляем информацию о производстве товара на подразделениях */
    for each buf_doc-fbr-gds exclusive-lock
      where buf_doc-fbr-gds.out-code = buf_doc-line.doc-code
        and buf_doc-fbr-gds.gds-code = v-gds-code
    on error undo, return error
    :
      delete buf_doc-fbr-gds.
    end.

  end.
  else do:
    run trndocrs-need-rsrv in this-procedure
      (input  buf_trn-doc.doc-type   /* p-doc-type     */
      ,input  buf_doc-line.artic     /* p-artic        */
      ,input  buf_doc-line.prod-type /* p-prod-type    */
      ,input  buf_doc-line.prod-code /* p-prod-code    */
      ,output v-need-rsrv            /* p-need-rsrv    */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры trndocrs-need-rsrv" skip
        "Документ" buf_trn-doc.doc-type skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    if v-need-rsrv = true
    then do:
      { gbl/gdsobjat.i
        buf_doc-line.obj-type
        buf_doc-line.obj-code
        buf_doc-line.artic
        buf_doc-line.prod-type
        buf_doc-line.prod-code
        "'place-rsrv=request'"
        v-reserv-pl-code
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при запросе атрибута товара" 'place-rsrv=request' skip
          "Документ" p-doc-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
    else do:
      assign
        v-reserv-pl-code = false
      .
    end.

    if v-need-rsrv = true
    then do:
      run trndocrs-clear in this-procedure
        .
    end.

    /* снимаем резервы по партиям */
    run rsrvindl in this-procedure
      (input recid(buf_trn-doc)  /* p-trn-doc-recid  */
      ,input recid(buf_doc-line) /* p-doc-line-recid */
      ,input v-reserv-pl-code    /* p-reserv-pl-code */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при снятии резервов" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    for each buf_doc-pl exclusive-lock
      where buf_doc-pl.out-code = buf_doc-line.doc-code
        and buf_doc-pl.gds-code = v-gds-code
    on error undo, return error
    :
      assign
        buf_doc-pl.cli-qnty         = 0.0
        buf_doc-pl.doc-qnty         = 0.0
        buf_doc-pl.fact-qnty        = 0.0
        buf_doc-pl.cli-doc-qnty     = 0.0
        buf_doc-pl.cli-fact-qnty    = 0.0
        buf_doc-pl.rest-af-qnty     = buf_doc-pl.rest-bf-qnty
        buf_doc-pl.cli-rest-af-qnty = buf_doc-pl.cli-rest-bf-qnty
      .
    end.

    for each buf_gds-dtl
      where buf_gds-dtl.doc-code  = buf_doc-line.doc-code
        and buf_gds-dtl.artic     = buf_doc-line.artic
        and buf_gds-dtl.prod-type = buf_doc-line.prod-type
        and buf_gds-dtl.prod-code = buf_doc-line.prod-code
    on error undo, return error return-value
    :
      if v-need-rsrv = true
      then do:
        define variable v-unreserv-qnty as decimal   no-undo .
        assign
          v-unreserv-qnty = - buf_gds-dtl.doc-qnty
        .
        assign
          v-total-doc-qnty = v-total-doc-qnty + v-unreserv-qnty
        .
        run trndocrs-gds-dtl-accum in this-procedure
          (input buf_gds-dtl.prt-code
          ,input v-unreserv-qnty
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при изменении зарезервированных количеств trndocrs-gds-dtl-accum" skip
            "Документ" p-doc-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
      end.

      delete buf_gds-dtl.
    end.

    if v-need-rsrv = true
    then do:
      run trndocrs in this-procedure
        (input buf_doc-line.doc-code
        ,input buf_doc-line.obj-type
        ,input buf_doc-line.obj-code
        ,input buf_doc-line.artic
        ,input buf_doc-line.prod-type
        ,input buf_doc-line.prod-code
        ,input v-total-doc-qnty
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при изменении зарезервированных количеств trndocrs" skip
          "Документ" p-doc-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "Общее количество для снятия резервов" v-total-doc-qnty skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
  end.

  if buf_trn-doc.doc-type = {&inventory} then do:
    for each buf_gds-dtl
      where buf_gds-dtl.doc-code  = buf_doc-line.doc-code
        and buf_gds-dtl.artic     = buf_doc-line.artic
        and buf_gds-dtl.prod-type = buf_doc-line.prod-type
        and buf_gds-dtl.prod-code = buf_doc-line.prod-code
    on error undo, return error return-value
    :
      delete buf_gds-dtl .
    end.

    /* для документа инвентаризации проставляем количество товара на объекте */
    find buf_gds-obj no-lock
      where buf_gds-obj.obj-type  = buf_doc-line.obj-type
        and buf_gds-obj.obj-code  = buf_doc-line.obj-code
        and buf_gds-obj.artic     = buf_doc-line.artic
        and buf_gds-obj.prod-type = buf_doc-line.prod-type
        and buf_gds-obj.prod-code = buf_doc-line.prod-code
      no-error.
    if available buf_gds-obj then do:
      if buf_trn-doc.fact-date = ? then do:
        assign
          buf_doc-line.doc-qnty = buf_gds-obj.fact-qnty
        .
        if available buf_inv-line then do:
          run get-after-cli-qnty in this-procedure
            ( input buf_doc-line.obj-type
             ,input buf_doc-line.obj-code
             ,input buf_doc-line.artic
             ,input buf_doc-line.prod-type
             ,input buf_doc-line.prod-code
             ,input ?
             ,output v-before-cli-qnty
            ).
        end.
      end.
      else do:
         run doc-qnty-by-factord in this-procedure
          ( input buf_doc-line.obj-type
           ,input buf_doc-line.obj-code
           ,input buf_doc-line.artic
           ,input buf_doc-line.prod-type
           ,input buf_doc-line.prod-code
           ,output buf_doc-line.doc-qnty
           ,output v-before-cli-qnty
          ) .
      end.

      if available buf_inv-line then do:
        assign
          buf_inv-line.before-cli-qnty = v-before-cli-qnty
          buf_inv-line.wast-cli-qnty   = buf_inv-line.before-cli-qnty
          buf_inv-line.after-cli-qnty  = buf_inv-line.wast-cli-qnty
        .
      end.
    end.
    else do:
      assign
        buf_doc-line.doc-qnty = 0
      .
      if available buf_inv-line then do:
        assign
          buf_inv-line.before-cli-qnty = 0.0
          buf_inv-line.wast-cli-qnty   = 0.0
          buf_inv-line.after-cli-qnty  = 0.0
        .
      end.
    end.
    assign
      buf_doc-line.fact-qnty = 0.0
      buf_doc-line.prt-OK = ?
    .
    if available buf_inv-line then do:
      assign
        buf_doc-line.cli-qnty = 0.0 /* разница в кг для топливных товаров (инвентаризация) */
      .
    end.
  end.
  else do:
    /* для всех документов кроме инвентаризации обнуляем количество по документу */
    assign
      buf_doc-line.doc-qnty = 0
    .
  end.

  /* строка приводится к состоянию, в котором она была создана */

  /* проверяем целостность товара */
  { gbl/gdscheck.i
    buf_doc-line.obj-type
    buf_doc-line.obj-code
    buf_doc-line.artic
    buf_doc-line.prod-type
    buf_doc-line.prod-code
    v-root-node
    "''"
    no-error
  }
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке целостности товара" skip
      "Документ" p-doc-code skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
      "Проверка целостности товара после удаления резервов" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.
  
end.

procedure get-after-cli-qnty :
  define input  parameter par-obj-type     like ub.doc-line.obj-type  no-undo .
  define input  parameter par-obj-code     like ub.doc-line.obj-code  no-undo .
  define input  parameter par-artic        like ub.doc-line.artic     no-undo .
  define input  parameter par-prod-type    like ub.doc-line.prod-type no-undo .
  define input  parameter par-prod-code    like ub.doc-line.prod-code no-undo .
  define input  parameter p-fact-order-end as decimal   no-undo .
  define output parameter p-fact-qty-kg    as decimal no-undo initial 0.0.

  define buffer bufloc_inv-line for ub.inv-line.

  do
  on error undo, return error return-value
  :
    if p-fact-order-end = ? then do:
      find last bufloc_inv-line no-lock
        where bufloc_inv-line.obj-type   = par-obj-type
          and bufloc_inv-line.obj-code   = par-obj-code
          and bufloc_inv-line.prod-type  = par-prod-type
          and bufloc_inv-line.prod-code  = par-prod-code
          and bufloc_inv-line.artic      = par-artic
          and bufloc_inv-line.status_    = {&fact}
          and bufloc_inv-line.fact-order > 0
        use-index fact-order
        no-error.
    end.
    else do:
      find last bufloc_inv-line no-lock
        where bufloc_inv-line.obj-type   = par-obj-type
          and bufloc_inv-line.obj-code   = par-obj-code
          and bufloc_inv-line.prod-type  = par-prod-type
          and bufloc_inv-line.prod-code  = par-prod-code
          and bufloc_inv-line.artic      = par-artic
          and bufloc_inv-line.status_    = {&fact}
          and bufloc_inv-line.fact-order <= p-fact-order-end
        use-index fact-order
        no-error.
    end.
    if available bufloc_inv-line then do:
      assign
        p-fact-qty-kg = bufloc_inv-line.after-cli-qnty
      .
    end. /* if available bufloc_inv-line */
  end. /* on error */
end procedure. /* get-after-cli-qnty */


procedure doc-qnty-by-factord :
/* Подсчет "было" на конец дня или смены  fact-date */
  define input  parameter par-obj-type   like ub.doc-line.obj-type  no-undo .
  define input  parameter par-obj-code   like ub.doc-line.obj-code  no-undo .
  define input  parameter par-artic      like ub.doc-line.artic     no-undo .
  define input  parameter par-prod-type  like ub.doc-line.prod-type no-undo .
  define input  parameter par-prod-code  like ub.doc-line.prod-code no-undo .
  define output parameter v-doc-qnty     as decimal   no-undo .
  define output parameter v-cli-doc-qnty as decimal   no-undo .

  do
  on error undo, return error return-value
  :
    define variable v-shift-on  as logical   no-undo .
    define variable v-fact-order-end as decimal   no-undo .
    define variable v-shift-end-fact-order as decimal   no-undo .
    define variable v-day-end-fact-order   as decimal   no-undo .

    { gbl/objat.i
      buf_trn-doc.obj-type
      buf_trn-doc.obj-code
      "'shift-on=request'"
      v-shift-on
      no-error
    }
    if error-status :error then do:
      message
          vss-workfile vss-revision vss-description
          skip "Ошибка при запросе, включены ли смены"
          skip error-status :get-message(1)
          skip return-value
      view-as alert-box error .
      undo, return error .
    end.
    run factord in this-procedure (
          input  buf_trn-doc.fact-date  /* p-fact-date            */
        , input  buf_trn-doc.fact-time  /* p-fact-time            */
        , input  buf_trn-doc.fact-time  /* p-fact-num             */
        , input  buf_trn-doc.shift-date /* p-shift-date           */
        , input  buf_trn-doc.shift-num  /* p-shift-num            */
        , input  v-shift-on              /* p-shift-on             */
        , output v-fact-order-end        /* p-fact-order           */
        , output v-shift-end-fact-order  /* p-shift-end-fact-order */
        , output v-day-end-fact-order    /* p-day-end-fact-order   */
    ) no-error .

    if v-shift-on = true then
      v-fact-order-end = v-shift-end-fact-order .
    else
      v-fact-order-end = v-day-end-fact-order .

    run partslib-init-temp-parts-by-factord in this-procedure
      ( input par-obj-type
       ,input par-obj-code
       ,input par-artic
       ,input par-prod-type
       ,input par-prod-code
       ,input v-fact-order-end
       ,input false
      ) .

    assign
      v-doc-qnty = 0
    .
    for each temp-parts
    on error undo, return error return-value
    :
      assign
        v-doc-qnty = v-doc-qnty + temp-parts.fact-qnty
      .
    end.

    run get-after-cli-qnty in this-procedure
      ( input par-obj-type
       ,input par-obj-code
       ,input par-artic
       ,input par-prod-type
       ,input par-prod-code
       ,input v-fact-order-end
       ,output v-cli-doc-qnty
      ).

  end.
end procedure. /* doc-qnty-by-factord */
