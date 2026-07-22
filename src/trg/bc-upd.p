block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Включение и выключение ДОпБК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-b-code like ub.prod-bc.b-code no-undo .
define input parameter p-b-str like ub.prod-bc.b-str no-undo .
define input parameter p-action as logical no-undo .
define input parameter p-mute as logical no-undo .
define input parameter p-send-ref as logical no-undo .
define input parameter p-same-recid as recid no-undo.
define input parameter p-write-proc-handle as handle no-undo .

/*
если задан p-same-recid то подразумевается что ДОПБК будет включаться в другой процедуре -
а здесь только выключение same
*/



define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Включение и выключение ДОпБК".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i }
{ ref/gdsoattr.i }
{ trg/new-bcod.i }
{ gbl/getcntxt.i def }

DEFINE VARIABLE loc#log as logical no-undo .
DEFINE VARIABLE var-rec as recid no-undo .
DEFINE VARIABLE l-prod-bc-global as logical no-undo .
DEFINE VARIABLE l-prod-bc-weight as logical no-undo .
DEFINE VARIABLE l-prod-bc-pgweight as logical no-undo .
DEFINE VARIABLE v-msg as character no-undo .
DEFINE VARIABLE v-main-b-code like ub.bar-code.b-code no-undo .
DEFINE VARIABLE v-db-num like ub.db.db-num no-undo .
DEFINE VARIABLE v-deleted as logical no-undo .
DEFINE VARIABLE v-attr-value as character no-undo .
DEFINE VARIABLE v-attr-type as character no-undo .
define variable dpl-off as logical no-undo .
define variable v-param-type                as character                no-undo.
define variable v-value-character           as character                no-undo.
define variable v-value-date                as date                     no-undo.
define variable v-value-decimal             as decimal                  no-undo.
define variable v-value-integer             as INTEGER                  no-undo.
define variable v-value-logical             AS LOGICAL                  no-undo.
define variable v-tth                       as handle                   no-undo.


define buffer buf_prod-bc for ub.prod-bc.
define buffer buf2_prod-bc for ub.prod-bc.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_units for ub.units.
define buffer buf_goods for ub.goods.
define buffer buf2_bar-code for ub.bar-code.
define buffer buf2_goods for ub.goods.
define buffer buf2_units for ub.units.
define buffer buf_gds-obj for ub.gds-obj.
define buffer buf_scales-gds for ub.scales-gds.
define buffer buf_gds-obj-attr for ub.gds-obj-attr.
define buffer buf_sys-ctrl for ub.sys-ctrl.
define buffer buf_clients for ub.clients.

