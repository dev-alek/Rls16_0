block-level on error undo, throw.
define input  parameter parparentproc       as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: incligds.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/incligds.p $":U .
define variable vss-description as character no-undo init "Расчет товарного архива (приход, расход, возврат) по контрагентам" .
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
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
define variable v-select-firm as logical   no-undo .
define variable v-host-code   as integer   no-undo .
define variable v-num         as integer   no-undo .
define buffer buf_dis-card     for ub.dis-card  .
define buffer buf_shop         for ub.shop      .
define buffer buf_chk-doc      for ub.chk-doc   .
define buffer buf_trn-doc      for ub.trn-doc   .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def new shared temp-table cli-list no-undo like ub.clients
  field to-del as logical
  index obj  is primary unique obj-type obj-code
  index cli-name      obj-name
  .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table cli-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
do
on error undo, return error return-value
:
  run gbl/d-askw.w
    (input "Вопрос"
    ,input "Инициализация расчета Итоговых значений по товарам по контрагентам  (приход, расход, возврат)" + chr(10)
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
      (input  parparentproc
      ,input  'b-sel':U
      ,input  no
      ,input  v-cntxt-host-code-obj
      ,output v-host-code
      ,input-output v-rid-list
      ) no-error.
    if error-status :error
    or v-host-code = 0
    or v-host-code = ?
    then do:
      return .
    end.
  end.
  define variable v-select-clients as logical   no-undo .
  define variable v-select-ok      as logical   no-undo .
  run gbl/d-askw.w
    (input "Вопрос"
    ,input "Инициализация расчета Итоговых значений по товарам по контрагентам  (приход, расход, возврат)" + chr(10)
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
      where buf_clients.obj-type = 'орг':U
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
    assign
      v-action = "Обработка документов"
      v-ind    = 0
    .
    if v-select-clients = true
    then do:
      for each buf_trn-doc no-lock
        where buf_trn-doc.host-code = ub.sysconf.host-code
          and buf_trn-doc.status_   = 'факт':U
          and buf_trn-doc.internal  = no
          and buf_trn-doc.doc-type  <> 'инв':U
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
          (input  buf_trn-doc.doc-code
          ,input  true
          ,input  false
          ,input  false
          ) .
      end.
      for each buf_dis-card no-lock
        where buf_dis-card.cli-type = ub.clients.obj-type
          and buf_dis-card.cli-code = ub.clients.obj-code
      on error undo, return error return-value
      :
        _buf_chk-doc:
        for each buf_shop no-lock
          where buf_shop.host-code = ub.sysconf.host-code
        ,each buf_chk-doc no-lock
          where buf_chk-doc.obj-type = 'маг':U
            and buf_chk-doc.obj-code = buf_shop.obj-code
            and buf_chk-doc.d-card   = buf_dis-card.d-card
        :
          if lookup(string(buf_chk-doc.chk-type), '14,15,16,36,17,8,11,12,13,40,69,101,106,108,169,196,114,115,116,117,111,112,136,113,101,106,108,208,2,3,4,5,7,43,44':U) > 0 then NEXT _buf_chk-doc.
          run str/trnsupds.p
            (input buf_chk-doc.doc-code
            ,input true
            ) .
        end.
      end.
    end.
    else do:
      for each buf_trn-doc no-lock
        where buf_trn-doc.host-code = ub.sysconf.host-code
          and buf_trn-doc.status_   = 'факт':U
          and buf_trn-doc.internal  = no
          and buf_trn-doc.doc-type  <> 'инв':U
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
          (input  buf_trn-doc.doc-code
          ,input  true
          ,input  false
          ,input  true
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
