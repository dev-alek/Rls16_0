block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обновление оборотов по поставщику

Автор: Чернова Светлана Александровна
Дата создания: 05/08/07
Author: Svetlana Chernova
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 05/27/04

*/

define input  parameter p-doc-code       as character no-undo .
define input  parameter p-trn-doc-close  as logical   no-undo .
define input  parameter p-update-supp    as logical   no-undo .
define input  parameter p-update-chk-doc as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Обновление оборотов по поставщику".
{ cmp/vssrevis.i "substitute('&1|&2':u,p-doc-code,p-trn-doc-close)" }
{ cmp/trg-def.i  }

define temp-table temp-cli-gds no-undo
  field temp-cli-type         like ub.cli-gds.cli-type
  field temp-cli-code         like ub.cli-gds.cli-code
  field temp-host-code        like ub.cli-gds.host-code
  field temp-artic            like ub.cli-gds.artic
  field temp-prod-type        like ub.cli-gds.prod-type
  field temp-prod-code        like ub.cli-gds.prod-code

  field temp-supp-qnty        like ub.cli-gds.supp-qnty
  field temp-supp-base        like ub.cli-gds.supp-base
  field temp-supp-rubl        like ub.cli-gds.supp-rubl
  field temp-in-qnty          like ub.cli-gds.in-qnty
  field temp-in-base          like ub.cli-gds.in-base
  field temp-in-rubl          like ub.cli-gds.in-rubl
  field temp-out-qnty         like ub.cli-gds.out-qnty
  field temp-out-sum          like ub.cli-gds.out-sum
  field temp-out-discnt       like ub.cli-gds.out-discnt
  field temp-ret-qnty         like ub.cli-gds.ret-qnty
  field temp-ret-sum          like ub.cli-gds.ret-sum
  field temp-ret-discnt       like ub.cli-gds.ret-discnt

  field temp-update-in-code   as logical
  field temp-in-code          like ub.cli-gds.in-code
  field temp-exch-code        like ub.cli-gds.exch-code
  field temp-price-cli        like ub.cli-gds.price-cli
  field temp-unit-cli         like ub.cli-gds.unit-cli

  index pi temp-cli-type temp-cli-code temp-host-code temp-artic temp-prod-type temp-prod-code
.

define buffer buf_trn-doc         for ub.trn-doc   .
define buffer buf_chk-doc         for ub.chk-doc   .
define buffer income_buf_trn-doc  for ub.trn-doc   .
define buffer buf_doc-line        for ub.doc-line  .
define buffer income_buf_doc-line for ub.doc-line  .
define buffer buf_gds-dtl         for ub.gds-dtl   .
define buffer buf_goods           for ub.goods     .
define buffer archive_parts       for ub.parts     .
define buffer buf_temp-cli-gds    for temp-cli-gds .
define buffer buf_cli-gds         for ub.cli-gds   .

define variable v-update-sign               as integer   no-undo .
define variable v-r-b-is-base               as logical   no-undo .
define variable v-change-qnty               as decimal   no-undo .
define variable v-change-price-base         as decimal   no-undo .
define variable v-change-price-rubl         as decimal   no-undo .
define variable v-total-qnty                as decimal   no-undo .
define variable v-total-base-total          as decimal   no-undo .
define variable v-total-rubl-total          as decimal   no-undo .
define variable v-total-gds-dtl-sum-base    as decimal   no-undo .
define variable v-total-gds-dtl-sum-rubl    as decimal   no-undo .
define variable v-total-gds-dtl-discnt-base as decimal   no-undo .
define variable v-total-gds-dtl-discnt-rubl as decimal   no-undo .
define variable v-flag                      as logical   no-undo .