do
on error undo, return error
:

  run get-db-num in parparentproc ( output v-cntxt-db-num).
  run get-userid in parparentproc ( output v-cntxt-userid).

  if p-same-recid = ? then do:
    find first buf_prod-bc No-LOCK where
              buf_prod-bc.b-code = p-b-code and
              buf_prod-bc.b-str = p-b-str no-error .
    if not available buf_prod-bc and p-action = no then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверные параметры вызова p-b-code/p-b-str" p-b-code p-b-str
      view-as alert-box error .
      undo, return error .
    end.
  end.
  find first buf_sys-ctrl no-lock .
  assign
  v-db-num = buf_sys-ctrl.db-num
  .
  find buf_bar-code where
      buf_bar-code.b-code = p-b-code no-lock no-error .
  find buf_units where
      buf_units.unit-name = buf_bar-code.unit-cli no-lock.
  find first buf_goods no-lock where
              buf_goods.gds-code = buf_bar-code.gds-code.
  CASE p-action:
    when no then do:
    /*выключить*/
      if buf_prod-bc.bc-on = false then do:
        assign
        v-msg = substitute("Товар: &1&2&3 код товара &4 ДопБк &5 уже выключен"
                          ,buf_goods.artic
                          ,buf_goods.prod-type
                          ,buf_goods.prod-code
                          ,buf_goods.gds-code
                          ,buf_prod-bc.b-str)
        .
        run err-msg in this-procedure ( input (v-msg)
                                       ,input "warning").
        undo, return error v-msg.
      end.
      if lookup({&weight}, buf_units.type) > 0 then do:
        /*проверим не глобальный ли он*/
        { gbl/prodbcat.i
          buf_prod-bc
          "'global=request':u"
          l-prod-bc-global
          no-error
        }
        if l-prod-bc-global then do:
          assign
          v-msg = substitute("Товар: &1&2&3 код товара &4 ДопБк &5 Нельзя выключить глобальный весовой код"
                            ,buf_goods.artic
                            ,buf_goods.prod-type
                            ,buf_goods.prod-code
                            ,buf_goods.gds-code
                            ,buf_prod-bc.b-str)
          .
          run err-msg in this-procedure (input (v-msg)
                                        ,input "error").
          undo, return error v-msg.
        end.
        else do:
          { gbl/prodbcat.i
            buf_prod-bc
            "'weight=request':u"
            l-prod-bc-weight
            no-error
          }
          if l-prod-bc-weight
          then do:
            { gbl/chk-actg.i
              v-cntxt-db-num
              v-cntxt-userid
              {&action-head-code-main}
              'actn_alt-barcode_loc-sc-code':U
              {&cntxt-global}
              0
              '':U
              0
              0
              buf_goods.grp-code
              0
              "not p-mute"
              loc#log
            }
            if not loc#log then do:
              undo, return error.
            end.
            { gbl/gdsbcode.i buf_goods.gds-code ? v-main-b-code }
            /*Блокирование процесса вкл/выкл лок весовых кодов*/

            { trg/locklscc.i }

            for each buf_clients no-lock where
                    buf_clients.db-num = v-db-num,
              each buf_gds-obj-attr where
                      buf_gds-obj-attr.gds-code = buf_goods.gds-code
                  AND buf_gds-obj-attr.obj-type = buf_clients.obj-type
                  AND buf_gds-obj-attr.obj-code = buf_clients.obj-code
                  AND buf_gds-obj-attr.attr-code = {&attr-scales-code-o}
            on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
            on stop   undo , return error substitute( "&1. stop", vss-workfile )
            on endkey undo , return error substitute( "&1. endkey", vss-workfile )
            :

              assign
              v-deleted = no
              .
              if buf_gds-obj-attr.attr-value = p-b-str then do:
                find first buf_scales-gds No-lock where
                          buf_scales-gds.b-code = v-main-b-code
                      AND buf_scales-gds.db-num = g#db-num
                      and buf_scales-gds.obj-type = buf_clients.obj-type
                      and buf_scales-gds.obj-code = buf_clients.obj-code
                      no-error .
                if available buf_scales-gds then do:
                  assign
                  v-msg = substitute("Товар: &1&2&3 код товара &4 есть товар на весах &5 БД № &6 для &7&8"
                                    ,buf_goods.artic
                                    ,buf_goods.prod-type
                                    ,buf_goods.prod-code
                                    ,buf_goods.gds-code
                                    ,buf_scales-gds.scales-num
                                    ,buf_scales-gds.db-num
                                    ,buf_scales-gds.obj-type
                                    ,buf_scales-gds.obj-code
                                    )
                  .
                  run err-msg in this-procedure (input (v-msg)
                                                ,input "error" ).
                  undo, return error v-msg.
                end.
                  run gdsoattr-delete in this-procedure (
                input buf_goods.gds-code
                ,input buf_gds-obj-attr.obj-type
                ,input buf_gds-obj-attr.obj-code
                ,input {&attr-scales-code-o}
                ,output v-deleted
                ).
                if not v-deleted then do:
                  /*не смогли стереть*/
                  assign
                  v-msg = substitute("Товар: &1 &2 &3 код товара &4 объект &5 &6 не удалось удалить атрибут товара на объекте &7"
                                      ,buf_goods.artic
                                      ,buf_goods.prod-type
                                      ,buf_goods.prod-code
                                      ,buf_goods.gds-code
                                      ,buf_gds-obj-attr.obj-type
                                      ,buf_gds-obj-attr.obj-code
                                      ,{&attr-scales-code-o})
                  .
                  run err-msg in this-procedure (input (v-msg)
                                                ,input "error"
                                                ).
                  undo, return error v-msg.
                end.
              end. /*в этом магазине взвешивалос именно по этому prod-bc*/
            end. /*for each buf_clients*/
          end.  /*if l-prod-bc-weight then do:*/
        end. /* not global:*/
      end. /*if lookup({&weight}, buf_units.type) > 0 then do:*/
      if lookup({&pieces}, buf_units.type) > 0 then do:
        { gbl/prodbcat.i
          buf_prod-bc
          "'pgweight=request':u"
          l-prod-bc-pgweight
          no-error
        }
        if l-prod-bc-pgweight
        then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_alt-barcode_loc-pg-code':U
          {&cntxt-global}
          0
          '':U
          0
          0
          buf_goods.grp-code
          0
          "not p-mute"
          loc#log
        }
        if not loc#log then do:
          undo, return error.
        end.
        { gbl/gdsbcode.i buf_goods.gds-code ? v-main-b-code }
        find first buf_scales-gds No-lock where
                  buf_scales-gds.b-code = v-main-b-code
              AND buf_scales-gds.db-num = g#db-num  no-error .
        if available buf_scales-gds then do:
          assign
          v-msg = substitute("Товар: &1&2&3 код товара &4 есть товар на весах &5 БД № &6"
                            ,buf_goods.artic
                            ,buf_goods.prod-type
                            ,buf_goods.prod-code
                            ,buf_goods.gds-code
                            ,buf_scales-gds.scales-num
                            ,buf_scales-gds.db-num)
          .
          run err-msg in this-procedure (input (v-msg)
                                        ,input "error").
          undo, return error v-msg.
        end.
        /*Блокирование процесса вкл/выкл лок весовых кодов*/
        { trg/locklscc.i }
          for each buf_clients no-lock where
                  buf_clients.db-num = v-db-num,
            each buf_gds-obj-attr where
                    buf_gds-obj-attr.gds-code = buf_goods.gds-code
                AND buf_gds-obj-attr.obj-type = buf_clients.obj-type
                AND buf_gds-obj-attr.obj-code = buf_clients.obj-code
                AND buf_gds-obj-attr.attr-code = {&attr-scales-code-o}
          on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
          on stop   undo , return error substitute( "&1. stop", vss-workfile )
          on endkey undo , return error substitute( "&1. endkey", vss-workfile )
          :

            assign
            v-deleted = no
            .
            if buf_gds-obj-attr.attr-value = p-b-str then do:
                run gdsoattr-delete in this-procedure (
              input buf_goods.gds-code
              ,input buf_gds-obj-attr.obj-type
              ,input buf_gds-obj-attr.obj-code
              ,input {&attr-scales-code-o}
              ,output v-deleted
              ).
              if not v-deleted then do:
                /*не смогли стереть*/
                assign
                v-msg = substitute("Товар: &1 &2 &3 код товара &4 объект &5 &6 не удалось удалить атрибут товара на объекте &7"
                                    ,buf_goods.artic
                                    ,buf_goods.prod-type
                                    ,buf_goods.prod-code
                                    ,buf_goods.gds-code
                                    ,buf_gds-obj-attr.obj-type
                                    ,buf_gds-obj-attr.obj-code
                                    ,{&attr-scales-code-o})
                .
                run err-msg in this-procedure (input (v-msg)
                                              ,input "error").
                undo, return error v-msg.
              end.
            end. /*в этом магазине взвешивалос именно по этому prod-bc*/
          end. /*for each buf_clients*/
        end.  /*if l-prod-bc-pgweight then do:*/
      end. /*if lookup({&pieces}, buf_units.type) > 0 then do:*/

      if lookup ({&petrolium}, buf_units.type) > 0 and
        lookup ({&divisional}, buf_units.type) > 0 and
        buf_goods.gds-type = {&gds-goods} then do:
        assign
        v-msg = substitute("Товар: &1&2&3 код товара &4 ДопБк &5 Топливный Нельзя выключить топливный код"
                          ,buf_goods.artic
                          ,buf_goods.prod-type
                          ,buf_goods.prod-code
                          ,buf_goods.gds-code
                          ,buf_prod-bc.b-str)
          .
        run err-msg in this-procedure (input (v-msg)
                                      ,input "error").
        return error v-msg.
      end.
      find first buf2_prod-bc where
                buf2_prod-bc.b-str = buf_prod-bc.b-str and
                buf2_prod-bc.bc-on = no no-lock no-error.
      if not available buf2_prod-bc then do:
        if not p-mute then do:
          loc#log = no.
          message
          "Выключить единственный (не имеющий повторных) доп. бар-код?! Вы уверены?"
          view-as alert-box question buttons OK-Cancel update loc#log.
          if not loc#log then return error.
        end.
      end.
      run do-off in this-procedure (recid(buf_prod-bc)) no-error .
      if error-status:error then do:
        assign
        v-msg = substitute("Товар: &1&2&3 код товара &4 ДопБк &5 Не удалось выключить&6&7"
                          ,buf_goods.artic
                          ,buf_goods.prod-type
                          ,buf_goods.prod-code
                          ,buf_goods.gds-code
                          ,buf_prod-bc.b-str
                          ,{&new-line}
                          , error-status:get-message(1)
                          )
        .
        run err-msg in this-procedure (input (v-msg)
                                      ,input "error").
        undo, return error v-msg.
      end.
      /*если выключаем локальный весовой то */
      assign
        v-msg = substitute("Товар: &1&2&3 код товара &4 ДопБк &5 Успешно выключен"
                          ,buf_goods.artic
                          ,buf_goods.prod-type
                          ,buf_goods.prod-code
                          ,buf_goods.gds-code
                          ,buf_prod-bc.b-str
                          )

      .
      run err-msg in this-procedure (input (v-msg)
                                     ,input ""
                                       ).
      if p-send-ref then do:
        run str/diallog.w ( parparentproc
                    , this-procedure
                    , 'str/s-prodbc.p':U
                    , string(recid(buf_prod-bc)) + {&delim-par} + "D":U
                    , yes /*p-auto-go*/
                    , '':U
                    , 'Удаление ДопБК с касс') no-error .

      END.
    end.
    when yes then do:
      /*включить*/
      if avail buf_prod-bc and buf_prod-bc.bc-on = true then do:
        assign
        v-msg = substitute("Товар: &1&2&3 код товара &4 ДопБк &5 Уже включен"
                          ,buf_goods.artic
                          ,buf_goods.prod-type
                          ,buf_goods.prod-code
                          ,buf_goods.gds-code
                          ,buf_prod-bc.b-str
                          )
                .
        run err-msg in this-procedure (input (v-msg)
                                       ,input "warning"
                                       ).
        undo, return error v-msg.
      end.
      if available buf_prod-bc and lookup({&weight}, buf_units.type) > 0 then do:
        { gbl/prodbcat.i
          buf_prod-bc
          "'weight=request':u"
          l-prod-bc-weight
          no-error
        }
        { gbl/prodbcat.i
          buf_prod-bc
          "'global=request':u"
          l-prod-bc-global
          no-error
        }
        if l-prod-bc-global
        AND l-prod-bc-weight then do:
          run mark-used-if-need in this-procedure (
                                                    input integer(buf_prod-bc.b-str)
                                                  , input {&loc-sc-code}
                                                  , input 0) no-error .
            if error-status:error then do:
            assign
            v-msg = substitute("Товар: &1&2&3 код товара &4 ДопБк &5 весовой Нельзя выключить весовой код вручную"
                              ,buf_goods.artic
                              ,buf_goods.prod-type
                              ,buf_goods.prod-code
                              ,buf_goods.gds-code
                              ,buf_prod-bc.b-str)
            .
            run err-msg in this-procedure (input (v-msg)
                                          ,input "error"
                                           ).
            undo, return error v-msg.
          end. /*error*/
        End. /*лок вес*/
      end. /*весового типа*/
      do transaction:
      if p-same-recid = ? then do:
        find buf2_prod-bc where
            buf2_prod-bc.b-str = p-b-str and
            buf2_prod-bc.bc-on = yes no-error.
      end.
      else do:
        find buf2_prod-bc where
            recid(buf2_prod-bc) = p-same-recid no-error.
        if not available buf2_prod-bc then do:
          message
          vss-workfile vss-revision vss-description skip
          "Неверный параметр вызова p-same-recid" p-same-recid
          view-as alert-box error .
          undo, return error .
        end.
      end.
      if available buf2_prod-bc then do:
        find buf2_bar-code no-lock where
            buf2_bar-code.b-code = buf2_prod-bc.b-code.
        find first buf2_goods no-lock where
                   buf2_goods.gds-code = buf2_bar-code.gds-code.
        find buf2_units where
            buf2_units.unit-name = buf2_bar-code.unit-cli no-lock.
        if lookup ({&weight}, buf2_units.type) > 0 and buf2_prod-bc.bc-on = yes then do:
          if p-same-recid = ? then do:
            assign
            v-msg = substitute("Товар: &1&2&3 код товара &4 ДопБк &5 весовой&6" +
                               "Нельзя включить данный доп. БК, т.к. для этого пришлось бы выключить весовой код для  другого товара"
                              ,buf_goods.artic
                              ,buf_goods.prod-type
                              ,buf_goods.prod-code
                              ,buf_goods.gds-code
                              ,p-b-str
                              ,{&new-line}) +
                   substitute("Товар: &1&2&3 код товара &4"
                              ,buf2_goods.artic
                              ,buf2_goods.prod-type
                              ,buf2_goods.prod-code
                              ,buf2_goods.gds-code
                              )
            .
            run err-msg in this-procedure (input (v-msg)
                                          ,input "error"
                                          ).
            undo, return error v-msg.
          end.
          else do:
            assign
            v-msg = substitute("Товар: &1&2&3 код товара &4 ДопБК &5&6Повторный дополнительный бар-код является ДОПБК для весового товара - запрещено&6"
                               ,buf_goods.artic
                               ,buf_goods.prod-type
                               ,buf_goods.prod-code
                               ,buf_goods.gds-code
                               ,p-b-str
                               ,{&new-line}) +
                    substitute("Товар: &1&2&3 код товара &4"
                               ,buf2_goods.artic
                               ,buf2_goods.prod-type
                               ,buf2_goods.prod-code
                               ,buf2_goods.gds-code)
            .
            run err-msg in this-procedure (input (v-msg)
                                          ,input "error"
                                          ).
            undo, return error v-msg.
          end.
        end.
        if p-same-recid <> ? then do:
          run adm/shattri.p (
              input "get":U
              ,input  '':U /*p-obj-type*/
              ,input  0 /*p-obj-code*/
              ,input  {&attr-gds-ref}
              ,input  {&attr-gds-ref_dpl-off} /*p-param-code*/
              ,output v-value-character
              ,output v-value-date
              ,output v-value-decimal
              ,output v-value-integer
              ,output dpl-off
              ,output v-param-type
              ,INPUT-OUTPUT table-handle v-tth
              ) no-error.
          delete object v-tth.
          if dpl-off = yes and
            buf2_prod-bc.bc-on then do:
            loc#log = yes.
            if not p-mute then do:
              message
              "Найденный повторный бар-код ВЫКЛЮЧАЕМ (в соответствии с настройкой)."
              view-as alert-box question buttons OK-Cancel update loc#log.
              if not loc#log then undo, return error.
            end.
          end.
          else return.
        end. /*if p-same-recid <> ?*/
        run do-off in this-procedure (recid(buf2_prod-bc)) no-error .
        if error-status:error then do:
          assign
          v-msg = substitute("Товар: &1&2&3 код товара &4 повторный ДопБК: &5&6не удалось выключить"
                             ,buf2_goods.artic
                             ,buf2_goods.prod-type
                             ,buf2_goods.prod-code
                             ,buf2_goods.gds-code
                             ,buf2_prod-bc.b-str
                             ,{&new-line})
          .
          run err-msg in this-procedure (input (v-msg)
                                        ,input "error"
                                        ).
          undo, return error v-msg.
        end.
        assign
        v-msg = substitute("Товар: &1&2&3 код товара &4 повторный ДопБК &5 успешно выключен"
                           ,buf2_goods.artic
                           ,buf2_goods.prod-type
                           ,buf2_goods.prod-code
                           ,buf2_goods.gds-code
                           ,buf2_prod-bc.b-str)
        .
        run err-msg in this-procedure (input (v-msg)
                                      ,input ''
                                      ).
        if p-send-ref then do:
        run str/diallog.w ( parparentproc
                    , this-procedure
                    , 'str/s-prodbc.p':U
                    , string(recid(buf2_prod-bc)) + {&delim-par} + "D":U
                    , yes /*p-auto-go*/
                    , '':U
                    , 'Удаление ДопБК с касс') no-error .

        end.

      end.
      if p-same-recid <> ? then return.
      run do-on in this-procedure (recid(buf_prod-bc)) no-error .
      if error-status:error then do:
        assign
        v-msg = substitute("Товар: &1&2&3 &4 не удалось включить"
                           ,buf_goods.artic
                           ,buf_goods.prod-type
                           ,buf_goods.prod-code
                           ,buf_prod-bc.b-str )
        .
        run err-msg in this-procedure (input (v-msg)
                                       ,input "error"
                                       ).
        undo, return error v-msg.
      end.
      assign
      v-msg = substitute("Товар: &1&2&3 код товара &4 ДопБк &5 успешно включен"
                         ,buf_goods.artic
                         ,buf_goods.prod-type
                         ,buf_goods.prod-code
                         ,buf_goods.gds-code
                         ,buf_prod-bc.b-str)
      .
      run err-msg in this-procedure (input (v-msg)
                                     ,input ""
                                     ).
      if p-send-ref then do:
        run str/diallog.w ( parparentproc
                    , this-procedure
                    , 'str/s-prodbc.p':U
                    , string(recid(buf_prod-bc)) + {&delim-par} + "U":U
                    , yes /*p-auto-go*/
                    , '':U
                    , 'Пересылка ДопБК на кассы') no-error .

      end.
      END. /*transaction*/
    end. /*when yes*/
  END CASE.
