block-level on error undo, throw.
define input parameter p-mode            as character no-undo .
define input parameter p-d-card          like ub.dis-dc-rule.d-card no-undo .
define input parameter p-host-code       like ub.dis-dc-rule.host-code no-undo .
define input parameter p-obj-type        like ub.dis-dc-rule.obj-type no-undo .
define input parameter p-obj-code        like ub.dis-dc-rule.obj-code no-undo .
define temp-table tt0-dis-dc-rule no-undo like ub.dis-dc-rule.
DEFINE INPUT PARAMETER TABLE FOR tt0-dis-dc-rule.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: disdcr1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/disdcr1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений скидок ДК".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
    assign
      p-vss-parameters = substitute('&1|&2|&3|&4':u,p-d-card,p-host-code,p-obj-type,p-obj-code)
    .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable v-deleted as logical no-undo .
define variable v-err-mess as character no-undo .
define buffer buf_dis-dc-rule for ub.dis-dc-rule.
define buffer buf_dis-card for ub.dis-card.
_main:
do
on error undo, return error return-value
:
  find first buf_dis-card no-lock where buf_dis-card.d-card = p-d-card no-error .
  if not available buf_dis-card then do:
    undo, return error substitute("&1 &2 &3&4Не найдена ДК &5"
                                 , vss-workfile
                                 , vss-revision
                                 , vss-description
                                 , chr(10)
                                 , p-d-card).
  end.
  FOR EACH tt0-dis-dc-rule where
  on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
  on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )  :
    if tt0-dis-dc-rule.obj-type = 'орг':U and g#db-num <> 0 then next.
    if tt0-dis-dc-rule.obj-type = '':U and g#db-num <> 0 then next.
    if p-mode <> 'ДОБАВЛЕНИЕ':U then do:
      find FIRST buf_dis-dc-rule WHERE
                buf_dis-dc-rule.d-card = p-d-card
            AND buf_dis-dc-rule.host-code = tt0-dis-dc-rule.host-code
            AND buf_dis-dc-rule.obj-type = tt0-dis-dc-rule.obj-type
            AND buf_dis-dc-rule.obj-code = tt0-dis-dc-rule.obj-code
            AND buf_dis-dc-rule.pos-type = tt0-dis-dc-rule.pos-type
            AND buf_dis-dc-rule.discnt-role = tt0-dis-dc-rule.discnt-role
            AND buf_dis-dc-rule.nonunique = tt0-dis-dc-rule.nonunique
            no-error.
    end.
    IF p-mode = 'ДОБАВЛЕНИЕ':U
    or not available buf_dis-dc-rule
    or buf_dis-dc-rule.rule-num <> tt0-dis-dc-rule.rule-num THEN DO:
      if p-mode = 'ДОБАВЛЕНИЕ':U
      or not available buf_dis-dc-rule then do:
        create buf_dis-dc-rule.
        assign
        buf_dis-dc-rule.d-card = p-d-card
        buf_dis-dc-rule.obj-type = tt0-dis-dc-rule.obj-type
        buf_dis-dc-rule.obj-code = tt0-dis-dc-rule.obj-code
        buf_dis-dc-rule.host-code = tt0-dis-dc-rule.host-code
        buf_dis-dc-rule.pos-type = tt0-dis-dc-rule.pos-type
        buf_dis-dc-rule.nonunique = tt0-dis-dc-rule.nonunique
        buf_dis-dc-rule.discnt-role = tt0-dis-dc-rule.discnt-role
        .
      end.
      assign
      buf_dis-dc-rule.rule-num = tt0-dis-dc-rule.rule-num
      buf_dis-dc-rule.rl-root = tt0-dis-dc-rule.rule-num
      buf_dis-dc-rule.templ-rl-root = tt0-dis-dc-rule.templ-rl-root
      buf_dis-dc-rule.time-templ-rl-root = tt0-dis-dc-rule.time-templ-rl-root
      buf_dis-dc-rule.nonunique = tt0-dis-dc-rule.nonunique
      .
      release buf_dis-dc-rule no-error.
      IF ERROR-STATUS:ERROR THEN DO:
        assign
        v-err-mess = substitute("Ошибка при сохранении типа скидки &1 (POS &2) на ДК &3 на ФИРМЕ &4 Объект &5&6&7&8"
                                ,entry (lookup (tt0-dis-dc-rule.discnt-role, 'debet-pay-pcnt-disc,debet-pay-abs-disc,debet-pay-qnty-disc,debet-pay-sum-disc,debet-pay-free-disc,dc-d-pcnt,dc-cash-d-pcnt,credit-pay-pcnt-disc,credit-pay-abs-disc,credit-pay-qnty-disc,credit-pay-sum-disc,credit-pay-free-disc':u) + 1, ',' + '% Скидка при оплате топлива по дебет.ведомости,ABS Скидка при оплате топлива по дебет.ведомости,Скидка на кол-во при оплате топлива по дебет.ведомости,Скидка на сумму при оплате топлива по дебет.ведомости,Своб скидка при оплате топлива по дебет.ведомости,% скидка на товар по ДК,% скидка на итог чека по ДК,% Скидка при оплате топлива по кредит.ведомости,Abs Скидка при оплате топлива по кредит.ведомости,Скидка на кол-во при оплате топлива по кредит.ведомости,Скидка на сумму при оплате топлива по кредит.ведомости,Своб Скидка на сумму при оплате топлива по кредит.ведомости':u)
                                ,tt0-dis-dc-rule.pos-type
                                ,p-d-card
                                ,tt0-dis-dc-rule.host-code
                                ,tt0-dis-dc-rule.obj-type
                                ,tt0-dis-dc-rule.obj-code
                                ,chr(10)
                                ,error-status:get-message(1)
                                ,return-value
                                ).
        undo _main, return error v-err-mess.
      END.
    END.
  END.
  if p-mode <> 'ДОБАВЛЕНИЕ':U then do:
    FOR EACH buf_dis-dc-rule where
           buf_dis-dc-rule.d-card = p-d-card
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )  :
      if buf_Dis-dc-rule.obj-type = 'орг':U and g#db-num <> 0 then next.
      if buf_dis-dc-rule.obj-type = '':U and g#db-num <> 0 then next.
      if (buf_dis-dc-rule.obj-type = 'маг':U
          or
          buf_dis-dc-rule.obj-type = 'скл':U )
      and ((buf_dis-dc-rule.obj-type <> p-obj-type
           or buf_dis-dc-rule.obj-code <> p-obj-code))  then next.
      if buf_dis-dc-rule.templ-rl-root = 0 then next.
        FIND FIRST tt0-dis-dc-rule NO-LOCK WHERE
            tt0-dis-dc-rule.d-card = p-d-card
        AND tt0-dis-dc-rule.host-code = buf_dis-dc-rule.host-code
        AND tt0-dis-dc-rule.obj-type = buf_dis-dc-rule.obj-type
        AND tt0-dis-dc-rule.obj-code = buf_dis-dc-rule.obj-code
        AND tt0-dis-dc-rule.pos-type = buf_dis-dc-rule.pos-type
        AND tt0-dis-dc-rule.discnt-role = buf_dis-dc-rule.discnt-role
        AND tt0-dis-dc-rule.nonunique = buf_dis-dc-rule.nonunique
        NO-ERROR.
      IF NOT AVAILABLE tt0-dis-dc-rule THEN DO:
        delete buf_dis-dc-rule no-error.
        IF error-status:error
        THEN DO:
          assign
          v-err-mess = substitute("Ошибка при удалении типа скидки скидки &1 (POS &2) на ДК &3 на ФИрме &4 Объект &5&6&7&8&9"
                                  ,entry (lookup (buf_dis-dc-rule.discnt-role, 'debet-pay-pcnt-disc,debet-pay-abs-disc,debet-pay-qnty-disc,debet-pay-sum-disc,debet-pay-free-disc,dc-d-pcnt,dc-cash-d-pcnt,credit-pay-pcnt-disc,credit-pay-abs-disc,credit-pay-qnty-disc,credit-pay-sum-disc,credit-pay-free-disc':u) + 1, ',' + '% Скидка при оплате топлива по дебет.ведомости,ABS Скидка при оплате топлива по дебет.ведомости,Скидка на кол-во при оплате топлива по дебет.ведомости,Скидка на сумму при оплате топлива по дебет.ведомости,Своб скидка при оплате топлива по дебет.ведомости,% скидка на товар по ДК,% скидка на итог чека по ДК,% Скидка при оплате топлива по кредит.ведомости,Abs Скидка при оплате топлива по кредит.ведомости,Скидка на кол-во при оплате топлива по кредит.ведомости,Скидка на сумму при оплате топлива по кредит.ведомости,Своб Скидка на сумму при оплате топлива по кредит.ведомости':u)
                                  ,buf_dis-dc-rule.pos-type
                                  ,p-d-card
                                  ,buf_dis-dc-rule.host-code
                                  ,buf_dis-dc-rule.obj-type
                                  ,buf_dis-dc-rule.obj-code
                                  ,chr(10)
                                  ,error-status:get-message(1)
                                  ,return-value
                                  ).
          undo _main, return error v-err-mess.
        END.
      END.
    END.
  end.
end.