do
on error undo, return error return-value
:

  find first buf_trn-doc no-lock
    where buf_trn-doc.doc-code = p-doc-code
    no-error .
  if not available buf_trn-doc
  then do:
    undo, return error substitute("&1: Не найден документ &2", vss-workfile, p-doc-code) .
  end.

  if p-update-chk-doc = true
  then do:
    for each buf_chk-doc no-lock
      where buf_chk-doc.out-code = p-doc-code
        and buf_chk-doc.d-card <> "":u
    on error undo, return error return-value
    :
      if lookup(string(buf_chk-doc.chk-type), {&no-d-card-receipt-codes}) > 0 then next.
      /* обновляем информацию на основании дисконтных карт */
      run str/trnsupds.p
        (input buf_chk-doc.doc-code /* p-doc-code      */
        ,input p-trn-doc-close      /* p-trn-doc-close */
        ) .
    end.
  end.

  if p-trn-doc-close = true
  then do:
    assign
      v-update-sign = 1
    .
  end.
  else do:
    assign
      v-update-sign = -1
    .
  end.

  { gbl/rbisbase.i
    v-r-b-is-base
  }

  for each buf_doc-line exclusive-lock
    where buf_doc-line.doc-code = buf_trn-doc.doc-code
  on error undo, return error return-value
  :
    assign
      v-total-qnty                = 0
      v-total-base-total          = 0
      v-total-rubl-total          = 0
      v-total-gds-dtl-sum-base    = 0
      v-total-gds-dtl-sum-rubl    = 0
      v-total-gds-dtl-discnt-base = 0
      v-total-gds-dtl-discnt-rubl = 0
    .

    find first buf_goods no-lock
      where buf_goods.artic     = buf_doc-line.artic
        and buf_goods.prod-type = buf_doc-line.prod-type
        and buf_goods.prod-code = buf_doc-line.prod-code
      .
    if buf_goods.gds-type = {&gds-goods}
    then do:
      run clear-temp-cli-gds in this-procedure .

      for each archive_parts share-lock
        where archive_parts.out-code  = buf_doc-line.doc-code
          and archive_parts.obj-type  = buf_doc-line.obj-type
          and archive_parts.obj-code  = buf_doc-line.obj-code
          and archive_parts.artic     = buf_doc-line.artic
          and archive_parts.prod-type = buf_doc-line.prod-type
          and archive_parts.prod-code = buf_doc-line.prod-code
      on error undo, return error return-value
      :

        /* заполняем таблицу остатков по поставщикам */
        run create-temp-cli-gds in this-procedure
          (input  archive_parts.supp-type
          ,input  archive_parts.supp-code
          ,input  buf_trn-doc.host-code
          ,input  archive_parts.artic
          ,input  archive_parts.prod-type
          ,input  archive_parts.prod-code
          ,buffer buf_temp-cli-gds
          ) .

        assign
          v-change-qnty = archive_parts.fact-qnty
        .

        if buf_trn-doc.doc-type = {&expense}
        or buf_trn-doc.doc-type = {&write-off}
        then do:
          assign
            v-change-qnty     = - v-change-qnty
          .
        end.

        assign
          v-change-price-base = archive_parts.price-base * v-change-qnty
          v-change-price-rubl = archive_parts.price-rubl * v-change-qnty
        .

        assign
          buf_temp-cli-gds.temp-supp-qnty  = buf_temp-cli-gds.temp-supp-qnty
                                           + v-change-qnty
          buf_temp-cli-gds.temp-supp-base  = buf_temp-cli-gds.temp-supp-base
                                           + v-change-price-base
          buf_temp-cli-gds.temp-supp-rubl  = buf_temp-cli-gds.temp-supp-rubl
                                           + v-change-price-rubl
        .

        assign
          v-total-qnty       = v-total-qnty
                             + archive_parts.fact-qnty
          v-total-base-total = v-total-base-total
                             + archive_parts.price-base * archive_parts.fact-qnty
          v-total-rubl-total = v-total-rubl-total
                             + archive_parts.price-rubl * archive_parts.fact-qnty
        .
      end.

      for each buf_gds-dtl share-lock
        where buf_gds-dtl.doc-code  = buf_doc-line.doc-code
          and buf_gds-dtl.artic     = buf_doc-line.artic
          and buf_gds-dtl.prod-type = buf_doc-line.prod-type
          and buf_gds-dtl.prod-code = buf_doc-line.prod-code
      on error undo, return error
      :
        /* здесь учтен тот факт, что документ инвентаризации не обрабатывается */
        /* поэтому берется значение из поля buf_gds-dtl.fact-qnty */
        /* для инвентаризации следует задать buf_gds-dtl.doc-qnty */
        assign
          v-total-gds-dtl-sum-base    = v-total-gds-dtl-sum-base
                                      + buf_gds-dtl.fact-qnty * (buf_gds-dtl.price-base - buf_gds-dtl.discnt-base)
          v-total-gds-dtl-sum-rubl    = v-total-gds-dtl-sum-rubl
                                      + buf_gds-dtl.fact-qnty * (buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl)
          v-total-gds-dtl-discnt-base = v-total-gds-dtl-discnt-base
                                      + buf_gds-dtl.fact-qnty * buf_gds-dtl.discnt-base
          v-total-gds-dtl-discnt-rubl = v-total-gds-dtl-discnt-rubl
                                      + buf_gds-dtl.fact-qnty * buf_gds-dtl.discnt-rubl
        .
      end.

      /* обновляем информацию о приходе, расходе, возврате */
      if buf_trn-doc.internal = no
      then do:
        run create-temp-cli-gds in this-procedure
          (input  buf_trn-doc.cli-type
          ,input  buf_trn-doc.cli-code
          ,input  buf_trn-doc.host-code
          ,input  buf_doc-line.artic
          ,input  buf_doc-line.prod-type
          ,input  buf_doc-line.prod-code
          ,buffer buf_temp-cli-gds
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры" 'create-temp-cli-gds':u skip
            "Клиент" buf_trn-doc.cli-type buf_trn-doc.cli-code skip
            "Фирма" buf_trn-doc.host-code skip
            "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.

        case buf_trn-doc.doc-type
        :
          when {&income}
          then do:
            if v-total-qnty <> 0
            then do:
              assign
                buf_temp-cli-gds.temp-in-qnty = v-total-qnty
                buf_temp-cli-gds.temp-in-base = v-total-base-total
                buf_temp-cli-gds.temp-in-rubl = v-total-rubl-total
              .
              if p-trn-doc-close = true
              then do:
                assign
                  buf_temp-cli-gds.temp-update-in-code = true
                  buf_temp-cli-gds.temp-in-code        = buf_trn-doc.doc-code
                  buf_temp-cli-gds.temp-exch-code      = buf_trn-doc.exch-code
                  buf_temp-cli-gds.temp-price-cli      = buf_doc-line.price-cli
                  buf_temp-cli-gds.temp-unit-cli       = buf_doc-line.unit-cli
                .
              end.
              else do:
                /* обновляем информацию о последнем приходе */
                /* после удаления документа прихода */
                /* ищем предыдущий документ прихода */
                /* по этому поставщику */
                v-flag = false .
                for each income_buf_doc-line no-lock
                  where income_buf_doc-line.obj-type     = buf_doc-line.obj-type
                    and income_buf_doc-line.obj-code     = buf_doc-line.obj-code
                    and income_buf_doc-line.artic        = buf_doc-line.artic
                    and income_buf_doc-line.prod-type    = buf_doc-line.prod-type
                    and income_buf_doc-line.prod-code    = buf_doc-line.prod-code
                    and income_buf_doc-line.status_      = {&fact}
                    and income_buf_doc-line.doc-code    <> buf_doc-line.doc-code
                ,first income_buf_trn-doc no-lock
                  where income_buf_trn-doc.doc-code = income_buf_doc-line.doc-code
                    and income_buf_trn-doc.doc-type = {&income}
                by income_buf_doc-line.fact-order descending
                on error undo, return error return-value
                :
                   if not (income_buf_trn-doc.cli-type = buf_trn-doc.cli-type and
                           income_buf_trn-doc.cli-code = buf_trn-doc.cli-code)
                   then next.
                  assign
                    buf_temp-cli-gds.temp-update-in-code = true
                    buf_temp-cli-gds.temp-in-code        = income_buf_trn-doc.doc-code
                    buf_temp-cli-gds.temp-exch-code      = income_buf_trn-doc.exch-code
                    buf_temp-cli-gds.temp-price-cli      = income_buf_doc-line.price-cli
                    buf_temp-cli-gds.temp-unit-cli       = income_buf_doc-line.unit-cli
                    v-flag = true
                  .
                  leave . /* --->>>--- */
                end.
                if v-flag = false then do:
                  assign
                    buf_temp-cli-gds.temp-update-in-code = true
                    buf_temp-cli-gds.temp-in-code        = ""
                    buf_temp-cli-gds.temp-price-cli      = 0
                    buf_temp-cli-gds.temp-unit-cli       = ?
                    buf_temp-cli-gds.temp-exch-code      = ?
                    .

                end.
              end.
            end.
          end.
          when {&expense}
          then do:
            assign
              buf_temp-cli-gds.temp-out-qnty   = v-total-qnty
            .
            if v-r-b-is-base = true
            then do:
              assign
                buf_temp-cli-gds.temp-out-sum    = v-total-gds-dtl-sum-base
                buf_temp-cli-gds.temp-out-discnt = v-total-gds-dtl-discnt-base
              .
            end.
            else do:
              assign
                buf_temp-cli-gds.temp-out-sum    = v-total-gds-dtl-sum-rubl
                buf_temp-cli-gds.temp-out-discnt = v-total-gds-dtl-discnt-rubl
              .
            end.
          end.
          when {&return}
          then do:
            assign
              buf_temp-cli-gds.temp-ret-qnty   = v-total-qnty
            .
            if v-r-b-is-base = true
            then do:
              assign
                buf_temp-cli-gds.temp-ret-sum    = v-total-gds-dtl-sum-base
                buf_temp-cli-gds.temp-ret-discnt = v-total-gds-dtl-discnt-base
              .
            end.
            else do:
              assign
                buf_temp-cli-gds.temp-ret-sum    = v-total-gds-dtl-sum-rubl
                buf_temp-cli-gds.temp-ret-discnt = v-total-gds-dtl-discnt-rubl
              .
            end.
          end.
        end case .
      end.

      for each buf_temp-cli-gds
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
          no-error
        }
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при создании записи информации остатков по клиенту" skip
            "cli-type"  buf_temp-cli-gds.temp-cli-type  skip
            "cli-code"  buf_temp-cli-gds.temp-cli-code  skip
            "host-code" buf_temp-cli-gds.temp-host-code skip
            "artic"     buf_temp-cli-gds.temp-artic     skip
            "prod-type" buf_temp-cli-gds.temp-prod-type skip
            "prod-code" buf_temp-cli-gds.temp-prod-code skip
            view-as alert-box error .
          undo, return error .
        end.

        find current buf_cli-gds exclusive-lock .

        if p-update-supp = true
        then do:
          assign
            buf_cli-gds.supp-qnty  = buf_cli-gds.supp-qnty  + buf_temp-cli-gds.temp-supp-qnty
                                                            * v-update-sign
            buf_cli-gds.supp-base  = buf_cli-gds.supp-base  + buf_temp-cli-gds.temp-supp-base
                                                            * v-update-sign
            buf_cli-gds.supp-rubl  = buf_cli-gds.supp-rubl  + buf_temp-cli-gds.temp-supp-rubl
                                                            * v-update-sign
          .
        end.

        assign
          buf_cli-gds.in-qnty    = buf_cli-gds.in-qnty    + buf_temp-cli-gds.temp-in-qnty
                                                          * v-update-sign
          buf_cli-gds.in-base    = buf_cli-gds.in-base    + buf_temp-cli-gds.temp-in-base
                                                          * v-update-sign
          buf_cli-gds.in-rubl    = buf_cli-gds.in-rubl    + buf_temp-cli-gds.temp-in-rubl
                                                          * v-update-sign
          buf_cli-gds.out-qnty   = buf_cli-gds.out-qnty   + buf_temp-cli-gds.temp-out-qnty
                                                          * v-update-sign
          buf_cli-gds.out-sum    = buf_cli-gds.out-sum    + buf_temp-cli-gds.temp-out-sum
                                                          * v-update-sign
          buf_cli-gds.out-discnt = buf_cli-gds.out-discnt + buf_temp-cli-gds.temp-out-discnt
                                                          * v-update-sign
          buf_cli-gds.ret-qnty   = buf_cli-gds.ret-qnty   + buf_temp-cli-gds.temp-ret-qnty
                                                          * v-update-sign
          buf_cli-gds.ret-sum    = buf_cli-gds.ret-sum    + buf_temp-cli-gds.temp-ret-sum
                                                          * v-update-sign
          buf_cli-gds.ret-discnt = buf_cli-gds.ret-discnt + buf_temp-cli-gds.temp-ret-discnt
                                                          * v-update-sign
        .

        if buf_temp-cli-gds.temp-update-in-code = true
        then do:
          find income_buf_trn-doc no-lock
            where income_buf_trn-doc.doc-code = buf_cli-gds.in-code
            no-error .
          if  available income_buf_trn-doc
          and income_buf_trn-doc.status_ = {&fact}
          and ( income_buf_trn-doc.fact-date > buf_trn-doc.fact-date
              or (income_buf_trn-doc.fact-date = buf_trn-doc.fact-date
                  and income_buf_trn-doc.fact-num > buf_trn-doc.fact-num
                  )
              )
          then do:
            /* ничего не делаем - уже записана информация о более позднем приходе */
          end.
          else do:
            assign
              buf_cli-gds.in-code   = buf_temp-cli-gds.temp-in-code
              buf_cli-gds.exch-code = buf_temp-cli-gds.temp-exch-code
              buf_cli-gds.price-cli = buf_temp-cli-gds.temp-price-cli
              buf_cli-gds.unit-cli  = buf_temp-cli-gds.temp-unit-cli
            .
          end.
        end.
      end.
    end.
  end.