end.


procedure do-on :
define input parameter p-rec as recid no-undo.
define buffer buf-on_prod-bc for ub.prod-bc.
  do
  on error undo, return error
  :
    find first buf-on_prod-bc exclusive-lock where
                recid(buf-on_prod-bc) = p-rec.
    assign
    buf-on_prod-bc.bc-on = yes
    .
    release buf-on_prod-bc.
  end.

end procedure. /* do-on */


procedure do-off :
define input parameter p-rec as recid no-undo.
define buffer buf-off_prod-bc for ub.prod-bc.
  do
  on error undo, return error
  :
    find first buf-off_prod-bc exclusive-lock where
                recid(buf-off_prod-bc) = p-rec.
    assign
    buf-off_prod-bc.bc-on = no
    .
    release buf-off_prod-bc.

  end.

end procedure. /* do-off */

procedure err-msg :
define input parameter p-msg as character no-undo .
define input parameter p-msg-type as character no-undo .

  do
  on error undo, return error
  :

    if not p-mute then do:
      case p-msg-type:
        when "error" then do:
      message
      p-msg
      view-as alert-box error .
    end.
        when "warning" then do:
          message
          p-msg
          view-as alert-box warning.
        end.
        otherwise do:
          message
          p-msg
          view-as alert-box .
        end.
      end case.
    end.
    if valid-handle (p-write-proc-handle) then do:
      run write-file in p-write-proc-handle ( input p-msg) .
    end.
  end.

end procedure. /* err-msg */