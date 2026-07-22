block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека  процедур

Автор: Перваков Михаил Сергеевич
Дата создания: 08/17/00
Author: Mikhail Pervakov
Creation date: 08/17/00

*/

using ibs.th.gbl.gbl-hndllib from propath.

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Библиотека  процедур".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/plwthlib.i }
{ trg/new-bcod.i }
{ ref/gdsoattr.i }
{ trg/factord.i  }
{ gbl/cur-time.i }
{ ref/disgdsru.i }
{ gbl/db-attr.i }
{ str/lib-trn.i  }
{ ref/gds-attr.i }
{ gbl/thbjattr.i }
{ gbl/getsect.i def }
{ gbl/lib-log.i }
{ trg/gds-objh.i }

if valid-handle (g#library)
and g#library <> this-procedure :handle
and g#library :get-signature('library_testproc':u) <> ""
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Попытка повторной загрузки библиотеки" skip
    g#library skip
    g#library :type skip
    g#library :file-name skip
    valid-handle(g#library) skip
    this-procedure :handle skip
    this-procedure :type skip
    this-procedure :file-name skip
    valid-handle(this-procedure) skip
    view-as alert-box error .
  undo, return error return-value .
end.
else do:
  assign
    g#library = this-procedure :handle
  .
  def var gbl-hndllibObj as class gbl-hndllib no-undo.
  gbl-hndllibObj = new gbl-hndllib ().
  gbl-hndllibObj:InitHndl("g#library", g#library).
  delete object gbl-hndllibObj.
end.

if this-procedure :persistent <> true
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка запуска библиотеки" program-name(1) skip
    "Попытка запустить ее как обычную процедуру" skip
    view-as alert-box error .
end.

on delete of this-procedure do:
  assign
    g#library = ?
  .
  def var gbl-hndllibObj as class gbl-hndllib no-undo.
  gbl-hndllibObj = new gbl-hndllib ().
  gbl-hndllibObj:InitHndl("g#library", g#library).
  delete object gbl-hndllibObj.
end.

define variable l-last-hostcode-exist     as logical                  no-undo initial false .
define variable v-last-hostcode-obj-type  like ub.price-doc.obj-type  no-undo .
define variable v-last-hostcode-obj-code  like ub.price-doc.obj-code  no-undo .
define variable v-last-hostcode-host-code like ub.price-doc.host-code no-undo .

define variable l-last-hostname-exist     as logical                  no-undo initial false .
define variable v-last-hostname-obj-type  like ub.price-doc.obj-type  no-undo .
define variable v-last-hostname-obj-code  like ub.price-doc.obj-code  no-undo .
define variable v-last-hostname-host-name like ub.clients.obj-name    no-undo .

define variable l-last-regcode-exist     as logical    no-undo initial false .
define variable v-last-regcode-obj-type  as character  no-undo .
define variable v-last-regcode-obj-code  as integer    no-undo .
define variable v-last-regcode-reg-code  as integer    no-undo .

define stream librout .

procedure library_testproc :
  /* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! */
  /* ДАННУЮ ПРОЦЕДУРУ УДАЛЯТЬ НЕЛЬЗЯ !!!!                  */
  /* ОНА СДЕЛАНА ДЛЯ ИСПРАВЛЕНИЯ СИСТЕМНОЙ ОШИБКИ PROGRESS */
  /* В ВЕРСИЯХ 8.2, 8.3                                    */
  /* решение ошибки                                        */
  /* Не могу найти индекс для pi (3252).                   */
  /* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! */

  define buffer buf_cli-gds    for ub.cli-gds .
  define buffer buf_gds-dtl    for ub.gds-dtl .
  define buffer buf_bar-code   for ub.bar-code .
  define buffer buf_wth-obj    for ub.wth-obj .

/*  find first ub.cli-gds    use-index pi no-error .*/
/*  find first ub.gds-dtl    use-index pi no-error .*/
/*  find first ub.config     use-index pi no-error .*/
/*  find first ub.gds-obj    use-index pi no-error .*/
/*  find first ub.gds-prt    use-index pi no-error .*/
/*  find first ub.goods      use-index pi no-error .*/
/*  find first ub.prt-obj    use-index pi no-error .*/
/*  find first ub.shop       use-index pi no-error .*/
/*  find first ub.store      use-index pi no-error .*/
/*  find first ub.trn-doc    use-index pi no-error .*/
/*  find first ub.units      use-index pi no-error .*/
end.


procedure hostcode :
do
on error undo, return error return-value
:
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define output parameter p-host-code as integer   no-undo .

  define variable vss-description as character no-undo initial "hostcode-01: код фирмы для объекта".

  if  l-last-hostcode-exist = true
  and p-obj-type            = v-last-hostcode-obj-type
  and p-obj-code            = v-last-hostcode-obj-code
  then do:
    assign
      p-host-code = v-last-hostcode-host-code
    .
    return . /* --->>>--- */
  end.

  define buffer buf_store   for ub.store .
  define buffer buf_shop    for ub.shop .

  case p-obj-type :
    when {&stock}
    then do:
      find first buf_store no-lock
        where buf_store.obj-code = p-obj-code
        no-error .
      if not available buf_store
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найден склад" skip
          "p-obj-type" p-obj-type skip
          "p-obj-code" p-obj-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      assign
        p-host-code = buf_store.host-code
      .
    end.
    when {&shop}
    then do:
      find first buf_shop no-lock
        where buf_shop.obj-code = p-obj-code
        no-error .
      if not available buf_shop
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найден магазин" skip
          "p-obj-type" p-obj-type skip
          "p-obj-code" p-obj-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      assign
        p-host-code = buf_shop.host-code
      .
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Неизвестный тип объекта" skip
        "p-obj-type" p-obj-type skip
        "p-obj-code" p-obj-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.

  assign
    l-last-hostcode-exist     = true
    v-last-hostcode-obj-type  = p-obj-type
    v-last-hostcode-obj-code  = p-obj-code
    v-last-hostcode-host-code = p-host-code
  .
end.
end procedure. /* hostcode */

procedure hostname :
do
on error undo, return error return-value
:
  define input  parameter p-obj-type  like ub.price-doc.obj-type  no-undo .
  define input  parameter p-obj-code  like ub.price-doc.obj-code  no-undo .
  define output parameter p-host-code like ub.price-doc.host-code no-undo .
  define output parameter p-host-name like ub.clients.obj-name    no-undo .

  define variable vss-description as character no-undo initial "hostname-01: имя фирмы для объекта".

  if  l-last-hostname-exist = true
  and p-obj-type            = v-last-hostname-obj-type
  and p-obj-code            = v-last-hostname-obj-code
  then do:
    assign
      p-host-code = v-last-hostcode-host-code
      p-host-name = v-last-hostname-host-name
    .
    return . /* --->>>--- */
  end.
  if  l-last-hostname-exist = true
  and p-obj-type = {&cmp}
  and v-last-hostcode-host-code = p-obj-code then do:
    assign
      p-host-code = v-last-hostcode-host-code
      p-host-name = v-last-hostname-host-name
    .
    return . /* --->>>--- */
  end.


  define buffer buf_store   for ub.store .
  define buffer buf_shop    for ub.shop .
  define buffer buf_clients for ub.clients.
  define buffer buf_sysconf for ub.sysconf .

  case p-obj-type :
    when {&stock}
    then do:
      find first buf_store no-lock
           where buf_store.obj-code = p-obj-code
      no-error .
      if not available buf_store
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найден склад" skip
          "p-obj-type" p-obj-type skip
          "p-obj-code" p-obj-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      assign
        p-host-code = buf_store.host-code
      .
    end.
    when {&shop}
    then do:
      find first buf_shop no-lock
           where buf_shop.obj-code = p-obj-code
      no-error .
      if not available buf_shop
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найден магазин" skip
          "p-obj-type" p-obj-type skip
          "p-obj-code" p-obj-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      assign
        p-host-code = buf_shop.host-code
      .
    end.
    when {&cmp}
    then do:
      find first buf_sysconf no-lock
           where buf_sysconf.host-code = p-host-code
      no-error.
      if not available buf_sysconf
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найдена СВОЯ фирма" skip
          "p-obj-type" p-obj-type skip
          "p-obj-code" p-obj-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      assign
        p-host-code = buf_sysconf.host-code
      .
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Неизвестный тип объекта" skip
        "p-obj-type" p-obj-type skip
        "p-obj-code" p-obj-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
  if p-obj-type <> {&cmp} then do:
    assign
      l-last-hostcode-exist     = true
      v-last-hostcode-obj-type  = p-obj-type
      v-last-hostcode-obj-code  = p-obj-code
      v-last-hostcode-host-code = p-host-code
    .
  end.
  find first buf_clients no-lock
       where buf_clients.obj-type = {&cmp}
         and buf_clients.obj-code = p-host-code
  no-error.
  if not available buf_clients
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найдена фирма" skip
      "p-host-code" p-host-code skip
    view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    p-host-name               = buf_clients.obj-name
  .
  if p-obj-type <> {&cmp} then do:
    assign
      l-last-hostname-exist     = true
      v-last-hostname-obj-type  = p-obj-type
      v-last-hostname-obj-code  = p-obj-code
      v-last-hostname-host-name = p-host-name
    .
  end.
end.
end procedure. /* hostname */


procedure hostcvat :
do
on error undo, return error return-value
:
  define input  parameter p-host-code   like ub.sysconf.host-code   no-undo .
  define output parameter p-cons-vat-pc like ub.sysconf.cons-vat-pc no-undo .

  define buffer buf_sysconf   for ub.sysconf.

  define variable vss-description as character no-undo initial "hostcvat-01: Консигнационный НДС для фирмы".

  find first buf_sysconf
       where buf_sysconf.host-code = p-host-code
  no-error.
  if error-status :error
  then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена фирма." skip
        "p-host-code" p-host-code skip
      view-as alert-box error .
      undo, return error return-value .
  end.
  assign
    p-cons-vat-pc = buf_sysconf.cons-vat-pc
  .
end.
end procedure. /* hostcvat */


procedure gdsobjcr :

  define input parameter  p-obj-type  like ub.gds-obj.obj-type  no-undo .
  define input parameter  p-obj-code  like ub.gds-obj.obj-code  no-undo .
  define input parameter  p-artic     like ub.gds-obj.artic     no-undo .
  define input parameter  p-prod-type like ub.gds-obj.prod-type no-undo .
  define input parameter  p-prod-code like ub.gds-obj.prod-code no-undo .
  define parameter buffer buf_gds-obj for ub.gds-obj .

  define variable vss-description as character no-undo initial "gdsobjcr-03: поиск и, при необходимости, cоздание записи товар на объекте".

  define buffer buf_goods for ub.goods .
  define buffer buf_units for ub.units .
  define buffer buf_dis-thbj-rule  for ub.dis-thbj-rule.
  define buffer buf_batchprocess for ub.batchprocess .

  do
  on error undo, return error return-value
  :
    find first buf_gds-obj no-lock
      where buf_gds-obj.obj-type  = p-obj-type
        and buf_gds-obj.obj-code  = p-obj-code
        and buf_gds-obj.artic     = p-artic
        and buf_gds-obj.prod-type = p-prod-type
        and buf_gds-obj.prod-code = p-prod-code
      no-error .
    if not available buf_gds-obj
    then do:
      do transaction
      on error undo, return error return-value
      :
        /* проверка возможности создания gds-obj */
        run gbl/lockgdoc.p
          (input  p-obj-type                 /* p-obj-type        */
          ,input  p-obj-code                 /* p-obj-code        */
          ,input  {&lock-prc-gds-obj-create} /* p-lock-gds-type   */
          ,input  {&lock-prc-subtype-enable} /* p-sub-type        */
          ,buffer buf_batchprocess           /* lock_batchprocess */
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при проверке возможности создания записей товара на объекте" skip
            "Объект" p-obj-type p-obj-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.

        find first buf_goods share-lock
          where buf_goods.artic     = p-artic
            and buf_goods.prod-type = p-prod-type
            and buf_goods.prod-code = p-prod-code
          no-error .
        if not available buf_goods
        then do:
          message
            "Не найдена запись товара" skip
            "Объект" p-obj-type p-obj-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            "Если товар переименован ждите повторной передачи пакета новостей с новым артикулом товара."
            view-as alert-box .
          undo, return error return-value .
        end.

        /* проверяем, возможно к этому моменту запись уже была создана */
        /* тем самым минимизируется количество ошибок при одновременной */
        /* попытке создания записей с одинаковым ключём */
        find first buf_gds-obj exclusive-lock
          where buf_gds-obj.obj-type  = p-obj-type
            and buf_gds-obj.obj-code  = p-obj-code
            and buf_gds-obj.artic     = p-artic
            and buf_gds-obj.prod-type = p-prod-type
            and buf_gds-obj.prod-code = p-prod-code
          no-error .
        if not available buf_gds-obj
        then do:
          /* создаём запись товар на объекте */
          create buf_gds-obj.
          assign
            buf_gds-obj.obj-type  = p-obj-type
            buf_gds-obj.obj-code  = p-obj-code
            buf_gds-obj.artic     = p-artic
            buf_gds-obj.prod-type = p-prod-type
            buf_gds-obj.prod-code = p-prod-code
            buf_gds-obj.grp-name  = buf_goods.grp-name
            buf_gds-obj.stts      = buf_goods.stts
            buf_gds-obj.gds-code  = buf_goods.gds-code
          .
          run gds-objh_write-gds-obj-proc in this-procedure ( buffer buf_gds-obj
                                                            ,integer({&hn-create})
                                                            ,input ''
                                                            ,input '').

          /* записываем код фирмы для объекта */
          { gbl/hostcode.i
            p-obj-type
            p-obj-code
            buf_gds-obj.host-code
            no-error
          }
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при определении кода фирмы для объекта" skip
              "Объект" p-obj-type p-obj-code skip
              "Артикул" p-artic p-prod-type p-prod-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.

          define variable v-cur-db-num like ub.db.db-num no-undo .
          define variable v-obj-db-num like ub.db.db-num no-undo .
          { gbl/curdbnum.i
            v-cur-db-num
            no-error
          }
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при определении номера текущей БД" skip
              "Объект" p-obj-type p-obj-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          { gbl/objdbnum.i
            p-obj-type
            p-obj-code
            v-obj-db-num
            no-error
          }
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при определении номера БД объекта" skip
              "Объект" p-obj-type p-obj-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          if v-cur-db-num = v-obj-db-num
          then do:
            /* определяется ночная скидка товара по умолчанию */
            /*так мы находим связку со свойством dr-rule-ref-object*/
            define buffer buf_dis-rule for ub.dis-rule.
            define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
            for each buf_dis-thbj-rule share-lock
              where buf_dis-thbj-rule.discnt-role = {&dthbjr-dflt-gds-temp-disc}
                and buf_dis-thbj-rule.obj-type    = p-obj-type
                and buf_dis-thbj-rule.obj-code    = p-obj-code
                and string(buf_dis-thbj-rule.rule-num) = buf_dis-thbj-rule.nonunique,
                first buf_dis-rule share-lock where
                      buf_dis-rule.rule-num = buf_dis-thbj-rule.rule-num
                  and buf_dis-rule.rule-num = buf_dis-rule.rl-root,
                first buf_dis-cfg-rule no-lock where
                     buf_dis-cfg-rule.table-name = {&table_dis-thbj-rule}
                and buf_dis-cfg-rule.templ-rl-root = buf_dis-rule.templ-rl-root
                and buf_dis-cfg-rule.link-prop = integer({&dr-rule-ref-object})
             on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
             on stop   undo , return error substitute( "&1. stop", vss-workfile )
             on endkey undo , return error substitute( "&1. endkey", vss-workfile )
             :
              run disgdsru-write  in this-procedure (
                  input p-obj-type
                  ,input p-obj-code
                  ,input buf_goods.gds-code
                  ,input buf_dis-thbj-rule.pos-type
                  ,input ? /*p-discnt-role*/
                  ,input buf_dis-rule.templ-rl-root
                  ,input buf_dis-cfg-rule.time-templ-rl-root
                  ,input buf_dis-rule.rule-num
                  ,input "" /*p-nonunique*/
                  ) no-error.
              if error-status :error
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Ошибка при создании скидки товара на объекте" skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Код товара" buf_goods.gds-code
                  "Правило скидки" buf_dis-thbj-rule.rule-num
                  error-status :get-message(1) skip
                  return-value skip
                  view-as alert-box error .
                undo, return error return-value .
              end. /*if error-status :error*/
              leave.
            end. /*            for first buf_dis-thbj-rule share-lock*/
          end. /*if v-cur-db-num = v-obj-db-num*/


          find buf_units no-lock
            where buf_units.unit-name = buf_goods.unit-base
            no-error .
          if not available buf_units
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Не найдена базовая единица измерения" skip
              "Объект" p-obj-type p-obj-code skip
              "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
              "Базовая единица измерения" buf_goods.unit-base skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          /* для серийного товара устанавливаем признак продажи по партиям */
          define variable v-cp as logical no-undo .
          v-cp = ?.
          if v-cp = ?
          and lookup({&serial}, buf_units.type) > 0
          then do:
            v-cp = yes.
          end.
          if v-cp = ?
          and (lookup({&weight}, buf_units.type) > 0
          or buf_goods.gds-type = {&gds-office}) then do:
            v-cp = no.
          end.
          if v-cp = ? then do:
            define variable v-is-petrolium as logical no-undo .
            define variable v-is-pieces as logical no-undo .
            { str/is-petrl.i
                p-artic
                p-prod-type
                p-prod-code
                v-is-petrolium
                v-is-pieces
              }
            if v-is-petrolium and
            not v-is-pieces then do:
              v-cp = no.
            end.
          end.
          if v-cp = ? then do:
            define buffer buf_gds-prt for ub.gds-prt.
            FIND FIRST buf_gds-prt No-LOCK WHERE
                  buf_gds-prt.upper-code = buf_goods.prt-root No-ERROR.
            if available buf_gds-prt
            and buf_gds-prt.node-name <> {&empty-scale}  then do:
              define variable l-doc-prt as logical no-undo .
              { gbl/objat.i
                p-obj-type
                p-obj-code
                "'doc-prt=request':u"
                l-doc-prt
                no-error
              }
            end.
            IF NOT AVAIL buf_gds-prt
            OR (buf_gds-prt.node-name <> {&empty-scale} and l-doc-prt) then do:
              v-cp = no.
            end.
          end.
          if v-cp = ? then do:
            /*торгуется ли по партиям по умолчанию*/
            /*получаем атрибут*/
            define variable v-attr-value as character no-undo .
            define variable v-attr-type as character no-undo .
            run gds-attr-value in this-procedure
              (input  buf_gds-obj.gds-code
              ,input  {&attr-cash-parts}
              ,output v-attr-value
              ,output v-attr-type
              ) .
            assign
              v-cp = lookup(v-attr-value, 'true,yes':u) > 0
            .
          end.
          assign
          buf_gds-obj.cash-parts = v-cp
          .
          /* для топливного дробного товара - задаем признак учета по складским местам */
          if  lookup({&petrolium},  buf_units.type) > 0
          and lookup({&divisional}, buf_units.type) > 0
          then do:
            assign
              buf_gds-obj.place-rsrv = true
            .
          end.

          /* для весового товара - создаем атрибут ВЕСОВОЙ КОД ТОВАРА НА ОБЪЕКТЕ */
          if lookup({&weight}, buf_units.type) > 0
          then do:
            run sclcdattr in this-procedure
              (input  buf_goods.gds-code /* p-gds-code  */
              ,input  p-obj-type         /* p-obj-type  */
              ,input  p-obj-code         /* p-obj-code  */
              ,input  ?                  /* p-b-str     */
              ,input  yes                /* p-overwrite */
              ) no-error.
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при создании атрибута ВЕСОВОЙ КОД ТОВАРА НА ОБЪЕКТЕ" skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                "Код товара" buf_goods.gds-code
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error return-value .
            end.
          end.
          define variable v-exist as logical no-undo .
          run gds-attr-exist in this-procedure ( input buf_gds-obj.gds-code
                                                ,input  {&attr-dflt-insalepr}
                                                ,output v-exist).
          if v-exist then do:

            run gds-attr-value in this-procedure
              (input  buf_gds-obj.gds-code
              ,input  {&attr-dflt-insalepr}
              ,output v-attr-value
              ,output v-attr-type
              ) .
            buf_gds-obj.insalepr = integer(logical(v-attr-value)).
          end.
          /* задаем дату начала движения по товару */
          /* и конца движения по товару */
          assign
            buf_gds-obj.first-doc = today
            buf_gds-obj.last-doc  = today
          .

          /* Проверяем, что в базе данных отсутствуют "кривые" prt-obj */
          define buffer buf_prt-obj for ub.prt-obj .
          for each buf_prt-obj no-lock
            where buf_prt-obj.obj-type  = p-obj-type
              and buf_prt-obj.obj-code  = p-obj-code
              and buf_prt-obj.artic     = p-artic
              and buf_prt-obj.prod-type = p-prod-type
              and buf_prt-obj.prod-code = p-prod-code
          on error undo, return error return-value
          :
            if buf_prt-obj.fact-qnty <> 0
            or buf_prt-obj.free-qnty <> 0
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при создании товара на объекте" skip
                "Уже существует признак на объекте с ненулевыми количествами" skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                "Ссылка на шкалу" buf_prt-obj.prt-code skip
                "Фактическое количество" buf_prt-obj.fact-qnty skip
                "Свободное количество" buf_prt-obj.free-qnty skip
                view-as alert-box error .
              undo, return error return-value .
            end.
          end.
        end.
      end.
    end.
  end.

end procedure. /* gdsobjcr */



procedure gohist :

  define input  parameter p-obj-type           as character no-undo .
  define input  parameter p-obj-code           as integer   no-undo .
  define input  parameter p-gds-code           as integer   no-undo .
  define input  parameter p-action-type        as character no-undo .
  define input  parameter p-fact-qnty          as decimal   no-undo .
  define input  parameter p-fact-cli-qnty      as decimal   no-undo .
  define input  parameter p-fact-base          as decimal   no-undo .
  define input  parameter p-fact-rubl          as decimal   no-undo .
  define input  parameter p-fact-sale          as decimal   no-undo .
  define input  parameter p-old-fact-qnty      as decimal   no-undo .
  define input  parameter p-old-fact-cli-qnty  as decimal   no-undo .
  define input  parameter p-old-fact-base      as decimal   no-undo .
  define input  parameter p-old-fact-rubl      as decimal   no-undo .
  define input  parameter p-old-fact-sale      as decimal   no-undo .
  define input  parameter p-source-type        as character no-undo .
  define input  parameter p-source-ref         as character no-undo .
  define input  parameter p-source-date        as date      no-undo .
  define input  parameter p-corr-user-db-num   as integer   no-undo .
  define input  parameter p-corr-user-name     as character no-undo .
  define input  parameter p-corr-date          as date      no-undo .
  define input  parameter p-corr-time          as integer   no-undo .
  define input  parameter p-corr-time-str      as character no-undo .

  define variable v-new-chip-num as integer   no-undo .

  define buffer buf_c-gds-obj for ub.c-gds-obj .

  do
  for buf_c-gds-obj
  transaction
  on error undo, return error return-value
  :
    find last buf_c-gds-obj exclusive-lock
      where buf_c-gds-obj.obj-type = p-obj-type
        and buf_c-gds-obj.obj-code = p-obj-code
        and buf_c-gds-obj.gds-code = p-gds-code
      use-index pi
      no-error .
    if available buf_c-gds-obj
    then do:
      assign
        v-new-chip-num = buf_c-gds-obj.chip-num + 1
      .
    end.
    else do:
      assign
        v-new-chip-num = 1
      .
    end.

    create buf_c-gds-obj .
    assign
      buf_c-gds-obj.obj-type          = p-obj-type
      buf_c-gds-obj.obj-code          = p-obj-code
      buf_c-gds-obj.gds-code          = p-gds-code
      buf_c-gds-obj.chip-num          = v-new-chip-num
      buf_c-gds-obj.action-type       = p-action-type
      buf_c-gds-obj.fact-qnty         = p-fact-qnty
      buf_c-gds-obj.fact-cli-qnty     = p-fact-cli-qnty
      buf_c-gds-obj.fact-base         = p-fact-base
      buf_c-gds-obj.fact-rubl         = p-fact-rubl
      buf_c-gds-obj.fact-sale         = p-fact-sale
      buf_c-gds-obj.old-fact-qnty     = p-old-fact-qnty
      buf_c-gds-obj.old-fact-cli-qnty = p-old-fact-cli-qnty
      buf_c-gds-obj.old-fact-base     = p-old-fact-base
      buf_c-gds-obj.old-fact-rubl     = p-old-fact-rubl
      buf_c-gds-obj.old-fact-sale     = p-old-fact-sale
      buf_c-gds-obj.source-type       = p-source-type
      buf_c-gds-obj.source-ref        = p-source-ref
      buf_c-gds-obj.source-date       = p-source-date
      buf_c-gds-obj.corr-user-db-num  = p-corr-user-db-num
      buf_c-gds-obj.corr-user-name    = p-corr-user-name
      buf_c-gds-obj.corr-date         = p-corr-date
      buf_c-gds-obj.corr-time         = p-corr-time
      buf_c-gds-obj.corr-time-str     = p-corr-time-str
    .


  end.

end procedure. /* gohist */


procedure plgohist :

  define input  parameter p-obj-type           as character no-undo .
  define input  parameter p-obj-code           as integer   no-undo .
  define input  parameter p-pl-code            as integer   no-undo .
  define input  parameter p-gds-code           as integer   no-undo .
  define input  parameter p-action-type        as character no-undo .
  define input  parameter p-fact-qnty          as decimal   no-undo .
  define input  parameter p-cli-qnty           as decimal   no-undo .
  define input  parameter p-free-qnty          as decimal   no-undo .
  define input  parameter p-cli-fact-qnty      as decimal   no-undo .
  define input  parameter p-cli-free-qnty      as decimal   no-undo .
  define input  parameter p-old-fact-qnty      as decimal   no-undo .
  define input  parameter p-old-cli-qnty       as decimal   no-undo .
  define input  parameter p-old-free-qnty      as decimal   no-undo .
  define input  parameter p-old-cli-fact-qnty  as decimal   no-undo .
  define input  parameter p-old-cli-free-qnty  as decimal   no-undo .
  define input  parameter p-source-type        as character no-undo .
  define input  parameter p-source-ref         as character no-undo .
  define input  parameter p-source-date        as date      no-undo .
  define input  parameter p-corr-user-db-num   as integer   no-undo .
  define input  parameter p-corr-user-name     as character no-undo .
  define input  parameter p-corr-date          as date      no-undo .
  define input  parameter p-corr-time          as integer   no-undo .
  define input  parameter p-corr-time-str      as character no-undo .

  define variable v-new-chip-num as integer   no-undo .

  define buffer buf_c-pl-gds-obj for ub.c-pl-gds-obj .

  do
  for buf_c-pl-gds-obj
  transaction
  on error undo, return error return-value
  :
    find last buf_c-pl-gds-obj exclusive-lock
      where buf_c-pl-gds-obj.obj-type = p-obj-type
        and buf_c-pl-gds-obj.obj-code = p-obj-code
        and buf_c-pl-gds-obj.gds-code = p-gds-code
        and buf_c-pl-gds-obj.pl-code = p-pl-code
      use-index pi
      no-error .
    if available buf_c-pl-gds-obj
    then do:
      assign
        v-new-chip-num = buf_c-pl-gds-obj.chip-num + 1
      .
    end.
    else do:
      assign
        v-new-chip-num = 1
      .
    end.

    create buf_c-pl-gds-obj .
    assign
      buf_c-pl-gds-obj.obj-type          = p-obj-type
      buf_c-pl-gds-obj.obj-code          = p-obj-code
      buf_c-pl-gds-obj.gds-code          = p-gds-code
      buf_c-pl-gds-obj.pl-code           = p-pl-code
      buf_c-pl-gds-obj.chip-num          = v-new-chip-num
      buf_c-pl-gds-obj.action-type       = p-action-type
      buf_c-pl-gds-obj.fact-qnty         = p-fact-qnty
      buf_c-pl-gds-obj.cli-qnty          = p-cli-qnty
      buf_c-pl-gds-obj.free-qnty         = p-free-qnty
      buf_c-pl-gds-obj.cli-fact-qnty     = p-cli-fact-qnty
      buf_c-pl-gds-obj.cli-free-qnty     = p-cli-free-qnty
      buf_c-pl-gds-obj.old-fact-qnty     = p-old-fact-qnty
      buf_c-pl-gds-obj.old-cli-qnty      = p-old-cli-qnty
      buf_c-pl-gds-obj.old-free-qnty     = p-old-free-qnty
      buf_c-pl-gds-obj.old-cli-fact-qnty = p-old-cli-fact-qnty
      buf_c-pl-gds-obj.old-cli-free-qnty = p-old-cli-free-qnty
      buf_c-pl-gds-obj.source-type       = p-source-type
      buf_c-pl-gds-obj.source-ref        = p-source-ref
      buf_c-pl-gds-obj.source-date       = p-source-date
      buf_c-pl-gds-obj.corr-user-db-num  = p-corr-user-db-num
      buf_c-pl-gds-obj.corr-user-name    = p-corr-user-name
      buf_c-pl-gds-obj.corr-date         = p-corr-date
      buf_c-pl-gds-obj.corr-time         = p-corr-time
      buf_c-pl-gds-obj.corr-time-str     = p-corr-time-str
    .


  end.

end procedure. /* plgohist */



procedure prtobjcr :

  define input parameter  v-obj-type   like ub.prt-obj.obj-type  no-undo .
  define input parameter  v-obj-code   like ub.prt-obj.obj-code  no-undo .
  define input parameter  v-artic      like ub.prt-obj.artic     no-undo .
  define input parameter  v-prod-type  like ub.prt-obj.prod-type no-undo .
  define input parameter  v-prod-code  like ub.prt-obj.prod-code no-undo .
  define input parameter  v-prt-code   like ub.prt-obj.prt-code  no-undo .
  define parameter buffer buf_prt-obj  for  ub.prt-obj .

  define variable vss-description as character no-undo initial "prtobjcr-02: поиск/создание записи о признаке на объекте".

  find first buf_prt-obj no-lock
    where buf_prt-obj.obj-type  = v-obj-type
      and buf_prt-obj.obj-code  = v-obj-code
      and buf_prt-obj.artic     = v-artic
      and buf_prt-obj.prod-type = v-prod-type
      and buf_prt-obj.prod-code = v-prod-code
      and buf_prt-obj.prt-code  = v-prt-code
    no-error.
  if not available buf_prt-obj
  then do:
    do transaction
    on error undo, return error return-value
    :
      create buf_prt-obj.
      assign
        buf_prt-obj.obj-type  = v-obj-type
        buf_prt-obj.obj-code  = v-obj-code
        buf_prt-obj.artic     = v-artic
        buf_prt-obj.prod-type = v-prod-type
        buf_prt-obj.prod-code = v-prod-code
        buf_prt-obj.prt-code  = v-prt-code
      .

      { gbl/prtobjup.i
        buf_prt-obj
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при обновлении информации в признаке на объекте" skip
          "Объект" v-obj-type v-obj-code skip
          "Артикул" v-artic v-prod-type v-prod-code skip
          "Признак" v-prt-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.

end procedure. /* prtobjcr */


procedure prtobjup :

  define parameter buffer buf_prt-obj for ub.prt-obj .

  define variable vss-description as character no-undo initial "prtobjup-02: обновление информации в признаке товара на объекте".

  define variable v-root-node     like ub.prt-obj.prt-code no-undo .
  define variable l-terminal-prt  as logical no-undo .

  do
  on error undo, return error return-value
  :
    /* определяем код фирмы */
    { gbl/hostcode.i
      buf_prt-obj.obj-type
      buf_prt-obj.obj-code
      buf_prt-obj.host-code
      no-error
    }
    if error-status :error
    then do:
      undo, return error
        "Ошибка при определении кода фирмы для объекта"
        .
    end.

    define buffer buf_goods    for ub.goods    .

    find first buf_goods no-lock
      where buf_goods.artic     = buf_prt-obj.artic
        and buf_goods.prod-type = buf_prt-obj.prod-type
        and buf_goods.prod-code = buf_prt-obj.prod-code
      no-error .
    if not available buf_goods
    then do:
      undo, return error
        "Не найден товар"
        .
    end.

    /* проверяем, что prt-obj принадлежит шкале товара */
    define buffer buf_gds-prt for ub.gds-prt .
    find first buf_gds-prt no-lock
      where buf_gds-prt.node-code = buf_prt-obj.prt-code
      no-error .
    if not available buf_gds-prt
    then do:
      undo, return error
        "Не найден признак"
       .
    end.

    if buf_gds-prt.prt-root <> buf_goods.prt-root
    then do:
      undo, return error
        "Задан код признака из шкалы, которая не принадлежит товару" + {&new-line}
        + "Код шкалы товара" + string(buf_goods.prt-root)
        + "Код шкалы признака" + string(buf_gds-prt.prt-root)
        .
    end.

    /* определяем корневой признак */
    { gbl/rootnode.i
      buf_prt-obj.artic
      buf_prt-obj.prod-type
      buf_prt-obj.prod-code
      v-root-node
      no-error
    }
    if error-status :error
    then do:
      undo, return error
        "Ошибка при определении корня шкалы для товара"
        .
    end.

    /* определяем признак терминальный или нет */
    { gbl/prtat.i
      buf_prt-obj.prt-code
      'terminal-prt=request':u
      l-terminal-prt
      no-error
    }
    if error-status :error
    then do:
      undo, return error
        "Ошибка при определении атрибута признака"
        .
    end.

    /* признак терминальный */
    assign
      buf_prt-obj.is-term = l-terminal-prt
    .

    if  buf_prt-obj.prt-code <> v-root-node
    and l-terminal-prt = false
    then do:
      /* если признак не корневой и не терминальный */
      /* проставляем неопределенную цену */
      assign
        buf_prt-obj.price-sale = ?
      .
    end.
    else do:
      /* ищем/создаем бар-код признака */
      define buffer buf_bar-code for ub.bar-code .

      define variable v-is-new as logical no-undo .

      { gbl/barcodcr.i
        buf_goods.gds-code
        buf_prt-obj.prt-code
        "'':U"
        "'':U"
        buf_goods.unit-base
        1
        v-is-new
        buf_bar-code
        no-error
      }
      if error-status :error
      then do:
        undo, return error
          "Ошибка при поиске бар-кода"
          .
      end.

      /* устанавливаем последнюю продажную цену признака */
      define variable v-doc-num    like ub.price-list.doc-num    no-undo .
      define variable v-price-sale like ub.price-list.price-sale no-undo .
      define variable v-road-tax   like ub.price-list.road-tax   no-undo .
      define variable v-excise     like ub.price-list.excise     no-undo .

      { gbl/bcodeprc.i
        buf_prt-obj.obj-type
        buf_prt-obj.obj-code
        buf_bar-code.b-code
        0
        0
        v-doc-num
        v-price-sale
        v-road-tax
        v-excise
        no-error
      }
      if error-status :error
      then do:
        undo, return error
          "Ошибка при определение цены признака на объекте"
          .
      end.

      if v-price-sale = ?
      then do:
        assign
          buf_prt-obj.price-sale = 0
        .
      end.
      else do:
        assign
          buf_prt-obj.price-sale = v-price-sale
        .
      end.
    end.

    if buf_prt-obj.fact-qnty = ?
    or buf_prt-obj.free-qnty = ?
    then do:
      undo, return error
        "В признаке на объекте заданы неопределенные количества"
        .
    end.

  end.

end procedure. /* prtobjup */



procedure gdscr :

  /*
  Поиск/Создание записей о товаре в базе данных

  Данная процедура должна использоваться для начала движения товара по фирме, объекту
  При этом проверяются, и при отсутствии создаются записи:
    товар на объекте            gds-obj
    корневой признак на объекте prt-obj

  */

  define input parameter p-obj-type       like ub.prt-obj.obj-type   no-undo .
  define input parameter p-obj-code       like ub.prt-obj.obj-code   no-undo .
  define input parameter p-artic          like ub.prt-obj.artic      no-undo .
  define input parameter p-prod-type      like ub.prt-obj.prod-type  no-undo .
  define input parameter p-prod-code      like ub.prt-obj.prod-code  no-undo .
  define input parameter p-root-node      like ub.prt-obj.prt-code   no-undo .

  define variable vss-description as character no-undo initial "gdscr-01: поиск/создание записей о товаре в базе данных".

  define parameter buffer buf_gds-obj  for ub.gds-obj .
  define parameter buffer buf_prt-obj  for ub.prt-obj .

  /* создаем товар на объекте */
  { gbl/gdsobjcr.i
    p-obj-type
    p-obj-code
    p-artic
    p-prod-type
    p-prod-code
    buf_gds-obj
    no-error
  }
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Невозможно найти gds-obj" skip
      "p-obj-type"  p-obj-type  skip
      "p-obj-code"  p-obj-code  skip
      "p-artic"     p-artic     skip
      "p-prod-type" p-prod-type skip
      "p-prod-code" p-prod-code skip
      "p-root-node" p-root-node skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box.
    undo, return error return-value .
  end.

  /* создаем корневой признак на объекте */
  { gbl/prtobjcr.i
    p-obj-type
    p-obj-code
    p-artic
    p-prod-type
    p-prod-code
    p-root-node
    buf_prt-obj
    no-error
  }
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Невозможно найти prt-obj для корневого признака" skip
      "p-obj-type"  p-obj-type  skip
      "p-obj-code"  p-obj-code  skip
      "p-artic"     p-artic     skip
      "p-prod-type" p-prod-type skip
      "p-prod-code" p-prod-code skip
      "p-root-node" p-root-node skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box.
    undo, return error return-value .
  end.

end procedure. /* gdscr */


procedure gdsat :

  do
  on error undo, return error return-value
  :
    /* Получить атрибут товара */
    define input  parameter p-artic            like ub.goods.artic     no-undo .
    define input  parameter p-prod-type        like ub.goods.prod-type no-undo .
    define input  parameter p-prod-code        like ub.goods.prod-code no-undo .
    define input  parameter p-action           as character            no-undo .
    define output parameter p-return-attribute as logical              no-undo .

    define variable vss-description as character no-undo initial "gdsat-03: Получить атрибут товара".

    define variable ind      as integer   no-undo .
    define variable v-action as character no-undo .

    define buffer buf_goods for ub.goods .
    define buffer buf_units for ub.units .

    for first buf_goods field(gds-code) no-lock
      where buf_goods.artic     = p-artic
        and buf_goods.prod-type = p-prod-type
        and buf_goods.prod-code = p-prod-code:

/*      no-error .*/
/*    if not available buf_goods*/
/*    then do:*/
/*      message*/
/*        vss-workfile vss-revision vss-description skip*/
/*        "Не найден товар" skip*/
/*        "Артикул" p-artic p-prod-type p-prod-code skip*/
/*        "Действие" p-action skip*/
/*        view-as alert-box error .*/
/*      undo, return error return-value .*/
/*    end.*/

      { gbl/gdscdat.i
        buf_goods.gds-code
        p-action
        p-return-attribute
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найден товар" skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "Действие" p-action skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.

end procedure. /* gdsat */


procedure gdscdat :

  do
  on error undo, return error return-value
  :
    /* Получить атрибут товара */
    define input  parameter p-gds-code         like ub.goods.gds-code  no-undo .
    define input  parameter p-action           as character            no-undo .
    define output parameter p-return-attribute as logical              no-undo .

    define variable vss-description as character no-undo initial "gdscdat-01: Получить атрибут товара".

    define variable ind      as integer   no-undo .
    define variable v-action as character no-undo .

    define buffer buf_goods for ub.goods .
    define buffer buf_units for ub.units .

    find first buf_goods no-lock
      where buf_goods.gds-code = p-gds-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Код товара" p-gds-code skip
        "Действие" p-action skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    define variable v-num-entries-p-action as integer no-undo .

    assign
      v-num-entries-p-action = num-entries(p-action)
    .

    do ind = 1 to v-num-entries-p-action
    :
      assign
        v-action = entry(ind, p-action)
      .

      case v-action :
        when 'gds-goods=request':u
        then do:
          assign
            p-return-attribute = (buf_goods.gds-type = {&gds-goods})
          .
        end.

        when 'empty-scale=request':u
        then do:
          define variable v-root-node   like ub.gds-dtl.prt-code no-undo .
          define variable l-empty-scale as logical no-undo .

          { gbl/gdsrtnod.i
            p-gds-code
            v-root-node
            no-error
          }
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при определении корневого признака шкалы" skip
              "Код товара" p-gds-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.

          /* проверяем, является ли шкала товара пустой */
          { gbl/prtat.i
            v-root-node
            "'empty-scale=request':u"
            l-empty-scale
            no-error
          }
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при определении атрибута шкалы" skip
              "Код товара" p-gds-code skip
              "Код признака" v-root-node skip
              "Запрашивался атрибут" "empty-scale=request" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.

          assign
            p-return-attribute = l-empty-scale
          .
        end.
        when 'serial=request':u
        then do:
          find first buf_units no-lock
            where buf_units.unit-name = buf_goods.unit-base
            no-error .
          if not available buf_units
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Не найдена базовая единица измерения" skip
              "Код товара" p-gds-code skip
              "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
              "Базовая единица измерения" buf_goods.unit-base skip
              view-as alert-box .
            undo, return error return-value .
          end.

          assign
            p-return-attribute = (lookup({&serial}, buf_units.type) > 0)
          .
        end.

        when 'twounit=request':u
        then do:
          find buf_units no-lock
            where buf_units.unit-name = buf_goods.unit-base
            no-error .
          if not available buf_units
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Не найдена базовая единица измерения" skip
              "Код товара" p-gds-code skip
              "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
              "Базовая единица измерения" buf_goods.unit-base skip
              view-as alert-box error .
            undo, return error return-value .
          end.

          assign
            p-return-attribute = (lookup({&twounit}, buf_units.type) > 0)
          .
        end.

        when 'bottle=request':u
        then do:
          find buf_units no-lock
            where buf_units.unit-name = buf_goods.unit-base
            no-error .
          if not available buf_units
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Не найдена базовая единица измерения" skip
              "Код товара" p-gds-code skip
              "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
              "Базовая единица измерения" buf_goods.unit-base skip
              view-as alert-box error .
            undo, return error return-value .
          end.

          assign
            p-return-attribute = (lookup({&bottle}, buf_units.type) > 0)
          .
        end.

        when 'alcohol-prod=request':u
        then do:
          define variable v-attr-value as character no-undo .
          define variable v-attr-type  as character no-undo .

          run gds-attr-value in this-procedure
            (input  p-gds-code
            ,input  {&attr-alcohol-prod}
            ,output v-attr-value
            ,output v-attr-type
            ) .
          assign
            p-return-attribute = lookup(v-attr-value, 'true,yes':u) > 0
          .
        end.

        when 'mercur_FGIS=request':u
        then do:
          run gds-attr-value in this-procedure
            (input  p-gds-code
            ,input  {&attr-mercur_FGIS}
            ,output v-attr-value
            ,output v-attr-type
            ) .
          assign
            p-return-attribute = lookup(v-attr-value, 'true,yes':u) > 0
          .
        end.
        
        when 'production-only=request':u
        then do:
          run gds-attr-value in this-procedure
            (input  p-gds-code
            ,input  {&attr-production-only}
            ,output v-attr-value
            ,output v-attr-type
            ) .
          assign
            p-return-attribute = lookup(v-attr-value, 'true,yes':u) > 0
          .
        end.

        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестный параметр вызова." skip
            "Код товара" p-gds-code skip
            "Список действий" p-action skip
            "Действие" v-action skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end case . /* v-action */
    end.
  end.

end procedure. /* gdscdat */


procedure gdsobjat :
 /*
  Задает/получает различные признаки товара на объекте

  значения p-action
  список значений действий разделенных запятыми

  exist-gds-obj=request     - существует ли gds-obj

  gds-obj.in-ov     - требуется переоценка после прихода.
    после закрытия внешнего прихода до статуса {&fact}
    до момента закрытия переоценки до статуса {&act-overvalue}
  in-ov=true
  in-ov=false
  in-ov=request

  gds-obj.inv-on    - включена инвентаризация.
    для товара на объекте только один документ инвентаризации
    может имет статус
      trn-doc.status_ = {&permitted}
      trn-doc.flag_   = yes
    или документ коррекции учетных цен
      trn-doc.status_ = {&wayb}
      trn-doc.flag_   = no
  inv-on=true
  inv-on=false
  inv-on=request

  gds-obj.ov-on     - включена переоценка.
    для товара на объекте только одна переоценка может иметь статус
    price-doc.status_  = {&permitted}
  ov-on=true
  ov-on=false
  ov-on=request
  ov-on=message  - выдача сообщение о переоценке, в которую входит товар

  gds-obj.cash-parts - товар продается по партиям
  cash-parts=true
  cash-parts=false
  cash-parts=request

  gds-obj.place-rsrv - резервирование товара происходит с учетом складских мест
  place-rsrv=true
  place-rsrv=false
  place-rsrv=request

  create-bar-code=request - создавать бар-коды для партий свободной зоны на объекте

  cr-root-gds-dtl=request - необходимо создавать корневой признак в документе
       истина, если товар имеет пустую шкалу
       или на объекте выключен учет товаров по признакам
  */

  define input  parameter p-obj-type         like ub.gds-obj.obj-type  no-undo .
  define input  parameter p-obj-code         like ub.gds-obj.obj-code  no-undo .
  define input  parameter p-artic            like ub.gds-obj.artic     no-undo .
  define input  parameter p-prod-type        like ub.gds-obj.prod-type no-undo .
  define input  parameter p-prod-code        like ub.gds-obj.prod-code no-undo .
  define input  parameter p-action           as character no-undo .
  define output parameter p-return-attribute as logical no-undo .

  define variable vss-description as character no-undo initial "gdsobjat-02: задает/получает признаки товара на объекте".

  define variable ind      as integer no-undo .
  define variable v-action as character no-undo .

  define variable l-find-gds-obj as logical no-undo initial false .

  define buffer buf_gds-obj for ub.gds-obj .

  define variable v-num-entries-p-action as integer no-undo .

  assign
    v-num-entries-p-action = num-entries(p-action)
  .

  do ind = 1 to v-num-entries-p-action
  :
    assign
      v-action = entry(ind, p-action)
    .

    if lookup(v-action, "in-ov=request,inv-on=request,ov-on=request,exist-gds-obj=request") > 0
    then do:
      find first buf_gds-obj no-lock
        where buf_gds-obj.obj-type  = p-obj-type
          and buf_gds-obj.obj-code  = p-obj-code
          and buf_gds-obj.artic     = p-artic
          and buf_gds-obj.prod-type = p-prod-type
          and buf_gds-obj.prod-code = p-prod-code
        no-error .
    end.
    else do:
      if l-find-gds-obj <> true
      then do:
        { gbl/gdsobjcr.i
          p-obj-type
          p-obj-code
          p-artic
          p-prod-type
          p-prod-code
          buf_gds-obj
          no-error
        }
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно найти gds-obj" skip
            "p-obj-type"  p-obj-type  skip
            "p-obj-code"  p-obj-code  skip
            "p-artic"     p-artic     skip
            "p-prod-type" p-prod-type skip
            "p-prod-code" p-prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        assign
          l-find-gds-obj = true
        .
      end.
    end.

    case v-action :

      when "exist-gds-obj=request"
      then do:
        assign
          p-return-attribute = (available buf_gds-obj)
        .
      end.

      when "in-ov=true" or
      when "in-ov=yes"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj exclusive-lock .

          if buf_gds-obj.in-ov <> true
          then do:
            assign
              buf_gds-obj.in-ov = true
            .
          end.

          assign
            p-return-attribute = buf_gds-obj.in-ov
          .
        end.
      end.

      when "in-ov=false" or
      when "in-ov=no"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj exclusive-lock .

          if buf_gds-obj.in-ov <> false
          then do:
            assign
              buf_gds-obj.in-ov = false
            .
          end.

          assign
            p-return-attribute = buf_gds-obj.in-ov
          .
        end.
      end.

      when "in-ov=request"
      then do:
        if available buf_gds-obj
        then do:
          assign
            p-return-attribute = buf_gds-obj.in-ov
          .
        end.
        else do:
          assign
            p-return-attribute = false
          .
        end.
      end.

      when "in-ov=request:exclusive"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj exclusive-lock .
          assign
            p-return-attribute = buf_gds-obj.in-ov
          .
        end.
      end.

      when "in-ov=request:share"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj share-lock .
          assign
            p-return-attribute = buf_gds-obj.in-ov
          .
        end.
      end.


      when "inv-on=true" or
      when "inv-on=yes"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj exclusive-lock .

          if buf_gds-obj.inv-on <> true
          then do:
            assign
              buf_gds-obj.inv-on = true
            .
          end.
          else do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при установке признака 'Товар находится в инвентаризации'."
              "p-obj-type"  p-obj-type  skip
              "p-obj-code"  p-obj-code  skip
              "p-artic"     p-artic     skip
              "p-prod-type" p-prod-type skip
              "p-prod-code" p-prod-code skip
              "v-action"    v-action    skip
              "p-action"    p-action    skip
              "gds-obj.inv-on" buf_gds-obj.inv-on skip
              view-as alert-box error .
            undo, return error return-value .
          end.

          assign
            p-return-attribute = buf_gds-obj.inv-on
          .
        end.
      end.

      when "inv-on=false" or
      when "inv-on=no"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj exclusive-lock .

          if buf_gds-obj.inv-on <> false
          then do:
            assign
              buf_gds-obj.inv-on = false
            .
          end.
          else do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при сбрасывании признака 'Товар находится в инвентаризации'."
              "p-obj-type"  p-obj-type  skip
              "p-obj-code"  p-obj-code  skip
              "p-artic"     p-artic     skip
              "p-prod-type" p-prod-type skip
              "p-prod-code" p-prod-code skip
              "v-action"    v-action    skip
              "p-action"    p-action    skip
              "gds-obj.inv-on" buf_gds-obj.inv-on skip
              view-as alert-box error .
            undo, return error return-value .
          end.

          assign
            p-return-attribute = buf_gds-obj.inv-on
          .
        end.
      end.

      when "inv-on=request"
      then do:
        if available buf_gds-obj
        then do:
          assign
            p-return-attribute = buf_gds-obj.inv-on
          .
        end.
        else do:
          assign
            p-return-attribute = false
          .
        end.
      end.

      when "inv-on=request:exclusive"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj exclusive-lock .
          assign
            p-return-attribute = buf_gds-obj.inv-on
          .
        end.
      end.

      when "inv-on=request:share"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj exclusive-lock .
          assign
            p-return-attribute = buf_gds-obj.inv-on
          .
        end.
      end.

      when "ov-on=true" or
      when "ov-on=yes"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj exclusive-lock .

          if buf_gds-obj.ov-on <> true
          then do:
            assign
              buf_gds-obj.ov-on = true
            .
          end.
          else do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при установке признака 'Товар находится в переоценке'."
              "p-obj-type"  p-obj-type  skip
              "p-obj-code"  p-obj-code  skip
              "p-artic"     p-artic     skip
              "p-prod-type" p-prod-type skip
              "p-prod-code" p-prod-code skip
              "v-action"    v-action    skip
              "p-action"    p-action    skip
              "gds-obj.ov-on" buf_gds-obj.ov-on skip
              view-as alert-box error .
            undo, return error return-value .
          end.

          assign
            p-return-attribute = buf_gds-obj.ov-on
          .
        end.
      end.

      when "ov-on=false" or
      when "ov-on=no"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj exclusive-lock .

          if buf_gds-obj.ov-on <> false
          then do:
            assign
              buf_gds-obj.ov-on = false
            .
          end.
          else do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при сбрасывании признака 'Товар находится в переоценке'."
              "p-obj-type"  p-obj-type  skip
              "p-obj-code"  p-obj-code  skip
              "p-artic"     p-artic     skip
              "p-prod-type" p-prod-type skip
              "p-prod-code" p-prod-code skip
              "v-action"    v-action    skip
              "p-action"    p-action    skip
              "gds-obj.ov-on" buf_gds-obj.ov-on skip
              view-as alert-box error .
            undo, return error return-value .
          end.

          assign
            p-return-attribute = buf_gds-obj.ov-on
          .
        end.
      end.

      when "ov-on=request"
      then do:
        if available buf_gds-obj
        then do:
          assign
            p-return-attribute = buf_gds-obj.ov-on
          .
        end.
        else do:
          assign
            p-return-attribute = false
          .
        end.
      end.

      when "ov-on=request:exclusive"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj exclusive-lock .

          assign
            p-return-attribute = buf_gds-obj.ov-on
          .
        end.
      end.

      when "ov-on=request:share"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj share-lock .

          assign
            p-return-attribute = buf_gds-obj.ov-on
          .
        end.
      end.

      when "ov-on=message"
      then do:
        run trg/gdsobjms.p
          (input p-obj-type
          ,input p-obj-code
          ,input p-artic
          ,input p-prod-type
          ,input p-prod-code
          ,input "ov-on"
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры gdsobjms.p" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.

      when "cash-parts=true" or
      when "cash-parts=yes" or
      when "cash-parts=false" or
      when "cash-parts=no"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj exclusive-lock .
          case v-action:
            when "cash-parts=true"
            or
            when  "cash-parts=yes"  then do:
              /**/
              define buffer buf_goods for ub.goods.
              find first buf_goods no-lock where
                        buf_goods.gds-code = buf_gds-obj.gds-code no-error.
              if not available buf_goods then do:
                message
                  "Не найдена запись товара" skip
                  "Объект" p-obj-type p-obj-code skip
                  "Код товара" buf_gds-obj.gds-code skip
                  "Если товар переименован ждите повторной передачи пакета новостей с новым артикулом товара."
                  view-as alert-box .
                undo, return error return-value .
              end.
              define buffer buf_units for ub.units.
              find buf_units no-lock
                where buf_units.unit-name = buf_goods.unit-base
                no-error .
              if not available buf_units
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Не найдена базовая единица измерения" skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
                  "Базовая единица измерения" buf_goods.unit-base skip
                  view-as alert-box error .
                undo, return error return-value .
              end.
              define variable v-cp as logical no-undo .
              if lookup({&weight}, buf_units.type) > 0
              then do:
                undo, return error substitute("Нельзя установить флаг продажи по партиям для весового товара. Код товара &1"
                                              , buf_gds-obj.gds-code).
              end.
              if buf_goods.gds-type = {&gds-office} then do:
                undo, return error substitute("Нельзя установить флаг продажи по партиям для услуги. Код товара &1"
                                              , buf_gds-obj.gds-code).
              end.
              define variable v-is-petrolium as logical no-undo .
              define variable v-is-pieces as logical no-undo .
              { str/is-petrl.i
                  p-artic
                  p-prod-type
                  p-prod-code
                  v-is-petrolium
                  v-is-pieces
                }
              if v-is-petrolium and
              not v-is-pieces then do:
                undo, return error substitute("Нельзя установить флаг продажи по партиям для топливного товара. Код товара &1"
                                              , buf_gds-obj.gds-code).
              end.
              define buffer buf_gds-prt for ub.gds-prt.
              FIND FIRST buf_gds-prt No-LOCK WHERE
                    buf_gds-prt.upper-code = buf_goods.prt-root No-ERROR.
              if available buf_gds-prt
              and buf_gds-prt.node-name <> {&empty-scale}  then do:
                define variable l-cp-doc-prt as logical no-undo .
                { gbl/objat.i
                  p-obj-type
                  p-obj-code
                  "'doc-prt=request':u"
                  l-cp-doc-prt
                  no-error
                }
              end.
              IF NOT AVAIL buf_gds-prt
              OR (buf_gds-prt.node-name <> {&empty-scale} and l-cp-doc-prt) then do:
                undo, return error substitute("Нельзя установить флаг продажи по партиям для партионного товара. Код товара &1"
                                              , buf_gds-obj.gds-code).

              end.
              if buf_gds-obj.cash-parts <> true
              then do:
                run gds-objh_write-gds-obj-proc in this-procedure ( buffer buf_gds-obj
                                                                  ,integer({&hn-create})
                                                                  ,input ''
                                                                  ,input '').
                assign
                  buf_gds-obj.cash-parts = true
                .
              end.
            end.
            when "cash-parts=false" or
            when "cash-parts=no"
            then do:
              if buf_gds-obj.cash-parts <> false
              then do:
                run gds-objh_write-gds-obj-proc in this-procedure ( buffer buf_gds-obj
                                                                  ,integer({&hn-create})
                                                                  ,input ''
                                                                  ,input '').
                assign
                  buf_gds-obj.cash-parts = false
                .
              end.
            end.
          end case.
          assign
            p-return-attribute = buf_gds-obj.cash-parts
          .
          define variable v-cur-db-num like ub.db.db-num no-undo .
          define variable v-obj-db-num like ub.db.db-num no-undo .
          { gbl/curdbnum.i
            v-cur-db-num
            no-error
          }
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при определении номера текущей БД" skip
              "Объект" buf_gds-obj.obj-type buf_gds-obj.obj-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.

          if v-cur-db-num = 0 then do:
            { gbl/objdbnum.i
              buf_gds-obj.obj-type
              buf_gds-obj.obj-code
              v-obj-db-num
              no-error
            }
          end.
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при определении номера БД объекта" skip
              "Объект" buf_gds-obj.obj-type buf_gds-obj.obj-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.

          if v-obj-db-num <> v-cur-db-num
          or v-cur-db-num > 0 then do:
            define variable v-cmd as character no-undo .
            assign
              v-cmd = "command":U + {&delim-nws}
                      + "create":U + {&delim-nws}
                      + "cash-parts":U + {&delim-nws}
                      + substitute( "&1", buf_gds-obj.obj-type ) + {&delim-nws}
                      + substitute( "&1", buf_gds-obj.obj-code ) + {&delim-nws}
                      + substitute( "&1", buf_gds-obj.artic ) + {&delim-nws}
                      + substitute( "&1", buf_gds-obj.prod-type ) + {&delim-nws}
                      + substitute( "&1", buf_gds-obj.prod-code ) + {&delim-nws}
                      + substitute( "&1", buf_gds-obj.cash-parts ) + {&delim-nws}
            .

            run nws/cr-route.p
              ( input {&send-cmd}
                ,input v-cmd
                ,input ?
                ,input (if v-cur-db-num > 0
                        then "0"
                        else string(v-obj-db-num)
                        )
              ).
          end.
        end. /*do transaction*/
      end.
      when "cash-parts=request"
      then do:
        if available buf_gds-obj
        then do:
          assign
            p-return-attribute = buf_gds-obj.cash-parts
          .
        end.
        else do:
          assign
            p-return-attribute = false
          .
        end.
      end.

      when "cash-parts=request:exclusive"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj exclusive-lock .

          assign
            p-return-attribute = buf_gds-obj.cash-parts
          .
        end.
      end.

      when "cash-parts=request:share"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj share-lock .

          assign
            p-return-attribute = buf_gds-obj.cash-parts
          .
        end.
      end.

      when "insalepr=true" or
      when "insalepr=yes" or
      when "insalepr=false" or
      when "insalepr=no"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj exclusive-lock .
          case v-action:
            when "insalepr=true"
            or
            when  "insalepr=yes"  then do:
              /**/
              if buf_gds-obj.insalepr <> integer({&insalepr-int})
              then do:
                run gds-objh_write-gds-obj-proc in this-procedure ( buffer buf_gds-obj
                                                                  ,integer({&hn-create})
                                                                  ,input ''
                                                                  ,input '').
                assign
                  buf_gds-obj.insalepr = integer({&insalepr-int})
                .
              end.
              assign
                p-return-attribute = yes
              .
            end.
            when "insalepr=false" or
            when "insalepr=no"
            then do:
              if buf_gds-obj.insalepr <> integer({&no-insalepr-int})
              then do:
                run gds-objh_write-gds-obj-proc in this-procedure ( buffer buf_gds-obj
                                                                  ,integer({&hn-create})
                                                                  ,input ''
                                                                  ,input '').
                assign
                  buf_gds-obj.insalepr = integer({&no-insalepr-int})
                .
              end.
              assign
                p-return-attribute = no
              .

            end.
          end case.
          { gbl/curdbnum.i
            v-cur-db-num
            no-error
          }
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при определении номера текущей БД" skip
              "Объект" buf_gds-obj.obj-type buf_gds-obj.obj-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.

          if v-cur-db-num = 0 then do:
            { gbl/objdbnum.i
              buf_gds-obj.obj-type
              buf_gds-obj.obj-code
              v-obj-db-num
              no-error
            }
          end.
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при определении номера БД объекта" skip
              "Объект" buf_gds-obj.obj-type buf_gds-obj.obj-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.

          if v-obj-db-num <> v-cur-db-num
          or v-cur-db-num > 0 then do:
            assign
              v-cmd = "command":U + {&delim-nws}
                      + "create":U + {&delim-nws}
                      + "insalepr":U + {&delim-nws}
                      + substitute( "&1", buf_gds-obj.obj-type ) + {&delim-nws}
                      + substitute( "&1", buf_gds-obj.obj-code ) + {&delim-nws}
                      + substitute( "&1", buf_gds-obj.artic ) + {&delim-nws}
                      + substitute( "&1", buf_gds-obj.prod-type ) + {&delim-nws}
                      + substitute( "&1", buf_gds-obj.prod-code ) + {&delim-nws}
                      + substitute( "&1", buf_gds-obj.insalepr ) + {&delim-nws}
            .

            run nws/cr-route.p
              ( input {&send-cmd}
                ,input v-cmd
                ,input ?
                ,input (if v-cur-db-num > 0
                        then "0"
                        else string(v-obj-db-num)
                        )
              ).
          end.
        end. /*do transaction*/
      end.
      when "insalepr=request"
      then do:
        if available buf_gds-obj
        then do:
          assign
            p-return-attribute = (if buf_gds-obj.insalepr = integer({&insalepr-int})
                                  then yes
                                  else no)
          .
        end.
        else do:
          assign
            p-return-attribute = false
          .
        end.
      end.

      when "insalepr=request:exclusive"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj exclusive-lock .

          assign
            p-return-attribute = (if buf_gds-obj.insalepr = integer({&insalepr-int})
                                  then yes
                                  else no)
          .
        end.
      end.

      when "insalepr=request:share"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj share-lock .

          assign
            p-return-attribute = (if buf_gds-obj.insalepr = integer({&insalepr-int})
                                  then yes
                                  else no)
          .
        end.
      end.

      when "place-rsrv=true" or
      when "place-rsrv=yes"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj exclusive-lock .

          if buf_gds-obj.place-rsrv <> true
          then do:
            run gds-objh_write-gds-obj-proc in this-procedure ( buffer buf_gds-obj
                                                              ,integer({&hn-create})
                                                              ,input ''
                                                              ,input '').
            assign
              buf_gds-obj.place-rsrv = true
            .
          end.

          assign
            p-return-attribute = buf_gds-obj.place-rsrv
          .
        end.
      end.

      when "place-rsrv=false" or
      when "place-rsrv=no"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj exclusive-lock .

          if buf_gds-obj.place-rsrv <> false
          then do:
            run gds-objh_write-gds-obj-proc in this-procedure ( buffer buf_gds-obj
                                                              ,integer({&hn-create})
                                                              ,input ''
                                                              ,input '').
            assign
              buf_gds-obj.place-rsrv = false
            .
          end.

          assign
            p-return-attribute = buf_gds-obj.place-rsrv
          .
        end.
      end.

      when "place-rsrv=request"
      then do:
        if available buf_gds-obj
        then do:
          assign
            p-return-attribute = buf_gds-obj.place-rsrv
          .
        end.
        else do:
          assign
            p-return-attribute = false
          .
        end.
      end.

      when "place-rsrv=request:exclusive"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj exclusive-lock .

          assign
            p-return-attribute = buf_gds-obj.place-rsrv
          .
        end.
      end.

      when "place-rsrv=request:share"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj share-lock .

          assign
            p-return-attribute = buf_gds-obj.place-rsrv
          .
        end.
      end.

      when "create-bar-code=request"
      then do:
        define variable l-goods-serial    as logical no-undo .
        define variable l-cash-parts      as logical no-undo .

        { gbl/gdsat.i
          p-artic
          p-prod-type
          p-prod-code
          "'serial=request':u"
          l-goods-serial
          no-error
        }
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при определении атрибута товара" skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            'serial=request':u skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.

        { gbl/gdsobjat.i
          p-obj-type
          p-obj-code
          p-artic
          p-prod-type
          p-prod-code
          "'cash-parts=request':u"
          l-cash-parts
          no-error
        }
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при определении признака товара на объекте" skip
            "Объект" p-obj-type p-obj-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            "Запрашиваемый атрибут" "cash-parts=request":u skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.

        if l-goods-serial
        or l-cash-parts
        then do:
          /* для серийного товара всегда создаются бар-коды */
          assign
            p-return-attribute = true
          .
        end.
        else do:
          /* это обычная партия товара */
          /* проверяем параметр конфигурации */
          { gbl/getsect.i run "''"  0  {&attr-rezerv-global} }
          for each thbjattr_thbj-attr :
              if thbjattr_thbj-attr.prop-code = 'parts-bc'  then p-return-attribute  = thbjattr_thbj-attr.property-value-logical.
          end.
          empty temp-table thbjattr_thbj-attr.
        end.
      end.

      when "cr-root-gds-dtl=request":u
      then do:

        define variable v-root-node   like ub.gds-dtl.prt-code no-undo .
        define variable l-empty-scale as logical   no-undo .
        define variable l-doc-prt     as logical   no-undo .

        { gbl/rootnode.i
          p-artic
          p-prod-type
          p-prod-code
          v-root-node
          no-error
        }
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при определении корневого признака шкалы" skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.

        /* проверяем, является ли шкала товара пустой */
        { gbl/prtat.i
          v-root-node
          "'empty-scale=request':u"
          l-empty-scale
          no-error
        }
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при определении атрибута шкалы" skip
            "Код признака" v-root-node skip
            "Запрашивался атрибут" "empty-scale=request" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.

        /* проверяем, учитываются ли признаки на объекте */
        { gbl/objat.i
          p-obj-type
          p-obj-code
          "'doc-prt=request':u"
          l-doc-prt
          no-error
        }
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при определении атрибута объекта" skip
            "Объект" p-obj-type p-obj-code skip
            "Запрашивался атрибут" "doc-prt=request" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        assign
          p-return-attribute = (l-empty-scale = true)
                               or
                               (l-doc-prt = false)
        .
      end.

      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестное значение параметра v-action " skip
          "v-action" v-action skip
          "p-action" p-action skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.

  /* раскомментируйте сообщения для отладки признакво товара на объекте */
  /*message                                       */
  /*  "p-obj-type"         p-obj-type         skip*/
  /*  "p-obj-code"         p-obj-code         skip*/
  /*  "p-artic"            p-artic            skip*/
  /*  "p-prod-type"        p-prod-type        skip*/
  /*  "p-prod-code"        p-prod-code        skip*/
  /*  "p-action"           p-action           skip*/
  /*  "p-return-attribute" p-return-attribute skip*/
  /*  view-as alert-box information .             */

end procedure. /* gdsobjat */


procedure gdsoattr-increase-pc :
define input parameter p-gds-code like ub.goods.gds-code no-undo .
define input parameter p-obj-type like ub.gds-obj.obj-type no-undo .
define input parameter p-obj-code like ub.gds-obj.obj-code no-undo .
define output parameter p-increase-pc like ub.goods.increase-pc no-undo .

/*

Author: Natalia Bakhtadze
Creation date: 05/15/03

*/

DEFINE VARIABLE v-exist as logical no-undo .
DEFINE VARIABLE v-attr-value as character no-undo .
DEFINE VARIABLE v-attr-type as character no-undo .
define variable vss-description as character no-undo initial "gdsoattr-increase-pc-01: получение значения наценки на объекте".
define buffer buf_goods for ub.goods .

  do
  on error undo, return error return-value
  :

    find first buf_goods no-lock
      where buf_goods.gds-code     = p-gds-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run gdsoattr-exist in this-procedure(
                                      input p-gds-code,
                                      input p-obj-type,
                                      input p-obj-code,
                                      input {&attr-increase-pc-o},
                                      output v-exist).
   if not v-exist
   then do:
      assign
      p-increase-pc = buf_goods.increase-pc
      .
    end.
    else do:
      run gdsoattr-value ( input {&attr-increase-pc-o},
                          input p-gds-code,
                          input p-obj-type,
                          input p-obj-code,
                          output v-attr-value,
                          output v-attr-type ) no-error .
      if not error-status :error
      then do:
        assign
        p-increase-pc = decimal(v-attr-value)
        no-error
        .
      end.
      if error-status :error
      then do:
        message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара на объекте" skip
        "Код товара" p-gds-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
        undo, return error return-value .
      end.
    end. /*v-exist*/
  end. /*doe*/

end procedure. /* gds-obj-attr-increase-pc */

procedure check-cfg-param :
  /* проверка любого параметра конфигурации */
  define input  parameter p-conf-type     like ub.config.conf-type     no-undo .
  define input  parameter p-param-code    like ub.config.param-code    no-undo .
  define input  parameter p-db-num        like ub.config.db-num        no-undo .
  define input  parameter p-param-value   like ub.config.param-value   no-undo .
  define input  parameter p-beg-date      like ub.config.beg-date      no-undo .
  define input  parameter p-end-date      like ub.config.end-date      no-undo .
  define input  parameter p-param-encoded like ub.config.param-encoded no-undo .
  define input  parameter p-host-code     like ub.config.host-code     no-undo .
  define input  parameter p-obj-type      like ub.config.obj-type      no-undo .
  define input  parameter p-obj-code      like ub.config.obj-code      no-undo .
  define input  parameter p-msg-on        as logical   no-undo .
  define output parameter p-attach-level  as character no-undo .

  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define variable v-ok               as logical   no-undo .
    define variable v-assignment-type  as character no-undo .
    define variable v-assignment-ind   as integer   no-undo .

    define buffer buf_db for ub.db .

    if lookup( p-conf-type, {&cnf-type-list-protect} ) > 0
    then do:
      /* читаем ключ базы */
      find first buf_db no-lock
        where buf_db.db-num = p-db-num
        no-error .
      if not available buf_db
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найдена запись таблицы базы данных" skip
          "База данных" p-db-num skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      run check-enc in this-procedure
        (input  p-db-num
        ,input  buf_db.db-key
        ,input  p-param-code
        ,input  p-param-value
        ,input  p-beg-date
        ,input  p-end-date
        ,input  p-param-encoded
        ,output v-ok
        ) no-error.
      if error-status :error
      then do:
        if p-msg-on = true
        then do:
          message
            vss-workfile vss-revision vss-description skip
            substitute ("Параметр &1. Ошибка при проверке кодирования.", p-param-code ) skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        end.
        undo, return error substitute ("Параметр &1. Ошибка при проверке кодирования. &2", p-param-code, error-status :get-message( error-status :num-messages ) ).
      end.
      if v-ok <> true
      then do:
        if p-msg-on = true
        then do:
          message
            vss-workfile vss-revision vss-description skip
            substitute("Некорректное кодированное значение параметра &1", p-param-code) skip
            view-as alert-box error.
        end.
        undo, return error substitute("Некорректное кодированное значение параметра &1", p-param-code).
      end.

      if p-host-code <> 0
      or p-obj-type  <> ""
      or p-obj-code  <> 0
      then do:
        if p-msg-on = true
        then do:
          message
            vss-workfile vss-revision vss-description skip
            substitute("Кодированые параметры могут быть только без привязки! Параметр &1", p-param-code) skip
            view-as alert-box error.
        end.
        undo, return error substitute("Кодированые параметры могут быть только без привязки! Параметр &1", p-param-code).
      end.

      assign
        p-attach-level = {&cntxt-global}
      .
    end.
    else do:
      assign
        v-assignment-type = ( if  p-host-code = 0
                              then "0":u
                              else "1":u
                            )
                          + ( if  p-obj-type  = ""
                              and p-obj-code  = 0
                              then "0":u
                              else "1":u
                            )
      .
      assign
        v-assignment-ind = lookup( v-assignment-type, "00,10,11":u )
      .
      if v-assignment-ind = 0
      then do:
        if p-msg-on = TRUE
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Неправильная привязка параметра конфигурации" skip
            "param-code" p-param-code      skip
            "host-code"  p-host-code       skip
            "obj-type"   p-obj-type        skip
            "obj-code"   p-obj-code        skip
            "привязка"   v-assignment-type skip
            view-as alert-box error .
        end.
        undo, return error substitute ("Неправильная привязка параметра конфигурации &1", p-param-code ).
      end.
      assign
        p-attach-level = entry(v-assignment-ind
                              ,{&cntxt-global}
                              + {&comma-char} + {&cntxt-firm}
                              + {&comma-char} + {&cntxt-object}
                              )
      .
    end.
    if p-beg-date = ?
    or p-end-date = ?
    then do:
      if p-msg-on = true
      then do:
        message
          vss-workfile vss-revision vss-description skip
          substitute("Ошибка задания срока действия параметра &1. Дата начала &2. Дата окончания &3"
                    ,p-param-code
                    ,p-beg-date
                    ,p-end-date
                    ) skip
          view-as alert-box error.
      end.
      undo, return error  substitute("Ошибка задания срока действия параметра &1. Дата начала &2. Дата окончания &3"
                              ,p-param-code
                              ,p-beg-date
                              ,p-end-date
                              ) .
    end.
  end.
end procedure. /* check-cfg-param */

procedure confrddb :

  /*
  Чтение параметров конфигурации для заданной БД

  Сначала ищется запись config с указанным параметрами,
  если запись не найдена, то производится поиск записи config
  только по параметру p-code (общесистемной настройки).

  Сначала ищется запись config с указанным параметрами,
  если запись не найдена, то производится поиск записи config
  только по параметру p-code (общесистемной настройки).

  */

  define input  parameter p-code   as character no-undo . /* метка настройки - обязательна */
  define input  parameter p-db-num as integer   no-undo . /* номер БД */
  define input  parameter h-code   as integer   no-undo . /* код фирмы */
  define input  parameter o-type   as character no-undo . /* тип объекта */
  define input  parameter o-code   as integer   no-undo . /* код объекта */
  define input  parameter msg-on   as logical   no-undo . /* yes - сообщения выдаются */
  define output parameter p-value  as character no-undo . /* значение параметра - character */
  define output parameter p-type   as character no-undo .
/*
Возвращаемые значения:
  p-value: значение параметра
  p-type:  тип параметра
    {&type-char}
    {&type-log}
    {&type-dec}
    {&type-int}
    {&type-date}
*/
  define variable vss-description as character no-undo initial "confrddb: Чтение параметров конфигурации для заданной БД".

  do
  on error undo, return error return-value
  :
    define variable v-today            as date      no-undo .
    define variable v-time             as integer   no-undo .
    define variable l-object-specified as logical   no-undo .
    define variable v-host-code        as integer   no-undo .
    define variable v-level            as character no-undo .
    define variable v-db-num        as integer   no-undo .

    define buffer buf_config     for ub.config .
    define buffer buf-all_config for ub.config .

    if p-db-num < 0 then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute("Ошибка задания входных параметров. Параметр &1 БД &2", p-code, p-db-num ) skip
        view-as alert-box error.
      undo, return error substitute("&1.&2 Ошибка задания входных параметров. Параметр &3 БД &4", vss-description, {&new-line}, p-code, p-db-num ) .
    end.

    if p-db-num = ? then do:
      { gbl/curdbnum.i
        p-db-num
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении номера базы данных" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.

    assign
      p-value            = ?
      l-object-specified = false
    .
        run cur-time in this-procedure
          ( output v-today
           ,output v-time
          ) no-error .
    if length(p-code) > 8
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Длина имени параметра не может превышать 8 символов" skip
        "p-code" p-code skip
        view-as alert-box error .
    end.

    find first buf_config no-lock
      where buf_config.param-code = p-code
        and buf_config.db-num     = p-db-num
      no-error .
    if not available buf_config
    then do:
      if msg-on = TRUE
      then do:
        message
          "Параметр" p-code "отсутствует в БД." skip
          "Параметры задаются через 'АРМ Администратор/Справочники/Настройки и конфигурация системы'" skip
          "или при первоначальной настройке системы" skip
          view-as alert-box error.
      end.
      undo, return error substitute ("Параметр &1 отсутствует в БД. Параметры задаются через 'АРМ Администратор/Справочники/Настройки и конфигурация системы' или при первоначальной настройке системы", p-code ).
    end.
    else do:
      if lookup( buf_config.conf-type, {&cnf-type-list-protect} ) > 0
      and ( buf_config.param-type = {&type-log}
            or buf_config.param-type = {&type-int}
          )
      then do:

        if error-status :error
        then do:
          if msg-on = TRUE
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при определении текущего времени" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
          end.
          undo, return error "Ошибка при определении текущего времени" .
        end.

        if buf_config.param-type = {&type-int}
        then do:
          assign
            p-type  = buf_config.param-type
          .
          for each buf-all_config no-lock
            where buf-all_config.param-code = p-code
              and buf-all_config.host-code  = 0
              and buf-all_config.obj-type   = ""
              and buf-all_config.obj-code   = 0
              and buf-all_config.beg-date   <= v-today
              and buf-all_config.end-date   >= v-today
              and buf-all_config.db-num     = p-db-num
          on error undo, return error return-value
          :
            run check-cfg-param in this-procedure
              ( input buf-all_config.conf-type
               ,input buf-all_config.param-code
               ,input buf-all_config.db-num
               ,input buf-all_config.param-value
               ,input buf-all_config.beg-date
               ,input buf-all_config.end-date
               ,input buf-all_config.param-encoded
               ,input buf-all_config.host-code
               ,input buf-all_config.obj-type
               ,input buf-all_config.obj-code
               ,input msg-on
               ,output v-level
              ) no-error .
            if error-status :error
            then do:
              undo, return error return-value .
            end.
            if p-value = ?
            then do:
              assign
                p-value = buf-all_config.param-value
              .
            end.
            else do:
              assign
                p-value = string( integer( p-value ) + integer( buf-all_config.param-value ) )
              .
            end.
          end.
          if p-value = ?
            or trim( p-value ) = "":U
          then do:
            for each buf-all_config no-lock
              where buf-all_config.param-code = p-code
                and buf-all_config.host-code  = 0
                and buf-all_config.obj-type   = ""
                and buf-all_config.obj-code   = 0
                and buf-all_config.beg-date   <= v-today
                and buf-all_config.end-date   >= v-today
                and buf-all_config.db-num     = p-db-num
            on error undo, return error return-value
            :
              run check-cfg-param in this-procedure
                ( input buf-all_config.conf-type
                 ,input buf-all_config.param-code
                 ,input buf-all_config.db-num
                 ,input buf-all_config.param-value
                 ,input buf-all_config.beg-date
                 ,input buf-all_config.end-date
                 ,input buf-all_config.param-encoded
                 ,input buf-all_config.host-code
                 ,input buf-all_config.obj-type
                 ,input buf-all_config.obj-code
                 ,input msg-on
                 ,output v-level
                ) no-error .
              if error-status :error
              then do:
                undo, return error return-value.
              end.
              if p-value = ?
              then do:
                assign
                  p-value = buf-all_config.param-value
                .
              end.
              else do:
                assign
                  p-value = string( integer( p-value ) + integer( buf-all_config.param-value ) )
                .
              end.
            end.
            if p-value = ?
              or trim( p-value ) = "":U
            then do:
              if msg-on = TRUE
              then do:
                message
                  "Параметр" p-code "действующий в данный момент отсутствует в БД" skip
                  view-as alert-box error.
              end.
              undo, return error substitute ("Параметр &1 действующий в данный момент отсутствует в БД.", p-code ).
            end.
          end.
        end.

        if buf_config.param-type = {&type-log}
        then do:
          assign
            p-type  = buf_config.param-type
          .
          /* ищем первый действующий со значением yes */
          find first buf_config no-lock
            where buf_config.param-code = p-code
              and buf_config.host-code  = 0
              and buf_config.obj-type   = ""
              and buf_config.obj-code   = 0
              and buf_config.beg-date   <= v-today
              and buf_config.end-date   >= v-today
              and buf_config.db-num     = p-db-num
              and buf_config.param-value = "yes":U
            no-error .
          if not available buf_config
          then do:
            /* ищем первый действующий уже с любым значением */
            find first buf_config no-lock
              where buf_config.param-code = p-code
                and buf_config.host-code  = 0
                and buf_config.obj-type   = ""
                and buf_config.obj-code   = 0
                and buf_config.beg-date   <= v-today
                and buf_config.end-date   >= v-today
                and buf_config.db-num     = p-db-num
              no-error .
          end.
          if available buf_config then do:
            run check-cfg-param in this-procedure
              ( input buf_config.conf-type
               ,input buf_config.param-code
               ,input buf_config.db-num
               ,input buf_config.param-value
               ,input buf_config.beg-date
               ,input buf_config.end-date
               ,input buf_config.param-encoded
               ,input buf_config.host-code
               ,input buf_config.obj-type
               ,input buf_config.obj-code
               ,input msg-on
               ,output v-level
              ) no-error .
            if error-status :error
            then do:
              undo, return error return-value .
            end.
            assign
              p-value = buf_config.param-value
            .
          end.
          else do:
            if msg-on = TRUE
            then do:
              message
                "Параметр" p-code "действующий в данный момент отсутствует в БД." skip
                "или имеет ошибочную привязку" skip
                view-as alert-box error.
            end.
            undo, return error substitute ("Параметр &1 действующий в данный момент отсутствует в БД.", p-code ).
          end.
        end.
      end.
      else do:
        if o-type <> ""
          and o-code <> 0
        then do:
          assign
            l-object-specified = true
          .
          { gbl/hostcode.i
            o-type
            o-code
            v-host-code
            no-error
          }
          if error-status :error
          then do:
            if msg-on = TRUE
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при определении кода фирмы для объекта" skip
                "o-type" o-type skip
                "o-code" o-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
            end.
            undo, return error substitute( "Ошибка при определении кода фирмы для объекта &1 &2", o-type, o-code ) .
          end.

          if h-code = 0
            or h-code = ?
          then do:
            assign
              h-code = v-host-code
            .
          end.
          else do:
            if h-code <> v-host-code
            then do:
              if msg-on = TRUE
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Объект привязки не соответствует фирме для поиска параметра конфигурации" skip
                  "param-code" p-code skip
                  "host-code"  h-code skip
                  "obj-type"   o-type skip
                  "obj-code"   o-code skip
                  view-as alert-box error .
              end.
              undo, return error substitute ("Объект привязки (&1 &2) не соответствует фирме (&3) для поиска параметра конфигурации &4", o-type, o-code, h-code, p-code ).
            end.
          end.
        end.
        find first buf_config no-lock
          where buf_config.param-code = p-code
            and buf_config.host-code  = h-code
            and buf_config.obj-type   = o-type
            and buf_config.obj-code   = o-code
            and buf_config.db-num     = p-db-num
            and buf_config.beg-date   <= v-today
            and buf_config.end-date   >= v-today  
        no-error .
        if not available buf_config then
        find first buf_config no-lock
          where buf_config.param-code = p-code
            and buf_config.host-code  = h-code
            and buf_config.obj-type   = o-type
            and buf_config.obj-code   = o-code
            and buf_config.db-num     = p-db-num
        no-error .
        if not available buf_config
        then do:
          if h-code <> 0
          or o-type <> ""
          or o-code <> 0
          then do:
            if l-object-specified
            then do:
              find first buf_config no-lock
                where buf_config.param-code = p-code
                  and buf_config.host-code  = h-code
                  and buf_config.obj-type   = ""
                  and buf_config.obj-code   = 0
                  and buf_config.db-num     = p-db-num
                no-error .
            end.
            if not available buf_config
            then do:
              find first buf_config no-lock
                where buf_config.param-code = p-code
                  and buf_config.host-code  = 0
                  and buf_config.obj-type   = ""
                  and buf_config.obj-code   = 0
                  and buf_config.db-num     = p-db-num
                no-error .
            end.
          end.
        end.
        if available buf_config then do:
          run check-cfg-param in this-procedure
            ( input buf_config.conf-type
             ,input buf_config.param-code
             ,input buf_config.db-num
             ,input buf_config.param-value
             ,input buf_config.beg-date
             ,input buf_config.end-date
             ,input buf_config.param-encoded
             ,input buf_config.host-code
             ,input buf_config.obj-type
             ,input buf_config.obj-code
             ,input msg-on
             ,output v-level
            ) no-error .
          if error-status :error
          then do:
            undo, return error return-value.
          end.
          assign
            p-type  = buf_config.param-type
            p-value = buf_config.param-value
          .
        end.
        else do:
          if msg-on = TRUE
          then do:
            message
              "Параметр" p-code "отсутствует в БД." skip
              "Параметры задаются через 'АРМ Администратор/Справочники/Настройки и конфигурация системы'" skip
              "или при первоначальной настройке системы" skip
              view-as alert-box error.
          end.
          undo, return error substitute ("Параметр &1 отсутствует в БД. Параметры задаются через 'АРМ Администратор/Справочники/Настройки и конфигурация системы' или при первоначальной настройке системы", p-code ).
        end.
      end.
    end.
  end.
end procedure. /* confrddb */

procedure conf-rd :

  define input  parameter p-code  as character no-undo . /* метка настройки - обязательна */
  define input  parameter h-code  as integer   no-undo . /* код фирмы */
  define input  parameter o-type  as character no-undo . /* тип объекта */
  define input  parameter o-code  as integer   no-undo . /* код объекта */
  define input  parameter g-name  as character no-undo . /* группа пользователей */
  define input  parameter u-name  as character no-undo . /* имя пользователя */
  define input  parameter e-name  as character no-undo . /* extra-name */
  define input  parameter msg-on  as logical   no-undo . /* yes - сообщения выдаются */
  define output parameter p-value as character no-undo . /* значение параметра - character */
  define output parameter p-type  as character no-undo .

  define variable vss-description as character no-undo initial "conf-rd: Чтение параметров конфигурации для текущей БД".
  define variable v-db-num        as integer   no-undo .

  { gbl/curdbnum.i
    v-db-num
    no-error
  }
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении номера базы данных" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  run confrddb in this-procedure
   ( input p-code
    ,input v-db-num
    ,input h-code
    ,input o-type
    ,input o-code
    ,input msg-on
    ,output p-value
    ,output p-type
   ) no-error .
  if error-status :error then do:
    if error-status :get-message(1) <> "" then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры confrddb" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    undo, return error return-value .
  end.

end procedure. /* conf-rd */


procedure unitbase :

  define input  parameter p-gds-code  like ub.goods.gds-code  no-undo .
  define output parameter p-unit-base like ub.goods.unit-base no-undo .

  define variable vss-description as character no-undo initial "unitbase-01: определение базовой единицы измерения товара".

  define buffer buf_goods for ub.goods .

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
        "Не найден товар" skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error return-value . /* --->>>--- */
    end.

    assign
      p-unit-base = buf_goods.unit-base
    .
  end.

end procedure. /* unitbase */


procedure gdsbcode :

  /* gdsbcode-01: получение первичного бар-кода признака */

  define input  parameter p-gds-code  like ub.bar-code.gds-code  no-undo .
  define input  parameter p-node-code like ub.bar-code.node-code no-undo .
  define output parameter p-b-code    like ub.bar-code.b-code    no-undo .

  define variable vss-description as character no-undo initial "gdsbcode-01: определение первичного бар-кода признака".
  define variable vss-proc-revision as character no-undo initial "library.p gdsbcode-01" .

  define buffer buf_bar-code for ub.bar-code .

  define variable v-unit-base like ub.goods.unit-base no-undo .

  do
  on error undo, return error return-value
  :

    if p-node-code = ?
    then do:
      { gbl/gdsrtnod.i
        p-gds-code
        p-node-code
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении корневого признака товара" skip
          "Код товара" p-gds-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value . /* --->>>--- */
      end.
    end.

    { gbl/unitbase.i
      p-gds-code
      v-unit-base
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка определения базовой единицы измерения товара" skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    for first buf_bar-code field(b-code) no-lock
      where buf_bar-code.gds-code  = p-gds-code
        and buf_bar-code.node-code = p-node-code
        and buf_bar-code.part-code = ""
        and buf_bar-code.in-code   = ""
        and buf_bar-code.unit-cli  = v-unit-base
        :
    assign
      p-b-code = buf_bar-code.b-code
    .
    end.
    if p-b-code = 0
    then do:
      undo, return error vss-proc-revision + ":" + {&new-line}
        + "Не найден первичный бар-кода признака " + {&new-line}
        + "Код товара " + string(p-gds-code) + {&new-line}
        + "Код признака " + string(p-node-code) + {&new-line}
        + "Базовая единица измерения " + string(v-unit-base) + {&new-line}
        .
    end.
  end.

end procedure. /* gdsbcode */

procedure gdspcode :
define input  parameter p-gds-code  like ub.bar-code.gds-code  no-undo .
define input  parameter p-node-code like ub.bar-code.node-code no-undo .
define input  parameter p-in-code   like ub.bar-code.in-code   no-undo .
define input  parameter p-part-code like ub.bar-code.part-code   no-undo .
define output parameter p-b-code    like ub.bar-code.b-code    no-undo .

/*

Author: Natalia Bakhtadze
Creation date: 05/15/03

*/

  define variable vss-description as character no-undo initial "gdspcode-01: определение первичного бар-кода партии".
  define variable vss-proc-revision as character no-undo initial "library.p gdspcode-01" .

  define buffer buf_bar-code for ub.bar-code .

  define variable v-unit-base like ub.goods.unit-base no-undo .


do
on error undo, return error return-value
:
    if p-node-code = ?
    then do:
      { gbl/gdsrtnod.i
        p-gds-code
        p-node-code
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении корневого признака товара" skip
          "Код товара" p-gds-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value . /* --->>>--- */
      end.
    end.

    { gbl/unitbase.i
      p-gds-code
      v-unit-base
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка определения базовой единицы измерения товара" skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    for first buf_bar-code field(b-code) no-lock
      where buf_bar-code.gds-code  = p-gds-code
        and buf_bar-code.node-code = p-node-code
        and buf_bar-code.part-code = p-part-code
        and buf_bar-code.in-code   = p-in-code
        and buf_bar-code.unit-cli  = v-unit-base
        :
        assign
          p-b-code = buf_bar-code.b-code
        .
    end.
    if p-b-code = 0
    then do:
      undo, return error vss-proc-revision + ":" + {&new-line}
        + "Не найден первичный бар-код партии " + {&new-line}
        + "Код товара " + string(p-gds-code) + {&new-line}
        + "Код признака " + string(p-node-code) + {&new-line}
        + "Код ПН " + string(p-in-code) + {&new-line}
        + "Код партии " + string(p-part-code) + {&new-line}
        + "Базовая единица измерения " + string(v-unit-base) + {&new-line}
        .
    end.
  end.
end procedure. /* gdspcode */

procedure partbcod :

  /* partbcod-01: получение первичного бар-кода признака */

  define parameter buffer buf_parts   for ub.parts .
  define output parameter p-b-code    like ub.bar-code.b-code    no-undo .

  define variable vss-description as character no-undo initial "partbcod-01: определение первичного бар-кода признака".
  define variable vss-proc-revision as character no-undo initial "library.p partbcod-01" .

  define buffer buf_goods    for ub.goods .
  define buffer buf_bar-code for ub.bar-code .

  define variable v-root-node like ub.prt-obj.prt-code no-undo .

  do
  on error undo, return error return-value
  :
    find first buf_goods no-lock
      where buf_goods.artic     = buf_parts.artic
        and buf_goods.prod-type = buf_parts.prod-type
        and buf_goods.prod-code = buf_parts.prod-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Артикул товара" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
        "Код партии" recid(buf_parts) skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    run prt-root-to-node-code in this-procedure
      (input  buf_goods.prt-root /* p-prt-root  */
      ,output v-root-node        /* p-root-node */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры prt-root-to-node-code" skip
        "Товар" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
        "Указатель на корень шкалы" buf_goods.prt-root skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value . /* --->>>--- */
    end.

    find first buf_bar-code no-lock
      where buf_bar-code.gds-code  = buf_goods.gds-code
        and buf_bar-code.node-code = v-root-node
        and buf_bar-code.part-code = buf_parts.part-code
        and buf_bar-code.in-code   = buf_parts.in-code
        and buf_bar-code.unit-cli  = buf_goods.unit-base
      no-error .
    if not available buf_bar-code
    then do:
      undo, return error vss-proc-revision + ":" + {&new-line}
        + "Не найден первичный бар-код партии " + {&new-line}
        + "Код товара " + string(buf_goods.gds-code) + {&new-line}
        + "Код признака " + string(v-root-node) + {&new-line}
        + "Код партии " + string(buf_parts.part-code) + {&new-line}
        + "Код ПН " + string(buf_parts.in-code) + {&new-line}
        + "Базовая единица измерения " + string(buf_goods.unit-base) + {&new-line}
        .
    end.
    assign
      p-b-code = buf_bar-code.b-code
    .
  end.

end procedure. /* partbcod */

procedure barcodcr :

  define input  parameter p-gds-code      like ub.bar-code.gds-code      no-undo .
  define input  parameter p-node-code     like ub.bar-code.node-code     no-undo .
  define input  parameter p-part-code     like ub.bar-code.part-code     no-undo .
  define input  parameter p-in-code       like ub.bar-code.in-code       no-undo .
  define input  parameter p-unit-cli      like ub.bar-code.unit-cli      no-undo .
  define input  parameter p-cli-base-rate like ub.bar-code.cli-base-rate no-undo .
  define output parameter p-is-new        as logical                     no-undo .
  define parameter buffer buf_bar-code for ub.bar-code .

  define variable vss-description as character no-undo initial "barcodcr-03: поиск/создание бар-кода" .

  define variable v-new-b-code like ub.bar-code.b-code no-undo .
  define variable v-unit-base  like ub.goods.unit-base no-undo .

  do
  on error undo, return error return-value
  :
    assign
      p-is-new = false
    .

    find first buf_bar-code no-lock
      where buf_bar-code.gds-code  = p-gds-code
        and buf_bar-code.node-code = p-node-code
        and buf_bar-code.part-code = p-part-code
        and buf_bar-code.in-code   = p-in-code
        and buf_bar-code.unit-cli  = p-unit-cli
      no-error .
    if not available buf_bar-code
    then do
    transaction
    on error undo, return error return-value
    :
      run gen-b-code in this-procedure
        ( input {&gbl-bc-code},
          output v-new-b-code
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при получении номера бар-кода" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      { gbl/unitbase.i
        p-gds-code
        v-unit-base
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка определения базовой единицы измерения товара" skip
          "Код товара" p-gds-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      if p-unit-cli = v-unit-base
      then do:
        assign
          p-cli-base-rate = 1
        .
      end.

      if p-cli-base-rate = ?
      or p-cli-base-rate = 0
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Не задана коэффициент преобразования из одной единицы измерения в другую" skip
          "Код товара" p-gds-code skip
          "p-unit-cli" p-unit-cli skip
          "v-unit-base" v-unit-base skip
          "p-cli-base-rate" p-cli-base-rate skip
          view-as alert-box error .
        undo, return error return-value .
      end.


      assign
        p-is-new = true
      .

      create buf_bar-code .
      assign
        buf_bar-code.b-code        = v-new-b-code
        buf_bar-code.gds-code      = p-gds-code
        buf_bar-code.node-code     = p-node-code
        buf_bar-code.part-code     = p-part-code
        buf_bar-code.in-code       = p-in-code
        buf_bar-code.unit-cli      = p-unit-cli
        buf_bar-code.cli-base-rate = p-cli-base-rate
      .
    end. /*if not available buf_bar-code*/
    else do:
      if buf_bar-code.stts_ = integer({&hn-delete})
      then do:
        undo, return error substitute("бар-код &1 для товара &2 помечен к удалению", buf_bar-code.b-code, p-gds-code).
      end.
    end.

  end.

end procedure. /* barcodcr */


procedure bcodeprc :
  /*

  Процедура получения продажной цены бар-кода
  и всех компонентов продажной цены

  v-fact-order = 0 Получить текущую продажную цену признака

  v-fact-order <> 0 Для получения цены, действовавшей на определенный момент
                  обычно в качестве v-fact-order следует передавать
                  trn-doc.fact-order документа закрытого по факту

  v-root-b-code   указатель на корневую шкалу
                  Не обязательный параметр.
                  Следует указывать для ускорения поиска цены

  */
  define input parameter  v-obj-type    like ub.price-list.obj-type   no-undo .
  define input parameter  v-obj-code    like ub.price-list.obj-code   no-undo .
  define input parameter  v-b-code      like ub.bar-code.b-code       no-undo .
  define input parameter  v-root-b-code like ub.bar-code.b-code       no-undo .
  define input parameter  v-fact-order  like ub.price-doc.fact-order  no-undo .
  define output parameter v-doc-num     like ub.price-list.doc-num    no-undo .
  define output parameter v-price-sale  like ub.price-list.price-sale no-undo .
  define output parameter v-road-tax    like ub.price-list.road-tax   no-undo .
  define output parameter v-excise      like ub.price-list.excise     no-undo .

  define variable v-price-list-recid as recid no-undo .
  define variable v-cli-base-rate    like ub.bar-code.cli-base-rate no-undo .

  define variable vss-description as character no-undo initial "bcodeprc-03: получение продажной цены товара (признака)".

  define buffer buf_price-list      for ub.price-list .

  do
  on error undo, return error return-value
  :

    { gbl/bcodepls.i
      v-obj-type
      v-obj-code
      v-b-code
      v-root-b-code
      v-fact-order
      v-price-list-recid
      v-cli-base-rate
    }

    if v-price-list-recid = ?
    then do:
      assign
        v-doc-num    = ?
        v-price-sale = ?
        v-road-tax   = ?
        v-excise     = ?
      .
    end.
    else do:
      find first buf_price-list no-lock
        where recid(buf_price-list) = v-price-list-recid
        .
      assign
        v-doc-num    = buf_price-list.doc-num
        v-price-sale = buf_price-list.price-sale * v-cli-base-rate
        v-road-tax   = buf_price-list.road-tax   * v-cli-base-rate
        v-excise     = buf_price-list.excise     * v-cli-base-rate
      .
    end.
  end.

end procedure. /* bcodeprc */


procedure bcprcex :
  /*

  Процедура получения продажной цены бар-кода
  и всех компонентов продажной цены с налогами

  v-fact-order = 0 Получить текущую продажную цену признака

  v-fact-order <> 0 Для получения цены, действовавшей на определенный момент
                  обычно в качестве v-fact-order следует передавать
                  trn-doc.fact-order документа закрытого по факту

  v-root-b-code   указатель на корневую шкалу
                  Не обязательный параметр.
                  Следует указывать для ускорения поиска цены

  */
  define input  parameter v-obj-type    like ub.price-list.obj-type   no-undo .
  define input  parameter v-obj-code    like ub.price-list.obj-code   no-undo .
  define input  parameter v-b-code      like ub.bar-code.b-code       no-undo .
  define input  parameter v-root-b-code like ub.bar-code.b-code       no-undo .
  define input  parameter v-fact-order  like ub.price-doc.fact-order  no-undo .
  define output parameter v-doc-num     like ub.price-list.doc-num    no-undo .
  define output parameter v-price-sale  like ub.price-list.price-sale no-undo .
  define output parameter v-road-tax    like ub.price-list.road-tax   no-undo .
  define output parameter v-excise      like ub.price-list.excise     no-undo .
  define output parameter v-VAT-pc      like ub.price-list.VAT-pc     no-undo .
  define output parameter v-SLT-pc      like ub.price-list.SLT-pc     no-undo .

  define variable v-price-list-recid as recid no-undo .
  define variable v-cli-base-rate    like ub.bar-code.cli-base-rate no-undo .

  define variable vss-description as character no-undo initial "bcprcex-01: получение продажной цены бар-кода с налогами".

  define buffer buf_price-list      for ub.price-list .

  do
  on error undo, return error return-value
  :

    { gbl/bcodepls.i
      v-obj-type
      v-obj-code
      v-b-code
      v-root-b-code
      v-fact-order
      v-price-list-recid
      v-cli-base-rate
    }

    if v-price-list-recid = ?
    then do:
      assign
        v-doc-num    = ?
        v-price-sale = ?
        v-road-tax   = ?
        v-excise     = ?
        v-VAT-pc     = ?
        v-SLT-pc     = ?
      .
    end.
    else do:
      find first buf_price-list no-lock
        where recid(buf_price-list) = v-price-list-recid
        .
      assign
        v-doc-num    = buf_price-list.doc-num
        v-price-sale = buf_price-list.price-sale * v-cli-base-rate
        v-road-tax   = buf_price-list.road-tax   * v-cli-base-rate
        v-excise     = buf_price-list.excise     * v-cli-base-rate
        v-VAT-pc     = buf_price-list.VAT-pc
        v-SLT-pc     = buf_price-list.SLT-pc
      .
    end.
  end.

end procedure. /* bcodeprc */



procedure bcodepls :

  /*

  Процедура получения продажной цены бар-кода
  и всех компонентов продажной цены

  v-fact-order = 0 Получить текущую продажную цену признака

  v-fact-order <> 0 Для получения цены, действовавшей на определенный момент
                  обычно в качестве v-fact-order следует передавать
                  trn-doc.fact-order документа закрытого по факту

  v-root-b-code   указатель на корневую шкалу
                  Не обязательный параметр.
                  Следует указывать для ускорения поиска цены

  Возвращаемой значение:
  v-recid-price-list  - указатель на запись, если цена найдена
                        ?, если цена не найдена

  */
  define input  parameter v-obj-type         like ub.price-list.obj-type    no-undo .
  define input  parameter v-obj-code         like ub.price-list.obj-code    no-undo .
  define input  parameter v-b-code           like ub.bar-code.b-code        no-undo .
  define input  parameter v-root-b-code      like ub.bar-code.b-code        no-undo .
  define input  parameter v-fact-order       like ub.price-doc.fact-order   no-undo .
  define output parameter v-recid-price-list as recid                       no-undo .
  define output parameter v-cli-base-rate    like ub.bar-code.cli-base-rate no-undo .

  define variable vss-description as character no-undo initial "bcodepls-01: записи продажной цены признака".

  define buffer buf_root_bar-code   for ub.bar-code .
  define buffer buf_bar-code        for ub.bar-code .
  define buffer buf_root_price-list for ub.price-list .
  define buffer buf_price-list      for ub.price-list .
  define buffer buf_main_bar-code   for ub.bar-code .

  define variable  v-is-parts as logical   no-undo .
  do
  on error undo, return error return-value
  :

    /* находим бар-код для которого необходимо определить цену */
    find first buf_bar-code no-lock
      where buf_bar-code.b-code = v-b-code
      no-error .
    if not available buf_bar-code
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при задании входных параметров" skip
        "Не найден бар-код" v-b-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    assign
      v-cli-base-rate = buf_bar-code.cli-base-rate
    .

    if v-fact-order = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при задании входных параметров" skip
        "Должен быть задан порядковый номер документа" skip
        "Для определения текущей цены он должен быть равен 0" skip
        "Порядковый номер документа" v-fact-order skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if v-root-b-code = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при задании входных параметров" skip
        "Должен быть задан бар-код корневого признака" skip
        "Или он должен быть равен 0" skip
        "Бар-код корневого признака" v-root-b-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if v-root-b-code = 0
    then do:
      /* определяем бар-код корневого признака товара */
      { gbl/gdsbcode.i
        buf_bar-code.gds-code
        ?
        v-root-b-code
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении корневого бар-кода для товара" skip
          "Код товара"  buf_bar-code.gds-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value . /* --->>>--- */
      end.
    end.
    else do:
      /* todo - временная мера, проверяем что нам передали действительно */
      /* корневой бар-код товара                                         */
      define variable v-check-root-b-code like ub.bar-code.b-code no-undo .
      { gbl/gdsbcode.i
        buf_bar-code.gds-code
        ?
        v-check-root-b-code
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении корневого бар-кода для товара" skip
          "Код товара"  buf_bar-code.gds-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value . /* --->>>--- */
      end.
      if v-root-b-code <> v-check-root-b-code
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Код товара" buf_bar-code.gds-code skip
          "Основной бар-код товара" v-check-root-b-code skip
          "В качестве параметра передано" v-root-b-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.

    /* находим бар-код корневого признака */
    find first buf_root_bar-code no-lock
      where buf_root_bar-code.b-code = v-root-b-code
      no-error .
    if not available buf_root_bar-code
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден бар-код корневого признака" skip
        "Код товара" buf_bar-code.gds-code skip
        "Бар-код" v-root-b-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    /* грубая проверка целостности */
    /* проверяем, что бар-коды принадлежат одно му и тому же товару */
    if buf_root_bar-code.gds-code <> buf_bar-code.gds-code
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "В качестве параметров указаны бар-коды разных товаров" skip
        "Бар-код" buf_bar-code.b-code skip
        "Код товара" buf_bar-code.gds-code skip
        "Бар-код корневого признака" buf_root_bar-code.b-code skip
        "Код товара в бар-коде корневого признака" buf_root_bar-code.gds-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

/* Проверим на партионнось */
    v-is-parts = false .
    if buf_bar-code.in-code <> "" then do:
       v-is-parts = true . /* Это капец !!! - баркод-партии !!! */
    end.

    if v-is-parts = true then do:
        if v-fact-order = 0
        then do:
          find last buf_root_price-list no-lock
            where buf_root_price-list.obj-type   = v-obj-type
              and buf_root_price-list.obj-code   = v-obj-code
              and buf_root_price-list.b-code     = v-b-code
              and buf_root_price-list.price-type = ""
            use-index fact-close
            no-error.
        end.
        else do:
          find last buf_root_price-list no-lock
            where buf_root_price-list.obj-type   = v-obj-type
              and buf_root_price-list.obj-code   = v-obj-code
              and buf_root_price-list.b-code     = v-b-code
              and buf_root_price-list.price-type = ""
              and buf_root_price-list.fact-order < v-fact-order
            use-index fact-close
            no-error.
        end.
        if  available buf_root_price-list
        and buf_root_price-list.fact-order <> 0
        then do:
            assign
              v-recid-price-list = recid(buf_root_price-list)
              v-cli-base-rate    = 1
            .
            return . /* --->>>--- */
        end.
        else do:  /* Цена с с основного кода */
          if v-fact-order = 0
          then do:
            find last buf_root_price-list no-lock
              where buf_root_price-list.obj-type   = v-obj-type
                and buf_root_price-list.obj-code   = v-obj-code
                and buf_root_price-list.b-code     = v-root-b-code
                and buf_root_price-list.price-type = ""
              use-index fact-close
              no-error.
          end.
          else do:
            find last buf_root_price-list no-lock
              where buf_root_price-list.obj-type   = v-obj-type
                and buf_root_price-list.obj-code   = v-obj-code
                and buf_root_price-list.b-code     = v-root-b-code
                and buf_root_price-list.price-type = ""
                and buf_root_price-list.fact-order < v-fact-order
              use-index fact-close
              no-error.
          end.
          if  available buf_root_price-list
          and buf_root_price-list.fact-order <> 0
          then do:
              /* требуется цена бар-кода корневого признака */
              assign
                v-recid-price-list = recid(buf_root_price-list)
                v-cli-base-rate    = 1
              .
              return . /* --->>>--- */
          end.
          else do:
              assign
                v-recid-price-list = ?
                v-cli-base-rate    = ?
              .
              return . /* --->>>--- */
          end.
        end. /* Цена с с основного кода */
    end. /* if v-is-parts = true */


    if v-fact-order = 0
    then do:
      find last buf_root_price-list no-lock
        where buf_root_price-list.obj-type   = v-obj-type
          and buf_root_price-list.obj-code   = v-obj-code
          and buf_root_price-list.b-code     = v-root-b-code
          and buf_root_price-list.price-type = ""
        use-index fact-close
        no-error.
    end.
    else do:
      find last buf_root_price-list no-lock
        where buf_root_price-list.obj-type   = v-obj-type
          and buf_root_price-list.obj-code   = v-obj-code
          and buf_root_price-list.b-code     = v-root-b-code
          and buf_root_price-list.price-type = ""
          and buf_root_price-list.fact-order < v-fact-order
        use-index fact-close
        no-error.
    end.
    if  available buf_root_price-list
    and buf_root_price-list.fact-order <> 0
    then do:
      /* у товара существует цена */
      if v-b-code = v-root-b-code
      then do:
        /* требуется цена бар-кода корневого признака */
        assign
          v-recid-price-list = recid(buf_root_price-list)
          v-cli-base-rate    = 1
        .
        return . /* --->>>--- */
      end.
      else do:
        /* нам требуется цена не корневого признака */
        /* необходимо производить поиск наличия специальной цены на бар-код */
        find first buf_price-list no-lock
          where buf_price-list.doc-num    = buf_root_price-list.doc-num
            and buf_price-list.b-code     = v-b-code
            and buf_price-list.price-type = ""
          no-error.
        if available buf_price-list
        then do:
          assign
            v-recid-price-list = recid(buf_price-list)
            v-cli-base-rate    = 1
          .
          return . /* --->>>--- */
        end.
        if buf_bar-code.unit-cli = buf_root_bar-code.unit-cli
        then do:
          assign
            v-recid-price-list = recid(buf_root_price-list)
            v-cli-base-rate    = 1
          .
          return . /* --->>>--- */
        end.
        else do:
          /* ищем бар-код с основной единицей измерения */
          /* если его нет, то создаем его */
          define variable v-is-new as logical no-undo .

          { gbl/barcodcr.i
            buf_bar-code.gds-code
            buf_bar-code.node-code
            buf_bar-code.part-code
            buf_bar-code.in-code
            buf_root_bar-code.unit-cli
            1
            v-is-new
            buf_main_bar-code
            no-error
          }
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при поиске бар-кода" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          find first buf_price-list no-lock
            where buf_price-list.doc-num    = buf_root_price-list.doc-num
              and buf_price-list.b-code     = buf_main_bar-code.b-code
              and buf_price-list.price-type = ""
            no-error.
          if available buf_price-list
          then do:
            assign
              v-recid-price-list = recid(buf_price-list)
              /* v-cli-base-rate = cli-base-rate запрашиваемого бар-кода */
            .
            return . /* --->>>--- */
          end.
          else do:
            assign
              v-recid-price-list = recid(buf_root_price-list)
              /* v-cli-base-rate = cli-base-rate запрашиваемого бар-кода */
            .
            return . /* --->>>--- */
          end.
        end.
      end.
    end.
    else do:
      /* цена не задана */
      assign
        v-recid-price-list = ?
        v-cli-base-rate    = ?
      .
      return . /* --->>>--- */
    end.

    message
      vss-workfile vss-revision vss-description skip
      "Внутренняя ошибка при определении цены бар-кода" skip
      "Бар-код"    buf_bar-code.b-code skip
      "Код товара" buf_bar-code.gds-code skip
      "recid(root_price-list)" recid(buf_root_price-list) skip
      "recid(price-list)"      recid(buf_price-list) skip
      view-as alert-box error .
    undo, return error return-value .

  end.

end procedure. /* bcodepls */



procedure bcodeqnt :
  /*

  Определение текущего количества товара на объекте с данным бар-кодом

  В случае, если запрашивается корневой бар-код,
    возвращается общее количество товара на объекте
  В случае, если запрашивает бар-код признака с основной единицей измерени
    возвращается количество признака на объекте
  В случае, если запрашивается бар-код партии с основной единицей измерени
    возвращается количество партии в свободной зоне

  Если запрашивает бар-код с неосновной единицей измерения,
    то возвращается 0

  v-obj-type    объект
  v-obj-code

  v-b-code      бар-код

  v-root-b-code необязательный параметр
                0 или бар-код корневого признака товара
                можно указать для ускорения работы метода

  Возвращаемые параметры:
  v-fact-qnty   количество по бар-коду на объекте в базовых единицах измерени
                если информация о товаре отсутствует, то возвращается 0
                Для бар-кода с неосновной единицей измерения всегда возвращается ?
  v-qnty-type   возвращает тип бар-кода
                "gds-obj":u
                "prt-obj":u
                "parts":u
                "alt-unit":u
  v-qnty-recid  указатель на запись бд в которой хранится текущий остаток,
                отлична от ?
                имеет значение только если lookup(v-qnty-type, "gds-obj,prt-obj,parts":u) > 0
                и существует запись в соответствующей таблице

  В случае, если возвращается ошибка, то это свидетельствует
  о серьезных проблемах с базой данных или с параметрами вызова.
  Следует останавливать работу программы.

  */
  define input parameter  v-obj-type    like ub.gds-obj.obj-type  no-undo .
  define input parameter  v-obj-code    like ub.gds-obj.obj-code  no-undo .
  define input parameter  v-b-code      like ub.bar-code.b-code   no-undo .
  define input parameter  v-root-b-code like ub.bar-code.b-code   no-undo .
  define output parameter v-fact-qnty   like ub.gds-obj.fact-qnty no-undo .
  define output parameter v-qnty-type   as character              no-undo .
  define output parameter v-qnty-recid  as recid                  no-undo .

  define variable vss-description as character no-undo initial "bcodeqnt-01: Определение текущего количества товара на объекте с данным бар-кодом".

  define buffer buf_root_bar-code   for ub.bar-code .
  define buffer buf_bar-code        for ub.bar-code .
  define buffer buf_root_price-list for ub.price-list .
  define buffer buf_price-list      for ub.price-list .
  define buffer buf_main_bar-code   for ub.bar-code .
  define buffer buf_goods for ub.goods .
  define buffer buf_parts for ub.parts .
  define buffer buf_prt-obj for ub.prt-obj .
  define buffer buf_gds-obj for ub.gds-obj .

  do
  on error undo, return error return-value
  :
    /* находим бар-код для которого необходимо определить количество */
    find first buf_bar-code no-lock
      where buf_bar-code.b-code = v-b-code
      no-error .
    if not available buf_bar-code
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при задании входных параметров" skip
        "Не найден бар-код" v-b-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if v-root-b-code = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при задании входных параметров" skip
        "Должен быть задан бар-код корневого признака" skip
        "Или он должен быть равено 0" skip
        "Бар-код корневого признака" v-root-b-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if v-root-b-code = 0
    then do:
      /* определяем бар-код корневого признака товара */
      { gbl/gdsbcode.i
        buf_bar-code.gds-code
        ?
        v-root-b-code
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении корневого бар-кода для товара" skip
          "Код товара"  buf_bar-code.gds-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value . /* --->>>--- */
      end.
    end.

    /* находим бар-код корневого признака */
    find first buf_root_bar-code no-lock
      where buf_root_bar-code.b-code = v-root-b-code
      no-error .
    if not available buf_root_bar-code
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден бар-код корневого признака" skip
        "Код товара" buf_bar-code.gds-code skip
        "Бар-код" v-root-b-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    /* грубая проверка целостности */
    /* проверяем, что бар-коды принадлежат одно му и тому же товару */
    if buf_root_bar-code.gds-code <> buf_bar-code.gds-code
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "В качестве параметров указаны бар-коды разных товаров" skip
        "Бар-код" buf_bar-code.b-code skip
        "Код товара" buf_bar-code.gds-code skip
        "Бар-код корневого признака" buf_root_bar-code.b-code skip
        "Код товара в бар-коде корневого признака" buf_root_bar-code.gds-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if buf_bar-code.unit-cli <> buf_root_bar-code.unit-cli
    then do:
      /* запрошено количество для бар-кода с неосновной единицей измерения */
      /* возвращаем нулевое количество */
      assign
        v-fact-qnty  = ?
        v-qnty-type  = "alt-unit":u
        v-qnty-recid = ?
      .
      return . /* --->>>--- */
    end.

    find first buf_goods no-lock
      where buf_goods.gds-code = buf_bar-code.gds-code
      no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Бар-код" buf_bar-code.b-code skip
        "Код товара" buf_bar-code.gds-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if buf_bar-code.in-code <> ""
    then do:
      /* запрошено количество по бар-коду партии */
      assign
        v-fact-qnty  = 0
        v-qnty-type  = "parts":u
        v-qnty-recid = ?
      .
      find first buf_parts no-lock
        where buf_parts.obj-type  = v-obj-type
          and buf_parts.obj-code  = v-obj-code
          and buf_parts.artic     = buf_goods.artic
          and buf_parts.prod-type = buf_goods.prod-type
          and buf_parts.prod-code = buf_goods.prod-code
          and buf_parts.in-code   = buf_bar-code.in-code
          and buf_parts.part-code = buf_bar-code.part-code
          and buf_parts.out-code  = {&free-code}
        no-error .
      if available buf_parts
      then do:
        assign
          v-fact-qnty  = buf_parts.fact-qnty
          v-qnty-recid = recid(buf_parts)
        .
      end.
      return . /* --->>>--- */
    end.

    if buf_bar-code.b-code = buf_root_bar-code.b-code
    then do:
      /* запрошена информация об основном бар-коде товара */
      assign
        v-fact-qnty  = 0
        v-qnty-type  = "gds-obj":u
        v-qnty-recid = ?
      .
      find first buf_gds-obj no-lock
        where buf_gds-obj.obj-type = v-obj-type
          and buf_gds-obj.obj-code = v-obj-code
          and buf_gds-obj.gds-code = buf_bar-code.gds-code
        no-error .
      if available buf_gds-obj
      then do:
        assign
          v-fact-qnty  = buf_gds-obj.fact-qnty
          v-qnty-recid = recid(buf_gds-obj)
        .
      end.
      return . /* --->>>--- */
    end.
    else do:
      /* запрошена информация о бар-коде признака */
      assign
        v-fact-qnty  = 0
        v-qnty-type  = "prt-obj":u
        v-qnty-recid = ?
      .
      find first buf_prt-obj no-lock
        where buf_prt-obj.obj-type  = v-obj-type
          and buf_prt-obj.obj-code  = v-obj-code
          and buf_prt-obj.artic     = buf_goods.artic
          and buf_prt-obj.prod-type = buf_goods.prod-type
          and buf_prt-obj.prod-code = buf_goods.prod-code
          and buf_prt-obj.prt-code  = buf_bar-code.node-code
        no-error .
      if available buf_prt-obj
      then do:
        assign
          v-fact-qnty  = buf_prt-obj.fact-qnty
          v-qnty-recid = recid(buf_prt-obj)
        .
      end.
      return . /* --->>>--- */
    end.

    message
      vss-workfile vss-revision vss-description skip
      "Внутренняя ошибка при определении количества по бар-коду" skip
      "Бар-код"    buf_bar-code.b-code skip
      "Код товара" buf_bar-code.gds-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.

end procedure. /* bcodeqnt */


procedure prodbcat :

  do
  on error undo, return error return-value
  :

    /*Задает/получает различные признаки дополнительного бар-кода

      значения p-action
      список значений действий разделенных запятыми

      global=request     - является ли бар-код локальным для данной базы данных
        локальный код это
          код, который имеет единицу измерени
            весовой
            или
            дробно-бензиновый

            и длина бар-кода строго меньше 6

        все остальные - глобальные
    */

    define parameter buffer buf_prod-bc  for ub.prod-bc .
    define input  parameter p-action           as character no-undo .
    define output parameter p-return-attribute as logical no-undo .

    define variable vss-description as character no-undo initial "prodbcat-01: определение параметров дополнительного бар-кода".

    define buffer buf_bar-code   for ub.bar-code   .
    define buffer buf_goods      for ub.goods      .
    define buffer buf_units      for ub.units      .
    define buffer base_units     for ub.units      .
    define buffer buf_code-range for ub.code-range .

    define variable p-code-int as integer no-undo .
    define variable v-cdrg-type as character no-undo .

    if not available buf_prod-bc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не задан дополнительный бар-код" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if buf_prod-bc.bc-on-type eq {&gtin}
    then do:
      /*  p-return-attribute = true. */
       return.
    end.
    define variable ind                    as integer   no-undo .
    define variable v-num-entries-p-action as integer   no-undo .
    define variable v-action               as character no-undo .

    assign
      v-num-entries-p-action = num-entries(p-action)
    .
    assign
      p-return-attribute = true
    .
    _ind:
    do ind = 1 to v-num-entries-p-action
    :
      if ind > 1 and p-return-attribute = false then return.
      assign
        v-action = entry(ind, p-action)
      .

      case v-action :
        when "global=request":u
        then do:
          if not (buf_prod-bc.bc-on-type = ''
          or buf_prod-bc.bc-on-type = {&gbl-sc-code}
          or buf_prod-bc.bc-on-type = {&gbl-ss-code}) then do:
            assign
              p-return-attribute = false
            .
          end.
        end.
        when "weight=request":u
        then do:
          if not (buf_prod-bc.bc-on-type = {&loc-sc-code}
          or buf_prod-bc.bc-on-type = {&gbl-sc-code}) then do:
            assign
              p-return-attribute = false
            .
          end.
        end.
        when "pgweight=request":u
        then do:
          if not (buf_prod-bc.bc-on-type = {&loc-pg-code}) then do:
            assign
              p-return-attribute = false.

          end.
        end.
        when "petrolium=request":u
        then do:
          if not (buf_prod-bc.bc-on-type = {&loc-pt-code}) then do:
            assign
              p-return-attribute = false.

          end.
        end.
        when "scaleable=request":u
        then do:
          if not (buf_prod-bc.bc-on-type = {&loc-ss-code}
          or buf_prod-bc.bc-on-type = {&gbl-ss-code}) then do:
            assign
              p-return-attribute = false.
          end.
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестное значение параметра v-action " skip
            "v-action" v-action skip
            "p-action" p-action skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end case. /* v-action */
    end.
  end.

end procedure. /* prodbcat */


procedure prodbctv :

  do
  on error undo, return error return-value
  :

    /*Задает/получает различные признаки ЗНАЧЕНИЯ дополнительного бар-кода

      значения p-action
      список значений действий разделенных запятыми

      global=request     - является ли бар-код локальным для данной базы данных
        локальный код это
          код, который имеет единицу измерени
            весовой
            или
            дробно-бензиновый

            и длина бар-кода строго меньше 6

        все остальные - глобальные
    */

    define input  parameter p-b-str    like ub.prod-bc.b-str   no-undo .
    define input  parameter p-unit-cli like ub.units.unit-name no-undo .
    define input  parameter p-unit-base like ub.units.unit-name no-undo .
    define input  parameter p-action           as character no-undo .
    define output parameter p-return-attribute as logical no-undo .

    define variable vss-description as character no-undo init "prodbctv-01: определение параметров ЗНАЧЕНИЯ дополнительного бар-кода".

    define buffer buf_units      for ub.units      .
    define buffer base_units     for ub.units      .
    define buffer buf_code-range for ub.code-range .

    define variable p-code-int as integer no-undo .
    define variable v-cdrg-type as character no-undo .

    find first buf_units no-lock
      where buf_units.unit-name = p-unit-cli
      no-error .
    if not available buf_units
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена единица измерения бар-кода" skip
        "Единица измерения" p-unit-cli skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    define variable ind                    as integer   no-undo .
    define variable v-num-entries-p-action as integer   no-undo .
    define variable v-action               as character no-undo .

    assign
      v-num-entries-p-action = num-entries(p-action)
    .
    assign
      p-return-attribute = true
    .
    _ind:
    do ind = 1 to v-num-entries-p-action
    :
      if ind > 1 and p-return-attribute = false then return.
      assign
        v-action = entry(ind, p-action)
      .

      case v-action :
        when "global=request":u
        then do:

          /* определяем код глобальный или нет */
          /* локальный код это
                код, который имеет единицу измерени
                  весовой и находится в диапазоне локальных кодов
                  или
                  дробно-бензиновый

                и длина бар-кода строго меньше 6

            все остальное - глобальные коды

          */

          if lookup({&weight}, buf_units.type) > 0
          or (lookup({&petrolium}, buf_units.type)  > 0
              and lookup({&divisional}, buf_units.type) > 0
            )
          or lookup({&pieces}, buf_units.type) > 0
          then do:
            if length(p-b-str) < 6
            then do:
              if v-action = "global=request":u
                 and (lookup({&weight}, buf_units.type) > 0
                     or lookup({&pieces}, buf_units.type) > 0
                    )
              then do:
                /* нам необходимо найти code-range в соответствии с указанными условиями */
                /*    find ub.code-range where*/
                /*         ub.code-range.range-type = {&loc-bc-code} and*/
                /*         ub.code-range.first-code <= int( p-b-str ) and*/
                /*         ub.code-range.last-code >= int( p-b-str ) no-error.*/

                /* так реализован эффективный поиск */
                if lookup({&weight}, buf_units.type) > 0 then v-cdrg-type = {&loc-sc-code}.
                if lookup({&pieces}, buf_units.type) > 0 then v-cdrg-type = {&loc-pg-code}.
                find first buf_code-range
                  where buf_code-range.range-type = v-cdrg-type
                    and buf_code-range.last-code >= int( p-b-str )
                  use-index last-codei
                  no-error .
                if  available buf_code-range
                and buf_code-range.first-code <= int( p-b-str )
                then do:
                  assign
                    p-return-attribute = false
                  .
                end.
              end.
              else do:
                assign
                  p-return-attribute = false
                .
              end.
            end.
          end.
          if lookup({&divisional}, buf_units.type) > 0
          then do:
            find first buf_code-range
              where buf_code-range.range-type = {&loc-ss-code}
                and buf_code-range.last-code >= int( p-b-str )
              use-index last-codei
              no-error .
            if  available buf_code-range
            and buf_code-range.first-code <= int( p-b-str )
            then do:
              assign
                p-return-attribute = false
              .
            end.
          end.
        end.
        when "weight=request":u
        then do:
          assign
            p-code-int         = integer( p-b-str ) no-error
          .
          if lookup({&weight}, buf_units.type) > 0
             and length(p-b-str) < 6
             and length( string( p-code-int ) ) < 6
             and length(p-b-str) > 2
             and length( string( p-code-int ) ) > 2
          then do:
            next _ind.
          end.
          else do:
            assign
              p-return-attribute = false
            .
          end.
        end.
        when "pgweight=request":u
        then do:
          assign
            p-code-int         = integer( p-b-str ) no-error
          .
          if lookup({&pieces}, buf_units.type) > 0
             and length(p-b-str) < 6
             and length( string( p-code-int ) ) < 6
             and length(p-b-str) > 2
             and length( string( p-code-int ) ) > 2
          then do:
            next _ind.
          end.
          else do:
            assign
              p-return-attribute = true
            .
          end.
        end.
        when "petrolium=request":u
        then do:
          assign
            p-code-int         = integer( p-b-str ) no-error
          .
          if lookup( {&petrolium}, buf_units.type )  > 0
             and lookup( {&divisional}, buf_units.type ) > 0
             and length( p-b-str ) <= 2
             and length( string( p-code-int ) ) <= 2
             and p-code-int <> 0
          then do:
            next _ind.
          end.
          else do:
            assign
              p-return-attribute = false
            .
          end.
        end.
        when "scaleable=request":u
        then do:
          assign
            p-code-int         = integer( p-b-str ) no-error
          .
          find first base_units no-lock
            where base_units.unit-name = p-unit-base
            no-error .
          if not available base_units
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Не найдена основная единица измерения" skip
              "Единица измерения" p-unit-base skip
              view-as alert-box error .
            undo, return error return-value .
          end.

          if lookup({&divisional}, buf_units.type) > 0
             and lookup({&weight}, base_units.type) > 0
          then do:
            p-code-int = 0.
            assign
            p-code-int = integer( p-b-str )
            no-error .
            if error-status :error or p-code-int <= 0
            then do:
              assign
                p-return-attribute = false
              .
              next _ind.
            end.
            if trim(string(p-code-int, ">>>>>>>>9":U)) <>  p-b-str
            then do:
              assign
                p-return-attribute = false
              .
              next _ind.
            end.
            find first buf_code-range
              where buf_code-range.range-type = {&loc-ss-code}
                and buf_code-range.last-code >= p-code-int
                use-index last-codei
              no-error .
            if  available buf_code-range
            and buf_code-range.first-code <= p-code-int
            then do:
              next _ind.
            end.
            else do:
              find first buf_code-range
                where buf_code-range.range-type = {&gbl-ss-code}
                  and buf_code-range.last-code >= p-code-int
                  use-index last-codei
                no-error .
              if  available buf_code-range
              and buf_code-range.first-code <= p-code-int
              then do:
                next _ind.
              end.
              else do:
                assign
                  p-return-attribute = false
                .
              end.
            end.
          end.
          else do:
            assign
              p-return-attribute = false
            .
          end.
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестное значение параметра v-action " skip
            "v-action" v-action skip
            "p-action" p-action skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end case. /* v-action */
    end.
  end.

end procedure. /* prodbctv */


procedure bc-ean :

  define input  parameter p-bc-frmt  as character no-undo .
  define input  parameter p-bc-pfx   as character no-undo .
  define input  parameter p-b-code   as integer   no-undo .
  define output parameter p-ean-code as character no-undo .

  define buffer buf_bar-code for ub.bar-code .
  define buffer buf_prod-bc for ub.prod-bc.

  define variable v-bc-frmt as character no-undo .

  define variable v-check-length as integer   no-undo .
  define variable v-check-code   as character no-undo .

  do
  on error undo, return error return-value
  :
    find first buf_bar-code no-lock
      where buf_bar-code.b-code = p-b-code
      no-error .
    if not available buf_bar-code
    then do:
      undo, return error substitute("Ошибка задания входных параметров. Не найден штрих-код &1"
                                   ,p-b-code
                                   ) .
    end.

    case p-bc-frmt :
      when 'EAN13':u
      then do:
        assign
          v-check-length = 13
        .
      end.
      when 'EAN8':u
      then do:
        assign
          v-check-length = 8
        .
      end.
      otherwise do:
        undo, return error substitute('Неизвестное значение параметра &1', p-bc-frmt) .
      end.
    end case .

    for each buf_prod-bc no-lock
      where buf_prod-bc.b-code = p-b-code
        and buf_prod-bc.bc-on  = true
    on error undo, return error return-value
    :
      if length(buf_prod-bc.b-str) = v-check-length
      then do:
        assign
          v-check-code = substring (buf_prod-bc.b-str
                                    ,1
                                    ,length (buf_prod-bc.b-str) - 1
                                    )
        .
        run str/chk-sum.p
          (input-output v-check-code
          ) no-error.
        if error-status :error <> true
        and v-check-code = buf_prod-bc.b-str
        then do:
          assign
            p-ean-code = buf_prod-bc.b-str
          .
          return . /* --->>>--- */
        end.
      end.
    end.

    { str/bc-gnrti.i
      p-bc
      p-b-code
      p-ean-code
      no-message
    }
  end.

end procedure. /* bc-ean */


procedure prt-root-to-node-code :

  define input  parameter p-prt-root  like ub.goods.prt-root no-undo .
  define output parameter p-root-node like ub.goods.prt-root no-undo .

  define variable vss-description as character no-undo initial "prt-root-to-node-code-01: определение корневого признака шкалы по коду шкалы".

  define buffer buf_gds-prt for ub.gds-prt .

  do
  on error undo, return error return-value
  :
    find buf_gds-prt no-lock
      where buf_gds-prt.upper-code = p-prt-root
      no-error .
    if not available buf_gds-prt
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден корень шкалы" skip
        "Указатель на корень шкалы" p-prt-root skip
        view-as alert-box error .
      undo, return error return-value . /* --->>>--- */
    end.
    assign
      p-root-node = buf_gds-prt.node-code
    .
  end.

end procedure. /* prt-root-to-node-code */


procedure rootnode :

  /* определение корневого признака товара по артикулу */

  define input  parameter p-artic     like ub.goods.artic     no-undo .
  define input  parameter p-prod-type like ub.goods.prod-type no-undo .
  define input  parameter p-prod-code like ub.goods.prod-code no-undo .
  define output parameter p-root-node like ub.goods.prt-root  no-undo .

  define variable vss-description as character no-undo initial "rootnode-01: определение корневого признака товара по артикулу".

  define buffer buf_goods for ub.goods .

  do
  on error undo, return error return-value
  :

    find first buf_goods no-lock
      where buf_goods.artic     = p-artic
        and buf_goods.prod-type = p-prod-type
        and buf_goods.prod-code = p-prod-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    run prt-root-to-node-code in this-procedure
      (input  buf_goods.prt-root /* p-prt-root  */
      ,output p-root-node        /* p-root-node */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры prt-root-to-node-code" skip
        "Товар" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
        "Указатель на корень шкалы" buf_goods.prt-root skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value . /* --->>>--- */
    end.
  end.

end procedure. /* rootnode */


procedure gdsrtnod :

  /* определение корневого признака товара по коду товара */

  define input  parameter p-gds-code  like ub.goods.gds-code no-undo .
  define output parameter p-root-node like ub.goods.prt-root no-undo .

  define variable vss-description as character no-undo initial "gdsrtnod-01: определение корневого признака товара по коду товара".

  define buffer buf_goods   for ub.goods .

  do
  on error undo, return error return-value
  :

    find first buf_goods no-lock
      where buf_goods.gds-code  = p-gds-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    run prt-root-to-node-code in this-procedure
      (input  buf_goods.prt-root /* p-prt-root  */
      ,output p-root-node        /* p-root-node */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры prt-root-to-node-code" skip
        "Товар" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
        "Указатель на корень шкалы" buf_goods.prt-root skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value . /* --->>>--- */
    end.
  end.

end procedure. /* gdsrtnod */


procedure currdbat :

  define input  parameter p-action           as character no-undo .
  define output parameter p-return-attribute as logical no-undo .

  define variable vss-description as character no-undo initial "currdbat-01: определение атрибутов текущей базы данных".


  do
  on error undo, return error return-value
  :

    define variable v-db-num               as integer   no-undo .
    define variable v-num-entries-p-action as integer   no-undo .
    define variable v-ind                  as integer   no-undo .
    define variable v-action               as character no-undo .

    assign
      v-num-entries-p-action = num-entries(p-action)
    .

    do v-ind = 1 to v-num-entries-p-action
    on error undo, return error return-value
    :
      assign
        v-action = entry(v-ind, p-action)
      .
      case v-action :
        when 'office=request':u
        then do:
          { gbl/curdbnum.i
            v-db-num
            no-error
          }
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при определении текущей БД" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          if v-db-num = 0
          then do:
            assign
              p-return-attribute = true
            .
          end.
          else do:
            assign
              p-return-attribute = false
            .
          end.
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка задания входных параметров" skip
            "p-action" p-action skip
            "v-action" v-action skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
    end.
  end.

end procedure. /* currdbat */



procedure objat :
 /* Получить атрибут объекта (склад, магазин)

 doc-prt=request
   true - на объекте учитываются признаки
   false - на объекте не учитываются признаки

 shift-on=request
   true - на объекте включены смены
   false - на объекте отсутствуют смены

 autodate=request
   true - на объекте задано автоизменение даты
   false - на объекте не задано автоизменение даты
      для обычного объекта анализируется параметр autodate
      для сменного объекта анализируется параметр autodtsh

 active=request
    true - объект активный, допускается например изменение даты
    false - объект пассивный

 inout-price=request
    true - объект активный, допускается например изменение даты
    false - объект пассивный

 no-eq=request
    true  - запрещен приход при отсутствии цен
    false - разрешен приход при отсутствии цен

 price-calc=request
       нельзя закрыть приход на объекте, если приходная цена не равна продажной
    true  -
    false -

 */

  define input  parameter p-obj-type         like ub.gds-obj.obj-type  no-undo .
  define input  parameter p-obj-code         like ub.gds-obj.obj-code  no-undo .
  define input  parameter p-action           as character no-undo .
  define output parameter p-return-attribute as logical no-undo .

  define variable vss-description as character no-undo initial "objat-03: Получить атрибут объекта (склад магазин)".

  define variable ind      as integer no-undo .
  define variable v-action as character no-undo .

  define variable l-in-ov       as logical   no-undo .
  define variable l-doc-prt     as logical   no-undo .
  define variable l-shift-on    as logical   no-undo .
  define variable v-no-eq       as logical   no-undo .
  define variable v-price-calc  as logical   no-undo .
  define variable v-inout-price as logical   no-undo .
  define variable v-host-code like ub.sysconf.host-code no-undo .

  define buffer buf_store   for ub.store .
  define buffer buf_shop    for ub.shop .
  define buffer buf_gds-obj for ub.gds-obj .

  do
  on error undo, return error return-value
  :
    case p-obj-type :
      when {&stock}
      then do:
        find buf_store no-lock
          where buf_store.obj-code = p-obj-code
          no-error .
        if not available buf_store
        then do:
          undo, return error substitute("Не найден объект &1 &2", p-obj-type, p-obj-code).
        end.
        assign
          l-in-ov       = buf_store.in-ov
          l-doc-prt     = buf_store.doc-prt
          l-shift-on    = buf_store.shift-on
          v-no-eq       = buf_store.no-eq
          v-price-calc  = buf_store.price-calc
          v-inout-price = buf_store.inout-price
          v-host-code   = buf_store.host-code
        .
      end.
      when {&shop}
      then do:
        find buf_shop no-lock
          where buf_shop.obj-code = p-obj-code
          no-error .
        if not available buf_shop
        then do:
          undo, return error substitute("Не найден объект &1 &2", p-obj-type, p-obj-code).
        end.
        assign
          l-in-ov       = buf_shop.in-ov
          l-doc-prt     = buf_shop.doc-prt
          l-shift-on    = buf_shop.shift-on
          v-no-eq       = buf_shop.no-eq
          v-price-calc  = buf_shop.price-calc
          v-inout-price = buf_shop.inout-price
          v-host-code   = buf_shop.host-code
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Задан неправильный тип для объекта" skip
          "p-obj-type" p-obj-type skip
          "p-obj-code" p-obj-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case . /* p-obj-type */

    define variable v-num-entries-p-action as integer no-undo .

    assign
      v-num-entries-p-action = num-entries(p-action)
    .

    do ind = 1 to v-num-entries-p-action
    on error undo, return error return-value
    :

      assign
        v-action = entry(ind, p-action)
      .

      case v-action :
        when 'check-exist':u
        then do:
          /* просто проверяем, что объект существует */
          assign
            p-return-attribute = true
          .
        end.

        when 'doc-prt=request':u
        then do:
          assign
            p-return-attribute = l-doc-prt
          .
        end.

        when 'in-ov=request':u
        then do:
          assign
            p-return-attribute = l-in-ov
          .
        end.

        when 'shift-on=request':u
        then do:
          assign
            p-return-attribute = l-shift-on
          .
        end.

        when 'inout-price=request':u
        then do:
          assign
            p-return-attribute = v-inout-price
          .
        end.

        when 'exist-in-ov=request':u
        then do:
          /* существуют ли товары, требующие переоценки */
          if can-find (first buf_gds-obj no-lock
            where buf_gds-obj.obj-type = p-obj-type
              and buf_gds-obj.obj-code = p-obj-code
              and buf_gds-obj.in-ov    = yes
          )
          and l-in-ov
          then do:
            assign
              p-return-attribute = true
            .
          end.
          else do:
            assign
              p-return-attribute = false
            .
          end.
        end.

        when 'autodate=request':u
        then do:
          /* определяем имя параметра */
          define variable v-param-name    as character no-undo .
          define variable v-default-value as logical   no-undo .
          define variable v-value-character as character  no-undo .
          define variable v-value-date      as date       no-undo .
          define variable v-value-decimal   as decimal    no-undo .
          define variable v-value-integer   as integer    no-undo .
          define variable v-value-logical   as logical    no-undo .
          define variable v-tth             as handle     no-undo .
          define variable v-param-type      as character no-undo .


          if l-shift-on = false
          then do:
              assign
                v-param-name    = 'autodate':u
                v-default-value = yes
              .
          end.    /* if l-shift-on = false */
          else do:
              assign
                v-param-name    = 'autodtsh':u
                v-default-value = no
              .
          end.

          run adm/shattri.p ( input "get":U
                            , input  p-obj-type
                            , input  p-obj-code
                            , input  {&attr-obj-date}
                            , input  v-param-name
                            , output v-value-character
                            , output v-value-date
                            , output v-value-decimal
                            , output v-value-integer
                            , output v-value-logical
                            , output v-param-type
                            , input-output table-handle v-tth
                            ) no-error .
          if error-status :error
          then do:
              assign
                p-return-attribute   = v-default-value
              .
          end.
          else do:
            assign
              p-return-attribute = v-value-logical
            .
          end.

          delete object v-tth no-error.
        end.    /* when 'autodate=request':u */
        when 'active=request':u
        then do:
          define variable v-db-num as integer   no-undo .
          { gbl/curdbnum.i
            v-db-num
            no-error
          }
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при определении текущей БД" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.

          define buffer buf_clients for ub.clients .
          find first buf_clients no-lock
            where buf_clients.obj-type = p-obj-type
              and buf_clients.obj-code = p-obj-code
            no-error.
          if not available buf_clients
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка задания входных параметров" skip
              substitute("Не найден объект &1 &2.", p-obj-type, p-obj-code) skip
              view-as alert-box error .
            undo, return error return-value .
          end.

          if buf_clients.db-num = v-db-num
          then do:
            /* объект базы данных совпадает с текущим номером БД */
            /* это активный объект */
            assign
              p-return-attribute = yes
            .
          end.
          else do:
            assign
              p-return-attribute = no
            .
          end.
        end.
        when 'no-eq=request':u
        then do:
          assign
            p-return-attribute = v-no-eq
          .
        end.
        when 'price-calc=request':u
        then do:
          assign
            p-return-attribute = v-price-calc
          .
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка задания входных параметров" skip
            "Объект" p-obj-type p-obj-code skip
            "Список действий" p-action skip
            "Действие" v-action skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end case . /* v-action */
    end.
  end.

end procedure. /* objat */


procedure objretsp :

  /* определение кода оплаты <<возврат поставщику>> для объекта  */

  define input parameter  p-obj-type    like ub.gds-obj.obj-type no-undo .
  define input parameter  p-obj-code    like ub.gds-obj.obj-code no-undo .
  define output parameter p-ret-sup-pay like ub.store.ret-sup-pay no-undo .

  define variable vss-description as character no-undo initial "objretsp-01: определение кода оплаты <<возврат поставщику>> для объекта".

  define buffer buf_store for ub.store .
  define buffer buf_shop  for ub.shop  .

  do
  on error undo, return error return-value
  :
    if p-obj-type = {&stock}
    then do:
      find first buf_store no-lock
        where buf_store.obj-code = p-obj-code
        .
      assign
        p-ret-sup-pay = buf_store.ret-sup-pay
      .
    end.
    else do:
      find buf_shop no-lock
        where buf_shop.obj-code = p-obj-code
        .
      assign
        p-ret-sup-pay = buf_shop.ret-sup-pay
      .
    end.
  end.

end procedure. /* objretsp */


procedure objoutp :

  /* код оплаты РН - нач. знач. */

  define input parameter  p-obj-type like ub.gds-obj.obj-type no-undo .
  define input parameter  p-obj-code like ub.gds-obj.obj-code no-undo .
  define output parameter p-out-pay  like ub.store.out-pay no-undo .

  define variable vss-description as character no-undo initial "objretsp-01: определение кода оплаты <<возврат поставщику>> для объекта".

  define buffer buf_store for ub.store .
  define buffer buf_shop  for ub.shop  .

  do
  on error undo, return error return-value
  :
    if p-obj-type = {&stock}
    then do:
      find first buf_store no-lock
        where buf_store.obj-code = p-obj-code
        .
      assign
        p-out-pay = buf_store.out-pay
      .
    end.
    else do:
      find buf_shop no-lock
        where buf_shop.obj-code = p-obj-code
        .
      assign
        p-out-pay = buf_shop.out-pay
      .
    end.
  end.

end procedure. /* objoutp */

procedure objinpay :

  /* код оплаты ПН - нач. знач. */

  define input parameter  p-obj-type like ub.gds-obj.obj-type no-undo .
  define input parameter  p-obj-code like ub.gds-obj.obj-code no-undo .
  define output parameter p-in-pay  like ub.store.in-pay no-undo .

  define variable vss-description as character no-undo initial "objretsp-01: определение кода оплаты <<возврат поставщику>> для объекта".

  define buffer buf_store for ub.store .
  define buffer buf_shop  for ub.shop  .

  do
  on error undo, return error return-value
  :
    if p-obj-type = {&stock}
    then do:
      find first buf_store no-lock
        where buf_store.obj-code = p-obj-code
        .
      assign
        p-in-pay = buf_store.in-pay
      .
    end.
    else do:
      find buf_shop no-lock
        where buf_shop.obj-code = p-obj-code
        .
      assign
        p-in-pay = buf_shop.in-pay
      .
    end.
  end.

end procedure. /* objinpay */


procedure objdnpay :

  /* определение кода оплаты списания для объекта  */

  define input parameter  p-obj-type    like ub.gds-obj.obj-type no-undo .
  define input parameter  p-obj-code    like ub.gds-obj.obj-code no-undo .
  define output parameter p-down-pay    like ub.store.down-pay   no-undo .

  define variable vss-description as character no-undo initial "objdnpay-01: определение кода оплаты списания для объекта".

  define buffer buf_store for ub.store .
  define buffer buf_shop  for ub.shop  .

  do
  on error undo, return error return-value
  :
    if p-obj-type = {&stock}
    then do:
      find first buf_store no-lock
        where buf_store.obj-code = p-obj-code
        .
      assign
        p-down-pay = buf_store.down-pay
      .
    end.
    else do:
      find buf_shop no-lock
        where buf_shop.obj-code = p-obj-code
        .
      assign
        p-down-pay = buf_shop.down-pay
      .
    end.
  end.

end procedure. /* objdnpay */


procedure objconsp :

  /* определение кода оплаты <<консигнация>> для объекта  */

  define input parameter  p-obj-type  like ub.gds-obj.obj-type   no-undo .
  define input parameter  p-obj-code  like ub.gds-obj.obj-code   no-undo .
  define output parameter p-cons-code like ub.sysconf.purch-code no-undo .

  define variable vss-description as character no-undo initial "objconsp-01: определение кода оплаты <<получение товара на консигнацию>> для объекта".

  do
  on error undo, return error return-value
  :

    assign
      p-cons-code = integer({&consignation-code})
    .

  end.


end procedure. /* objconsp */


procedure objatext :
 /*
    Получить расширенный атрибут объекта

    За один раз может быть получен только один атрибут
    Программа аналогично программе чтения параметров конфигурации
    но используется для чтения информации из БД, связанной с объектом
    и не хранящейся в параметрах конфигурации

    ret-sup-pay=request

    cons-pay=request

    out-pay=request

    in-pay=request

 */

  define input  parameter p-obj-type like ub.gds-obj.obj-type  no-undo .
  define input  parameter p-obj-code like ub.gds-obj.obj-code  no-undo .
  define input  parameter p-action   as character no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .

  define variable vss-description as character no-undo initial "objatext-01: получение расширенного атрибута объекта".

  do
  on error undo, return error return-value
  :

    define variable v-action-code as character no-undo .

    assign
      v-action-code = entry(1, p-action, '=':u)
    .

    case p-action :
      when "ret-sup-pay=request":u
      then do:
        run objretsp in this-procedure
          (input  p-obj-type /* p-obj-type    */
          ,input  p-obj-code /* p-obj-code    */
          ,output p-value    /* p-ret-sup-pay */
          ).
        assign
          p-type  = {&type-int}
        .
      end.

      when "cons-pay=request":u
      then do:
        run objconsp in this-procedure
          (input  p-obj-type /* p-obj-type */
          ,input  p-obj-code /* p-obj-code */
          ,output p-value    /* p-cons-pay */
          ).
        assign
          p-type  = {&type-int}
        .
      end.

      when "out-pay=request":u
      then do:
        run objoutp in this-procedure
          (input  p-obj-type /* p-obj-type */
          ,input  p-obj-code /* p-obj-code */
          ,output p-value    /* p-cons-pay */
          ).
        assign
          p-type  = {&type-int}
        .
      end.

      when "in-pay=request":u
      then do:
        run objinpay in this-procedure
          (input  p-obj-type /* p-obj-type */
          ,input  p-obj-code /* p-obj-code */
          ,output p-value    /* p-cons-pay */
          ).
        assign
          p-type  = {&type-int}
        .
      end.

      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестный параметр вызова." skip
          "Объект" p-obj-type p-obj-code skip
          "p-action" p-action skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case . /* p-action */
  end.

end procedure. /* objatext */




procedure prtcheck :

  /* Проверка допустимости признака для использования в gds-dtl */

  define input parameter p-doc-prt    as logical no-undo .
  define input parameter p-node-code  like ub.gds-prt.node-code no-undo .
  define input parameter p-root-node  like ub.gds-prt.node-code no-undo .

  define variable vss-description as character no-undo initial "prtcheck-01: проверка допустимости признака для использования в gds-dtl".

  if p-doc-prt   = ?

  or p-node-code = ?

  or p-root-node = ?
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Входные параметры должны быть определены" skip
      "p-doc-prt"   p-doc-prt   skip
      "p-node-code" p-node-code skip
      "p-node-code" p-node-code skip
      "p-root-node" p-root-node skip
      "p-root-node" p-root-node skip
      view-as alert-box error .
    undo, return error return-value .
  end.


  if p-doc-prt
  then do:
    define variable l-terminal-prt as logical no-undo .

    /* на объекте включены признаки */
    /* p-node-code должен соответствовать терминальному признаку */
    { gbl/prtat.i
      p-node-code
      "'terminal-prt=request':U"
      l-terminal-prt
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута признака" skip
        "p-node-code" p-node-code skip
        "Запрашивался атрибут" "terminal-prt=request"
        error-status:get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if l-terminal-prt <> true
    then do:
      undo, return error
        vss-workfile + "Недопустимый признак" + {&new-line}
        + "На объекте включены признаки" + {&new-line}
        + "Указанный признак не является терминальным" + {&new-line}
        + "p-node-code " + string(p-node-code) + {&new-line}
        + "p-root-node " + string(p-root-node) + {&new-line}
        .
    end.
  end.
  else do:
    /* на объекте выключены признаки */
    /* p-node-code должен совпадать с p-root-node */

    if p-node-code <> p-root-node
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Недопустимый признак" skip
        "На объекте выключены признаки" skip
        "Указанный признак не является корневым" skip
        "p-node-code" p-node-code skip
        error-status:get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error
        vss-workfile + "Недопустимый признак" + {&new-line}
        + "На объекте выключены признаки" + {&new-line}
        + "Указанный признак не является корневым" + {&new-line}
        + "p-node-code " + string(p-node-code) + {&new-line}
        + "p-root-node " + string(p-root-node) + {&new-line}
        .
    end.
  end.

end procedure. /* prtcheck */


procedure prtat :

  /* Получить атрибут шкалы/признака */
  define input  parameter p-node-code        like ub.gds-prt.node-code no-undo .
  define input  parameter p-action           as character              no-undo .
  define output parameter p-return-attribute as logical                no-undo .

  define variable vss-description as character no-undo initial "prtat-01: Получить атрибут шкалы/признака".

  define variable ind      as integer   no-undo .
  define variable v-action as character no-undo .

  /* ищем указанный признак */
  define buffer buf_gds-prt for ub.gds-prt .
  find first buf_gds-prt no-lock
    where buf_gds-prt.node-code = p-node-code
    no-error .
  if not available buf_gds-prt
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найдена шкала." skip
      "p-node-code" p-node-code skip
      "p-action"    p-action skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  define variable v-num-entries-p-action as integer no-undo .

  assign
    v-num-entries-p-action = num-entries(p-action)
  .

  do ind = 1 to v-num-entries-p-action
  :
    assign
      v-action = entry(ind, p-action)
    .

    case v-action :
      when 'empty-scale=request'
      then do:
        /* проверяем, что признак является корневым */
        if buf_gds-prt.root <> true
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Переданный признак не является корнем шкалы." skip
            "p-node-code" p-node-code skip
            "p-action"    v-action skip
            view-as alert-box error .
          undo, return error return-value .
        end.

        /* возможная дополнительная проверка того, */
        /* что признак не имеет родительского, */
        /* а следовательно корневой */
        /*define buffer parent_gds-prt for buf_gds-prt .*/

        /*if can-find(first parent_gds-prt no-lock*/
        /*  where parent_gds-prt.node-code = buf_gds-prt.upper-code*/
        /*) then do:*/
        /*  message*/
        /*    vss-workfile vss-revision vss-description skip */
        /*    "Запрошенная шкала не является корневой." skip*/
        /*    "node-code" p-node-code skip*/
        /*    view-as alert-box error .*/
        /*  undo, return error return-value .*/
        /*end.*/

        /* признак того, что товар имеет пустую шкалу */
        assign
          p-return-attribute = (buf_gds-prt.node-name = {&empty-scale} )
        .
      end.

      when 'terminal-prt=request'
      then do:
        define variable l-terminal-prt as logical no-undo .

        assign
          l-terminal-prt = true
        .
        define buffer terminal_gds-prt for ub.gds-prt .
        find first terminal_gds-prt no-lock
          where terminal_gds-prt.upper-code = p-node-code
          no-error .
        if available terminal_gds-prt
        then do:
          /* признак не терминальный */
          assign
            l-terminal-prt = false
          .
        end.

        assign
          p-return-attribute = l-terminal-prt
        .
      end.

      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестный параметр вызова." skip
          "p-node-code" p-node-code skip
          "p-action" p-action skip
          "v-action" v-action skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case . /* v-action */
  end.

end procedure. /* prtat */


define temp-table temp-pl-gds no-undo
  field pl-code          like ub.pl-gds.pl-code
  field fact-qnty        like ub.pl-gds.fact-qnty
  field free-qnty        like ub.pl-gds.free-qnty
  field db-fact-qnty     like ub.pl-gds.fact-qnty
  field db-free-qnty     like ub.pl-gds.free-qnty
  field cli-fact-qnty    like ub.pl-gds.cli-fact-qnty
  field cli-free-qnty    like ub.pl-gds.cli-free-qnty
  field db-cli-fact-qnty like ub.pl-gds.cli-fact-qnty
  field db-cli-free-qnty like ub.pl-gds.cli-free-qnty
  index xpk is primary unique pl-code
.

procedure gdscheck :
  /* Проверка целостности товара

    1. свободно и фактически по товару должно совпадать с соответствующими значениями
      для корневого признака
    2. свободно и фактически должно совпадать с количеством по партиям
      в свободной зоне и с общим количество по партиям (включая зарезервированные партии)

  p-mode
    ""         при обнаружении нецелостного товара выдается сообщение на экран
              возвращается ошибка
    "return"   при обнаружении нецелостного товара
              возвращается ошибка и текстовая строка с описанием проблемы

  */

  define input parameter p-obj-type  like ub.gds-obj.obj-type  no-undo .
  define input parameter p-obj-code  like ub.gds-obj.obj-code  no-undo .
  define input parameter p-artic     like ub.gds-obj.artic     no-undo .
  define input parameter p-prod-type like ub.gds-obj.prod-type no-undo .
  define input parameter p-prod-code like ub.gds-obj.prod-code no-undo .
  define input parameter p-root-node like ub.prt-obj.prt-code  no-undo .
  define input parameter p-mode      as character              no-undo .

  define variable vss-description as character no-undo initial "gdscheck-01: Проверка целостности товара" .

  define buffer buf_goods       for ub.goods .
  define buffer buf_gds-obj     for ub.gds-obj .
  define buffer buf_prt-obj     for ub.prt-obj .
  define buffer buf_parts       for ub.parts .
  define buffer buf_units       for ub.units .
  define buffer buf_contract    for ub.contract .
  define buffer buf_temp-pl-gds for temp-pl-gds .
  define buffer buf_pl-gds      for ub.pl-gds .

  define variable l-bad-gds   as logical /* intentionally undo */ initial true .
  define variable v-host-code as integer   no-undo .

  define variable v-message as character no-undo .

  if  p-mode <> ""
  and p-mode <> ?
  and p-mode <> "return"
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестное значение параметра p-mode" skip
      "p-mode" p-mode skip
      view-as alert-box information.
    undo, return error return-value .
  end.


  assign
    v-message = "Объект" + " " + string(p-obj-type) + " " + string(p-obj-code) + {&new-line}
              + "Товар" + " " + string(p-artic) + " "
                + string(p-prod-type) + " " + string(p-prod-code) + {&new-line}
  .


  check_block:
  do
  on error undo check_block, leave
  :
    assign
      l-bad-gds = false
    .

    find first buf_goods no-lock
      where buf_goods.artic     = p-artic
        and buf_goods.prod-type = p-prod-type
        and buf_goods.prod-code = p-prod-code
      no-error .
    if not available buf_goods
    then do:
      assign
        v-message = v-message
                  + "Не найдена запись товар" + {&new-line}
        l-bad-gds = true
      .
      leave check_block.
    end.

    if buf_goods.PS begins "123321"
    then do:
      /* товар уже поломан - его не надо контролировать */
      /* с тем чтобы он не мешал закрытию документов */
      return .
    end.

    { gbl/hostcode.i
      p-obj-type
      p-obj-code
      v-host-code
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении кода фирмы для объекта" skip
        "Объект" p-obj-type p-obj-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    define variable l-goods-twounit as logical no-undo .

    { gbl/gdsat.i
      buf_goods.artic
      buf_goods.prod-type
      buf_goods.prod-code
      "'twounit=request':U"
      l-goods-twounit
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
        'twounit=request':u skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    find first buf_gds-obj exclusive-lock
      where buf_gds-obj.obj-type  = p-obj-type
        and buf_gds-obj.obj-code  = p-obj-code
        and buf_gds-obj.artic     = p-artic
        and buf_gds-obj.prod-type = p-prod-type
        and buf_gds-obj.prod-code = p-prod-code
      no-error .
    if not available buf_gds-obj
    then do:
      assign
        v-message = v-message
                  + "Не найдена запись товара на объекте" + {&new-line}
        l-bad-gds = true
      .
      leave check_block.
    end.

    if p-root-node = ?
    then do:
      { gbl/rootnode.i
        p-artic
        p-prod-type
        p-prod-code
        p-root-node
        no-error
      }
      if error-status :error
      then do:
        assign
          v-message = v-message
                    + "Не найден корень шкалы" + {&new-line}
          l-bad-gds = true
        .
        leave check_block.
      end.
    end.

    define variable v-total-prt-obj-fact-qnty like buf_prt-obj.fact-qnty no-undo .
    define variable v-total-prt-obj-free-qnty like buf_prt-obj.free-qnty no-undo .

    assign
      v-total-prt-obj-fact-qnty = 0
      v-total-prt-obj-free-qnty = 0
    .
    for each buf_prt-obj share-lock
      where buf_prt-obj.obj-type  = p-obj-type
        and buf_prt-obj.obj-code  = p-obj-code
        and buf_prt-obj.artic     = p-artic
        and buf_prt-obj.prod-type = p-prod-type
        and buf_prt-obj.prod-code = p-prod-code
        and buf_prt-obj.prt-code  = p-root-node
    on error undo check_block, leave check_block
    :
      assign
        v-total-prt-obj-fact-qnty = v-total-prt-obj-fact-qnty + buf_prt-obj.fact-qnty
        v-total-prt-obj-free-qnty = v-total-prt-obj-free-qnty + buf_prt-obj.free-qnty
      .
    end.

    if v-total-prt-obj-fact-qnty <> buf_gds-obj.fact-qnty
    or v-total-prt-obj-free-qnty <> buf_gds-obj.free-qnty
    then do:
      assign
        v-message = v-message
                  + "Количество по шкале не совпадает с количеством по товару" + {&new-line}
                  + "По товару:" + {&new-line}
                  + "  " + "фактически" + " " + string(buf_gds-obj.fact-qnty) + {&new-line}
                  + "  " + "свободно" + " " + string(buf_gds-obj.free-qnty) + {&new-line}
                  + "По шкале:" + {&new-line}
                  + "  " + "фактически" + " " + string(v-total-prt-obj-fact-qnty) + {&new-line}
                  + "  " + "свободно" + " " + string(v-total-prt-obj-free-qnty) + {&new-line}
        l-bad-gds = true
      .
      leave check_block.
    end.

    find first buf_units no-lock
      where buf_units.unit-name = buf_goods.unit-base
      no-error .
    if not available buf_units
    then do:
      assign
        v-message = v-message
                  + "Не найдена базовая единица измерения"
                  + string(buf_goods.unit-base) + {&new-line}
        l-bad-gds = true
      .
      leave check_block.
    end.

    define variable l-goods-serial as logical no-undo .
    { gbl/gdsat.i
      buf_goods.artic
      buf_goods.prod-type
      buf_goods.prod-code
      "'serial=request':u"
      l-goods-serial
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
        'twounit=request':u skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    /* для серийного товара устанавливаем признак продажи по партиям */
    if l-goods-serial = true
    then do:
      if buf_gds-obj.cash-parts <> true
      then do:
        assign
          v-message = v-message
                    + "У серийного товара отсутствует признак продажи по партиям (cash-parts)"
                    + {&new-line}
          l-bad-gds = true
        .
        leave check_block.
      end.
    end.

    /* для топливного дробного товара - задаем признак учета по складским местам */
    if  lookup({&petrolium},  buf_units.type) > 0
    and lookup({&divisional}, buf_units.type) > 0
    then do:
      if buf_gds-obj.place-rsrv <> true
      then do:
        assign
          v-message = v-message
                    + "У дробного топливного товара отсутствует признак учета по местам хранения (place-rsrv)"
                    + {&new-line}
          l-bad-gds = true
        .
        leave check_block.
      end.
    end.

    /* проверяем общее количество по складским местам */
    if buf_gds-obj.place-rsrv = true
    then do:

      for each buf_temp-pl-gds
      on error undo, return error return-value
      :
        delete buf_temp-pl-gds .
      end.

      for each buf_pl-gds share-lock
        where buf_pl-gds.gds-code = buf_goods.gds-code
          and buf_pl-gds.obj-type = p-obj-type
          and buf_pl-gds.obj-code = p-obj-code
      on error undo, return error return-value
      :
        create buf_temp-pl-gds .
        assign
          buf_temp-pl-gds.pl-code      = buf_pl-gds.pl-code
          buf_temp-pl-gds.fact-qnty    = 0.0
          buf_temp-pl-gds.free-qnty    = 0.0
          buf_temp-pl-gds.db-fact-qnty = buf_pl-gds.fact-qnty
          buf_temp-pl-gds.db-free-qnty = buf_pl-gds.free-qnty
        .
      end.
    end.

    /* проверяем все партии свободной зоны */
    define variable v-parts-fact-qnty     as decimal no-undo .
    define variable v-parts-free-qnty     as decimal no-undo .
    define variable v-parts-cli-qnty      as decimal no-undo .
    define variable v-parts-add-fact-qnty as decimal no-undo .
    define variable v-parts-add-free-qnty as decimal no-undo .

    define buffer buf_trn-doc for ub.trn-doc .

    assign
      v-parts-fact-qnty = 0
      v-parts-free-qnty = 0
      v-parts-cli-qnty  = 0
    .

    for each buf_parts share-lock
      where buf_parts.obj-type  = p-obj-type
        and buf_parts.obj-code  = p-obj-code
        and buf_parts.artic     = p-artic
        and buf_parts.prod-type = p-prod-type
        and buf_parts.prod-code = p-prod-code
        and buf_parts.status_   = no
        and buf_parts.rsrv-free = yes
    on error undo check_block, leave check_block
    :
      assign
        v-parts-add-fact-qnty = 0.0
        v-parts-add-free-qnty = 0.0
      .

      if buf_parts.out-code = {&output-code}
      then do:
        assign
          v-message = v-message
                    + "Партия по ПН" + " " + string(buf_parts.in-code) + {&new-line}
                    + "в расходной зоне логически принадлежит приходной зоне (rsrv-free=yes)" + {&new-line}
          l-bad-gds = true
        .
        leave check_block.
      end.

      if buf_gds-obj.place-rsrv = true
        and ( buf_parts.pl-code = ?
              or buf_parts.pl-code = 0
            )
      then do:
        assign
          v-message = v-message
                    + "Партия по ПН" + " " + string(buf_parts.in-code) + {&new-line}
                    + "Имеет не заданное складское место (pl-code)" + {&new-line}
          l-bad-gds = true
        .
        leave check_block.
      end.

      if buf_parts.out-code = {&free-code}
      then do:
        assign
          v-parts-add-fact-qnty = v-parts-add-fact-qnty + buf_parts.qnty
          v-parts-add-free-qnty = v-parts-add-free-qnty + buf_parts.qnty
        .
      end.
      else do:
        /* buf_parts.out-code <> {&free-code} */
        /* у партий зарезервированных для инвентаризации партия хранится с отрицательным знаком
          в любом случае партия, зарезервированная из свободной зоны
          имеет смысл зарезервированного положительного количества
        */
        find first buf_trn-doc no-lock
          where buf_trn-doc.doc-code = buf_parts.out-code
          no-error .
        if not available buf_trn-doc
        then do:
          assign
            v-message = v-message
                      + "Партия по ПН" + " " + string(buf_parts.in-code) + {&new-line}
                      + "Не найден документ для которого зарезервирована партия" + {&new-line}
                      + "Документ" + " " + string(buf_parts.out-code) + {&new-line}
            l-bad-gds = true
          .
          leave check_block.
        end.


        if buf_parts.in-code <> buf_parts.out-code
        then do:
          assign
            v-parts-add-fact-qnty = v-parts-add-fact-qnty + abs(buf_parts.qnty)
          .
        end.
        if buf_trn-doc.doc-type = {&inventory}
        then do:
          if buf_parts.qnty > 0
          then do:
            assign
              v-message = v-message
                        + "Партия по ПН" + " " + string(buf_parts.in-code) + {&new-line}
                        + "Зарезервированная за документом инвентаризации" + " "
                          + string(buf_parts.out-code) + {&new-line}
                        + "Имеет положительный знак количества" + {&new-line}
                        + "  " + "buf_trn-doc.doc-type" + " " + string(buf_trn-doc.doc-type) + {&new-line}
                        + "  " + "buf_parts.qnty" + " " + string(buf_parts.qnty) + {&new-line}
              l-bad-gds = true
            .
            leave check_block.
          end.
          if buf_parts.in-code <> buf_parts.out-code
          then do:
            assign
              v-parts-add-free-qnty = v-parts-add-free-qnty + abs(buf_parts.qnty)
            .
          end.
        end.
        else do:
          /* buf_trn-doc.doc-type <> {&inventory} */
          if buf_parts.qnty < 0
          then do:
            assign
              v-message = v-message
                        + "Партия по ПН" + " " + string(buf_parts.in-code) + {&new-line}
                        + "Зарезервированная за документом" + " " + string(buf_parts.out-code) + {&new-line}
                        + "Имеет отрицательный знак количества" + {&new-line}
                        + "  " + "buf_trn-doc.doc-type" + " " + string(buf_trn-doc.doc-type) + {&new-line}
                        + "  " + "buf_parts.qnty" + " " + string(buf_parts.qnty) + {&new-line}
              l-bad-gds = true
            .
            leave check_block.
          end.
          if buf_parts.in-code = buf_parts.out-code
          then do:
            assign
              v-parts-add-free-qnty = v-parts-add-free-qnty - abs(buf_parts.qnty)
            .
          end.
        end.
      end.

      assign
        v-parts-fact-qnty = v-parts-fact-qnty + v-parts-add-fact-qnty
        v-parts-free-qnty = v-parts-free-qnty + v-parts-add-free-qnty
      .

      if buf_gds-obj.place-rsrv = true then do:
        find first buf_temp-pl-gds
          where buf_temp-pl-gds.pl-code = buf_parts.pl-code
          no-error .
        if not available buf_temp-pl-gds then do:
          create buf_temp-pl-gds .
          assign
            buf_temp-pl-gds.pl-code = buf_parts.pl-code
          .
        end.
        assign
          buf_temp-pl-gds.fact-qnty = buf_temp-pl-gds.fact-qnty + v-parts-add-fact-qnty
          buf_temp-pl-gds.free-qnty = buf_temp-pl-gds.free-qnty + v-parts-add-free-qnty
        .
      end.

      if buf_parts.contract-code = ?
      then do:
        assign
          v-message = v-message
                    + "Партия по ПН" + " " + string(buf_parts.in-code) + {&new-line}
                    + "Неопределённое значение поля contract-code" + {&new-line}
          l-bad-gds = true
        .
        leave check_block.
      end.

      if buf_parts.contract-code <> 0
      then do:
          
        /* контракт может быть задан только для партии с реальным поставщиком */
        /*if  buf_parts.supp-type <> {&cmp}
        and buf_parts.supp-type <> {&prs}
        then do:
          assign
            v-message = v-message
                      + "Партия по ПН" + " " + string(buf_parts.in-code) + {&new-line}
                      + substitute("Контракт может быть задан только для партии с реальным поставщиком") + {&new-line}
                      + substitute("Поставщик &1 &2", buf_parts.supp-type, buf_parts.supp-code) + {&new-line}
                      + substitute("Код фирмы &1", v-host-code) + {&new-line}
                      + substitute("Код контракта &1", buf_parts.contract-code) + {&new-line}
            l-bad-gds = true
          .
          leave check_block.
        end.*/

        /* у партии задан контракт - проверяем его наличие */
        find first buf_contract no-lock
          where buf_contract.host-code     = v-host-code
            and buf_contract.contract-code = buf_parts.contract-code
          no-error .
        if not available buf_contract
        then do:
          assign
            v-message = v-message
                      + "Партия по ПН" + " " + string(buf_parts.in-code) + {&new-line}
                      + substitute("Не найден контракт партии") + {&new-line}
                      + substitute("Код фирмы &1", v-host-code) + {&new-line}
                      + substitute("Код контракта &1", buf_parts.contract-code) + {&new-line}
            l-bad-gds = true
          .
          leave check_block.
        end.

        if buf_parts.supp-type <> buf_contract.cli-type
        or buf_parts.supp-code <> buf_contract.cli-code
        then do:
            
          if not buf_contract.doc-type = {&expense} then do:
          assign
            v-message = v-message
                      + "Партия по ПН" + " " + string(buf_parts.in-code) + {&new-line}
                      + substitute("Отличаются поставщик партии и контрагент договора") + {&new-line}
                      + substitute("Поставщик партии &1 &2", buf_parts.supp-type, buf_parts.supp-code) + {&new-line}
                      + substitute("Контрагент договора &1 &2",buf_contract.cli-type, buf_contract.cli-code) + {&new-line}
                      + substitute("Код фирмы &1", v-host-code) + {&new-line}
                      + substitute("Код контракта &1", buf_contract.contract-code) + {&new-line}
            l-bad-gds = true
          .
          leave check_block.
        end.
        end.

        if  buf_parts.supp-type = {&cmp}
        and buf_parts.supp-code = v-host-code
        then do:
          assign
            v-message = v-message
                      + "Партия по ПН" + " " + string(buf_parts.in-code) + {&new-line}
                      + substitute("Нельзя указывать контракт для партии, поставщиком которой является собственная фирма") + {&new-line}
                      + substitute("Поставщик партии &1 &2", buf_parts.supp-type, buf_parts.supp-code) + {&new-line}
                      + substitute("Контрагент договора &1 &2",buf_contract.cli-type, buf_contract.cli-code) + {&new-line}
                      + substitute("Код фирмы &1", v-host-code) + {&new-line}
                      + substitute("Код контракта &1", buf_contract.contract-code) + {&new-line}
            l-bad-gds = true
          .
          leave check_block.
        end.

        if buf_parts.exch-code <> buf_contract.curr-code
        then do:
          assign
            v-message = v-message
                      + "Партия по ПН" + " " + string(buf_parts.in-code) + {&new-line}
                      + "Не совпадают валюта партии и валюта контракта" + {&new-line}
                      + substitute("Валюта партии &1", buf_parts.exch-code) + {&new-line}
                      + substitute("Валюта контракта &1", buf_contract.curr-code) + {&new-line}
            l-bad-gds = true
          .
          leave check_block.
        end.

        define variable v-contract-purch-code as integer   no-undo .

        { gbl/cntpurch.i
          buf_contract.contract-type
          v-contract-purch-code
          no-error
        }
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при определении типа поставки для контракта" skip
            "Код фирмы" v-host-code skip
            "Код контракта" buf_contract.contract-code skip
            "Тип контракта" buf_contract.contract-type skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.

        if v-contract-purch-code = {&bef-responsible-storage-code}
        then do:
          if  buf_parts.purch-code <> {&bef-responsible-storage-code}
          and buf_parts.purch-code <> {&bef-repayment-code}
          then do:
            /* проверка типа поставки партии */
            assign
              v-message = v-message
                        + "Партия по ПН" + " " + string(buf_parts.in-code) + {&new-line}
                        + "Не совпадают тип поставки партии и тип поставки контракта" + {&new-line}
                        + substitute("Код фирмы &1", v-host-code) + {&new-line}
                        + substitute("Код контракта &1", buf_contract.contract-code) + {&new-line}
                        + substitute("Тип поставки партии &1", buf_parts.purch-code) + {&new-line}
                        + substitute("Тип поставки контракта &1", v-contract-purch-code) + {&new-line}
              l-bad-gds = true
            .
            leave check_block.
          end.
        end.
        else do:
          if buf_parts.purch-code <> v-contract-purch-code
          then do:
            /* проверка типа поставки партии */
            assign
              v-message = v-message
                        + "Партия по ПН" + " " + string(buf_parts.in-code) + {&new-line}
                        + "Не совпадают тип поставки партии и тип поставки контракта" + {&new-line}
                        + substitute("Код фирмы &1", v-host-code) + {&new-line}
                        + substitute("Код контракта &1", buf_contract.contract-code) + {&new-line}
                        + substitute("Тип поставки партии &1", buf_parts.purch-code) + {&new-line}
                        + substitute("Тип поставки контракта &1", v-contract-purch-code) + {&new-line}
              l-bad-gds = true
            .
            leave check_block.
          end.
        end.
      end.

      if l-goods-twounit
      then do:
        if buf_parts.out-code = {&free-code}
        then do:
          assign
            v-parts-cli-qnty = v-parts-cli-qnty + buf_parts.cli-qnty
          .
        end.
        else do:
          if buf_parts.in-code <> buf_parts.out-code
          then do:
            assign
              v-parts-cli-qnty = v-parts-cli-qnty + abs(buf_parts.cli-qnty)
            .
          end.
        end.
      end.
    end.

    if buf_gds-obj.place-rsrv = true
    then do:
      define variable is-petrol as logical no-undo .
      define variable is-pieces as logical no-undo .
      { str/is-petrl.i
          buf_goods.artic
          buf_goods.prod-type
          buf_goods.prod-code
          is-petrol
          is-pieces
          no-error
      }
      if error-status :error
      then do:
        assign
          is-petrol = ?
          is-pieces = ?
        .
      end.
      if not( is-petrol = true
              and is-pieces = false
            )
      then do:
        for each buf_temp-pl-gds
        on error undo check_block, leave check_block
        :
          if buf_temp-pl-gds.db-fact-qnty <> buf_temp-pl-gds.fact-qnty
          or buf_temp-pl-gds.db-free-qnty <> buf_temp-pl-gds.free-qnty
          then do:
            assign
              v-message = v-message
                        + "Количество по партиям свободной зоны и зарезервированным партиям" + {&new-line}
                        + "не совпадает с количеством по месту резервирования" + {&new-line}
                        + "Место хранения:" + " " + string(buf_temp-pl-gds.pl-code) + {&new-line}
                        + "  " + "фактически" + " " + string(buf_temp-pl-gds.db-fact-qnty) + {&new-line}
                        + "  " + "свободно" + " " + string(buf_temp-pl-gds.db-free-qnty) + {&new-line}
                        + "По партиям:" + {&new-line}
                        + "  " + "фактически" + " " + string(buf_temp-pl-gds.fact-qnty) + {&new-line}
                        + "  " + "свободно" + " " + string(buf_temp-pl-gds.free-qnty) + {&new-line}
              l-bad-gds = true
            .
            leave check_block.
          end.
        end. /* for each buf_temp-pl-gds */
      end. /* не топливо */
    end. /* if buf_gds-obj.place-rsrv = true */

    if v-parts-fact-qnty <> buf_gds-obj.fact-qnty
    or v-parts-free-qnty <> buf_gds-obj.free-qnty
    then do:
      assign
        v-message = v-message
                  + "Количество по партиям свободной зоны и зарезервированным партиям" + {&new-line}
                  + "не совпадает с количеством по товару" + {&new-line}
                  + "По товару:" + {&new-line}
                  + "  " + "фактически" + " " + string(buf_gds-obj.fact-qnty) + {&new-line}
                  + "  " + "свободно" + " " + string(buf_gds-obj.free-qnty) + {&new-line}
                  + "По партиям:" + {&new-line}
                  + "  " + "фактически" + " " + string(v-parts-fact-qnty) + {&new-line}
                  + "  " + "свободно" + " " + string(v-parts-free-qnty) + {&new-line}
        l-bad-gds = true
      .
      leave check_block.
    end.

    if l-goods-twounit
    then do:
      if v-parts-cli-qnty <> buf_gds-obj.fact-cli-qnty
      then do:
        assign
          v-message = v-message
                    + "Количество второй единицы измерения по партиям свободной зоны и зарезервированным партиям" + {&new-line}
                    + "не совпадает с количеством второй единицы измерения по товару" + {&new-line}
                    + "По товару:" + {&new-line}
                    + "  " + "фактически" + " " + string(buf_gds-obj.fact-qnty) + {&new-line}
                    + "  " + "свободно" + " " + string(buf_gds-obj.free-qnty) + {&new-line}
                    + "  " + "вторая ед. изм." + " " + string(buf_gds-obj.fact-cli-qnty) + {&new-line}
                    + "По партиям:" + {&new-line}
                    + "  " + "фактически" + " " + string(v-parts-fact-qnty) + {&new-line}
                    + "  " + "свободно" + " " + string(v-parts-free-qnty) + {&new-line}
                    + "  " + "вторая ед. изм." + " " + string(v-parts-cli-qnty) + {&new-line}
          l-bad-gds = true
        .
        leave check_block.
      end.
    end.
  end. /* check_block */


  if l-bad-gds
  then do:
    define variable v-return-value as character no-undo .

    if p-mode = ""
    or p-mode = ?
    then do:
      message
        vss-workfile + " " + vss-revision + " " + vss-description + {&new-line}
        v-message + {&new-line}
        view-as alert-box .
    end.

    if p-mode = "return"
    then do:
      assign
        v-return-value = v-message
      .
    end.

    undo, return error v-return-value .

  end.

end procedure. /* gdscheck */


procedure prtlevel :

  /* определяет количество уровней в шкале */
  /* 1 пустая шкала */
  /* 2 одноуровневая шкала */
  /* 3 двухуровневая шкала */

  define input  parameter p-root-node  like ub.gds-prt.node-code no-undo .
  define output parameter p-prt-level  as integer no-undo .

  define variable vss-description as character no-undo initial "prtlevel-01: определяет количество уровней в шкале".

  do
  on error undo, return error return-value
  :

    define buffer buf_gds-prt for ub.gds-prt .

    find first buf_gds-prt no-lock
      where buf_gds-prt.node-code = p-root-node
      use-index level
      no-error.
    if not available buf_gds-prt
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найдена шкала" skip
        "p-root-node" p-root-node skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if buf_gds-prt.root <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Переданный признак не является корнем шкалы." skip
        "p-root-node" p-root-node skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    assign
      p-prt-level = 1
    .

    define variable terminal-n-c like ub.gds-prt.node-code no-undo .

    assign
      terminal-n-c = p-root-node
    .

    do while true:
      find first buf_gds-prt no-lock
        where buf_gds-prt.upper-code = terminal-n-c
        use-index level
        no-error.
      if not available buf_gds-prt
      then do:
        return . /* --->>>--- */
      end.
      assign
        p-prt-level  = p-prt-level + 1
        terminal-n-c = buf_gds-prt.node-code
      .
    end.
  end.

end procedure. /* prtlevel */


procedure termnode :

/* Поиск первого терминального узла для указанного узла */

  define input parameter  p-node-code  like ub.gds-prt.node-code no-undo .
  define output parameter terminal-n-c like ub.gds-prt.node-code no-undo .

  define variable vss-description as character no-undo initial "termnode-01: определение первого терминального признака для указанного признака".

  define buffer terminal_gds-prt for ub.gds-prt .

  assign
    terminal-n-c = p-node-code
  .
  do while true:
    find first terminal_gds-prt no-lock
      where terminal_gds-prt.upper-code = terminal-n-c
      use-index level
      no-error.
    if not available terminal_gds-prt
    then do:
      return . /* --->>>--- */
    end.
    assign
      terminal-n-c = terminal_gds-prt.node-code
    .
  end.


end procedure. /* termnode */


procedure cligdscr :

  /* Создание записи остатков по объекту */
  define input parameter  v-cli-type  like ub.cli-gds.cli-type  no-undo .
  define input parameter  v-cli-code  like ub.cli-gds.cli-code  no-undo .
  define input parameter  v-host-code like ub.cli-gds.host-code no-undo .
  define input parameter  v-artic     like ub.cli-gds.artic     no-undo .
  define input parameter  v-prod-type like ub.cli-gds.prod-type no-undo .
  define input parameter  v-prod-code like ub.cli-gds.prod-code no-undo .
  define parameter buffer buf_cli-gds for ub.cli-gds .

  define variable vss-description as character no-undo initial "cligdscr-01: поиск/cоздание записи остатков по объекту".

   find first buf_cli-gds no-lock
    where buf_cli-gds.cli-type  = v-cli-type
      and buf_cli-gds.cli-code  = v-cli-code
      and buf_cli-gds.host-code = v-host-code
      and buf_cli-gds.artic     = v-artic
      and buf_cli-gds.prod-type = v-prod-type
      and buf_cli-gds.prod-code = v-prod-code
    no-error.
  if not available buf_cli-gds
  then do:
    do transaction
    on error undo, return error return-value
    :
      create buf_cli-gds.
      assign
        buf_cli-gds.cli-type  = v-cli-type
        buf_cli-gds.cli-code  = v-cli-code
        buf_cli-gds.host-code = v-host-code
        buf_cli-gds.artic     = v-artic
        buf_cli-gds.prod-type = v-prod-type
        buf_cli-gds.prod-code = v-prod-code
      .

      assign
        buf_cli-gds.in-rubl   = 0
        buf_cli-gds.in-base   = 0
        buf_cli-gds.in-qnty   = 0
        buf_cli-gds.out-qnty  = 0
        buf_cli-gds.ret-qnty  = 0
      .
         release buf_cli-gds.
    end.

    find first buf_cli-gds no-lock
    where buf_cli-gds.cli-type  = v-cli-type
      and buf_cli-gds.cli-code  = v-cli-code
      and buf_cli-gds.host-code = v-host-code
      and buf_cli-gds.artic     = v-artic
      and buf_cli-gds.prod-type = v-prod-type
      and buf_cli-gds.prod-code = v-prod-code
    .

  end.

end procedure. /* cligdscr */


procedure unitqnty :
  /*

  Контроль допустимых количеств для данной единицы измерения (товара)

  Для серийного и штучного товара количество должно быть целым

  Параметры:

  Необходимо задать контролируемое количество p-qnty
  И либо единицу измерения p-unit-name
  либо артикул товара, которые необходимо контролировать.

  Если задан только артикул товара, то будет контролироваться базовая единица
  измерения товара.

  Необязательный параметр p-unit-description определяет
  имя единицы измерения.
  Например можно задать его как
    p-unit-description = "Единица измерения поставщика"
    или
    p-unit-description = "Базовая единица измерения"

  */

  define input parameter  p-unit-name        like ub.units.unit-name no-undo .
  define input parameter  p-artic            like ub.goods.artic     no-undo .
  define input parameter  p-prod-type        like ub.goods.prod-type no-undo .
  define input parameter  p-prod-code        like ub.goods.prod-code no-undo .
  define input parameter  p-unit-description as character            no-undo .
  define input parameter  p-qnty             as decimal              no-undo .

  define variable vss-description as character no-undo initial "unitqnty-01: Контроль допустимых количеств для данной единицы измерения (товара)".

  define buffer buf_units for ub.units .
  define buffer buf_goods for ub.goods .

  define variable v-artic as character no-undo .

  if p-unit-description = ''
  or p-unit-description = ?
  then do:
    assign
      p-unit-description = "Единица измерения"
    .
  end.

  if  p-unit-name <> ''
  and p-unit-name <> ?
  then do:
    find first buf_units no-lock
      where buf_units.unit-name = p-unit-name
      no-error .
    if not available buf_units
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена единица измерения" skip
        "p-unit-name"   p-unit-name skip
        "p-artic"       p-artic  skip
        "p-prod-type"   p-prod-type skip
        "p-proc-code"   p-prod-code skip
        "p-qnty"        p-qnty skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
  else do:
    find first buf_goods no-lock
      where buf_goods.artic     = p-artic
        and buf_goods.prod-type = p-prod-type
        and buf_goods.prod-code = p-prod-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "p-unit-name"   p-unit-name skip
        "p-artic"       p-artic  skip
        "p-prod-type"   p-prod-type skip
        "p-proc-code"   p-prod-code skip
        "p-qnty"        p-qnty skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    find first buf_units no-lock
      where buf_units.unit-name = buf_goods.unit-base
      no-error .
    if not available buf_units
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена единица измерения" skip
        "p-unit-name"   p-unit-name skip
        "p-artic"       p-artic  skip
        "p-prod-type"   p-prod-type skip
        "p-proc-code"   p-prod-code skip
        "p-qnty"        p-qnty skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    assign
      v-artic = "Артикул " + string(p-artic) + " " + string(p-prod-type)
              + " " + string(p-prod-code)
      p-unit-description = "Базовая единица измерения"
    .
  end.


  if lookup({&pieces}, buf_units.type) > 0
  or lookup({&serial}, buf_units.type) > 0
  then do:
    if p-qnty <> truncate(p-qnty, 0)
    then do:
      message
        "Для штучного и серийного товаров резервируемое количество должно быть целым" skip
        v-artic skip
        p-unit-description buf_units.unit-name skip
        "Запрошено количество " p-qnty skip
        view-as alert-box .
      undo, return error return-value .
    end.
  end.

end procedure. /* unitqnty */



/* функция преобразования строки, имеющей неопределенное значение в строку,
   состоящую из вопросительного знака
 */
function not-null-string returns character
  (input p-str as character )
:
  if p-str = ?
  then do:
    return '?' .
  end.
  return p-str .
end.


procedure usrnick :
define input parameter p-user-id as character        no-undo.
define output parameter p-nick   as character        no-undo.

   define buffer buf_user-account      for ub.user-account .
do
for buf_user-account
on error undo, return error
:
   find first buf_user-account no-lock
        where buf_user-account.user-id = p-user-id
   no-error.
   if available buf_user-account
   then do:
       assign
           p-nick = buf_user-account.nik
       .
   end.
   else do:
       assign
           p-nick = p-user-id
       .
   end.
end. /* do on error */
end procedure. /* usrnick */


procedure chkextdt :

  /* проверяет соответствие расширенного типа документа и других полей */

  define parameter buffer buf_trn-doc for ub.trn-doc .

  define variable vss-description as character no-undo initial "chkextdt-01: проверка соответствия типа и расширенного типа документа".

  do
  on error undo, return error return-value
  :
    case buf_trn-doc.ext-doc-type :
      when {&TDEDT_Pri_Vnesh}
      then do:
        if  buf_trn-doc.doc-type    = {&income}
        and buf_trn-doc.internal    = false
        and buf_trn-doc.discnt-type = ""
        and buf_trn-doc.ret-supp    = false
        then do:
          return . /* --->>>--- */
        end.
      end.
      when {&TDEDT_Ras_Vnesh}
      then do:
        if  buf_trn-doc.doc-type    = {&expense}
        and buf_trn-doc.internal    = false
        and lookup(buf_trn-doc.discnt-type, {&d-type-list}) > 0
        and buf_trn-doc.ret-supp    = false
        then do:
          return . /* --->>>--- */
        end.
      end.
      when {&TDEDT_Ras_Vnesh_VP}
      then do:
        if  buf_trn-doc.doc-type    = {&expense}
        and buf_trn-doc.internal    = false
        and lookup(buf_trn-doc.discnt-type, {&d-type-list}) > 0
        and buf_trn-doc.ret-supp    = true
        then do:
          return . /* --->>>--- */
        end.
      end.
      when {&TDEDT_Ras_Vnesh_Kass}
      then do:
        if  buf_trn-doc.doc-type    = {&expense}
        and buf_trn-doc.internal    = false
        and buf_trn-doc.discnt-type = {&cash-desk}
        and buf_trn-doc.ret-supp    = false
        then do:
          return . /* --->>>--- */
        end.
      end.
      when {&TDEDT_Vozvrat_Vnesh}
      then do:
        if  buf_trn-doc.doc-type    = {&return}
        and buf_trn-doc.internal    = false
        and lookup(buf_trn-doc.discnt-type, {&d-type-list}) > 0
        and buf_trn-doc.ret-supp    = false
        then do:
          return . /* --->>>--- */
        end.
      end.
      when {&TDEDT_Vozvrat_Vnesh_Kass}
      then do:
        if  buf_trn-doc.doc-type    = {&return}
        and buf_trn-doc.internal    = false
        and buf_trn-doc.discnt-type = {&cash-desk}
        and buf_trn-doc.ret-supp    = false
        then do:
          return . /* --->>>--- */
        end.
      end.
      when {&TDEDT_Spi_Vnesh}
      then do:
        if  buf_trn-doc.doc-type    = {&write-off}
        and buf_trn-doc.internal    = false
        and lookup(buf_trn-doc.discnt-type, {&d-type-list}) > 0
        and buf_trn-doc.ret-supp    = false
        then do:
          return . /* --->>>--- */
        end.
      end.
      when {&TDEDT_Inv}
      then do:
        if  buf_trn-doc.doc-type    = {&inventory}
        and buf_trn-doc.internal    = false
        and buf_trn-doc.discnt-type = ""
        and buf_trn-doc.ret-supp    = false
        then do:
          return . /* --->>>--- */
        end.
      end.
      when {&TDEDT_Peresort}
      then do:
        if  buf_trn-doc.doc-type    = {&inventory}
        and buf_trn-doc.internal    = false
        and buf_trn-doc.discnt-type = ""
        and buf_trn-doc.ret-supp    = false
        then do:
          return . /* --->>>--- */
        end.
      end.
      when {&TDEDT_Pri_Perem}
      then do:
        if  buf_trn-doc.doc-type    = {&income}
        and buf_trn-doc.internal    = true
        and buf_trn-doc.discnt-type = {&percent}
        and buf_trn-doc.ret-supp    = false
        then do:
          return . /* --->>>--- */
        end.
      end.
      when {&TDEDT_Ras_Perem}
      then do:
        if  buf_trn-doc.doc-type    = {&expense}
        and buf_trn-doc.internal    = true
        and buf_trn-doc.discnt-type = {&percent}
        and buf_trn-doc.ret-supp    = false
        then do:
          return . /* --->>>--- */
        end.
      end.
      when {&TDEDT_Pri_Object}
      then do:
        if  buf_trn-doc.doc-type    = {&income}
        and buf_trn-doc.internal    = true
        and buf_trn-doc.discnt-type = {&percent}
        and buf_trn-doc.ret-supp    = false
        then do:
          return . /* --->>>--- */
        end.
      end.
      when {&TDEDT_Ras_Object}
      then do:
        if  buf_trn-doc.doc-type    = {&expense}
        and buf_trn-doc.internal    = true
        and buf_trn-doc.discnt-type = {&percent}
        and buf_trn-doc.ret-supp    = false
        then do:
          return . /* --->>>--- */
        end.
      end.
      when {&TDEDT_Vozvrat_Perem}
      then do:
        if  buf_trn-doc.doc-type    = {&return}
        and buf_trn-doc.internal    = true
        and buf_trn-doc.discnt-type = {&percent}
        and buf_trn-doc.ret-supp    = false
        then do:
          return . /* --->>>--- */
        end.
      end.
      when {&TDEDT_Ras_Prvo}
      then do:
        if  buf_trn-doc.doc-type    = {&expense}
        and buf_trn-doc.internal    = true
        and buf_trn-doc.discnt-type = {&manufactured}
        and buf_trn-doc.ret-supp    = false
        then do:
          return . /* --->>>--- */
        end.
      end.
      when {&TDEDT_Spi_Prvo}
      then do:
        if  buf_trn-doc.doc-type    = {&write-off}
        and buf_trn-doc.internal    = true
        and buf_trn-doc.discnt-type = {&manufactured}
        and buf_trn-doc.ret-supp    = false
        then do:
          return . /* --->>>--- */
        end.
      end.
      when {&TDEDT_Pri_Prvo}
      then do:
        if  buf_trn-doc.doc-type    = {&income}
        and buf_trn-doc.internal    = true
        and buf_trn-doc.discnt-type = {&manufactured}
        and buf_trn-doc.ret-supp    = false
        then do:
          return . /* --->>>--- */
        end.
      end.
      when {&TDEDT_Overturn}
      then do:
        /* недопустимый тип для складских документов */
      end.
      when {&TDEDT_Corr_Acc_Price}
      then do:
        if  buf_trn-doc.doc-type    = {&inventory}
        and buf_trn-doc.internal    = false
        and buf_trn-doc.discnt-type = ""
        and buf_trn-doc.ret-supp    = false
        then do:
          return . /* --->>>--- */
        end.
      end.
      when {&TDEDT_Corr_Minus_Parts}
      then do:
        if  buf_trn-doc.doc-type    = {&inventory}
        and buf_trn-doc.internal    = false
        and buf_trn-doc.discnt-type = ""
        and buf_trn-doc.ret-supp    = false
        then do:
          return . /* --->>>--- */
        end.
      end.
      when {&TDEDT_Chg_Purch_Code}
      then do:
        if  buf_trn-doc.doc-type    = {&inventory}
        and buf_trn-doc.internal    = false
        and buf_trn-doc.discnt-type = ""
        and buf_trn-doc.ret-supp    = false
        then do:
          return . /* --->>>--- */
        end.
      end.
    end.

    return error substitute(vss-description
      + "Противоречивое состояние полей типа документа." + {&new-line}
      + "doc-code &1" + {&new-line}
      + "doc-type &2" + {&new-line}
      + "internal &3" + {&new-line}
      + "discnt-type &4" + {&new-line}
      + "ret-supp &5" + {&new-line}
      + "status_ &6" + {&new-line}
      + "obj-type &7" + {&new-line}
      + "obj-code &8" + {&new-line}
      + "ext-doc-type &9" + {&new-line}
      , buf_trn-doc.doc-code
      , buf_trn-doc.doc-type
      , buf_trn-doc.internal
      , buf_trn-doc.discnt-type
      , buf_trn-doc.ret-supp
      , buf_trn-doc.status_
      , buf_trn-doc.obj-type
      , buf_trn-doc.obj-code
      , buf_trn-doc.ext-doc-type
      ) .
  end.

end procedure. /* chkextdt */


procedure trnextdt :

  define input  parameter p-ext-doc-type as character no-undo .
  define output parameter p-doc-type     as character no-undo .

  /* возвращает тип документа в соответствии с его расширенным типом */

  define variable vss-description as character no-undo initial "trnextdt-01: возвращает тип документа в соответствии с его расширенным типом".

  do
  on error undo, return error return-value
  :
    case p-ext-doc-type
    :
      when {&TDEDT_Pri_Vnesh}
      then do:
        assign
          p-doc-type = {&income}
        .
      end.
      when {&TDEDT_Ras_Vnesh}
      then do:
        assign
          p-doc-type = {&expense}
        .
      end.
      when {&TDEDT_Ras_Vnesh_VP}
      then do:
        assign
          p-doc-type = {&expense}
        .
      end.
      when {&TDEDT_Ras_Vnesh_Kass}
      then do:
        assign
          p-doc-type = {&expense}
        .
      end.
      when {&TDEDT_Vozvrat_Vnesh}
      then do:
        assign
          p-doc-type = {&return}
        .
      end.
      when {&TDEDT_Vozvrat_Vnesh_Kass}
      then do:
        assign
          p-doc-type = {&return}
        .
      end.
      when {&TDEDT_Spi_Vnesh}
      then do:
        assign
          p-doc-type = {&write-off}
        .
      end.
      when {&TDEDT_Inv}
      then do:
        assign
          p-doc-type = {&inventory}
        .
      end.
      when {&TDEDT_Peresort}
      then do:
        assign
          p-doc-type = {&inventory}
        .
      end.

      when {&TDEDT_Pri_Perem}
      then do:
        assign
          p-doc-type = {&income}
        .
      end.
      when {&TDEDT_Ras_Perem}
      then do:
        assign
          p-doc-type = {&expense}
        .
      end.
      when {&TDEDT_Pri_Object}
      then do:
        assign
          p-doc-type = {&income}
        .
      end.
      when {&TDEDT_Ras_Object}
      then do:
        assign
          p-doc-type = {&expense}
        .
      end.
      when {&TDEDT_Vozvrat_Perem}
      then do:
        assign
          p-doc-type = {&return}
        .
      end.
      when {&TDEDT_Ras_Prvo}
      then do:
        assign
          p-doc-type = {&expense}
        .
      end.
      when {&TDEDT_Spi_Prvo}
      then do:
        assign
          p-doc-type = {&write-off}
        .
      end.
      when {&TDEDT_Pri_Prvo}
      then do:
        assign
          p-doc-type = {&income}
        .
      end.
      when {&TDEDT_Corr_Acc_Price}
      then do:
        assign
          p-doc-type = {&inventory}
        .
      end.
      when {&TDEDT_Corr_Minus_Parts}
      then do:
        assign
          p-doc-type = {&inventory}
        .
      end.
      when {&TDEDT_Chg_Purch_Code}
      then do:
        assign
          p-doc-type = {&inventory}
        .
      end.
      otherwise do:
        return error substitute(vss-description
          + "Неизвестный расширенный тип документа &1" + {&new-line}
          , p-ext-doc-type
          ) .
      end.
    end.
  end.

end procedure. /* chkextdt */


procedure gdsdtlcr :

  /* cоздается корневой gds-dtl в накладной на основании строки накладной */

  define input parameter  v-root-node  like ub.gds-dtl.prt-code no-undo .
  define parameter buffer buf_doc-line for ub.doc-line .
  define parameter buffer buf_gds-dtl  for ub.gds-dtl .

  define variable vss-description as character no-undo initial "gdsdtlcr-02: Создается корневой gds-dtl в накладной на основании строки накладной".

  define buffer buf_trn-doc for ub.trn-doc .

  do
  on error undo, return error return-value
  :
    if v-root-node = ?
    then do:
      /* определяем корневой узел шкалы */
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
          "Ошибка при определении корневого признака шкалы" skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.

    find first buf_gds-dtl
      where buf_gds-dtl.doc-code  = buf_doc-line.doc-code
        and buf_gds-dtl.artic     = buf_doc-line.artic
        and buf_gds-dtl.prod-type = buf_doc-line.prod-type
        and buf_gds-dtl.prod-code = buf_doc-line.prod-code
        and buf_gds-dtl.prt-code  = v-root-node
      no-error .
    if not available buf_gds-dtl
    then do:
      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = buf_doc-line.doc-code
        no-error .
      if not available buf_trn-doc
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найден документ" skip
          "Документ" buf_doc-line.doc-code skip
          error-status :get-message(1) skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      define variable l-cr-root-gds-dtl as logical no-undo .

      { gbl/gdsobjat.i
        buf_doc-line.obj-type
        buf_doc-line.obj-code
        buf_doc-line.artic
        buf_doc-line.prod-type
        buf_doc-line.prod-code
        "'cr-root-gds-dtl=request':U"
        l-cr-root-gds-dtl
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении признака товара на объекте" skip
          "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          "Запрашиваемый атрибут" "cash-parts=request":u skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      if l-cr-root-gds-dtl = false
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Недопустимо создавать корневой признак в накладной для товара" skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      create buf_gds-dtl.
      assign
        buf_gds-dtl.doc-code  = buf_doc-line.doc-code
        buf_gds-dtl.artic     = buf_doc-line.artic
        buf_gds-dtl.prod-code = buf_doc-line.prod-code
        buf_gds-dtl.prod-type = buf_doc-line.prod-type
        buf_gds-dtl.prt-code  = v-root-node
        buf_gds-dtl.obj-type  = buf_doc-line.obj-type
        buf_gds-dtl.obj-code  = buf_doc-line.obj-code
      .

      if buf_trn-doc.ext-doc-type = {&TDEDT_Inv}              or
         buf_trn-doc.ext-doc-type = {&TDEDT_Peresort}         or
         buf_trn-doc.ext-doc-type = {&TDEDT_Corr_Acc_Price}   or
         buf_trn-doc.ext-doc-type = {&TDEDT_Corr_Minus_Parts} or
         buf_trn-doc.ext-doc-type = {&TDEDT_Chg_Purch_Code}   then do:
        assign
          buf_gds-dtl.doc-qnty  = buf_doc-line.fact-qnty
          buf_gds-dtl.fact-qnty = buf_doc-line.doc-qnty
        .
      end.
      else do:
        assign
          buf_gds-dtl.doc-qnty  = buf_doc-line.doc-qnty
          buf_gds-dtl.fact-qnty = buf_doc-line.fact-qnty
        .
      end.
    end.
  end.


end procedure. /* gdsdtlcr */



procedure trnat :

  /*
  Задает/получает различные признаки документа на объекте

  значения p-action
  список значений действий разделенных запятыми

  can-edit-inv-on=request - возвращает true или false
    имеет ли право пользователь редактировать документ при наличии
    и переходить между различными статусами документа при наличии инвентаризации
      в статусе status_ = {&permitted}, flag_ = true (разр +)

  */

  define input parameter  p-trn-doc-doc-type     like ub.trn-doc.doc-type     no-undo .
  define input parameter  p-trn-doc-internal     like ub.trn-doc.internal     no-undo .
  define input parameter  p-trn-doc-discnt-type  like ub.trn-doc.discnt-type  no-undo .
  define input parameter  p-trn-doc-status_      like ub.trn-doc.status_      no-undo .
  define input parameter  p-trn-doc-flag         like ub.trn-doc.flag_        no-undo .
  define input parameter  p-trn-doc-ext-doc-type like ub.trn-doc.ext-doc-type no-undo.
  define input  parameter p-action               as   character               no-undo .
  define output parameter p-return-attribute     as   character               no-undo .

  define variable vss-description as character no-undo initial "trnat-01: Задает/получает различные признаки товара на объекте".

  define variable ind      as integer no-undo .
  define variable v-action as character no-undo .

  define variable v-num-entries-p-action as integer no-undo .

  do
  on error undo, return error return-value
  :

    assign
      v-num-entries-p-action = num-entries(p-action)
    .

    do ind = 1 to v-num-entries-p-action
    :
      assign
        v-action = entry(ind, p-action)
      .

      case v-action :
        when "can-change-status-inv-on=request"
        then do:
          if  p-trn-doc-doc-type = {&inventory}
          then do:
            assign
              p-return-attribute = "true":u
            .
            next . /* --->>>--- */
          end.

          if  p-trn-doc-doc-type = {&income}
          and p-trn-doc-internal = false
          and p-trn-doc-status_  = {&wayb}
          /* and ( p-trn-doc-flag     = true
                  or p-trn-doc-flag     = false
                  )
          */
          then do:
            assign
              p-return-attribute = "true":u
            .
            next . /* --->>>--- */
          end.

          assign
            p-return-attribute = "false":u
          .

        end.


        when "can-edit-inv-on=request":u
        then do:
          if  p-trn-doc-doc-type     = {&inventory}
          and p-trn-doc-ext-doc-type = {&TDEDT_Inv}
          and p-trn-doc-status_      = {&permitted}
          and p-trn-doc-flag         = true
          then do:
            assign
              p-return-attribute = "true":u
            .
            next . /* --->>>--- */
          end.
          if  p-trn-doc-doc-type     = {&inventory}
          and p-trn-doc-ext-doc-type = {&TDEDT_Peresort}
          and p-trn-doc-status_      = {&wayb}
          and p-trn-doc-flag         = false
          then do:
            assign
              p-return-attribute = "true":u
            .
            next . /* --->>>--- */
          end.
          if  p-trn-doc-doc-type     = {&inventory}
          and p-trn-doc-ext-doc-type = {&TDEDT_Corr_Acc_Price}
          and p-trn-doc-status_      = {&wayb}
          and p-trn-doc-flag         = false
          then do:
            assign
              p-return-attribute = "true":u
            .
            next . /* --->>>--- */
          end.
          if  p-trn-doc-doc-type     = {&inventory}
          and p-trn-doc-ext-doc-type = {&TDEDT_Corr_Minus_Parts}
          and p-trn-doc-status_      = {&wayb}
          and p-trn-doc-flag         = false
          then do:
            assign
              p-return-attribute = "true":u
            .
            next . /* --->>>--- */
          end.
          if  p-trn-doc-doc-type = {&income}
          and p-trn-doc-internal = false
          and p-trn-doc-status_  = {&wayb}
          /* and ( p-trn-doc-flag     = true
                  or p-trn-doc-flag     = false
                  )
          */
          then do:
            assign
              p-return-attribute = "true":u
            .
            next . /* --->>>--- */
          end.

          assign
            p-return-attribute = "false":u
          .
        end.

        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестное значение параметра v-action " skip
            "v-action" v-action skip
            "p-action" p-action skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
    end.
  end.

end procedure. /* trnat */


procedure qntycalc :

  /* Пересчет количеств из одной единицы измерения в другую */

  define input parameter  p-calc-method   as character                   no-undo .
  define input parameter  p-cli-base-rate like ub.doc-line.cli-base-rate no-undo .
  define input parameter  p-cli-qnty      like ub.doc-line.cli-qnty      no-undo .
  define input parameter  p-doc-qnty      like ub.doc-line.doc-qnty      no-undo .
  define output parameter p-new-cli-qnty  like ub.doc-line.cli-qnty      no-undo .
  define output parameter p-new-doc-qnty  like ub.doc-line.doc-qnty      no-undo .

  define variable vss-description as character no-undo initial "qntycalc-01: Пересчет количеств из одной единицы измерения в другую".

  do
  on error undo, return error return-value
  :
    if p-cli-base-rate <= 0
    or p-cli-base-rate = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Невозможно пересчитать количество при коэффициенте пересчета " skip
        string(p-cli-base-rate) {&new-line}
        view-as alert-box error .
      undo, return error
        "Невозможно пересчитать количество при коэффициенте пересчета "
        + string(p-cli-base-rate) + {&new-line}
        .
    end.

    define variable v-round-parameter as integer no-undo .
    if p-cli-base-rate = 1
    then do:
      assign
        v-round-parameter = 10
      .
    end.
    else do:
      assign
        v-round-parameter = 3
      .
    end.

    case p-calc-method :
      when "cli-qnty"
      then do:
        if abs(p-doc-qnty - round(p-cli-qnty * p-cli-base-rate, v-round-parameter)) < 0.0011
        then do:
          assign
            p-new-cli-qnty = p-cli-qnty
            p-new-doc-qnty = p-doc-qnty
          .
        end.
        else do:
          assign
            p-new-cli-qnty = round(p-doc-qnty / p-cli-base-rate, v-round-parameter)
          .
          assign
            p-new-doc-qnty = p-doc-qnty
          .
          if abs(p-new-doc-qnty - p-new-cli-qnty * p-cli-base-rate) > 0.001
          then do:
            undo, return error
              "Невозможно пересчитать количество по документу " + string(p-doc-qnty) + {&new-line}
              + "в количество по ТТН" + {&new-line}
              + "при коэффициенте пересчета " + string(p-cli-base-rate, "->>>,>>9.9999999999") + {&new-line}
              + "p-new-doc-qnty " + string(p-new-doc-qnty) + {&new-line}
              + "p-new-cli-qnty " + string(p-new-cli-qnty) + {&new-line}
              + "p-new-cli-qnty * p-cli-base-rate " + string(p-new-cli-qnty * p-cli-base-rate) + {&new-line}
              .
          end.
        end.
      end.

      when "doc-qnty"
      then do:
        assign
          p-new-cli-qnty = p-cli-qnty
          p-new-doc-qnty = round(p-cli-qnty * p-cli-base-rate, v-round-parameter)
        .
      end.

      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестное значение парметра" skip
          "p-calc-method" p-calc-method skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.

end procedure. /* qntycalc */


procedure needprts :

  define input  parameter p-ext-doc-type         like ub.trn-doc.ext-doc-type         no-undo .
  define input  parameter p-cli-type             like ub.trn-doc.cli-type             no-undo .
  define input  parameter p-cli-code             like ub.trn-doc.cli-code             no-undo .
  define input  parameter p-hold-doc-code-child  like ub.trn-doc.hold-doc-code-child  no-undo .
  define input  parameter p-hold-doc-code-parent like ub.trn-doc.hold-doc-code-parent no-undo .
  define input  parameter p-status               like ub.trn-doc.status_              no-undo .
  define output parameter p-result               as   character                       no-undo .

  define variable vss-description as character no-undo initial "needprts-01: Определяет способ резервирования партий за документом возврата поставщику".

  /*

  Возвращаемое значение
  all     - любые партии поставщика
  hold    - партии, пришедшие по межфирменным прихода
  no-hold - партии, пришедшие по стандартным внешним приходам от своей фирмы

  */

  define buffer bf_sysconf for ub.sysconf.
  define variable varhold          as character no-undo.
  define variable varhold-type     as character no-undo.


  do for bf_sysconf
  on error undo, return error substitute ("&1 &2", return-value, error-status:get-message(1))
  :
    if p-ext-doc-type <> {&TDEDT_Ras_Vnesh_VP}
    then do:
      assign
        p-result = 'all':u
      .
      return .
    end.

    { gbl/conf-rd.i
      "'holding':U"
      "'':U"
      "'':U"
      0
      "'':U"
      "'':U"
      "'':U"
      true
      varhold
      varhold-type
    }
    if lookup(varhold, 'true,yes':u) = 0
    then do:
      assign
        p-result = 'all':u
      .
    end.
    else do:
      if p-cli-type <> {&cmp}
      then do:
        assign
          p-result = 'all':u
        .
      end.
      else do:
        find first bf_sysconf no-lock
          where bf_sysconf.host-code = p-cli-code
          no-error.
        if not available bf_sysconf
        then do:
          assign
            p-result = 'all':u
          .
        end.
        else do:
          if  (p-hold-doc-code-child  = '':u
               or
               p-hold-doc-code-child  = 'no-hold':u
              )
          and (p-hold-doc-code-parent = '':u
               or
               p-hold-doc-code-parent = 'no-hold':u
              )
          then do:
            assign
              p-result = 'no-hold':u
            .
          end.
          else do:
            assign
              p-result = 'hold':u
            .
          end.
        end.
      end.
    end.
  end.
end procedure.



procedure part-prc :

  /* проверяет возможность резервирования партии в зависимости от определенного типа */
  /* документа и типа партии */
  define parameter buffer buf_parts               for ub.parts .
  define parameter buffer buf_trn-doc             for ub.trn-doc .
  define input  parameter p-reserv-single-part    as logical   no-undo .
  define input  parameter p-single-part-in-code   as character no-undo .
  define input  parameter p-single-part-part-code as character no-undo .
  define input  parameter p-pl-code               as decimal   no-undo .
  define input  parameter p-goods-twounit         as logical   no-undo .
  define input  parameter p-purch-code-list       as character no-undo .
  define input  parameter p-rsrv-qnty             as decimal   no-undo .
  define input  parameter p-check-negmanuf        as logical   no-undo .
  define output parameter p-reason                as character no-undo .
  define output parameter p-process-part          as logical   no-undo .


  define variable vss-description as character no-undo initial "Проверка возможности резервирования партии".
  define variable v-value-character as character no-undo .
  define variable v-value-date      as date      no-undo .
  define variable v-value-decimal   as decimal   no-undo .
  define variable v-value-integer   as integer   no-undo .
  define variable v-avail-on-date   as logical   no-undo .
  define variable v-avail-on-date-type as character no-undo .
  define variable v-tth             as handle no-undo .



  do
  on error undo, return error return-value
  :

    if not available buf_parts
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не задана запись партий"
        view-as alert-box error .
      undo, return error return-value .
    end.

    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не задана запись документа"
        view-as alert-box error .
      undo, return error return-value .
    end.

    assign
      p-process-part = true
    .
    /* Для  расходов будем проверять дату прихода +++ */
    define variable v-date-compare as date      no-undo .
    if buf_trn-doc.doc-type = {&expense} and buf_parts.out-code = {&free-code} and
       buf_trn-doc.ext-doc-type <> {&TDEDT_Ras_Vnesh_VP}  then do:
        if  buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}  then do:
             v-date-compare =  buf_trn-doc.doc-date .
           end.
           else do:
             v-date-compare =  buf_trn-doc.fact-date .
           end.
       if v-date-compare < buf_parts.fact-date then do:

  delete object v-tth no-error.
  run adm/shattri.p (
      input "get":U
      ,input buf_trn-doc.obj-type
      ,input buf_trn-doc.obj-code
      ,input {&attr-nakl_par}
      ,input  "avail-on-date"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-avail-on-date
      ,output v-avail-on-date-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
      if error-status :error  then v-avail-on-date = false .

      delete object v-tth no-error.
      if v-avail-on-date = true then do:
            message  substitute("По товару &3 (&4&5)  дата прихода партии &2 позже даты расхода (док.дата &1 и факт.дата &6 ) !!!" ,buf_trn-doc.doc-date , buf_parts.fact-date , buf_parts.artic, buf_parts.prod-type , buf_parts.prod-code ,buf_trn-doc.fact-date) view-as alert-box error .
            p-reason        = substitute("По товару &3 (&4&5)  дата прихода партии &2 позже даты расхода (док.дата &1 и факт.дата &6 ) !!!" ,buf_trn-doc.doc-date , buf_parts.fact-date , buf_parts.artic, buf_parts.prod-type , buf_parts.prod-code ,buf_trn-doc.fact-date) .
            p-process-part  = false.
            return .
       end.
    end.
    end.


    define variable v-rsrv-type as character no-undo .

    run needprts in this-procedure
      (input  buf_trn-doc.ext-doc-type         /* p-ext-doc-type         */
      ,input  buf_trn-doc.cli-type             /* p-cli-type             */
      ,input  buf_trn-doc.cli-code             /* p-cli-code             */
      ,input  buf_trn-doc.hold-doc-code-child  /* p-hold-doc-code-child  */
      ,input  buf_trn-doc.hold-doc-code-parent /* p-hold-doc-code-parent */
      ,input  buf_trn-doc.status_              /* p-status               */
      ,output v-rsrv-type                      /* p-result               */
      ) .
    if v-rsrv-type = 'hold':u
    then do:
      define buffer buf_income_trn-doc for ub.trn-doc .
      find first buf_income_trn-doc no-lock
        where buf_income_trn-doc.doc-code = buf_parts.in-code
        no-error .
      if not available buf_income_trn-doc
      then do:
        assign
          p-reason        = vss-description + ":" + {&new-line}
                          + substitute("Не найден документ прихода &1",buf_parts.in-code) + {&new-line}
                          + "Невозможно зарезервировать партию " +  buf_parts.in-code + " " + buf_parts.part-code
          p-process-part  = false
        .
        return .
      end.

      if buf_income_trn-doc.cli-type <> buf_trn-doc.cli-type
      or buf_income_trn-doc.cli-code <> buf_trn-doc.cli-code
      then do:
        assign
          p-reason        = vss-description + ":" + {&new-line}
                          + substitute("Документ прихода &1",buf_income_trn-doc.doc-code) + {&new-line}
                          + substitute("Фирма на которую производится межфирменное перемещение &1 &2",buf_trn-doc.cli-type,buf_trn-doc.cli-code) + {&new-line}
                          + substitute("Фирма с которой было межфирменное перемещение &1 &2",buf_income_trn-doc.cli-type,buf_income_trn-doc.cli-code) + {&new-line}
                          + "Фирмы не совпадают" + {&new-line}
                          + "Невозможно зарезервировать партию " +  buf_parts.in-code + " " + buf_parts.part-code
          p-process-part  = false
        .
        return .
      end.

      if buf_income_trn-doc.hold-obj-type <> buf_trn-doc.hold-obj-type
      or buf_income_trn-doc.hold-obj-code <> buf_trn-doc.hold-obj-code
      then do:
        assign
          p-reason        = vss-description + ":" + {&new-line}
                          + substitute("Документ прихода &1",buf_income_trn-doc.doc-code) + {&new-line}
                          + substitute("Объект на который производится межфирменное перемещение &1 &2",buf_trn-doc.hold-obj-type,buf_trn-doc.hold-obj-code) + {&new-line}
                          + substitute("Объект с которого было межфирменное перемещение &1 &2",buf_income_trn-doc.hold-obj-type,buf_income_trn-doc.hold-obj-code) + {&new-line}
                          + "Объекты не совпадают" + {&new-line}
                          + "Невозможно зарезервировать партию " +  buf_parts.in-code + " " + buf_parts.part-code
          p-process-part  = false
        .
        return .
      end.

      if buf_trn-doc.hold-doc-code-parent = ""
      then do:
        assign
          p-reason        = vss-description + ":" + {&new-line}
                          + substitute("Документ прихода &1",buf_income_trn-doc.doc-code) + {&new-line}
                          + "Документ прихода не является документом межфирменного прихода" + {&new-line}
                          + "Невозможно зарезервировать партию " +  buf_parts.in-code + " " + buf_parts.part-code
          p-process-part  = false
        .
        return .
      end.
    end.

    if p-goods-twounit = true
    then do:
      /* определяем количество по партии, которое находится в свободной зоне */
      /* или зарезервировано за документов с учетом знака */
      define variable v-parts-qnty like ub.parts.qnty no-undo .
      case buf_parts.out-code :
        when {&free-code}
        then do:
          assign
            v-parts-qnty = buf_parts.qnty
          .
        end.
        when {&output-code}
        then do:
          assign
            v-parts-qnty = - buf_parts.qnty
          .
        end.
        when buf_trn-doc.doc-code
        then do:
          if lookup(buf_trn-doc.doc-type, {&expense_write-off}) > 0
          then do:
            assign
              v-parts-qnty = - buf_parts.qnty
            .
          end.
          else do:
            assign
              v-parts-qnty = buf_parts.qnty
            .
          end.
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Попытка изменить партию, не принадлежащую документу" skip
            "Партия зарезервирована за документом" buf_parts.out-code skip
            "Текущий документ" buf_trn-doc.doc-code skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end case .

      if buf_parts.out-code <> buf_parts.in-code
      then do:
        /* для порожденных партий количество можно менять как угодно */
        /* для остальных партий */
        /* сравниваем указанное количество с запрошенным количеством резервирования */
        if v-parts-qnty <> - p-rsrv-qnty
        then do:
          assign
            p-reason        = vss-description + ":" + {&new-line}
                            + "Для товара с двумя ед.изм. партию можно зарезервировать только целиком" + {&new-line}
                            + "Количество в партии" + " " + string(v-parts-qnty) + {&new-line}
                            + "Было запрошено количество" + " " + string(p-rsrv-qnty) + {&new-line}
                            + "Невозможно зарезервировать партию " +  buf_parts.in-code + " " + buf_parts.part-code
            p-process-part  = false
          .
          return . /* --->>>--- */
        end.
      end.
      if buf_parts.cli-qnty <> 1
      then do:
        assign
          p-reason       = vss-description + ":" + {&new-line}
                        + "Для товара с двумя ед.изм. количество по клиенту должно быть 1" + {&new-line}
                        + "Невозможно зарезервировать партию " +  buf_parts.in-code + " " + buf_parts.part-code
          p-process-part = false
        .
        return . /* --->>>--- */
      end.
    end.

    if  p-purch-code-list <> ?
    and p-purch-code-list <> '':u
    then do:
      if lookup(string(buf_parts.purch-code), p-purch-code-list) = 0
      then do:
        define variable v-ind              as integer   no-undo .
        define variable v-purch-code-list  as character no-undo .
        define variable v-parts-purch-code as character no-undo .

        assign
          v-purch-code-list = ""
        .

        do v-ind = 1 to num-entries(p-purch-code-list)
        :
          &scop purchase-code entry(v-ind,p-purch-code-list)
          assign
            v-purch-code-list = v-purch-code-list
                              + (if v-purch-code-list <> '':u then ',':u else '':u )
                              + {&purchase-codes-name}
          .
        end.

        &scop purchase-code string(buf_parts.purch-code)
        assign
          v-parts-purch-code = {&purchase-codes-name}
        .

        assign
          p-reason        = vss-description + ":" + {&new-line}
                          + substitute("Задано резервирование по типам приобретения &1", v-purch-code-list) + {&new-line}
                          + substitute("Невозможно зарезервировать партию &1 &2", buf_parts.in-code, buf_parts.part-code) + {&new-line}
                          + substitute("с типом приобретения &1", v-parts-purch-code)
          p-process-part  = false
        .
        return . /* --->>>--- */
      end.
    end.

    /* задан бар-код - резервируем только партии заданного бар-кода */
    if p-reserv-single-part
    then do:
    define buffer buf_goods for ub.goods  .
    define buffer buf_parts-attr for ub.parts-attr  .
    define variable v-is-ok as logical   no-undo .
    define buffer buf_trn-doc-parts for ub.trn-doc  .
    find first buf_trn-doc-parts no-lock where
               buf_trn-doc-parts.doc-code = p-single-part-in-code no-error .
     v-is-ok =  false .

      if not available buf_trn-doc-parts then do:
          v-is-ok = true .
      end.
      else do:
        if buf_trn-doc-parts.ext-doc-type <> {&tdedt_Ras_perem} then v-is-ok = true .
      end.

      if v-is-ok = true then do:
        find first buf_goods no-lock where
                   buf_goods.artic     = buf_parts.artic and
                   buf_goods.prod-type = buf_parts.prod-type and
                   buf_goods.prod-code = buf_parts.prod-code no-error .

        find first buf_parts-attr no-lock where
                   buf_parts-attr.gds-code  = buf_goods.gds-code  and
                   buf_parts-attr.part-code = buf_parts.part-code  and
                   buf_parts-attr.in-code =   buf_parts.in-code no-error .
                    if error-status :error then DO:
                        message
                          vss-workfile vss-revision vss-description skip
                          error-status :get-message(1) skip
                          return-value skip
                          "Нет атрибута партиии "
                          view-as alert-box error
                        .
                        return error return-value .
                    end.
          if buf_parts-attr.orig-in-code   <> p-single-part-in-code
          or buf_parts-attr.orig-part-code <> p-single-part-part-code
          then do:
            assign
              p-reason       = vss-description + ":" + {&new-line}
                            + "Происходит резервирование конкретной партии"
                            + p-single-part-in-code + " " + p-single-part-part-code + {&new-line}
                            + "Невозможно зарезервировать партию " +  buf_parts.in-code + " " + buf_parts.part-code
              p-process-part = false
            .
            return . /* --->>>--- */
          end.
      end.
    end.

    if  p-pl-code <> ?
    and p-pl-code <> 0
    then do:
      if buf_parts.pl-code <> p-pl-code
      then do:
        assign
          p-reason        = vss-description + ":" + {&new-line}
                          + substitute("Происходит резервирование партий на складском месте &1", p-pl-code) + {&new-line}
                          + substitute("Невозможно зарезервировать партию &1 &2", buf_parts.in-code, buf_parts.part-code) + {&new-line}
                          + substitute("со складского места &1", buf_parts.pl-code)
          p-process-part  = false
        .
        return . /* --->>>--- */
      end.
    end.

    /* возврат поставщику - резервируем только партии указанного поставщика */
    if buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
    then do:
      if ( buf_parts.is-supp   = true
          and buf_parts.supp-type = buf_trn-doc.cli-type
          and buf_parts.supp-code = buf_trn-doc.cli-code
        )
      or ( buf_parts.is-supp   = false
        )
      then do:
      end.
      else do:
        assign
          p-reason       = vss-description + ":" + {&new-line}
                        + "Для документа расход возврат поставщику" + {&new-line}
                        + "Можно резервировать только партии, созданные документом внешнего прихода от поставщика "
                        + string (buf_trn-doc.cli-type) + " " + string(buf_trn-doc.cli-code)
                        + {&new-line}
                        + "или созданные другими типами документов"
          p-process-part = false
        .
        return . /* --->>>--- */
      end.
    end.

    /* контроль порожденных партий в документе производства */
    if p-check-negmanuf = true
    then do:
      if buf_trn-doc.ext-doc-type = {&TDEDT_Spi_Prvo}
      or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Prvo}
      then do:
        if buf_parts.in-code = buf_parts.out-code
        then do:
          define variable conf-par as character no-undo .

          { gbl/getsect.i run buf_trn-doc.obj-type buf_trn-doc.obj-code  {&attr-rezerv-obj} }
          for each thbjattr_thbj-attr :
              if thbjattr_thbj-attr.prop-code = 'negmanuf'  then conf-par  = thbjattr_thbj-attr.property-value-character.
          end.
          empty temp-table thbjattr_thbj-attr.

          if conf-par = "disable"
          then do:
            assign
              p-reason       = vss-description + ":" + {&new-line}
                              + "Для документа списание по производству запрещено порождение партий" + {&new-line}
                              + "Параметр системы negmanuf" + {&new-line}
              p-process-part = false
            .
            return . /* --->>>--- */
          end.
        end.
      end.
    end.

    if  buf_parts.supp-type = buf_trn-doc.obj-type
    and buf_parts.supp-code = buf_trn-doc.obj-code
    then do:
      /* партия, порождена на данном объекте */

      define variable v-is-hold as logical   no-undo .

      { gbl/hold-doc.i
        buf_trn-doc.doc-code
        v-is-hold
      }

      /* контроль резервирования порожденных партий для документов */
      if buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Perem}
      or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Object}
      or v-is-hold                = true
      then do:
        /* резервировать нельзя */
        /* единственное исключение - отсутсвие отрицательной */
        /* партии в расходной зоне для документа перемещения */
        define buffer negative_parts for ub.parts .

        if buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Perem}
        or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Object}
        then do:
          /* ищем отрицательную партию в противоположной зоне */
          find first negative_parts no-lock
            where negative_parts.obj-type  = buf_parts.obj-type
              and negative_parts.obj-code  = buf_parts.obj-code
              and negative_parts.artic     = buf_parts.artic
              and negative_parts.prod-type = buf_parts.prod-type
              and negative_parts.prod-code = buf_parts.prod-code
              and negative_parts.in-code   = buf_parts.in-code
              and negative_parts.out-code  = {&output-code}
              and negative_parts.part-code = buf_parts.part-code
            no-error .
          if available negative_parts
          and negative_parts.fact-qnty < 0
          then do:
            assign
              p-reason       = vss-description + ":" + {&new-line}
                             + "Это порожденная партия. Ее нельзя зарезервировать за документом внутреннего перемещения." + {&new-line}
                             + "В расходной зоне существует партия с отрицательным количеством"
              p-process-part = false
            .
            return . /* --->>>--- */
          end.
        end.
        else do:
        /*
          assign
            p-reason       = vss-description + ":" + {&new-line}
                           + "Это порожденная партия. Ее нельзя зарезервировать за документом межфирменного перемещения"
            p-process-part = false
          .
          return . /* --->>>--- */
          */
        end.
      end.
    end.

    return . /* --->>>--- */
  end.

end procedure. /* part-prc */


procedure gds-code :

  define input  parameter p-artic     like ub.goods.artic     no-undo .
  define input  parameter p-prod-type like ub.goods.prod-type no-undo .
  define input  parameter p-prod-code like ub.goods.prod-code no-undo .
  define output parameter p-gds-code  like ub.goods.gds-code  no-undo .

  define variable vss-description as character no-undo initial "gds-code-01: Поиск кода товара по артикулу и коду производителя".

  define buffer buf_goods    for ub.goods .

  do
  on error undo, return error return-value
  :

    find first buf_goods no-lock
      where buf_goods.artic     = p-artic
        and buf_goods.prod-type = p-prod-type
        and buf_goods.prod-code = p-prod-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error return-value  . /* --->>>--- */
    end.

    if buf_goods.gds-code = 0
    or buf_goods.gds-code = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "У товара не задан первичный код" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "gds-code" buf_goods.gds-code skip
        view-as alert-box error .
      undo, return error return-value . /* --->>>--- */
    end.

    assign
      p-gds-code = buf_goods.gds-code
    .
  end.

end procedure. /* gds-code */


procedure arptpc :

  define input  parameter p-gds-code  like ub.goods.gds-code  no-undo .
  define output parameter p-artic     like ub.goods.artic     no-undo .
  define output parameter p-prod-type like ub.goods.prod-type no-undo .
  define output parameter p-prod-code like ub.goods.prod-code no-undo .

  define variable vss-description as character no-undo initial "arptpc-01: Поиск артикула и кода производителя".

  define buffer buf_goods    for ub.goods .

  do
  on error undo, return error return-value
  :

    if p-gds-code = 0
    or p-gds-code = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не задан код товара" skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    find first buf_goods no-lock
      where buf_goods.gds-code = p-gds-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error return-value . /* --->>>--- */
    end.

    assign
      p-artic     = buf_goods.artic
      p-prod-type = buf_goods.prod-type
      p-prod-code = buf_goods.prod-code
    .
  end.

end procedure. /* gds-code */

procedure gds-arnm :

  define input  parameter p-artic     like ub.goods.artic     no-undo .
  define input  parameter p-prod-type like ub.goods.prod-type no-undo .
  define input  parameter p-prod-code like ub.goods.prod-code no-undo .
  define output parameter p-gds-name  like ub.goods.gds-name  no-undo .

  define variable vss-description as character no-undo initial "gds-arnm: Возвращает имя товара по артикулу".

  define buffer buf_goods for ub.goods .

  do
  on error undo, return error return-value
  :
    find first buf_goods no-lock
      where buf_goods.artic     = p-artic
        and buf_goods.prod-type = p-prod-type
        and buf_goods.prod-code = p-prod-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error return-value . /* --->>>--- */
    end.

    assign
      p-gds-name = buf_goods.gds-name
    .
  end.

end procedure. /* gds-name */


procedure gds-cdnm :

  define input  parameter p-gds-code  like ub.goods.gds-code  no-undo .
  define output parameter p-gds-name  like ub.goods.gds-name  no-undo .

  define variable vss-description as character no-undo initial "gds-cdnm: Возвращает имя товара по коду".

  define buffer buf_goods for ub.goods .

  do
  on error undo, return error return-value
  :
    find first buf_goods no-lock
      where buf_goods.gds-code  = p-gds-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Код" p-gds-code skip
        view-as alert-box error .
      undo, return error return-value . /* --->>>--- */
    end.

    assign
      p-gds-name = buf_goods.gds-name
    .
  end.
end procedure. /* gds-name */


procedure basecode :

  define input parameter  p-host-code  like ub.sysconf.host-code     no-undo .
  define output parameter p-base-code  like ub.sysconf.base-code     no-undo .

  define variable vss-description as character no-undo initial "basecode-01: определение кода базовой валюты".

  do
  on error undo, return error return-value
  :

    define buffer buf_sysconf for ub.sysconf .
    find first buf_sysconf no-lock
      where buf_sysconf.host-code = p-host-code
      no-error .
    if not available buf_sysconf
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена фирма" skip
        "host-code" p-host-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    assign
      p-base-code = buf_sysconf.base-code
    .
  end.

end procedure. /* basecode */


procedure consvtpc :

  define input parameter  p-host-code   like ub.sysconf.host-code   no-undo .
  define output parameter p-cons-vat-pc like ub.sysconf.cons-vat-pc no-undo .

  define variable vss-description as character no-undo initial "consvtpc-01: определение налога по консигнации".

  do
  on error undo, return error return-value
  :
    define buffer buf_sysconf for ub.sysconf .
    find first buf_sysconf no-lock
      where buf_sysconf.host-code = p-host-code
      no-error .
    if not available buf_sysconf
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена фирма" skip
        "host-code" p-host-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    assign
      p-cons-vat-pc = buf_sysconf.cons-vat-pc
    .
  end.

end procedure. /* basecode */

procedure baserate :

  define input  parameter p-host-code  like ub.sysconf.host-code     no-undo .
  define input  parameter p-curr-date  as date no-undo .
  define output parameter p-base-rate  like ub.curr-accnt.exch-rate  no-undo .
  define output parameter p-base-scale like ub.curr-accnt.exch-scale no-undo .

  define variable vss-description as character no-undo initial "baserate-01: определение курса базовой валюты".

  define buffer buf_curr-accnt for ub.curr-accnt .
  define buffer buf_currency   for ub.currency .

  define variable v-base-code like ub.sysconf.base-code no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/basecode.i
      p-host-code
      v-base-code
      no-error
    }
    if error-status :error
    then do:
      undo, return error substitute("Ошибка при определении кода базовой валюты для фирмы &1", p-host-code) .
    end.

    if p-curr-date = ?
    then do:
      find last buf_curr-accnt no-lock
        where buf_curr-accnt.curr-code = v-base-code
        use-index pi
        no-error .
    end.
    else do:
      find last buf_curr-accnt no-lock
        where buf_curr-accnt.curr-code =  v-base-code
          and buf_curr-accnt.exch-date <= p-curr-date
        use-index pi
        no-error .
    end.
    if not available buf_curr-accnt
    then do:
      find first buf_currency no-lock
        where buf_currency.curr-code = v-base-code
        no-error .
      if not available buf_currency
      then do:
        undo, return error substitute("Не найдена базовая валюта &1", v-base-code) .
      end.

      undo, return error substitute("Базовая валюта") + {&new-line}
        + substitute("Код &1", buf_currency.curr-code) + {&new-line}
        + substitute("Краткое название &1", buf_currency.curr-abbr ) + {&new-line}
        + substitute("Название &1", buf_currency.curr-name) + {&new-line}
        + substitute("На дату &1 неизвестен курс базовой валюты", string(p-curr-date, "99/99/9999"))
        .
    end.

    assign
      p-base-rate  = buf_curr-accnt.exch-rate
      p-base-scale = buf_curr-accnt.exch-scale
    .
  end.

end procedure. /* baserate */

procedure exchrate :

  define input  parameter p-curr-code  like ub.currency.curr-code    no-undo .
  define input  parameter p-curr-date  as date no-undo .
  define output parameter p-exch-rate  like ub.curr-accnt.exch-rate  no-undo .
  define output parameter p-exch-scale like ub.curr-accnt.exch-scale no-undo .
  define output parameter p-curr-abbr  like ub.currency.curr-abbr    no-undo .

  define variable vss-description as character no-undo initial "exchrate-01: определение курса валюты по отношению к национальной".
  define buffer buf_curr-accnt for ub.curr-accnt .
  define buffer buf_currency   for ub.currency .


  do
  on error undo, return error return-value
  :

    find first buf_currency no-lock
      where buf_currency.curr-code = p-curr-code
      no-error .
    if not available buf_currency
    then do:
      undo, return error substitute("Не найдена валюта &1", p-curr-code) .
    end.

    find last buf_curr-accnt no-lock
      where buf_curr-accnt.curr-code =  p-curr-code
        and buf_curr-accnt.exch-date <= p-curr-date
      use-index pi
      no-error .
    if not available buf_curr-accnt
    then do:

      undo, return error substitute("Валюта") + {&new-line}
        + substitute("Код &1", buf_currency.curr-code) + {&new-line}
        + substitute("Краткое название &1", buf_currency.curr-abbr ) + {&new-line}
        + substitute("Название &1", buf_currency.curr-name) + {&new-line}
        + substitute("На дату &1 неизвестен курс валюты", string(p-curr-date, "99/99/9999"))
        .
    end.

    assign
      p-exch-rate  = buf_curr-accnt.exch-rate
      p-exch-scale = buf_curr-accnt.exch-scale
      p-curr-abbr  = buf_currency.curr-abbr
    .
  end.

end procedure. /* exch-rate */



procedure curshift :
  define input  parameter p-obj-type   like ub.shift-obj.obj-type   no-undo .
  define input  parameter p-obj-code   like ub.shift-obj.obj-code   no-undo .
  define output parameter p-shift-date like ub.shift-obj.shift-date no-undo .
  define output parameter p-shift-num  like ub.shift-obj.shift-num  no-undo .
  define output parameter p-shift-name like ub.shift-obj.shift-name no-undo.

  define variable vss-description as character no-undo initial "curshift-01: определение текущей смены".

  define buffer buf_shift-obj for ub.shift-obj .

  do
  on error undo, return error return-value
  :

    find first buf_shift-obj
      where buf_shift-obj.obj-type = p-obj-type
        and buf_shift-obj.obj-code = p-obj-code
        and buf_shift-obj.status_ = {&sht-current}
      use-index stts
      no-error .
    if not available buf_shift-obj
    then do:
      undo, return error
        "Нет открытой смены на объекте: "
        + string(p-obj-type) + " " + string(p-obj-code) .
    end.

    assign
      p-shift-date = buf_shift-obj.shift-date
      p-shift-num  = buf_shift-obj.shift-num
      p-shift-name = buf_shift-obj.shift-name
    .
  end.

end procedure. /* curshift */


procedure lastindc :

/* Определение последнего прихода по фирме */
  define input  parameter p-host-code  like ub.gds-obj.host-code no-undo .
  define input  parameter p-artic      like ub.gds-obj.artic     no-undo .
  define input  parameter p-prod-type  like ub.gds-obj.prod-type no-undo .
  define input  parameter p-prod-code  like ub.gds-obj.prod-code no-undo .
  define output parameter p-in-code    like ub.gds-obj.in-code   no-undo .
  define output parameter p-obj-type   like ub.gds-obj.obj-type  no-undo .
  define output parameter p-obj-code   like ub.gds-obj.obj-code  no-undo .

  define variable vss-description as character no-undo initial "lastincd-01: определение объекта на котором был последний приход" .

  define buffer buf_gds-obj for ub.gds-obj .
  define buffer buf_trn-doc for ub.trn-doc .

  do
  on error undo, return error return-value
  :
    assign
      p-in-code  = ""
      p-obj-type = ""
      p-obj-code = 0
    .

    for each buf_gds-obj no-lock
      where buf_gds-obj.host-code = p-host-code
        and buf_gds-obj.artic     = p-artic
        and buf_gds-obj.prod-type = p-prod-type
        and buf_gds-obj.prod-code = p-prod-code
    , first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = buf_gds-obj.in-code
        and buf_trn-doc.status_  = {&fact}
    by buf_trn-doc.fact-order descending
    on error undo, return error return-value
    :
      assign
        p-in-code  = buf_gds-obj.in-code
        p-obj-type = buf_gds-obj.obj-type
        p-obj-code = buf_gds-obj.obj-code
      .

      leave . /* --->>>--- */
    end.
  end.

end procedure. /* lastincd */

procedure sclcdattr :

  /* создание атрибута ВЕСОВОЙ КОД ТОВАРА НА ОБЪЕКТЕ */

  define input  parameter p-gds-code  like ub.bar-code.gds-code  no-undo .
  define input  parameter p-obj-type  like ub.gds-obj.obj-type   no-undo .
  define input  parameter p-obj-code  like ub.gds-obj.obj-code   no-undo .
  define input  parameter p-b-str     like ub.prod-bc.b-str      no-undo.
  define input  parameter p-overwrite as logical no-undo .

  define variable vss-description as character no-undo initial "sclcdattr-01: создание атрибута ВЕСОВОЙ КОД ТОВАРА НА ОБЪЕКТЕ".
  define variable vss-proc-revision as character no-undo initial "library.p sclcdattr" .

  define buffer buf_bar-code for ub.bar-code .
  define buffer buf_prod-bc for ub.prod-bc .
  define buffer buf_gds-obj for ub.gds-obj .
  define buffer buf_clients for ub.clients .
  define buffer buf_units   for ub.units .
  define buffer buf_db       for ub.db .

  define variable v-db-num    as integer   no-undo .
  define variable v-node-code like ub.bar-code.node-code no-undo .
  define variable v-unit-base like ub.goods.unit-base no-undo .
  define variable p-b-code like ub.bar-code.b-code no-undo .
  define variable v-exist as logical no-undo .
  define variable v-b-str as integer no-undo .
  define variable l-prod-bc-weight as logical no-undo .
  define variable v-nw as logical no-undo .

  do
  on error undo, return error return-value
  :

    { gbl/curdbnum.i
      v-db-num
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении текущей БД" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    find first buf_db no-lock
      where buf_db.db-num = v-db-num
      no-error .
    if not available buf_db
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена запись таблицы базы данных" skip
        "База данных" v-db-num skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    { gbl/gdsrtnod.i
      p-gds-code
      v-node-code
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении корневого признака товара" skip
        "Код товара" p-gds-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value . /* --->>>--- */
    end.


    { gbl/unitbase.i
      p-gds-code
      v-unit-base
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка определения базовой единицы измерения товара" skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    find first buf_units No-LOCK
      where buf_units.unit-name = v-unit-base No-ERROR.
    if not avail buf_units
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена базовая единица измерения товара" skip
        "Единица измерения" v-unit-base
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if lookup({&weight}, buf_units.type) = 0
    then do:
      if lookup({&pieces}, buf_units.type) > 0 then do:
        v-nw = yes.
      end.
      else do:
      message
        vss-workfile vss-revision vss-description skip
        "Попытка присвоить атрибут товара на  объекте" skip
          "ВЕСОВОЙ КОД невесовому и не штучному товару" skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    end.

    find first buf_bar-code no-lock
      where buf_bar-code.gds-code  = p-gds-code
        and buf_bar-code.node-code = v-node-code
        and buf_bar-code.part-code = ""
        and buf_bar-code.in-code   = ""
        and buf_bar-code.unit-cli  = v-unit-base
      no-error .
    if not available buf_bar-code
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден первичный бар-кода признака " skip
        "Код товара" p-gds-code skip
        "Код признака" v-node-code skip
        "Базовая единица измерения" skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    assign
      p-b-code = buf_bar-code.b-code
    .

    _prod-bc:
    for each  buf_prod-bc no-lock
      where buf_prod-bc.b-code = p-b-code
        and buf_prod-bc.bc-on = true
        and (p-b-str = ? or buf_prod-bc.b-str = p-b-str)
     on error undo, return error return-value
     :

      if v-nw then do:
        if (buf_prod-bc.bc-on-type = {&loc-pg-code}) then do:
          leave _prod-bc.
        end.
        else do:
          next _prod-bc.
        end.
      end.
      else do:
      { gbl/prodbcat.i
        buf_prod-bc
        "'weight=request':u"
        l-prod-bc-weight
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении типа дополнительного бар-кода prodbcat" skip
          "Основной бар-код" buf_prod-bc.b-code skip
          "Дополнительный бар-код" buf_prod-bc.b-str skip
          "Действие weight=request" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      if not l-prod-bc-weight
      then do:
        NEXT _prod-bc.
      end.
      ELSE do:
        LEAVE _prod-bc.
      end.
      end.
    END. /*For eac buf_prod-bc*/

    if not avail buf_prod-bc
    then do:
      if p-b-str = ?
      then do:
        error-status:error = false.
        return.
      end.
      else do:
        if v-nw then do:
          message
            vss-workfile vss-revision vss-description skip
            "Не найден штучный код товара для весов" skip
            "Код товара" p-gds-code skip
            "Весовой код" p-b-str skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        else do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найден весовой код товара " skip
          "Код товара" p-gds-code skip
          "Весовой код" p-b-str skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      end.
    END.

    assign
    v-b-str = integer(buf_prod-bc.b-str) no-error.

    if error-status :error or v-b-str = ? or length(buf_prod-bc.b-str) > 6
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неверный весовой код " skip
        "Код товара" p-gds-code skip
        "Весовой код" buf_prod-bc.b-str skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    do
    on error undo, return error return-value
    :
      _clients:
      FOR EACH buf_clients No-LOCK WHERE
              buf_clients.db-num = buf_db.db-num
              on error undo, return error return-value
                /*на складах весов НЕТ но для общности в выборке будут и склады*/
              :
        if p-obj-type <> "" and
          p-obj-code <> 0 and
          (buf_clients.obj-type <> p-obj-type OR
            buf_clients.obj-code <> p-obj-code) then NEXT _Clients.

        FIND FIRST buf_gds-obj no-LOCK WHERE
                  buf_gds-obj.gds-code = p-gds-code AND
                  buf_gds-obj.obj-type = buf_clients.obj-type AND
                  buf_gds-obj.obj-code = buf_clients.obj-code No-ERROR.

        if NOT avail buf_gds-obj then NEXT _clients.

        run gdsoattr-exist in this-procedure (
                                              input p-gds-code,
                                              input buf_clients.obj-type,
                                              input buf_clients.obj-code,
                                              input {&attr-scales-code-o},
                                              output v-exist
                                            ) .

        if  v-exist
        and p-overwrite = false
        and (p-obj-type <> "" OR p-obj-code <> 0)
        then do:
          undo, return error vss-proc-revision + ":" + {&new-line}
            + "Уже имеется  атрибут  товара  на  объекте  ВЕСОВОЙ  КОД " + {&new-line}
            + "Код товара " + string(p-gds-code) + {&new-line}
            + "Тип объекта " + string(buf_clients.obj-type) + {&new-line}
            + "Код объекта " + string(buf_clients.obj-code) + {&new-line}
            .

        end.

        run gdsoattr-write in this-procedure (
                                              input p-gds-code,
                                              input buf_clients.obj-type,
                                              input buf_clients.obj-code,
                                              input {&attr-scales-code-o},
                                              input string(v-b-str, "99999")
                                            ) no-error.
        if error-status :error
        then do:
          undo, return error vss-proc-revision + ":" + {&new-line}
            + "Ошибка при создания атрибута товара на объекте ВЕСОВОЙ КОД" + {&new-line}
            + "Код товара " + string(p-gds-code) + {&new-line}
            + "Тип объекта " + string(buf_clients.obj-type) + {&new-line}
            + "Код объекта " + string(buf_clients.obj-code) + {&new-line}
            + "Значение атрибута " + string(v-b-str, "99999") + {&new-line}
            .
        end.

      END. /*FOR EACH buf_clients*/
    END. /*DO:*/
  end.

end procedure. /* sclcdattr */



procedure pftaxval :

  define input  parameter par-rc       as recid     no-undo .
  define input  parameter partax-code  like ub.tax.tax-code no-undo .
  define input  parameter parrate-code like ub.tax-rate.rate-code no-undo .
  /*if par-date = ? то для сейчас*/
  define input  parameter par-date     as date      no-undo .
  define input  parameter parhost-code like ub.sysconf.host-code no-undo .
  define input  parameter parobj-type  like ub.clients.obj-type no-undo .
  define input  parameter parobj-code  like ub.clients.obj-code no-undo .
  define output parameter partax-value as decimal no-undo initial ?.

  define variable vss-description as character no-undo initial "pftaxval: Значение по ставке налога в заданный момент  времени для заданного объекта и фирмы".

  define variable v-fact-order as decimal no-undo .
  define buffer buf_tax-rate for ub.tax-rate.
  define buffer buf_tax-rate-value for ub.tax-rate-value.
  define buffer buf_tax-rate-attr for ub.tax-rate-attr .
  do
  on error undo, return error return-value
  :

    if par-date = ?
    then do:
      assign
        par-date = today
      .
    end.

    run factord-end-day in this-procedure
      (input  par-date
      ,output v-fact-order
      ).

    if partax-code  = 0
    or parrate-code = 0
    then do:
      find first buf_tax-rate no-lock
        where recid(buf_tax-rate) = par-rc
        no-error .
      if not available buf_tax-rate
      then do:
        assign
          partax-value = ?
        .
        undo, return error
        "Не найдена ставка налога "
        + "recid " + string(par-rc)
        .
      end.
      assign
      partax-code = buf_tax-rate.tax-code
      parrate-code = buf_tax-rate.rate-code
      .
      if buf_tax-rate.status_ = {&deleted-status}
      then do:
        partax-value = ?.
        undo, return error
        "Ставка налога недействительна "
        + "налог: " + string(buf_tax-rate.tax-code) + " ставка: " + string(buf_tax-rate.rate-code) .

      end.
    END.
    FIND LAST buf_tax-rate-value NO-LOCK WHERE
                buf_tax-rate-value.tax-code  = partax-code  AND
                buf_tax-rate-value.rate-code = parrate-code AND
                buf_tax-rate-value.host-code = parhost-code AND
                buf_tax-rate-value.obj-type = parobj-type AND
                buf_tax-rate-value.obj-code = parobj-code AND
                buf_tax-rate-value.fact-order <= v-fact-order AND
                buf_tax-rate-value.status_ <> {&deleted-status}
                NO-ERROR.

    if avail buf_tax-rate-value
    then do:
      find first buf_tax-rate-attr no-lock where buf_tax-rate-attr.tax-code = integer({&vat-tax-code})
      and buf_tax-rate-attr.attr-code = "envd" and buf_tax-rate-attr.rate-code = buf_tax-rate-value.rate-code no-error .
      if available (buf_tax-rate-attr) then partax-value = -1 .
      else partax-value = buf_tax-rate-value.rate-value.
      return.
    end.

    FIND LAST buf_tax-rate-value NO-LOCK WHERE
                buf_tax-rate-value.tax-code  = partax-code  AND
                buf_tax-rate-value.rate-code = parrate-code AND
                buf_tax-rate-value.host-code = parhost-code AND
                buf_tax-rate-value.obj-type = "" AND
                buf_tax-rate-value.obj-code = 0 AND
                buf_tax-rate-value.fact-order <= v-fact-order AND
                buf_tax-rate-value.status_ <> {&deleted-status}
                NO-ERROR.

    if avail buf_tax-rate-value
    then do:
      find first buf_tax-rate-attr no-lock where buf_tax-rate-attr.tax-code = integer({&vat-tax-code})
      and buf_tax-rate-attr.attr-code = "envd" and buf_tax-rate-attr.rate-code = buf_tax-rate-value.rate-code no-error .
      if available (buf_tax-rate-attr) then partax-value = -1 .
      else partax-value = buf_tax-rate-value.rate-value.
      return.
    end.


    FIND LAST buf_tax-rate-value NO-LOCK WHERE
                buf_tax-rate-value.tax-code  = partax-code  AND
                buf_tax-rate-value.rate-code = parrate-code AND
                buf_tax-rate-value.host-code = 0 AND
                buf_tax-rate-value.obj-type = "" AND
                buf_tax-rate-value.obj-code = 0 AND
                buf_tax-rate-value.fact-order <= v-fact-order AND
                buf_tax-rate-value.status_ <> {&deleted-status}
                NO-ERROR.

    if avail buf_tax-rate-value
    then do:
      find first buf_tax-rate-attr no-lock where buf_tax-rate-attr.tax-code = integer({&vat-tax-code})
      and buf_tax-rate-attr.attr-code = "envd" and buf_tax-rate-attr.rate-code = buf_tax-rate-value.rate-code no-error .
      if available (buf_tax-rate-attr) then partax-value = -1 .
      else partax-value = buf_tax-rate-value.rate-value.
      return.
    end.

  end.

end procedure. /* pftaxval */


procedure pftaxvlx :

  define input  parameter par-rc       as recid     no-undo .
  define input  parameter partax-code  like ub.tax.tax-code no-undo .
  define input  parameter parrate-code like ub.tax-rate.rate-code no-undo .
  /*if par-date = ? то для сейчас*/
  define input  parameter par-date     as date      no-undo .
  define input  parameter parhost-code like ub.sysconf.host-code no-undo .
  define input  parameter parobj-type  like ub.clients.obj-type no-undo .
  define input  parameter parobj-code  like ub.clients.obj-code no-undo .
  define output parameter par-x-host-code like ub.sysconf.host-code no-undo .
  define output parameter par-x-obj-type  like ub.clients.obj-type no-undo .
  define output parameter par-x-obj-code  like ub.clients.obj-code no-undo .

  define variable vss-description as character no-undo initial "pftaxvlx: Область действия ставки налога в заданный момент  времени для заданного объекта и фирмы".

  define variable v-fact-order as decimal no-undo .
  define buffer buf_tax-rate for ub.tax-rate.
  define buffer buf_tax-rate-value for ub.tax-rate-value.

  do
  on error undo, return error return-value
  :

    if par-date = ?
    then do:
      assign
        par-date = today
      .
    end.

    run factord-end-day in this-procedure
      (input  par-date
      ,output v-fact-order
      ).

    if partax-code  = 0
    or parrate-code = 0
    then do:
      find first buf_tax-rate no-lock
        where recid(buf_tax-rate) = par-rc
        no-error .
      if not available buf_tax-rate
      then do:
        undo, return error
        "Не найдена ставка налога "
        + "recid " + string(par-rc)
        .
      end.
      assign
      partax-code = buf_tax-rate.tax-code
      parrate-code = buf_tax-rate.rate-code
      .
      if buf_tax-rate.status_ = {&deleted-status}
      then do:
        undo, return error
        "Ставка налога недействительна "
        + "налог: " + string(buf_tax-rate.tax-code) + " ставка: " + string(buf_tax-rate.rate-code) .

      end.
    END.
    FIND LAST buf_tax-rate-value NO-LOCK WHERE
                buf_tax-rate-value.tax-code  = partax-code  AND
                buf_tax-rate-value.rate-code = parrate-code AND
                buf_tax-rate-value.host-code = parhost-code AND
                buf_tax-rate-value.obj-type = parobj-type AND
                buf_tax-rate-value.obj-code = parobj-code AND
                buf_tax-rate-value.fact-order <= v-fact-order AND
                buf_tax-rate-value.status_ = {&current-status}
                NO-ERROR.

    if avail buf_tax-rate-value
    then do:
      assign
      par-x-host-code = buf_tax-rate-value.host-code
      par-x-obj-type = buf_tax-rate-value.obj-type
      par-x-obj-code = buf_tax-rate-value.obj-code
      .
      return.
    end.

    FIND LAST buf_tax-rate-value NO-LOCK WHERE
                buf_tax-rate-value.tax-code  = partax-code  AND
                buf_tax-rate-value.rate-code = parrate-code AND
                buf_tax-rate-value.host-code = parhost-code AND
                buf_tax-rate-value.obj-type = "" AND
                buf_tax-rate-value.obj-code = 0 AND
                buf_tax-rate-value.fact-order <= v-fact-order AND
                buf_tax-rate-value.status_ = {&current-status}
                NO-ERROR.

    if avail buf_tax-rate-value
    then do:
      assign
      par-x-host-code = buf_tax-rate-value.host-code
      par-x-obj-type = buf_tax-rate-value.obj-type
      par-x-obj-code = buf_tax-rate-value.obj-code
      .
      return.
    end.


    FIND LAST buf_tax-rate-value NO-LOCK WHERE
                buf_tax-rate-value.tax-code  = partax-code  AND
                buf_tax-rate-value.rate-code = parrate-code AND
                buf_tax-rate-value.host-code = 0 AND
                buf_tax-rate-value.obj-type = "" AND
                buf_tax-rate-value.obj-code = 0 AND
                buf_tax-rate-value.fact-order <= v-fact-order AND
                buf_tax-rate-value.status_ = {&current-status}
                NO-ERROR.

    if avail buf_tax-rate-value
    then do:
      assign
      par-x-host-code = buf_tax-rate-value.host-code
      par-x-obj-type = buf_tax-rate-value.obj-type
      par-x-obj-code = buf_tax-rate-value.obj-code
      .
      return.
    end.

  end.

end procedure. /* pftaxvlx */


procedure pftxvalg :

  define input parameter pargds-code like ub.goods.gds-code no-undo.
  define input parameter partax-code like ub.tax.tax-code no-undo.
  define input parameter par-date as date no-undo.
  /*если pardate = ? то искать на момент сейчас*/
  define input parameter parhost-code like ub.sysconf.host-code no-undo .
  define input parameter parobj-type  like ub.clients.obj-type no-undo .
  define input parameter parobj-code  like ub.clients.obj-code no-undo .
  define output parameter partax-value as decimal no-undo .

  define variable vss-description as character no-undo initial "pftxvalg: значение по ставке налога на товар в выбранный момент времени".


  DEFINE VARIABLE v-fact-order as decimal no-undo .
  define buffer buf_tax-rate-gds for ub.tax-rate-gds.
  define buffer buf_goods for ub.goods.

  do
  on error undo, return error return-value
  :

    assign
      partax-value = ?
    .

    find first buf_goods no-lock
      where buf_goods.gds-code = pargds-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найден товар" skip
        "Код товара" pargds-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if par-date = ?
    then do:
      assign
        par-date = today
      .
    end.

    run factord-end-day in this-procedure
      (input  par-date
      ,output v-fact-order
      ).

    find last buf_tax-rate-gds no-lock
      where buf_tax-rate-gds.gds-code   = pargds-code
        and buf_tax-rate-gds.tax-code   = partax-code
        and buf_tax-rate-gds.host-code  = 0
        and buf_tax-rate-gds.obj-type   = ""
        and buf_tax-rate-gds.obj-code   = 0
        and buf_tax-rate-gds.fact-order <= v-fact-order
      no-error .

    /*налог на товар определен глобально*/

    IF AVAIL buf_tax-rate-gds
    then do:
      { gbl/pftxvalo.i
        ?
        buf_tax-rate-gds.tax-code
        buf_tax-rate-gds.rate-code
        v-fact-order
        parhost-code
        parobj-type
        parobj-code
        partax-value
        no-error
      }
      if error-status :error
      then do:
        undo, return error return-value .
      end.
      return.
    end.
  end.

end procedure. /* pftxvalg */

procedure pgtxvalg :

  define input  parameter pargds-code  like ub.goods.gds-code no-undo .
  define input  parameter partax-code  like ub.tax.tax-code   no-undo .
  define input  parameter par-date     as date no-undo .
  /*если pardate = ? то искать на момент сейчас*/
  define output parameter partax-value as decimal no-undo initial ? .

  define variable vss-description as character no-undo initial "pgtxvalg: корневое значение ставки налога на товар в выбранный момент времени".

  define variable v-fact-order as decimal no-undo .
  define buffer buf_tax-rate-gds for ub.tax-rate-gds.
  define buffer buf_goods for ub.goods.
  define buffer buf_tax-rate for ub.tax-rate .

  do
  on error undo, return error return-value
  :

    find first buf_goods no-lock
      where buf_goods.gds-code = pargds-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найден товар" skip
        "Код товара" pargds-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if par-date = ?
    then do:
      assign
        par-date = today
      .
    end.

    run factord-end-day in this-procedure
      (input  par-date
      ,output v-fact-order
      ).

    find last buf_tax-rate-gds no-lock
      where buf_tax-rate-gds.gds-code   = pargds-code
        and buf_tax-rate-gds.tax-code   = partax-code
        and buf_tax-rate-gds.host-code  = 0
        and buf_tax-rate-gds.obj-type   = ""
        and buf_tax-rate-gds.obj-code   = 0
        and buf_tax-rate-gds.fact-order <= v-fact-order
      no-error .

    /*налог на товар определен глобально*/

    if available buf_tax-rate-gds
    then do:
      FIND FIRST buf_tax-rate NO-LOCK
        WHERE buf_tax-rate.tax-code = buf_tax-rate-gds.tax-code
          AND buf_tax-rate.rate-code = buf_tax-rate-gds.rate-code
        NO-ERROR .
      if not avail buf_tax-rate
      then do:
        assign
          partax-value = ?
        .
        undo, return error
          "Не найдена ставка налога "
          + "налог: " + string(buf_tax-rate-gds.tax-code) + " ставка: " + string(buf_tax-rate-gds.rate-code)
          .
      end.
      if buf_tax-rate.status_ = {&deleted-status}
      then do:
        assign
          partax-value = ?
        .
        undo, return error
          "Ставка налога недействительна "
          + "налог: " + string(buf_tax-rate.tax-code) + " ставка: " + string(buf_tax-rate.rate-code)
          .
      end.
      { gbl/pftxvalo.i
        ?
        buf_tax-rate-gds.tax-code
        buf_tax-rate-gds.rate-code
        v-fact-order
        0
        "'':U"
        0
        partax-value
        no-error
      }
      if error-status :error
      then do:
        undo, return error return-value .
      end.
      return.
    end.
  end.

end procedure. /* pgtxvalg */

procedure pftxvalo :

  define input  parameter par-rc        as recid                          no-undo .
  define input  parameter partax-code   like ub.tax.tax-code              no-undo .
  define input  parameter parrate-code  like ub.tax-rate.rate-code        no-undo .
  define input  parameter parfact-order like ub.tax-rate-value.fact-order no-undo .
  define input  parameter parhost-code  like ub.sysconf.host-code         no-undo .
  define input  parameter parobj-type   like ub.clients.obj-type          no-undo .
  define input  parameter parobj-code   like ub.clients.obj-code          no-undo .
  define output parameter partax-value  as decimal no-undo .

  define variable vss-description as character no-undo initial "pftxvalo: Значение по ставке налога для данного fact-order для заданного объекта и фирмы".

  define buffer buf_tax-rate for ub.tax-rate.
  define buffer buf_tax-rate-value for ub.tax-rate-value.

  do
  on error undo, return error return-value
  :
    assign
      partax-value = ?
    .

    if partax-code  = 0
    or parrate-code = 0
    then do:
      if par-rc = ?
      then do:
        undo, return error "Неверный параметр - recid tax-rate" .
      end.
      find first buf_tax-rate no-lock
        where recid(buf_tax-rate) = par-rc
        no-error .
      if not available buf_tax-rate
      then do:
        undo, return error "Не найдена ставка налога " + "recid " + string(par-rc) .
      end.
      if buf_tax-rate.status_ = {&deleted-status}
      then do:
        undo, return error "Ставка налога недействительна "
        + "налог: " + string(buf_tax-rate.tax-code) + " ставка: " + string(buf_tax-rate.rate-code) .
      end.
      assign
        partax-code  = buf_tax-rate.tax-code
        parrate-code = buf_tax-rate.rate-code
      .
    end.

    find last buf_tax-rate-value no-lock
      where buf_tax-rate-value.tax-code   = partax-code
        and buf_tax-rate-value.rate-code  = parrate-code
        and buf_tax-rate-value.host-code  = parhost-code
        and buf_tax-rate-value.obj-type   = parobj-type
        and buf_tax-rate-value.obj-code   = parobj-code
        and buf_tax-rate-value.fact-order <= parfact-order
        and buf_tax-rate-value.status_    = {&current-status}
      no-error .
    if available buf_tax-rate-value
    then do:
      assign
        partax-value = buf_tax-rate-value.rate-value
      .
      return.
    end.

    find last buf_tax-rate-value no-lock
      where buf_tax-rate-value.tax-code   = partax-code
        and buf_tax-rate-value.rate-code  = parrate-code
        and buf_tax-rate-value.host-code  = parhost-code
        and buf_tax-rate-value.obj-type   = ""
        and buf_tax-rate-value.obj-code   = 0
        and buf_tax-rate-value.fact-order <= parfact-order
        and buf_tax-rate-value.status_    = {&current-status}
      no-error .
    if available buf_tax-rate-value
    then do:
      assign
        partax-value = buf_tax-rate-value.rate-value
      .
      return.
    end.

    find last buf_tax-rate-value no-lock
      where buf_tax-rate-value.tax-code   = partax-code
        and buf_tax-rate-value.rate-code  = parrate-code
        and buf_tax-rate-value.host-code  = 0
        and buf_tax-rate-value.obj-type   = ""
        and buf_tax-rate-value.obj-code   = 0
        and buf_tax-rate-value.fact-order <= parfact-order
        and buf_tax-rate-value.status_    = {&current-status}
      no-error .
    if available buf_tax-rate-value
    then do:
      assign
        partax-value = buf_tax-rate-value.rate-value
      .
      return.
    end.
  end.

end procedure. /* pftaxval */

procedure getListTaxRateValue :

  define input  parameter iTax       like ub.tax.tax-name              no-undo .
  define input  parameter iDate      like ub.tax-rate-value.fact-date  no-undo .
  define input  parameter iHostCode  like ub.sysconf.host-code         no-undo .
  define input  parameter iObjType   like ub.clients.obj-type          no-undo .
  define input  parameter iObjCode   like ub.clients.obj-code          no-undo .
  define output parameter oListTaxValue as character no-undo .

  define variable vss-description as character no-undo initial "getListTaxRateValue: Возвращает список действующих ставок налога на дату для заданного объекта".

  define variable vFactOrder as decimal no-undo.
  define buffer buf_tax            for ub.tax.
  define buffer buf_tax-rate       for ub.tax-rate.
  define buffer buf_tax-rate-value for ub.tax-rate-value.

  if iDate = ? then
    iDate = today.
  run factord-end-day in this-procedure
    (input  iDate
    ,output vFactOrder
    ).
  do
  on error undo, return error return-value
  :
    for first buf_tax where 
              buf_tax.tax-name = iTax
          and buf_tax.status_  = {&current-status} no-lock,
        each buf_tax-rate where 
             buf_tax-rate.tax-code = buf_tax.tax-code
         and buf_tax-rate.status_ <> {&deleted-status}
        no-lock,
        last buf_tax-rate-value where
             buf_tax-rate-value.tax-code = buf_tax-rate.tax-code 
         and buf_tax-rate-value.rate-code = buf_tax-rate.rate-code 
         and buf_tax-rate-value.host-code = iHostCode 
         and buf_tax-rate-value.obj-type = iObjType 
         and buf_tax-rate-value.obj-code = iObjCode
         and buf_tax-rate-value.fact-order <= vFactOrder 
         and buf_tax-rate-value.status_ = {&current-status}
        no-lock by buf_tax-rate-value.rate-value:
      oListTaxValue = substitute(
        "&1&2&3", 
        oListTaxValue,
        if oListTaxValue = "" then "" else ",",
        string(buf_tax-rate-value.rate-value)
      ). 
    end.
  end.
end procedure.

procedure curobjdt :

  define input  parameter p-obj-type like ub.obj-date.obj-type   no-undo .
  define input  parameter p-obj-code like ub.obj-date.obj-code   no-undo .
  define output parameter p-sys-date like ub.obj-date.sys-date no-undo .

  define variable vss-description as character no-undo initial "curobjdt-01: определение текущей даты".

  do
  on error undo, return error return-value
  :
    define buffer bf_clients for ub.clients.
    define variable v-cur-sys-date  as date      no-undo .
    define variable v-db-sys-date   as date      no-undo .
    define variable v-obj-is-active as logical   no-undo.
    define variable diffshftvalue   as character no-undo initial ?.
    define variable diffshfttype    as character no-undo initial ?.
    define variable vardiffshft     as integer   no-undo initial ?.
    assign
      v-db-sys-date = today
    .
    { gbl/objdtget.i
      p-obj-type
      p-obj-code
      v-cur-sys-date
      no-error
    }
    if error-status :error
    then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры получить текущую дату объекта" skip
          "Объект" p-obj-type p-obj-code skip
          return-value skip
          error-status :get-message(1) skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
    { gbl/objat.i
      p-obj-type
      p-obj-code
      "'active=request':U"
      v-obj-is-active
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не удалось определить активность объекта." skip
        "Объект" p-obj-type p-obj-code skip
        return-value skip
        error-status :get-message(1) skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if v-obj-is-active = yes
    then do:
      if v-cur-sys-date = ?
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "На объекте не задана текущая дата" skip
          "Объект" p-obj-type p-obj-code skip
          return-value skip
          error-status :get-message(1) skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      /* Дата объекта больше, чем показания системных часов */
      /* не разрешаем работать пользователям, возвращаем ошибку */
      if v-cur-sys-date > v-db-sys-date
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Дата объекта не может быть больше, чем физическое время на сервере БД" skip
          "Объект" p-obj-type p-obj-code skip
          "Дата объекта" v-cur-sys-date skip
          "Физическое время на сервере БД" v-db-sys-date skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      if v-cur-sys-date = v-db-sys-date
      then do:
        assign
          p-sys-date = v-cur-sys-date
        .
        return .
      end.

      define variable l-shift-on  as logical   no-undo .
      define variable l-auto-date as logical   no-undo .

      if v-cur-sys-date < v-db-sys-date
      then do:
        { gbl/objat.i
          p-obj-type
          p-obj-code
          "'shift-on=request':U"
          l-shift-on
          no-error
        }
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при определении атрибута объекта" skip
            "Объект" p-obj-type p-obj-code skip
            "Атрибут" 'shift-on=request':u skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.

        { gbl/objat.i
          p-obj-type
          p-obj-code
          "'autodate=request':u"
          l-auto-date
          no-error
        }
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при определении атрибута объекта" skip
            "Объект" p-obj-type p-obj-code skip
            "Атрибут" 'autodate=request':u skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.

/*        if v-db-sys-date - v-cur-sys-date > 10 */
/*        then do:*/
/*          message*/
/*            "Дата на объекте отличается от системной даты более чем на 10 дней" skip*/
/*            "Обратитесь к администратору" skip*/
/*            "Объект" p-obj-type p-obj-code skip*/
/*            "Дата на объекте" v-cur-sys-date skip*/
/*            "Системная дата" v-db-sys-date skip*/
/*            view-as alert-box error .*/
/*          undo, return error return-value .*/
/*        end.*/

        if l-shift-on = false
        then do:
          /* на объекте выключены смены */
          if l-auto-date = false
          then do:
            assign
              p-sys-date = v-cur-sys-date
            .
            return .
          end.
          else do:
            { gbl/objdtset.i
              p-obj-type
              p-obj-code
              v-db-sys-date
            }

            { gbl/objdtget.i
              p-obj-type
              p-obj-code
              p-sys-date
              no-error
            }
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Не объекте не задана текущая дата" skip
                "Объект" p-obj-type p-obj-code skip
                return-value skip
                error-status :get-message(1) skip
                view-as alert-box error .
              undo, return error return-value .
            end.
            return .
          end.
        end.
        else do:
          /* на объекте включены смены */
          if l-auto-date = false
          then do:
            assign
              p-sys-date = v-cur-sys-date
            .
            return .
          end.
          else do:
            /* определяем текущую смену */
            /* если она задана - то контролируем максимальное количество дней для смены */
            define variable p-shift-date as date      no-undo .
            define variable p-shift-num  as integer   no-undo .
            define variable p-shift-name as character no-undo .

            { gbl/curshift.i
              p-obj-type
              p-obj-code
              p-shift-date
              p-shift-num
              p-shift-name
              no-error
            }
            if error-status :error
            then do:
              if error-status :get-message(1) <> ""
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Ошибка при вызове процедуры" 'curshift':u skip
                  error-status :get-message(1) skip
                  return-value skip
                  view-as alert-box error .
                undo, return error return-value .
              end.
            end.

            if p-shift-date <> ?
            then do:
              find first bf_clients where bf_clients.obj-type = p-obj-type and
                                          bf_clients.obj-code = p-obj-code no-lock no-error.
              if not available bf_clients then do:
                message "Не найден клиент: " p-obj-type p-obj-code skip
                vss-workfile vss-revision vss-description skip
                view-as alert-box error .
                undo, return error return-value .
              end.
               define variable v-value-character as character  no-undo .
               define variable v-value-date      as date       no-undo .
               define variable v-value-decimal   as decimal    no-undo .
               define variable v-value-integer   as integer    no-undo .
               define variable v-value-logical   as logical    no-undo .
               define variable v-tth             as handle     no-undo .
               define variable v-param-type            as character no-undo .

               run adm/shattri.p ( input "get":U
                                 , input  p-obj-type
                                 , input  p-obj-code
                                 , input  {&attr-obj-date}
                                 , input  {&attr-obj-date_diffshft}
                                 , output v-value-character
                                 , output v-value-date
                                 , output v-value-decimal
                                 , output v-value-integer
                                 , output v-value-logical
                                 , output v-param-type
                                 , input-output table-handle v-tth
                                 ) no-error .
              if error-status :error then do:
                /* параметр может быть не задан */
                assign vardiffshft = 3.
              end.
              else do:
                assign
                  vardiffshft = v-value-integer no-error.
                if error-status :error
                or vardiffshft < 0
                then do:
                  message "Неверно задан параметр diffshft: " diffshftvalue skip
                          "Параметр может принимать целые значения > 0." skip
                  view-as alert-box error.
                  undo, return error substitute( "Неверно задан параметр diffshft: &1.&2" +
                                                 "Параметр может принимать целые значения > 0.",
                                                 diffshftvalue,
                                                 {&new-line} ) .
                end.
              end.
              delete object v-tth no-error.
              if v-db-sys-date - p-shift-date > vardiffshft
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Нельзя изменить дату" skip
                  "Максимальный размер смены составляет " vardiffshft " суток" skip
                  "Объект" p-obj-type p-obj-code skip
                  view-as alert-box error .
                undo, return error return-value .
              end.
            end.

            { gbl/objdtset.i
              p-obj-type
              p-obj-code
              v-db-sys-date
            }

            { gbl/objdtget.i
              p-obj-type
              p-obj-code
              p-sys-date
              no-error
            }
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Не объекте не задана текущая дата" skip
                "Объект" p-obj-type p-obj-code skip
                return-value skip
                error-status :get-message(1) skip
                view-as alert-box error .
              undo, return error return-value .
            end.
            return .
          end.
        end.
      end.
    end.        /* v-obj-is-active = yes */
    else do:
      assign
        p-sys-date = v-cur-sys-date
      .
      /* текущая дата на объекте не задана */
      /* возвращаем текущую дату */
      /* имеет значение сразу после upgrade, когда дата с удаленного объекта ещё не пришла */
      if p-sys-date = ?
      then do:
        assign
          p-sys-date = today
        .
      end.
    end.        /* v-obj-is-active <> yes */
  end.

end procedure. /* curobjdt */

procedure objdtget :

  define input  parameter p-obj-type like ub.obj-date.obj-type no-undo .
  define input  parameter p-obj-code like ub.obj-date.obj-code no-undo .
  define output parameter p-sys-date like ub.obj-date.sys-date no-undo .

  define variable vss-description as character no-undo initial "objdtget-01: запросить текущую дату на объекте".

  do
  on error undo, return error return-value
  :
    define buffer buf_obj-date for ub.obj-date .

    /* разделяемая блокировка, с тем чтобы запретить одновременное */
    /* изменение даты на объекте */
    find first buf_obj-date
      where buf_obj-date.obj-type = p-obj-type
        and buf_obj-date.obj-code = p-obj-code
        and buf_obj-date.status_  = {&objdt-current}
      no-error .
    if not available buf_obj-date
    then do:
      undo, return error substitute("На объекте не задана текущая дата. Объект &1 &2", p-obj-type, p-obj-code) .
    end.

    assign
      p-sys-date = buf_obj-date.sys-date
    .
    RELEASE buf_obj-date.

  end.

end procedure. /* objdtget */


procedure objdtset :

  define input parameter p-obj-type like ub.obj-date.obj-type   no-undo .
  define input parameter p-obj-code like ub.obj-date.obj-code   no-undo .
  define input parameter p-sys-date like ub.obj-date.sys-date no-undo .

  define variable vss-description as character no-undo initial "objdtset-01: установить текущую дату на объекте".

  do transaction
  on error undo, return error return-value
  :
    define buffer buf_obj-date for ub.obj-date .

    { gbl/odtclose.i
      p-obj-type
      p-obj-code
      p-sys-date
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры" 'odtclose':u skip
        "Объект" p-obj-type p-obj-code skip
        "Новая дата" p-sys-date skip
        return-value skip
        error-status :get-message(1) skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    { gbl/objdtcr.i
      p-obj-type
      p-obj-code
      p-sys-date
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры" 'objdtcr':u skip
        "Объект" p-obj-type p-obj-code skip
        "Новая дата" p-sys-date skip
        return-value skip
        error-status :get-message(1) skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.

end procedure. /* objdtset */

procedure objdtcr :

  define input parameter p-obj-type like ub.obj-date.obj-type no-undo .
  define input parameter p-obj-code like ub.obj-date.obj-code no-undo .
  define input parameter p-sys-date like ub.obj-date.sys-date no-undo .

  define variable vss-description as character no-undo initial "objdtcr-01: создать новую текущую дату на объекте".

  define buffer buf_obj-date for ub.obj-date .

  do
  on error undo, return error return-value
  :
    create buf_obj-date .
    assign
      buf_obj-date.obj-type = p-obj-type
      buf_obj-date.obj-code = p-obj-code
      buf_obj-date.sys-date = p-sys-date
      buf_obj-date.status_  = {&objdt-current}
    .
    release buf_obj-date .
  end.

end procedure. /* objdtcr */


procedure odtclose :

  define input parameter p-obj-type like ub.obj-date.obj-type no-undo .
  define input parameter p-obj-code like ub.obj-date.obj-code no-undo .
  define input parameter p-sys-date like ub.obj-date.sys-date no-undo .

  define variable vss-description as character no-undo initial "odtclose-01: закрыть текущую дату на объекте".

  do transaction
  on error undo, return error return-value
  :
    define buffer buf_obj-date for ub.obj-date .

    find first buf_obj-date exclusive-lock
      where buf_obj-date.obj-type = p-obj-type
        and buf_obj-date.obj-code = p-obj-code
        and buf_obj-date.status_  = {&objdt-current}
      no-error .
    if not available buf_obj-date
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "На объекте не задана текущая дата" skip
        "Объект" p-obj-type p-obj-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if p-sys-date < buf_obj-date.sys-date
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Новая дата не может быть меньше текущей даты" skip
        "Объект" p-obj-type p-obj-code skip
        "Новая дата" p-sys-date skip
        "Текущая дата" buf_obj-date.sys-date skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    assign
      buf_obj-date.status_ = {&objdt-closed}
    .

    release buf_obj-date .
  end.

end procedure. /* odtclose */


procedure curr-r-b :

  define output parameter p-r-b       as character no-undo .

  define variable vss-description as character no-undo initial "curr-r-b-1: определение типа валюты продажи".

  define buffer buf_sys-ctrl for ub.sys-ctrl .

  do
  on error undo, return error return-value
  :
    find first buf_sys-ctrl no-lock .

    assign
      p-r-b = buf_sys-ctrl.r-b
    .
    if  p-r-b <> {&r-b-rubl}
    and p-r-b <> {&r-b-base}
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Недопустимое значение типа валюты продажи" p-r-b skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.

end procedure. /* curr-r-b */

procedure currsysk :

  define output parameter p-sys-key       as character no-undo .

  define variable vss-description as character no-undo initial "curr-sk: определение sys-key".

  define buffer buf_sys-ctrl for ub.sys-ctrl .

  do
  on error undo, return error return-value
  :
    find first buf_sys-ctrl no-lock .

    assign
      p-sys-key = buf_sys-ctrl.sys-key
    .
    if p-sys-key = ? then do:
      assign
        p-sys-key = "":U
      .
    end.
  end.

end procedure. /* currsysk */


procedure rbisbase :

  define output parameter p-rb-is-base as logical   no-undo .

  do
  on error undo, return error return-value
  :
    define variable v-curr-r-b as character no-undo .
    { gbl/curr-r-b.i
      v-curr-r-b
    }
    if v-curr-r-b = {&r-b-base}
    then do:
      assign
        p-rb-is-base = true
      .
    end.
    else do:
      assign
        p-rb-is-base = false
      .
    end.
  end.

end procedure. /* rbisbase */

procedure r-b-curr :

  define input parameter  p-host-code  like ub.sysconf.host-code     no-undo .
  define output parameter p-curr-code  as integer   no-undo .

  define variable vss-description as character no-undo initial "r-b-curr-01: определение кода валюты r-b для фирмы".

  define variable v-curr-r-b  as character no-undo .

  do
  on error undo, return error return-value
  :

    { gbl/curr-r-b.i
      v-curr-r-b
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры curr-r-b" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if v-curr-r-b = {&r-b-rubl}
    then do:
      assign
        p-curr-code = 0
      .
    end.
    else do:
      { gbl/basecode.i
        p-host-code
        p-curr-code
        no-error
      }
      if error-status :error
      then do:
        undo, return error return-value .
      end.
    end.
  end.

end procedure. /* r-b-abbr */



procedure r-b-abbr :

  define input parameter  p-host-code  like ub.sysconf.host-code     no-undo .
  define output parameter p-r-b-abbr   as character no-undo .

  define variable vss-description as character no-undo initial "r-b-abbr-03: определение аббревиатуры валюты r-b для фирмы".

  define variable v-curr-code as integer   no-undo .
  define buffer buf_currency for ub.currency.

  do
  on error undo, return error return-value
  :
    { gbl/r-b-curr.i
      p-host-code
      v-curr-code
      no-error
    }
    if error-status :error
    then do:
      undo, return error return-value .
    end.

    find first buf_currency no-lock
      where buf_currency.curr-code = v-curr-code
      no-error .
    if not available buf_currency
    then do:
      assign
        p-r-b-abbr = "?"
      .
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена валюта" skip
        "curr-code" v-curr-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    assign
      p-r-b-abbr = buf_currency.curr-abbr
    .
  end.

end procedure. /* r-b-abbr */

procedure objdpcnt :
  define input parameter p-type like ub.dis-card-type.type no-undo .
  define input parameter p-emitent-host-code like ub.dis-card-type.emitent-host-code no-undo .
  define input parameter p-host-code like ub.sysconf.host-code  no-undo .
  define input parameter p-obj-type like ub.clients.obj-type   no-undo .
  define input parameter p-obj-code like ub.clients.obj-code   no-undo .
  define input parameter p-discnt-role as character no-undo .
  define output parameter p-d-pcnt as decimal no-undo init ?.
  define variable vss-description as character no-undo initial "objdpcnt2: определение скидки по карте на объекте".


  do transaction
  on error undo, return error return-value
  :
    define buffer buf_dis-dct-rule for ub.dis-dct-rule .
    define buffer buf_dis-rule for ub.dis-rule.
    if NOT (p-discnt-role = {&ddctr-def-pcnt}
            OR
            p-discnt-role = {&ddctr-def-cash-pcnt}
            or
            p-discnt-role = {&ddctr-def-categ}
            )
    then do:
        message
          vss-workfile vss-revision vss-description skip
          "Неверные параметры вызова" skip
          "p-discnt-role" skip
          view-as alert-box error .
        undo, return error return-value .
    end.
    FIND FIRST buf_dis-dct-rule No-LOCK WHERE
                        buf_dis-dct-rule.type = p-type
                    AND buf_dis-dct-rule.emitent-host-code = p-emitent-host-code
                    AND buf_dis-dct-rule.host-code = p-host-code
                    AND buf_dis-dct-rule.obj-type = p-obj-type
                    and buf_dis-dct-rule.obj-code = p-obj-code
                    and buf_dis-dct-rule.pos-type = {&cd-type-bo}
                    and buf_dis-dct-rule.discnt-role = p-discnt-role No-ERROR.
    if available buf_dis-dct-rule
    then do:
      find first buf_dis-rule NO-lock
        where buf_dis-rule.rule-num = buf_dis-dct-rule.rule-num no-error.
      if not avail buf_dis-rule
      then do:
&scop dis-dct-rule-code p-discnt-role
          p-d-pcnt = ?.
          undo, return error
          substitute("Не найдена скидка для типа ДК: тип &1 эмитент &2&3тип скидки &4"
                     , p-type
                     , p-emitent-host-code
                     , {&new-line}
                     ,{&dis-dct-rule-name}
                     ) .
      end. /*if not avail buf_dis-card-type host-code = 0 */
      assign
      p-d-pcnt = (if p-discnt-role = {&ddctr-def-categ}
                  then buf_dis-rule.dis-kat
                  else buf_dis-rule.discnt-value).
      return.
    end. /*if not avail buf_dis-card-type obj-code = 0*/
  end. /*do transaction*/

end procedure. /* objdpcnt */

procedure wthobjcr :
  define input parameter  v-obj-type  like ub.wth-obj.obj-type  no-undo .
  define input parameter  v-obj-code  like ub.wth-obj.obj-code  no-undo .
  define input parameter  v-wth-code  like ub.wth-obj.wth-code     no-undo .
  define parameter buffer buf_wth-obj for ub.wth-obj .

  define variable vss-description as character no-undo initial "wthobjcr-01: поиск/cоздание записи о МЦ на объекте".

  define buffer buf_wealth for ub.wealth .

  find first buf_wth-obj no-lock
    where buf_wth-obj.obj-type  = v-obj-type
      and buf_wth-obj.obj-code  = v-obj-code
      and buf_wth-obj.wth-code  = v-wth-code
    no-error .
  if not available buf_wth-obj
  then do:
    do transaction
    on error undo, return error return-value
    :
      find first buf_wealth share-lock
        where buf_wealth.wth-code = v-wth-code
        no-error .

      if not available buf_wealth
      then do:
        message
          "МЦ" v-wth-code "не найдена."
          view-as alert-box .
        undo, return error return-value .
      end.

      create buf_wth-obj.
      assign
        buf_wth-obj.obj-type     = v-obj-type
        buf_wth-obj.obj-code     = v-obj-code
        buf_wth-obj.wth-code     = v-wth-code
      .

      /* прописываем host-code */

      { gbl/hostcode.i
        v-obj-type
        v-obj-code
        buf_wth-obj.host-code
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении кода фирмы для объекта" skip
          "v-obj-type" v-obj-type skip
          "v-obj-code" v-obj-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      /* Проверяем, что в базе данных отсутствуют "кривые" wt-pobj */
      define buffer buf_wth-pobj for ub.wth-pobj .
      for each buf_wth-pobj no-lock
        where buf_wth-pobj.obj-type   = v-obj-type
          and buf_wth-pobj.obj-code   = v-obj-code
          and buf_wth-pobj.wth-code    = v-wth-code
      on error undo, return error return-value
      :
        if buf_wth-pobj.incass-bank-pl <> 0
        or buf_wth-pobj.incass-other-pl <> 0
        or buf_wth-pobj.incass-cassa-pl <> 0
        or buf_wth-pobj.incass-pl <> 0
        or buf_wth-pobj.income-cassa-pl <> 0
        or buf_wth-pobj.income-other-pl <> 0
        or buf_wth-pobj.income-pl <> 0
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при создании МЦ на объекте" skip
            "Уже существует МЦ на МХ объекта с ненулевыми суммами" skip
            "Объект"  v-obj-type v-obj-code skip
            "Код МЦ" v-wth-code skip
            "Код МХ" buf_wth-pobj.w-p-code skip
            "Сумма инкассировано в банк" buf_wth-pobj.incass-bank-pl SKIP
            "Сумма возврата по кассе" buf_wth-pobj.incass-cassa-pl SKIP
            "Сумма других расходов" buf_wth-pobj.incass-other-pl SKIP
            "Сумма расходов всего" buf_wth-pobj.incass-pl SKIP
            "Сумма выручки" buf_wth-pobj.income-cassa-pl
            "Сумма других приходов" buf_wth-pobj.income-other-pl
            "Сумма приходов всего" buf_wth-pobj.income-pl
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
    end.
  end.

end procedure. /* wthobjcr */


procedure wthpobjc :
  define input parameter  v-obj-type  like ub.wth-pobj.obj-type  no-undo .
  define input parameter  v-obj-code  like ub.wth-pobj.obj-code  no-undo .
  define input parameter  v-wth-code  like ub.wth-pobj.wth-code  no-undo .
  define input parameter  v-w-p-code  like ub.wth-pobj.wth-code  no-undo .
  define parameter buffer buf_wth-pobj for ub.wth-pobj .

  define variable vss-description as character no-undo initial "wthpobjc-01: поиск/cоздание записи о МЦ на МХ объекта".

  define buffer buf_wealth for ub.wealth .
  define buffer buf_wth-place for ub.wth-place .
  define buffer buf_wth-obj for ub.wth-obj .

  find first buf_wth-pobj no-lock
    where buf_wth-pobj.obj-type  = v-obj-type
      and buf_wth-pobj.obj-code  = v-obj-code
      and buf_wth-pobj.wth-code  = v-wth-code
      and buf_wth-pobj.w-p-code  = v-w-p-code
    no-error .
  if not available buf_wth-pobj
  then do:
    do transaction
    on error undo, return error return-value
    :
      find first buf_wealth share-lock
        where buf_wealth.wth-code = v-wth-code
        no-error .

      if not available buf_wealth
      then do:
        message
          "МЦ" v-wth-code "не найдена."
          view-as alert-box .
        undo, return error return-value .
      end.

      find first buf_wth-place share-lock
        where buf_wth-place.w-p-code = v-w-p-code
          AND buf_wth-place.obj-type = v-obj-type
          AND buf_wth-place.obj-code = v-obj-code
        no-error .

      if not available buf_wth-place
      then do:
        message
          "МХ" v-w-p-code
          "объект" v-obj-type v-obj-code
          "не найдено."
          view-as alert-box .
        undo, return error return-value .
      end.

      create buf_wth-pobj.
      assign
        buf_wth-pobj.obj-type     = v-obj-type
        buf_wth-pobj.obj-code     = v-obj-code
        buf_wth-pobj.wth-code     = v-wth-code
        buf_wth-pobj.w-p-code     = v-w-p-code
      .

      /* прописываем host-code */

      { gbl/hostcode.i
        v-obj-type
        v-obj-code
        buf_wth-pobj.host-code
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении кода фирмы для объекта" skip
          "v-obj-type" v-obj-type skip
          "v-obj-code" v-obj-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.

end procedure. /* wthpobjc */


procedure wthcheck :
  /* Проверка целостности МЦ

    1. суммы по МХ в сумме должны давать суммы МЦ по объекте

  p-mode
    ""         при обнаружении нецелостной МЦ выдается сообщение на экран
              возвращается ошибка
    "return"   при обнаружении нецелостной МЦ
              возвращается ошибка и текстовая строка с описанием проблемы

  */

  define input parameter p-obj-type  like ub.wth-obj.obj-type  no-undo .
  define input parameter p-obj-code  like ub.wth-obj.obj-code  no-undo .
  define input parameter p-wth-code  like ub.wth-obj.wth-code  no-undo .
  define input parameter p-mode      as character              no-undo .

  define variable vss-description as character no-undo initial "wthcheck-01: Проверка целостности МЦ" .

  define buffer buf_wealth      for ub.wealth .
  define buffer buf_wth-obj     for ub.wth-obj .
  define buffer buf_wth-pobj    for ub.wth-pobj .
  define buffer buf_temp-pl-wth for temp-pl-wth .

  define variable l-bad-wth as logical /* intentionally undo */ initial true .

  define variable v-message as character no-undo .

  if  p-mode <> ""
  and p-mode <> ?
  and p-mode <> "return"
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестное значение параметра p-mode" skip
      "p-mode" p-mode skip
      view-as alert-box information.
    undo, return error return-value .
  end.


  assign
    v-message = "Объект" + " " + string(p-obj-type) + " " + string(p-obj-code) + {&new-line}
              + "МЦ" + " " + string(p-wth-code) + {&new-line}
  .


  check_block:
  do
  on error undo check_block, leave
  :
    assign
      l-bad-wth = false
    .

    find first buf_wealth no-lock
      where buf_wealth.wth-code     = p-wth-code
      no-error .
    if not available buf_wealth
    then do:
      assign
        v-message = v-message
                  + "Не найдена запись МЦ" + {&new-line}
        l-bad-wth = true
      .
      leave check_block.
    end.

    if buf_wealth.PS begins "%%%"
    then do:
      /* МЦ уже поломан - еее не надо контролировать */
      /* с тем чтобы она не мешал закрытию документов */
      return .
    end.

    find first buf_wth-obj exclusive-lock
      where buf_wth-obj.obj-type  = p-obj-type
        and buf_wth-obj.obj-code  = p-obj-code
        and buf_wth-obj.wth-code  = p-wth-code
      no-error .
    if not available buf_wth-obj
    then do:
      assign
        v-message = v-message
                  + "Не найдена запись МЦ на объекте" + {&new-line}
        l-bad-wth = true
      .
      leave check_block.
    end.

    DEFINE VARIABLE v-incass-bank  like ub.wth-obj.incass-bank  no-undo .
    DEFINE VARIABLE v-incass-other like ub.wth-obj.incass-other no-undo .
    DEFINE VARIABLE v-incass-cassa like ub.wth-obj.incass-cassa no-undo .
    DEFINE VARIABLE v-incass       like ub.wth-obj.incass       no-undo .
    DEFINE VARIABLE v-income-cassa like ub.wth-obj.income-cassa no-undo .
    DEFINE VARIABLE v-income-other like ub.wth-obj.income-other no-undo .
    DEFINE VARIABLE v-income       like ub.wth-obj.income       no-undo .

    assign
    v-incass-bank  = 0
    v-incass-other = 0
    v-incass-cassa = 0
    v-incass       = 0
    v-income-cassa = 0
    v-income-other = 0
    v-income       = 0
    .

    for each buf_wth-pobj share-lock
      where buf_wth-pobj.obj-type  = p-obj-type
        and buf_wth-pobj.obj-code  = p-obj-code
        and buf_wth-pobj.wth-code   = p-wth-code
    on error undo check_block, leave check_block
    :
      assign
      v-incass-bank  = v-incass-bank  + buf_wth-pobj.incass-bank-pl
      v-incass-other = v-incass-other + buf_wth-pobj.incass-other-pl
      v-incass-cassa = v-incass-cassa + buf_wth-pobj.incass-cassa-pl
      v-incass       = v-incass       + buf_wth-pobj.incass-pl
      v-income-cassa = v-income-cassa + buf_wth-pobj.income-cassa-pl
      v-income-other = v-income-other + buf_wth-pobj.income-other-pl
      v-income       = v-income       + buf_wth-pobj.income-pl
      .
    end.

    if
    (v-incass-bank + v-incass-other + v-incass-cassa) <> v-incass OR
    (v-income-cassa + v-income-other) <> v-income OR
    (buf_wth-obj.incass-bank + buf_wth-obj.incass-other + buf_wth-obj.incass-cassa) <> buf_wth-obj.incass OR
    (buf_wth-obj.income-cassa + buf_wth-obj.income-other) <> buf_wth-obj.income
    then do:
      assign
        v-message = v-message
                  + "Суммы по МХ не совпадают с суммами по МЦ на объекте" + {&new-line}
                  + "или не корреллируют друг с другом" + {&new-line}
                  + "По МЦ на объекте:"          +         {&new-line}
                  + "Сумма инкассировано в банк" + {&space-char} + string(buf_wth-obj.incass-bank ) + {&new-line}
                  + "Сумма возвратов по кассе"   + {&space-char} + string(buf_wth-obj.incass-cassa) + {&new-line}
                  + "Сумма других расходов"      + {&space-char} + string(buf_wth-obj.incass-other) + {&new-line}
                  + "Сумма расходов всего"       + {&space-char} + string(buf_wth-obj.incass      ) + {&new-line}
                  + "Сумма выручки"              + {&space-char} + string(buf_wth-obj.income-cassa) + {&new-line}
                  + "Сумма других приходов"      + {&space-char} + string(buf_wth-obj.income-other) + {&new-line}
                  + "Сумма приходов всего"       + {&space-char} + string(buf_wth-obj.income      ) + {&new-line}
                  + "По МХ:" + {&new-line}
                  + "Сумма инкассировано в банк" + {&space-char} + string(          v-incass-bank ) + {&new-line}
                  + "Сумма возвратов по кассе"   + {&space-char} + string(          v-incass-cassa) + {&new-line}
                  + "Сумма других расходов"      + {&space-char} + string(          v-incass-other) + {&new-line}
                  + "Сумма расходов всего"       + {&space-char} + string(          v-incass      ) + {&new-line}
                  + "Сумма выручки"              + {&space-char} + string(          v-income-cassa) + {&new-line}
                  + "Сумма других приходов"      + {&space-char} + string(          v-income-other) + {&new-line}
                  + "Сумма приходов всего"       + {&space-char} + string(          v-income      ) + {&new-line}

        l-bad-wth = true
      .
      leave check_block.
    end.
  end. /* check_block */


  if l-bad-wth
  then do:
    define variable v-return-value as character no-undo .

    if p-mode = ""
    or p-mode = ?
    then do:
      message
        vss-workfile + " " + vss-revision + " " + vss-description + {&new-line}
        v-message + {&new-line}
        view-as alert-box .
    end.

    if p-mode = "return"
    then do:
      assign
        v-return-value = v-message
      .
    end.

    undo, return error v-return-value .

  end.

end procedure. /* wthcheck */



procedure wthobjat :
 /*
  Задает/получает различные признаки МЦ на объекте

  значения p-action
  список значений действий разделенных запятыми

  exist-wth-obj=request     - существует ли wth-obj

  wth-obj.inv-on    - включена инвентаризация.
    для МЦ на объекте только один документ инвентаризации
    может имет статус
      wth-doc.status_ = {&permitted}

  inv-on=true
  inv-on=false
  inv-on=request

  */

  define input  parameter p-obj-type         like ub.wth-obj.obj-type  no-undo .
  define input  parameter p-obj-code         like ub.wth-obj.obj-code  no-undo .
  define input  parameter p-wth-code         like ub.wth-obj.wth-code  no-undo .
  define input  parameter p-action           as character no-undo .
  define output parameter p-return-attribute as logical no-undo .

  define variable vss-description as character no-undo initial "wthobjat-01: задает/получает признаки МЦ на объекте".

  define variable ind      as integer no-undo .
  define variable v-action as character no-undo .

  define variable l-find-wth-obj as logical no-undo initial false .

  define buffer buf_wth-obj for ub.wth-obj .

  define variable v-num-entries-p-action as integer no-undo .

  assign
    v-num-entries-p-action = num-entries(p-action)
  .

  do ind = 1 to v-num-entries-p-action
  :
    assign
      v-action = entry(ind, p-action)
    .

    if lookup(v-action, "inv-on=request,exist-wth-obj=request") > 0
    then do:
      find first buf_wth-obj no-lock
        where buf_wth-obj.obj-type  = p-obj-type
          and buf_wth-obj.obj-code  = p-obj-code
          and buf_wth-obj.wth-code  = p-wth-code
        no-error .
    end.
    else do:
      if l-find-wth-obj <> true
      then do:
        { gbl/wthobjcr.i
          p-obj-type
          p-obj-code
          p-wth-code
          buf_wth-obj
          no-error
        }
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно найти wth-obj" skip
            "p-obj-type"  p-obj-type  skip
            "p-obj-code"  p-obj-code  skip
            "p-wth-code"  p-wth-code  skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        assign
          l-find-wth-obj = true
        .
      end.
    end.

    case v-action :

      when "exist-wth-obj=request"
      then do:
        assign
          p-return-attribute = (available buf_wth-obj)
        .
      end.

      when "inv-on=true" or
      when "inv-on=yes"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_wth-obj exclusive-lock .

          if buf_wth-obj.inv-on <> true
          then do:
            assign
              buf_wth-obj.inv-on = true
            .
          end.
          else do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при установке признака 'МЦ находится в инвентаризации'."
              "p-obj-type"  p-obj-type  skip
              "p-obj-code"  p-obj-code  skip
              "p-wth-code"  p-wth-code  skip
              "v-action"    v-action    skip
              "p-action"    p-action    skip
              "wth-obj.inv-on" buf_wth-obj.inv-on skip
              view-as alert-box error .
            undo, return error return-value .
          end.

          assign
            p-return-attribute = buf_wth-obj.inv-on
          .
        end.
      end.

      when "inv-on=false" or
      when "inv-on=no"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_wth-obj exclusive-lock .

          if buf_wth-obj.inv-on <> false
          then do:
            assign
              buf_wth-obj.inv-on = false
            .
          end.
          else do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при сбрасывании признака 'МЦ находится в инвентаризации'."
              "p-obj-type"  p-obj-type  skip
              "p-obj-code"  p-obj-code  skip
              "p-wth-code"  p-wth-code  skip
              "v-action"    v-action    skip
              "p-action"    p-action    skip
              "wth-obj.inv-on" buf_wth-obj.inv-on skip
              view-as alert-box error .
            undo, return error return-value .
          end.

          assign
            p-return-attribute = buf_wth-obj.inv-on
          .
        end.
      end.

      when "inv-on=request"
      then do:
        if available buf_wth-obj
        then do:
          assign
            p-return-attribute = buf_wth-obj.inv-on
          .
        end.
        else do:
          assign
            p-return-attribute = false
          .
        end.
      end.

      when "inv-on=request:exclusive"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_wth-obj exclusive-lock .
          assign
            p-return-attribute = buf_wth-obj.inv-on
          .
        end.
      end.

      when "inv-on=request:share"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_wth-obj exclusive-lock .
          assign
            p-return-attribute = buf_wth-obj.inv-on
          .
        end.
      end.

      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестное значение параметра v-action " skip
          "v-action" v-action skip
          "p-action" p-action skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.

  /* раскомментируйте сообщения для отладки признакво товара на объекте */
  /*message                                       */
  /*  "p-obj-type"         p-obj-type         skip*/
  /*  "p-obj-code"         p-obj-code         skip*/
  /*  "p-wth-code"         p-wth-code         skip*/
  /*  "p-action"           p-action           skip*/
  /*  "p-return-attribute" p-return-attribute skip*/
  /*  view-as alert-box information .             */

end procedure. /* wthobjat */

procedure wthdat :

  /*
  Задает/получает различные признаки документа МЦ на объекте

  значения p-action
  список значений действий разделенных запятыми

  can-edit-inv-on=request - возвращает true или false
    имеет ли право пользователь редактировать документ при наличии
    и переходить между различными статусами документа при наличии инвентаризации
      в статусе status_ = {&permitted}

  */

  define input parameter  p-wth-doc-doc-type    like ub.wth-doc.doc-type no-undo .
  define input parameter  p-wth-doc-internal    like ub.wth-doc.exter_   no-undo .
  define input parameter  p-wth-doc-status_     like ub.wth-doc.status_  no-undo .
  define input  parameter p-action              as character no-undo .
  define output parameter p-return-attribute    as character no-undo .

  define variable vss-description as character no-undo initial "wthdat-01: Задает/получает различные признаки документа МЦ на объекте".

  define variable ind      as integer no-undo .
  define variable v-action as character no-undo .

  define variable v-num-entries-p-action as integer no-undo .

  do
  on error undo, return error return-value
  :

    assign
      v-num-entries-p-action = num-entries(p-action)
    .

    do ind = 1 to v-num-entries-p-action
    :
      assign
        v-action = entry(ind, p-action)
      .

      case v-action :
        when "can-change-status-inv-on=request"
        then do:
          if  p-wth-doc-doc-type = {&inventory}
          then do:
            assign
              p-return-attribute = "true":u
            .
            next . /* --->>>--- */
          end.

          if  p-wth-doc-doc-type = {&income}
          and p-wth-doc-internal = false
          and p-wth-doc-status_  = {&wayb}
          then do:
            assign
              p-return-attribute = "true":u
            .
            next . /* --->>>--- */
          end.

          assign
            p-return-attribute = "false":u
          .

        end.


        when "can-edit-inv-on=request":u
        then do:
          if  p-wth-doc-doc-type = {&inventory}
          and p-wth-doc-status_  = {&permitted}
         then do:
            assign
              p-return-attribute = "true":u
            .
            next . /* --->>>--- */
          end.

          if  p-wth-doc-doc-type = {&income}
          and p-wth-doc-internal = false
          and p-wth-doc-status_  = {&wayb}
          then do:
            assign
              p-return-attribute = "true":u
            .
            next . /* --->>>--- */
          end.

          assign
            p-return-attribute = "false":u
          .
        end.

        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестное значение параметра v-action " skip
            "v-action" v-action skip
            "p-action" p-action skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
    end.
  end.

end procedure. /* wthdat */


procedure emptyscl :

  define output parameter p-node-code as integer   no-undo .

  define variable vss-description as character no-undo initial "emptyscl-01: Определение корневого признака пустой шкалы".

  define buffer buf_gds-prt for ub.gds-prt .

  do
  on error undo, return error return-value
  :
    find first buf_gds-prt no-lock
      where buf_gds-prt.root = true
        and buf_gds-prt.node-name = {&empty-scale}
      no-error .
    if available buf_gds-prt
    then do:
      assign
        p-node-code = buf_gds-prt.node-code
      .
    end.
    else do:
      undo, return error substitute("&1 не найдена", {&empty-scale} ) .
    end.
  end.

end procedure. /* emptyscl */


procedure objdbnum :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define output parameter p-db-num   as integer   no-undo .

  define variable vss-description as character no-undo initial "objdbnum-01: Определить базу данных, которой принадлежит объект".

  define buffer buf_clients for ub.clients .

  do
  on error undo, return error return-value
  :
    find first buf_clients no-lock
      where buf_clients.obj-type = p-obj-type
        and buf_clients.obj-code = p-obj-code
      no-error .
    if not available buf_clients
    then do:
      undo, return error substitute( "Ошибка задания входных параметров. Не найден объект &1 &2", p-obj-type, p-obj-code) .
    end.

    assign
      p-db-num = buf_clients.db-num
    .
  end.

end procedure. /* objdbnum */


procedure grpgdsnm :

  define input  parameter p-node-code     as integer   no-undo .
  define output parameter p-full-grp-name as character no-undo .

  define variable vss-description as character no-undo initial "grpgdsnm-01: Полное имя группы для сортировки и поиска".

  define variable v-upper-code as integer   no-undo .
  define variable v-grp-name   as character no-undo .

  define buffer buf_gds-grp for ub.gds-grp .

  do
  on error undo, return error return-value
  :
    /* собираем полное имя, игнорируя корневой узел */
    find buf_gds-grp no-lock
      where buf_gds-grp.node-code = p-node-code
      no-error .
    if not available buf_gds-grp
    then do:
      undo, return error substitute("Ошибка задания входных параметров" + {&new-line}
                                   + "Не найдена группа &1", p-node-code
                                   ) .
    end.

    assign
      v-grp-name = ''
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error return-value
    :
      /* здесь совершенное сознательно сделан алгоритм образования имени группы */
      /* имя корневой группы - не включается */
      /* строка всегда оканчивается на символ разделитель */
      /* возвращаемая строка совместима с оператором begins */
      assign
        v-grp-name   = buf_gds-grp.node-name + {&delim-grp} + v-grp-name
        v-upper-code = buf_gds-grp.upper-code
      .
      find buf_gds-grp no-lock
        where buf_gds-grp.node-code = v-upper-code
        no-error .
      if not available buf_gds-grp
      then do:
        undo, return error substitute("Не найдена родительская группа для группы &1", v-upper-code
                                     ) .
      end.
    end.
    assign
      p-full-grp-name = v-grp-name
    .
  end.

end procedure. /* grpgdsnm */

procedure file-clr :

  define input  parameter p-file-name as character no-undo .

  define variable vss-description as character no-undo initial "file-clr-01: Создать новый файл нулевой длины".

  /* если файл с таким именем существует в текущей директории, */
  /* то он будет удален */
  /* затем создаётся файл в текущей директории нулевого размера */

  do
  on error undo, return error return-value
  :
    if p-file-name = ""
    or p-file-name = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не задано имя файла" skip
        "p-file-name" p-file-name skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    output stream librout to value(p-file-name) .
    output stream librout close .
  end.
end procedure. /* file-clr */


procedure file-wr :

  define input  parameter p-file-name as character no-undo .
  define input  parameter p-line      as character no-undo .

  define variable vss-description as character no-undo initial "file-wr-01: Записать строку в файл".

  do
  on error undo, return error return-value
  :
    if p-file-name = ""
    or p-file-name = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не задано имя файла" skip
        "p-file-name" p-file-name skip
        "p-line" p-line skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if p-line = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не задана строка для вывода в файл" skip
        "p-file-name" p-file-name skip
        "p-line" p-line skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    output stream librout to value(p-file-name) append.
    put stream librout unformatted p-line .
    output stream librout close .
  end.
end procedure. /* file-wr */


procedure filenmln :

  define input  parameter p-file-name  as character no-undo .
  define input  parameter p-line-count as integer   no-undo .
  define output parameter p-line-exist as logical   no-undo .

  define variable vss-description as character no-undo initial "filenmln-01: Определить наличие определенного количества строк в файле".

  define variable v-str-read as character no-undo .
  define variable v-str-ind  as integer   no-undo init 0 .

  if p-line-count = ?
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "p-line-count" p-line-count skip
      view-as alert-box error .
    undo, return error return-value .
  end.


  do
  on error undo, return error return-value
  :
    assign
      p-line-exist = false
    .

    input stream librout from value(p-file-name) .
    repeat
    :
      import stream librout unformatted v-str-read no-error .
      assign
        v-str-ind = v-str-ind + 1
      .
      if v-str-ind >= p-line-count
      then do:
        assign
          p-line-exist = true
        .
        leave.
      end.
    end.
    input stream librout close .
  end.

end procedure. /* filenmln */



procedure rsrvtype :

  /* определяет по какой схеме необходимо резервировать документ */
  define input  parameter p-doc-code  as character no-undo .
  define output parameter p-rsrv-type as character no-undo .

  define variable vss-description as character no-undo initial "rsrvtype-01: Способ резервирования документа в зависимости от типа и статуса".

  define buffer buf_trn-doc for ub.trn-doc .

  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Документ" p-doc-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    case buf_trn-doc.doc-type:
      when {&income}
      then do:
        if buf_trn-doc.internal = false
        then do:
          if  buf_trn-doc.status_  = {&wayb}
          and buf_trn-doc.flag_    = false
          then do:
            assign
              p-rsrv-type = {&rsrvtype_pri-doc}
            .
            return .
          end.
          if  buf_trn-doc.status_  = {&wayb}
          and buf_trn-doc.flag_    = true
          then do:
            assign
              p-rsrv-type = {&rsrvtype_pri-fact}
            .
            return .
          end.
        end.
        if  buf_trn-doc.internal = true
        then do:
          if  buf_trn-doc.status_  = {&wayb}
          and buf_trn-doc.flag_    = false
          then do:
            assign
              p-rsrv-type = {&rsrvtype_pri-doc}
            .
            return .
          end.
          if  buf_trn-doc.status_  = {&wayb}
          and buf_trn-doc.flag_    = true
          then do:
            assign
              p-rsrv-type = {&rsrvtype_fact}
            .
            return .
          end.
        end.
      end.

      when {&expense}   or
      when {&write-off} or
      when {&return}
      then do:
        if (buf_trn-doc.status_ = {&wayb} and buf_trn-doc.flag_ = no )
        or (buf_trn-doc.status_ = {&cash-desk} )
        then do:
          assign
            p-rsrv-type = {&rsrvtype_doc}
          .
          return .
        end.
        else do:
          if buf_trn-doc.status_ = {&permitted}
          or (buf_trn-doc.status_ = {&wayb} and buf_trn-doc.flag_ = yes and buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Object})
          then do:
            assign
              p-rsrv-type = {&rsrvtype_fact}
            .
            return .
          end.
        end.
      end.
      when {&inventory}
      then do:
        assign
          p-rsrv-type = {&rsrvtype_doc}
        .
        return .
      end.
    end case.

    undo, return error substitute("Неизвестный тип документа. Тип документа &1. Статус &2", buf_trn-doc.doc-type, buf_trn-doc.status_) .

  end.
end procedure. /* rsrvtype */


procedure curdbnum :

  define output parameter p-db-num as integer   no-undo .

  define variable vss-description as character no-undo initial "curdbnum-01: Возвращает номер текущей базы данных".

  define buffer buf_sys-ctrl for ub.sys-ctrl .

  do
  on error undo, return error return-value
  :
    find first buf_sys-ctrl no-lock no-error .
    if not available buf_sys-ctrl
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена запись sys-ctrl" skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    assign
      p-db-num = buf_sys-ctrl.db-num
    .
  end.

end procedure. /* curdbnum */


procedure usrfulnm :

  define input  parameter p-user-id   as character no-undo .
  define output parameter p-user-name as character no-undo .

  define variable vss-description as character no-undo initial "usrfulnm-01: Псевдоним пользователя".

  define buffer buf_user-account        for ub.user-account .
  define buffer buf_parent_user-account for ub.user-account .

  do
  on error undo, return error return-value
  :
    find first buf_user-account no-lock
      where buf_user-account.user-id = p-user-id
      no-error .
    if not available buf_user-account
    then do:
      assign
        p-user-name = p-user-id
      .
    end.
    else do:
      if buf_user-account.check-parent = true
      then do:
        find first buf_parent_user-account no-lock
          where buf_parent_user-account.user-id = buf_user-account.parent-user-id
          no-error .
        if not available buf_parent_user-account
        then do:
          assign
            p-user-name = p-user-id
          .
        end.
        else do:
          assign
            p-user-name = buf_user-account.nik
          .
        end.
      end.
      else do:
        assign
          p-user-name = buf_user-account.nik
        .
      end.
    end.
  end.

end procedure. /* usrfulnm */


procedure usrfuln2 :

  define input  parameter p-user-id   as character no-undo .
  define input  parameter p-db-num    as integer   no-undo .
  define output parameter p-user-name as character no-undo .

  define variable vss-description as character no-undo initial "usrfulnm-01: Имя пользователя".

  define buffer buf_user-account        for ub.user-account .
  define buffer buf_parent_user-account for ub.user-account .
  define buffer buf_user-account-attr   for ub.user-account-attr .

  do
  on error undo, return error return-value
  :
    find first buf_user-account no-lock
      where buf_user-account.user-id = p-user-id
      no-error .
    if not available buf_user-account
    then do:
      find first buf_user-account
           where buf_user-account.user-id begins SUBSTITUTE("&1-", p-db-num)
             and buf_user-account.parent-user-id   = p-user-id
             and buf_user-account.check-parent     = FALSE
           no-lock
           no-error
           .
            if available buf_user-account
            then do:
               assign
                  p-user-name = substitute('&1 &2 &3':U
                                          ,buf_user-account.last-name
                                          ,buf_user-account.first-name
                                          ,buf_user-account.second-name
                                          )
               .
            end.
            else do:
               assign
                  p-user-name = p-user-id
               .
            end.
    end.
    else do:
      if buf_user-account.check-parent = true
      then do:
        find first buf_parent_user-account no-lock
          where buf_parent_user-account.user-id = buf_user-account.parent-user-id
          no-error .
        if not available buf_parent_user-account
        then do:
          assign
            p-user-name = p-user-id
          .
        end.
        else do:
          assign
            p-user-name = substitute('&1 &2 &3':U
                                    ,buf_parent_user-account.last-name
                                    ,buf_parent_user-account.first-name
                                    ,buf_parent_user-account.second-name
                                    )
          .
        end.
      end.
      else do:
        assign
          p-user-name = substitute('&1 &2 &3':U
                                  ,buf_user-account.last-name
                                  ,buf_user-account.first-name
                                  ,buf_user-account.second-name
                                  )
        .
      end.
    end.
  end.

end procedure. /* usrfulnm */


procedure curdburt :

  define output parameter p-db-num       as integer   no-undo .
  define output parameter p-user-name    as character no-undo .
  define output parameter p-sys-date     as date      no-undo .
  define output parameter p-sys-time     as character no-undo .
  define output parameter p-sys-time-int as integer   no-undo .

  define variable vss-description as character no-undo initial "curdburt-01: Возвращает текущий номер базы данных, пользователя, дату, время и количество секунд".

  do
  on error undo, return error return-value
  :
    { gbl/getcurus.i
      p-db-num
      p-user-name
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении текущего номера базы данных и пользователя" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run cur-time in this-procedure
      (output p-sys-date
      ,output p-sys-time-int
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении текущего номера базы данных" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    assign
      p-sys-time = string(p-sys-time-int, 'HH:MM:SS':u)
    .
  end.

end procedure. /* curdburt */


procedure proridoc :

  define input  parameter p-in-code        as character no-undo .
  define input  parameter p-gds-code       as integer   no-undo .
  define input  parameter p-part-code      as character no-undo .
  define output parameter p-orig-in-code   as character no-undo .
  define output parameter p-orig-gds-code  as integer   no-undo .
  define output parameter p-orig-part-code as character no-undo .

  define variable vss-description as character no-undo initial "proridoc-01: Возвращает первичный приход партии".

  define buffer buf_parts-root for ub.parts-root .

  do
  on error undo, return error return-value
  :

    define variable v-in-code   as character no-undo .
    define variable v-gds-code  as integer   no-undo .
    define variable v-part-code as character no-undo .

    assign
      v-in-code   = p-in-code
      v-gds-code  = p-gds-code
      v-part-code = p-part-code
    .

    find first buf_parts-root no-lock
      where buf_parts-root.in-code   = v-in-code
        and buf_parts-root.gds-code  = v-gds-code
        and buf_parts-root.part-code = v-part-code
      no-error .
    do while available buf_parts-root
    :
      assign
        v-in-code   = buf_parts-root.orig-in-code
        v-gds-code  = buf_parts-root.orig-gds-code
        v-part-code = buf_parts-root.orig-part-code
      .
      find first buf_parts-root no-lock
        where buf_parts-root.in-code   = v-in-code
          and buf_parts-root.gds-code  = v-gds-code
          and buf_parts-root.part-code = v-part-code
        no-error .
    end.

    assign
      p-orig-in-code   = v-in-code
      p-orig-gds-code  = v-gds-code
      p-orig-part-code = v-part-code
    .
  end.

end procedure. /* proridoc */


procedure pargocod :

  define input  parameter p-parts-recid as recid     no-undo .
  define output parameter p-gds-code    as integer   no-undo .

  define variable vss-description as character no-undo initial "pargocod-01: Возвращает код товара для партии".

  define buffer buf_parts for ub.parts .
  define buffer buf_goods for ub.goods .

  do
  on error undo, return error return-value
  :

    find first buf_parts no-lock
      where recid(buf_parts) = p-parts-recid
      no-error .
    if not available buf_parts
    then do:
      undo, return error substitute("Ошибка задания входных параметров. Не найдена партия с кодом &1", p-parts-recid).
    end.

    find first buf_goods no-lock
      where buf_goods.artic     = buf_parts.artic
        and buf_goods.prod-type = buf_parts.prod-type
        and buf_goods.prod-code = buf_parts.prod-code
      no-error .
    if not available buf_goods
    then do:
      undo, return error substitute("Не найден товар. Указатель партии &1. Артикул &2 &3 &4.", p-parts-recid, buf_parts.artic, buf_parts.prod-type, buf_parts.prod-code) .
    end.

    assign
      p-gds-code = buf_goods.gds-code
    .
  end.

end procedure. /* pargocod */


procedure doclicod :

  define input  parameter p-doc-line-recid as recid     no-undo .
  define output parameter p-gds-code       as integer   no-undo .

  define variable vss-description as character no-undo initial "doclicod-01: Возвращает код товара для строки документа".

  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_goods for ub.goods .

  do
  on error undo, return error return-value
  :

    find first buf_doc-line no-lock
      where recid(buf_doc-line) = p-doc-line-recid
      no-error .
    if not available buf_doc-line
    then do:
      undo, return error substitute("Ошибка задания входных параметров. Не найдена строка документа с указателем &1", p-doc-line-recid) .
    end.

    find first buf_goods no-lock
      where buf_goods.artic     = buf_doc-line.artic
        and buf_goods.prod-type = buf_doc-line.prod-type
        and buf_goods.prod-code = buf_doc-line.prod-code
      no-error .
    if not available buf_goods
    then do:
      undo, return error substitute("Не найден товар. Указатель строки &1. Артикул &2 &3 &4",p-doc-line-recid,buf_doc-line.artic,buf_doc-line.prod-type,buf_doc-line.prod-code).
    end.

    assign
      p-gds-code = buf_goods.gds-code
    .
  end.

end procedure. /* pargocod */


procedure tblnmusr :

  define input  parameter p-table-name as character no-undo .
  define output parameter p-user-name  as character no-undo .

  define variable vss-description as character no-undo initial "tblnmusr-01: Возвращает пользовательское имя таблицы".

  do
  on error undo, return error return-value
  :
    case p-table-name
    :
      when {&table_trn-doc}
      then do:
        assign
          p-user-name = 'Накладная'
        .
      end.
      when {&table_price-doc}
      then do:
        assign
          p-user-name = 'Переоценка'
        .
      end.
      when {&table_wth-doc}
      then do:
        assign
          p-user-name = 'Документ МЦ'
        .
      end.
      when {&table_inkas}
      then do:
        assign
          p-user-name = 'Продажа'
        .
      end.
      when {&table_fbr-doc}
      then do:
        assign
          p-user-name = 'Производство'
        .
      end.
      when {&table_fbr-pln}
      then do:
        assign
          p-user-name = 'План-меню'
        .
      end.
      when {&table_chk-doc}
      then do:
        assign
          p-user-name = 'Чек'
        .
      end.
      when {&table_goods}
      then do:
        assign
          p-user-name = 'Товар'
        .
      end.
      when {&table_place}
      then do:
        assign
          p-user-name = 'Складское место'
        .
      end.
      when {&table_rvs-doc}
      then do:
        assign
          p-user-name = 'Сверка'
        .
      end.
      when {&table_icnt-doc}
      then do:
        assign
          p-user-name = 'Док.сч.ТРК'
        .
      end.
      when {&table_ord-doc}
      then do:
        assign
          p-user-name = 'Заказ'
        .
      end.
      when {&table_ord-doc-rcv}
      then do:
        assign
          p-user-name = 'Поставка'
        .
      end.
      when {&table_ord-cons}
      then do:
        assign
          p-user-name = 'СЗФП'
        .
      end.
      when {&table_c-usr-hist}
      then do:
        assign
          p-user-name = 'История пользователя'
        .
      end.
      when {&table_cash-pay}
      then do:
        assign
          p-user-name = 'Тип кассовых платежей'
        .
      end.
      when {&table_pay-type}
      then do:
        assign
          p-user-name = 'Вид оплаты'
        .
      end.
      when {&table_cli-grp}
      then do:
        assign
          p-user-name = 'Группа клиентов'
        .
      end.
      when {&table_clients}
      then do:
        assign
          p-user-name = 'Клиенты'
        .
      end.
      when {&table_config}
      then do:
        assign
          p-user-name = 'Конфигурация'
        .
      end.      
      when {&table_dis-card}
      then do:
        assign
          p-user-name = 'Дисконтная карта'
        .
      end.      
      when {&table_dis-card-type}
      then do:
        assign
          p-user-name = 'Тип дисконтной карты'
        .
      end.      
      when {&table_fin-bank}
      then do:
        assign
          p-user-name = 'Банк'
        .
      end.    
      when {&table_gds-grp}
      then do:
        assign
          p-user-name = 'Группа товаров'
        .
      end.  
      when {&table_units}
      then do:
        assign
          p-user-name = 'Единица измерения'
        .
      end.      
      when {&table_auto-tank}
      then do:
        assign
          p-user-name = 'Транспорт'
        .
      end.       
      when {&table_sr-izmerenia}
      then do:
        assign
          p-user-name = 'Средство измерения'
        .
      end.
      when {&table_action-role}
      then do:
        assign
          p-user-name = 'Группа прав'
        .
      end.    
      when {&table_action-role-item}
      then do:
        assign
          p-user-name = 'Группа прав пункты'
        .
      end.    
      when {&table_pl-gds}
      then do:
        assign
          p-user-name = 'Товар на скл.месте'
        .
      end.    
      when {&table_pl-gds-pump}
      then do:
        assign
          p-user-name = 'Контейнер через товар'
        .
      end.     
      when {&table_price-doc-forming}
      then do:
        assign
          p-user-name = 'Документ формир.цены'
        .
      end.                
      when {&table_c-sht-hist} or when "sht-hist"
      then do:
        assign
          p-user-name = 'История смены'
        .
      end.                
      when {&table_cash-desk}
      then do:
        assign
          p-user-name = 'Касса'
        .
      end.             
      when {&table_thbj-attr}
      then do:
        assign
          p-user-name = 'Конфигурационные атрибуты'
        .
      end.       
      when {&table_staff}
      then do:
        assign
          p-user-name = 'Персонал'
        .
      end.   
      when {&table_pl-level}
      then do:
        assign
          p-user-name = 'Градуир. таблица'
        .
      end.
      when {&table_c-plc-hist}
      THEN do:
          assign
          p-user-name = "Хранения тов. на скл. месте"
          .
      end.    
      when {&table_pl-pump}
      THEN do:
          assign
          p-user-name = "Склад.место ТРК"
          .
      end.         
      when {&table_pl-pump-nozzle}
      THEN do:
          assign
          p-user-name = "Соотв. пистолета и ТРК"
          .
      end.  
      when {&table_shift-obj}
      THEN do:
          assign
          p-user-name = "Смены"
          .
      end.       
      when "report"
      THEN do:
          assign
          p-user-name = "Отчеты"
          .
      end.
      when "utl"
      THEN do:
          assign
          p-user-name = "Утилиты"
          .
      end.    
      when "printdoc"
      THEN do:
          assign
          p-user-name = "Печать"
          .
      end.
      otherwise do:
        assign
          p-user-name = p-table-name
        .
      end.
    end.
  end.

end procedure. /* tblnmusr */


procedure tblusrnm :

  define input  parameter p-user-name  as character no-undo .
  define output parameter p-table-name as character no-undo .

  define variable vss-description as character no-undo initial "tblusrnm-01: возвращает имя таблицы по пользовательскому имени таблицы".

  do
  on error undo, return error return-value
  :
    case p-user-name
    :
      when 'Накладная'
      then do:
        assign
          p-table-name = {&table_trn-doc}
        .
      end.
      when 'Переоценка'
      then do:
        assign
          p-table-name = {&table_price-doc}
        .
      end.
      when 'Документ МЦ'
      then do:
        assign
          p-table-name = {&table_wth-doc}
        .
      end.
      when 'Продажа'
      then do:
        assign
          p-table-name = {&table_inkas}
        .
      end.
      when 'Производство'
      then do:
        assign
          p-table-name = {&table_fbr-doc}
        .
      end.
      when 'План-меню'
      then do:
        assign
          p-table-name = {&table_fbr-pln}
        .
      end.
      when 'Сверка'
      then do:
        assign
          p-table-name = {&table_rvs-doc}
        .
      end.
      when 'Док.сч.ТРК'
      then do:
        assign
          p-table-name = {&table_icnt-doc}
        .
      end.
      when 'Заказ'
      then do:
        assign
          p-table-name = {&table_ord-doc}
        .
      end.
      when 'Поставка'
      then do:
        assign
          p-table-name = {&table_ord-doc-rcv}
        .
      end.
      when 'СЗФП'
      then do:
        assign
          p-table-name = {&table_ord-cons}
        .
      end.
      otherwise do:
        assign
          p-table-name = p-user-name
        .
      end.
    end.
  end.


end procedure. /* tblusrnm */


procedure partcond :

  define input  parameter p-ext-doc-type    as character no-undo .
  define input  parameter p-is-hold         as logical   no-undo .
  define input  parameter p-parts-fact-qnty as decimal   no-undo .
  define input  parameter p-create-part     as logical   no-undo .
  define input  parameter p-old-return      as logical   no-undo .
  define output parameter p-rsrv-code       as character no-undo .
  define output parameter p-unrv-code       as character no-undo .
  define output parameter p-need-rsrv       as logical   no-undo .
  define output parameter p-need-unrv       as logical   no-undo .
  define output parameter p-rsrv-sign       as integer   no-undo .
  define output parameter p-unrv-sign       as integer   no-undo .

  define variable vss-description as character no-undo init "partcond-01: определяет каким образом обрабатывать партии документа".

  /*
  Определяет каким образом обрабатывать партию в документах
  Из какой зоны ее надо резервировать, и в какую зону она отправляется при закрытии документа

  */

  do
  on error undo, return error return-value
  :
    assign
      p-rsrv-sign = -1
      p-unrv-sign = 1
    .

    case p-ext-doc-type :
      when {&TDEDT_Pri_Vnesh}
      then do:
        assign
          p-rsrv-code = {&free-code}
          p-unrv-code = {&output-code}
          p-need-rsrv = true
          p-need-unrv = false
        .
      end.
      when {&TDEDT_Ras_Vnesh}
      then do:
        assign
          p-rsrv-code = {&output-code}
          p-unrv-code = {&free-code}
          p-need-rsrv = true
          p-need-unrv = true
        .

        /* для документа межфирменного внешнего расхода партии в расходной зоне не создаются */
        /* их не надо удалять */

        /*if p-is-hold = true
        then do:
          assign
            p-need-rsrv = false
          .
        end.
        */
      end.
      when {&TDEDT_Ras_Vnesh_VP}
      then do:
        assign
          p-rsrv-code = {&output-code}
          p-unrv-code = {&free-code}
          p-need-rsrv = false
          p-need-unrv = true
        .
      end.
      when {&TDEDT_Ras_Vnesh_Kass}
      then do:
        assign
          p-rsrv-code = {&output-code}
          p-unrv-code = {&free-code}
          p-need-rsrv = true
          p-need-unrv = true
        .
      end.
      when {&TDEDT_Vozvrat_Vnesh}
      then do:
        assign
          p-rsrv-code = {&free-code}
          p-unrv-code = {&output-code}
          p-need-rsrv = true
          p-need-unrv = true
        .
        if ( p-create-part = true
             and
             p-old-return  = true
           )
        or p-is-hold = true
        then do:
          assign
            p-need-unrv = false
          .
        end.
      end.
      when {&TDEDT_Vozvrat_Vnesh_Kass}
      then do:
        assign
          p-rsrv-code = {&free-code}
          p-unrv-code = {&output-code}
          p-need-rsrv = true
          p-need-unrv = true
        .
        if  p-create-part = true
        and p-old-return  = true
        then do:
          assign
            p-need-unrv = false
          .
        end.
      end.
      when {&TDEDT_Spi_Vnesh}
      then do:
        assign
          p-rsrv-code = {&output-code}
          p-unrv-code = {&free-code}
          p-need-rsrv = true
          p-need-unrv = true
        .
      end.
      when {&TDEDT_Inv}              or
      when {&TDEDT_Corr_Minus_Parts} or
      when {&TDEDT_Peresort}         then do:
        if p-parts-fact-qnty >= 0
        then do:
          assign
            p-rsrv-code = {&free-code}
            p-unrv-code = {&output-code}
            p-need-rsrv = true
            p-need-unrv = true
          .
          if  p-create-part = true
          and p-old-return  = true
          then do:
            assign
              p-need-unrv = false
            .
          end.
        end.
        else do:
          assign
            p-rsrv-sign = 1
            p-unrv-sign = -1
          .
          assign
            p-rsrv-code = {&output-code}
            p-unrv-code = {&free-code}
            p-need-rsrv = true
            p-need-unrv = true
          .
        end.
      end.
      when {&TDEDT_Corr_Acc_Price} or
      when {&TDEDT_Chg_Purch_Code}
      then do:
        if p-parts-fact-qnty >= 0
        then do:
          assign
            p-rsrv-code = {&free-code}
            p-unrv-code = {&output-code}
            p-need-rsrv = true
            p-need-unrv = false
          .
        end.
        else do:
          assign
            p-rsrv-sign = 1
            p-unrv-sign = -1
          .
          assign
            p-rsrv-code = {&output-code}
            p-unrv-code = {&free-code}
            p-need-rsrv = false
            p-need-unrv = true
          .
        end.
      end.
      when {&TDEDT_Pri_Perem}
      then do:
        assign
          p-rsrv-code = {&free-code}
          p-unrv-code = {&output-code}
          p-need-rsrv = true
          p-need-unrv = false
        .
      end.
      when {&TDEDT_Ras_Perem}
      then do:
        assign
        /*
          p-rsrv-code = {&output-code}
          p-unrv-code = {&free-code}
          p-need-rsrv = false
          p-need-unrv = true
        */
          p-rsrv-code = {&output-code}
          p-unrv-code = {&free-code}
          p-need-rsrv = true
          p-need-unrv = true

        .
      end.
      when {&TDEDT_Pri_Object}
      then do:
        assign
          p-rsrv-code = {&free-code}
          p-unrv-code = {&output-code}
          p-need-rsrv = true
          p-need-unrv = false
        .
      end.
      when {&TDEDT_Ras_Object}
      then do:
        assign
          p-rsrv-code = {&output-code}
          p-unrv-code = {&free-code}
          p-need-rsrv = true
          p-need-unrv = true
        .
      end.
      when {&TDEDT_Vozvrat_Perem}
      then do:
        assign
          p-rsrv-code = {&free-code}
          p-unrv-code = {&output-code}
          p-need-rsrv = true
          p-need-unrv = true
        .
      end.
      when {&TDEDT_Ras_Prvo} or
      when {&TDEDT_Spi_Prvo}
      then do:
        assign
          p-rsrv-code = {&output-code}
          p-unrv-code = {&free-code}
          p-need-rsrv = true
          p-need-unrv = true
        .
      end.
      when {&TDEDT_Pri_Prvo}
      then do:
        assign
          p-rsrv-code = {&free-code}
          p-unrv-code = {&output-code}
          p-need-rsrv = true
          p-need-unrv = false
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестный тип документа" skip
          "Тип документа" p-ext-doc-type skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .

    if p-rsrv-code = p-unrv-code
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Внутренняя ошибка" skip
        "p-rsrv-code" p-rsrv-code skip
        "p-unrv-code" p-unrv-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.

end procedure. /* partcond */


procedure partparm :

  define input  parameter p-parts-recid as recid     no-undo .
  define output parameter p-create-part as logical   no-undo .
  define output parameter p-old-return  as logical   no-undo .
  define output parameter p-create-obj  as logical   no-undo .

  define variable vss-description as character no-undo init "partparm-01: определяет тип партии".

  /*

  Определяет тип партии - порожденная это партия или нет
  .является ли она партией старого возврата

  p-create-part - партия порождена непосредственно в этом документе
  p-old-return  - партия порождена непосредственно в этом документе
                  и является партией старого возврата
  p-create-obj  - партия является порожденной на данном объекте
                  этим или любым другим документом
                  и не является партией старого возврата

  */

  define buffer buf_parts for ub.parts .

  do
  on error undo, return error return-value
  :
    find first buf_parts no-lock
      where recid(buf_parts) = p-parts-recid
      no-error .
    if not available buf_parts
    then do:
      undo, return error substitute("Не найдена партия с кодом &1", p-parts-recid) .
    end.

    if  buf_parts.supp-type = buf_parts.obj-type
    and buf_parts.supp-code = buf_parts.obj-code
    then do:
      /* партия была порождена на этом объекте */
      assign
        p-create-obj = true
      .
    end.
    else do:
      assign
        p-create-obj = false
      .
    end.

    assign
      p-old-return = false
    .

    if buf_parts.in-code = buf_parts.out-code
    then do:
      assign
        p-create-part = true
      .
      if p-create-obj = true
      then do:
        /* партия является порожденной  на данном объекте */
        assign
          p-old-return = false
        .
      end.
      else do:
        /* партия является партией старого возврата */
        assign
          p-old-return = true
        .
      end.
    end.
    else do:
      assign
        p-create-part = false
      .
    end.
  end.

end procedure. /* partparm */


procedure hold-doc :

  define input  parameter pardoc-code as character no-undo .
  define output parameter paris-hold  as logical   no-undo .

  define buffer buf_trn-doc for ub.trn-doc.

  define variable vss-description as character no-undo init "hold-doc-01: определяет тип документа - холдинговый или нет".

  do
  for buf_trn-doc
  on error undo, return error substitute ("&1 &2", return-value, error-status:get-message(1))
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = pardoc-code
      no-error .
    if not available buf_trn-doc
    then do:
      undo, return error substitute ("Не найден документ с номером &1.", pardoc-code).
    end.
    if  ( buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
          or buf_trn-doc.ext-doc-type = {&TDEDt_Ras_Vnesh}
          or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
          or buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}
        )
    and ( ( buf_trn-doc.hold-doc-code-child  <> ""
            and buf_trn-doc.hold-doc-code-child  <> "no-hold":u
          )
          or
          ( buf_trn-doc.hold-doc-code-parent <> ""
            and buf_trn-doc.hold-doc-code-parent <> "no-hold":u
          )
        )
    then do:
      assign
        paris-hold = yes
      .
    end.
    else do:
      assign
        paris-hold = no
      .
    end.
  end.

end procedure. /* hold-doc */


procedure docextnm :

  define input  parameter p-doc-code as character no-undo .
  define output parameter p-ext-name as character no-undo .

  define variable vss-description as character no-undo init "docextnm-01: определяет короткое имя документа для показа в интерфейсах".

  define variable v-is-hold as logical   no-undo .

  define buffer buf_trn-doc for ub.trn-doc .

  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if available buf_trn-doc
    then do:
      { gbl/hold-doc.i
        p-doc-code
        v-is-hold
      }
      case buf_trn-doc.ext-doc-type
      :
        when {&TDEDT_Pri_Vnesh}
        then do:
          if v-is-hold = false
          then do:
            assign
              p-ext-name = "ПН"
            .
          end.
          else do:
            assign
              p-ext-name = "ПФ"
            .
          end.
        end.
        when {&TDEDT_Ras_Vnesh}
        then do:
          if v-is-hold = false
          then do:
            assign
              p-ext-name = "РН"
            .
          end.
          else do:
            assign
              p-ext-name = "РФ"
            .
          end.
        end.
        when {&TDEDT_Ras_Vnesh_VP}
        then do:
          if v-is-hold = false
          then do:
            assign
              p-ext-name = "РЩ"
            .
          end.
          else do:
            assign
              p-ext-name = "РЖ"
            .
          end.
        end.
        when {&TDEDT_Ras_Vnesh_Kass}
        then do:
          assign
            p-ext-name = "РК"
          .
        end.
        when {&TDEDT_Vozvrat_Vnesh}
        then do:
          if v-is-hold = false
          then do:
            assign
              p-ext-name = "ВН"
            .
          end.
          else do:
            assign
              p-ext-name = "ВФ"
            .
          end.
        end.
        when {&TDEDT_Vozvrat_Vnesh_Kass}
        then do:
          assign
            p-ext-name = "ВК"
          .
        end.
        when {&TDEDT_Spi_Vnesh}
        then do:
          assign
            p-ext-name = "СН"
          .
        end.
        when {&TDEDT_Inv}
        then do:
          assign
            p-ext-name = "ИН"
          .
        end.
        when {&TDEDT_Peresort}
        then do:
          assign
            p-ext-name = "ПС"
          .
        end.
        when {&TDEDT_Pri_Perem}
        then do:
          assign
            p-ext-name = "ПВ"
          .
        end.
        when {&TDEDT_Ras_Perem}
        then do:
          assign
            p-ext-name = "РВ"
          .
        end.
        when {&TDEDT_Pri_Object}
        then do:
          assign
            p-ext-name = "ПО"
          .
        end.
        when {&TDEDT_Ras_Object}
        then do:
          assign
            p-ext-name = "РО"
          .
        end.
        when {&TDEDT_Vozvrat_Perem}
        then do:
          assign
            p-ext-name = "ВВ"
          .
        end.
        when {&TDEDT_Ras_Prvo}
        then do:
          assign
            p-ext-name = "РП"
          .
        end.
        when {&TDEDT_Spi_Prvo}
        then do:
          assign
            p-ext-name = "СП"
          .
        end.
        when {&TDEDT_Pri_Prvo}
        then do:
          assign
            p-ext-name = "ПП"
          .
        end.
        when {&TDEDT_Corr_Acc_Price}
        then do:
          assign
            p-ext-name = "ИЦ"
          .
        end.
        when {&TDEDT_Corr_Minus_Parts}
        then do:
          assign
            p-ext-name = "ИМ"
          .
        end.
        when {&TDEDT_Chg_Purch_Code}
        then do:
          assign
            p-ext-name = "ИТ"
          .
        end.
        otherwise do:
          assign
            p-ext-name = buf_trn-doc.ext-doc-type
          .
        end.
      end case .
    end.
    else do:
      assign
        p-ext-name = "??"
      .
    end.
  end.

end procedure. /* docextnm */


procedure fgdsobjt :
 /*
  Задает/получает различные признаки товара на объекте РЕСТОРАН в текстовой переменной
  - логические преобразунются к 0/1

  значения p-action
  список значений действий разделенных запятыми

  exist-fbr-gds-obj=request     - существует ли gds-obj

  fbr-gds-obj.is-menu    - является блюдом меню
  is-menu=request[:exclusive][:share]

  fbr-gds-obj.is-semifinished    - является полуфабрикатом
  is-semi-finished=request[:exclusive][:share]

  fbr-gds-obj.is-menu or fbr-gds-obj.is-semi-finished
  вообще что-то
  is-dish=request[:exclusive][:share]
  возвратит string(0)  если ни то ни другое если is-menu 2 если только is-semi-finished и 3 если и то и другое

  fbr-gds-obj.is-modificator and fbr-gds-obj.is-null-price   - является модификатором с нулевой ценой
  is-modificator-null-price=request[:exclusive][:share]

  */

  define input  parameter p-obj-type         like ub.fbr-gds-obj.obj-type  no-undo .
  define input  parameter p-obj-code         like ub.fbr-gds-obj.obj-code  no-undo .
  define input  parameter p-gds-code         like ub.fbr-gds-obj.gds-code  no-undo .
  define input  parameter p-action           as character no-undo .
  define output parameter p-return-attribute as character no-undo .

  define variable vss-description as character no-undo initial "fgdsobjt-01: задает/получает признаки товара на объекте РЕСТОРАН".

  define variable ind      as integer no-undo .
  define variable v-action as character no-undo .

  define variable l-find-fbr-gds-obj as logical no-undo initial false .

  define buffer buf_fbr-gds-obj for ub.fbr-gds-obj .

  define variable v-num-entries-p-action as integer no-undo .

  assign
    v-num-entries-p-action = num-entries(p-action)
  .

  do ind = 1 to v-num-entries-p-action
  :
    assign
      v-action = entry(ind, p-action)
    .
    if lookup(entry(1, v-action, ":":U), "is-menu=request,is-semi-finished=request,is-dish=request,is-modificator=request,is-modificator-null-price=request,exist-fbr-gds-obj=request") > 0
    then do:
      find first buf_fbr-gds-obj no-lock
        where buf_fbr-gds-obj.obj-type  = p-obj-type
          and buf_fbr-gds-obj.obj-code  = p-obj-code
          and buf_fbr-gds-obj.gds-code  = p-gds-code
        no-error .
    end.
    if not available buf_fbr-gds-obj then return string(0).
    if num-entries(v-action, ":":U) > 1
    then do:
      if entry(2, v-action, ":":U) = "exclusive-lock":U
      then do:
        find current buf_fbr-gds-obj exclusive-lock .
      end.
      if entry(2, v-action, ":":U) = "share":U
      then do:
        find current buf_fbr-gds-obj share-lock .
      end.
    end.
    case entry(1, v-action, "=request":U) :
      when "exist-fbr-gds-obj":U
      then do:
        assign
        p-return-attribute = p-return-attribute + (if p-return-attribute = '':U then '':U else {&comma-char})
                             + if (available buf_fbr-gds-obj) then string(1) else string(0)
        .
      end.
      when "is-menu":U
      then do:
        assign
          p-return-attribute = p-return-attribute + (if p-return-attribute = '':U then '':U else {&comma-char})
                               + if buf_fbr-gds-obj.is-menu then string(1) else string(0)
        .
      end.
      when "is-semi-finished":U
      then do:
        assign
        p-return-attribute = p-return-attribute + (if p-return-attribute = '':U then '':U else {&comma-char})
                             + if buf_fbr-gds-obj.is-semi-finished then string(1) else string(0)
        .
      end.
      when "is-dish":U
      then do:
        assign
        p-return-attribute = p-return-attribute + (if p-return-attribute = '':U then '':U else {&comma-char})
                             + string(if buf_fbr-gds-obj.is-menu then 1 else 0 +
                                    if buf_fbr-gds-obj.is-semi-finished then 2 else 0 )
        .
      end.
      when "is-modificator-null-price":U
      then do:

        assign
        p-return-attribute = p-return-attribute + (if p-return-attribute = '':U then '':U else {&comma-char})
                             + string(if buf_fbr-gds-obj.is-modificator
                                    and buf_fbr-gds-obj.is-null-price
                                    then 1
                                    else 0)
        .
      end.
      when "is-modificator":U
      then do:

        assign
        p-return-attribute = p-return-attribute + (if p-return-attribute = '':U then '':U else {&comma-char})
                             + string(if buf_fbr-gds-obj.is-modificator
                                    then 1
                                    else 0)
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестное значение параметра v-action " skip
          "v-action" v-action skip
          "p-action" p-action skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.

end procedure. /* fgdsobjt */


procedure cntpurch :

  define input  parameter p-contract-type as character no-undo .
  define output parameter p-purch-code    as integer   no-undo .

  define variable vss-description as character no-undo initial "cntpurch-01: Определить тип приобретения по типу контракта".

  do
  on error undo, return error return-value
  :
    if p-contract-type = ""
    or p-contract-type = ?
    then do:
      undo, return error vss-description + "Не задан тип договора"
        .
    end.

    if lookup(p-contract-type, {&contract-type-list}) = 0
    then do:
      undo, return error vss-description + "Неизвестный тип договора" + {&new-line}
        + substitute("Тип договора &1", p-contract-type)
        .
    end.

    if lookup(p-contract-type, {&contr-purch-repayment}) > 0
    then do:
      assign
        p-purch-code = {&bef-repayment-code}
      .
    end.
    else do:
      if lookup(p-contract-type, {&contr-purch-consignation}) > 0
      then do:
        assign
          p-purch-code = {&bef-consignation-code}
        .
      end.
      else do:
        if lookup(p-contract-type, {&contr-purch-resp-store}) > 0
        then do:
          assign
            p-purch-code = {&bef-responsible-storage-code}
          .
        end.
        else do:
          undo, return error vss-description + "Ошибка при определении типа приобретения на основе типа договора" + {&new-line}
            + substitute("Тип договора &1", p-contract-type)
            .
        end.
      end.
    end.
  end.

end procedure. /* cntpurch */

procedure purchnam :

  define input  parameter p-purch-code as integer   no-undo .
  define output parameter p-purch-name as character no-undo .

  define variable vss-description as character no-undo initial "purchnam-01: Определить название типа приобретения по коду типа приобретения".

  define variable v-purch-code-index as integer   no-undo .

  do
  on error undo, return error return-value
  :
    assign
      v-purch-code-index = lookup(string(p-purch-code), {&purchase-codes} )
    .

    if v-purch-code-index = ?
    then do:
      undo, return error vss-description + {&new-line}
        + "Тип приобретения имеет неопределённое значение" .
    end.

    if v-purch-code-index > 0
    then do:
      assign
        p-purch-name = entry(v-purch-code-index, {&purchase-codes-full})
      .
    end.
    else do:
      undo, return error vss-description + {&new-line}
        + substitute("Неизвестный тип приобретения &1", p-purch-code) .
    end.
  end.
end procedure. /* purchnam */

procedure xmlbegin :

  define input  parameter p-file-name    as character no-undo .
  define input  parameter p-option-string as character no-undo .

  define variable vss-description as character no-undo initial "xmlbegin-01: Начать создание xml файла".

  do
  on error undo, return error return-value
  :
    output stream librout to value(p-file-name) .
    put stream librout unformatted
      substitute("<?xml version='1.0' &1?>":u, p-option-string) + {&new-line}
      + "<root>":u + {&new-line}
      .
    output stream librout close .
  end.

end procedure. /* xmlbegin */

procedure xmlend :

  define input  parameter p-file-name as character no-undo .

  define variable vss-description as character no-undo initial "xmlend-01: Завершить создание xml файла".

  do
  on error undo, return error return-value
  :
    output stream librout to value(p-file-name) append .
    put stream librout unformatted
      "</root>":u + {&new-line}
      .
    output stream librout close .

  end.

end procedure. /* xmlend */

procedure cutd-obj :
  define input  parameter p-obj-type     as character no-undo .
  define input  parameter p-obj-code     as integer   no-undo .
  define output parameter p-status       as integer   no-undo .
  define output parameter p-cut-date     as date      no-undo .
  define output parameter p-cut-fin-date as date      no-undo .

  do
  on error undo, return error substitute( "&1 (cutd-obj). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  :
    define buffer buf_clients for ub.clients .

    find first buf_clients no-lock
      where buf_clients.obj-type = p-obj-type
        and buf_clients.obj-code = p-obj-code
      no-error .
    if not available buf_clients
    then do:
      undo, return error substitute( "&1 (cutd-obj). Объект &2 &3 не найден!", vss-workfile, p-obj-type, p-obj-code ) .
    end.

    { gbl/cutd-db.i
      buf_clients.db-num
      p-status
      p-cut-date
      p-cut-fin-date
      no-error
    }
    if error-status :error
    then do:
      undo, return error substitute( "&1 (cutd-obj). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ).
    end.
  end.
  return.
end procedure. /* cutd-obj */

procedure cutd-db :
  define input  parameter p-db-num       as integer   no-undo .
  define output parameter p-status       as integer   no-undo .
  define output parameter p-cut-date     as date      no-undo .
  define output parameter p-cut-fin-date as date      no-undo .

  do
  on error undo, return error substitute( "&1 (cutd-db). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  :
    define variable v-attr-exist as logical   no-undo .
    define variable v-attr-value as character no-undo .
    define variable v-attr-type  as character no-undo .

    define buffer buf_sys-ctrl for ub.sys-ctrl .

    assign
      p-cut-date = ?
      p-status   = ?
    .

    run db-attr-exist ( input p-db-num
                       ,input {&attr-cut-date}
                       ,output v-attr-exist
                      ) no-error.
    if error-status :error
    then do:
      undo, return error substitute( "&1 (cutd-db). Ошибка при определении наличия атрибута 'дата обрезания складских документов' для БД &2 &3&4&5", vss-workfile, p-db-num, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ).
    end.

    if v-attr-exist = true then do:
      run db-attr-value ( input p-db-num
                         ,input {&attr-cut-date}
                         ,output v-attr-value
                         ,output v-attr-type
                        ) no-error.
      if error-status :error
      then do:
        undo, return error substitute( "&1 (cutd-db). Ошибка при чтении значения атрибута 'дата обрезания складских документов' для БД &2 &3&4&5", vss-workfile, p-db-num, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ).
      end.
      if v-attr-value = "":U
        or v-attr-value = ?
      then do:
        undo, return error substitute( "&1 (cutd-db). Атрибут 'дата обрезания складских документов' для БД &2 имеет некорректное значение '&3'", vss-workfile, p-db-num, v-attr-value ).
      end.
      else do:
        assign
          p-cut-date = date( v-attr-value )
        .
        run db-attr-exist ( input p-db-num
                           ,input {&attr-unload-after-cut}
                           ,output v-attr-exist
                          ) no-error.
        if error-status :error
        then do:
          undo, return error substitute( "&1 (cutd-db). Ошибка при определении наличия атрибута 'выгрузка после обрезания' для БД &2 &3&4&5", vss-workfile, p-db-num, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ).
        end.
        run db-attr-value ( input p-db-num
                           ,input {&attr-unload-after-cut}
                           ,output v-attr-value
                           ,output v-attr-type
                          ) no-error.
        if error-status :error
        then do:
          undo, return error substitute( "&1 (cutd-db). Ошибка при чтении значения атрибута 'выгрузка после обрезани ' для БД &2 &3&4&5", vss-workfile, p-db-num, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ).
        end.
        if v-attr-exist = true
          and v-attr-value = "yes":U
        then do:
          assign
            p-status = 4
          .
        end.
        else do:
          assign
            p-status = 3
          .
        end.
      end.
    end.
    else do:
      find first buf_sys-ctrl no-lock .
      if buf_sys-ctrl.cut-date <> ? then do:
        assign
          p-cut-date = buf_sys-ctrl.cut-date
          p-status   = 2
        .
      end.
      else do:
        assign
          p-cut-date = buf_sys-ctrl.cut-date
          p-status   = 1
        .
      end.
    end.

    run db-attr-exist ( input p-db-num
                      ,input {&attr-cut-fin-date}
                      ,output v-attr-exist
                      ) no-error.
    if error-status :error
    then do:
      undo, return error substitute( "&1 (cutd-db). Ошибка при определении наличия атрибута 'дата обрезания финансовых документов' для БД &2 &3&4&5", vss-workfile, p-db-num, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ).
    end.

    if v-attr-exist = true then do:
      run db-attr-value ( input p-db-num
                        ,input {&attr-cut-fin-date}
                        ,output v-attr-value
                        ,output v-attr-type
                        ) no-error.
      if error-status :error
      then do:
        undo, return error substitute( "&1 (cutd-db). Ошибка при чтении значения атрибута 'дата обрезания финансовых документов' для БД &2 &3&4&5", vss-workfile, p-db-num, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ).
      end.
      if v-attr-value = "":U
        or v-attr-value = ?
      then do:
        undo, return error substitute( "&1 (cutd-db). Атрибут 'дата обрезания финансовых документов' для БД &2 имеет некорректное значение '&3'", vss-workfile, p-db-num, v-attr-value ).
      end.
      else do:
        assign
          p-cut-fin-date = date( v-attr-value )
        .
      end.
    end.
    else do:
      assign
        p-cut-fin-date = ?
      .
    end.
  end.
  return.
end procedure. /* cutd-db */

procedure gdsobjpr :
  /* получить Свойства товара на объекте по АССОРТИМЕНТНОЙ ПОЛИТИКЕ и по заказам   */
  do
  on error undo, return error substitute( "&1 (gdsobjpr). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  :
  define input  parameter p-obj-type                    like ub.gds-obj.obj-type  no-undo .
  define input  parameter p-obj-code                    like ub.gds-obj.obj-code  no-undo .
  define input  parameter p-artic                       like ub.gds-obj.artic     no-undo .
  define input  parameter p-prod-type                   like ub.gds-obj.prod-type no-undo .
  define input  parameter p-prod-code                   like ub.gds-obj.prod-code no-undo .
  define input  parameter p-gds-code                    like ub.gds-obj.gds-code no-undo .
  define output parameter p-amin                        as logical no-undo .
  define output parameter p-izt                         as character no-undo .
  define output parameter p-gdop-min-stock              as decimal   no-undo .
  define output parameter p-grop-max-stock              as decimal   no-undo .
  define output parameter p-grop-level-always-presence  as decimal   no-undo .
  define output parameter p-grop-min-order              as decimal   no-undo .


define buffer buf_goods for  ub.goods .
define buffer buf_gds-obj-prop for  ub.gds-obj-prop .

if p-gds-code = ? or p-gds-code = 0  then do:
   find first buf_goods no-lock where
        buf_goods.artic      = p-artic     and
        buf_goods.prod-type  = p-prod-type and
        buf_goods.prod-code  = p-prod-code no-error .
        if error-status :error
        then do:
          undo, return error substitute( "Ошибка при определении товара &1 &2 &3 &4",
          p-artic   ,
          p-prod-type,
          p-prod-code ,
          error-status :get-message (1) ).
        end.
   p-gds-code = buf_goods.gds-code.
end.

find first buf_gds-obj-prop no-lock where
           buf_gds-obj-prop.gds-code = p-gds-code and
           buf_gds-obj-prop.obj-type = p-obj-type and
           buf_gds-obj-prop.obj-code = p-obj-code no-error .
           if available buf_gds-obj-prop
           then do:
              assign
                p-amin = buf_gds-obj-prop.gdop-assort-min
                p-izt  = buf_gds-obj-prop.gdop-igt
                p-gdop-min-stock               = buf_gds-obj-prop.gdop-min-stock
                p-grop-max-stock               = buf_gds-obj-prop.grop-max-stock
                p-grop-level-always-presence   = buf_gds-obj-prop.grop-level-always-presence
                p-grop-min-order               = buf_gds-obj-prop.grop-min-order
              .
           end.
           else do:
              assign
                p-amin = false
                p-izt  = {&ass-izd-empty}
                p-gdop-min-stock               = 0
                p-grop-max-stock               = 0
                p-grop-level-always-presence   = 0
                p-grop-min-order               = 0
              .
           end.
end.
end procedure. /* gdsobjpr */

procedure glstmain :
define output parameter p-main-price-list as logical   no-undo . /* yes только главные ПЛ */

define buffer buf_global-state for ub.global-state  .

  do
  on error undo, return error return-value
  :

 find first  buf_global-state no-lock no-error .
 if not available buf_global-state then create buf_global-state.
    assign
        p-main-price-list  = false
    .
if  logical(buf_global-state.db-num-chg)   = true  and   /* !!! */
    buf_global-state.pl-use-grp-buy        = false and
    buf_global-state.pl-use-oborot-buy     = false and
    buf_global-state.pl-use-qnty-group     = false and
    buf_global-state.pl-use-sum-group      = false and
    buf_global-state.pl-use-sys-date-time  = false and
    buf_global-state.pl-use-shift-date-num = false and
    buf_global-state.pl-use-cassa          = false and
    buf_global-state.pl-use-val            = false and
    buf_global-state.pl-use-pay-type       = false and
    buf_global-state.pl-use-child          = false and
    buf_global-state.pl-use-cash-pay       = false
    then do:
      p-main-price-list  = true  .
    end.
  end.

end procedure. /* glstmain */

procedure glstall :
define output parameter p-use-grp-buy          as logical   no-undo .
define output parameter p-use-oborot-buy       as logical   no-undo .
define output parameter p-use-qnty-group       as logical   no-undo .
define output parameter p-use-sum-group        as logical   no-undo .
define output parameter p-use-add-code         as logical   no-undo .
define output parameter p-use-sys-date-time    as logical   no-undo .
define output parameter p-use-shift-date-num   as logical   no-undo .
define output parameter p-use-cassa            as logical   no-undo .
define output parameter p-use-val              as logical   no-undo .
define output parameter p-use-pay-type         as logical   no-undo .
define output parameter p-use-cash-pay         as logical   no-undo .
define output parameter p-use-child            as logical   no-undo .

define buffer buf_global-state for ub.global-state  .
  do
  on error undo, return error return-value
  :

 find first  buf_global-state no-lock no-error .
 if error-status :error then do:
   return error "Не заданы Глобальные настройки ценообразования !!!".
 end.
  assign
    p-use-grp-buy          =  buf_global-state.pl-use-grp-buy
    p-use-oborot-buy       =  buf_global-state.pl-use-oborot-buy
    p-use-qnty-group       =  buf_global-state.pl-use-qnty-group
    p-use-sum-group        =  buf_global-state.pl-use-sum-group
    p-use-add-code         =  buf_global-state.pl-use-add-code
    p-use-sys-date-time    =  buf_global-state.pl-use-sys-date-time
    p-use-shift-date-num   =  buf_global-state.pl-use-shift-date-num
    p-use-cassa            =  buf_global-state.pl-use-cassa
    p-use-val              =  buf_global-state.pl-use-val
    p-use-pay-type         =  buf_global-state.pl-use-pay-type
    p-use-cash-pay         =  buf_global-state.pl-use-cash-pay
    p-use-child            =  buf_global-state.pl-use-child
  .
 end.
 end procedure. /* glstmain */


procedure proprice :
/* Получение цены производителя  по баркоду*/
define input  parameter p-b-code          as integer   no-undo .
define input  parameter p-obj-type        as character no-undo .
define input  parameter p-obj-code        as integer   no-undo .
define output parameter p-price           as decimal   no-undo .
define output parameter p-priceWithVat    as decimal   no-undo .
define output parameter p-vat-pc          as decimal   no-undo .
define output parameter p-part-code as character no-undo . /* по какой партии получен результат */
define output parameter p-in-code   as character no-undo .

define buffer buf_bar-code for ub.bar-code  .
define buffer buf_goods for ub.goods  .
define buffer buf_parts for ub.parts  .

define variable v-artic       as character no-undo .
define variable v-prod-type as character no-undo .
define variable v-prod-code as integer   no-undo .
define variable v-doc-code as character no-undo .
   do
   on error undo, return error return-value
   :

   assign
    p-price = 0
    p-priceWithVat = 0
    p-vat-pc       = 0
   .
 find first buf_bar-code no-lock where
            buf_bar-code.b-code = p-b-code no-error .
    if error-status :error then do:
      return error error-status :get-message(1) .
    end.
    { gbl/arptpc.i
      buf_bar-code.gds-code
      v-artic
      v-prod-type
      v-prod-code
    }
    find first ub.gds-obj no-lock where
      ub.gds-obj.gds-code = buf_bar-code.gds-code and
      ub.gds-obj.obj-code = p-obj-code and
      ub.gds-obj.obj-type = p-obj-type
      no-error .
    if available ub.gds-obj then do:
      v-doc-code = ub.gds-obj.in-code .
    end.

    if buf_bar-code.in-code <> "" then do:
       find first buf_parts no-lock where
                  buf_parts.in-code   = buf_bar-code.in-code  and
                  buf_parts.part-code = buf_bar-code.part-code  and
                  buf_parts.out-code  = {&free-code}  and
                  buf_parts.status_   = false   and
                  buf_parts.rsrv-free = true    and
                  buf_parts.artic     = v-artic and
                  buf_parts.prod-type = v-prod-type and
                  buf_parts.prod-code = v-prod-code  no-error .
                      if available buf_parts then do:
                         { gbl/partppric.i
                           buf_parts
                           p-price
                           p-priceWithVat
                           p-vat-pc
                         }
                         p-part-code = buf_parts.part-code.
                         p-in-code   = buf_parts.in-code  .


                      end.
                      if not available buf_parts or buf_parts.dop = "" then do:
                      find last buf_parts no-lock where
                            buf_parts.obj-type  = p-obj-type  and
                            buf_parts.obj-code  = p-obj-code  and
                            buf_parts.artic     = v-artic and
                            buf_parts.prod-type = v-prod-type and
                            buf_parts.prod-code = v-prod-code  and
                            buf_parts.out-code  = {&free-code}  and
                            buf_parts.status_   = false   and
                            buf_parts.rsrv-free = true    and
                            buf_parts.dop <> "" and
                            buf_parts.dop <> "0;0" and
                            buf_parts.dop <> "0"
                            no-error .
                            if available buf_parts then do:
                              { gbl/partppric.i
                                buf_parts
                                p-price
                                p-priceWithVat
                                p-vat-pc
                              }
                              p-part-code = buf_parts.part-code.
                              p-in-code   = buf_parts.in-code  .

                            end.
                            else do:
                              find last buf_parts no-lock where
                                    buf_parts.obj-type  = p-obj-type  and
                                    buf_parts.obj-code  = p-obj-code  and
                                    buf_parts.artic     = v-artic and
                                    buf_parts.prod-type = v-prod-type and
                                    buf_parts.prod-code = v-prod-code  and
                                    buf_parts.out-code  = {&free-code}  and
                                    buf_parts.status_   = false   and
                                    buf_parts.rsrv-free = true
                                    no-error .
                                    if not available buf_parts then do:
                                        /* последний из ПН*/

                                        find last buf_parts no-lock where
                                                  buf_parts.obj-type  = p-obj-type  and
                                                  buf_parts.obj-code  = p-obj-code  and
                                                  buf_parts.artic     = v-artic and
                                                  buf_parts.prod-type = v-prod-type and
                                                  buf_parts.prod-code = v-prod-code  and
                                                  buf_parts.out-code  = v-doc-code and
                                                  buf_parts.dop <> ""  and
                                                  buf_parts.dop <> "0;0"  and
                                                  buf_parts.dop <> "0"
                                                  no-error .
                                                      if available buf_parts then do:
                                                          { gbl/partppric.i
                                                            buf_parts
                                                            p-price
                                                            p-priceWithVat
                                                            p-vat-pc
                                                          }
                                                          p-part-code = buf_parts.part-code.
                                                          p-in-code   = buf_parts.in-code  .
                                                      end.
                                    end.
                            end.
                      end.
    end.
    else do:

    /* Может стоит брать только с последнего прихода по объекту */
       find last buf_parts no-lock where
                  buf_parts.obj-type  = p-obj-type  and
                  buf_parts.obj-code  = p-obj-code  and
                  buf_parts.artic     = v-artic and
                  buf_parts.prod-type = v-prod-type and
                  buf_parts.prod-code = v-prod-code  and
                  buf_parts.out-code  = {&free-code}  and
                  buf_parts.status_   = false   and
                  buf_parts.rsrv-free = true    and
                  buf_parts.dop <> ""  and
                  buf_parts.dop <> "0;0"  and
                  buf_parts.dop <> "0"
                  no-error .
                      if available buf_parts then do:
                          { gbl/partppric.i
                            buf_parts
                            p-price
                            p-priceWithVat
                            p-vat-pc
                          }
                         p-part-code = buf_parts.part-code.
                         p-in-code   = buf_parts.in-code  .
                      end.
                      else do:
                        find last buf_parts no-lock where
                                  buf_parts.obj-type  = p-obj-type  and
                                  buf_parts.obj-code  = p-obj-code  and
                                  buf_parts.artic     = v-artic and
                                  buf_parts.prod-type = v-prod-type and
                                  buf_parts.prod-code = v-prod-code  and
                                  buf_parts.out-code  = v-doc-code and
                                  buf_parts.dop <> ""  and
                                  buf_parts.dop <> "0;0"  and
                                  buf_parts.dop <> "0"
                                  no-error .
                                      if available buf_parts then do:
                                          { gbl/partppric.i
                                            buf_parts
                                            p-price
                                            p-priceWithVat
                                            p-vat-pc
                                          }
                                          p-part-code = buf_parts.part-code.
                                          p-in-code   = buf_parts.in-code  .
                                      end.
                      end.
    end.
   end.
end procedure. /* proprice */

procedure partppric :
define parameter buffer buf_parts for ub.parts .
define output parameter p-price           as decimal   no-undo . /* Цена без НДС */
define output parameter p-priceWithVat    as decimal   no-undo . /* Цена с   НДС */
define output parameter p-vat-pc          as decimal   no-undo .

  do
  on error undo, return error return-value
  :

   p-price        = decimal(entry(1,buf_parts.dop,";")) / buf_parts.cli-base-rate.
   p-priceWithVat = decimal(entry(2,buf_parts.dop,";")) / buf_parts.cli-base-rate no-error .
   if error-status :error then do:
      p-priceWithVat = 0 .
   end.

   if p-priceWithVat = 0 then do:
     p-vat-pc       = 0 .
   end.
   else do:
      p-vat-pc       = 100 * ( p-priceWithVat - p-price ) / p-price .
   end.


  end.

end procedure. /* partppric */

procedure calltree :
define input parameter p-proc-name as character no-undo .
define input parameter p-from-handle as handle no-undo .
define input parameter p-find-up-to-handle as handle no-undo .
define output parameter p-proc-handle as handle no-undo .

define variable v-uh as handle no-undo .
define variable v-uh1 as handle no-undo .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not valid-handle(p-from-handle) then do:
    undo, return error substitute("Не указан handle procedure, от которой начинается поиск").
  end.
  if p-from-handle:persistent then do:
    if p-proc-name <> "mainhandle_parentproc_indicator" then do:
      message
      vss-workfile vss-revision vss-description skip
      substitute("НЕ разрешено вызывать процедуру из персистентной процедуры (&1)", p-from-handle:name)
      view-as alert-box error .
      undo, return error .
    end.
    v-uh = session:first-procedure no-error .
    do while valid-handle(v-uh):
      v-uh1 = v-uh:instantiating-procedure.
      if valid-handle(v-uh1)
      and v-uh1:type = "PROCEDURE"
      and lookup(p-proc-name, v-uh1:internal-entries) > 0 then do:
        p-proc-handle = v-uh1 .
        leave.
      end.
      v-uh = v-uh:next-sibling no-error .
    end.
  end.
  v-uh = p-from-handle:instantiating-procedure.
  do while valid-handle(v-uh):
    if lookup(p-proc-name, v-uh:internal-entries) > 0 then do:
      p-proc-handle = v-uh .
      leave.
    end.
    if valid-handle(p-find-up-to-handle) and  v-uh = p-find-up-to-handle then do:
      leave.
    end.
    v-uh = v-uh:instantiating-procedure.
  end.
end.
end procedure. /* calltree */

procedure regcode :
do
on error undo, return error return-value
:
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define output parameter p-reg-code  as integer   no-undo .

  define variable vss-description as character no-undo initial "regcode-01: код региона для БД".
  define variable v-db-attr-type  as character no-undo.
/*
  if  l-last-regcode-exist = true
  and p-obj-type           = v-last-regcode-obj-type
  and p-obj-code           = v-last-regcode-obj-code
  then do:
    assign
      p-reg-code = v-last-regcode-reg-code
    .
    return . /* --->>>--- */
  end.
*/
  define buffer buf_db   for ub.db .
  
  case p-obj-type :
    when {&db}
    then do:
      find first buf_db no-lock
        where buf_db.db-num = p-obj-code
        no-error .
      if not available buf_db
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найдена БД" skip
          "p-obj-type" p-obj-type skip
          "p-obj-code" p-obj-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      run db-attr-value in this-procedure (buf_db.db-num, 
                                           "reg-code", 
                                           output p-reg-code,
                                           output v-db-attr-type) no-error.
    end.    
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Неизвестный тип объекта" skip
        "p-obj-type" p-obj-type skip
        "p-obj-code" p-obj-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.

  assign
    l-last-regcode-exist     = true
    v-last-regcode-obj-type  = p-obj-type
    v-last-regcode-obj-code  = p-obj-code
    v-last-regcode-reg-code  = p-reg-code
  .
end.
end procedure. /* regcode */

{ gbl/conf-enc.i }


/*ниже тело функции rum-runa -
Библиотечная функция для входа в машину правил в событиях изменения записи ( должна вызываться из триггеров)
*/
{ gbl/rumrunas.i }