end.



procedure clear-temp-cli-gds :

  define buffer buf_temp-cli-gds for temp-cli-gds .

  do
  on error undo, return error return-value
  :
    for each buf_temp-cli-gds
    on error undo, return error
    :
      delete buf_temp-cli-gds .
    end.

  end.

end procedure. /* clear-temp-cli-gds */


procedure create-temp-cli-gds :

  define input  parameter p-supp-type as character no-undo .
  define input  parameter p-supp-code as integer   no-undo .
  define input  parameter p-host-code as integer   no-undo .
  define input  parameter p-artic     as character no-undo .
  define input  parameter p-prod-type as character no-undo .
  define input  parameter p-prod-code as integer   no-undo .
  define parameter buffer buf_temp-cli-gds for temp-cli-gds .

  do
  on error undo, return error return-value
  :
    find first buf_temp-cli-gds
      where buf_temp-cli-gds.temp-cli-type  = p-supp-type
        and buf_temp-cli-gds.temp-cli-code  = p-supp-code
        and buf_temp-cli-gds.temp-host-code = p-host-code
        and buf_temp-cli-gds.temp-artic     = p-artic
        and buf_temp-cli-gds.temp-prod-type = p-prod-type
        and buf_temp-cli-gds.temp-prod-code = p-prod-code
      no-error .
    if not available buf_temp-cli-gds
    then do:
      create buf_temp-cli-gds .
      assign
        buf_temp-cli-gds.temp-cli-type  = p-supp-type
        buf_temp-cli-gds.temp-cli-code  = p-supp-code
        buf_temp-cli-gds.temp-host-code = p-host-code
        buf_temp-cli-gds.temp-artic     = p-artic
        buf_temp-cli-gds.temp-prod-type = p-prod-type
        buf_temp-cli-gds.temp-prod-code = p-prod-code
      .
    end.
  end.

end procedure. /* create-temp-cli-gds */