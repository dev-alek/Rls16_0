block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание динамического меню

Автор: Уханов Дмитрий Юрьевич
Дата создания: 10/06/09
Author: Dmitry Ukhanov
Creation date: 10/06/09

Автор3: Белоусов Илья Александрович
Дата создания3: 06/20/05

Автор2: Перваков
Автор1: Суслов Алексей Юрьевич  27 Oct 1999

*/

define input  parameter parparentproc     as widget-handle no-undo .
define input  parameter p-menu-handle     as widget-handle no-undo .
define input  parameter p-menu-code       as integer   no-undo .
define input  parameter p-menu-group-code as integer   no-undo .
define output parameter p-menu-control-number as character no-undo .

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Создание динамического меню":U .
{ cmp/vssrevis.i "substitute('&1|&2|&3':u,parparentproc,p-menu-handle,p-menu-code,p-menu-group-code)" }
{ cmp/str-glbl.i }
{ gbl/waitfram.i }
{ cmp/library.i  }
{ cmp/strcodec.i }
{ gbl/getcntxt.i def }
{ gbl/thbjattr.i }
{ gbl/cur-time.i }
{ str/lib-farh.i }
{ gbl/cd-attr.i }

define temp-table temp-menu-toggle no-undo
  field item-code      as integer
  field item-handle    as widget-handle
  index xpk is primary unique item-code
  .

define buffer buf_menu-head      for ub.menu-head .

define variable v-context-list    as character no-undo .

do
on error undo, return error return-value
:
  { gbl/getcntxt.i get }

  case v-cntxt-level
  :
    when {&cntxt-global}
    then do:
      assign
        v-context-list = {&cntxt-global}
      .
    end.
    when {&cntxt-firm}
    then do:
      assign
        v-context-list = {&cntxt-global} + {&comma-char} + {&cntxt-firm}
      .
    end.
    when {&cntxt-object}
    then do:
      assign
        v-context-list = {&cntxt-global} + {&comma-char} + {&cntxt-firm} + {&comma-char} + {&cntxt-object}
      .
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Неизвестное значение контекста" skip
        "Контекст" v-cntxt-level skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end case .
   define variable v-value    as character no-undo .
   define variable v-type     as character no-undo .
   define variable isERPRN as logical no-undo.
  
    run gbl/conf-rd.p ("is-erpRN", "", "", 0, "", "", "", no, output v-value, output v-type) no-error.
    isERPRN = v-value eq "yes".
  define stream sinp .
  define stream sout .

  create widget-pool .

  run mainmenu-menu-item-clear in parparentproc .

    find first buf_menu-head
       where buf_menu-head.menu-code = p-menu-code
       no-lock
       .
  assign
      p-menu-control-number = buf_menu-head.control-number
  .
  release buf_menu-head.

  run proc-create-menu-item in this-procedure
    (input  0
    ,input  p-menu-handle
    ,input  true
    ,input  true
    ) .

  run mainmenu-menu-item-open in parparentproc
    (input  0
    ) .
end.

procedure proc-create-menu-item :

  define input  parameter p-parent-code   as integer   no-undo .
  define input  parameter p-parent-handle as widget-handle no-undo .
  define input  parameter p-create-menu   as logical   no-undo .
  define input  parameter p-create-browse as logical   no-undo .

  define buffer buf_menu-item for ub.menu-item .
  define buffer buf_temp-menu-toggle for temp-menu-toggle .
  define buffer buf_menu-item-group for ub.menu-item-group .

  define variable v-object-handle         as widget-handle no-undo .
  define variable v-enable-procedure-list as character no-undo .
  define variable v-enable-item           as logical   no-undo .
  define variable v-procedure-enable-item as logical   no-undo .
  define variable v-enable-index          as integer   no-undo .
  define variable v-enable-num-proc       as integer   no-undo .
  define variable v-item-exist            as logical   no-undo .
  define variable v-create-line           as logical   no-undo .

  do
  on error undo, return error return-value
  :
    assign
      v-item-exist  = false
      v-create-line = false
    .
    IF p-menu-code <> 0
    AND NOT CAN-FIND( FIRST buf_menu-item
                      WHERE buf_menu-item.menu-code = p-menu-code
                        AND buf_menu-item.item-code = p-parent-code
                      SHARE-LOCK NO-WAIT
                    ) THEN DO:
       message "Другой пользователь изменил состав меню." SKIP
               "Перезайдите в TradeHouse или повторно выберите группу меню."
       VIEW-AS ALERT-BOX.
       RETURN.
    END.

    create-menu-item :
    for each buf_menu-item no-lock
      where buf_menu-item.menu-code   = p-menu-code
        and buf_menu-item.parent-code = p-parent-code
    by buf_menu-item.item-code
    on error undo create-menu-item, next create-menu-item
    :
      assign
        v-enable-item = true
      .

      assign
        v-enable-procedure-list = '':u
      .

      /* проверяем контекст группы пунктов меню */
      if buf_menu-item.item-type = 's-m':u
      then do:
        find first buf_menu-item-group no-lock
          where buf_menu-item-group.menu-code       = p-menu-code
            and buf_menu-item-group.item-code       = buf_menu-item.item-code
            and buf_menu-item-group.item-context    = v-cntxt-level
            and buf_menu-item-group.menu-group-code = p-menu-group-code
          no-error .
        if available buf_menu-item-group
        then do:
          assign
            v-enable-procedure-list = buf_menu-item-group.item-condition
          .
        end.
        else do:
          assign
            v-enable-item = false
          .
        end.
      end.
      else do:
        if lookup(string(p-menu-group-code), buf_menu-item.item-group-id) > 0
        then do:
          assign
            v-enable-procedure-list = buf_menu-item.item-condition
          .
        end.
        else do:
          assign
            v-enable-item = false
          .
        end.
      end.

      /* проверяем контекст пункта меню */
      if  (buf_menu-item.item-type = 'm-i':U
           or
           buf_menu-item.item-type = 'm-t':U
          )
      and v-enable-item = true
      then do:
        if lookup(buf_menu-item.item-context, v-context-list) > 0
        then do:
          /* пункт меню показывается */
        end.
        else do:
          assign
            v-enable-item = false
          .
        end.
      end.

      /* проверка условий видимости пункта меню */
      if v-enable-item = true
      then do:
        if  buf_menu-item.item-condition <> ""
        and buf_menu-item.item-condition <> ?
        then do:
          assign
            v-enable-num-proc = num-entries(v-enable-procedure-list, {&comma-char})
          .
          check_condition:
          do v-enable-index = 1 to v-enable-num-proc
          :
            run value(entry(v-enable-index,v-enable-procedure-list,{&comma-char})) in this-procedure
              (output v-procedure-enable-item
              ) .
            if v-procedure-enable-item <> true
            then do:
              assign
                v-enable-item = false
              .
              leave check_condition . /* --->>>--- */
            end.
          end.
        end.
      end.

      /* todo - проверка прав пользователя */

      /* todo - индивидуальная настройка меню пользователя */

      if v-enable-item = true
      then do:
        if p-create-menu = true
        then do:
          if buf_menu-item.item-type = 'r-l':U
          then do:
            assign
              v-create-line = true
            .
          end.
          else do:
            if  v-item-exist  = true
            and v-create-line = true
            then do:
              create menu-item v-object-handle
              assign
                subtype = "rule"
                parent  = p-parent-handle
              .
            end.
            assign
              v-item-exist  = true
              v-create-line = false
            .
          end.

          case buf_menu-item.item-type
          :
            when 's-m':u
            then do:
              create sub-menu v-object-handle
              assign
                label = buf_menu-item.item-name
                triggers:
                  on menu-drop
                  persistent run run-menu-drop-procedure in this-procedure
                    (input v-object-handle
                    ).
                  end triggers.
              .
              assign
                v-object-handle :private-data = 's-m':u
                                              + {&comma-char} + string(buf_menu-item.item-code)
              .
            end.
            when 'r-l':u
            then do:
              /* событие обрабатывается выше */
              /* взводится флаг необходимости создания линейки */
            end.
            when 'm-i':u
            then do:
              create menu-item v-object-handle
              assign
                label = buf_menu-item.item-name
                triggers:
                  on choose
                  persistent run run-menu-item-procedure in this-procedure
                    (input v-object-handle
                    ).
                  end triggers.
              assign
                v-object-handle :private-data = 'm-i':u
                                              + {&comma-char} + string(buf_menu-item.item-code)
                                              + {&comma-char} + buf_menu-item.item-procedure
              .
            end.
            when 'm-t':u
            then do:
              create menu-item v-object-handle
              assign
                label        = buf_menu-item.item-name
                toggle-box   = yes
                triggers:
                  on value-changed
                  persistent run run-menu-item-procedure in this-procedure
                    (input v-object-handle
                    ).
                  end triggers.
              assign
                v-object-handle :private-data = 'm-t':u
                                              + {&comma-char} + string(buf_menu-item.item-code)
                                              + {&comma-char} + buf_menu-item.item-procedure
              .

              /* запоминаем указатель на пункт меню */
              create buf_temp-menu-toggle .
              assign
                buf_temp-menu-toggle.item-code   = buf_menu-item.item-code
                buf_temp-menu-toggle.item-handle = v-object-handle
              .

              define variable v-object-value as logical   no-undo .

              case entry(1, buf_menu-item.item-procedure, {&comma-char})
              :
                when 'int':u
                then do:
                  run value(entry(2, buf_menu-item.item-procedure, {&comma-char})) in this-procedure
                    (input 'get':u
                    ,input-output v-object-value
                    ) .
                end.
                when 'ext':u
                then do:
                  run value(entry(2, buf_menu-item.item-procedure, {&comma-char}))
                    (input 'get':u
                    ,input-output v-object-value
                    ) .
                end.
                otherwise do:
                  message
                    vss-workfile vss-revision vss-description skip
                    "Внутренняя ошибка" skip
                    "Неизвестный тип процедуры в пункте меню" skip
                    buf_menu-item.item-procedure skip
                    view-as alert-box error .
                  undo create-menu-item, next create-menu-item .
                end.
              end case .

              assign
                v-object-handle :checked = v-object-value
              .
            end.
            otherwise do:
              message
                vss-workfile vss-revision vss-description skip
                "Внутренняя ошибка" skip
                "Неизвестный тип пункта меню" buf_menu-item.item-type skip
                view-as alert-box error .
              undo create-menu-item, next create-menu-item .
            end.
          end case .

          if buf_menu-item.item-type <> 'r-l':U
          then do:
            assign
              v-object-handle :parent = p-parent-handle
            .
          end.
        end.

        if  p-create-browse         = true
        and buf_menu-item.item-type <> 'r-l':u
        then do:
          run mainmenu-menu-item-create in parparentproc
            (input buf_menu-item.item-code
            ,input buf_menu-item.item-type
            ,input buf_menu-item.item-name
            ,input buf_menu-item.item-id
            ,input buf_menu-item.item-procedure
            ,input buf_menu-item.parent-code
            ,input true
            ) .
        end.
      end.
    end.
  end.

end procedure. /* proc-create-menu-item */

procedure run-menu-drop-procedure :

  define input  parameter p-item-handle as widget-handle no-undo .

  define variable v-object-handle  as widget-handle no-undo .

  define variable v-item-data      as character no-undo .
  define variable v-item-type      as character no-undo .
  define variable v-procedure-type as character no-undo .
  define variable v-item-procedure as character no-undo .

  do
  on error undo, return error return-value
  :
    assign
      v-item-data = p-item-handle :private-data
    .

    if v-item-data <> 's-m':u
    then do:
      run proc-create-menu-item in this-procedure
        (input  entry(2, v-item-data, {&comma-char})
        ,input  p-item-handle
        ,input  true
        ,input  false
        ) .
      assign
        p-item-handle :private-data = 's-m':u
      .
    end.
  end.

end procedure. /* run-menu-drop-procedure */


procedure run-menu-item-procedure :

  define input  parameter p-item-handle as widget-handle no-undo .

  define variable v-item-data           as character no-undo .
  define variable v-item-type           as character no-undo .
  define variable v-item-code           as integer   no-undo .
  define variable v-procedure-type      as character no-undo .
  define variable v-item-procedure      as character no-undo .
  define variable v-procedure-parameter as character no-undo .
  define variable v-cur-date-error-code as integer      no-undo.

  do
  on error undo, return error return-value
  :
/*    message*/
/*      "x" "Вызов пункта меню" skip*/
/*      p-item-handle skip*/
/*      p-item-handle :private-data skip*/
/*      view-as alert-box error .*/

    assign
      v-item-data = p-item-handle :private-data
    .

    if num-entries(v-item-data, {&comma-char}) < 4
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Внутренняя ошибка" skip
        "Ошибка при доступе к внутренним данным пункта меню" skip
        "Количество полей менее четырех" skip
        p-item-handle skip
        p-item-handle :private-data skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    assign
      v-item-type      = entry(1, v-item-data, {&comma-char})
      v-item-code      = integer(entry(2, v-item-data, {&comma-char}))
      v-procedure-type = entry(3, v-item-data, {&comma-char})
      v-item-procedure = entry(4, v-item-data, {&comma-char})
    .

    if num-entries(v-item-data, {&comma-char}) > 4
    then do:
      assign
        v-procedure-parameter = entry(5, v-item-data, {&comma-char})
      .
    end.
    else do:
      assign
        v-procedure-parameter = '':u
      .
    end.

    run mainmenu-show-item in parparentproc
      (input  v-item-code
      ) .

    run dm-menu-choose-item in this-procedure
      (input  v-item-type           /* p-item-type           */
      ,input  v-item-code           /* p-item-code           */
      ,input  v-procedure-type      /* p-procedure-type      */
      ,input  v-item-procedure      /* p-item-procedure      */
      ,input  v-procedure-parameter /* p-procedure-parameter */
      ) .

    run mainmenu-menu-item-open in parparentproc
      (input v-item-code
      ) .

    if v-item-procedure <> 'm_exit-exe':u
    then do:
      run mainmenu-disp-mutable in parparentproc (
            output v-cur-date-error-code
      ).
    end.
  end.


end procedure. /* run-menu-item-procedure */


procedure dm-menu-choose-item :

  define input  parameter p-item-type           as character no-undo .
  define input  parameter p-item-code           as integer   no-undo .
  define input  parameter p-procedure-type      as character no-undo .
  define input  parameter p-item-procedure      as character no-undo .
  define input  parameter p-procedure-parameter as character no-undo .

  define buffer buf_temp-menu-toggle for temp-menu-toggle .

  do
  on error undo, return error return-value
  :
    if transaction = true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Внутренняя ошибка" skip
        "Активна транзакция при запуске пункта меню" skip
        "Работа будет продолжена" skip
        "В случае отката транзакция пропадет вся работа," skip
        "сделанная в пункте меню" skip
        view-as alert-box error .
    end.

    /* записываем информацию о входе в пункт меню */
    /* пункт меню выход не надо записывать        */
    if p-item-procedure <> 'm_exit-exe':u
    then do:
      run mainmenu-start-item in parparentproc
        (input  p-item-code
        ) .
    end.

    define variable v-message as character no-undo .

    case p-item-type :
      when 'm-i':u
      then do:
        run choose-menu-item in parparentproc .

        do
        on error   undo, leave
        on end-key undo, leave
        on stop    undo, leave
        :
          case p-procedure-type :
            when 'int':u
            then do:
              run run-procedure-int in this-procedure
                (input p-item-procedure
                ) no-error .
              if error-status :error
              then do:
                run menu-item-get-error-message in this-procedure
                  (input  p-menu-code
                  ,input  p-item-code
                  ,input  p-item-procedure
                  ,input  error-status :get-message(1)
                  ,input  return-value
                  ,output v-message
                  ) .
                message
                  "Ошибка при вызове пункта меню" skip
                  v-message skip
                  view-as alert-box error .
              end.
            end.
            when 'ext':u
            then do:
              run run-procedure-ext in this-procedure
                (input p-item-procedure
                ) no-error .
              if error-status :error
              then do:
                run menu-item-get-error-message in this-procedure
                  (input  p-menu-code
                  ,input  p-item-code
                  ,input  p-item-procedure
                  ,input  error-status :get-message(1)
                  ,input  return-value
                  ,output v-message
                  ) .
                message
                  "Ошибка при вызове пункта меню" skip
                  v-message skip
                  view-as alert-box error .
              end.
            end.
            when 'par':u
            then do:
              run run-procedure-par in this-procedure
                (input  p-item-procedure
                ) no-error .
              if error-status :error
              then do:
                run menu-item-get-error-message in this-procedure
                  (input  p-menu-code
                  ,input  p-item-code
                  ,input  p-item-procedure
                  ,input  error-status :get-message(1)
                  ,input  return-value
                  ,output v-message
                  ) .
                message
                  "Ошибка при вызове пункта меню" skip
                  v-message skip
                  view-as alert-box error .
              end.
            end.
            when 'str':u
            then do:
              run run-procedure-str in this-procedure
                (input  p-item-procedure
                ,input  str-decode(p-procedure-parameter, '':u)
                ) no-error .
              if error-status :error
              then do:
                run menu-item-get-error-message in this-procedure
                  (input  p-menu-code
                  ,input  p-item-code
                  ,input  p-item-procedure
                  ,input  error-status :get-message(1)
                  ,input  return-value
                  ,output v-message
                  ) .
                message
                  "Ошибка при вызове пункта меню" skip
                  v-message skip
                  view-as alert-box error .
              end.
            end.
            when 'pst':u
            then do:
              run run-procedure-pst in this-procedure
                (input  p-item-procedure
                ,input  str-decode(p-procedure-parameter, '':u)
                ) no-error .
              if error-status :error
              then do:
                run menu-item-get-error-message in this-procedure
                  (input  p-menu-code
                  ,input  p-item-code
                  ,input  p-item-procedure
                  ,input  error-status :get-message(1)
                  ,input  return-value
                  ,output v-message
                  ) .
                message
                  "Ошибка при вызове пункта меню" skip
                  v-message skip
                  view-as alert-box error .
              end.
            end.
            otherwise do:
              message
                vss-workfile vss-revision vss-description skip
                "Внутренняя ошибка" skip
                "Тип пункта" p-item-type skip
                "Код пункта меню" p-item-code skip
                "Неизвестный тип процедуры" p-procedure-type skip
                "Процедура" p-item-procedure skip
                view-as alert-box error .
            end.
          end case .
        end.
        run deselect-menu-item in parparentproc .
      end.
      when 'm-t':u
      then do:
        define variable v-item-value       as logical   no-undo .
        define variable v-menu-item-handle as widget-handle no-undo .

        case p-procedure-type
        :
          when 'int':u
          then do:
            run value(p-item-procedure) in this-procedure
              (input  'get':u
              ,input-output v-item-value
              ) .
          end.
          otherwise do:
            message
              vss-workfile vss-revision vss-description skip
              "Внутренняя ошибка" skip
              "Код пункта меню" p-item-code skip
              "Неизвестный тип процедуры" p-procedure-type skip
              "Процедура" p-item-procedure skip
              view-as alert-box error .
          end.
        end case .

        assign
          v-item-value = not v-item-value
        .

        case p-procedure-type
        :
          when 'int':u
          then do:
            run value(p-item-procedure) in this-procedure
              (input  'set':u
              ,input-output v-item-value
              ) .
          end.
          otherwise do:
            message
              vss-workfile vss-revision vss-description skip
              "Внутренняя ошибка" skip
              "Код пункта меню" p-item-code skip
              "Неизвестный тип процедуры" p-procedure-type skip
              "Процедура" p-item-procedure skip
              view-as alert-box error .
          end.
        end case .

        find first buf_temp-menu-toggle
          where buf_temp-menu-toggle.item-code = p-item-code
          no-error .
        if available buf_temp-menu-toggle
        then do:
          assign
            v-menu-item-handle = buf_temp-menu-toggle.item-handle
          .
          assign
            v-menu-item-handle :checked = v-item-value
          .
        end.

        run mainmenu-set-menu-toggle in parparentproc
          (input  p-item-code
          ,input  v-item-value
          ) .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Внутренняя ошибка" skip
          "Неизвестный тип пункта меню" p-item-type skip
          "Код пункта меню" p-item-code skip
          "Тип процедуры" p-procedure-type skip
          "Процедура" p-item-procedure skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.

    /* записываем информацию о выходе из пункта меню */
    /* пункт меню выход не надо записывать */
    if p-item-procedure <> 'm_exit-exe':u
    then do:
      run mainmenu-stop-item in parparentproc .
    end.
  end.

end procedure. /* dm-menu-choose-item */


procedure run-procedure-clear-return-value :

  do
  on error undo, return error return-value
  :
    return '':U .
  end.

end procedure. /* run-procedure-clear-return-value */


procedure run-procedure-int :

  define input  parameter p-item-procedure as character no-undo .

  do
  on error undo, retry
  on end-key undo, retry
  on stop undo, retry
  :
    if retry then do:
      message
        "Ошибка при вызове внутренней процедуры" skip
        "Процедура" p-item-procedure skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    run run-procedure-clear-return-value in this-procedure .

    run value(p-item-procedure) in this-procedure .
  end.

end procedure. /* run-procedure-int */

procedure run-procedure-ext :

  define input  parameter p-item-procedure as character no-undo .

  do
  on error undo, retry
  on end-key undo, retry
  on stop undo, retry
  :
    if retry then do:
      message
        "Ошибка при вызове внешней процедуры" skip
        "Процедура" p-item-procedure skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    run run-procedure-clear-return-value in this-procedure .

    run value(p-item-procedure) .
  end.

end procedure. /* run-procedure-ext */

procedure run-procedure-par :

  define input  parameter p-item-procedure as character no-undo .

  do
  on error undo, retry
  on end-key undo, retry
  on stop undo, retry
  :
    if retry then do:
      message
        "Ошибка при вызове внешней процедуры с параметром parparentproc" skip
        "Процедура" p-item-procedure skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    run run-procedure-clear-return-value in this-procedure .

    run value(p-item-procedure)
      (input  parparentproc
      ) .
  end.

end procedure. /* run-procedure-par */

procedure run-procedure-str :

  define input  parameter p-item-procedure      as character no-undo .
  define input  parameter p-procedure-parameter as character no-undo .

  do
  on error undo, retry
  on end-key undo, retry
  on stop undo, retry
  :
    if retry then do:
      message
        "Ошибка при вызове внешней процедуры с параметром строка" skip
        "Процедура" p-item-procedure skip
        "Параметр" p-procedure-parameter skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    run run-procedure-clear-return-value in this-procedure .

    run value(p-item-procedure)
      (input p-procedure-parameter
      ) .
  end.

end procedure. /* run-procedure-str */


procedure run-procedure-pst :

  define input  parameter p-item-procedure      as character no-undo .
  define input  parameter p-procedure-parameter as character no-undo .

  do
  on error undo, retry
  on end-key undo, retry
  on stop undo, retry
  :
    if retry then do:
      message
        "Ошибка при вызове внешней процедуры с параметрами parparentproc, строка" skip
        "Процедура" p-item-procedure skip
        "Параметр" p-procedure-parameter skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    run run-procedure-clear-return-value in this-procedure .

    run value(p-item-procedure)
      (input  parparentproc
      ,input  p-procedure-parameter
      ) .
  end.

end procedure. /* run-procedure-pst */


procedure menu-item-get-error-message :

  define input  parameter p-menu-code      as integer   no-undo .
  define input  parameter p-item-code      as integer   no-undo .
  define input  parameter p-item-procedure as character no-undo .
  define input  parameter p-error-message  as character no-undo .
  define input  parameter p-return-value   as character no-undo .
  define output parameter v-message        as character no-undo .

  define buffer buf_menu-item for ub.menu-item .

  define variable v-item-id as character no-undo .

  do
  on error undo, return error return-value
  :
    find first buf_menu-item no-lock
      where buf_menu-item.menu-code = p-menu-code
        and buf_menu-item.item-code = p-item-code
      no-error .
    if available buf_menu-item
    then do:
      assign
        v-item-id = buf_menu-item.item-id
      .
    end.
    else do:
      assign
        v-item-id = substitute('код &1':U, p-item-code)
      .
    end.

    assign
      v-message = substitute('Пункт меню &2&1Процедура &3&1&4&1&5  '
                            ,{&new-line}
                            ,v-item-id
                            ,p-item-procedure
                            ,p-error-message
                            ,p-return-value
                            )
    .


  end.

end procedure. /* menu-item-get-error-message */


/* процедуры для пунктов меню */


procedure m_sf-new-exe :
  define variable rid# as recid no-undo.

  do on error undo, return error return-value :
    run str/s-f-docs.w ( input parparentproc, input v-cntxt-host-code-obj, "", ?, ?, ?, ?, ?, ?,  input "new", input-output rid# ).
  end.
end procedure. /* m_sf-new-exe */

procedure m_sf-fact-exe :
  define variable rid# as recid no-undo.

  do on error undo, return error return-value :
    run str/s-f-docs.w ( input parparentproc, input v-cntxt-host-code-obj, "", ?, ?, ?, ?, ?, ?,  input "fact", input-output rid# ).
  end.
end procedure. /* m_sf-new-exe */

procedure m_sf-all-exe :
  define variable rid# as recid no-undo.

  do on error undo, return error return-value :
    run str/s-f-docs.w ( input parparentproc, input v-cntxt-host-code-obj, "", ?, ?, ?, ?, ?, ?, input "all", input-output rid# ).
  end.
end procedure. /* m_sf-new-exe */

procedure m_c-fin-doc-del-exe :

define variable p-fin-doc-type like ub.fin-doc.fin-doc-type initial "":U no-undo .
define variable p-status_ like ub.fin-doc.status_ initial "":U no-undo .
define variable v-rid-list as character no-undo .
define variable v-mode as character no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
if num-entries(p-fin-doc-type, {&delim-par}) > 1
and entry(2, p-fin-doc-type, {&delim-par}) =  {&g___object}
then do:
  v-obj-type = v-cntxt-obj-type.
  v-obj-code = v-cntxt-obj-code.
  assign v-mode =  (if p-fin-doc-type = "":U
                     then {&g___object}
                     else (if p-status_ = "":U
                           then "type-object":U
                           else "type-stat-object":U))
  p-fin-doc-type = entry(1, p-fin-doc-type, {&delim-par})
  .
end.
else do:
  assign v-mode =  (if p-fin-doc-type = "":U
                     then {&company}
                     else (if p-status_ = "":U
                           then "type":U
                           else "type-stat":U))
  .
end.

  do on error undo, return error return-value :
    run str/fincdocdel.w
              (input parparentproc
              ,input v-cntxt-host-code-obj
              ,input v-mode
              ,input {&all}  /*p-list*/
              ,input v-cntxt-host-code-obj /*p-host-code*/
              ,input v-obj-type   /*p-obj-type*/
              ,input v-obj-code   /*p-obj-code*/
              ,input p-status_
              ,input p-fin-doc-type
              ,input "":U   /*p-fin-ext-doc-type*/
              ,input ?      /*p-start-date  */
              ,input ?      /*p-end-date  */
              ,input "":U   /* p-trn-doc-code */
              ,input "":U   /*p-receiver-type */
              ,input 0      /* p-receiver-code */
              ,input "":U   /* p-receiver-r-schet */
              ,input "":U   /*p-PAYER-type */
              ,input 0      /* p-PAYER-code */
              ,input "":U   /* p-PAYER-r-schet */
              ,input ?      /*p-curr-code*/
              ,input 0      /* p-receiver-code-schet */
              ,input 0      /* p-payer-code-schet */
              ,input 0      /*p-contract-code*/
              ,input 0      /*p-cor-acc  */
              ,input 0      /*p-cor-acc1 */
              ,input 0      /*p-an-uchet-code */
              ,input 0      /*p-cel-nazn-code */
    ).
  end.

end procedure. /* m_c-fin-doc-del-exe */


procedure m_par-obj-auto-exp-exe :    /*автоматические факт*/

  do
  on error undo, return error return-value
  :
    run wth-docs-exe in this-procedure ('ext-doc-type':U,{&expense},{&WDEDT_Cas_Exp},'':U).
  end.

end procedure. /* m_par-obj-auto-exe */

procedure m_par-obj-auto-inc-exe :       /*автоматические приход */

  do
  on error undo, return error return-value
  :
    run wth-docs-exe in this-procedure ('ext-doc-type':U,{&income},{&WDEDT_Cas_Inc},'':U).

  end.

end procedure. /* m_par-obj-auto-exe */


procedure m_par-obj-wrt-new-exe :       /*списание*/

  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type':U,{&write-off},{&WDEDT_Wrt_Off},{&wayb}) .
  end.

end procedure. /* m_par-obj-wrt-exe */

procedure m_par-obj-wrt-fact-exe :

  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type':U,{&write-off},{&WDEDT_Wrt_Off},{&fact}) .
  end.

end procedure. /* m_par-obj-wrt-fact-exe */
 procedure m_par-obj-wrt-all-exe :       /*списание*/

  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type':U,{&write-off},{&WDEDT_Wrt_Off},'':U) .
  end.

end procedure. /* m_par-obj-wrt-all-exe */


procedure m_par-obj-all-exe :

  do
  on error undo, return error return-value
  :
    run wth-docs-exe({&g___object},'':U,'':U ,'':U) .
  end.

end procedure. /* m_par-obj-all-exe */

procedure m_par-cmp-all-exe :

  do
  on error undo, return error return-value
  :
    run wth-docs-exe({&company},'':U,'':U, '':U) .
  end.

end procedure. /* m_par-cmp-all-exe */

procedure m_par-all-all-exe :

  do
  on error undo, return error return-value
  :
    run wth-docs-exe({&all},'':U,'':U,'':U) .
  end.

end procedure. /* m_par-all-all-exe */

procedure m_wth-obj-ext-in-new-exe :    /* Приход внешний */
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&income},{&WDEDT_Inc_Ext},{&wayb}) .
  end.
end procedure. /* m_wth-obj-ext-in-new-exe */

procedure m_wth-obj-ext-in-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&income},{&WDEDT_Inc_Ext},{&fact}) .
  end.
end procedure. /* m_wth-obj-ext-in-fact-exe */

procedure m_wth-obj-ext-in-all-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&income},{&WDEDT_Inc_Ext},'':U) .
  end.

end procedure. /* m_wth-obj-ext-in-all-exe */

procedure m_wth-obj-inc-in-zp-new-exe    /*Приход внутренний зоны погашени */
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&income},{&WDEDT_Inc_Int_Put},{&wayb}) .
  end.
end procedure. /* m_wth-obj-inc-in-zp-new-exe */

procedure m_wth-obj-inc-in-zp-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&income},{&WDEDT_Inc_Int_Put},{&fact}) .
  end.
end procedure. /* m_wth-obj-inc-in-zp-fact-exe */

procedure m_wth-obj-inc-in-zp-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&income},{&WDEDT_Inc_Int_Put},'':U) .
  end.

end procedure. /* m_wth-obj-inc-in-zp-all-exe */

procedure m_wth-obj-inc-in-fr-new-exe    /*Приход внутренний свободной зоны  */
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&income},{&WDEDT_Inc_Int_Free},{&wayb}) .
  end.
end procedure. /* m_wth-obj-inc-in-fr-new-exe */

procedure m_wth-obj-inc-in-fr-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&income},{&WDEDT_Inc_Int_Free},{&fact}) .
  end.
end procedure. /* m_wth-obj-inc-in-fr-fact-exe */

procedure m_wth-obj-inc-in-fr-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&income},{&WDEDT_Inc_Int_Free},'':U) .
  end.

end procedure. /* m_wth-obj-inc-in-fr-all-exe */

procedure m_wth-obj-inc-in-new-exe    /*Приход внутренний */
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&income},{&WDEDT_Inc_Int},{&wayb}) .
  end.
end procedure. /* m_wth-obj-inc-in-new-exe */

procedure m_wth-obj-inc-in-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&income},{&WDEDT_Inc_Int},{&fact}) .
  end.
end procedure. /* m_wth-obj-inc-in-fr-fact-exe */

procedure m_wth-obj-inc-in-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&income},{&WDEDT_Inc_Int},'':U) .
  end.

end procedure. /* m_wth-obj-inc-in-all-exe */

procedure m_wth-obj-ext-out-new-exe   /*расход внешний*/
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&expense},{&WDEDT_Exp_Ext},{&wayb}) .
  end.
end procedure. /* m_wth-obj-ext-out-new-exe */

procedure m_wth-obj-ext-out-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&expense},{&WDEDT_Exp_Ext},{&fact}) .
  end.
end procedure. /* m_wth-obj-ext-out-fact-exe */

procedure m_wth-obj-ext-out-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&expense},{&WDEDT_Exp_Ext},{&all}) .
  end.

end procedure. /* m_wth-obj-ext-out-all-exe */

procedure m_wth-obj-inc-out-zp-new-exe   /*расход внутренний зоны погашения*/
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&expense},{&WDEDT_Exp_Int_Put},{&wayb}) .
  end.
end procedure. /* m_wth-obj-inc-in-zp-new-exe */

procedure m_wth-obj-inc-out-zp-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&expense},{&WDEDT_Exp_Int_Put},{&fact}) .
  end.
end procedure. /* m_wth-obj-inc-in-zp-new-exe */

procedure m_wth-obj-inc-out-zp-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&expense},{&WDEDT_Exp_Int_Put},{&all}) .
  end.

end procedure. /* m_wth-obj-inc-in-zp-new-exe */

procedure m_wth-obj-inc-out-fr-new-exe   /*расход внутренний свободной зоны */
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&expense},{&WDEDT_Exp_Int_Free},{&wayb}) .
  end.
end procedure. /* m_wth-obj-inc-in-fr-new-exe */

procedure m_wth-obj-inc-out-fr-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&expense},{&WDEDT_Exp_Int_Free},{&fact}) .
  end.
end procedure. /* m_wth-obj-inc-in-fr-new-exe */

procedure m_wth-obj-inc-out-fr-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&expense},{&WDEDT_Exp_Int_Free},{&all}) .
  end.

end procedure. /* m_wth-obj-inc-in-fr-new-exe */

procedure m_wth-obj-inc-out-new-exe   /*расход внутренний */
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&expense},{&WDEDT_Exp_Int},{&wayb}) .
  end.
end procedure. /* m_wth-obj-inc-in-new-exe */

procedure m_wth-obj-inc-out-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&expense},{&WDEDT_Exp_Int},{&fact}) .
  end.
end procedure. /* m_wth-obj-inc-in-new-exe */

procedure m_wth-obj-inc-out-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&expense},{&WDEDT_Exp_Int},{&all}) .
  end.

end procedure. /* m_wth-obj-inc-in-new-exe */

procedure m_wth-obj-inj-out-new-exe   /*расход внутриобъектный*/
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&expense},{&WDEDT_Exp_Obj},{&wayb}) .
  end.
end procedure. /* m_wth-obj-inj-out-new-exe */

procedure m_wth-obj-inj-out-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&expense},{&WDEDT_Exp_Obj},{&fact}) .
  end.
end procedure. /* m_wth-obj-inj-out-fact-exe */

procedure m_wth-obj-inj-out-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&expense},{&WDEDT_Exp_Obj},{&all}) .
  end.

end procedure. /* m_wth-obj-inj-out-all-exe */


procedure m_wth-obj-inj-in-new-exe   /*приход внутриобъектный*/
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&income},{&WDEDT_Inc_Obj},{&wayb}) .
  end.
end procedure. /* m_wth-obj-inj-in-new-exe */

procedure m_wth-obj-inj-in-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&income},{&WDEDT_Inc_Obj},{&fact}) .
  end.
end procedure. /* m_wth-obj-inj-in-fact-exe */

procedure m_wth-obj-inj-in-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&income},{&WDEDT_Inc_Obj},{&all}) .
  end.
end procedure. /* m_wth-obj-inj-in-all-exe */

procedure m_wth-obj-inj-out-free-new-exe   /*расход внутриобъектный своб. зоны*/
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&expense},{&WDEDT_Exp_Obj_Free},{&wayb}) .
  end.
end procedure. /* m_wth-obj-inj-out-free-new-exe */

procedure m_wth-obj-inj-out-free-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&expense},{&WDEDT_Exp_Obj_Free},{&fact}) .
  end.
end procedure. /* m_wth-obj-inj-out-free-fact-exe */

procedure m_wth-obj-inj-out-free-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&expense},{&WDEDT_Exp_Obj_Free},{&all}) .
  end.

end procedure. /* m_wth-obj-inj-out-free-all-exe */


procedure m_wth-obj-inj-in-free-new-exe   /*приход внутриобъектный своб. зоны*/
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&income},{&WDEDT_Inc_Obj_Free},{&wayb}) .
  end.
end procedure. /* m_wth-obj-inj-in-free-new-exe */

procedure m_wth-obj-inj-in-free-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&income},{&WDEDT_Inc_Obj_Free},{&fact}) .
  end.
end procedure. /* m_wth-obj-inj-in-free-fact-exe */

procedure m_wth-obj-inj-in-free-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&income},{&WDEDT_Inc_Obj_Free},{&all}) .
  end.
end procedure. /* m_wth-obj-inj-in-free-all-exe */

procedure m_wth-obj-inj-out-put-new-exe   /*расход внутриобъектный зоны погаш.*/
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&expense},{&WDEDT_Exp_Obj_put},{&wayb}) .
  end.
end procedure. /* m_wth-obj-inj-out-Put-new-exe */

procedure m_wth-obj-inj-out-Put-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&expense},{&WDEDT_Exp_Obj_Put},{&fact}) .
  end.
end procedure. /* m_wth-obj-inj-out-Put-fact-exe */

procedure m_wth-obj-inj-out-Put-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&expense},{&WDEDT_Exp_Obj_Put},{&all}) .
  end.

end procedure. /* m_wth-obj-inj-out-Put-all-exe */


procedure m_wth-obj-inj-in-Put-new-exe   /*приход внутриобъектный своб. зоны*/
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&income},{&WDEDT_Inc_Obj_Put},{&wayb}) .
  end.
end procedure. /* m_wth-obj-inj-in-Put-new-exe */

procedure m_wth-obj-inj-in-Put-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&income},{&WDEDT_Inc_Obj_Put},{&fact}) .
  end.
end procedure. /* m_wth-obj-inj-in-Put-fact-exe */

procedure m_wth-obj-inj-in-Put-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&income},{&WDEDT_Inc_Obj_Put},{&all}) .
  end.
end procedure. /* m_wth-obj-inj-in-Put-all-exe */



procedure m_wth-obj-inc-ret-zp-new-exe   /*возврат внутренний зоны погашения*/
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&return},{&WDEDT_Ret_Int_Put},{&wayb}) .
  end.
end procedure. /* m_wth-obj-inc-ret-zp-new-exe */

procedure m_wth-obj-inc-ret-zp-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&return},{&WDEDT_Ret_Int_Put},{&fact}) .
  end.
end procedure. /* m_wth-obj-inc-ret-zp-fact-exe */

procedure m_wth-obj-inc-ret-zp-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&return},{&WDEDT_Ret_Int_Put},{&all}) .
  end.
end procedure. /* m_wth-obj-inc-ret-zp-all-exe */

procedure m_wth-obj-inc-ret-fr-new-exe   /*возврат внутренний свободной зоны */
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&return},{&WDEDT_Ret_Int_Free},{&wayb}) .
  end.
end procedure. /* m_wth-obj-inc-ret-fr-new-exe */

procedure m_wth-obj-inc-ret-fr-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&return},{&WDEDT_Ret_Int_Free},{&fact}) .
  end.
end procedure. /* m_wth-obj-inc-ret-fr-fact-exe */

procedure m_wth-obj-inc-ret-fr-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&return},{&WDEDT_Ret_Int_Free},{&all}) .
  end.
end procedure. /* m_wth-obj-inc-ret-fr-all-exe */

procedure m_wth-obj-inc-ret-new-exe   /*возврат внутренний  */
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&return},{&WDEDT_Ret_Int},{&wayb}) .
  end.
end procedure. /* m_wth-obj-inc-ret-new-exe */

procedure m_wth-obj-inc-ret-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&return},{&WDEDT_Ret_Int},{&fact}) .
  end.
end procedure. /* m_wth-obj-inc-ret-fact-exe */

procedure m_wth-obj-inc-ret-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&return},{&WDEDT_Ret_Int},{&all}) .
  end.
end procedure. /* m_wth-obj-inc-ret-all-exe */


procedure m_wth-obj-put-ch-all-exe:      /*погашение через кассу*/

  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&income},{&WDEDT_Put_Cash},{&all}) .
  end.
end procedure. /* m_wth-obj-put-ch-all-exe */
procedure m_wth-obj-put-sl-new-exe   /*погашение за реализованное топливо*/
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&income},{&WDEDT_Put_Sale},{&wayb}) .
  end.
end procedure. /* m_wth-obj-put-sl-new-exe */

procedure m_wth-obj-put-sl-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&income},{&WDEDT_Put_Sale},{&fact}) .
  end.
end procedure. /* m_wth-obj-put-sl-fact-exe */

procedure m_wth-obj-put-sl-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&income},{&WDEDT_Put_Sale},{&all}) .
  end.
end procedure. /* m_wth-obj-put-sl-all-exe */
procedure m_wth-obj-put-zc-new-exe   /*погашение за нереализованное топливо*/
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&income},{&WDEDT_Put_Cli},{&wayb}) .
  end.
end procedure. /* m_wth-obj-put-zc-new-exe */

procedure m_wth-obj-put-zc-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&income},{&WDEDT_Put_Cli},{&fact}) .
  end.
end procedure. /* m_wth-obj-put-zc-fact-exe */

procedure m_wth-obj-put-zc-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&income},{&WDEDT_Put_Cli},{&all}) .
  end.
end procedure. /* m_wth-obj-put-zc-all-exe */
procedure m_wth-obj-ex-new-exe   /* обмен */
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&exchange},{&WDEDT_exch},{&wayb}) .
  end.
end procedure. /* m_wth-obj-ex-new-exe */

procedure m_wth-obj-ex-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&exchange},{&WDEDT_exch},{&fact}) .
  end.
end procedure. /* m_wth-obj-ex-fact-exe */

procedure m_wth-obj-ex-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&exchange},{&WDEDT_exch},{&all}) .
  end.
end procedure. /* m_wth-obj-ex-all-exe */

procedure m_wth-obj-dst-zf-new-exe   /*акт уничтожения свободной зоны*/
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&write-off},{&WDEDT_Dst_free},{&wayb}) .
  end.
end procedure. /* m_wth-obj-dst-zf-new-exe */

procedure m_wth-obj-dst-zf-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&write-off},{&WDEDT_Dst_Free},{&fact}) .
  end.
end procedure. /* m_wth-obj-dst-zf-fact-exe */

procedure m_wth-obj-dst-zf-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&write-off},{&WDEDT_Dst_free},{&all}) .
  end.
end procedure. /* m_wth-obj-dst-zf-all-exe */

procedure m_wth-obj-dst-zp-new-exe   /*акт уничтожения зоны погашения*/
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&write-off},{&WDEDT_Dst_Put},{&wayb}) .
  end.
end procedure. /* m_wth-obj-dst-zp-new-exe */

procedure m_wth-obj-dst-zp-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&write-off},{&WDEDT_Dst_Put},{&fact}) .
  end.
end procedure. /* m_wth-obj-dst-zp-fact-exe */

procedure m_wth-obj-dst-zp-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&write-off},{&WDEDT_Dst_Put},{&all}) .
  end.
end procedure. /* m_wth-obj-dst-zp-all-exe */



procedure m_wth-obj-dst-zc-new-exe   /*акт уничтожения талонов, принадлежащих покупателю*/
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&write-off},{&WDEDT_Dst_Cli},{&wayb}) .
  end.
end procedure. /* m_wth-obj-dst-zc-new-exe */

procedure m_wth-obj-dst-zc-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&write-off},{&WDEDT_Dst_Cli},{&fact}) .
  end.
end procedure. /* m_wth-obj-dst-zc-fact-exe */

procedure m_wth-obj-dst-zc-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type',{&write-off},{&WDEDT_Dst_cli},{&all}) .
  end.
end procedure. /* m_wth-obj-dst-zc-all-exe */

procedure m_par-obj-inv-exe :

  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type':U,{&inventory},{&WDEDT_Inv},'':U) .
  end.

end procedure. /* m_par-obj-inv-exe */

procedure m_par-obj-dec-exe :

  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type':U,{&declaration},{&WDEDT_Dec},'':U) .
  end.

end procedure. /* m_par-obj-inv-exe */


procedure m_c-wth-doc-obj-all-exe :

  do
  on error undo, return error return-value
  :
    run c-wth-doc-exe({&g___object}, '':U) .
  end.

end procedure. /* m_c-wth-doc-obj-all-exe */

procedure m_c-wth-doc-cmp-all-exe :

  do
  on error undo, return error return-value
  :
    run c-wth-doc-exe({&company}, '':U) .
  end.

end procedure. /* m_c-wth-doc-cmp-all-exe */

procedure m_c-wth-doc-all-all-exe :

  do
  on error undo, return error return-value
  :
    run c-wth-doc-exe({&all}, '':U) .
  end.

end procedure. /* m_c-wth-doc-all-all-exe */

procedure c-obj-ext-in-exe :

  do
  on error undo, return error return-value
  :
    run dm-c-doc-exe in this-procedure (INPUT {&c-type}, INPUT ?, INPUT '?', INPUT {&income}, INPUT no, INPUT {&TDEDT_Pri_Vnesh}, input ? ) .
  end.

end procedure. /* c-obj-ext-in-exe */

procedure c-obj-ext-in-ho-exe :

  do
  on error undo, return error return-value
  :
    run dm-c-doc-exe in this-procedure (INPUT {&c-type}, INPUT ?, INPUT '?', INPUT {&income}, INPUT no, INPUT {&TDEDT_Pri_Vnesh}, input no) .
  end.

end procedure. /* c-obj-ext-in-ho-exe */

procedure c-obj-ext-out-exe :

  do
  on error undo, return error return-value
  :
    run dm-c-doc-exe in this-procedure (INPUT {&c-type}, INPUT ?, INPUT '?', INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh}, input ? ) .
  end.

end procedure. /* c-obj-ext-out-exe */

procedure c-obj-ext-out-ho-exe :

  do
  on error undo, return error return-value
  :
    run dm-c-doc-exe in this-procedure (INPUT {&c-type}, INPUT ?, INPUT '?', INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh}, input no) .
  end.

end procedure. /* c-obj-ext-out-ho-exe */

procedure c-obj-ext-out-kass-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-c-doc-exe in this-procedure (INPUT {&c-type}, INPUT ?, INPUT '?', INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh_Kass}, input ? ) .
  end.

end procedure. /* c-obj-ext-out-kass-all-exe */

procedure c-obj-ext-sup-exe :

  do
  on error undo, return error return-value
  :
    run dm-c-doc-exe in this-procedure (INPUT {&c-type}, INPUT ?, INPUT '?', INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh_VP}, input ? ) .
  end.

end procedure. /* c-obj-ext-sup-exe */

procedure c-obj-ext-sup-ho-exe :
  do on error undo, return error return-value :
    run dm-c-doc-exe in this-procedure ( input {&c-type},
                                         input ?,
                                         input '?',
                                         input {&expense},
                                         input no,
                                         input {&TDEDT_Ras_Vnesh_VP},
                                         input no ).
  end.
end procedure. /* c-obj-ext-sup-ho-exe */

procedure c-obj-ext-ret-exe :

  do
  on error undo, return error return-value
  :
    run dm-c-doc-exe in this-procedure (INPUT {&c-type}, INPUT ?, INPUT '?', INPUT {&return}, INPUT no, INPUT {&TDEDT_Vozvrat_Vnesh}, input ? ) .
  end.

end procedure. /* c-obj-ext-ret-exe */

procedure c-obj-ext-ret-ho-exe :
  do on error undo, return error return-value :
    run dm-c-doc-exe in this-procedure ( input {&c-type},
                                         input ?,
                                         input '?',
                                         input {&return},
                                         input no,
                                         input {&TDEDT_Vozvrat_Vnesh},
                                         input no ).
  end.
end procedure. /* c-obj-ext-ret-ho-exe */

procedure c-obj-ext-retc-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-c-doc-exe in this-procedure (INPUT {&c-type}, INPUT ?, INPUT '?', INPUT {&return}, INPUT no, INPUT {&TDEDT_Vozvrat_Vnesh_Kass}, input ? ) .
  end.

end procedure. /* c-obj-ext-retc-all-exe */

procedure c-obj-aw-exe :

  do
  on error undo, return error return-value
  :
    run dm-c-doc-exe in this-procedure (INPUT {&c-type}, INPUT ?, INPUT '?', INPUT {&write-off}, INPUT no, INPUT {&TDEDT_Spi_Vnesh}, input ? ) .
  end.

end procedure. /* c-obj-aw-exe */

procedure c-obj-cpc-exe :
  do
  on error undo, return error return-value
  :
  run dm-c-doc-exe in this-procedure (INPUT {&c-type}, INPUT ?, INPUT '?', INPUT {&inventory}, INPUT no,  INPUT {&TDEDT_Chg_Purch_Code}, INPUT ? ).
  end.
end procedure. /* c-obj-cpc-exe */

procedure c-obj-cmp-exe :
  do
  on error undo, return error return-value
  :
  run dm-c-doc-exe in this-procedure (INPUT {&c-type}, INPUT ?, INPUT '?', INPUT {&inventory}, INPUT no,  INPUT {&TDEDT_Corr_Minus_Parts}, INPUT ? ).
  end.
end procedure. /* c-obj-cmp-exe */

procedure c-obj-in-in-exe :

  do
  on error undo, return error return-value
  :
    run dm-c-doc-exe in this-procedure (INPUT {&c-type}, INPUT ?, INPUT '?', INPUT {&income}, INPUT yes, INPUT {&TDEDT_Pri_Perem}, input ? ) .
  end.

end procedure. /* c-obj-in-in-exe */

procedure c-obj-in-out-exe :

  do
  on error undo, return error return-value
  :
    run dm-c-doc-exe in this-procedure (INPUT {&c-type}, INPUT ?, INPUT '?', INPUT {&expense}, INPUT yes, INPUT {&TDEDT_Ras_Perem}, input ? ) .
  end.

end procedure. /* c-obj-in-out-exe */

procedure c-obj-in-ret-exe :

  do
  on error undo, return error return-value
  :
    run dm-c-doc-exe in this-procedure (INPUT {&c-type}, INPUT ?, INPUT '?', INPUT {&return}, INPUT yes, INPUT {&TDEDT_Vozvrat_Perem}, input ? ) .
  end.

end procedure. /* c-obj-in-ret-exe */

procedure c-obj-in-prvo-exe :

  do
  on error undo, return error return-value
  :
    run dm-c-doc-exe in this-procedure (INPUT {&c-type}, INPUT ?, INPUT '?', INPUT {&income}, INPUT yes, INPUT {&TDEDT_Pri_Prvo}, input ? ) .
  end.

end procedure. /* c-obj-in-prvo-exe */

procedure c-obj-spis-prv-exe :

  do
  on error undo, return error return-value
  :
    run dm-c-doc-exe in this-procedure (INPUT {&c-type}, INPUT ?, INPUT '?', INPUT {&write-off}, INPUT yes, INPUT {&TDEDT_Spi_Prvo}, input ? ) .
  end.

end procedure. /* c-obj-spis-prv-exe */

procedure c-obj-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-c-doc-exe in this-procedure (INPUT {&c-g___object}, INPUT ?, INPUT '?', INPUT '?', INPUT ?, INPUT {&TDEDT_Vozvrat_Perem}, input ? ) .
  end.

end procedure. /* c-obj-all-exe */

procedure c-m-host-exe :

  do
  on error undo, return error return-value
  :
    run dm-c-doc-exe in this-procedure (INPUT {&c-company}, INPUT ?, INPUT '?', INPUT '?', INPUT ?, INPUT {&TDEDT_Vozvrat_Perem}, input ? ) .
  end.

end procedure. /* c-m-host-exe */

procedure m-a-f-n1-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'obj':U , {&o-f} , {&g___new} ) .

  end.

end procedure. /* m-a-f-n1-exe */

procedure m-all-of-u-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'firm':U,{&o-f},{&ord-accept}) .
  end.

end procedure. /* m-all-of-u-exe */

procedure m-all-of-o-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'firm':U,{&o-f},{&ord-rejection}) .
  end.

end procedure. /* m-all-of-o-exe */

procedure m-all-of-u1-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'firm':U,{&o-f},{&ord-rcv}) .
  end.

end procedure. /* m-all-of-u1-exe */

procedure m-all-of-u2-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'firm':U,{&o-f},{&ord-close}) .
  end.

end procedure. /* m-all-of-u2-exe */

procedure m-all-of-fact-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'firm':U,{&o-f},{&fact}) .
  end.

end procedure. /* m-all-of-fact-exe */

procedure m-all-of-all-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'firm':U,{&o-f},'all':U) .
  end.

end procedure. /* m-all-of-all-exe */

procedure m-allsupp1-of-new-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'obj':U,{&o-f},{&g___new}) .
  end.

end procedure. /* m-allsupp1-of-new-exe */

procedure m-allsupp1-of-u-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'obj':U,{&o-f},{&ord-accept}) .
  end.

end procedure. /* m-allsupp1-of-u-exe */

procedure m-allsupp1-of-o1-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'obj':U,{&o-f},{&ord-rejection}) .
  end.

end procedure. /* m-allsupp1-of-o1-exe */

procedure m-allsupp1-of-o2-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'obj':U,{&o-f},{&ord-rcv}) .
  end.

end procedure. /* m-allsupp1-of-o2-exe */

procedure m-allsupp1-of-o3-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'obj':U,{&o-f},{&ord-close}) .
  end.

end procedure. /* m-allsupp1-of-o3-exe */

procedure m-allsupp1-of-fact-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'obj':U,{&o-f},{&fact}) .
  end.

end procedure. /* m-allsupp1-of-fact-exe */

procedure m-allsupp1-of-all-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'obj':U,{&o-f},'all':U) .
  end.

end procedure. /* m-allsupp1-of-all-exe */

procedure m-all-suppfp-new-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'obj':U,{&o-p},{&g___new}) .
  end.

end procedure. /* m-all-suppfp-new-exe */

procedure m-all-suppfp-razr1-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'obj':U,{&o-p},{&ord-accept}) .
  end.

end procedure. /* m-all-suppfp-razr1-exe */

procedure m-all-suppfp-razr2-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'obj':U,{&o-p},{&ord-rejection}) .
  end.

end procedure. /* m-all-suppfp-razr2-exe */

procedure m-all-suppfp-razr3-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'obj':U,{&o-p},{&ord-rcv}) .
  end.

end procedure. /* m-all-suppfp-razr3-exe */

procedure m-all-suppfp-razr4-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'obj':U,{&o-p},{&ord-close}) .
  end.

end procedure. /* m-all-suppfp-razr4-exe */

procedure m-all-suppfp-fact-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'obj':U,{&o-p},{&fact}) .
  end.

end procedure. /* m-all-suppfp-fact-exe */

procedure m-all-suppfp-all-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'obj':U,{&o-p},'all':U) .
  end.

end procedure. /* m-all-suppfp-all-exe */

procedure m-all-suppfp-new-f-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'firm':U,{&o-p},{&g___new}) .
  end.

end procedure. /* m-all-suppfp-new-f-exe */

procedure m-all-suppfp-razr-f1-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'firm':U,{&o-p},{&ord-accept}) .
  end.

end procedure. /* m-all-suppfp-razr-f1-exe */

procedure m-all-suppfp-razr-f2-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'firm':U,{&o-p},{&ord-rejection}) .
  end.

end procedure. /* m-all-suppfp-razr-f2-exe */

procedure m-all-suppfp-razr-f3-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'firm':U,{&o-p},{&ord-rcv}) .
  end.

end procedure. /* m-all-suppfp-razr-f3-exe */

procedure m-all-suppfp-razr-f4-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'firm':U,{&o-p},{&ord-close}) .
  end.

end procedure. /* m-all-suppfp-razr-f4-exe */

procedure m-all-suppfp-fact-f5-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'firm':U,{&o-p},{&fact}) .
  end.

end procedure. /* m-all-suppfp-fact-f5-exe */

procedure m-all-oo-new-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'obj':U,{&o-o},{&g___new}) .
  end.

end procedure. /* m-all-oo-new-exe */

procedure m-all-oo-razr-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'obj':U,{&o-o},{&ord-req}) .
  end.

end procedure. /* m-all-oo-razr-exe */

procedure m-all-oo-fact-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'obj':U,{&o-o},{&fact}) .
  end.

end procedure. /* m-all-oo-fact-exe */

procedure m-all-oo-all-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'obj':U,{&o-o},'all':U) .
  end.

end procedure. /* m-all-oo-all-exe */

procedure m-all-suppfp-all-f-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'firm':U,{&o-p},'all':U) .
  end.

end procedure. /* m-all-suppfp-all-f-exe */

procedure m-all-fp-new-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'firm':U,{&f-p},{&g___new}) .
  end.

end procedure. /* m-all-fp-new-exe */

procedure m-all-fp-razr-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'firm':U,{&f-p},{&ord-rcv}) .
  end.

end procedure. /* m-all-fp-razr-exe */

procedure m-all-fp-cl-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'firm':U,{&f-p},{&ord-close}) .
  end.

end procedure. /* m-all-fp-cl-exe */

procedure m-all-fp-fact-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'firm':U,{&f-p},{&fact}) .
  end.

end procedure. /* m-all-fp-fact-exe */

procedure m-all-fp-all-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'firm':U,{&f-p},'all':U) .
  end.

end procedure. /* m-all-fp-all-exe */

procedure ord-supp-all-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'obj':U,'all':U,'all':U) .
  end.

end procedure. /* ord-supp-all-exe */

procedure m-all-af-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'firm':U,'all':U,'all':U) .
  end.

end procedure. /* m-all-af-exe */
/*--------*/
procedure m-all-recive1-conso1-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-cons.w (parparentproc , {&g___new} , "obj":U ) .
  end.

end procedure. /* m-all-recive1-cons1-exe */


procedure m-all-recive1-conso2-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-cons.w (parparentproc , {&ord-alloc} , "obj":U ) .
  end.

end procedure. /* m-all-reciveo1-cons2-exe */

procedure m-all-recive1-conso3-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-cons.w (parparentproc , {&ord-close} , "obj":U ) .
  end.

end procedure. /* m-all-recive1-cons3-exe */

procedure m-all-recive1-conso4-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-cons.w (parparentproc , {&fact} , "obj":U ) .
  end.

end procedure. /* m-all-reciveo1-cons4-exe */

procedure m-all-recive1-conso5-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-cons.w (parparentproc , "all":U , "obj":U ) .
  end.

end procedure. /* m-all-reciveo1-conso5-exe */



/*------*/
procedure m-all-recive1-cons1-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-cons.w (parparentproc , {&g___new} , "firm":U ) .
  end.

end procedure. /* m-all-recive1-cons1-exe */


procedure m-all-recive1-cons2-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-cons.w (parparentproc , {&ord-alloc} , "firm":U ) .
  end.

end procedure. /* m-all-recive1-cons2-exe */

procedure m-all-recive1-cons3-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-cons.w (parparentproc , {&ord-close} , "firm":U ) .
  end.

end procedure. /* m-all-recive1-cons3-exe */

procedure m-all-recive1-cons4-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-cons.w (parparentproc , {&fact} , "firm":U ) .
  end.

end procedure. /* m-all-recive1-cons4-exe */

procedure m-all-recive1-cons5-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-cons.w (parparentproc , 'all':U , "firm":U ) .
  end.

end procedure. /* m-all-recive1-cons5-exe */

procedure m-all-recive1-4-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p (parparentproc , 'obj':U,'out':U,{&ord-rcv}) .
  end.

end procedure. /* m-all-recive1-4-exe */

procedure m-all-recive1-2-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p ( parparentproc , 'obj':U,'out':U,{&fact}) .
  end.

end procedure. /* m-all-recive1-2-exe */

procedure m-all-recive1-3-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p (parparentproc , 'obj':U,'out':U,'all':U) .
  end.

end procedure. /* m-all-recive1-3-exe */

procedure m-all-recive2-2-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p (parparentproc , 'obj':U,'in':U,{&ord-rcv}) .
  end.

end procedure. /* m-all-recive2-2-exe */

procedure m-all-recive2-4-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p (parparentproc , 'obj':U,'in':U,{&fact}) .
  end.

end procedure. /* m-all-recive2-4-exe */

procedure m-all-recive2-3-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p (parparentproc , 'obj':U,'in':U,'all':U) .
  end.

end procedure. /* m-all-recive2-3-exe */

procedure m-all-recive1-1-2-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p (parparentproc , 'firm':U,'out':U,{&g___new}) .
  end.

end procedure. /* m-all-recive1-1-2-exe */

procedure m-all-recive1-4-2-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p (parparentproc , 'firm':U,'out':U,{&ord-rcv}) .
  end.

end procedure. /* m-all-recive1-4-2-exe */

procedure m-all-recive1-2-2-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p (parparentproc , 'firm':U,'out':U,{&fact}) .
  end.

end procedure. /* m-all-recive1-2-2-exe */

procedure m-all-recive1-3-2-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p (parparentproc , 'firm':U,'out':U,'all':U) .
  end.

end procedure. /* m-all-recive1-3-2-exe */


procedure m-all-recive2-1-2-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p (parparentproc , 'firm':U,'in':U,{&g___new}) .
  end.

end procedure. /* m-all-recive2-1-2-exe */

procedure m-all-recive2-2-2-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p (parparentproc , 'firm':U,'in':U,{&ord-rcv}) .
  end.

end procedure. /* m-all-recive2-2-2-exe */

procedure m-all-recive2-4-2-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p (parparentproc , 'firm':U,'in':U,{&fact}) .
  end.

end procedure. /* m-all-recive2-4-2-exe */

procedure m-all-recive2-3-2-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p (parparentproc , 'firm':U,'in':U,'all':U) .
  end.

end procedure. /* m-all-recive2-3-2-exe */

procedure m-all-recive02-2-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p (parparentproc , 'cli':U,'in':U,{&ord-rcv}) .
  end.

end procedure. /* m-all-recive02-2-exe */

procedure m-all-recive02-4-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p (parparentproc , 'cli':U,'in':U,{&fact}) .
  end.

end procedure. /* m-all-recive02-4-exe */

procedure m-all-recive02-3-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p (parparentproc , 'cli':U,'in':U,'all':U) .
  end.

end procedure. /* m-all-recive02-3-exe */

procedure m-all-recive3-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p (parparentproc , 'obj':U,'all':U,'all':U) .
  end.

end procedure. /* m-all-recive3-exe */

procedure m-all-recive4-exe :

  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p ( parparentproc , 'firm':U,'all':U,'all':U) .
  end.

end procedure. /* m-all-recive4-exe */

procedure obj-pln-new-exe :

  do
  on error undo, return error return-value
  :
    run str/fbr-plns.w
      (input  parparentproc
      ,input  {&g___new}
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  v-cntxt-userid
      ) .
  end.

end procedure. /* obj-pln-new-exe */

procedure obj-pln-permitted-exe :

  do
  on error undo, return error return-value
  :
    run str/fbr-plns.w
      (input  parparentproc
      ,input  {&permitted}
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  v-cntxt-userid
      ) .
  end.

end procedure. /* obj-pln-permitted-exe */

procedure obj-pln-closed-exe :

  do
  on error undo, return error return-value
  :
    run str/fbr-plns.w
      (input  parparentproc
      ,input  {&fact}
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  v-cntxt-userid
      ) .
  end.

end procedure. /* obj-pln-closed-exe */

procedure proc-fbr-doc :
define input parameter p-status as character no-undo .
define input parameter p-list-mode as character no-undo .
define variable v-rid-list as character no-undo .

  do
  on error undo, return error
  :
    run str/fbr-docs.w
      (input  parparentproc /* parparentproc */
      ,input  p-status     /* p-status      */
      ,input  p-list-mode  /* p-list-mode   */
      ,input-output v-rid-list
      ) .

  end.

end procedure. /* proc-fbr-doc */

procedure obj-fbr-new-exe :
    run proc-fbr-doc in this-procedure (
          input {&g___new}
        , input {&status}
    ).
end procedure. /* obj-fbr-new-exe */

procedure obj-fbr-perm-exe :
    run proc-fbr-doc in this-procedure (
          input {&permitted}
        , input {&status}
    ).
end procedure. /* obj-fbr-perm-exe */

procedure obj-fbr-close-exe :
    run proc-fbr-doc in this-procedure (
          input {&fact}
        , input {&status}
    ).
end procedure. /* obj-fbr-close-exe */

procedure obj-fbr-froze-exe :
    run proc-fbr-doc in this-procedure (
          input {&status}
        , input {&doc-froze}
    ).
end procedure. /* obj-fbr-froze-exe */

procedure obj-fbr-exe :
    run proc-fbr-doc in this-procedure (
          input "":U
        , input {&g___object}
    ).
end procedure.
procedure firm-fbr-exe :
    run proc-fbr-doc in this-procedure (
          input "":U
        , input {&company}
    ).
end procedure.

procedure proc-cash-gds :
define input parameter p-mode as character no-undo .
  define variable v-host-code as integer no-undo .
  do
  on error undo, return error return-value
  :
    { gbl/hostcode.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-host-code
    }
    run str/gds-cash.p (
                     input parparentproc
                   , input v-host-code
                   , input v-cntxt-obj-type
                   , input v-cntxt-obj-code
                   , p-mode) .

  end.
end procedure.

procedure m-cash-gds-exe :
run proc-cash-gds in this-procedure ('cash').
end procedure. /* m-cash-gds-exe */

procedure m-infokiosk-exe :
run proc-cash-gds in this-procedure ({&cd-type-infokiosk}).
end procedure.

procedure m_lst-inv-exe :
run proc-cash-gds in this-procedure ('qnty').
end procedure. /* m_lst-inv-exe */


procedure m-cash-KKT-with-exe :
   
   
   run str/diallog.w (
      input parparentproc
      , input this-procedure
      , input "str/sendkkt.p":U
      , input ( v-cntxt-obj-type + {&delim-par} + string(v-cntxt-obj-code) + {&delim-par} + 'U':U + {&delim-par} + "0")
      , input no /*p-auto-go*/
      , input "":U
      , input substitute("Отсылка схемы интеграции ККТ ")
      ) no-error.   
   if error-status:error then 
   do:
      message "Не удалось отправить схему интеграции ККТ на кассу"
         view-as alert-box.
   end.      

end procedure. /* m-cash-KKT-with-exe */

procedure m-cash-KKT-without-exe :
   
   run str/diallog.w (
      input parparentproc
      , input this-procedure
      , input "str/sendkkt.p":U
      , input ( v-cntxt-obj-type + {&delim-par} + string(v-cntxt-obj-code) + {&delim-par} + 'U':U + {&delim-par} + "1")
      , input no /*p-auto-go*/
      , input "":U
      , input substitute("Отсылка схемы интеграции ККТ ")
      ) no-error.   
   if error-status:error then 
   do:
      message "Не удалось отправить схему интеграции ККТ на кассу"
         view-as alert-box.
   end.      

end procedure. /* m-cash-KKT-without-exe */

procedure m-cash-pay-exe :

  do
  on error undo, return error return-value
  :
    run run-2cashpay in this-procedure ({&cd-type-ibm}, 'U':U) .
  end.

end procedure. /* m-cash-pay-exe */

procedure m-cash-pay-curr-exe :

  do
  on error undo, return error return-value
  :
    run run-2cashpay in this-procedure ({&cd-type-MAGIA-XML}, 'U':U) .
  end.

end procedure. /* m-cash-pay-curr-exe */

procedure m-cashiers-exe :

  do
  on error undo, return error return-value
  :
    run str/sndcash.p (parparentproc, input v-cntxt-obj-code, 'U' ) .
  end.

end procedure. /* m-cashiers-exe */

procedure m-sellers-exe :

  do
  on error undo, return error return-value
  :
    run str/sndsell.p (parparentproc, input v-cntxt-obj-code, 'U' ) .
  end.

end procedure. /* m-sellers-exe */

procedure m-staff-exe :

  do
  on error undo, return error return-value
  :
    run str/sndstaf.p
      (input  parparentproc
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  'U'
      ) .
  end.

end procedure. /* m-staff-exe */

procedure m-fgrp-exe :

  do
  on error undo, return error return-value
  :
    run str/sndfgrp.p (parparentproc, v-cntxt-obj-code, 'U' ) .
  end.

end procedure. /* m-fgrp-exe */

procedure m-cash-dc-mask-exe :

  do
  on error undo, return error return-value
  :
    run str/diallog.w (parparentproc, this-procedure, 'str/senddcty.p':U, (v-cntxt-obj-type + {&delim-par} + string(v-cntxt-obj-code) + {&delim-par} + 'U'), no, '', 'Отправка информации по типам-маскам карт') .
  end.

end procedure. /* m-cash-dc-mask-exe */

procedure m-cash-cli-exe :

  define variable v-obj-db-num  as integer   no-undo initial ? .

  do
  on error undo, return error return-value
  :
    { gbl/objdbnum.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-obj-db-num
    }

    run str/diallog.w
      (input  parparentproc
      ,input  this-procedure
      ,input  'str/cash-cli.p':U
      ,input  (string(v-obj-db-num) + {&delim-par} + v-cntxt-obj-type + {&delim-par} + string(v-cntxt-obj-code) + {&delim-par} + 'U')
      ,input  no
      ,input  ''
      ,input  'Отправка информации по диск.картам'
      ) .
  end.

end procedure. /* m-cash-cli-exe */

procedure m-tot-d-u-exe :

  do
  on error undo, return error return-value
  :
    run str/diallog.w (parparentproc, this-procedure, 'str/sendtotd.p':U, (string(v-cntxt-obj-code) + {&delim-par} + 'U' + {&delim-par} + 'all':U), no, '', 'Отправка информации по скидкам на итог чека') .
  end.

end procedure. /* m-tot-d-u-exe */

procedure m-tax-n-u-shop-exe :

  do
  on error undo, return error return-value
  :
    run str/send-tax.p (parparentproc, {&cd-type-ibm}, v-cntxt-obj-type, v-cntxt-obj-code, 'U') .
  end.

end procedure. /* m-tax-n-u-shop-exe */

procedure m-cash-db-objs-exe :

  define variable v-obj-db-num  as integer   no-undo initial ? .

  do
  on error undo, return error return-value
  :
    { gbl/objdbnum.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-obj-db-num
    }

    run str/diallog.w
      (input  parparentproc
      ,input  this-procedure
      ,input  'str/sendobjs.p':U
      ,input  (string(v-obj-db-num) + {&delim-par} + string(v-cntxt-obj-code) + {&delim-par} + 'U')
      ,input  no
      ,input  ''
      ,input  'Отправка информации по объектам БД'
      ) .
  end.

end procedure. /* m-cash-db-objs-exe */

procedure m-cash-db-objs-del-exe :

  define variable v-obj-db-num  as integer   no-undo initial ? .

  do
  on error undo, return error return-value
  :
    { gbl/objdbnum.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-obj-db-num
    }

    run str/diallog.w
      (input  parparentproc
      ,input  this-procedure
      ,input  'str/sendobjs.p':U
      ,input  (string(v-obj-db-num) + {&delim-par} + string(v-cntxt-obj-code) + {&delim-par} + 'D')
      ,input  no
      ,input  ''
      ,input  'Удаление информации по объектам БД'
      ) .
  end.

end procedure. /* m-cash-db-objs-del-exe */

procedure m-cash-pet-exe :

  do
  on error undo, return error return-value
  :

    run str/diallog.w
      (input  parparentproc
      ,input  this-procedure
      ,input  'str/send-pet.p':U
      ,input  (v-cntxt-obj-type + {&delim-par} + string(v-cntxt-obj-code) + {&delim-par} + 'U')
      ,input  no
      ,input  ''
      ,input  'Отправка конфигурации АЗК'
      ) no-error .
  end.

end procedure. /* m-cash-pet-exe */


procedure m-cash-pet-del-exe :

  do
  on error undo, return error return-value
  :
    run str/diallog.w
      (input  parparentproc
      ,input  this-procedure
      ,input  'str/send-pet.p':U
      ,input  (v-cntxt-obj-type + {&delim-par} + string(v-cntxt-obj-code) + {&delim-par} + 'D')
      ,input  no
      ,input  ''
      ,input  'Очистка конфигурации АЗК'
      ) no-error .
  end.

end procedure. /* m-cash-pet-del-exe */

procedure m-del-all-gds-exe :

  do
  on error undo, return error return-value
  :
    run str/diallog.w (parparentproc, this-procedure, 'str/del-gds.p':U, string(v-cntxt-obj-code), no, 'Прервать', 'Удаление товаров с касс') .
  end.

end procedure. /* m-del-all-gds-exe */

procedure m-cash-pay-del-exe :

  do
  on error undo, return error return-value
  :
    run run-2cashpay in this-procedure ({&cd-type-ibm}, 'D':U) .
  end.

end procedure. /* m-cash-pay-del-exe */

procedure m-cash-pay-curr-del-exe :

  do
  on error undo, return error return-value
  :
    run run-2cashpay in this-procedure ({&cd-type-MAGIA-XML}, 'D':U) .
  end.

end procedure. /* m-cash-pay-curr-del-exe */

procedure m-cashiers-del-exe :

  do
  on error undo, return error return-value
  :
    run str/sndcash.p (parparentproc, input v-cntxt-obj-code, 'D' ) .
  end.

end procedure. /* m-cashiers-del-exe */

procedure m-sellers-del-exe :

  do
  on error undo, return error return-value
  :
    run str/sndsell.p (parparentproc, input v-cntxt-obj-code, 'D' ) .
  end.

end procedure. /* m-sellers-del-exe */

procedure m-staff-del-exe :

  do
  on error undo, return error return-value
  :
    run str/sndstaf.p
      (input  parparentproc
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  'D'
      ) .
  end.

end procedure. /* m-staff-del-exe */

procedure m-fgrp-del-exe :

  do
  on error undo, return error return-value
  :
    run str/sndfgrp.p (parparentproc, v-cntxt-obj-code, 'D' ) .
  end.

end procedure. /* m-fgrp-del-exe */

procedure m-cash-dc-mask-del-exe :

  do
  on error undo, return error return-value
  :
    run str/diallog.w (parparentproc, this-procedure, 'str/senddcty.p':U, (v-cntxt-obj-type + {&delim-par} + string(v-cntxt-obj-code) + {&delim-par} + 'D'), no, '', 'Удаление информации по типам-маскам карт') .
  end.

end procedure. /* m-cash-dc-mask-del-exe */

procedure m-cash-cli-del-exe :

  define variable v-obj-db-num  as integer   no-undo initial ? .

  do
  on error undo, return error return-value
  :
    { gbl/objdbnum.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-obj-db-num
    }

    run str/diallog.w
      (input  parparentproc
      ,input  this-procedure
      ,input  'str/cash-cli.p':U
      ,input  (string(v-obj-db-num) + {&delim-par} + v-cntxt-obj-type + {&delim-par} + string(v-cntxt-obj-code) + {&delim-par} + 'D')
      ,input  no
      ,input  ''
      ,input  'Удаление информации по диск.картам'
      ) .
  end.

end procedure. /* m-cash-cli-del-exe */

procedure m-tot-d-d-exe :

  do
  on error undo, return error return-value
  :
    run str/diallog.w (parparentproc, this-procedure, 'str/sendtotd.p':U, (string(v-cntxt-obj-code) + {&delim-par} + 'D' + {&delim-par} + 'all':U), no, '', 'Удаление информации по скидкам на итог чека') .
  end.

end procedure. /* m-tot-d-d-exe */

procedure m-tax-n-d-shop-exe :

  do
  on error undo, return error return-value
  :
    run str/send-tax.p (parparentproc, {&cd-type-ibm}, v-cntxt-obj-type, v-cntxt-obj-code, 'D') .
  end.

end procedure. /* m-tax-n-d-shop-exe */

procedure m-cash-inf-exe :

  do
  on error undo, return error return-value
  :
    run str/cd-inf.p (parparentproc, yes, no) .
  end.

end procedure. /* m-cash-inf-exe */

procedure m-cash-chk-exe :

  do
  on error undo, return error return-value
  :
    run str/diallog.w (parparentproc, this-procedure, 'str/get-chkf.p':U, (v-cntxt-obj-type + {&delim-par} + string(v-cntxt-obj-code) + {&delim-par} + string(0)), no, '', 'Прием чеков с касс') .
  end.

end procedure. /* m-cash-chk-exe */

procedure m-cash-report-exe :

  do
  on error undo, return error return-value
  :
    run str/diallog.w (parparentproc, this-procedure, 'str/get-repf.p':U, (v-cntxt-obj-type + {&delim-par} + string(v-cntxt-obj-code) + {&delim-par} + string(0)), no, '', 'Прием отчетов с касс') .
  end.

end procedure. /* m-cash-report-exe */

procedure m-cash-chk-remote-exe :

  do
  on error undo, return error return-value
  :
    run str/diallog.w (parparentproc, this-procedure, 'str/get-chkf.p':U, (v-cntxt-obj-type + {&delim-par} + string(v-cntxt-obj-code) + {&delim-par} + string(1)), no, '', 'Запрос на удаленные кассы') .
  end.

end procedure. /* m-cash-chk-remote-exe */

procedure m_sysconf-list-exe :

  define variable v-host-code as integer   no-undo .
  define variable ri-list     as character no-undo .

  do
  on error undo, return error return-value
  :
    run adm/sconfs.w
      (input  parparentproc
      ,input  'b-add,b-attr-copy,b-attr-update':U
      ,input  no
      ,input  v-cntxt-host-code-obj
      ,output v-host-code
      ,input-output ri-list
      ) .
  end.

end procedure. /* m_sysconf-list-exe */

procedure m_action-role :

  define variable v-action-role-code as integer   no-undo .
  define variable v-rid-list         as character no-undo .
  define variable v-context          as character no-undo .

  do
  on error undo, return error return-value
  :
    ASSIGN
      v-context = 'All':U
    .
    run str/actnrole.w ( input  parparentproc
                       , input  'b-add,rs-scope':U
                       , input-output v-context
                       , output v-action-role-code
                       , input-output v-rid-list
                       , input v-cntxt-db-num 
                       ) .
  end.

end procedure. /* m_action-role */

procedure m-smart-ref :
  do
  on error undo, return error
  :
    
  run ref/codelay.p (parparentproc, "", "", "SpravAttrSmart", "Справочник атрибутов SMART") no-error.
  
  end.

end procedure. /* m-hdd-ref */

procedure m-hdd-ref :
  do
  on error undo, return error
  :
    
  run ref/hdd.p ( input parparentproc, input v-cntxt-db-num) no-error.
  
  end.

end procedure. /* m-hdd-ref */

procedure m-cashp-ref :
  do
  on error undo, return error
  :
  define buffer code for ub.code.
  find first code where code.parent eq ""
                    and code.code eq "cash-param"
  no-lock no-error.
  if not avail code
  then do:
     message "Справочник не найден." view-as alert-box.
     return.
  end.  
  run ref/cashpargroup.w ( input  parparentproc
                     ,input  if isERPRN then {&lookup} else {&update}
                     ,input  ""
                     ,input "cash-param"
                     ,input ?
                    ) .
  
  end.

end procedure. /* m-hdd-ref */

procedure m-code-ref :
  do
  on error undo, return error
  :
  define buffer code for ub.code.
  run ref/codelay.p ( input  parparentproc
                      ,input  {&lookup}
                      ,input  ""
                      ,input  ""
                      ,input  "Дополнительные справочники системы"
                        ) .
  
  end.

end procedure. /* m-hdd-ref */

procedure m-cashp-rep :
  do
  on error undo, return error
  :
    
  run rep/g-cash-param.p(input  parparentproc).
  
  end.

end procedure. /* m-hdd-ref */

procedure m_action-item :

  define variable v-rid-list         as character no-undo .

  do
  on error undo, return error return-value
  :
    run adm/actnitem.w ( input  parparentproc
                       , input  '':U
                       , input-output v-rid-list
                       ) .
  end.

end procedure. /* m_action-item */

procedure m_sysconf-exe :

  define variable v-host-code as integer   no-undo .

  do
  on error undo, return error return-value
  :
    if lookup(v-cntxt-level, {&cntxt-firm} + {&comma-char} + {&cntxt-object}) > 0
    then do:
      run adm/config.w
        (input  parparentproc
        ,input  v-cntxt-host-code-obj
        ,input (if v-cntxt-db-num <> 0 then {&lookup} else {&update})
        ,input no
        ) .
    end.
    else do:
      message
        "Не выбрана текущая фирма" skip
        view-as alert-box error .
    end.
  end.

end procedure. /* m_sysconf-exe */

procedure m_newhost-exe :

  do
  on error undo, return error return-value
  :
    run adm/config.w (input parparentproc, 0, {&add-def}, no ) .
  end.

end procedure. /* m_newhost-exe */

procedure m_chk-senreq-exe :

  do
  on error undo, return error return-value
  :
    run utl/g-sndreq.p (parparentproc) .
  end.

end procedure. /* m_chk-senreq-exe */



procedure m_util-version-exe :

  do
  on error undo, return error return-value
  :
    run gbl/menubrws.w (parparentproc, {&menuload_adm_version}, 'Коррекция при смене версии') .
  end.

end procedure. /* m_util-version-exe */

procedure m_util-function-exe :

  do
  on error undo, return error return-value
  :
    run gbl/menubrws.w (parparentproc, {&menuload_adm_function}, 'Функции администратора') .
  end.

end procedure. /* m_util-function-exe */

procedure m_util-check-exe :

  do
  on error undo, return error return-value
  :
    run gbl/menubrws.w (parparentproc, {&menuload_adm_check}, 'Проверки') .
  end.

end procedure. /* m_util-check-exe */

procedure m_view-history-exe :

  do
  on error undo, return error return-value
  :
    run str/history.w (parparentproc) .
  end.

end procedure. /* m_util-check-exe */

procedure m_util-archive-exe :

  do
  on error undo, return error return-value
  :
    run gbl/menubrws.w (parparentproc, {&menuload_adm_archive}, 'Работа с архивами') .
  end.

end procedure. /* m_util-archive-exe */

procedure m_util-impexp-exe :

  define variable glog as logical no-undo.

  do
  on error undo, return error return-value
  :
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_impexp_proc':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    glog
  }
    if glog then do :
      run gbl/menubrws.w (parparentproc, {&menuload_adm_impexp}, 'Импорт/Экспорт') .
    end.
  end.

end procedure. /* m_util-impexp-exe */


procedure m-gds-show-exe :

  define variable ri-list as character no-undo .

  do
  on error undo, return error return-value
  :
    run ref/gds-ref.p (parparentproc, 'b-add', ?, ?, ?, ?, ?, ?, ?, v-cntxt-obj-type, v-cntxt-obj-code, ?, output ri-list) .
  end.

end procedure. /* m-gds-show-exe */

procedure m-gds-grp-off-exe :

  define variable ri-list as character no-undo .

  do
  on error undo, return error return-value
  :
    run ref/gds-grp.w (parparentproc, input 'buttons-for-admin', input v-cntxt-obj-type, input v-cntxt-obj-code, input-output ri-list) .
  end.

end procedure. /* m-gds-grp-off-exe */

procedure m-gds-grp-stsh-exe :

  define variable ri-list as character no-undo .

  do
  on error undo, return error return-value
  :
    run ref/gds-grp.w (parparentproc, input '', input v-cntxt-obj-type, input v-cntxt-obj-code, input-output ri-list) .
  end.

end procedure. /* m-gds-grp-stsh-exe */

procedure m-fbr-gds-grp-exe :

  define variable ri-list as character no-undo .

  do
  on error undo, return error return-value
  :
    run ref/fbrggrp.w ( input parparentproc, input v-cntxt-obj-type, input v-cntxt-obj-code, input 'buttons-for-admin', input-output ri-list ) .
  end.

end procedure. /* m-fbr-gds-grp-exe */

procedure m-gds-prt-exe :

  define variable rid# as recid    no-undo .

  do
  on error undo, return error return-value
  :
    run ref/gdsprts.w
      (input  parparentproc
      ,input  v-cntxt-db-num <> 0
      ,output rid#
      ) .
  end.

end procedure. /* m-gds-prt-exe */

procedure m-rcps-exe :

  define variable ri-list as character no-undo .
  do
  on error undo, return error return-value
  :
      run ref/rcp-all.w (
            input parparentproc
          , input 'b-add'
          , input {&all}
          , input ?
          , input v-cntxt-obj-type
          , input v-cntxt-obj-code
          , output ri-list
      ).
  end.

end procedure. /* m-rcps-exe */

procedure m-units-exe :

  define variable rid#          as recid     no-undo .

  do
  on error undo, return error return-value
  :
    run ref/units.w
      (input  parparentproc
      ,input  v-cntxt-db-num <> 0
      ,output rid#
      ) .
  end.

end procedure. /* m-units-exe */

procedure m-units-merc-exe :

  define variable rid#          as recid     no-undo .

  do
  on error undo, return error return-value
  :
    run bge/units-merc.w
      (input  parparentproc
      ,input  no
      ,output rid#
      ) .
  end.

end procedure. /* m-units-exe */

procedure m-okei-kkt-exe:

  define variable rid#          as recid     no-undo .

  do
  on error undo, return error return-value
  :
    run ref/codelay.p
      (input  parparentproc
      ,input  {&update}
      ,input  ""
      ,input  "okei-kkt"
      ,input  ?
      ) .
  end.

end procedure. /* m-units-exe */

procedure m-dt-seasons-exe:

  define variable rid#          as recid     no-undo .

  do
  on error undo, return error return-value
  :
    run ref/codelay.p
      (input  parparentproc
      ,input  ( if v-cntxt-db-num = 0 then {&update} else {&lookup})
      ,input  ""
      ,input  "DTSeasons"
      ,input  ?
      ) .
  end.

end procedure. /* m-units-exe */

procedure m-emrc-exe:

  define variable rid#          as char     no-undo .

  do
  on error undo, return error return-value
  :
run ref/codelay.p(input  parparentproc
      ,input  {&update}
      ,input  ""
      ,input  "EMC"
      ,input  ? ).
      
  end.

end procedure. /* m-emrc-exe */

procedure m-tares-exe :

  define variable v-rid-list as character no-undo .
  define variable v-stts as integer no-undo .

  do
  on error undo, return error return-value
  :
    run ref/tares.w
      (input  parparentproc
      ,input  (if v-cntxt-db-num = 0 then "b-add" else '')
      ,input {&all}
      ,input-output v-stts
      ,input-output v-rid-list
      ) .
  end.

end procedure. /* m-tares-exe */


procedure m-tmp-exe :

  define variable rid#          as   recid             no-undo.

  do
  on error undo, return error return-value
  :
    run ref/tmp-sale.w (input parparentproc, input 'b-add', output  rid# ) .
  end.

end procedure. /* m-tmp-exe */

procedure m-season-exe :

  define variable rid#          as   recid             no-undo.

  do
  on error undo, return error return-value
  :
    run ref/season.w (input parparentproc, input 'b-add' , output  rid#) .
  end.

end procedure. /* m-season-exe */

procedure m-alc-type :

  define variable rid-list as recid   no-undo.
  define variable v-ok     as logical no-undo.

  do
  on error undo, return error return-value
  :
    run ref/alc-type.w ( input parparentproc
                       , input 'b-add'
                       , input-output  rid-list
                       , output v-ok
                       ) .
  end.

end procedure. /* m-alc-type */

procedure m-lic-supp :

  do
  on error undo, return error return-value
  :
    run ref/licsupp.w ( input parparentproc
                      , input ?
                      , input ?
                      ) .
  end.

end procedure. /* m-lic-supp */

procedure m-lic-sale :

  do
  on error undo, return error return-value
  :
    run ref/licsale.w ( input parparentproc ) .
  end.

end procedure. /* m-lic-sale */

procedure m-collection-exe :

  define variable rid#          as   recid             no-undo.

  do
  on error undo, return error return-value
  :
    run ref/collec.w (input parparentproc, input 'b-add' , output  rid#) .
  end.

end procedure. /* m-season-exe */

procedure m-marking-exe :
  do
  on error undo, return error return-value
  :
    run str/mark_hist.w (input parparentproc , input "", input "") .
  end.

end procedure. /* m-marking-exe */

procedure m-assmatr-exe :

  define variable rid#          as   recid             no-undo.

  do
  on error undo, return error return-value
  :
    run ref/assmatr.w (input parparentproc , input 'b-add',v-cntxt-obj-type,v-cntxt-obj-code , ? ,  ?, input-output  rid#) .
  end.

end procedure. /* m-assmatr-exe */

procedure m-addcharges-exe :
define variable v-spis as character no-undo .
  do
  on error undo, return error return-value
  :
    run ref/addchls.w (input parparentproc , input '' , output v-spis) .
  end.

end procedure. /* m-addcharges-exe */
procedure m-exmark-exe :

  define variable rid#          as   recid             no-undo.

  do
  on error undo, return error return-value
  :
    run ref/exmark.w (input parparentproc , input 'b-add', input-output  rid#) .
  end.

end procedure. /* m-assmatr-exe */

procedure m-cli-show-exe :

  define variable ri-list as character no-undo .

  do
  on error undo, return error return-value
  :
    run ref/cli-all.w (input parparentproc, 'b-bank,b-add', ?, ?, ?, ?, ?, ?, output ri-list) .
  end.

end procedure. /* m-cli-show-exe */

procedure m-cli-grp-off-exe :

  define variable ri-list as character no-undo .

  do
  on error undo, return error return-value
  :
    run ref/cli-grps.w (input parparentproc, 'buttons-for-admin', input-output ri-list) .
  end.

end procedure. /* m-cli-grp-off-exe */

procedure m-cli-grp-stsh-exe :

  define variable ri-list as character no-undo .

  do
  on error undo, return error return-value
  :
    run ref/cli-grps.w (input parparentproc, '', input-output ri-list) .
  end.

end procedure. /* m-cli-grp-stsh-exe */

procedure m-dc-type-exe :

  define variable v-host-code as integer   no-undo .
  define variable ri-list     as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/hostcode.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-host-code
    }

    run ref/dc-types.w
      (input  parparentproc
      ,input  '':U
      ,input  'b-add':U
      ,input  v-host-code
      ,input  v-host-code
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input-output ri-list
      ) .
  end.

end procedure. /* m-dc-type-exe */

procedure m-dc-masks-exe :
define variable v-host-code as integer   no-undo .
define variable v-rid-list AS CHARACTER NO-UNDO.

do
on error undo, return error return-value
:
    { gbl/hostcode.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-host-code
    }


    run ref/dc-masks.w (
                    INPUT parparentproc
                   ,INPUT v-cntxt-host-code-obj
                   ,INPUT v-cntxt-obj-type
                   ,INPUT v-cntxt-obj-code
                   ,input (if v-cntxt-db-num = 0 then "b-add" else '':U)
                   ,INPUT {&all}
                   ,INPUT '':U /*p-TYPE*/
                   ,INPUT 0 /*p-emitent-host-code*/
                   ,INPUT ?
                   ,input-output v-rid-list
                    ) NO-ERROR.
end.

end procedure. /* m-dc-masks-exe */

procedure m-discards-exe :

  define variable ri-list as character no-undo .
  define variable v-host-code like ub.sysconf.host-code no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/hostcode.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-host-code
    }

    run ref/discards.w (
                     input parparentproc
                   , input (if v-cntxt-db-num = 0 then 'b-add' else '':U) /*bttns*/
                   , input {&all}
                   , input v-host-code
                   , input v-cntxt-obj-type
                   , input v-cntxt-obj-code
                   , input '':U
                   , input ?
                   , output ri-list ) .
  end.

end procedure. /* m-discards-exe */

procedure m-dc-prop-head-exe :

  define variable v-rid-list as character no-undo .

  do
  on error undo, return error return-value
  :

   run rul/prop-head-s.w (
                          input parparentproc
                        , input 'b-storage' /*bttns*/
                        , input "general-view"
                        , input {&prop-head-gen-loyalty2}
                        , input-output v-rid-list ) .
  end.
end procedure. /* m-dc-prop-head-exe */


procedure m-dc-rule-profile-exe :

  define variable v-rid-list as character no-undo .

  do
  on error undo, return error return-value
  :

   run rul/rule-profile-s.w (
                          input parparentproc
                        , input '' /*bttns*/
                        , input "general-view"
                        , input {&table_dis-card-type}
                        , input-output v-rid-list ) .
  end.
end procedure. /* m-dc-rule-profile-exe */

procedure m-dc-ruleset-exe :

  define variable v-rid-list as character no-undo .

  do
  on error undo, return error return-value
  :

   run rul/ruleset-s.w (
                          input parparentproc
                        , input '' /*bttns*/
                        , input "profile-type" + {&delim-par} + {&table_dis-card-type} + {&delim-par} + "ruleset" /*p-list-mode*/
                        , input 0
                        , input-output v-rid-list ) .
  end.
end procedure. /* m-dc-ruleset-exe */

procedure m-dc-codex-exe :

  define variable v-rid-list as character no-undo .

  do
  on error undo, return error return-value
  :

   run rul/ruleset-s.w (
                          input parparentproc
                        , input '' /*bttns*/
                        , input "profile-type" + {&delim-par} + {&table_dis-card-type} + {&delim-par} + "codex" /*p-list-mode*/
                        , input 0
                        , input-output v-rid-list ) .
  end.
end procedure. /* m-dc-codex-exe */


procedure m-lo-prop-ref-exe :
  define variable v-rid-list as character no-undo .

  do
  on error undo, return error return-value
  :
   run ref/proprefs.w (
                          input parparentproc
                        , input (if v-cntxt-db-num = 0 then 'b-add'else '') /*bttns*/
                        , input {&all}
                        , input 0 /*p-dtm-code*/
                        , input '':U /*p-sum-id*/
                        , input '':U   /*p-calli-id*/
                        , input-output v-rid-list ) .
  end.
end procedure. /* m-lo-prop-ref-exe */


procedure m-stop-ls-exe :
define variable v-rid-list as character no-undo .

  do
  on error undo, return error
  :
    run ref/stop-ls.w (
                        input parparentproc
                       ,input (if v-cntxt-db-num  = 0 then 'b-add':U else '')
                       ,input {&all}
                       ,input-output v-rid-list) no-error.
  end.

end procedure. /* m-stop-ls-exe */


procedure m-rum-cds-rep-exe :
do
on error undo, return error return-value
:
  run ref/rum-cds.w ( input parparentproc
                    ,input {&attr-rum_rep}
                    ,input {&attr-rum_obj_rep}
                    ,input (if v-cntxt-db-num  = 0 then {&update} else {&lookup})
                    ,input {&all}
                    ,input ''
                    ,input 0
                    ) no-error .
  end.
end procedure.  /* m-rum-cds-rep-exe */


procedure m-rum-cds-chk-exe :
define variable v-ok as logical no-undo .
  do
  on error undo, return error return-value
  :
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_rum_chk-doc-work':U
      {&cntxt-global}
      0
      "''"
      0
      0
      0
      0
      false
      v-ok
    }

   run ref/rum-cds.w (
                          input parparentproc
                         ,input {&attr-rum_chk-doc_ibs-th}
                         ,input {&attr-rum_obj_chk-doc_ibs-th}
                         ,input (if v-cntxt-db-num  = 0 and v-ok then {&update} else {&lookup})
                        , input {&all}
                        , input ''
                        , input 0) no-error.
  end.
end procedure.  /* m-rum-cds-chk-exe */


procedure m-chk-doc-rule-profile-exe :

  define variable v-rid-list as character no-undo .

  do
  on error undo, return error return-value
  :

   run rul/rule-profile-s.w (
                          input parparentproc
                        , input '' /*bttns*/
                        , input "general-view"
                        , input {&table_chk-doc}
                        , input-output v-rid-list ) .
  end.
end procedure. /* m-chk-doc-rule-profile-exe */



procedure m-taxes-exe :

  define variable v-host-code as integer   no-undo .
  define variable ri-list     as character no-undo .

  do
  on error undo, return error return-value
  :
    case v-cntxt-level:
      WHEN {&cntxt-object}
      THEN DO:
         { gbl/hostcode.i
            v-cntxt-obj-type
            v-cntxt-obj-code
            v-host-code
         }
         run ref/tax-tree.w
            (input  parparentproc
            ,input  ''
            ,input  'ALL':U
            ,input  v-host-code
            ,input  v-cntxt-obj-type
            ,input  v-cntxt-obj-code
            ,input  ?
            ,input-output ri-list
            ) .
      END.
      WHEN {&cntxt-firm}
      THEN DO:
         run ref/tax-tree.w
            (input  parparentproc
            ,input  ''
            ,input  'ALL':U
            ,input  v-cntxt-host-code-obj
            ,input  "":U
            ,input  0
            ,input  ?
            ,input-output ri-list
            ) .
      END.
      OTHERWISE DO:
         run ref/tax-tree.w
            (input  parparentproc
            ,input  ''
            ,input  'ALL':U
            ,input  0
            ,input  ''
            ,input  0
            ,input  ?
            ,input-output ri-list
            ) .
      END.
    END CASE.

  end.

end procedure. /* m-taxes-exe */

procedure m-countries-exe :

  define variable v-rid-list as character  no-undo .

  do
  on error undo, return error return-value
  :
    if v-cntxt-db-num = 0
    then do:
      run ref/countris.w
        (input parparentproc
        ,input  'b-add,b-chg'
        ,input-output v-rid-list
        ) .
    end.
    else do:
      run ref/countris.w
        (input parparentproc
        ,input  ''
        ,input-output v-rid-list
        ) .
    end.
  end.

end procedure. /* m-countries-exe */

procedure m-currency-exe :

  define variable rid#          as recid     no-undo .

  do
  on error undo, return error return-value
  :
    if v-cntxt-db-num = 0
    then do:
      run ref/currency.w
        (input  parparentproc
        ,input  'b-add,b-add-acc,b-add-bank'
        ,input-output  rid#
        ) .
    end.
    else do:
      run ref/currency.w
        (input  parparentproc
        ,input  ''
        ,input-output  rid#
        ) .
    end.
  end.

end procedure. /* m-currency-exe */

procedure m-pay-type-exe :

  define variable rid#             as character no-undo .

  do
  on error undo, return error return-value
  :
    if v-cntxt-db-num = 0
    then do:
      run ref/paytype.w
        (input  parparentproc
        ,input  'b-add,b-upd,b-del,b-doc,b-print'
        ,output rid#
        ) .
    end.
    else do:
      run ref/paytype.w
        (input  parparentproc
        ,input  'b-doc'
        ,output  rid#
        ) .
    end.
  end.

end procedure. /* m-pay-type-exe */

procedure m-rvd-reason-exe :

  define variable rid#             as character no-undo .
  define variable v-value    as character no-undo .
  define variable v-type     as character no-undo .

  do
  on error undo, return error return-value
  :
    run gbl/conf-rd.p ("is-erpRN", "", "", 0, "", "", "", no, output v-value, output v-type) no-error.
    
    if v-value = "no"
    then do:
      if v-cntxt-db-num = 0
      then do:
        run ref/rvd-reason.w
          (input  parparentproc
          ,input  'b-add,b-upd,b-del'
          ,input {&all}
          ,input -1
          ,output rid#
          ) .
      end.
      else do:
        run ref/rvd-reason.w
          (input  parparentproc
          ,input  ''
          ,input {&all}
          ,input -1
          ,output  rid#
          ) .
      end.
    end .
    else do :
      run ref/rvd-reason.w
        (input  parparentproc
        ,input  ''
        ,input {&all}
        ,input -1
        ,output  rid#
        ) .
    end .
  end.

end procedure.

procedure m-reason-check-exe :

  define variable rid#             as character no-undo .
  do
  on error undo, return error return-value
  :
      run ref/reasonSuspCheck.w
        (input  parparentproc
        ,input  ''
        ,output  rid#
        ) .
    end .

end procedure.

procedure m-cashpay-exe :

  define variable ri-list          as character no-undo .

  do
  on error undo, return error return-value
  :
    if v-cntxt-db-num = 0
    then do:
      run ref/cashpays.w
        (input  parparentproc
        ,input  'b-add'
        ,input {&all}
        ,input  v-cntxt-host-code-obj
        ,input  v-cntxt-obj-type
        ,input  v-cntxt-obj-code
        ,output ri-list
        ) .
    end.
    else do:
      run ref/cashpays.w
        (input  parparentproc
        ,input  ''
        ,input {&all}
        ,input  v-cntxt-host-code-obj
        ,input  v-cntxt-obj-type
        ,input  v-cntxt-obj-code
        ,output ri-list
        ) .
    end.
  end.

end procedure. /* m-cashpay-exe */

procedure m-cashdesk-exe :

  define variable ri-list     as character no-undo .

  do
  on error undo, return error return-value
  :
    run ref/cashlist.w
      (input  parparentproc
      ,input  'b-add,b-on':U
      ,input  'db':U
      ,input  v-cntxt-db-num
      ,input  v-cntxt-host-code-obj
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  ?
      ,output ri-list
      ) .
  end.

end procedure. /* m-cashdesk-exe */

procedure m-cashdesk-all-exe :

  define variable ri-list as character no-undo .

  do
  on error undo, return error return-value
  :
    run ref/cashlist.w
      (input  parparentproc
      ,input  '':U
      ,input  {&all}
      ,input  v-cntxt-db-num
      ,input  v-cntxt-host-code-obj
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  ?
      ,output ri-list
      ) .
  end.

end procedure. /* m-cashdesk-all-exe */

procedure m-scales-all-exe :

  define variable ri-list as character no-undo .

  do
  on error undo, return error return-value
  :
    run ref/scales.w (parparentproc, v-cntxt-obj-type, v-cntxt-obj-code, '':U, {&all}, output  ri-list ) .
  end.

end procedure. /* m-scales-all-exe */


procedure m-scales-exe :

  define variable ri-list as character no-undo .

  do
  on error undo, return error return-value
  :
    run ref/scales.w (parparentproc, v-cntxt-obj-type, v-cntxt-obj-code, 'b-add', 'db':U, output ri-list) .
  end.

end procedure. /* m-scales-exe */

procedure m-grp-scales-exe :

  define variable ri-list as character no-undo .

  do
  on error undo, return error return-value
  :
    run ref/gds-grp.w (parparentproc, {&g#term} + ',b-scales', input v-cntxt-obj-type, input v-cntxt-obj-code, input-output ri-list) .
  end.

end procedure. /* m-grp-scales-exe */

procedure m-store-ref-exe :

  define variable ri-list as character no-undo .

  do
  on error undo, return error return-value
  :
    run adm/stores.w
      (input parparentproc
      ,input 'b-add'
      ,input-output ri-list
      ,input no
      ) .
  end.

end procedure. /* m-store-ref-exe */

procedure m-shop-ref-exe :

  define variable ri-list as character no-undo .

  do
  on error undo, return error return-value
  :
    run adm/shops.w
      (input parparentproc
      ,input 'b-add'
      ,input-output ri-list
      ,no
      ) .
  end.

end procedure. /* m-shop-ref-exe */

procedure m-dis-rules-exe :

  do
  on error undo, return error
  :
    define variable v-sts as integer no-undo init 0.
    define variable v-rid-list as character no-undo .
    run ref/dis-ruls.w ( INPUT parparentproc
                       , input v-cntxt-host-code-obj
                       , input v-cntxt-obj-type
                       , input v-cntxt-obj-code
                       , input "b-add"
                       , input "template"
                       , input 0 /*p-uppre-rule-num*/
                       , input ? /*p-time-templ-rlr-oot*/
                       , input 0 /*b-code*/
                       , input-output v-sts
                       , input-output v-rid-list).
  end.
end procedure. /* m-dis-rules-exe */


procedure m-obj-init-exe :
define variable v-host-code like ub.sysconf.host-code no-undo .

  do
  on error undo, return error return-value
  :
    run adm/obj-init.w ( input parparentproc, input v-cntxt-host-code-obj) .
  end.

end procedure. /* m-obj-init-exe */


procedure m-db-ref-exe :

  define variable rid#          as   recid             no-undo.

  do
  on error undo, return error return-value
  :
    run adm/dbs.w ( input parparentproc
                  ,input {&update}
                  ,output rid# ) .
  end.

end procedure. /* m-db-ref-exe */

procedure m-obj-sht-open-exe :

  do
  on error undo, return error return-value
  :
    run gbl/sht-open.p ( input parparentproc, input v-cntxt-obj-type, input v-cntxt-obj-code ) no-error .
  end.

end procedure. /* m-obj-sht-open-exe */


procedure m-obj-sht-close-exe :

  do
  on error undo, return error return-value
  :
    run gbl/sht-clos.p ( input parparentproc, input v-cntxt-obj-type, input v-cntxt-obj-code, input yes, input no ) no-error.
  end.

end procedure. /* m-obj-sht-close-exe */

procedure m-obj-sht-undo-exe :

  do
  on error undo, return error return-value
  :
    run str/sht-undo.p ( input parparentproc, input v-cntxt-obj-type, input v-cntxt-obj-code ) .
  end.

end procedure. /* m-obj-sht-undo-exe */


procedure obj-pr-new-exe :
  do
  on error undo, return error return-value
  :
    run gbl/prdoclst.p
      (input  parparentproc
      ,input  {&status}
      ,input  {&g___new}
      ) .
  end.
end procedure.

procedure obj-pr-doc-exe :
  do
  on error undo, return error return-value
  :
    run gbl/prdoclst.p
      (input  parparentproc
      ,input  {&status}
      ,input  {&order}
      ) .
  end.
end procedure.

procedure obj-pr-perm-exe :
  do
  on error undo, return error return-value
  :
    run gbl/prdoclst.p
      (input  parparentproc
      ,input  {&status}
      ,input  {&permitted}
      ) .
  end.
end procedure .

procedure obj-pr-akt-exe :
  do
  on error undo, return error return-value
  :
    run gbl/prdoclst.p
      (input  parparentproc
      ,input  {&status}
      ,input  {&act-overvalue}
      ) .
  end.
end procedure.

procedure obj-pr-exe :
  do
  on error undo, return error return-value
  :
    run gbl/prdoclst.p
      (input  parparentproc
      ,input  {&g___object}
      ,input  ""
      )  .
  end.
end procedure.

procedure m-host-pr-exe :
  define variable v-ok   as logical   no-undo.
  do
  on error undo, return error return-value
  :
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_documents_company':U
      {&cntxt-firm}
      v-cntxt-host-code-obj
      '':U
      0
      0
      0
      0
      true
      v-ok
    }
    if v-ok then do:
      run gbl/prdoclst.p
        (input  parparentproc
        ,input  {&company}
        ,input  ""
        ) .
    end.
  end.
end procedure.

procedure m-all-pr-exe :

  define variable v-ok as logical   no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_documents_all':U
      {&cntxt-global}
      0
      '':U
      0
      0
      0
      0
      true
      v-ok
    }
    if v-ok = true
    then do:
      run gbl/prdoclst.p
        (input  parparentproc
        ,input  {&work}
        ,input  ""
        ) .
    end.
  end.
end procedure.

procedure m-all-pr-del :

  define variable v-ok as logical   no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_documents_all':U
      {&cntxt-global}
      0
      '':U
      0
      0
      0
      0
      true
      v-ok
    }
    if v-ok = true
    then do:
      run str/pr-cdocs.w
        ( parparentproc ,
          v-cntxt-host-code-obj   ) .
    end.
  end.
end procedure.

procedure obj-fbr-pln-exe :

  do
  on error undo, return error return-value
  :
    run str/fbr-plns.w
      (input  parparentproc
      ,input  ""
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  v-cntxt-userid
      ) .
  end.
end procedure.

procedure m-cash-rate-exe :

  define variable v-host-code as integer   no-undo .
  define variable v-base-code as integer   no-undo .
  define variable v-r-b       as character no-undo.

  do
  on error undo, return error return-value
  :
    { gbl/curr-r-b.i
      v-r-b
    }
    { gbl/hostcode.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-host-code
    }
    { gbl/basecode.i
      v-host-code
      v-base-code
    }
    if  v-r-b = 'rubl':u
    and v-base-code = 0
    then do:
      run str/diallog.w
        (input  parparentproc
        ,input  this-procedure
        ,input  "str/send-cur.p":U
        ,input  (v-cntxt-obj-type + {&delim-par} + string(v-cntxt-obj-code) + {&delim-par} + "U")
        ,input  no /* p-auto-go */
        ,input  "":U
        ,input  substitute("Отсылка данных по курсам валют на кассы")
        ) no-error.
    end.
    else do:
      run ref/currshop.w (input parparentproc, input v-cntxt-obj-type, input v-cntxt-obj-code).
    end.
  end.

END PROCEDURE.

procedure bpasend :
define input parameter p-pos-type as character no-undo .
define input parameter p-action as character no-undo .
 run str/diallog.w (
        input parparentproc
      , input this-procedure
      , input "str/bpasend.p":U
      , input (p-pos-type + {&delim-par} + v-cntxt-obj-type + {&delim-par} + string(v-cntxt-obj-code) + {&delim-par} + p-action)
      , input no /*p-auto-go*/
      , input "":U
      , input substitute("Отсылка справочника ОСС на кассы &1", p-pos-type, {&cd-type-IBm-XML})
  ) no-error.
end procedure. /* bpasend */

procedure run-2cashpay :
define input parameter p-pos-type as character no-undo .
define input parameter p-action as character no-undo .
 run str/diallog.w (
        input parparentproc
      , input this-procedure
      , input "str/2cashpay.p":U
      , input (p-pos-type + {&delim-par} + v-cntxt-obj-type + {&delim-par} + string(v-cntxt-obj-code) + {&delim-par} + p-action)
      , input no /*p-auto-go*/
      , input "":U
      , input substitute("Отсылка данных по типам кассовых платежей на кассы &1 &2", p-pos-type, (if p-pos-type = {&cd-type-IBM} then {&cd-type-IBm-XML} else "":U))
  ) no-error.
end procedure. /* run-2cashpay */

procedure m-cash-wthser-exe :
/*define input parameter p-pos-type as character no-undo .
define input parameter p-action as character no-undo .   */
 run str/diallog.w (
        input parparentproc
      , input this-procedure
      , input "str/sendwths.p":U
      , input ( v-cntxt-obj-type + {&delim-par} + string(v-cntxt-obj-code) + {&delim-par} + 'U':U)
      , input no /*p-auto-go*/
      , input "":U
      , input substitute("Отсылка данных по маскам серийных МЦ на кассы ")
  ) no-error.
end procedure. /* m-cash-wthser-exe */

procedure m-promo-u-exe :

  do
  on error undo, return error return-value
  :
    run promosend in this-procedure ({&cd-type-IBm-XML}, 'U':U) .
  end.

end procedure. /* m-cash-pay-exe */
procedure m-catalog-corr-exe :

 run str/diallog.w (
        input parparentproc
      , input this-procedure
      , input "str/sendcorr.p":U
      , input ( v-cntxt-obj-type + {&delim-par} + string(v-cntxt-obj-code) + {&delim-par} + 'U':U)
      , input no /*p-auto-go*/
      , input "":U
      , input substitute("Отсылка данных по справочнику ОСС ")
  ) no-error.

end procedure. /* m-catalog-oss-exe */

procedure m-cash-emrc-exe :

 run str/diallog.w (
        input parparentproc
      , input this-procedure
      , input "str/send-all.p":U
      , input ( v-cntxt-obj-type + {&delim-par} + string(v-cntxt-obj-code) + {&delim-par} + 'D':U + {&delim-par} + 'emrc':U + {&delim-par} + 'Удаление справочника ЕМЦ':U)
      , input ? /*p-auto-go*/
      , input "":U
      , input substitute("Отсылка очистки справочника ЕМЦ")
  ) no-error.


 run str/diallog.w (
        input parparentproc
      , input this-procedure
      , input "str/send-all.p":U
      , input ( v-cntxt-obj-type + {&delim-par} + string(v-cntxt-obj-code) + {&delim-par} + 'U':U + {&delim-par} + 'emrc':U + {&delim-par} + 'Передача справочника ЕМЦ':U)
      , input ? /*p-auto-go*/
      , input "":U
      , input substitute("Отсылка справочника ЕМЦ")
  ) no-error.

end procedure. /* m-cash-emrc-exe */

procedure m-cash-marktype-exe :

 run str/diallog.w (
        input parparentproc
      , input this-procedure
      , input "str/send-all.p":U
      , input ( v-cntxt-obj-type + {&delim-par} + string(v-cntxt-obj-code) + {&delim-par} + 'U':U + {&delim-par} + 'MarkType':U + {&delim-par} + 'Передача справочника Типы Марок':U)
      , input ? /*p-auto-go*/
      , input "":U
      , input substitute("Отсылка справочника MarkType")
  ) no-error.

end procedure. /* m-cash-marktype-exe */

procedure m-cash-gismt-exe :

 run str/diallog.w (
        input parparentproc
      , input this-procedure
      , input "str/sendgismt.p":U
      , input ( v-cntxt-obj-type + {&delim-par} + string(v-cntxt-obj-code) + {&delim-par} + 'U':U + {&delim-par} + 'gismt':U + {&delim-par} + 'Передача настроек для проверки КМ':U)
      , input ? /*p-auto-go*/
      , input "":U
      , input substitute("Отсылка настроек для проверки КМ")
  ) no-error.

end procedure. /* m-cash-marktype-exe */
 { utl/cashparamHash.i }
procedure m-cash-param-exe :
   define variable v-current-db-num as integer   no-undo .
   def var vlist as char no-undo.
   { gbl/curdbnum.i
      v-current-db-num
    }
   if v-current-db-num ne 0
   then
      run saveCashParHash(v-current-db-num).
   vList = "cashp1,cashp2". /* параметры 1 клава 2*/
   if vList ne ""
   then do: 
      run str/diallog.w (
        input parparentproc
      , input this-procedure
      , input "str/send-all.p":U
      , input ( v-cntxt-obj-type + {&delim-par} + string(v-cntxt-obj-code) + {&delim-par} + 'U':U + {&delim-par} + vList + {&delim-par} + 'Получение параметров кассы':U + {&delim-par} + "cash-send=all,SocetLog=cashparam.log")
      , input ? /*p-auto-go*/
      , input "":U
      , input substitute("Получение параметров кассы")
      ) no-error.
      
      run bge\send1cerp.p (?,
                      this-procedure,
                      this-procedure,
                      "CashParamControl",
                      ?,
                      ?,
                      ?).
      run bge\send1cerp.p (?,
                      this-procedure,
                      this-procedure,
                      "CashParamHist",
                      ?,
                      ?,
                      ?).
   end.
end procedure.

procedure m-catalog-petrol-exe :

 run str/diallog.w (
        input parparentproc
      , input this-procedure
      , input "str/sendpetrol.p":U
      , input ( v-cntxt-obj-type + {&delim-par} + string(v-cntxt-obj-code) + {&delim-par} + 'U':U)
      , input no /*p-auto-go*/
      , input "":U
      , input substitute("Отсылка данных по соответствию товаров/кошельков ")
  ) no-error.

end procedure. /* m-catalog-petrol-exe */

procedure m-cash-petrol-del-exe :

 run str/diallog.w (
        input parparentproc
      , input this-procedure
      , input "str/sendpetrol.p":U
      , input ( v-cntxt-obj-type + {&delim-par} + string(v-cntxt-obj-code) + {&delim-par} + 'D':U)
      , input no /*p-auto-go*/
      , input "":U
      , input substitute("Удаление данных по соответствию товаров/кошельков ")
  ) no-error.

end procedure. /* m-catalog-petrol-exe */

procedure m-promo-d-exe :

  do
  on error undo, return error return-value
  :
    run promosend in this-procedure ({&cd-type-IBm-XML}, 'D':U) .
  end.

end procedure. /* m-cash-pay-exe */
procedure m-catalog-block-nozzle :

  define variable v-current-db-num as integer   no-undo .
  define variable v-obj-db-num     as integer   no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/curdbnum.i
      v-current-db-num
    }
    { gbl/objdbnum.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-obj-db-num
    }
    if v-current-db-num = v-obj-db-num
    then do:
      /* todo - объект активный */
      run str/blockplgdspm.w
        (input parparentproc
        ,input v-cntxt-obj-type
        ,input v-cntxt-obj-code
        ,input 'block'
        ) .
    end.
    else do:
      run str/blockplgdspm.w (input parparentproc,
                      input v-cntxt-obj-type,
                      input v-cntxt-obj-code,
                      input '').
    end.
  end.

end procedure. /* m-catalog-petrol-exe */

procedure m-catalog-unblock-nozzle :

  define variable v-current-db-num as integer   no-undo .
  define variable v-obj-db-num     as integer   no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/curdbnum.i
      v-current-db-num
    }
    { gbl/objdbnum.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-obj-db-num
    }
    if v-current-db-num = v-obj-db-num
    then do:
      /* todo - объект активный */
      run str/blockplgdspm.w
        (input parparentproc
        ,input v-cntxt-obj-type
        ,input v-cntxt-obj-code
        ,input 'un-block'
        ) .
    end.
    else do:
      run str/blockplgdspm.w (input parparentproc,
                      input v-cntxt-obj-type,
                      input v-cntxt-obj-code,
                      input '').
    end.
  end.

end procedure. /* m-catalog-petrol-exe */
procedure m-bpa-u-exe :

  do
  on error undo, return error return-value
  :
    run bpasend in this-procedure ({&cd-type-IBm-XML}, 'U':U) .
  end.

end procedure. /* m-bpa-u-exe */

procedure m-bpa-d-exe :

  do
  on error undo, return error return-value
  :
    run bpasend in this-procedure ({&cd-type-IBm-XML}, 'D':U) .
  end.

end procedure. /* m-bpa-d-exe */

procedure m-gds-ef-exe :
define variable v-rid-list as character no-undo .

  do
  on error undo, return error
  :
      define variable v-row as rowid no-undo .
      define buffer buf_PromoAction for ub.PromoAction .
      define variable v-PromoName as character no-undo .
    if v-cntxt-db-num = 0 then 
    do:
      for each buf_PromoAction exclusive-lock where buf_PromoAction.Status_ = 1 and
        (buf_PromoAction.end-date < today or (buf_PromoAction.changeDate < today and
        buf_PromoAction.changeDate <> 01/01/1970)):
        buf_PromoAction.Status_ = 2 .
        v-PromoName = v-PromoName + {&new-line} + buf_PromoAction.nameAction .
      end.

      if v-PromoName <> "" then 
      do:
        message "Статус был изменен на Заблокирован для акций:" skip
          skip
          v-PromoName
          view-as alert-box.
      end.
    end.
    run ref/promo.p ( input parparentproc, input false, output v-rid-list) no-error.
  end.

end procedure. /* m_gds-ef-exe */

procedure m-platsys-exe :
define variable v-rid-list as character no-undo .

  do
  on error undo, return error
  :
    run ref/codelay.p (parparentproc, "", "", "platsys", "Платежные системы") no-error.
    
  end.

end procedure. /* m-platsys-exe */

procedure m-corrsys-exe :
define variable v-rid-list as character no-undo .

  do
  on error undo, return error
  :
    run ref/codelay.p (parparentproc, "", "", "OsnovCorr", "Основание коррекции") no-error.
    
  end.

end procedure. /* m-platsys-exe */

procedure m-device-ref :
define variable v-rid-list as character no-undo .

  do
  on error undo, return error
  :
    
    run ref/codelay.p (parparentproc, "", "", "SpravDevice", "Справочник устройств") no-error.
    
  end.

end procedure. /* m-platsys-exe */


procedure m-cash-wthser-del-exe :
/*define input parameter p-pos-type as character no-undo .
define input parameter p-action as character no-undo .   */
 run str/diallog.w (
        input parparentproc
      , input this-procedure
      , input "str/sendwths.p":U
      , input ( v-cntxt-obj-type + {&delim-par} + string(v-cntxt-obj-code) + {&delim-par} + 'D':U)
      , input no /*p-auto-go*/
      , input "":U
      , input substitute("Отсылка данных по маскам серийных МЦ на кассы ")
  ) no-error.
end procedure. /* run-2cashpay */

procedure m-cash-dept-exe :
  define variable v-obj-db-num  as integer   no-undo initial ? .

  do
  on error undo, return error return-value
  :
    { gbl/objdbnum.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-obj-db-num
    }
    run str/diallog.w
      (input parparentproc
      ,input this-procedure
      ,input "str/senddept.p":U
      ,input (string(v-obj-db-num) + {&delim-par} + v-cntxt-obj-type + {&delim-par} + string(v-cntxt-obj-code) + {&delim-par} + 'U':U)
      ,input no /*p-auto-go*/
      ,input "":U
      ,input substitute("Отсылка данных по подразделениям на кассы БД &1", v-obj-db-num)
      ) no-error.
  end.
end procedure. /* m-cash-dept-exe */

procedure proc-chk-docs :
define input parameter p-bttns as character no-undo .
define input parameter p-mode as character no-undo .
DEFINE VARIABLE varrid-list as character no-undo .
  do
  on error undo, return error
  :

    run str/chk-docs.w (
                    input parparentproc
                    ,input p-bttns
                    ,input p-mode
                    ,input ?
                    ,input v-cntxt-obj-type
                    ,input v-cntxt-obj-code
                    ,input '':U
                    ,input '':U
                    ,input 0
                    ,input ?
                    ,input ?
                    ,input 0
                    ,output varrid-list) no-error.
  end.
end procedure. /* proc-chk-docs */

PROCEDURE m-chk-free-exe :
run proc-chk-docs in this-procedure (input 'b-del', input 'free':U).
END PROCEDURE.

PROCEDURE m-chk-del-exe :
define variable v-rid-list as character no-undo .
 run str/cchkdocs.w (
                        input parparentproc
                       , "b-restore":U /*bttns*/
                       , {&deletion}
                       , "":U /*p-doc-code*/
                       , v-cntxt-obj-type
                       , v-cntxt-obj-code
                       , input-output v-rid-list
                    ).
END PROCEDURE.

PROCEDURE m-chk-add-exe :
define variable v-rid-list as character no-undo .
 run str/cchkdocs.w (
                        input parparentproc
                       , "":U /*bttns*/
                       , {&add-def}
                       , "":U /*p-doc-code*/
                       , v-cntxt-obj-type
                       , v-cntxt-obj-code
                       , input-output v-rid-list
                    ).
END PROCEDURE.

PROCEDURE m-chk-off-del-exe :
define variable v-rid-list as character no-undo .
 run str/cchkdocs.w (
                        input parparentproc
                       , "":U /*bttns*/
                       , {&deletion}
                       , "":U /*p-doc-code*/
                       , v-cntxt-obj-type
                       , v-cntxt-obj-code
                       , input-output v-rid-list
                    ).
END PROCEDURE.

PROCEDURE m-chk-off-add-exe :
define variable v-rid-list as character no-undo .
 run str/cchkdocs.w (
                        input parparentproc
                       , "":U /*bttns*/
                       , {&add-def}
                       , "":U /*p-doc-code*/
                       , v-cntxt-obj-type
                       , v-cntxt-obj-code
                       , input-output v-rid-list
                    ).
END PROCEDURE.

PROCEDURE m-chk-list-off-exe :
run proc-chk-docs in this-procedure (input '', input {&g___object}).
END PROCEDURE.

PROCEDURE m-chk-list-all-off-exe :
DEFINE VARIABLE varrid-list as character no-undo .
define variable v-base-code as integer no-undo init ?.
define variable v-not-show  as logical no-undo .
define buffer buf_shop for ub.shop.
define buffer buf_sysconf for ub.sysconf.
_shop:
for each buf_shop no-lock,
    first buf_sysconf no-lock where
          buf_sysconf.host-code = buf_shop.host-code :
  if v-base-code <> ?
  AND buf_sysconf.base-code <> v-base-code then do:
    assign
    v-not-show = yes
    .
    leave _shop.
  end.
  assign
  v-base-code = buf_sysconf.base-code
  .
end.
if v-not-show then do:
  message
  "В Вашей системе имеются магазины, принадлежащие фирмам с разными базовыми валютами" skip
  "Просмотр ВСЕХ чеков невозможен"
  view-as alert-box error .
end.
else do:
  run proc-chk-docs in this-procedure (input '', input {&all}).
end.
END PROCEDURE.

procedure m-mrkt-petrol-exe :
  run run-mrkt-gds in this-procedure (input yes).
END procedure.

procedure m-mrkt-gds-exe :
  run run-mrkt-gds in this-procedure (input no).
END procedure.

procedure run-mrkt-gds:
define input parameter p-is-petrolium as logical no-undo .
define variable ri-list as character no-undo .
define variable v-plu-type as character no-undo .
define variable dflt-cd as character no-undo .
/*ищем кассу по умолчанию*/
{ gbl/dflt-cd.i v-cntxt-obj-type v-cntxt-obj-code dflt-cd }
IF dflt-cd = {&cd-type-maria} then do:
  assign
  v-plu-type = (if p-is-petrolium
                   then {&petrolium}
                   else '':U).
  run str/mrkt-gds.w (
                 input parparentproc
                ,input '':U
                ,input {&g___object}
                ,input v-cntxt-obj-type
                ,input v-cntxt-obj-code
                ,input dflt-cd
                ,input v-plu-type
                ,input-output ri-list) no-error .
end.
else do:
  message
  substitute("Кассы типа &1 на данном объекте не работают", {&cd-type-maria})
  view-as alert-box  ERROR.
end.

end procedure.

procedure m-mar-cli-exe :
DEFINE VARIABLE rid-list as character no-undo .
define variable v-delim as character no-undo .
  run str/mar-cli.w (
                 input parparentproc
                ,input '':U
                ,input {&g___object}
                ,input v-cntxt-obj-type
                ,input v-cntxt-obj-code
                ,input {&cd-type-maria}
                ,input-output rid-list) no-error .
end procedure. /* m-mar-cli-exe */


procedure m-rkep-gds-exe :
define variable ri-list as character no-undo .

run str/rkep-gds.w (
                parparentproc
              , '':U
              , {&all}
              , ('no' + {&delim-par} + 'no' + {&delim-par} + 'no' + {&delim-par} + 'no')
              , v-cntxt-obj-type
              , v-cntxt-obj-code
              , input-output ri-list) no-error .

end procedure.


procedure m-rkep-grp-exe :
define variable ri-list as character no-undo .
run str/rkep-grp.w (
                parparentproc
              , '':U
              , {&all}
              , ('no' + {&delim-par} + 'no')
              , v-cntxt-obj-type
              , v-cntxt-obj-code
              , input-output ri-list) no-error .

end procedure.

procedure m-rkep-cli-exe :
define variable ri-list as character no-undo .
run str/rkep-cli.w (
                parparentproc
              , '':U
              , {&all}
              , ('no' + {&delim-par} + 'no')
              , v-cntxt-obj-type
              , v-cntxt-obj-code
              , input-output ri-list) no-error .

end procedure.

PROCEDURE obj-sale-exe :

  define variable rid-list    as character no-undo .
  define variable v-host-code as integer   no-undo .

  do
  on error undo, return error return-value
  :
    if v-cntxt-obj-type = {&shop}
    then do:
      { gbl/hostcode.i
        v-cntxt-obj-type
        v-cntxt-obj-code
        v-host-code
      }

      run str/salelist.w
        (input  parparentproc
        ,input  "b-export":U
        ,input  {&g___object}
        ,input  v-host-code
        ,input  v-cntxt-obj-type
        ,input  v-cntxt-obj-code
        ,input-output rid-list
        ) no-error.
    end.
  end.
END PROCEDURE.

PROCEDURE del-sale-exe :
define variable rid-list    as character no-undo .
define variable v-host-code as integer   no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define variable v-mode as character no-undo .

do
on error undo, return error return-value
:
  if v-cntxt-obj-type = {&shop}
  and v-cntxt-level = {&cntxt-object}
  then do:
    { gbl/hostcode.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-host-code
    }
    assign
    v-mode = {&deleted} + {&comma-char} + {&g___object}
    v-obj-type = v-cntxt-obj-type
    v-obj-code = v-cntxt-obj-code
    .
  end.
  if v-cntxt-level = {&cntxt-firm}
  then do:
    assign
    v-mode = {&deleted} + {&comma-char} + {&company}
    v-host-code = v-cntxt-host-code-obj
    v-obj-type = '':U
    v-obj-code = 0
    .
  end.
  if v-cntxt-level = {&cntxt-global}
  then do:
    assign
    v-mode = {&deleted}
    v-host-code = 0
    v-obj-type = '':U
    v-obj-code = 0
    .
  end.
  run str/salclist.w
    (input  parparentproc
    ,input  "":U /*bttns*/
    ,input  v-mode
    ,input '':U /*p-inkas-code*/
    ,input  v-host-code
    ,input  v-obj-type
    ,input  v-obj-code
    ,input-output rid-list
    ) no-error.
end.
END PROCEDURE.


PROCEDURE host-sale-exe :

  define variable rid-list    as character no-undo .
  define variable v-host-code as integer   no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/hostcode.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-host-code
    }

    run str/salelist.w
      (input  parparentproc
      ,input  "b-export":U
      ,input  {&company}
      ,input  v-host-code
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input-output rid-list
      ) no-error.
  end.

END PROCEDURE.

PROCEDURE all-sale-exe :

  define variable rid-list    as character no-undo .
  define variable v-host-code as integer   no-undo .
  define variable v-ok        as logical   no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_documents_all':U
      {&cntxt-global}
      0
      '':U
      0
      0
      0
      0
      true
      v-ok
    }
    if v-ok = true
    then do:
      { gbl/hostcode.i
        v-cntxt-obj-type
        v-cntxt-obj-code
        v-host-code
      }

      run str/salelist.w
        (input  parparentproc
        ,input  'b-export':U
        ,input  {&all}
        ,input  v-host-code
        ,input  v-cntxt-obj-type
        ,input  v-cntxt-obj-code
        ,input-output rid-list
        ) no-error.
    end.
  end.
END PROCEDURE.

PROCEDURE m-chk-sl-exe :

  define variable rid-list    as character no-undo .
  define variable v-host-code as integer   no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/hostcode.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-host-code
    }
    run str/salelist.w
      (input  parparentproc
      ,input  "":U
      ,input  {&g___object}
      ,input  v-host-code
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input-output rid-list
      ) no-error.
  end.

END PROCEDURE.

PROCEDURE m-sale-lkp-exe :

  define variable rid-list    as character no-undo .
  define variable v-host-code as integer   no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/hostcode.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-host-code
    }
    run str/salelist.w
      (input  parparentproc
      ,input  "b-add":U
      ,input  {&g___new}
      ,input  v-host-code
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input-output rid-list
      ) no-error.
  end.

END PROCEDURE.

PROCEDURE m-chk-sale-exe :
define variable v-inkas-code as character no-undo .
run str/cre-sale.p ( input parparentproc
                   , input v-cntxt-obj-type
                   , input v-cntxt-obj-code
                   , input {&update}
                   , input 0 /*p-silent*/
                   , input '':U  /*p-shift-date*/
                   , input-output v-inkas-code
                   , input {&cash-desk}).
END PROCEDURE.

PROCEDURE m-sale-inf-exe :

  /*есть неучтенные чеки*/
  define variable not-all-saled-chk    as logical   no-undo initial no .
  /*есть ошибочные чеки*/
  define variable not-all-normal-chk       as logical   no-undo initial no .
  /*есть незакрытые продажи*/
  define variable not-all-inkas-closed as logical   no-undo initial no .
  define variable v-host-code              as integer   no-undo .
  define variable v-notes                  as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/hostcode.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-host-code
    }

    run str/chk-inf.p
      (input  parparentproc
      ,input  v-host-code
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  yes
      ,input  no
      ,input  ?
      ,output v-notes
      ,output not-all-saled-chk
      ,output not-all-normal-chk
      ,output not-all-inkas-closed
      ) no-error.

  end.

END PROCEDURE.



PROCEDURE m-chk-wth-r-exe :

  define variable v-host-code as integer   no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/hostcode.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-host-code
    }
    run str/inc-wth.w
      (input parparentproc
      ,input  v-host-code
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ).
  end.
END PROCEDURE.

PROCEDURE m-chk-wth-inf-exe :

  /*есть неучтенные чеки МЦ*/
  define variable not-all-doced  as logical   no-undo init no .
  /*есть ошибочные чеки МЦ*/
  define variable not-all-normal as logical   no-undo init no .
  /*есть незакрытые автодокументы МЦ*/
  define variable not-all-closed as logical   no-undo init no .
  define variable v-host-code    as integer   no-undo .
  define variable v-notes        as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/hostcode.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-host-code
    }
    run str/chk-winf.p
      (input  parparentproc
      ,input  v-host-code
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  yes
      ,input  no
      ,input  ?
      ,output v-notes
      ,output not-all-doced
      ,output not-all-normal
      ,output not-all-closed
      ).
  end.

END.

PROCEDURE m_scgdsobj-exe :
  run ref/scgdsobj.w
    (input  parparentproc
    ,input  {&g___object}
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ) .
END PROCEDURE.

PROCEDURE m_loc-ss-code-exe :
  define variable loc-ref-list as character no-undo .
  define variable v-host-code as integer no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/hostcode.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-host-code
    }
    run ref/locsscds.w
      (input  parparentproc
      ,input  "":U
      ,input  "":U
      ,input  v-host-code
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,output loc-ref-list
      ).
  end.
END PROCEDURE.

PROCEDURE m_pl-list :

  define variable ri-list          as character no-undo .

  do
  on error undo, return error return-value
  :
    if v-cntxt-db-num = v-cntxt-db-num-obj
    then do:
      run ref/pl-list.w
        (input  parparentproc
        ,input  'b-add'
        ,input  v-cntxt-obj-type
        ,input  v-cntxt-obj-code
        ,input  {&g___object}
        ,input-output ri-list
        ).
    end.
    else do:
      run ref/pl-list.w
        (input  parparentproc
        ,input  ''
        ,input  v-cntxt-obj-type
        ,input  v-cntxt-obj-code
        ,input  {&g___object}
        ,input-output ri-list
        ).
    end.
  end.
END PROCEDURE.

PROCEDURE m_sr-izmeren :
  define variable v-node-code as integer no-undo.
  define variable v-sr-type as character no-undo.
  do
  on error undo, return error return-value
  :
   v-node-code = 0 .
   run ref/sr-izm.w (input parparentproc
                    ,input "b-add"
                    ,input {&UPDATE}
                    ,input ""
                    ,input ""
                    ,input-output v-node-code
                    ,output v-sr-type
                    ).
  end.
END PROCEDURE.


PROCEDURE m_place-io-exe :

  define variable ri-list          as character no-undo .

  do
  on error undo, return error return-value
  :
    if v-cntxt-db-num = v-cntxt-db-num-obj
    then do:
      run ref/place-io.w
        (input  parparentproc
        ,input  'b-add'
        ,input  v-cntxt-obj-type
        ,input  v-cntxt-obj-code
        ,input  {&g___object}
        ,input  'all'
        ,input-output ri-list
        ).
    end.
    else do:
      run ref/place-io.w
        (input  parparentproc
        ,input  ''
        ,input  v-cntxt-obj-type
        ,input  v-cntxt-obj-code
        ,input  {&g___object}
        ,input  'all'
        ,input-output ri-list
        ).
    end.
  end.
END PROCEDURE.

PROCEDURE m_point-io-exe  :
  define variable ri-list          as character no-undo .

  do
  on error undo, return error return-value
  :
    run ref/point-io.w
        (input  parparentproc
        ,input  'b-add'
        ,input  v-cntxt-db-num
        ,input  '' /*cli-type*/
        ,input  0  /*cli-code*/
        ,input  {&g___object}
        ,input  'all'
        ,input-output ri-list
        ).
  end.
END PROCEDURE.


PROCEDURE m_pl-pump-nozzle :

  define variable rid#             as recid     no-undo .

  do
  on error undo, return error return-value
  :
    /* todo - Алексей Суслов */
  /*  list-mode = {&g___object}.*/
    if v-cntxt-db-num = v-cntxt-db-num-obj
    then do:
      run str/plpumpnz.w
        (input  parparentproc
        ,input  'b-add|b-del':U
        ,output rid#
        ).
    end.
    else do:
      run str/plpumpnz.w
        (input  parparentproc
        ,input  'b-help':U
        ,output rid#
        ).
    end.
  end.
END PROCEDURE.

procedure m_auto-tank :
  define variable varrec-tank      as recid no-undo.
  define variable varrec-meas      as recid no-undo.

  do
  on error undo, return error return-value
  :
    if v-cntxt-db-num = 0
    then do:
      run str/auto-tn.w
        (input parparentproc
        ,input  'b-add,b-chg,b-del':u
        ,input ""
        ,input 0
        ,output varrec-tank
        ,output varrec-meas
        ) .
    end.
    else do:
      run str/auto-tn.w
        (input parparentproc
        ,input  '':u
        ,input ""
        ,input 0
        ,output varrec-tank
        ,output varrec-meas
        ) .
    end.
  end.
end procedure.

procedure m_pl-all-list :

  define variable ri-list as character no-undo .

  do
  on error undo, return error return-value
  :
    run ref/pl-list.w
      (input  parparentproc
      ,input  ''
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  {&all}
      ,input-output ri-list
      ).
  end.
end procedure.

PROCEDURE m_wth-ref :

  define variable ri-list          as character no-undo .

  do
  on error undo, return error return-value
  :
    if v-cntxt-db-num = 0
    then do:
      run ref/wth-ref.w
        (input parparentproc
        ,input 'b-add':u
        ,input v-cntxt-host-code-obj
        ,input v-cntxt-obj-type
        ,input v-cntxt-obj-code
        ,input {&all}
        ,input-output ri-list
        ).
    end.
    else do:
      run ref/wth-ref.w
        (input parparentproc
        ,input '':U
        ,input v-cntxt-host-code-obj
        ,input v-cntxt-obj-type
        ,input v-cntxt-obj-code
        ,input {&all}
        ,input-output ri-list
        ).
    end.
  end.
END PROCEDURE.

PROCEDURE m_wthp-ref :

  define variable ri-list          as character no-undo .

  do
  on error undo, return error return-value
  :
    if v-cntxt-db-num = 0
    then do:
      run ref/wthp-ref.w
        (input parparentproc
        ,input 'b-add':u
        ,input v-cntxt-host-code-obj
        ,input v-cntxt-obj-type
        ,input v-cntxt-obj-code
        ,input {&all}
        ,input 0
        ,input-output ri-list
        ) .
    end.
    else do:
      run ref/wthp-ref.w
        (input parparentproc
        ,input '':U
        ,input v-cntxt-host-code-obj
        ,input v-cntxt-obj-type
        ,input v-cntxt-obj-code
        ,input {&all}
        ,input 0
        ,input-output ri-list
        ) .
    end.
  end.

END PROCEDURE.

PROCEDURE m_wths-ref :

  define variable rid-list          as character no-undo .

  do
  on error undo, return error return-value
  :
      run ref/wths-ref.w
        (input parparentproc
        ,input 'b-add,b-chg,b-del':u
        ,input v-cntxt-host-code-obj
        ,input v-cntxt-obj-type
        ,input v-cntxt-obj-code
        ,input {&all}
        ,input 0
        ,input 0
        ,input-output rid-list
        ) .

  end.

END PROCEDURE.


PROCEDURE m_wth-pl-list :

  define variable ri-list          as character no-undo .

  do
  on error undo, return error return-value
  :
    if v-cntxt-db-num = v-cntxt-db-num-obj
    then do:
      run ref/wthplref.w
        (input parparentproc
        ,input 'b-add':u
        ,input v-cntxt-host-code-obj
        ,input v-cntxt-obj-type
        ,input v-cntxt-obj-code
        ,input {&g___object}
        ,input-output ri-list
        ).
    end.
    else do:
      run ref/wthplref.w
        (input parparentproc
        ,input '':u
        ,input v-cntxt-host-code-obj
        ,input v-cntxt-obj-type
        ,input v-cntxt-obj-code
        ,input {&g___object}
        ,input-output ri-list
        ).
    end.
  end.
END PROCEDURE.

PROCEDURE m_wth-pl-host-list :
  define variable ri-list as character no-undo .

  do
  on error undo, return error return-value
  :
    run ref/wthplref.w
      (input parparentproc
      ,input ''
      ,input v-cntxt-host-code-obj
      ,input v-cntxt-obj-type
      ,input v-cntxt-obj-code
      ,input {&company}
      ,input-output ri-list
      ).
  end.
END PROCEDURE.

PROCEDURE m_wth-pl-all-list :
  define variable ri-list as character no-undo .

  do
  on error undo, return error return-value
  :
    run ref/wthplref.w
      (input parparentproc
      ,input ''
      ,input v-cntxt-host-code-obj
      ,input v-cntxt-obj-type
      ,input v-cntxt-obj-code
      ,input {&all}
      ,input-output ri-list
      ).
  end.
END PROCEDURE.

procedure wth-docs-exe :

  define input parameter p-mode as character no-undo .
  define input parameter p-doc-type as character no-undo .
  define input parameter p-ext-type as character no-undo.
  define input parameter p-status as character no-undo.
  define variable ri-list as character no-undo .

  do
  on error undo, return error return-value
  :
    run str/wth-docs.w
      (input  parparentproc
      ,input  'b-add'
      ,input  p-mode
      ,input  v-cntxt-host-code-obj
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  '':u
      ,input  0
      ,input  p-ext-type
      ,input  p-status
      ,input  p-doc-type
      ,input-output ri-list
      ).
  end.

end PROCEDURE.

procedure c-wth-doc-exe :

  define input parameter p-mode     as character no-undo .
  define input parameter p-doc-type as character no-undo .

  define variable ri-list as character no-undo .

  do
  on error undo, return error return-value
  :
    run str/wthcdocs.w
      (input  parparentproc
      ,input  'b-add'
      ,input  p-mode
      ,input  v-cntxt-host-code-obj
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  '':U
      ,input  0
      ,input  p-doc-type
      ,input '':U /*p-doc-code*/
      ,output ri-list
      ).
  end.

end PROCEDURE.

PROCEDURE m__all-exe :
  do
  on error undo, return error return-value
  :
    run sel-cur-menu-grp in parparentproc
      (input 'all':u
      ) no-error .
    if error-status :error
    then do:
      return error.
    end.
  end.
END PROCEDURE.

PROCEDURE m_help-exe :

  do
  on error undo, return error return-value
  :
    run run-help in parparentproc no-error .
  end.

END PROCEDURE.

PROCEDURE m_exit-exe :

  do
  on error undo, return error return-value
  :
    apply 'close' to parparentproc.
  end.

END PROCEDURE.

PROCEDURE new-all-rvs :
define variable v-rvs-rid as recid no-undo.    
run str/all-rvs.w (input parparentproc, input {&status}, input {&g___new}, output v-rvs-rid).
END PROCEDURE.

PROCEDURE prm-all-rvs :
define variable v-rvs-rid as recid no-undo.
run str/all-rvs.w (input parparentproc, input {&status}, input {&permitted}, output v-rvs-rid).
END PROCEDURE.

PROCEDURE fact-all-rvs :
define variable v-rvs-rid as recid no-undo.
run str/all-rvs.w (input parparentproc, input {&status}, input {&fact}, output v-rvs-rid).
END PROCEDURE.

PROCEDURE obj-all-rvs :
define variable v-rvs-rid as recid no-undo.
run str/all-rvs.w (input parparentproc, input {&g___object}, input ?, output v-rvs-rid).
END PROCEDURE.


PROCEDURE c-obj-rvs-exe :
define variable v-rvs-rid as recid no-undo.
run str/rvsalldocws-c.w (input parparentproc, input {&g___object}, input ?, output v-rvs-rid).
END PROCEDURE.


PROCEDURE firm-all-rvs :
define variable v-rvs-rid as recid no-undo.
run str/all-rvs.w (input parparentproc, input {&company}, input ?, output v-rvs-rid).
END PROCEDURE.

PROCEDURE all-all-rvs :
  define variable v-rvs-rid as recid no-undo.  
  define variable v-ok as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_documents_all':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    v-ok
  }
  if v-ok then do:
    run str/all-rvs.w (input parparentproc, input {&work}, input ?, output v-rvs-rid).
  end.
END PROCEDURE.

PROCEDURE new-all-test-asi :
define variable v-rvs-rid as recid no-undo.    
run str/all-test-asi.w (input parparentproc, input {&status}, input {&g___new}, output v-rvs-rid).
END PROCEDURE.

PROCEDURE fact-all-test-asi :
define variable v-rvs-rid as recid no-undo.
run str/all-test-asi.w (input parparentproc, input {&status}, input {&fact}, output v-rvs-rid).
END PROCEDURE.

PROCEDURE obj-all-test-asi :
define variable v-rvs-rid as recid no-undo.
run str/all-test-asi.w (input parparentproc, input {&g___object}, input ?, output v-rvs-rid).
END PROCEDURE.


PROCEDURE c-obj-test-asi :
define variable v-rvs-rid as recid no-undo.
run str/test-asi_alldocws-c.w (input parparentproc, input {&g___object}, input ?, output v-rvs-rid).
END PROCEDURE.


PROCEDURE firm-all-test-asi :
define variable v-rvs-rid as recid no-undo.
run str/all-test-asi.w (input parparentproc, input {&company}, input ?, output v-rvs-rid).
END PROCEDURE.

PROCEDURE all-all-test-asi :
  define variable v-rvs-rid as recid no-undo.  
  define variable v-ok as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_documents_all':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    v-ok
  }
  if v-ok then do:
    run str/all-test-asi.w (input parparentproc, input {&work}, input ?, output v-rvs-rid).
  end.
END PROCEDURE.

PROCEDURE new-all-icnt :
define variable v-rid-list as character no-undo .
run ref/icntdocs.w ( input parparentproc
                   , input 'b-add':U /*bttns*/
                   , input {&status}
                   , input {&g___new}
                   , input {&icnt-doc}
                   , input v-cntxt-host-code-obj
                   , input v-cntxt-obj-type
                   , input v-cntxt-obj-code
                   , input-output v-rid-list
                   ) no-error .
END PROCEDURE.

PROCEDURE fact-all-icnt :
define variable v-rid-list as character no-undo .
run ref/icntdocs.w ( input parparentproc
                   , input '':U /*bttns*/
                   , input {&status}
                   , input {&fact}
                   , input {&icnt-doc}
                   , input v-cntxt-host-code-obj
                   , input v-cntxt-obj-type
                   , input v-cntxt-obj-code
                   , input-output v-rid-list
                   ) no-error .
END PROCEDURE.

PROCEDURE obj-all-icnt :
define variable v-rid-list as character no-undo .
run ref/icntdocs.w ( input parparentproc
                   , input 'b-add':U /*bttns*/
                   , input {&g___object}
                   , input ?
                   , input {&icnt-doc}
                   , input v-cntxt-host-code-obj
                   , input v-cntxt-obj-type
                   , input v-cntxt-obj-code
                   , input-output v-rid-list
                   ) no-error .
END PROCEDURE.

PROCEDURE firm-all-icnt :
define variable v-rid-list as character no-undo .
run ref/icntdocs.w ( input parparentproc
                   , input '':U /*bttns*/
                   , input {&company}
                   , input ?
                   , input {&icnt-doc}
                   , input v-cntxt-host-code-obj
                   , input v-cntxt-obj-type
                   , input v-cntxt-obj-code
                   , input-output v-rid-list
                   ) no-error .

END PROCEDURE.

PROCEDURE all-all-icnt :
  define variable v-ok as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_documents_all':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    v-ok
  }
  if v-ok
  then do:
    define variable v-rid-list as character no-undo .
    run ref/icntdocs.w ( input parparentproc
                      , input '':U /*bttns*/
                      , input {&all}
                      , input ?
                      , input {&icnt-doc}
                      , input v-cntxt-host-code-obj
                      , input v-cntxt-obj-type
                      , input v-cntxt-obj-code
                      , input-output v-rid-list
                      ) no-error .
  end.
END PROCEDURE.

PROCEDURE new-all-eicnt :
define variable v-rid-list as character no-undo .
run ref/icntdocs.w ( input parparentproc
                   , input 'b-add':U /*bttns*/
                   , input {&status}
                   , input {&g___new}
                   , input {&icnt-err}
                   , input v-cntxt-host-code-obj
                   , input v-cntxt-obj-type
                   , input v-cntxt-obj-code
                   , input-output v-rid-list
                   ) no-error .
END PROCEDURE.

PROCEDURE fact-all-eicnt :
define variable v-rid-list as character no-undo .
run ref/icntdocs.w ( input parparentproc
                   , input '':U /*bttns*/
                   , input {&status}
                   , input {&fact}
                   , input {&icnt-err}
                   , input v-cntxt-host-code-obj
                   , input v-cntxt-obj-type
                   , input v-cntxt-obj-code
                   , input-output v-rid-list
                   ) no-error .
END PROCEDURE.

PROCEDURE obj-all-eicnt :
define variable v-rid-list as character no-undo .
run ref/icntdocs.w ( input parparentproc
                   , input 'b-add':U /*bttns*/
                   , input {&g___object}
                   , input ?
                   , input {&icnt-err}
                   , input v-cntxt-host-code-obj
                   , input v-cntxt-obj-type
                   , input v-cntxt-obj-code
                   , input-output v-rid-list
                   ) no-error .
END PROCEDURE.

PROCEDURE firm-all-eicnt :
define variable v-rid-list as character no-undo .
run ref/icntdocs.w ( input parparentproc
                   , input '':U /*bttns*/
                   , input {&company}
                   , input ?
                   , input {&icnt-err}
                   , input v-cntxt-host-code-obj
                   , input v-cntxt-obj-type
                   , input v-cntxt-obj-code
                   , input-output v-rid-list
                   ) no-error .

END PROCEDURE.

PROCEDURE all-all-eicnt :
  define variable v-ok as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_documents_all':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    v-ok
  }
  if v-ok
  then do:
    define variable v-rid-list as character no-undo .
    run ref/icntdocs.w ( input parparentproc
                      , input '':U /*bttns*/
                      , input {&all}
                      , input ?
                      , input {&icnt-err}
                      , input v-cntxt-host-code-obj
                      , input v-cntxt-obj-type
                      , input v-cntxt-obj-code
                      , input-output v-rid-list
                      ) no-error .
  end.
END PROCEDURE.

procedure c-m-all-exe :
  run c-trn-doc-all-exe in this-procedure ( input ? ).
end procedure. /* c-m-all-exe */

procedure dm-c-doc-exe :
  define input parameter parlistmode     as character no-undo.
  define input parameter parflag         as logical   no-undo.
  define input parameter parstat         as character no-undo.
  define input parameter partype         as character no-undo.
  define input parameter parinternal     as logical   no-undo.
  define input parameter parext-doc-type as character no-undo.
  define input parameter paris-hold      as logical   no-undo.

  define variable loc-ref-list as character no-undo.

  run str/calldocs.w (  input parparentproc,
                    input ( if parlistmode = "?" then ? else parlistmode ),
                    input ( if parstat     = "?" then ? else parstat     ),
                    input ( if partype     = "?" then ? else partype     ),
                    input ?,
                    input parinternal,
                    input "":U,
                    input parext-doc-type,
                    input paris-hold,
                    input ?,
                    input v-cntxt-obj-type,
                    input v-cntxt-obj-code,
                   output loc-ref-list ).
end procedure. /* dm-c-doc-exe */

PROCEDURE m_pl-gds-pump:
  define variable v-current-db-num as integer   no-undo .
  define variable v-obj-db-num     as integer   no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/curdbnum.i
      v-current-db-num
    }
    { gbl/objdbnum.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-obj-db-num
    }
    if v-current-db-num = v-obj-db-num
    then do:
      /* todo - объект активный */
      run str/wplgdspm.w
        (input parparentproc
        ,input v-cntxt-obj-type
        ,input v-cntxt-obj-code
        ,input 'b-cur|b-block'
        ) .
    end.
    else do:
      run str/wplgdspm.w (input parparentproc,
                      input v-cntxt-obj-type,
                      input v-cntxt-obj-code,
                      input '').
    end.
  end.
END PROCEDURE.

PROCEDURE m_banks-exe:
  define variable v-rid-list as character no-undo .
  define variable v-status_ like ub.fin-bank.status_ no-undo init {&current-status}.

  do
  on error undo, return error return-value
  :
    run ref/finbanks.w
      (input parparentproc
      ,input v-cntxt-host-code-obj
      ,input "b-add,b-mark":U
      ,input {&company}
      ,input v-cntxt-host-code-obj
      ,input-output v-status_
      ,input-output v-rid-list
      ).
  end.

END PROCEDURE.

PROCEDURE m_schets-exe:
  define variable v-rid-list as character no-undo .
  define variable v-status_ like ub.fin-bank.status_ no-undo init {&current-status}.

  do
  on error undo, return error return-value
  :
    run ref/finschts.w
      (input parparentproc
      ,input v-cntxt-host-code-obj
      ,input "b-add,b-mark":U
      ,input {&company}
      ,input "":U
      ,input 0
      ,input ?
      ,input v-cntxt-host-code-obj
      ,input 0
      ,input-output v-status_
      ,input-output v-rid-list
      ).
  end.
END PROCEDURE.


PROCEDURE m-condkeep-ref-exe :
  define variable v-sts as integer no-undo.
  define variable v-rid-list as character no-undo .

  do
  on error undo, return error return-value
  :
    run ref/cndkeeps.w
      (input  parparentproc
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  "b-add":U
      ,input  {&all}
      ,input-output v-sts
      ,input-output v-rid-list
      ) no-error .
  end.
end PROCEDURE.

PROCEDURE m-all-exe :
DEFINE VARIABLE loc-ref-list as character no-undo.
define variable v-ok as logical   no-undo .
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_documents_all':U
  {&cntxt-global}
  0
  '':U
  0
  0
  0
  0
  true
  v-ok
}
if v-ok then do:
  run str/all-docs.w (input parparentproc, ?,?,?, input {&work}, input ?, input ?, input ?, input ?, input "b-mark", input ?, input ?, input ?, output loc-ref-list).
end.
END PROCEDURE.

PROCEDURE m-load-exe :
DEFINE VARIABLE loc-ref-list as character no-undo.
run str/all-docs.w (input parparentproc, ?,?,?,  input {&shipping}, input ?, input ?, input ?, input ?, input "":u, input ?, input ?, input ?, output loc-ref-list).
END PROCEDURE.

PROCEDURE m-rep-book-exe :

define variable varcli-type   like ub.clients.obj-type no-undo.
define variable varcli-code   like ub.clients.obj-code no-undo.
define variable vartnved      as   character           no-undo format "x(10)":u.
define variable varcst-units  as   character           no-undo.
define variable varis-ok      as   logical             no-undo initial no.
define variable from-date as date no-undo .
define variable to-date as date no-undo .
run rep/get-cst.w ( input parparentproc
                   ,input-output from-date
                   ,input-output to-date
                   ,input v-cntxt-host-code-obj
                   ,INPUT {&stock}
                   ,OUTPUT varcli-type
                   ,OUTPUT varcli-code
                   ,OUTPUT vartnved
                   ,OUTPUT varcst-units
                   ,OUTPUT varis-ok) no-error.
IF ERROR-STATUS:ERROR OR
   NOT varis-ok THEN
  RETURN ERROR.
  run rep/v-cst.w
    (input parparentproc,
    input varcli-type,
    input varcli-code,
    input from-date,
    input to-date,
    input vartnved,
    input varcst-units,
    input 'OUT'
    ).
END PROCEDURE.

PROCEDURE m-rep-sm-exe :

define variable varcli-type   like ub.clients.obj-type no-undo.
define variable varcli-code   like ub.clients.obj-code no-undo.
define variable vartnved      as   character           no-undo format "x(10)":u.
define variable varcst-units  as   character           no-undo.
define variable varis-ok      as   logical             no-undo initial no.
define variable v-host-code   like ub.sysconf.host-code no-undo .
define variable from-date as date no-undo .
define variable to-date as date no-undo .

{ gbl/hostcode.i v-cntxt-obj-type v-cntxt-obj-code v-host-code }
run rep/get-cst.w (
                    input parparentproc
                  , input-output from-date
                  , input-output to-date
                  , input v-host-code
                  , INPUT ''
                  , OUTPUT varcli-type
                  , OUTPUT varcli-code
                  , OUTPUT vartnved
                  , OUTPUT varcst-units
                  , OUTPUT varis-ok) no-error.
IF ERROR-STATUS:ERROR OR
   NOT varis-ok THEN
  RETURN ERROR.
run rep/v-cst.w (input parparentproc, INPUT varcli-type, INPUT varcli-code, input from-date, input to-date, INPUT vartnved, INPUT varcst-units, INPUT 'IN').
END PROCEDURE.

PROCEDURE m-rep-stsm-exe  :

define variable varcli-type   like ub.clients.obj-type no-undo.
define variable varcli-code   like ub.clients.obj-code no-undo.
define variable vartnved      as   character           no-undo format "x(10)":u.
define variable varcst-units  as   character           no-undo.
define variable varis-ok      as   logical             no-undo initial no.
define variable v-host-code   like ub.sysconf.host-code no-undo .
define variable from-date as date no-undo .
define variable to-date as date no-undo .

{ gbl/hostcode.i v-cntxt-obj-type v-cntxt-obj-code v-host-code }
run rep/get-cst.w ( input parparentproc
                  , input-output from-date
                  , input-output to-date
                  , input v-host-code
                  , INPUT 'all'
                  , OUTPUT varcli-type
                  , OUTPUT varcli-code
                  , OUTPUT vartnved
                  , OUTPUT varcst-units
                  , OUTPUT varis-ok) no-error.
IF ERROR-STATUS:ERROR OR
   NOT varis-ok THEN
  RETURN ERROR.
    run rep/v-cst.w (
      input parparentproc,
      INPUT 'all',
      INPUT 0,
      input from-date,
      input to-date,
      INPUT vartnved,
      INPUT varcst-units,
      INPUT 'IN')
      .
END PROCEDURE.

PROCEDURE m-rep-gtd-exe :

  DEFINE VARIABLE varcst-units  AS   CHARACTER           NO-UNDO.
  DEFINE VARIABLE varis-ok      AS   LOGICAL             NO-UNDO INITIAL NO.
  DEFINE VARIABLE varcst-code   LIKE ub.parts.cst-code   NO-UNDO.
  DEFINE VARIABLE vardate       AS   DATE                NO-UNDO.

  run rep/get-code.w ( OUTPUT varcst-code, OUTPUT vardate, OUTPUT varcst-units, OUTPUT varis-ok ) NO-ERROR.
  IF ERROR-STATUS :ERROR OR
     varis-ok <> YES THEN DO:
    RETURN ERROR.
  END.
  run rep/v-gtd.w ( INPUT parparentproc, INPUT varcst-code, INPUT vardate, INPUT varcst-units ) NO-ERROR.
END PROCEDURE. /* m-rep-gtd-exe */

PROCEDURE m_superchk :
define variable v-doc-rec as recid no-undo .
  run str/rsperchk.p (parparentproc, {&add-def}, v-cntxt-obj-type,  v-cntxt-obj-code).
END.

PROCEDURE m_search-ser-exe :
define variable v-gds-rec as recid no-undo .
  run str/ser-sale.w (
                  input parparentproc
                 ,input v-cntxt-obj-type
                 ,input v-cntxt-obj-code
                 ,input v-gds-rec
                  )no-error.
END PROCEDURE.

PROCEDURE m_checkwth-exe :
  run str/chckwthr.p
    (input parparentproc
    ,input {&add-def}
    ,input v-cntxt-obj-type
    ,input v-cntxt-obj-code
    ) no-error.
END PROCEDURE.

PROCEDURE m_twogoods-exe :

  run ref/twogoods.w (
                  input parparentproc
                 ,input {&g___object}
                 ,input v-cntxt-obj-type
                 ,input v-cntxt-obj-code
                 )
               no-error.
END PROCEDURE.

PROCEDURE m_calendar-exe :
  define variable v-disp-date as date      no-undo .
  define variable v-ok        as logical   no-undo .
  assign
    v-disp-date = today
  .
        run gbl/d-inpday.w
          (input ?                        /* h-callback    */
          ,input "Календарь"              /* p-title       */
          ,input ""                       /* p-description */
          ,input "holyday"                /* p-mode        */
          ,input-output v-disp-date       /* p-date        */
          ,output v-ok                    /* p-ok          */
          ) no-error.
END PROCEDURE.


PROCEDURE m_disable-online-check :
  define buffer buf_thbj-attr for ub.thbj-attr .
  define variable p-enable-item as logical   no-undo .
  
  run chk-goods_add(output p-enable-item)no-error .
  if not p-enable-item then return .
  
  define variable v-current-db-num as integer   no-undo .
  define variable v-obj-db-num     as integer   no-undo .
  define variable v-CrashCh        as logical   no-undo .
  define variable v-ok             as logical   no-undo .
     
  message
   "Внимание! При включении аварии продажа маркированной продукции на кассе происходит без проверки в Честном Знаке! Включить аварию?"    
    view-as alert-box question buttons yes-no update v-ok .
  if v-ok <> true then do:
      return.
  end.    
  
  { gbl/curdbnum.i
    v-current-db-num
  }
  v-CrashCh = no.
  if v-current-db-num <> 0 then do:
      /* изменяем локальное значение для данного магазина */
      run chgCrashSituat (v-current-db-num, {&db}, yes, yes, output v-CrashCh).      
  end.
  else do:
      /* меняем значение для всех локальных секций */
      for each ub.db no-lock :
        run chgCrashSituat (ub.db.db-num, {&db}, yes, no, output v-CrashCh).         
      end.
      /* меняем глобальное значение */
      run chgCrashSituat (0, "", yes, no, output v-CrashCh).
  end.
  if v-CrashCh = yes then
  message "Параметр «Аварийная ситуация в ГИС МТ» - включен"
    view-as alert-box.          
  
END PROCEDURE.

PROCEDURE m_enable-online-check :
  define buffer buf_thbj-attr for ub.thbj-attr .
  define variable p-enable-item as logical   no-undo .
  run chk-goods_add(output p-enable-item)no-error .
  if not p-enable-item then return .
  define variable v-current-db-num as integer   no-undo .
  define variable v-obj-db-num     as integer   no-undo .
  define variable v-CrashCh        as logical   no-undo .

    { gbl/curdbnum.i
      v-current-db-num
    }
  v-CrashCh = no.
  if v-current-db-num <> 0 then do:
    /* изменяем локальное значение для данного магазина */
    run chgCrashSituat (v-current-db-num, {&db}, no, yes, output v-CrashCh).     
  end.
  else do:
      /* изменяем значение для всех локальных секций */
      for each ub.db no-lock : 
        run chgCrashSituat (ub.db.db-num, {&db}, no, no, output v-CrashCh).         
      end.
      /* изменяем глобальное значение */
      run chgCrashSituat (0, "", no, no, output v-CrashCh).
  end.
  if v-CrashCh = yes then
  message "Параметр «Аварийная ситуация в ГИС МТ» - выключен"
    view-as alert-box.          

END PROCEDURE.

PROCEDURE chgCrashSituat:
   define input  parameter iObjCode as integer no-undo.
   define input  parameter iObjType as character no-undo.
   define input  parameter iValue   as logical no-undo.
   define input  parameter iCreateLocal as logical no-undo.
   define output parameter oChgVal  as logical no-undo. 
    
   define buffer buf_thbj-attr for ub.thbj-attr .
   
   do transaction
       on error undo, return error:       
       oChgVal = no.
        
       find first buf_thbj-attr exclusive-lock where 
                  buf_thbj-attr.obj-code = iObjCode and
                  buf_thbj-attr.obj-type = iObjType and
                  buf_thbj-attr.upper-prop-code = {&attr-gisMT} and
                  buf_thbj-attr.prop-code = {&attr-gisMT_crashSituat}
              no-wait no-error.
       if not avail buf_thbj-attr and 
          iCreateLocal = yes 
       then do:       
           run crLocalCrashSit (iObjCode,
                                iObjType,
                                iValue,   
                                output oChgVal ) no-error.        
       end.             
       else if avail buf_thbj-attr 
       then do:           
          buf_thbj-attr.property-value-logical = iValue .      
          oChgVal = yes.
       end.
   end. 
END PROCEDURE.

PROCEDURE crLocalCrashSit:
    define input  parameter iObjCode as integer no-undo.
    define input  parameter iObjType as character no-undo.
    define input  parameter iValue   as logical no-undo.
    define output parameter oChgVal  as logical no-undo.
    
    define variable v-param-type      as character  no-undo .
    define variable v-value-character as character  no-undo .
    define variable v-value-date      as date       no-undo .
    define variable v-value-decimal   as decimal    no-undo .
    define variable v-value-integer   as integer    no-undo .
    define variable v-value-logical   as logical    no-undo .
    define variable v-tth             as handle     no-undo . 
    
    for each thbjattr_thbj-attr:
      delete thbjattr_thbj-attr.
    end.
    run adm/shattri.p (
      input "init":U
      ,input  iObjType
      ,input  iObjCode
      ,input  {&attr-gisMT}
      ,input  "":U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table thbjattr_thbj-attr
      )  no-error.
      

    for each thbjattr_thbj-attr
    on error undo, return error return-value
    :        
      if thbjattr_thbj-attr.prop-code = {&attr-gisMT_crashSituat}
      then do:                   
          thbjattr_thbj-attr.property-value-logical = iValue.                         
      end .
      else delete thbjattr_thbj-attr.
    end.
    
    RUN thbjattr_set-section IN THIS-PROCEDURE (
             input iObjType
            ,input iObjCode
            ,input {&attr-gisMT}
            ,INPUT table thbjattr_thbj-attr
        ) NO-ERROR.
    if error-status:error then do:
        message "Не удалось сохранить настройки"
        view-as alert-box.
        undo, return error.
    end.      
    else oChgVal = yes .
    
END PROCEDURE.    

PROCEDURE m_obj-sht-all-exe :
  define variable varrid-list   as   character           no-undo.
  run str/sht-all.w (parparentproc, v-cntxt-obj-type, v-cntxt-obj-code, 'b-add', 'obj', v-cntxt-obj-type, v-cntxt-obj-code, '':U,  input-OUTPUT varrid-list) no-error.
END PROCEDURE.

procedure obj-ext-in-new-no-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT no, INPUT {&wayb}, INPUT {&income}, INPUT no, INPUT {&TDEDT_Pri_Vnesh}, input no) .
  end.

end procedure. /* obj-ext-in-new-no-exe */

procedure obj-ext-in-new-ok-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT yes, INPUT {&wayb}, INPUT {&income}, INPUT no, INPUT {&TDEDT_Pri_Vnesh}, input no) .
  end.

end procedure. /* obj-ext-in-new-ok-exe */

procedure obj-ext-in-new-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&wayb}, INPUT {&income}, INPUT no, INPUT {&TDEDT_Pri_Vnesh}, input no) .
  end.

end procedure. /* obj-ext-in-new-all-exe */

procedure obj-ext-in-fact-no-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT no, INPUT {&fact}, INPUT {&income}, INPUT no, INPUT {&TDEDT_Pri_Vnesh}, input no) .
  end.

end procedure. /* obj-ext-in-fact-no-exe */

procedure obj-ext-in-fact-ok-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT yes, INPUT {&fact}, INPUT {&income}, INPUT no, INPUT {&TDEDT_Pri_Vnesh}, input no) .
  end.

end procedure. /* obj-ext-in-fact-ok-exe */

procedure obj-ext-in-fact-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&fact}, INPUT {&income}, INPUT no, INPUT {&TDEDT_Pri_Vnesh}, input no) .
  end.

end procedure. /* obj-ext-in-fact-all-exe */

procedure obj-ext-in-req-no-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT no, INPUT {&inquiry}, INPUT {&income}, INPUT no, INPUT {&TDEDT_Pri_Vnesh}, input no) .
  end.

end procedure. /* obj-ext-in-req-no-exe */

procedure obj-ext-in-req-ok-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT yes, INPUT {&inquiry}, INPUT {&income}, INPUT no, INPUT {&TDEDT_Pri_Vnesh}, input no) .
  end.

end procedure. /* obj-ext-in-req-ok-exe */

procedure obj-ext-in-req-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&inquiry}, INPUT {&income}, INPUT no, INPUT {&TDEDT_Pri_Vnesh}, input no) .
  end.

end procedure. /* obj-ext-in-req-all-exe */

procedure obj-ext-in-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&type}, INPUT ?, INPUT '?', INPUT {&income}, INPUT no, INPUT {&TDEDT_Pri_Vnesh}, input no) .
  end.

end procedure. /* obj-ext-in-all-exe */

procedure obj-cor-part-all :
  do
  on error undo, return error return-value
  :
   run dm-doc-exe (INPUT {&type}, INPUT ?, INPUT '?', INPUT {&inventory}, INPUT no, INPUT {&TDEDT_Corr_Minus_Parts}, input no).
  end.
end procedure.

procedure obj-ext-out-new-no-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT no, INPUT {&wayb}, INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh}, input no) .
  end.

end procedure. /* obj-ext-out-new-no-exe */

procedure obj-ext-out-new-ok-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT yes, INPUT {&wayb}, INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh}, input no) .
  end.

end procedure. /* obj-ext-out-new-ok-exe */

procedure obj-ext-out-new-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&wayb}, INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh}, input no) .
  end.

end procedure. /* obj-ext-out-new-all-exe */

procedure obj-ext-out-perm-no-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT no, INPUT {&permitted}, INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh}, input no) .
  end.

end procedure. /* obj-ext-out-perm-no-exe */

procedure obj-ext-out-perm-ok-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT yes, INPUT {&permitted}, INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh}, input no) .
  end.

end procedure. /* obj-ext-out-perm-ok-exe */

procedure obj-ext-out-perm-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&permitted}, INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh}, input no) .
  end.

end procedure. /* obj-ext-out-perm-all-exe */

procedure obj-ext-out-fact-no-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT no, INPUT {&fact}, INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh}, input no) .
  end.

end procedure. /* obj-ext-out-fact-no-exe */

procedure obj-ext-out-fact-ok-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT yes, INPUT {&fact}, INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh}, input no) .
  end.

end procedure. /* obj-ext-out-fact-ok-exe */

procedure obj-ext-out-fact-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&fact}, INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh}, input no) .
  end.

end procedure. /* obj-ext-out-fact-all-exe */

procedure obj-ext-out-req-no-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT no, INPUT {&inquiry}  , INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh}, input no) .
  end.

end procedure. /* obj-ext-out-req-no-exe */

procedure obj-ext-out-req-ok-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT yes, INPUT {&inquiry} , INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh}, input no) .
  end.

end procedure. /* obj-ext-out-req-ok-exe */

procedure obj-ext-out-req-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&inquiry}, INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh}, input no) .
  end.

end procedure. /* obj-ext-out-req-all-exe */

procedure obj-ext-out-req-z-exe :

  do
  on error undo, return error return-value
  :
    run dm-fl-exe  (INPUT {&is-flor} + {&status}, INPUT ?, INPUT {&inquiry}) .
  end.

end procedure. /* obj-ext-out-req-z-exe */

procedure obj-ext-out-req-w-exe :

  do
  on error undo, return error return-value
  :
    run dm-fl-exe  (INPUT {&is-flor} + {&status}, INPUT ?, INPUT {&wayb}) .
  end.

end procedure. /* obj-ext-out-req-w-exe */

procedure obj-ext-out-req-per-exe :

  do
  on error undo, return error return-value
  :
    run dm-fl-exe  (INPUT {&is-flor} + {&status}, INPUT ?, INPUT {&permitted}) .
  end.

end procedure. /* obj-ext-out-req-per-exe */

procedure obj-ext-out-req-f-exe :

  do
  on error undo, return error return-value
  :
    run dm-fl-exe  (INPUT {&is-flor} + {&status}, INPUT ?, INPUT {&fact}) .
  end.

end procedure. /* obj-ext-out-req-f-exe */

procedure obj-ext-out-req-nakl-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-fl-exe  (INPUT {&is-flor} + {&g___object}, INPUT ?, INPUT ?) .
  end.

end procedure. /* obj-ext-out-req-nakl-all-exe */

procedure obj-ext-out-req-redy-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT yes, INPUT {&ready}, INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh}, input no) .
  end.

end procedure. /* obj-ext-out-req-redy-exe */

procedure obj-ext-out-req-reject-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT yes, INPUT {&rejected}, INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh}, input no) .
  end.

end procedure. /* obj-ext-out-req-reject-exe */

procedure obj-ext-out-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&type}, INPUT ?, INPUT '?', INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh}, input no) .
  end.

end procedure. /* obj-ext-out-all-exe */

procedure obj-ext-out-kass-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&type}, INPUT ?, INPUT '?', INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh_Kass}, input no) .
  end.

end procedure. /* obj-ext-out-kass-all-exe */

procedure obj-ext-sup-new-no-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT no, INPUT {&wayb}, INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh_VP}, input no) .
  end.

end procedure. /* obj-ext-sup-new-no-exe */

procedure obj-ext-sup-new-ok-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT yes, INPUT {&wayb}, INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh_VP}, input no) .
  end.

end procedure. /* obj-ext-sup-new-ok-exe */

procedure obj-ext-sup-new-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&wayb}, INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh_VP}, input no) .
  end.

end procedure. /* obj-ext-sup-new-all-exe */

procedure obj-ext-sup-perm-no-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT no, INPUT {&permitted}, INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh_VP}, input no) .
  end.

end procedure. /* obj-ext-sup-perm-no-exe */

procedure obj-ext-sup-perm-ok-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT yes, INPUT {&permitted}, INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh_VP}, input no) .
  end.

end procedure. /* obj-ext-sup-perm-ok-exe */

procedure obj-ext-sup-perm-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&permitted}, INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh_VP}, input no) .
  end.

end procedure. /* obj-ext-sup-perm-all-exe */

procedure obj-ext-sup-fact-no-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT no, INPUT {&fact}, INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh_VP}, input no) .
  end.

end procedure. /* obj-ext-sup-fact-no-exe */

procedure obj-ext-sup-fact-ok-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT yes, INPUT {&fact}, INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh_VP}, input no) .
  end.

end procedure. /* obj-ext-sup-fact-ok-exe */

procedure obj-ext-sup-fact-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&fact}, INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh_VP}, input no) .
  end.

end procedure. /* obj-ext-sup-fact-all-exe */

procedure obj-ext-sup-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&type}, INPUT ?, INPUT '?', INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh_VP}, input no) .
  end.

end procedure. /* obj-ext-sup-all-exe */

procedure obj-ext-ret-new-no-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT no, INPUT {&wayb}, INPUT {&return}, INPUT no, INPUT {&TDEDT_Vozvrat_Vnesh}, input no) .
  end.

end procedure. /* obj-ext-ret-new-no-exe */

procedure obj-ext-ret-new-ok-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT yes, INPUT {&wayb}, INPUT {&return}, INPUT no, INPUT {&TDEDT_Vozvrat_Vnesh}, input no) .
  end.

end procedure. /* obj-ext-ret-new-ok-exe */

procedure obj-ext-ret-new-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&wayb}, INPUT {&return}, INPUT no, INPUT {&TDEDT_Vozvrat_Vnesh}, input no) .
  end.

end procedure. /* obj-ext-ret-new-all-exe */

procedure obj-ext-ret-perm-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&permitted}, INPUT {&return}, INPUT no, INPUT {&TDEDT_Vozvrat_Vnesh}, input no) .
  end.

end procedure. /* obj-ext-ret-perm-exe */

procedure obj-ext-ret-fact-no-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT no, INPUT {&fact}, INPUT {&return}, INPUT no, INPUT {&TDEDT_Vozvrat_Vnesh}, input no) .
  end.

end procedure. /* obj-ext-ret-fact-no-exe */

procedure obj-ext-ret-fact-ok-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT yes, INPUT {&fact}, INPUT {&return}, INPUT no, INPUT {&TDEDT_Vozvrat_Vnesh}, input no) .
  end.

end procedure. /* obj-ext-ret-fact-ok-exe */

procedure obj-ext-ret-fact-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&fact}, INPUT {&return}, INPUT no, INPUT {&TDEDT_Vozvrat_Vnesh}, input no) .
  end.

end procedure. /* obj-ext-ret-fact-all-exe */

procedure obj-ext-ret-req-no-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT no, INPUT {&inquiry}, INPUT {&return}, INPUT no, INPUT {&TDEDT_Vozvrat_Vnesh}, input no) .
  end.

end procedure. /* obj-ext-ret-req-no-exe */

procedure obj-ext-ret-req-ok-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT yes, INPUT {&inquiry}, INPUT {&return}, INPUT no, INPUT {&TDEDT_Vozvrat_Vnesh}, input no) .
  end.

end procedure. /* obj-ext-ret-req-ok-exe */

procedure obj-ext-ret-req-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&inquiry}, INPUT {&return}, INPUT no, INPUT {&TDEDT_Vozvrat_Vnesh}, input no) .
  end.

end procedure. /* obj-ext-ret-req-all-exe */

procedure obj-ext-ret-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&type}, INPUT ?, INPUT '?', INPUT {&return}, INPUT no, INPUT {&TDEDT_Vozvrat_Vnesh}, input no) .
  end.

end procedure. /* obj-ext-ret-all-exe */

procedure obj-ext-retc-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&type}, INPUT ?, INPUT '?', INPUT {&return}, INPUT no, INPUT {&TDEDT_Vozvrat_Vnesh_Kass}, input no) .
  end.

end procedure. /* obj-ext-retc-all-exe */

procedure obj-aw-new-no-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT no, INPUT {&wayb}, INPUT {&write-off}, INPUT no, INPUT {&TDEDT_Spi_Vnesh}, input no) .
  end.

end procedure. /* obj-aw-new-no-exe */

procedure obj-aw-new-ok-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT yes, INPUT {&wayb}, INPUT {&write-off}, INPUT no, INPUT {&TDEDT_Spi_Vnesh}, input no) .
  end.

end procedure. /* obj-aw-new-ok-exe */

procedure obj-aw-new-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&wayb}, INPUT {&write-off}, INPUT no, INPUT {&TDEDT_Spi_Vnesh}, input no) .
  end.

end procedure. /* obj-aw-new-all-exe */

procedure obj-aw-perm-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&permitted}, INPUT {&write-off}, INPUT no, INPUT {&TDEDT_Spi_Vnesh}, input no) .
  end.

end procedure. /* obj-aw-perm-exe */

procedure obj-aw-fact-no-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT no, INPUT {&fact}, INPUT {&write-off}, INPUT no, INPUT {&TDEDT_Spi_Vnesh}, input no) .
  end.

end procedure. /* obj-aw-fact-no-exe */

procedure obj-aw-fact-ok-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT yes, INPUT {&fact}, INPUT {&write-off}, INPUT no, INPUT {&TDEDT_Spi_Vnesh}, input no) .
  end.

end procedure. /* obj-aw-fact-ok-exe */

procedure obj-aw-fact-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&fact}, INPUT {&write-off}, INPUT no, INPUT {&TDEDT_Spi_Vnesh}, input no) .
  end.

end procedure. /* obj-aw-fact-all-exe */

procedure obj-aw-req-no-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT no, INPUT {&inquiry}, INPUT {&write-off}, INPUT no, INPUT {&TDEDT_Spi_Vnesh}, input no) .
  end.

end procedure. /* obj-aw-req-no-exe */

procedure obj-aw-req-ok-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT yes, INPUT {&inquiry}, INPUT {&write-off}, INPUT no, INPUT {&TDEDT_Spi_Vnesh}, input no) .
  end.

end procedure. /* obj-aw-req-ok-exe */

procedure obj-aw-req-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&inquiry}, INPUT {&write-off}, INPUT no, INPUT {&TDEDT_Spi_Vnesh}, input no) .
  end.

end procedure. /* obj-aw-req-all-exe */

procedure obj-aw-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&type}, INPUT ?, INPUT '?', INPUT {&write-off}, INPUT no, INPUT {&TDEDT_Spi_Vnesh}, input no) .
  end.

end procedure. /* obj-aw-all-exe */

procedure obj-inv-new-no-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT no, INPUT {&wayb}, INPUT {&inventory}, INPUT no, INPUT {&TDEDT_Inv}, input no) .
  end.

end procedure. /* obj-inv-new-no-exe */

procedure obj-inv-new-ok-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT yes, INPUT {&wayb}, INPUT {&inventory}, INPUT no, INPUT {&TDEDT_Inv}, input no) .
  end.

end procedure. /* obj-inv-new-ok-exe */

procedure obj-inv-new-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&wayb}, INPUT {&inventory}, INPUT no, INPUT {&TDEDT_Inv}, input no) .
  end.

end procedure. /* obj-inv-new-all-exe */

procedure obj-pst-new-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&wayb}, INPUT {&inventory}, INPUT no, INPUT {&TDEDT_Peresort}, input no) .
  end.

end procedure. /* obj-pst-new-all-exe */

procedure obj-inv-perm-no-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT no, INPUT {&permitted}, INPUT {&inventory}, INPUT no, INPUT {&TDEDT_Inv}, input no) .
  end.

end procedure. /* obj-inv-perm-no-exe */

procedure obj-inv-perm-ok-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT yes, INPUT {&permitted}, INPUT {&inventory}, INPUT no, INPUT {&TDEDT_Inv}, input no) .
  end.

end procedure. /* obj-inv-perm-ok-exe */

procedure obj-inv-perm-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&permitted}, INPUT {&inventory}, INPUT no, INPUT {&TDEDT_Inv}, input no) .
  end.

end procedure. /* obj-inv-perm-all-exe */

procedure obj-inv-fact-no-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT no, INPUT {&fact}, INPUT {&inventory}, INPUT no, INPUT {&TDEDT_Inv}, input no) .
  end.

end procedure. /* obj-inv-fact-no-exe */

procedure obj-inv-fact-ok-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT yes, INPUT {&fact}, INPUT {&inventory}, INPUT no, INPUT {&TDEDT_Inv}, input no) .
  end.

end procedure. /* obj-inv-fact-ok-exe */

procedure obj-inv-fact-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&fact}, INPUT {&inventory}, INPUT no, INPUT {&TDEDT_Inv}, input no) .
  end.

end procedure. /* obj-inv-fact-all-exe */

procedure obj-pst-fact-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&fact}, INPUT {&inventory}, INPUT no, INPUT {&TDEDT_Peresort}, input no) .
  end.

end procedure. /* obj-pst-fact-all-exe */

procedure obj-inv-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&type}, INPUT ?, INPUT '?', INPUT {&inventory}, INPUT no, INPUT {&TDEDT_Inv}, input no) .
  end.

end procedure. /* obj-inv-all-exe */

procedure obj-pst-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&type}, INPUT ?, INPUT '?', INPUT {&inventory}, INPUT no, INPUT {&TDEDT_Peresort}, input no) .
  end.

end procedure. /* obj-pst-all-exe */

procedure obj-ext-in-new-all-hi-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&wayb}, INPUT {&income}, INPUT no, INPUT {&TDEDT_Pri_Vnesh}, input yes) .
  end.

end procedure. /* obj-ext-in-new-all-hi-exe */

procedure obj-ext-in-fact-no-hi-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT no, INPUT {&fact}, INPUT {&income}, INPUT no, INPUT {&TDEDT_Pri_Vnesh}, input yes) .
  end.

end procedure. /* obj-ext-in-fact-no-hi-exe */

procedure obj-ext-in-fact-ok-hi-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT yes, INPUT {&fact}, INPUT {&income}, INPUT no, INPUT {&TDEDT_Pri_Vnesh}, input yes) .
  end.

end procedure. /* obj-ext-in-fact-ok-hi-exe */

procedure obj-ext-in-fact-all-hi-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&fact}, INPUT {&income}, INPUT no, INPUT {&TDEDT_Pri_Vnesh}, input yes) .
  end.

end procedure. /* obj-ext-in-fact-all-hi-exe */

procedure obj-ext-in-all-hi-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&type}, INPUT ?, INPUT '?', INPUT {&income}, INPUT no, INPUT {&TDEDT_Pri_Vnesh}, input yes) .
  end.

end procedure. /* obj-ext-in-all-hi-exe */

procedure obj-ext-out-new-no-hi-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT no, INPUT {&wayb}, INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh}, input yes) .
  end.

end procedure. /* obj-ext-out-new-no-hi-exe */

procedure obj-ext-out-new-ok-hi-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT yes, INPUT {&wayb}, INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh}, input yes) .
  end.

end procedure. /* obj-ext-out-new-ok-hi-exe */

procedure obj-ext-out-new-all-hi-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&wayb}, INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh}, input yes) .
  end.

end procedure. /* obj-ext-out-new-all-hi-exe */

procedure obj-ext-out-perm-no-hi-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT no, INPUT {&permitted}, INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh}, input yes) .
  end.

end procedure. /* obj-ext-out-perm-no-hi-exe */

procedure obj-ext-out-perm-ok-hi-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT yes, INPUT {&permitted}, INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh}, input yes) .
  end.

end procedure. /* obj-ext-out-perm-ok-hi-exe */

procedure obj-ext-out-perm-all-hi-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&permitted}, INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh}, input yes) .
  end.

end procedure. /* obj-ext-out-perm-all-hi-exe */

procedure obj-ext-out-fact-no-hi-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT no, INPUT {&fact}, INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh}, input yes) .
  end.

end procedure. /* obj-ext-out-fact-no-hi-exe */

procedure obj-ext-out-fact-ok-hi-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT yes, INPUT {&fact}, INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh}, input yes) .
  end.

end procedure. /* obj-ext-out-fact-ok-hi-exe */

procedure obj-ext-out-fact-all-hi-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&fact}, INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh}, input yes) .
  end.

end procedure. /* obj-ext-out-fact-all-hi-exe */

procedure obj-ext-out-all-hi-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&type}, INPUT ?, INPUT '?', INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh}, input yes) .
  end.

end procedure. /* obj-ext-out-all-hi-exe */

procedure obj-ext-sup-new-no-ho-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT no, INPUT {&wayb}, INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh_VP}, input yes) .
  end.

end procedure. /* obj-ext-sup-new-no-ho-exe */

procedure obj-ext-sup-new-ok-ho-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT yes, INPUT {&wayb}, INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh_VP}, input yes) .
  end.

end procedure. /* obj-ext-sup-new-ok-ho-exe */

procedure obj-ext-sup-new-all-ho-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&wayb}, INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh_VP}, input yes) .
  end.

end procedure. /* obj-ext-sup-new-all-ho-exe */

procedure obj-ext-sup-perm-no-ho-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT no, INPUT {&permitted}, INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh_VP}, input yes) .
  end.

end procedure. /* obj-ext-sup-perm-no-ho-exe */

procedure obj-ext-sup-perm-ok-ho-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT yes, INPUT {&permitted}, INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh_VP}, input yes) .

  end.

end procedure. /* obj-ext-sup-perm-ok-ho-exe */

procedure obj-ext-sup-perm-all-ho-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&permitted}, INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh_VP}, input yes) .
  end.

end procedure. /* obj-ext-sup-perm-all-ho-exe */

procedure obj-ext-sup-fact-no-ho-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT no, INPUT {&fact}, INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh_VP}, input yes) .
  end.

end procedure. /* obj-ext-sup-fact-no-ho-exe */

procedure obj-ext-sup-fact-ok-ho-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT yes, INPUT {&fact}, INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh_VP}, input yes) .
  end.

end procedure. /* obj-ext-sup-fact-ok-ho-exe */

procedure obj-ext-sup-fact-all-ho-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&fact}, INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh_VP}, input yes) .
  end.

end procedure. /* obj-ext-sup-fact-all-ho-exe */

procedure obj-ext-sup-all-ho-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&type}, INPUT ?, INPUT '?', INPUT {&expense}, INPUT no, INPUT {&TDEDT_Ras_Vnesh_VP}, input yes) .
  end.

end procedure. /* obj-ext-sup-all-ho-exe */

procedure obj-ext-ret-new-all-ho-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&wayb}, INPUT {&return}, INPUT no, INPUT {&TDEDT_Vozvrat_Vnesh}, input yes) .
  end.

end procedure. /* obj-ext-ret-new-all-ho-exe */

procedure obj-ext-ret-fact-all-ho-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&fact}, INPUT {&return}, INPUT no, INPUT {&TDEDT_Vozvrat_Vnesh}, input yes) .
  end.

end procedure. /* obj-ext-ret-fact-all-ho-exe */

procedure obj-ext-ret-all-ho-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&type}, INPUT ?, INPUT '?', INPUT {&return}, INPUT no, INPUT {&TDEDT_Vozvrat_Vnesh}, input yes) .
  end.

end procedure. /* obj-ext-ret-all-ho-exe */

procedure obj-cor-prt-new-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&wayb}, INPUT {&inventory}, INPUT no, INPUT {&TDEDT_Corr_Acc_Price}, input no) .
  end.

end procedure. /* obj-cor-prt-new-all-exe */

procedure obj-cor-prt-fact-ok-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT yes, INPUT {&fact}, INPUT {&inventory}, INPUT no, INPUT {&TDEDT_Corr_Acc_Price}, input no) .
  end.

end procedure. /* obj-cor-prt-fact-ok-exe */

procedure obj-cor-prt-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&type}, INPUT ?, INPUT '?', INPUT {&inventory}, INPUT no, INPUT {&TDEDT_Corr_Acc_Price}, input no) .
  end.

end procedure. /* obj-cor-prt-all-exe */

procedure obj-chg-pcode-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&type}, INPUT ?, INPUT '?', INPUT {&inventory}, INPUT no, INPUT {&TDEDT_Chg_Purch_Code}, input no) .
  end.

end procedure. /* obj-chg-pcode-all-exe */

procedure obj-ext-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&in_}, INPUT ?, INPUT '?', INPUT '?', INPUT no, INPUT ?, input no) .
  end.

end procedure. /* obj-ext-all-exe */

procedure obj-int-in-new-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&wayb}, INPUT {&income}, INPUT yes, INPUT {&TDEDT_Pri_Perem}, input no) .
  end.

end procedure. /* obj-int-in-new-exe */

procedure obj-int-in-fact-no-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT no, INPUT {&fact}, INPUT {&income}, INPUT yes, INPUT {&TDEDT_Pri_Perem}, input no) .
  end.

end procedure. /* obj-int-in-fact-no-exe */

procedure obj-int-in-fact-ok-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT yes, INPUT {&fact}, INPUT {&income}, INPUT yes, INPUT {&TDEDT_Pri_Perem}, input no) .
  end.

end procedure. /* obj-int-in-fact-ok-exe */

procedure obj-int-in-fact-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&fact}, INPUT {&income}, INPUT yes, INPUT {&TDEDT_Pri_Perem}, input no) .
  end.

end procedure. /* obj-int-in-fact-all-exe */

procedure obj-int-in-req-no-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT no, INPUT {&inquiry}, INPUT {&income}, INPUT yes, INPUT {&TDEDT_Pri_Perem}, input no) .
  end.

end procedure. /* obj-int-in-req-no-exe */

procedure obj-int-in-req-ok-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT yes, INPUT {&inquiry}, INPUT {&income}, INPUT yes, INPUT {&TDEDT_Pri_Perem}, input no) .
  end.

end procedure. /* obj-int-in-req-ok-exe */

procedure obj-int-in-req-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&inquiry}, INPUT {&income}, INPUT yes, INPUT {&TDEDT_Pri_Perem}, input no) .
  end.

end procedure. /* obj-int-in-req-all-exe */

procedure obj-int-in-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&type}, INPUT ?, INPUT '?', INPUT {&income}, INPUT yes, INPUT {&TDEDT_Pri_Perem}, input no) .
  end.

end procedure. /* obj-int-in-all-exe */

procedure obj-int-in-invert-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'invert':u, INPUT yes, INPUT {&inquiry}, INPUT {&income}, INPUT yes, INPUT {&TDEDT_Pri_Perem}, input no) .
  end.

end procedure. /* obj-int-in-invert-exe */

procedure obj-int-out-new-no-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT no, INPUT {&wayb}, INPUT {&expense}, INPUT yes, INPUT {&TDEDT_Ras_Perem}, input no) .
  end.

end procedure. /* obj-int-out-new-no-exe */

procedure obj-int-out-new-ok-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT yes, INPUT {&wayb}, INPUT {&expense}, INPUT yes, INPUT {&TDEDT_Ras_Perem}, input no) .
  end.

end procedure. /* obj-int-out-new-ok-exe */

procedure obj-int-out-new-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&wayb}, INPUT {&expense}, INPUT yes, INPUT {&TDEDT_Ras_Perem}, input no) .
  end.

end procedure. /* obj-int-out-new-all-exe */

procedure obj-int-out-perm-no-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT no, INPUT {&permitted}, INPUT {&expense}, INPUT yes, INPUT {&TDEDT_Ras_Perem}, input no) .
  end.

end procedure. /* obj-int-out-perm-no-exe */

procedure obj-int-out-perm-ok-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT yes, INPUT {&permitted}, INPUT {&expense}, INPUT yes, INPUT {&TDEDT_Ras_Perem}, input no) .
  end.

end procedure. /* obj-int-out-perm-ok-exe */

procedure obj-int-out-perm-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&permitted}, INPUT {&expense}, INPUT yes, INPUT {&TDEDT_Ras_Perem}, input no) .
  end.

end procedure. /* obj-int-out-perm-all-exe */

procedure obj-int-out-fact-no-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT no, INPUT {&fact}, INPUT {&expense}, INPUT yes, INPUT {&TDEDT_Ras_Perem}, input no) .
  end.

end procedure. /* obj-int-out-fact-no-exe */

procedure obj-int-out-fact-ok-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT yes, INPUT {&fact}, INPUT {&expense}, INPUT yes, INPUT {&TDEDT_Ras_Perem}, input no) .
  end.

end procedure. /* obj-int-out-fact-ok-exe */

procedure obj-int-out-fact-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&fact}, INPUT {&expense}, INPUT yes, INPUT {&TDEDT_Ras_Perem}, input no) .
  end.

end procedure. /* obj-int-out-fact-all-exe */

procedure obj-int-out-req-no-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT no, INPUT {&inquiry}, INPUT {&expense}, INPUT yes, INPUT {&TDEDT_Ras_Perem}, input no) .
  end.

end procedure. /* obj-int-out-req-no-exe */

procedure obj-int-out-req-ok-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT yes, INPUT {&inquiry}, INPUT {&expense}, INPUT yes, INPUT {&TDEDT_Ras_Perem}, input no) .
  end.

end procedure. /* obj-int-out-req-ok-exe */

procedure obj-int-out-req-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&inquiry}, INPUT {&expense}, INPUT yes, INPUT {&TDEDT_Ras_Perem}, input no) .
  end.

end procedure. /* obj-int-out-req-all-exe */

procedure obj-int-out-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&type}, INPUT ?, INPUT '?', INPUT {&expense}, INPUT yes, INPUT {&TDEDT_Ras_Perem}, input no) .
  end.

end procedure. /* obj-int-out-all-exe */

procedure obj-int-ret-new-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&wayb},      INPUT {&return}, INPUT yes, INPUT {&TDEDT_Vozvrat_Perem}, input no) .
  end.

end procedure. /* obj-int-ret-new-exe */

procedure obj-int-ret-perm-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&permitted}, INPUT {&return}, INPUT yes, INPUT {&TDEDT_Vozvrat_Perem}, input no) .
  end.

end procedure. /* obj-int-ret-perm-exe */

procedure obj-int-ret-fact-no-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT no, INPUT {&fact}, INPUT {&return}, INPUT yes, INPUT {&TDEDT_Vozvrat_Perem}, input no) .
  end.

end procedure. /* obj-int-ret-fact-no-exe */

procedure obj-int-ret-fact-ok-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&flag}, INPUT yes, INPUT {&fact}, INPUT {&return}, INPUT yes, INPUT {&TDEDT_Vozvrat_Perem}, input no) .
  end.

end procedure. /* obj-int-ret-fact-ok-exe */

procedure obj-int-ret-fact-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&fact}, INPUT {&return}, INPUT yes, INPUT {&TDEDT_Vozvrat_Perem}, input no) .
  end.

end procedure. /* obj-int-ret-fact-all-exe */

procedure obj-int-ret-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&type}, INPUT ?, INPUT '?', INPUT {&return}, INPUT yes, INPUT {&TDEDT_Vozvrat_Perem}, input no) .
  end.

end procedure. /* obj-int-ret-all-exe */

procedure obj-int-in-prvo-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&type}, INPUT ?, INPUT '?', INPUT {&income}, INPUT yes, INPUT {&TDEDT_Pri_Prvo}, input no) .
  end.

end procedure. /* obj-int-in-prvo-all-exe */

procedure obj-int-ret-mn-pr-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&manufactured}, INPUT {&write-off}, INPUT yes, INPUT {&TDEDT_Spi_Prvo}, input no) .
  end.

end procedure. /* obj-int-ret-mn-pr-all-exe */

procedure obj-int-ret-f-pr-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&fact}, INPUT {&write-off}, INPUT yes, INPUT {&TDEDT_Spi_Prvo}, input no) .
  end.

end procedure. /* obj-int-ret-f-pr-all-exe */

procedure obj-int-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&in_}, INPUT ?, INPUT '?', INPUT '?', INPUT yes, INPUT {&TDEDT_Ras_Perem}, input no) .
  end.

end procedure. /* obj-int-all-exe */

procedure out-int-obj-new-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&wayb}, INPUT {&expense}, INPUT yes, INPUT {&TDEDT_Ras_Object}, input no) .
  end.

end procedure. /* out-int-obj-new-exe */

procedure out-int-obj-fact-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&status}, INPUT ?, INPUT {&fact}, INPUT {&expense}, INPUT yes, INPUT {&TDEDT_Ras_Object}, input no) .
  end.

end procedure. /* out-int-obj-fact-exe */

procedure out-int-obj-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&type}, INPUT ?, INPUT '?', INPUT {&expense}, INPUT yes, INPUT {&TDEDT_Ras_Object}, input no) .
  end.

end procedure. /* out-int-obj-all-exe */


procedure in-int-obj-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&type}, INPUT ?, INPUT '?', INPUT {&income}, INPUT yes, INPUT {&TDEDT_Pri_Object}, input no) .
  end.

end procedure. /* in-int-obj-all-exe */

procedure obj-all-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&g___object}, INPUT ?, INPUT '?', INPUT '?', INPUT ?, INPUT {&TDEDT_Vozvrat_Perem}, input no) .
  end.

end procedure. /* obj-all-exe */

procedure m-host-exe :

  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT {&company}, INPUT ?, INPUT '?', INPUT '?', INPUT ?, INPUT {&TDEDT_Vozvrat_Perem}, input no) .
  end.

end procedure. /* m-host-exe */

procedure m-rsrvPlan-exe :

  do
  on error undo, return error return-value
  :
    run rep/g-rsrvPlan.p (input parparentproc, input no) no-error .
  end.

end procedure. /* m-rsrvPlan-exe */

procedure m-fbrpr-exe :

  do
  on error undo, return error return-value
  :
    run rep/g-fbrpr.p ( input parparentproc, input v-cntxt-obj-type, input v-cntxt-obj-code ) .
  end.

end procedure. /* m-fbrpr-exe */

procedure m-rep-shift4-exe :

  do
  on error undo, return error return-value
  :
    run rep/g-new-shift.p (input parparentproc, input '') .
  end.

end procedure. /* m-rep-shift4-exe */
procedure m-rep-shiftOld-exe :

  do
  on error undo, return error return-value
  :
    run rep/g-new-shift.p (input parparentproc, input '') .
  end.

end procedure. /* m-rep-shift4-exe */


procedure m-rep-shift4-ukr-exe :
  do on error undo, return error return-value :
    run rep/g-zmzvit.p ( input parparentproc ).
  end.
end procedure. /* m-rep-shift4-ukr-exe */


procedure m-sz-fin-exe :

  do
  on error undo, return error return-value
  :
    run rep/g-czbdp.p
      (input  parparentproc
      ,input  v-cntxt-host-code-obj
      ) .
  end.

end procedure. /* m-sz-fin-exe */

procedure m_300-exe :

  do
  on error undo, return error return-value
  :
    run bge/bge.p (input parparentproc, 'flat','REF') .
  end.

end procedure. /* m_300-exe */

procedure m_301-exe :

  do
  on error undo, return error return-value
  :
    run bge/bge.p (input parparentproc, 'flat','DOC') .
  end.

end procedure. /* m_301-exe */

procedure m_310-exe :

  do
  on error undo, return error return-value
  :
    run bge/bge.p (input parparentproc, 'flat','FINDOC') .

  end.

end procedure. /* m_310-exe */


procedure m_310_1-exe :

  do
  on error undo, return error return-value
  :
    run bge/bge.p (input parparentproc, 'flat','FIN-OB') .
  end.

end procedure. /* m_310_1-exe */

procedure m_310_2-exe :

  do
  on error undo, return error return-value
  :
    run bge/bge.p (input parparentproc, 'flat','CONTRACT') .
  end.

end procedure. /* m_310_2-exe */

procedure m_311-exe :

  do
  on error undo, return error return-value
  :
    run bge/bge.p (input parparentproc, 'flat','STD') .
  end.

end procedure. /* m_311-exe */

procedure m_312-exe :

  do
  on error undo, return error return-value
  :
    run bge/bge.p (input parparentproc, 'flat','STT') .
  end.

end procedure. /* m_312-exe */

procedure m_313-exe :

  do
  on error undo, return error return-value
  :
    run bge/bgerddoc.w ( input parparentproc, 'flat', 'DOC' ) .
  end.

end procedure. /* m_313-exe */

procedure m_314-exe :

  do
  on error undo, return error return-value
  :
    run bge/bge.p ( input parparentproc, 'flat', 'PRC' ) .
  end.

end procedure. /* m_313-exe */

procedure m_315-exe :

  do
  on error undo, return error return-value
  :
    run bge/bge.p (input parparentproc, 'tree','SHIFT') .

  end.

end procedure. /* m_315-exe */

procedure m_316-exe :

  do
  on error undo, return error return-value
  :
    run bge/bge.p (input parparentproc, 'flat','SCHET-FACTUR') .
  end.

end procedure. /* m_316-exe */

procedure m__bge_ref-exe :

  do
  on error undo, return error return-value
  :
    run bge/bge.p (input parparentproc, 'tree','REF') .
  end.

end procedure. /* m__bge_ref-exe */

procedure m_282-exe :

  do
  on error undo, return error return-value
  :
    run bge/bge.p (input parparentproc, 'tree','DOC') .
  end.

end procedure. /* m_282-exe */

procedure m_28c-exe :

  do
  on error undo, return error return-value
  :
    run bge/bge.p (input parparentproc, 'tree','STK') .
  end.

end procedure. /* m_28c-exe */

procedure m_28d-exe :

  do
  on error undo, return error return-value
  :
    run bge/bge.p (input parparentproc, 'tree','DAY') .
  end.

end procedure. /* m_28d-exe */

procedure m_28e-exe :

  do
  on error undo, return error return-value
  :
    run bge/bge.p (input parparentproc, 'tree','WAY') .
  end.

end procedure. /* m_28e-exe */

procedure m_28f-exe :

  do
  on error undo, return error return-value
  :
    run bge/bge.p (input parparentproc, 'tree','CARD') .
  end.

end procedure. /* m_28f-exe */

procedure m_28a-exe :

  do
  on error undo, return error return-value
  :
    run bge/bge.p (input parparentproc, 'tree','ALL-DOC-REF') .
  end.

end procedure. /* m_28a-exe */

procedure m_28z-exe :

  do
  on error undo, return error return-value
  :
    run bge/bge.p (input parparentproc, 'tree','ALL-DAY-WAY') .
  end.

end procedure. /* m_28z-exe */

procedure m_28g-exe :

  do
  on error undo, return error return-value
  :
    run bge/bgerddoc.w ( input parparentproc, 'tree', 'DOC' ) .
  end.

end procedure. /* m_28g-exe */

procedure m_41-exe :
  do
  on error undo, return error return-value
  :
    run bge/oxmlext.w
      (input  parparentproc
      ,input  "b-add" /*bttns*/
      ,input  {&all}
      ,input  v-cntxt-db-num
      ,input  v-cntxt-db-num
      ,input  ''
      ,input  ? /*p-esys-type*/
      ) .
  end.

end procedure. /* m_41-exe */

procedure m_45-exe :
  do
  on error undo, return error return-value
  :
    run bge/oxmlext.w
      (input  parparentproc
      ,input  "b-add" /*bttns*/
      ,input  "special"
      ,input  v-cntxt-db-num
      ,input  v-cntxt-db-num
      ,input  ''
      ,input  integer({&openxml-type-special}) /*p-esys-type - хотя для этой моды покажет все специальные*/
      ) .
  end.

end procedure. /* m_42-exe */


procedure m_43-exe :

  do
  on error undo, return error return-value
  :
    /* Процедура импорта */
    message
      "Процедура импорта находится в разработке"
      view-as alert-box error .
  end.

end procedure. /* m_43-exe */

procedure m__rfr-exe :

  define variable v-cur-date-error-code as integer      no-undo.
  do
  on error undo, return error return-value
  :
    /* обновление экрана */
    run mainmenu-disp-mutable in parparentproc (
        output v-cur-date-error-code
    ) no-error.
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры mainmenu-disp-mutable" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

  end.

end procedure. /* m__rfr-exe */


procedure m__st-exe :

  do
  on error undo, return error return-value
  :
    run trigger-select-context in parparentproc no-error.

    if error-status :error
    then do:
      if error-status :get-message(1) <> '':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при смене объекта процедура trigger-select-context" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.

  end.

end procedure. /* m__st-exe */

procedure obj-sht-ch-date-exe :

    define variable v-error-code    as integer      no-undo.
  do
  on error undo, return error return-value
  :
    run adm/cur-date.w
      (input  parparentproc
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  'change-date':u
      ,output v-error-code
      ) no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> '':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры" 'adm/cur-date.w':U skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.

end procedure. /* obj-sht-ch-date-exe */

procedure m-gds-list-exe :

  define variable v-host-code as integer no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/hostcode.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-host-code
    }
    run str/gdslistr.p (parparentproc, v-host-code, v-cntxt-obj-type, v-cntxt-obj-code) .
  end.

end procedure. /* m-gds-list-exe */

procedure m-scn-list-exe :

  define variable v-host-code as integer no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/hostcode.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-host-code
    }
    run str/scnlistr.p (parparentproc, v-host-code, v-cntxt-obj-type, v-cntxt-obj-code) .
  end.

end procedure. /* m-scn-list-exe */


procedure m-cli-list-exe :

  define variable v-host-code as integer no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/hostcode.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-host-code
    }
    run str/clilistr.p (parparentproc, v-host-code, v-cntxt-obj-type, v-cntxt-obj-code) .
  end.

end procedure. /* m-cli-list-exe */

procedure m-doc-list-exe :

  define variable v-host-code as integer no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/hostcode.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-host-code
    }
    run str/doclistr.p (parparentproc, v-host-code, v-cntxt-obj-type, v-cntxt-obj-code) .
  end.

end procedure. /* m-dc-list-exe */

procedure m-dc-list-exe :

  define variable v-host-code as integer no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/hostcode.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-host-code
    }
    run str/dclistr.p (parparentproc, v-host-code, v-cntxt-obj-type, v-cntxt-obj-code) .
  end.

end procedure. /* m-dc-list-exe */

procedure m-chk-list-all-exe :
run proc-chk-docs in this-procedure (input 'b-del', input {&g___object}).
end procedure. /* m-chk-list-all */

procedure m-chk-list-per-exe :
DEFINE VARIABLE p-list as character no-undo .

run str/tab-peresm.w (
                    input parparentproc
                    ,input 'b-restore'
                    ,input if v-cntxt-db-num <> 0 then {&g___object} else {&all}
                    ,input ?
                    ,input v-cntxt-obj-type
                    ,input v-cntxt-obj-code
                    ,input '':U
                    ,input '':U
                    ,input ?
                    ,input ?
                    ,output p-list) no-error.
end procedure. /* m-chk-list-all */



procedure m-chk-list-exe :

  define variable v-host-code as integer no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/hostcode.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-host-code
    }
    run str/chklistr.p (parparentproc, v-cntxt-obj-type, v-cntxt-obj-code, v-host-code) .
  end.

end procedure. /* m-chk-list-exe */

procedure m-bb-list-exe :

  do
  on error undo, return error return-value
  :
    run str/bblistr.p ( parparentproc, v-cntxt-obj-type, v-cntxt-obj-code) .
  end.

end procedure. /* m-bb-list-exe */

procedure m-scnblist-exe :

  do
  on error undo, return error return-value
  :
    run str/scnblstr.p ( parparentproc, v-cntxt-obj-type, v-cntxt-obj-code) .
  end.

end procedure. /* m-scnblist-exe */




procedure m_bc-ab-exe :

  define variable varb-c        like ub.bar-code.b-code  no-undo.

  do
  on error undo, return error return-value
  :
    run str/bc-ab.p (input parparentproc, input v-cntxt-obj-type, input v-cntxt-obj-code, ?, output varb-c) .
  end.

end procedure. /* m_bc-ab-exe */

procedure inv-lui-local:

  do
  on error undo, return error return-value
  :
    run str/inv-lui.w
      (input  parparentproc
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ).
  end.
end procedure.


procedure m_clobbnds_rep-xml-exe :

  do
  on error undo, return error
  :
    define variable v-rid-list as character no-undo .
    run ref/clobbnds.w ( input parparentproc
                        ,input ? /*p-parent-handle*/
                        ,input '' /*bttns*/
                        ,input {&all} /*p-list-mode*/
                        ,input "" /*p-mode*/
                        ,input {&lob-res-report-xml}
                        ,input '' /*p-unique-key-rec*/
                        ,input v-cntxt-db-num /*p-db-num*/
                        ,input-output v-rid-list) no-error.
  end.

end procedure. /* m_clobbnds_rep-xml-exe */

procedure m_clobbnds_list-exe :
define variable v-rid-list as character no-undo .
run ref/clobbnds.w ( input parparentproc
                    ,input this-procedure:handle
                    ,input 'b-sel,b-add,managed' /*bttns*/
                    ,input {&all} /*p-list-mode*/
                    ,input "" /*p-mode*/
                    ,input {&lob-res-list}
                    ,input ''  /*p-unique-key-rec*/
                    ,input -1 /*p-db-num*/
                    ,input-output v-rid-list) no-error.
end.

procedure m__inp-jewel-set-val :

  define input  parameter p-action as character no-undo .
  define input-output parameter p-value as logical   no-undo .

  do
  on error undo, return error return-value
  :
    case p-action :
      when 'set':u
      then do:
        run set-inp-jewel in parparentproc
          (input  p-value
          ) .
      end.
      when 'get':u
      then do:
        run get-inp-jewel in parparentproc
          (output p-value
          ) .
      end.
    end.
  end.

end procedure. /* m__inp-jewel-set-val */

procedure m__gds-engl-set-val :

  define input  parameter p-action as character no-undo .
  define input-output parameter p-value as logical   no-undo .

  do
  on error undo, return error return-value
  :
    case p-action :
      when 'set':u
      then do:
        run set-gds-engl in parparentproc
          (input  p-value
          ) .
      end.
      when 'get':u
      then do:
        run get-gds-engl in parparentproc
          (output p-value
          ) .
      end.
    end.
  end.

end procedure. /* m__gds-engl-set-val */

procedure m__quest-print-set-val :

  define input  parameter p-action as character no-undo .
  define input-output parameter p-value as logical   no-undo .

  define variable v-checked as logical   no-undo .

  do
  on error undo, return error return-value
  :
    case p-action :
      when 'set':u
      then do:
        run set-quest-print in parparentproc
          (input  p-value
          ) .
      end.
      when 'get':u
      then do:
        run get-quest-print in parparentproc
          (output p-value
          ) .
      end.
    end.
  end.

end procedure. /* m__quest-print-set-val */

procedure m_cshprtob-exe :
define variable v-host-code like ub.sysconf.host-code no-undo .

  do
  on error undo, return error
  :
    { gbl/hostcode.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-host-code
    }
    run str/cshprtob.p (parparentproc, v-host-code, v-cntxt-obj-type, v-cntxt-obj-code).
  end.

end procedure. /* m_cshprtob-exe */

procedure m_insaleob-exe :
define variable v-host-code like ub.sysconf.host-code no-undo .

  do
  on error undo, return error
  :
    { gbl/hostcode.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-host-code
    }
    run str/insaleob.p (parparentproc, v-host-code, v-cntxt-obj-type, v-cntxt-obj-code).
  end.

end procedure. /* m_insaleob-exe */


procedure m_bc-price-set-val :

  define input  parameter p-action as character no-undo .
  define input-output parameter p-value as logical   no-undo .

  define variable v-checked as logical   no-undo .

  do
  on error undo, return error return-value
  :
    case p-action :
      when 'set':u
      then do:
        run set-bc-price in parparentproc
          (input  p-value
          ) .
      end.
      when 'get':u
      then do:
        run get-bc-price in parparentproc
          (output p-value
          ) .
      end.
    end.
  end.

end procedure. /* m_bc-price-set-val */

procedure m_disgdsrule-exe :

  define variable v-host-code as integer no-undo .

  do
  on error undo, return error return-value
  :
    run ref/dgrbylst.w ( input parparentproc
                        ,input {&table_dis-gds-rule}
                        ,input v-cntxt-obj-type
                        ,input v-cntxt-obj-code) .
  end.

end procedure. /* m_disgdsrule-exe */

procedure m_disdcrule-exe :

  do
  on error undo, return error return-value
  :
    run ref/ddcrbyls.w ( input parparentproc
                        ,input {&table_dis-dc-rule}
                        ,input v-cntxt-host-code-obj
                        ,input v-cntxt-obj-type
                        ,input v-cntxt-obj-code) .
  end.

end procedure. /* m_disdcrule-exe */

procedure m_discprule-exe :

  do
  on error undo, return error return-value
  :
    run ref/cshbylst.w ( input parparentproc
                        ,input {&table_dis-cp-rule}
                        ,input v-cntxt-host-code-obj
                        ,input v-cntxt-obj-type
                        ,input v-cntxt-obj-code) .
  end.

end procedure. /* m_disgdsrule-exe */


procedure m_gdsoattr-exe :

  define variable v-host-code as integer no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/hostcode.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-host-code
    }
    run ref/atrbylst.w (parparentproc, {&table_gds-obj-attr}, v-host-code, v-cntxt-obj-type, v-cntxt-obj-code) .
  end.

end procedure. /* m_gdsoattr-exe */

procedure m_gdshattr-exe :

  define variable v-host-code as integer no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/hostcode.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-host-code
    }
    run ref/atrbylst.w (parparentproc, {&table_gds-host-attr}, v-host-code, v-cntxt-obj-type, v-cntxt-obj-code) .
  end.

end procedure. /* m_gdshattr-exe */

procedure m_clntattr-exe :

  define variable v-host-code as integer no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/hostcode.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-host-code
    }
    run ref/atrbylst.w (parparentproc, {&table_clients-attr}, v-host-code, v-cntxt-obj-type, v-cntxt-obj-code) .
  end.

end procedure. /* m_clntattr-exe */

procedure m_goods-attr-exe :

  define variable v-host-code as integer no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/hostcode.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-host-code
    }
    run ref/atrbylst.w (parparentproc, {&table_goods-attr}, v-host-code, v-cntxt-obj-type, v-cntxt-obj-code) .
  end.

end procedure. /* m_goods-attr-exe */


procedure m-fbr-gds-grp-attr-exe :

  do
  on error undo, return error return-value
  :
    run ref/fbrgdsat.w ( input parparentproc, input v-cntxt-obj-type, input v-cntxt-obj-code ) .
  end.

end procedure. /* m-fbr-gds-grp-attr-exe */

procedure m_clients-parus-exe :
define variable v-rid-list as character no-undo .

  do
  on error undo, return error
  :
    run ref/par-clis.w ( input parparentproc
                        ,input (if v-cntxt-db-num > 0 then '':U else "b-add")
                        ,input '':U
                        ,input-output v-rid-list) no-error.

  end.

end procedure. /* m_clients-parus-exe */

procedure m_clients-parus-2-exe :
define variable v-rid-list as character no-undo .

  do
  on error undo, return error
  :
    run ref/par2clis.w ( input parparentproc
                        ,input (if v-cntxt-db-num > 0 then '':U else "b-add")
                        ,input '':U
                        ,input-output v-rid-list) no-error.

  end.

end procedure. /* m_clients-parus-exe */


procedure m_clients-esys-exe :
define variable v-rid-list as character no-undo .
  do
  on error undo, return error
  :
    run ref/esysclis.w ( input parparentproc
                        ,input (if v-cntxt-db-num > 0 then '':U else "b-add")
                        ,input {&all}
                        ,input 0
                        ,input-output v-rid-list) no-error.


  end.
end procedure. /* m_clients-esys-exe */

procedure m_goods-esys-exe :
define variable v-rid-list as character no-undo .
  do
  on error undo, return error
  :
    run ref/codelay.p
      (input  parparentproc
      ,input  {&lookup}
      ,input  ""
      ,input  "FuelCodeInfo"
      ,input  ?
      ) .

  end.
end procedure. /* m_goods-esys-exe */

procedure m_gds-grp-esys-exe :
define variable v-rid-list as character no-undo .
  do
  on error undo, return error
  :
    run ref/esys-grp.w ( input parparentproc
                        ,input (if v-cntxt-db-num > 0 then '':U else "b-add")
                        ,input {&all}
                        ,input 0
                        ,input-output v-rid-list) no-error.


  end.
end procedure. /* m_gds-grp-esys-exe */

procedure m_gds-ef-exe :
define variable v-rid-list as character no-undo .

  do
  on error undo, return error
  :
    run ref/gds-ef.w ( input parparentproc
                      ,input (if v-cntxt-db-num > 0 then '':U else "b-add")
                      ,input '':U
                      ,output v-rid-list) no-error.

  end.

end procedure. /* m_gds-ef-exe */


procedure m-obj-unrv-exe :

  do
  on error undo, return error return-value
  :
    run str/chck-rv.p (input parparentproc, input {&period}) no-error .
  end.

end procedure. /* m-obj-unrv-exe */

procedure m-obj-req-exe :

  do
  on error undo, return error return-value
  :
    run str/chck-rv.p (input parparentproc, input {&inquiry}) no-error .
  end.

end procedure. /* m-obj-req-exe */

procedure m-obj-uninv-exe :

  do
  on error undo, return error return-value
  :
    run str/chck-rv.p (input parparentproc, input 'инв-снять') no-error .
  end.

end procedure. /* m-obj-uninv-exe */

procedure m-obj-rvinv-exe :

  do
  on error undo, return error return-value
  :
    run str/chck-rv.p (input parparentproc, input 'инв-рез') no-error  .
  end.

end procedure. /* m-obj-rvinv-exe */

/* 26/II-2019 не используется. Справочник операторов сотовой связи (ОСС) перенесён в БПА
procedure m-oss-ref :
    define variable v-rid-list as character no-undo.
    define variable v-mode as character no-undo.
  do
  on error undo, return error return-value
  :
    v-mode = "". /* возможное значение - "v-sel", т.е. активизация возможности выбора произвольных строк в браузере ОСС. */

    run ref/oss-ref.w
        (
        input parparentproc,
        input v-mode,
        input v-cntxt-db-num,
        output v-rid-list
        ) no-error.
  end.

end procedure. /* m-oss-exe */
*/

procedure m-bpa-ref :
define variable v-rid-list as character no-undo .
define variable v-mode     as character no-undo .
define variable v-value    as character no-undo .
define variable v-type     as character no-undo .
  do
  on error undo, return error
  :
    run gbl/conf-rd.p ("is-erpRN", "", "", 0, "", "", "", no, output v-value, output v-type) no-error.
    
    if v-value = "no" then do:
    if v-cntxt-db-num > 0 then v-mode = {&lookup}. else v-mode = {&update} .
    end.
    else v-mode = {&lookup} .
    run ref/bpa.p ( input parparentproc, input v-mode, output v-rid-list) no-error.
  end.

end procedure. /* m_gds-ef-exe */

procedure m-cashbook-ref :
define variable v-rid-list as character no-undo .
define variable v-mode     as character no-undo .
define variable v-value    as character no-undo .
define variable v-type     as character no-undo .
  do
  on error undo, return error
  :
    run gbl/conf-rd.p ("is-erpRN", "", "", 0, "", "", "", no, output v-value, output v-type) no-error.
    
    if v-value = "no"
    then v-mode = {&update} .
    else v-mode = {&lookup} .
    run ref/cashbook.p ( input parparentproc, input v-mode ) no-error.
  end.

end procedure.

procedure m_autopush-exe :

  define variable varrid-list   as   character           no-undo.
  define variable v-host-code as integer no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/hostcode.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-host-code
    }

    run adm/autopush.w
      (input  parparentproc
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  v-host-code
      ) .
  end.

end procedure. /* m_autopush-exe */



procedure m_nwsdistrcmd-exe :

  define variable varrid-list   as   character           no-undo.

  do
  on error undo, return error return-value
  :
    run str/dbracmds.w (parparentproc, '':U, {&all}, ?, '':U, '':U, input-output varrid-list) .
  end.

end procedure. /* m_nwsdistrcmd-exe */

procedure m-impexp-exe :

  define variable glog as logical no-undo.

  do
  on error undo, return error return-value
  :
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_impexp_proc':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    glog
  }
    if glog then do :
      run gbl/menubrws.w (parparentproc, {&menuload_service_impexp},  'Импорт/Экспорт') .
    end.
  end.

end procedure. /* m-impexp-exe */

procedure m-impexp-fin-exe :

  define variable glog as logical no-undo.

  do
  on error undo, return error return-value
  :
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_impexp_proc':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    glog
  }
    if glog then do :
      run gbl/menubrws.w (parparentproc, {&menuload_service_fin_impexp},  'Импорт/Экспорт') .
    end.
  end.

end procedure. /* m-impexp-fin-exe */


procedure m-customs-exe :

  do
  on error undo, return error return-value
  :
    run gbl/menubrws.w (parparentproc, {&menuload_service_customs}, 'Заказные программы') .
  end.

end procedure. /* m-customs-exe */

procedure m-utility-exe :

  do
  on error undo, return error return-value
  :
    run gbl/menubrws.w (parparentproc, {&menuload_service_utility}, 'Служебные программы') .
  end.

end procedure. /* m-utility-exe */

procedure m-check-exe :

  do
  on error undo, return error return-value
  :
    run gbl/menubrws.w (parparentproc, {&menuload_service_check},   'Программы проверки') .
  end.

end procedure. /* m-check-exe */

procedure m__fin_cli-grp-exe :

  define variable varrid-list   as   character           no-undo.

  do
  on error undo, return error return-value
  :
    run ref/cli-grps.w (input parparentproc, '', input-output varrid-list) .
  end.

end procedure. /* m__fin_cli-grp-exe */

procedure m__fin_code-corr-exe :

  do
  on error undo, return error return-value
  :
    run ref/f-code-c.p
      (input  parparentproc
      ,input  1
      ,input  v-cntxt-host-code-obj
      ) .
  end.

end procedure. /* m__fin_code-corr-exe */

procedure m__fin_code-gol-exe :

  do
  on error undo, return error return-value
  :
    run ref/f-code-c.p
      (input  parparentproc
      ,input  2
      ,input  v-cntxt-host-code-obj
      ) .
  end.

end procedure. /* m__fin_code-gol-exe */

procedure m__fin_code-analit-exe :

  do
  on error undo, return error return-value
  :
    run ref/f-code-c.p
      (input  parparentproc
      ,input  3
      ,input  v-cntxt-host-code-obj
      ) .
  end.

end procedure. /* m__fin_code-analit-exe */

procedure m__fi-taxes-exe :

  define variable varrid-list   as   character           no-undo.

  do
  on error undo, return error return-value
  :
    run ref/tax-tree.w
      (input  parparentproc
      ,input  ''
      ,input  'ALL':U
      ,input  v-cntxt-host-code-obj
      ,input  '':U
      ,input  0
      ,input  ?
      ,input-output varrid-list
      ) .
  end.

end procedure. /* m__fi-taxes-exe */

procedure m__fin_countries-exe :

  define variable v-rid-list  as   character   no-undo.

  do
  on error undo, return error return-value
  :
    run ref/countris.w (input parparentproc
                 , input ''
                 , input-output  v-rid-list ) .
  end.

end procedure. /* m__fin_countries-exe */

procedure m__fin_currency-exe :

  define variable varrid        as   recid               no-undo.

  do
  on error undo, return error return-value
  :
    run ref/currency.w (parparentproc, 'b-add-bank':U, input-output  varrid ) .
  end.

end procedure. /* m__fin_currency-exe */

procedure m__fin-pay-type-exe :

  define variable varrid           as character no-undo .
  define variable v-current-db-num as integer   no-undo .


  do
  on error undo, return error return-value
  :
    { gbl/curdbnum.i
      v-current-db-num
    }

    run ref/paytype.w
      (input  parparentproc
      ,input  (if v-current-db-num = 0
               then 'b-add,b-upd,b-del,b-doc,b-print'
               else 'b-doc'
              )
      ,output varrid
      ) .
  end.

end procedure. /* m__fin-pay-type-exe */

procedure m__fin_plan-attr-exe :

  do
  on error undo, return error return-value
  :
    run ref/fiatrobj.w
      (input  parparentproc
      ,input  v-cntxt-host-code-obj
      ) .
  end.

end procedure. /* m__fin_plan-attr-exe */

procedure m__fin_ove_rs_n-exe :

  do
  on error undo, return error return-value
  :
    run str/fi-liab1.p (input parparentproc ,21,v-cntxt-host-code-obj) .
  end.

end procedure. /* m__fin_ove_rs_n-exe */

procedure m__fin_ove_rs_g-exe :

  do
  on error undo, return error return-value
  :
    run str/fi-liab1.p (input parparentproc ,210,v-cntxt-host-code-obj) .
  end.

end procedure. /* m__fin_ove_rs_g-exe */

procedure m__fin_ove_rs_f-exe :

  do
  on error undo, return error return-value
  :
    run str/fi-liab1.p (input parparentproc ,22,v-cntxt-host-code-obj) .
  end.

end procedure. /* m__fin_ove_rs_f-exe */

procedure m__fin_ove_rs_a-exe :

  do
  on error undo, return error return-value
  :
    run str/fi-liab1.p (input parparentproc ,2,v-cntxt-host-code-obj) .
  end.

end procedure. /* m__fin_ove_rs_a-exe */

procedure m__fin_ove_rs_bef-exe :

  do
  on error undo, return error return-value
  :
    run str/fi-liab1.p (input parparentproc ,3,v-cntxt-host-code-obj) .
  end.

end procedure. /* m__fin_ove_rs_bef-exe */

procedure m__fin_ove_in_n-exe :
  do
  on error undo, return error return-value
  :
     run str/fi-liab1.p (input parparentproc , input 11 , v-cntxt-host-code-obj) .
  end.
end procedure.

procedure m__fin_ove_in_g-exe :
  do
  on error undo, return error return-value
  :
     run str/fi-liab1.p (input parparentproc , input 13 , v-cntxt-host-code-obj) .
  end.
end procedure.

procedure m__fin_ove_in_f-exe :
  do
  on error undo, return error return-value
  :
     run str/fi-liab1.p (input parparentproc , input 12 , v-cntxt-host-code-obj) .
  end.
end procedure.


procedure m__fin_ove_in_a-exe :
  do
  on error undo, return error return-value
  :
     run str/fi-liab1.p (input parparentproc , input 1 , v-cntxt-host-code-obj) .
  end.
end procedure.

procedure m__fin_ob-inf-exe :

  do
  on error undo, return error return-value
  :
    run str/fo-inf.w (input parparentproc ,v-cntxt-host-code-obj) .
  end.

end procedure. /* m__fin_ob-inf-exe */

procedure m__fd_pr_cash-new-exe :

  do
  on error undo, return error return-value
  :
    run m__fd_exe({&income-cash}, {&fin-new}) .
  end.

end procedure. /* m__fd_pr_cash-new-exe */

procedure m__fd_pr_cash-perm-exe :

  do
  on error undo, return error return-value
  :
    run m__fd_exe({&income-cash}, {&fin-permitted}) .
  end.

end procedure. /* m__fd_pr_cash-perm-exe */

procedure m__fd_pr_cash-fact-exe :

  do
  on error undo, return error return-value
  :
    run m__fd_exe({&income-cash}, {&fin-fact}) .
  end.

end procedure. /* m__fd_pr_cash-fact-exe */

procedure m__fd_pr_cash-all-exe :

  do
  on error undo, return error return-value
  :
    run m__fd_exe({&income-cash}, '':U) .
  end.

end procedure. /* m__fd_pr_cash-all-exe */

procedure m__fd_pr_casho-new-exe :

  do
  on error undo, return error return-value
  :
    run m__fd_exe( input ({&income-cash} + {&delim-par} + {&g___object}), {&fin-new}) .
  end.

end procedure. /* m__fd_pr_casho-new-exe */

procedure m__fd_pr_casho-perm-exe :

  do
  on error undo, return error return-value
  :
    run m__fd_exe( input ({&income-cash} + {&delim-par} + {&g___object}), {&fin-permitted}) .
  end.

end procedure. /* m__fd_pr_casho-perm-exe */

procedure m__fd_pr_casho-fact-exe :

  do
  on error undo, return error return-value
  :
    run m__fd_exe( input ({&income-cash} + {&delim-par} + {&g___object}) , {&fin-fact}) .
  end.

end procedure. /* m__fd_pr_casho-fact-exe */

procedure m__fd_pr_casho-all-exe :

  do
  on error undo, return error return-value
  :
    run m__fd_exe( input ({&income-cash} + {&delim-par} + {&g___object}), '':U) .
  end.

end procedure. /* m__fd_pr_casho-all-exe */


procedure m__fd_pr_cashless-new-exe :

  do
  on error undo, return error return-value
  :
    run m__fd_exe({&income-cashless}, {&fin-new}) .
  end.

end procedure. /* m__fd_pr_cashless-new-exe */

procedure m__fd_pr_cashless-perm-exe :

  do
  on error undo, return error return-value
  :
    run m__fd_exe({&income-cashless}, {&fin-permitted}) .
  end.

end procedure. /* m__fd_pr_cashless-perm-exe */

procedure m__fd_pr_cashless-bank-exe :

  do
  on error undo, return error return-value
  :
    run m__fd_exe({&income-cashless}, {&fin-bank}) .
  end.

end procedure. /* m__fd_pr_cashless-bank-exe */

procedure m__fd_pr_cashless-fact-exe :

  do
  on error undo, return error return-value
  :
    run m__fd_exe({&income-cashless}, {&fin-fact}) .
  end.

end procedure. /* m__fd_pr_cashless-fact-exe */

procedure m__fd_pr_cashless-all-exe :

  do
  on error undo, return error return-value
  :
    run m__fd_exe({&income-cashless}, '':U) .
  end.

end procedure. /* m__fd_pr_cashless-all-exe */

procedure m__fd_pr_payoff-new-exe :

  do
  on error undo, return error return-value
  :
    run m__fd_exe({&income-payoff}, {&fin-new}) .
  end.

end procedure. /* m__fd_pr_payoff-new-exe */

procedure m__fd_pr_payoff-perm-exe :

  do
  on error undo, return error return-value
  :
    run m__fd_exe({&income-payoff}, {&fin-permitted}) .
  end.

end procedure. /* m__fd_pr_payoff-perm-exe */

procedure m__fd_pr_payoff-fact-exe :

  do
  on error undo, return error return-value
  :
    run m__fd_exe({&income-payoff}, {&fin-fact}) .
  end.

end procedure. /* m__fd_pr_payoff-fact-exe */

procedure m__fd_pr_payoff-all-exe :

  do
  on error undo, return error return-value
  :
    run m__fd_exe({&income-payoff}, '':U) .
  end.

end procedure. /* m__fd_pr_payoff-all-exe */

procedure m__fd_ra_cash-new-exe :

  do
  on error undo, return error return-value
  :
    run m__fd_exe({&expense-cash}, {&fin-new}) .
  end.

end procedure. /* m__fd_ra_cash-new-exe */

procedure m__fd_ra_cash-perm-exe :

  do
  on error undo, return error return-value
  :
    run m__fd_exe({&expense-cash}, {&fin-permitted}) .
  end.

end procedure. /* m__fd_ra_cash-perm-exe */

procedure m__fd_ra_cash-fact-exe :

  do
  on error undo, return error return-value
  :
    run m__fd_exe({&expense-cash}, {&fin-fact}) .
  end.

end procedure. /* m__fd_ra_cash-fact-exe */

procedure m__fd_ra_cash-all-exe :

  do
  on error undo, return error return-value
  :
    run m__fd_exe({&expense-cash}, '':U) .
  end.

end procedure. /* m__fd_ra_cash-all-exe */


procedure m__fd_ra_casho-new-exe :

  do
  on error undo, return error return-value
  :
    run m__fd_exe( input ({&expense-cash} + {&delim-par} + {&g___object}), {&fin-new}) .
  end.

end procedure. /* m__fd_ra_casho-new-exe */

procedure m__fd_ra_casho-perm-exe :

  do
  on error undo, return error return-value
  :
    run m__fd_exe( input ({&expense-cash} + {&delim-par} + {&g___object}), {&fin-permitted}) .
  end.

end procedure. /* m__fd_ra_casho-perm-exe */

procedure m__fd_ra_casho-fact-exe :

  do
  on error undo, return error return-value
  :
    run m__fd_exe( input ({&expense-cash} + {&delim-par} + {&g___object}), {&fin-fact}) .
  end.

end procedure. /* m__fd_ra_casho-fact-exe */

procedure m__fd_ra_casho-all-exe :

  do
  on error undo, return error return-value
  :
    run m__fd_exe( input ({&expense-cash} + {&delim-par} + {&g___object}), '':U) .
  end.

end procedure. /* m__fd_ra_casho-all-exe */


procedure m__fd_casho-all-exe :

  do
  on error undo, return error return-value
  :
    run m__fd_exe( input ("cash" + {&delim-par} + {&g___object}), '':U) .
  end.

end procedure. /* m__fd_casho-all-exe */


procedure m__fd_casha-all-exe :

  do
  on error undo, return error return-value
  :
    run m__fd_exe( input "cash", input '':U) .
  end.

end procedure. /* m__fd_pr_casha-all-exe */



procedure m__fd_ra_cashless-new-exe :

  do
  on error undo, return error return-value
  :
    run m__fd_exe({&expense-cashless}, {&fin-new}) .
  end.

end procedure. /* m__fd_ra_cashless-new-exe */

procedure m__fd_ra_cashless-perm-exe :

  do
  on error undo, return error return-value
  :
    run m__fd_exe({&expense-cashless}, {&fin-permitted}) .
  end.

end procedure. /* m__fd_ra_cashless-perm-exe */

procedure m__fd_ra_cashless-bank-exe :

  do
  on error undo, return error return-value
  :
    run m__fd_exe({&expense-cashless}, {&fin-bank}) .
  end.

end procedure. /* m__fd_ra_cashless-bank-exe */

procedure m__fd_ra_cashless-fact-exe :

  do
  on error undo, return error return-value
  :
    run m__fd_exe({&expense-cashless}, {&fin-fact}) .
  end.

end procedure. /* m__fd_ra_cashless-fact-exe */

procedure m__fd_ra_cashless-all-exe :

  do
  on error undo, return error return-value
  :
    run m__fd_exe({&expense-cashless}, '':U) .
  end.

end procedure. /* m__fd_ra_cashless-all-exe */

procedure m__fd_ra_payoff-new-exe :

  do
  on error undo, return error return-value
  :
    run m__fd_exe({&expense-payoff}, {&fin-new}) .
  end.

end procedure. /* m__fd_ra_payoff-new-exe */

procedure m__fd_ra_payoff-perm-exe :

  do
  on error undo, return error return-value
  :
    run m__fd_exe({&expense-payoff}, {&fin-permitted}) .
  end.

end procedure. /* m__fd_ra_payoff-perm-exe */

procedure m__fd_ra_payoff-fact-exe :

  do
  on error undo, return error return-value
  :
    run m__fd_exe({&expense-payoff}, {&fin-fact}) .
  end.

end procedure. /* m__fd_ra_payoff-fact-exe */

procedure m__fd_ra_payoff-all-exe :

  do
  on error undo, return error return-value
  :
    run m__fd_exe({&expense-payoff}, '':U) .
  end.

end procedure. /* m__fd_ra_payoff-all-exe */

procedure m__fd_all-all-exe :

  do
  on error undo, return error return-value
  :
    run m__fd_exe('':U, '':U) .
  end.

end procedure. /* m__fd_all-all-exe */

procedure m__fs_all-all-exe :

  do
  on error undo, return error return-value
  :
    run m__fs_exe({&company}, '':U, '':U, '':U) .
  end.

end procedure. /* m__fs_all-all-exe */


procedure m_212-exe :

  do
  on error undo, return error return-value
  :
    run m_21-exe ( INPUT '{&abbr_rub}' ) .
  end.

end procedure. /* m_212-exe */

procedure m_211-exe :

  do
  on error undo, return error return-value
  :
    run m_21-exe ( INPUT 'вал' ) .
  end.

end procedure. /* m_211-exe */

procedure m_221-exe :

  do
  on error undo, return error return-value
  :
    run m_22-exe ( INPUT '{&abbr_rub}' ) .
  end.

end procedure. /* m_221-exe */

procedure m_222-exe :

  do
  on error undo, return error return-value
  :
    run m_22-exe ( INPUT 'вал' ) .
  end.

end procedure. /* m_222-exe */

procedure m_223-F2r-exe :

  do
  on error undo, return error return-value
  :
    run m_223-F2-exe ( INPUT '{&abbr_rub}' ) .
  end.

end procedure. /* m_223-F2r-exe */

procedure m_223-F2b-exe :

  do
  on error undo, return error return-value
  :
    run m_223-F2-exe ( INPUT 'вал' ) .
  end.

end procedure. /* m_223-F2b-exe */

procedure m_223-F3r-exe :

  do
  on error undo, return error return-value
  :
    run m_223-F3-exe ( INPUT '{&abbr_rub}' ) .
  end.

end procedure. /* m_223-F3r-exe */

procedure m_223-F3b-exe :

  do
  on error undo, return error return-value
  :
    run m_223-F3-exe ( INPUT 'вал' ) .
  end.

end procedure. /* m_223-F3b-exe */


procedure m_223-F4r-exe :

  do
  on error undo, return error return-value
  :
    run m_223-F4-exe ( INPUT '{&abbr_rub}' ) .
  end.

end procedure. /* m_223-F4r-exe */

procedure m_223-F4b-exe :

  do
  on error undo, return error return-value
  :
    run m_223-F4-exe ( INPUT 'вал' ) .
  end.

end procedure. /* m_223-F4b-exe */

procedure m_223-F5r-exe :

  do
  on error undo, return error return-value
  :
    run m_223-F5-exe ( INPUT '{&abbr_rub}' ) .
  end.

end procedure. /* m_223-F5r-exe */

procedure m_223-F5b-exe :

  do
  on error undo, return error return-value
  :
    run m_223-F5-exe ( INPUT 'вал' ) .
  end.

end procedure. /* m_223-F5b-exe */

procedure m_223-F6r-exe :

  do
  on error undo, return error return-value
  :
    run m_223-F6-exe ( INPUT '{&abbr_rub}' ) .
  end.

end procedure. /* m_223-F6r-exe */

procedure m_223-F6b-exe :

  do
  on error undo, return error return-value
  :
    run m_223-F6-exe ( INPUT 'вал' ) .
  end.

end procedure. /* m_223-F6b-exe */

procedure m_223-FSr-exe :

  do
  on error undo, return error return-value
  :
    run m_223-FS-exe ( INPUT '{&abbr_rub}' ) .
  end.

end procedure. /* m_223-FSr-exe */

procedure m_223-FSb-exe :

  do
  on error undo, return error return-value
  :
    run m_223-FS-exe ( INPUT 'вал' ) .
  end.

end procedure. /* m_223-FSb-exe */

procedure m_223-FVr-exe :

  do
  on error undo, return error return-value
  :
    run m_223-FV-exe ( INPUT '{&abbr_rub}' ) .
  end.

end procedure. /* m_223-FVr-exe */

procedure m_223-FVb-exe :

  do
  on error undo, return error return-value
  :
    run m_223-FV-exe ( INPUT 'вал' ) .
  end.

end procedure. /* m_223-FVb-exe */

procedure m_2231r-exe :

  do
  on error undo, return error return-value
  :
    run m_2231-exe ( INPUT '{&abbr_rub}' ) .
  end.

end procedure. /* m_2231r-exe */

procedure m_2231b-exe :

  do
  on error undo, return error return-value
  :
    run m_2231-exe ( INPUT 'вал' ) .
  end.

end procedure. /* m_2231b-exe */

procedure m_2232r-exe :

  do
  on error undo, return error return-value
  :
    run m_2232-exe ( INPUT '{&abbr_rub}' ) .
  end.

end procedure. /* m_2232r-exe */

procedure m_2232b-exe :

  do
  on error undo, return error return-value
  :
    run m_2232-exe ( INPUT 'вал' ) .
  end.

end procedure. /* m_2232b-exe */

procedure m_2233r-exe :

  do
  on error undo, return error return-value
  :
    run m_2233-exe ( INPUT '{&abbr_rub}' ) .
  end.

end procedure. /* m_2233r-exe */

procedure m_2233b-exe :
  do on error undo, return error return-value :
    run m_2233-exe ( input 'вал' ).
  end.
end procedure. /* m_2233b-exe */



procedure m__fin_trn1-exe :

  do
  on error undo, return error return-value
  :
    run str/fialltrn.p (input parparentproc ,1,v-cntxt-host-code-obj) .
  end.

end procedure. /* m__fin_trn1-exe */

procedure m__fin_trn2-exe :

  do
  on error undo, return error return-value
  :
    run str/fialltrn.p (input parparentproc ,2,v-cntxt-host-code-obj) .
  end.

end procedure. /* m__fin_trn2-exe */

procedure m__fin_trn3-exe :

  do
  on error undo, return error return-value
  :
    run str/fialltrn.p (input parparentproc ,4,v-cntxt-host-code-obj) .
  end.

end procedure. /* m__fin_trn3-exe */

procedure m__fin_trn4-exe :

  do
  on error undo, return error return-value
  :
    run str/fialltrn.p (input parparentproc ,3,v-cntxt-host-code-obj) .
  end.

end procedure. /* m__fin_trn4-exe */

procedure m__fin_trn6-exe :

  do
  on error undo, return error return-value
  :
    run str/fialltrn.p (input parparentproc ,11,v-cntxt-host-code-obj) .
  end.

end procedure. /* m__fin_trn6-exe */

procedure m__fin_trn7-exe :

  do
  on error undo, return error return-value
  :
    run str/fialltrn.p (input parparentproc ,12,v-cntxt-host-code-obj) .
  end.

end procedure. /* m__fin_trn7-exe */

procedure m__fin_trn8-exe :

  do
  on error undo, return error return-value
  :
    run str/fialltrn.p (input parparentproc ,13,v-cntxt-host-code-obj) .
  end.

end procedure. /* m__fin_trn8-exe */

procedure m__fin_trn9-exe :

  do
  on error undo, return error return-value
  :
    run str/fialltrn.p (input parparentproc ,0,v-cntxt-host-code-obj) .
  end.

end procedure. /* m__fin_trn9-exe */

procedure m-fin-trn-del-exe :

  do
  on error undo, return error return-value
  :
    run dm-c-doc-exe (INPUT {&c-company}, INPUT ?, INPUT '?', INPUT '?', INPUT ?, INPUT {&TDEDT_Vozvrat_Perem}, input ? ) .
  end.

end procedure. /* m-fin-trn-del-exe */

procedure m-assort-amin-exe :

  do
  on error undo, return error return-value
  :
    run ref/gds-amin.w (parparentproc,v-cntxt-obj-type,v-cntxt-obj-code,?) .
  end.

end procedure. /* m-assort-amin-exe */


procedure m-assort-polit-izt-exe :

  do
  on error undo, return error return-value
  :
    run ref/u-ind.p ( input parparentproc, v-cntxt-obj-type , v-cntxt-obj-code ) .
  end.

end procedure. /* m-assort-polit-izt-exe */


procedure m-assort-krit-anal-exe :

  define variable varrid-list   as   character           no-undo.

  do
  on error undo, return error return-value
  :
    run ref/critanal.w (parparentproc, '','', output varrid-list) .
  end.

end procedure. /* m-assort-krit-anal-exe */

procedure m-copyamin :


  do
  on error undo, return error return-value
  :
    run ref/copyamin.p (input  parparentproc, input v-cntxt-obj-type, input v-cntxt-obj-code) .
  end.

end procedure. /* m-copyamin */


procedure m-assort-abc-anal-exe :

  do
  on error undo, return error return-value
  :
  define variable p-rez as character no-undo .
    run ref/abcanal.w (input parparentproc ,  "b-add,b-del" , output p-rez) .
  end.

end procedure. /* m-assort-abc-anal-exe */


procedure m-assort-abcxyzc :

  do
  on error undo, return error return-value
  :
    define variable p-rez as character no-undo .
    run ref/abcxyzv.w (input parparentproc ,  "b-add,b-del" , output p-rez ) .

  end.

end procedure.


procedure m-assort-xyz-anal-exe :

  do
  on error undo, return error return-value
  :
    define variable p-rez as character no-undo .
    run ref/xyzanal.w (parparentproc ,  "b-add,b-del" , output p-rez) .
  end.

end procedure. /* m-assort-xyz-anal-exe */

procedure dm-doc-exe :
define input parameter parlistmode     as character no-undo.
define input parameter parflag         as logical   no-undo.
define input parameter parstat         as character no-undo.
define input parameter partype         as character no-undo.
define input parameter parinternal     as logical   no-undo.
define input parameter parext-doc-type as character no-undo.
define input parameter paris-hold      as logical   no-undo.
define variable loc-ref-list           as character no-undo.
define variable v-ok                   as logical   no-undo.

assign v-ok = yes.
if parlistmode = {&company} then do:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_documents_company':U
    {&cntxt-firm}
    v-cntxt-host-code-obj
    '':U
    0
    0
    0
    0
    true
    v-ok
  }
end.
if v-ok then do:
  run str/all-docs.w (input  parparentproc,
                      input  v-cntxt-host-code-obj ,
                      input  v-cntxt-obj-type      ,
                      input  v-cntxt-obj-code      ,
                      input  parlistmode,
                      input  parstat,
                      input  partype,
                      input  parflag,
                      input  parinternal,
                      input  "b-mark",
                      input  parext-doc-type,
                      input  paris-hold,
                      input  ?,
                      output loc-ref-list).
end.
end procedure.

procedure dm-fl-exe :
define input parameter parlistmode     as character no-undo.
define input parameter parflag         as logical   no-undo.
define input parameter parstat         as character no-undo.

define variable loc-ref-list as character no-undo.
run str/all-docf.w (input parparentproc,
               input ""   ,          /*bttns*/
               input parlistmode ,
               input parflag ,
               input parstat ,
               output loc-ref-list).

end procedure.

PROCEDURE m_scn-flt-exe :

define variable vartempchar   as   character           no-undo.

get-key-value section 'mob_scan' key 'scan_com' value varTempChar.
if varTempChar = ? then do:
  message 'Отсутствует секция mob_scan в progress.ini'.
end.
else do:
  os-command value (varTempChar).
end.
end.

procedure proc-hour-proc :
define input parameter p-proc-name as character no-undo .
define input parameter p-proc-title  as character no-undo .
define variable varis-ok      as   logical             no-undo initial no.
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_cur-obj-proceeds_print':U
  {&cntxt-firm}
  v-cntxt-host-code-obj
  '':U
  0
  0
  0
  0
  true
  varis-ok
}
if not varis-ok then return error.
run rep/d-report.w ( input parparentproc ,input p-proc-name, input p-proc-title, 2, '', '*', '', '', 'shop,{&send-check}', no).
end procedure. /* proc-hour-proc */

PROCEDURE m-chkhr-exe :
run proc-hour-proc in this-procedure (input 'rep/e-chkhr.w', input 'Почасовая статистика розничных продаж по КОЛИЧЕСТВУ ПОКУПОК').
END PROCEDURE.

PROCEDURE m-grphr-exe :
run rep/g-grphr.p ( input parparentproc) no-error.
END PROCEDURE.

PROCEDURE m-sumhr-exe :
run proc-hour-proc in this-procedure (input 'rep/e-sumhr.w', input 'Почасовая статистика розничных продаж по СУММЕ ПРОДАЖ').
END PROCEDURE.

PROCEDURE m-svhr-exe :
run proc-hour-proc in this-procedure (input 'rep/e-svhr.w', input 'Почасовая статистика розничных продаж  ПО ВЕЛИЧИНЕ СУММ ПРОДАЖ').
END PROCEDURE.

PROCEDURE m-buyers-exe :
define variable v-host-code like ub.sysconf.host-code no-undo .
{ gbl/hostcode.i v-cntxt-obj-type v-cntxt-obj-code v-host-code }
 run rep/buyers.w (input parparentproc, input v-host-code).
END PROCEDURE.


PROCEDURE m-sj-exe :
  run rep/g-sj.p (input parparentproc, input "").
END PROCEDURE.

PROCEDURE m-sjjwl-exe :
  run rep/g-sj.p (input parparentproc, input {&twounit}).
END PROCEDURE.



PROCEDURE m-benefi-exe :
  run rep/g-benefi.p (input parparentproc, "rep/e-benefi.w").
END PROCEDURE.



procedure m-sale-rom-exe :
 do on error undo, return error return-value  :
   run rep/sale-rom.w (input parparentproc, input v-cntxt-obj-type, input v-cntxt-obj-code ) .
  end.
 end procedure.

PROCEDURE m-srvsal-exe :
/*  { cmp/r-page0.i } */
&scop g-all 1
&glob g-prod 3
&scop g-choice 4


run rep/d-report.w (
                            input parparentproc
                           ,input 'rep/e-srvsl1.w'
                           ,input ('Реализация услуг')
                           ,input 2
                           ,input "{&g-all},{&g-prod},{&g-choice}"
                           ,input "*"
                           ,input ""
                           ,input ""
                           ,input "shop"
                           ,input no).
END PROCEDURE.


PROCEDURE m_fin_cli-all-exe :
define variable v-rid-list as character no-undo .
run ref/cli-all.w (input parparentproc, "b-add,b-bank":U, {&cmp}, ?, ?, ?, ?, "without-obj":U, output v-rid-list) .
END PROCEDURE.

PROCEDURE m_finbanks-exe :
define variable v-rid-list as character no-undo .
define variable v-status_ like ub.fin-bank.status_ no-undo init {&current-status}.
run ref/finbanks.w (input parparentproc
             , input v-cntxt-host-code-obj
             , input "b-add,b-mark,b-copy":U
             , input {&company}
             , input v-cntxt-host-code-obj
             , input-output v-status_
             , input-output v-rid-list).
END PROCEDURE.

PROCEDURE m_finschets-exe :
define variable v-rid-list as character no-undo .
define variable v-status_ like ub.fin-bank.status_ no-undo init {&current-status}.
run ref/finschts.w (input parparentproc
             , input v-cntxt-host-code-obj
             , input "b-add,b-mark,b-copy":U
             , input {&company}
             , input "":U
             , input 0
             , input ?
             , input v-cntxt-host-code-obj
             , input 0
             , input-output v-status_
             , input-output v-rid-list).
END PROCEDURE.

procedure m__fd_exe :
define input parameter p-fin-doc-type like ub.fin-doc.fin-doc-type no-undo .
define input parameter p-status_ like ub.fin-doc.status_ no-undo .
define variable v-rid-list as character no-undo .
define variable v-mode as character no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
if num-entries(p-fin-doc-type, {&delim-par}) > 1
and entry(2, p-fin-doc-type, {&delim-par}) =  {&g___object}
then do:
  v-obj-type = v-cntxt-obj-type.
  v-obj-code = v-cntxt-obj-code.
  assign v-mode =  (if p-fin-doc-type = "":U
                     then {&g___object}
                     else (if p-status_ = "":U
                           then "type-object":U
                           else "type-stat-object":U))
  p-fin-doc-type = entry(1, p-fin-doc-type, {&delim-par})
  .
end.
else do:
  assign v-mode =  (if p-fin-doc-type = "":U
                     then {&company}
                     else (if p-status_ = "":U
                           then "type":U
                           else "type-stat":U))
  .
end.

run ref/findocs.w (input parparentproc, input v-cntxt-host-code-obj, input "":U
              ,input v-mode
              ,input {&all}  /*p-list*/
              ,input v-cntxt-host-code-obj /*p-host-code*/
              ,input v-obj-type   /*p-obj-type*/
              ,input v-obj-code   /*p-obj-code*/
              ,input p-status_
              ,input p-fin-doc-type
              ,input "":U   /*p-fin-ext-doc-type*/
              ,input ?      /*p-start-date  */
              ,input ?      /*p-end-date  */
              ,input "":U   /* p-trn-doc-code */
              ,input "":U   /*p-receiver-type */
              ,input 0      /* p-receiver-code */
              ,input "":U   /* p-receiver-r-schet */
              ,input "":U   /*p-PAYER-type */
              ,input 0      /* p-PAYER-code */
              ,input "":U   /* p-PAYER-r-schet */
              ,input ?      /*p-curr-code*/
              ,input 0      /* p-receiver-code-schet */
              ,input 0      /* p-payer-code-schet */
              ,input 0      /*p-contract-code*/
              ,input 0      /*p-cor-acc  */
              ,input 0      /*p-cor-acc1 */
              ,input 0      /*p-an-uchet-code */
              ,input 0      /*p-cel-nazn-code */
              ,input-output v-rid-list).
end procedure. /* m__fd-exe */


procedure m__fd_casho-encashment-exe :
define variable v-doc-rec as recid no-undo .
run ref/finencsh.p  (
                      input parparentproc
                     ,input v-cntxt-host-code-obj
                     ,input v-cntxt-obj-type
                     ,input v-cntxt-obj-code
                     ,input no /*p-silent*/
                     ,input yes /*p-start-ref*/
                     ) no-error.
end procedure. /* m__fd_casho-encashment-exe */

procedure m__cfd_exe :
define variable v-rid-list as character no-undo .
run ref/fincdocs.w (
               input parparentproc
              ,input v-cntxt-host-code-obj
              ,input ''
              ,input {&deletion}
              ,input v-cntxt-host-code-obj
              ,input '' /*p-obj-type*/
              ,input 0 /*p-obj-code*/
              ,input 0 /*p-fin-doc-code*/
              ,input-output v-rid-list).
end procedure. /* m__cfd-exe */

procedure m__cfdo_exe :
define variable v-rid-list as character no-undo .
run ref/fincdocs.w (
               input parparentproc
              ,input v-cntxt-host-code-obj
              ,input ''
              ,input {&g___object}
              ,input v-cntxt-host-code-obj
              ,input v-cntxt-obj-type /*p-obj-type*/
              ,input v-cntxt-obj-code /*p-obj-code*/

              ,input 0 /*p-fin-doc-code*/
              ,input-output v-rid-list).
end procedure. /* m__cfd-exe */

procedure m__fs_exe :
define input parameter p-mode as character no-undo .
define input parameter p-status_ like ub.fin-statement.status_ no-undo .
define input parameter p-fins-doc-type like ub.fin-statement.fins-doc-type no-undo .
define input parameter p-fins-ext-doc-type like ub.fin-statement.fins-doc-type no-undo .
define variable v-rid-list as character no-undo .

run ref/finsttms.w (
               input parparentproc
              ,input v-cntxt-host-code-obj /*p-current-host-code*/
              ,input "":U  /*bttns*/
              ,input p-mode
              ,input v-cntxt-host-code-obj /*p-host-code*/
              ,input p-status_
              ,input p-fins-doc-type      /*p-fin-ext-doc-type*/
              ,input p-fins-ext-doc-type  /*p-fins-ext-doc-type*/
              ,input ?      /*p-start-date  */
              ,input ?      /*p-end-date  */
              ,input 0      /*p-code-bank*/
              ,input 0      /* p-code-schet */
              ,input ?      /* p-curr-code */
              ,input-output v-rid-list).
end procedure. /* m__fs-exe */

procedure m_EGAIS-all-awo_exe :
define variable v-RegID as character no-undo .

run bge/egais-all-act-writeOff.w (input parparentproc, input no, output v-RegID ) . 
    
end procedure . /* m_EGAIS-all-awo_exe */

procedure m_EGAIS-all-awoS_exe :
define variable v-RegID as character no-undo .

run bge/egais-all-act-writeOff_shop.w (input parparentproc, input no, output v-RegID ) . 
    
end procedure . /* m_EGAIS-all-awoS_exe */

procedure chk-goods_add :

  define output parameter p-enable-item as logical   no-undo .

  do
  on error undo, return error return-value
  :

    IF not p-enable-item then do:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_cashdesk-goods_add-def':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    p-enable-item
  }
    end.
  end.

end procedure. /* chk-goods_add */

procedure chk-user-adm :

  define output parameter p-enable-item as logical   no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/user-adm.i
      v-cntxt-db-num
      v-cntxt-userid
      p-enable-item
    }
    IF not p-enable-item then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        "'actn_admin':U"
        {&cntxt-global}
        0
        '':U
        0
        0
        0
        0
        false
        p-enable-item
      }
    end.
  end.

end procedure. /* chk-user-adm */


procedure chk-is-wth :

  define output parameter p-enable-item as logical   no-undo .

  define variable v-is-wth as character no-undo .
  define variable par-type as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'is-wth':u"
      "'':u"
      "'':u"
      0
      "'':u"
      "'':u"
      "'':u"
      no
      v-is-wth
      par-type
      no-error
    }
    if error-status :error
    or par-type <> {&type-log}
    or v-is-wth <> 'yes':u
    then do:
      assign
        v-is-wth = 'no':u
      .
    end.

    if v-is-wth = 'yes':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

end procedure. /* chk-is-wth */

procedure chk-ser-wth :

  define output parameter p-enable-item as logical   no-undo .

  define variable v-ser-wth as character no-undo .
  define variable par-type as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'ser-wth':u"
      0
      "'':u"
      0
      "'':u"
      "'':u"
      "'':u"
      no
      v-ser-wth
      par-type
      no-error
    }
    if error-status :error
    or par-type <> {&type-log}
    or v-ser-wth <> 'yes':u
    then do:
      assign
        v-ser-wth = 'no':u
      .
    end.

    if v-ser-wth = 'yes':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

end procedure. /* chk-ser-wth */

procedure chk-is-jwlr :

  define output parameter p-enable-item as logical   no-undo .

  define variable v-is-jwlr as character no-undo .
  define variable par-type  as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'is-jwlr':u"
      "'':u"
      "'':u"
      0
      "'':u"
      "'':u"
      "'':u"
      no
      v-is-jwlr
      par-type
      no-error
    }
    if error-status :error
    or par-type  <> {&type-log}
    or v-is-jwlr <> 'yes':u
    then do:
      assign
        v-is-jwlr = 'no':u
      .
    end.

    if v-is-jwlr = 'yes':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

end procedure. /* chk-is-jwlr */

procedure chk-is-ptrl :

  define output parameter p-enable-item as logical   no-undo .

  define variable v-is-ptrl as character no-undo .
  define variable par-type  as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'is-ptrl':u"
      "'':u"
      "'':u"
      0
      "'':u"
      "'':u"
      "'':u"
      no
      v-is-ptrl
      par-type
      no-error
    }
    if error-status :error
    or par-type  <> {&type-log}
    or v-is-ptrl <> 'yes':u
    then do:
      assign
        v-is-ptrl = 'no':u
      .
    end.

    if v-is-ptrl = 'yes':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

end procedure. /* chk-is-ptrl */


procedure chk-is-cdinv :

  define output parameter p-enable-item as logical   no-undo .

  define variable v-is-cdinv as character no-undo .
  define variable par-type   as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'is-cdinv':u"
      "'':u"
      "'':u"
      0
      "'':u"
      "'':u"
      "'':u"
      no
      v-is-cdinv
      par-type
      no-error
    }
    if error-status :error
    or v-is-cdinv  <> 'yes':u
    then do:
      assign
        v-is-cdinv = 'no':u
      .
    end.

    if v-is-cdinv = 'yes':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

end procedure. /* chk-is-cdinv */

procedure chk-is-custm :

  define output parameter p-enable-item as logical   no-undo .

  define variable v-is-custm as character no-undo .
  define variable par-type   as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'is-custm':u"
      "'':u"
      "'':u"
      0
      "'':u"
      "'':u"
      "'':u"
      no
      v-is-custm
      par-type
      no-error
    }
    if v-is-custm = 'yes':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

end procedure. /* chk-is-custm */

procedure chk-alcohol :

  define output parameter p-enable-item as logical   no-undo .

  define variable v-alcohol as character no-undo .
  define variable par-type  as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'alcohol':u"
      "'':u"
      "'':u"
      0
      "'':u"
      "'':u"
      "'':u"
      no
      v-alcohol
      par-type
      no-error
    }
    if v-alcohol = 'yes':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

end procedure. /* chk-alcohol */

procedure chk-mercuri :

  define output parameter p-enable-item as logical   no-undo .

  define variable v-mercuri as character no-undo .
  define variable par-type  as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'mercuri':u"
      "'':u"
      "'':u"
      0
      "'':u"
      "'':u"
      "'':u"
      no
      v-mercuri
      par-type
      no-error
    }
    if v-mercuri = 'no':u or v-mercuri = ""
    then do:
      assign
        p-enable-item = false
      .
    end.
    else do:
      assign
        p-enable-item = true
      .
    end.
  end.

end procedure. /* chk-mercuri */

procedure chk-holding :

  define output parameter p-enable-item as logical   no-undo .

  define variable v-holding as character no-undo .
  define variable par-type  as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'holding':u"
      "'':u"
      "'':u"
      0
      "'':u"
      "'':u"
      "'':u"
      no
      v-holding
      par-type
      no-error
    }

    if v-holding = 'yes':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

end procedure. /* chk-holding */

procedure chk-holding-no :

  define output parameter p-enable-item as logical   no-undo .

  define variable v-holding as character no-undo .
  define variable par-type  as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'holding':u"
      "'':u"
      "'':u"
      0
      "'':u"
      "'':u"
      "'':u"
      no
      v-holding
      par-type
      no-error
    }
    if v-holding = 'no':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

end procedure. /* chk-holding-no */

procedure chk-shuttle-yes :

  define output parameter p-enable-item as logical   no-undo .

  define variable v-shuttle as character no-undo .
  define variable par-type  as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'shuttlsp':u"
      "'':u"
      "'':u"
      0
      "'':u"
      "'':u"
      "'':u"
      no
      v-shuttle
      par-type
      no-error
    }

    if v-shuttle = 'yes':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
end procedure. /* chk-shuttle-yes */


procedure chk-db-num-0 :

  define output parameter p-enable-item as logical   no-undo .
  define variable v-current-db-num as integer   no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/curdbnum.i
      v-current-db-num
    }
    if v-current-db-num = 0
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

end procedure. /* chk-db-num-0 */


procedure chk-firm-db-num :

  define output parameter p-enable-item as logical   no-undo .
  define variable v-current-db-num as integer   no-undo .
  define variable v-firm-db-num as integer   no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/curdbnum.i
      v-current-db-num
    }
    { gbl/frmdbnum.i
      v-cntxt-host-code-obj
      v-firm-db-num
    }
    if v-current-db-num = v-firm-db-num
    then do:

      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

end procedure. /* chk-firm-db-num */



procedure chk-is-dc :

  define output parameter p-enable-item as logical   no-undo .

  define variable v-is-dc  as character no-undo .
  define variable par-type as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'is-dc':u"
      "'':u"
      "'':u"
      0
      "'':u"
      "'':u"
      "'':u"
      no
      v-is-dc
      par-type
      no-error
    }
    if error-status :error
    or par-type <> {&type-log}
    or v-is-dc  <> 'yes':u
    then do:
      assign
        v-is-dc = 'no':u
      .
    end.

    if v-is-dc = 'yes':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

end procedure. /* chk-is-dc */


procedure chk-is-ef :

  define output parameter p-enable-item as logical   no-undo .

  define variable v-is-ef  as character no-undo .
  define variable par-type as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'is-ef':u"
      "'':u"
      "'':u"
      0
      "'':u"
      "'':u"
      "'':u"
      no
      v-is-ef
      par-type
      no-error
    }
    if error-status :error
    or par-type <> {&type-log}
    or v-is-ef  <> 'yes':u
    then do:
      assign
        v-is-ef = 'no':u
      .
    end.

    if v-is-ef = 'yes':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

end procedure. /* chk-is-ef */


procedure chk-is-flora :

  define output parameter p-enable-item as logical   no-undo .

  define variable v-is-flora as character no-undo .
  define variable par-type as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'is-flora':u"
      "'':u"
      "'':u"
      0
      "'':u"
      "'':u"
      "'':u"
      no
      v-is-flora
      par-type
      no-error
    }
    if error-status :error
    or par-type <> {&type-log}
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра is-flora" skip
        view-as alert-box error .
      return error.
    end.
    if v-is-flora = 'yes':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
      p-enable-item = false
      .
    end.

  end.

end procedure. /* chk-is-flora */

procedure chk-is-abc :

  define output parameter p-enable-item as logical   no-undo .

  define variable v-is-abc  as character no-undo .
  define variable par-type   as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'is-abc'"
      "'':u"
      "'':u"
      0
      "'':u"
      "'':u"
      "'':u"
      no
      v-is-abc
      par-type
      no-error
    }
    if lookup( v-is-abc, "yes,no" ) = 0
    or v-is-abc = ?
    or par-type <> {&type-log}
    or error-status :error
    then do:
      assign
        v-is-abc = "no"
      .
    end.

    if v-is-abc = 'no':u
    then do:
      assign
        p-enable-item = false
      .
    end.
    else do:
      assign
        p-enable-item = true
      .
    end.
  end.
end procedure.

procedure chk-is-edi :

  define output parameter p-enable-item as logical   no-undo .

  define variable v-is-edi as character no-undo .
  define variable par-type  as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'is-edi':u"
      "'':u"
      "'':u"
      0
      "'':u"
      "'':u"
      "'':u"
      no
      v-is-edi
      par-type
      no-error
    }
    if error-status :error
    or par-type  <> {&type-log}
    or v-is-edi <> 'yes':u
    then do:
      assign
        v-is-edi = 'no':u
      .
    end.

    if v-is-edi = 'yes':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

end procedure. /* chk-is-edi */

procedure chk-bgefmt-is-analythic :

  define output parameter p-enable-item as logical   no-undo .

  define variable v-bgefmt      as character    no-undo.
  define variable v-param-type      as character  no-undo .
  define variable v-value-character as character  no-undo .
  define variable v-value-date      as date       no-undo .
  define variable v-value-decimal   as decimal    no-undo .
  define variable v-value-integer   as integer    no-undo .
  define variable v-value-logical   as logical    no-undo .
  define variable v-tth             as handle     no-undo .

  do
  on error undo, return error return-value
  :
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  {&attr-bge-export}
                      , input  {&attr-bge-export_bgefmt}
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
        p-enable-item = false
      .
    end.
    else do:
      assign
        v-bgefmt = v-value-character
      .
      if v-bgefmt = 'analythic':u
      then do:
          assign
              p-enable-item = true
          .
      end.        /* if v-bgefmt = 'analythic':u */
      else do:
          assign
              p-enable-item = false
          .
      end.        /* NOT ( if v-bgefmt = 'analythic':u ) */
    end.
    delete object v-tth.
  end.
end procedure. /* chk-bgefmt-is-analythic */

procedure chk-bgefmt-is-not-analythic :

  define output parameter p-enable-item as logical   no-undo .

  do
  on error undo, return error return-value
  :
    run chk-bgefmt-is-analythic in this-procedure (
        output p-enable-item
    ) no-error.
    if error-status :error
    then do:
        assign
            p-enable-item = false
        .
    end.
    else do:
        assign
            p-enable-item = not p-enable-item
        .
    end.
  end.
end procedure. /* chk-bgefmt-is-not-analythic */

procedure chk-orders :

  define output parameter p-enable-item as logical   no-undo .

  define variable v-orders as character no-undo .
  define variable par-type as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'orders':u"
      "'':u"
      "'':u"
      0
      "'':u"
      "'':u"
      "'':u"
      no
      v-orders
      par-type
      no-error
    }
    if error-status :error
    or par-type <> {&type-log}
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра orders" skip
        view-as alert-box error .
      return error.
    end.

    if v-orders = 'yes':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

end procedure. /* chk-orders */

procedure chk-orders-fby :

  define output parameter p-enable-item as logical   no-undo .

  define variable v-orders as character no-undo .
  define variable par-type as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'orders':u"
      "'':u"
      "'':u"
      0
      "'':u"
      "'':u"
      "'':u"
      no
      v-orders
      par-type
      no-error
    }
    if error-status :error
    or par-type <> {&type-log}
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра orders" skip
        view-as alert-box error .
      return error.
    end.

    if v-orders = 'yes':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
      return .
    end.
    v-orders = ''.
    { gbl/conf-rd.i
      "'is-finby':u"
      "'':u"
      "'':u"
      0
      "'':u"
      "'':u"
      "'':u"
      no
      v-orders
      par-type
      no-error
    }
    if v-orders <> '':U
    and (error-status :error
    or par-type <> {&type-log})
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра is-finby" skip
        view-as alert-box error .
      return error.
    end.

    p-enable-item = true .

    if v-cntxt-db-num > 0 and v-orders <> 'yes' then do:
       assign
         p-enable-item = false
       .
    end.


  end.

end procedure. /* chk-orders */

procedure chk-is-thpos :

  define output parameter p-enable-item as logical   no-undo .

  define variable v-is-thpos  as character no-undo .
  define variable par-type as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'is-thpos':u"
      "'':u"
      "'':u"
      0
      "'':u"
      "'':u"
      "'':u"
      no
      v-is-thpos
      par-type
      no-error
    }
    if error-status :error
    or par-type <> {&type-log}
    or v-is-thpos  <> 'yes':u
    then do:
      assign
        v-is-thpos = 'no':u
      .
    end.

    if v-is-thpos = 'yes':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

end procedure. /* chk-is-thpos */

procedure chk-is-addcharges :

  define output parameter p-enable-item as logical   no-undo .

  define variable v-is-add as character no-undo .
  define variable par-type   as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'is-addch':u"
      "'':u"
      "'':u"
      0
      "'':u"
      "'':u"
      "'':u"
      no
      v-is-add
      par-type
      no-error
    }

    if v-is-add = 'yes'
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

end procedure. /* chk-is-addcharges */


procedure chk-is-not-addcharges :

  define output parameter p-enable-item as logical   no-undo .

  define variable v-is-add as character no-undo .
  define variable par-type   as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'is-addch':u"
      "'':u"
      "'':u"
      0
      "'':u"
      "'':u"
      "'':u"
      no
      v-is-add
      par-type
      no-error
    }
    if v-is-add = 'yes'
    then do:
      assign
        p-enable-item = false
      .
    end.
    else do:
      assign
        p-enable-item = true
      .
    end.
  end.

end procedure. /* chk-is-addcharges */


procedure chk-ord-op :

  define output parameter p-enable-item as logical   no-undo .

  define variable v-ord-op as logical   no-undo .
  define variable v-value-character  as character no-undo .
  define variable v-value-date       as date      no-undo .
  define variable v-value-decimal    as decimal   no-undo .
  define variable v-value-integer    as integer   no-undo .


  define variable par-type as character no-undo .

  do
  on error undo, return error return-value
  :
    run adm/shattri.p (
      input "get":U
      ,input ""
      ,input 0
      ,input {&attr-ord-global}
      ,input  {&attr-ord-global_ord-op}
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-ord-op
      ,output par-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
    if error-status :error
    or v-ord-op  <> yes then do:
      assign
        v-ord-op = no
      .
    end.

    if v-ord-op = yes
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

end procedure. /* chk-ord-op */

procedure chk-ord-ofof :

  define output parameter p-enable-item as logical   no-undo .

  define variable v-ord-ofof as logical   no-undo .
  define variable v-value-character  as character no-undo .
  define variable v-value-date       as date      no-undo .
  define variable v-value-decimal    as decimal   no-undo .
  define variable v-value-integer    as integer   no-undo .


  define variable par-type as character no-undo .
  define variable v-act as logical   no-undo .

  do
  on error undo, return error return-value
  :
  run chk-obj-active (output v-act) .
  if v-act then do:
     p-enable-item = true.
     return .
  end.

    run adm/shattri.p (
      input "get":U
      ,input ""
      ,input 0
      ,input {&attr-ord-global}
      ,input  {&attr-ord-global_ord-ofof}
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-ord-ofof
      ,output par-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
    if error-status :error
    or v-ord-ofof  <> yes then do:
      assign
        v-ord-ofof = no
      .
    end.

    if v-ord-ofof = yes
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

end procedure. /* chk-ord-ofof */


procedure chk-is-fbr :

  define output parameter p-enable-item as logical   no-undo .

  define variable v-is-fbr as character no-undo .
  define variable par-type   as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'is-fbr':u"
      "'':u"
      "'':u"
      0
      "'':u"
      "'':u"
      "'':u"
      no
      v-is-fbr
      par-type
      no-error
    }
    if error-status :error
    or par-type <> {&type-log}
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра is-fbr" skip
        view-as alert-box error .
      return error.
    end.

    if v-is-fbr = 'yes':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

end procedure. /* chk-slf-prod */

procedure chk-oxmlthon :

  define output parameter p-enable-item as logical   no-undo .

  define variable v-oxmlthon as character no-undo .
  define variable par-type   as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'oxmlthon':u"
      "'':u"
      "'':u"
      0
      "'':u"
      "'':u"
      "'':u"
      no
      v-oxmlthon
      par-type
      no-error
    }
    if error-status :error
    or par-type   <> {&type-log}
    or v-oxmlthon <> 'yes':u
    then do:
      assign
        v-oxmlthon = 'no':u
      .
    end.

    if v-oxmlthon = 'yes':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

end procedure. /* chk-oxmlthon */

procedure chk-r-b-base :

  define output parameter p-enable-item as logical   no-undo .

  define variable v-r-b    as character no-undo .
  define variable par-type as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/curr-r-b.i
      v-r-b
      no-error
    }
    if error-status :error
    or lookup( v-r-b, 'rubl,base':u ) = 0
    then do:
      assign
        v-r-b = ?
      .
    end.

    if v-r-b = 'base':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

end procedure. /* chk-oxmlthon */


procedure chk-obj-active :

  define output parameter p-enable-item as logical   no-undo .

  define variable v-obj-active as logical   no-undo .

  do
  on error undo, return error return-value
  :
    if  v-cntxt-obj-code <> ?
    and v-cntxt-obj-code <> 0
    then do:
      { gbl/objat.i
        v-cntxt-obj-type
        v-cntxt-obj-code
        'active=request'
        v-obj-active
      }
    end.
    else do:
      assign
        v-obj-active = ?
      .
    end.

    if v-obj-active = true
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

end procedure. /* chk-obj-active */


procedure chk-obj-active-or-db-num-0 :

  define output parameter p-enable-item as logical   no-undo .

  define variable v-obj-active as logical   no-undo .
  define variable v-current-db-num as integer   no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/curdbnum.i
      v-current-db-num
    }

    if  v-cntxt-obj-code <> ?
    and v-cntxt-obj-code <> 0
    then do:
      { gbl/objat.i
        v-cntxt-obj-type
        v-cntxt-obj-code
        'active=request'
        v-obj-active
      }
    end.
    else do:
      assign
        v-obj-active = ?
      .
    end.

    if v-obj-active = true
    or v-current-db-num = 0
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

end procedure. /* chk-obj-active-or-db-num-0 */

procedure chk-obj-type-shop :

  define output parameter p-enable-item as logical   no-undo .

  do
  on error undo, return error return-value
  :
    if v-cntxt-obj-type = {&shop}
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

end procedure. /* chk-obj-type-shop */


procedure chk-shift :

  define output parameter p-enable-item as logical   no-undo .

  define variable v-shift-obj-on as logical   no-undo .

  do
  on error undo, return error return-value
  :
    if  v-cntxt-obj-code <> ?
    and v-cntxt-obj-code <> 0
    then do:
      { gbl/objat.i
        v-cntxt-obj-type
        v-cntxt-obj-code
        "'shift-on=request':u"
        v-shift-obj-on
        no-error
      }
    end.
    else do:
      assign
        v-shift-obj-on = ?
      .
    end.

    if v-shift-obj-on = true
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

end procedure. /* chk-shift */
PROCEDURE chk-is-finby :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-enable-item as logical   no-undo .

  define variable v-is-finby as character no-undo .
  define variable par-type as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'is-finby':U"
      "'':U"
      "'':U"
      0
      "'':U"
      "'':U"
      "'':U"
      no
      v-is-finby
      par-type
      no-error
    }
    if error-status :error
    then do:
      v-is-finby = 'no':U .
    end.

    if  v-is-finby = 'yes':U
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

END PROCEDURE.

procedure chk-menu-group-all :

  define output parameter p-enable-item as logical   no-undo .

  do
  on error undo, return error return-value
  :
    run chk-menu-group-valid in parparentproc
      (input  'all':u
      ,output p-enable-item
      ) .
  end.

end procedure.

procedure chk-menu-group-off :

  define output parameter p-enable-item as logical   no-undo .

  do
  on error undo, return error return-value
  :
    run chk-menu-group-valid in parparentproc
      (input  'off':u
      ,output p-enable-item
      ) .
  end.

end procedure.

procedure chk-menu-group-str :

  define output parameter p-enable-item as logical   no-undo .

  do
  on error undo, return error return-value
  :
    run chk-menu-group-valid in parparentproc
      (input  'str':u
      ,output p-enable-item
      ) .
  end.

end procedure.

procedure chk-menu-group-shp :

  define output parameter p-enable-item as logical   no-undo .

  do
  on error undo, return error return-value
  :
    run chk-menu-group-valid in parparentproc
      (input  'shp':u
      ,output p-enable-item
      ) .
  end.

end procedure.

procedure chk-menu-group-res :

  define output parameter p-enable-item as logical   no-undo .

  do
  on error undo, return error return-value
  :
    run chk-menu-group-valid in parparentproc
      (input  'res':u
      ,output p-enable-item
      ) .
  end.

end procedure.

procedure chk-menu-group-fin :

  define output parameter p-enable-item as logical   no-undo .

  do
  on error undo, return error return-value
  :
    run chk-menu-group-valid in parparentproc
      (input  'fin':u
      ,output p-enable-item
      ) .
  end.

end procedure.

procedure chk-menu-group-bge :

  define output parameter p-enable-item as logical   no-undo .

  do
  on error undo, return error return-value
  :
    run chk-menu-group-valid in parparentproc
      (input  'bge':u
      ,output p-enable-item
      ) .
  end.

end procedure.

procedure chk-menu-group-adm :

  define output parameter p-enable-item as logical   no-undo .

  do
  on error undo, return error return-value
  :
    run chk-menu-group-valid in parparentproc
      (input  'adm':U
      ,output p-enable-item
      ) .
  end.

end procedure. /* chk-menu-group-adm */

procedure chk-menu-group-mmr :

  define output parameter p-enable-item as logical   no-undo .

  do
  on error undo, return error return-value
  :
    run chk-menu-group-valid in parparentproc
      (input  'mmr':U
      ,output p-enable-item
      ) .
  end.

end procedure. /* chk-menu-group-adm */


procedure clear-menu :

  define variable v-menu-item-handle as widget-handle no-undo .

  /* удаление пунктов меню - подпунктов главного меню */
  assign
    v-menu-item-handle = p-menu-handle :first-child
  .
  do while valid-handle(v-menu-item-handle)
  :
    delete widget v-menu-item-handle .
    assign
      v-menu-item-handle = p-menu-handle :first-child
    .
  end.

end procedure.


procedure m-pinp :
  do on error undo, return error return-value  :
    run rep/r-pinp.p (input parparentproc, input v-cntxt-obj-type, input v-cntxt-obj-code ) .
  end.
end procedure.


procedure m-pexcis :
  do on error undo, return error return-value  :
    run rep/r-pexcis.p (input parparentproc, input v-cntxt-obj-type, input v-cntxt-obj-code ) .
  end.
end procedure.

procedure m-is_PM-rep :
  do on error undo, return error return-value  :
    run rep/g-is_PM-rep.w ( input parparentproc ) .
  end.
end procedure.

procedure m-shift-periods :
  do on error undo, return error return-value  :
    run rep/g-shift-periods.w (input parparentproc, input v-cntxt-obj-type, input v-cntxt-obj-code ) .
  end.
end procedure.

procedure m-reason-exe :
  define variable j_reason-code like ub.trn-reason.reason-code no-undo.

  do on error undo, return error return-value :
    run str/trn-reas.w ( input parparentproc, input {&reference}, input-output j_reason-code ).
  end.
end procedure. /* m-reason-exe */

procedure m-rfin-allord-exe  :
  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p (parparentproc , 'firm-fin':U,'out':U, {&fact} ) .
  end.
end procedure.

procedure m-rfin-without-fo-exe   :
  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p (parparentproc , 'without-fo':U,'out':U, {&fact} ) .
  end.
end procedure.

procedure m-rfin-with-fo-exe     :
  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p (parparentproc , 'with-fo':U,'out':U, {&fact} ) .
  end.
end procedure.

procedure m-fin-allord-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'firm-fin':U,"all":U ,{&fact}) .
  end.
end procedure.

procedure m-fin-without-fo-exe  :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'without-fo':U,"all":U ,{&fact}) .
  end.
end procedure. /* m-all-of-u-exe */

procedure m-fin-with-fo-exe      :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'with-fo':U,"all":U ,{&fact}) .
  end.
end procedure. /* m-all-of-u-exe */

procedure m_pricing-exe :
  define variable v-current-db-num as integer   no-undo .
  do
  on error undo, return error return-value
  :
    { gbl/curdbnum.i
      v-current-db-num
    }

   run str/pricing.w (parparentproc , v-current-db-num ) .
  end.

end procedure. /* m_pricing-exe */

procedure m-type-pricelists-exe :

  do
  on error undo, return error return-value
  :
  define variable v-rec-list as character no-undo .
    run ref/typepric.w (parparentproc , "b-add,b-del,b-chg", input-output v-rec-list) .
  end.

end procedure. /* m-type-pricelists-exe */

procedure m-group-obj-price-exe :

  do
  on error undo, return error return-value
  :
  define variable v-rec-list as character no-undo .
   run ref/gr-objpr.w (parparentproc ,"b-add,b-del,b-chg" , input-output v-rec-list) .
  end.

end procedure. /* m-group-obj-price-exe */

procedure m-group-buyer-pr-exe :
define variable v-rec-list as character no-undo .
  do
  on error undo, return error return-value
  :
  run ref/gr-bupr.w (parparentproc ,"b-add,b-del,b-chg", input-output v-rec-list ) .
  end.

end procedure. /* m-group-buyer-pr-exe */

procedure m-oborot-buyer-pr-exe :
define variable v-rec-list as character no-undo .
  do
  on error undo, return error return-value
  :

  run ref/gr-obupr.w (parparentproc, "b-add,b-del,b-chg", input-output v-rec-list) .
  end.

end procedure. /* m-oborot-buyer-pr-exe */

procedure m-group-summ-pr-exe :
define variable v-rec-list as character no-undo .
  do
  on error undo, return error return-value
  :
  run ref/gr-supr.w (parparentproc ,"b-add,b-del,b-chg", input-output v-rec-list) .
  end.

end procedure. /* m-group-summ-pr-exe */

procedure m-group-qnty-pr-exe :

  do
  on error undo, return error return-value
  :
  define variable v-rec-list as character no-undo .
  run ref/gr-qupr.w (parparentproc,"b-add,b-del,b-chg", input-output v-rec-list) .
  end.

end procedure. /* m-group-qnty-pr-exe */

procedure m-utd-exe :

  do
  on error undo, return error return-value
  :
    define variable v-rec-list as character no-undo .
    define variable vconnect as com-handle no-undo.
    run str/UPD.w ( parparentproc, "", 0, ?, input-output vconnect , output v-rec-list) .
    release object vconnect no-error.
  end.

end procedure. /* m-utd-exe */

procedure m-mark_collect-exe :

  do
  on error undo, return error return-value
  :
    define variable v-rec-list as character no-undo .
    run str/Mark_Collect-docs.w ( parparentproc, "", output v-rec-list) .
  end.

end procedure. /* m-mark_collect-exe */

procedure m-zakaz-exe :

  do
  on error undo, return error return-value
  :
    define variable v-rec-list as character no-undo .
    run str/all-orders.w ( parparentproc, "", output v-rec-list) .
  end.

end procedure. /* m-zakaz-exe */

procedure m-docs-pricelists-exe :
define variable v-ok as logical   no-undo .

  do
  on error undo, return error return-value
  :
  define variable v-rec-list as character no-undo .
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_documents_all':U
      {&cntxt-global}
      0
      "''"
      0
      0
      0
      0
      true
      v-ok
    }
    if v-ok then do:
      run str/docsprls.w ( parparentproc , "all" , ? , ? , "b-add,b-del,b-chg" , input-output v-rec-list) .
    end.
  end.

end procedure. /* m-docs-pricelists-exe */
procedure m-docs-pricelists-obj :

  do
  on error undo, return error return-value
  :
  define variable v-rec-list as character no-undo .
  run str/pdfobj.w ( parparentproc , "all" , v-cntxt-obj-type, v-cntxt-obj-code , ? , ? , "b-add,b-del,b-chg" , input-output v-rec-list) .
  end.

end procedure. /* m-docs-pricelists-exe */

procedure m-docs-pricelists-onew :

  do
  on error undo, return error return-value
  :
  define variable v-rec-list as character no-undo .
  run str/pdfnew.w ( parparentproc , "all" , v-cntxt-obj-type, v-cntxt-obj-code , ? , ? , "b-add,b-del,b-chg" , input-output v-rec-list) .
  end.

end procedure. /* m-docs-pricelists-exe */


procedure c-obj-ext-inv-exe :
  do on error undo, return error return-value :
    run dm-c-doc-exe in this-procedure ( input {&c-type},
                                         input ?,
                                         input '?',
                                         input {&inventory},
                                         input no,
                                         input {&TDEDT_Inv},
                                         input ? ).
  end. /* on error */
end procedure. /* c-obj-ext-inv-exe */

procedure c-obj-all-ho-exe :
  do on error undo, return error return-value :
    run dm-c-doc-exe in this-procedure ( input {&c-g___object},
                                         input ?,
                                         input '?',
                                         input '?',
                                         input ?,
                                         input ?,
                                         input no ).
  end. /* on error */
end procedure. /* c-obj-all-ho-exe */

procedure c-obj-all-hi-exe :
  do on error undo, return error return-value :
    run dm-c-doc-exe in this-procedure ( input {&c-g___object},
                                         input ?,
                                         input '?',
                                         input '?',
                                         input ?,
                                         input ?,
                                         input yes ).
  end. /* on error */
end procedure. /* c-obj-all-hi-exe */

procedure c-host-all-ho-exe :
  do on error undo, return error return-value :
    run dm-c-doc-exe in this-procedure ( input {&c-company},
                                         input ?,
                                         input '?',
                                         input '?',
                                         input ?,
                                         input ?,
                                         input no ).
  end. /* on error */
end procedure. /* c-host-all-ho-exe */

procedure c-host-all-hi-exe :
  do on error undo, return error return-value :
    run dm-c-doc-exe in this-procedure ( input {&c-company},
                                         input ?,
                                         input '?',
                                         input '?',
                                         input ?,
                                         input ?,
                                         input yes ).
  end. /* on error */
end procedure. /* c-host-all-hi-exe */

procedure c-m-all-ho-exe :
  run c-trn-doc-all-exe in this-procedure ( input no ).
end procedure. /* c-m-all-ho-exe */

procedure c-m-all-hi-exe :
  run c-trn-doc-all-exe in this-procedure ( input yes ).
end procedure. /* c-m-all-hi-exe */

procedure c-obj-ext-in-hi-exe :
  do on error undo, return error return-value :
    run dm-c-doc-exe in this-procedure ( input {&c-type},
                                         input ?,
                                         input '?',
                                         input {&income},
                                         input no,
                                         input {&TDEDT_Pri_Vnesh},
                                         input yes ).
  end. /* on error */
end procedure. /* c-obj-ext-in-hi-exe */

procedure c-obj-ext-out-hi-exe :
  do on error undo, return error return-value :
    run dm-c-doc-exe in this-procedure ( input {&c-type},
                                         input ?,
                                         input '?',
                                         input {&expense},
                                         input no,
                                         input {&TDEDT_Ras_Vnesh},
                                         input yes ).
  end. /* on error */
end procedure. /* c-obj-ext-out-hi-exe */

procedure c-obj-ext-sup-hi-exe :
  do on error undo, return error return-value :
    run dm-c-doc-exe in this-procedure ( input {&c-type},
                                         input ?,
                                         input '?',
                                         input {&expense},
                                         input no,
                                         input {&TDEDT_Ras_Vnesh_VP},
                                         input yes ).
  end. /* on error */
end procedure. /* c-obj-ext-sup-hi-exe */

procedure c-obj-ext-ret-hi-exe :
  do on error undo, return error return-value :
    run dm-c-doc-exe in this-procedure ( input {&c-type},
                                         input ?,
                                         input '?',
                                         input {&return},
                                         input no,
                                         input {&TDEDT_Vozvrat_Vnesh},
                                         input yes ).
  end. /* on error */
end procedure. /* c-obj-ext-ret-hi-exe */

procedure c-trn-doc-all-exe :
  define input parameter p-is-hold as logical no-undo.
  define variable loc-ref-list as character no-undo.

  do on error undo, return error return-value :

    run str/calldocs.w
      (input parparentproc
      ,input {&c-work}
      ,input ?
      ,input ?
      ,input ?
      ,input ?
      ,input "":U
      ,input ?
      ,input p-is-hold
      ,input ?
      ,input v-cntxt-obj-type
      ,input v-cntxt-obj-code
      ,output loc-ref-list
      ).

  end. /* on error */
end procedure. /* c-trn-doc-all-exe */

procedure chk-group-buyer-price :
  define output parameter p-enable-item as logical   no-undo .

  define buffer buf_global-state for ub.global-state  .

  do
  on error undo, return error return-value
  :

    assign
      p-enable-item = false
    .

    find last buf_global-state no-lock  no-error .
    if error-status :error
    then do:
      return .
    end.

    if buf_global-state.pl-use-grp-buy  = true
    then do:
      assign
        p-enable-item = true
      .
    end.
  end.

end procedure. /* chk-group-buyer-price */

procedure chk-oborot-buyer-price :
define output parameter p-enable-item as logical   no-undo .

define buffer buf_global-state for ub.global-state  .
  do
  on error undo, return error return-value
  :
     p-enable-item = false  .

    find last buf_global-state no-lock  no-error .
    if error-status :error then do:
       return .
    end.

    if buf_global-state.pl-use-oborot-buy  = true  then do:
       p-enable-item = true .
    end.

  end.

end procedure. /* chk-oborot-buyer-price */

procedure chk-group-summ-price  :
define output parameter p-enable-item as logical   no-undo .

define buffer buf_global-state for ub.global-state  .
  do
  on error undo, return error return-value
  :
     p-enable-item = false  .

    find last buf_global-state no-lock  no-error .
    if error-status :error then do:
       return .
    end.

    if buf_global-state.pl-use-sum-group  = true  then do:
       p-enable-item = true .
    end.

  end.

end procedure. /* chk-group-summ-price  */

procedure chk-group-qnty-price  :
define output parameter p-enable-item as logical   no-undo .

define buffer buf_global-state for ub.global-state  .
  do
  on error undo, return error return-value
  :
     p-enable-item = false  .

    find last buf_global-state no-lock  no-error .
    if error-status :error then do:
       return .
    end.

    if buf_global-state.pl-use-qnty-group  = true  then do:
       p-enable-item = true .
    end.

  end.

end procedure. /* chk-group-qnty-price  */

procedure chk-ukr-ptrl :
  define output parameter p-enable-item as logical no-undo initial no.

  define variable is_OK      as logical   no-undo.

  do on error undo, return error return-value :
    run chk-is-ptrl in this-procedure ( output is_OK ) no-error.
    if error-status :error or is_OK <> yes then do: undo, return error return-value. end.
    if "{&abbr-country}":U = "UKR":U  then do: assign p-enable-item = yes. end.
  end.
end procedure. /* chk-ukr-ptrl */


procedure m__menu-select-context-exe :

  do
  on error undo, return error return-value
  :
    run trigger-select-context in parparentproc
      no-error .
  end.

end procedure. /* m__menu-select-context */


procedure m__menu-all-exe :

  define buffer buf_menu-group for ub.menu-group .

  do
  on error undo, return error return-value
  :
    find first buf_menu-group no-lock
      where buf_menu-group.menu-code     = p-menu-code
        and buf_menu-group.menu-group-id = 'all':U
      no-error .
    if not available buf_menu-group
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена группа пунктов меню" skip
        "Код меню" p-menu-code skip
        "Идентификатор группы пунктов меню" 'all':U skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    run select-menu-group in parparentproc
      (input  buf_menu-group.menu-group-code
      ).
  end.

end procedure. /* m__menu-all-exe */


procedure m__menu-off-exe :
  define buffer buf_menu-group for ub.menu-group .

  do
  on error undo, return error return-value
  :
    find first buf_menu-group no-lock
      where buf_menu-group.menu-code     = p-menu-code
        and buf_menu-group.menu-group-id = 'off':U
      no-error .
    if not available buf_menu-group
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена группа пунктов меню" skip
        "Код меню" p-menu-code skip
        "Идентификатор группы пунктов меню" 'off':U skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    run select-menu-group in parparentproc
      (input  buf_menu-group.menu-group-code
      ).
  end.

end procedure. /* m__menu-off-exe */


procedure m__menu-mmr-exe :
  define buffer buf_menu-group for ub.menu-group .

  do
  on error undo, return error return-value
  :
    find first buf_menu-group no-lock
      where buf_menu-group.menu-code     = p-menu-code
        and buf_menu-group.menu-group-id = 'mmr':U
      no-error .
    if not available buf_menu-group
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена группа пунктов меню" skip
        "Код меню" p-menu-code skip
        "Идентификатор группы пунктов меню" 'mmr':U skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    run select-menu-group in parparentproc
      (input  buf_menu-group.menu-group-code
      ).
  end.

end procedure. /* m__menu-mmr-exe */


procedure m__menu-str-exe :

  define buffer buf_menu-group for ub.menu-group .

  do
  on error undo, return error return-value
  :
    find first buf_menu-group no-lock
      where buf_menu-group.menu-code     = p-menu-code
        and buf_menu-group.menu-group-id = 'str':U
      no-error .
    if not available buf_menu-group
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена группа пунктов меню" skip
        "Код меню" p-menu-code skip
        "Идентификатор группы пунктов меню" 'str':U skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    run select-menu-group in parparentproc
      (input  buf_menu-group.menu-group-code
      ).
  end.

end procedure. /* m__menu-str-exe */

procedure m__menu-shp-exe :

  define buffer buf_menu-group for ub.menu-group .

  do
  on error undo, return error return-value
  :
    find first buf_menu-group no-lock
      where buf_menu-group.menu-code     = p-menu-code
        and buf_menu-group.menu-group-id = 'shp':U
      no-error .
    if not available buf_menu-group
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена группа пунктов меню" skip
        "Код меню" p-menu-code skip
        "Идентификатор группы пунктов меню" 'shp':U skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    run select-menu-group in parparentproc
      (input  buf_menu-group.menu-group-code
      ).
  end.

end procedure. /* m__menu-shp-exe */


procedure m__menu-res-exe :

  define buffer buf_menu-group for ub.menu-group .

  do
  on error undo, return error return-value
  :
    find first buf_menu-group no-lock
      where buf_menu-group.menu-code     = p-menu-code
        and buf_menu-group.menu-group-id = 'res':U
      no-error .
    if not available buf_menu-group
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена группа пунктов меню" skip
        "Код меню" p-menu-code skip
        "Идентификатор группы пунктов меню" 'res':U skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    run select-menu-group in parparentproc
      (input  buf_menu-group.menu-group-code
      ).
  end.

end procedure. /* m__menu-res-exe */

procedure m__menu-fin-exe :

  define buffer buf_menu-group for ub.menu-group .

  do
  on error undo, return error return-value
  :
    find first buf_menu-group no-lock
      where buf_menu-group.menu-code     = p-menu-code
        and buf_menu-group.menu-group-id = 'fin':U
      no-error .
    if not available buf_menu-group
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена группа пунктов меню" skip
        "Код меню" p-menu-code skip
        "Идентификатор группы пунктов меню" 'fin':U skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    run select-menu-group in parparentproc
      (input  buf_menu-group.menu-group-code
      ).
  end.

end procedure. /* m__menu-fin-exe */

procedure m__menu-bge-exe :

  define buffer buf_menu-group for ub.menu-group .

  do
  on error undo, return error return-value
  :
    find first buf_menu-group no-lock
      where buf_menu-group.menu-code     = p-menu-code
        and buf_menu-group.menu-group-id = 'bge':U
      no-error .
    if not available buf_menu-group
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена группа пунктов меню" skip
        "Код меню" p-menu-code skip
        "Идентификатор группы пунктов меню" 'bge':U skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    run select-menu-group in parparentproc
      (input  buf_menu-group.menu-group-code
      ).
  end.

end procedure. /* m__menu-bge-exe */

procedure m__menu-buh-exe :

  define buffer buf_menu-group for ub.menu-group .

  do
  on error undo, return error return-value
  :
    find first buf_menu-group no-lock
      where buf_menu-group.menu-code     = p-menu-code
        and buf_menu-group.menu-group-id = 'buh':U
      no-error .
    if not available buf_menu-group
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена группа пунктов меню" skip
        "Код меню" p-menu-code skip
        "Идентификатор группы пунктов меню" 'buh':U skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    run select-menu-group in parparentproc
      (input  buf_menu-group.menu-group-code
      ).
  end.

end procedure. /* m__menu-buh-exe */

procedure m__menu-fas-exe :

  define buffer buf_menu-group for ub.menu-group .

  do
  on error undo, return error return-value
  :
    find first buf_menu-group no-lock
      where buf_menu-group.menu-code     = p-menu-code
        and buf_menu-group.menu-group-id = 'fas':U
      no-error .
    if not available buf_menu-group
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена группа пунктов меню" skip
        "Код меню" p-menu-code skip
        "Идентификатор группы пунктов меню" 'fas':U skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    run select-menu-group in parparentproc
      (input  buf_menu-group.menu-group-code
      ).
  end.

end procedure. /* m__menu-fas-exe */
PROCEDURE journal-vsd :
     DEFINE VARIABLE v-vsd-dialog AS  CLASS  ibs.th.ref.journal_vsd_abl  .  
     v-vsd-dialog = NEW ibs.th.ref.journal_vsd_abl (  parparentproc  ) .
     v-vsd-dialog:ShowModalDialog().
     finally: 
         DELETE  OBJECT v-vsd-dialog no-error.
     end finally.  
END PROCEDURE.
procedure m__menu-adm-exe :

  define buffer buf_menu-group for ub.menu-group .

  do
  on error undo, return error return-value
  :
    find first buf_menu-group no-lock
      where buf_menu-group.menu-code     = p-menu-code
        and buf_menu-group.menu-group-id = 'adm':U
      no-error .
    if not available buf_menu-group
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена группа пунктов меню" skip
        "Код меню" p-menu-code skip
        "Идентификатор группы пунктов меню" 'adm':U skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    run select-menu-group in parparentproc
      (input  buf_menu-group.menu-group-code
      ).
  end.

end procedure. /* m__menu-adm-exe */


procedure m__menu-bck-exe :

  do
  on error undo, return error return-value
  :
    run select-previous-menu-group-id in parparentproc .
  end.

end procedure. /* m__menu-bck-exe */

procedure m__fo-dels-exe :
define variable varrid-list as character no-undo .
  do
  on error undo, return error return-value
  :
  run str/fin-dels.w
  (input parParentProc,
   input 'b-lkp',
   input {&company},
   input ?,
   input v-cntxt-host-code-obj,
   input ?,
   input ?,
   input '',
   output varrid-list ).

  end.

end procedure. /* fo-dels-exe */

procedure m-all-or-new-exe  :
  do on error undo, return error return-value :
    run cus/ord-pos.p (parparentproc,'obj':U,{&o-r},{&g___new}) .
  end.
end procedure.
procedure m-all-or-req-exe  :
  do on error undo, return error return-value :
     run cus/ord-pos.p (parparentproc,'obj':U,{&o-r},{&ord-req}) .
  end.
end procedure.
procedure m-all-or-per-exe  :
  do on error undo, return error return-value :
    run cus/ord-pos.p (parparentproc,'obj':U,{&o-r},{&ord-per}) .
  end.
end procedure.
procedure m-all-or-rej-exe  :
  do on error undo, return error return-value :
    run cus/ord-pos.p (parparentproc,'obj':U,{&o-r},{&ord-rejection}) .
  end.
end procedure.

procedure m-all-or-ship-exe :
  do on error undo, return error return-value :
    run cus/ord-pos.p (parparentproc,'obj':U,{&o-r},{&ord-ship}).
  end.
end procedure.
procedure m-all-or-fact-exe :
  do on error undo, return error return-value :
     run cus/ord-pos.p (parparentproc,'obj':U,{&o-r},{&fact})    .
  end.
end procedure.
procedure m-all-or-all-exe  :
  do on error undo, return error return-value :
     run cus/ord-pos.p (parparentproc,'obj':U,{&o-r},'all':U)    .
  end.
end procedure.
procedure m-all-rc-req-exe  :
  do on error undo, return error return-value :
     run cus/ord-pos.p (parparentproc,'rc':U,{&o-r},{&ord-req})  .
  end.
end procedure.
procedure m-all-rc-per-exe  :
  do on error undo, return error return-value :
    run cus/ord-pos.p (parparentproc,'rc':U,{&o-r},{&ord-per})  .
  end.
end procedure.

procedure m-all-rc-rej-exe  :
  do on error undo, return error return-value :
    run cus/ord-pos.p (parparentproc,'rc':U,{&o-r},{&ord-rejection})  .
  end.
end procedure.

procedure m-all-rc-ship-exe :
  do on error undo, return error return-value :
    run cus/ord-pos.p (parparentproc,'rc':U,{&o-r},{&ord-ship}) .
  end.
end procedure.
procedure m-all-rc-fact-exe :
  do on error undo, return error return-value :
    run cus/ord-pos.p (parparentproc,'rc':U,{&o-r},{&fact})     .
  end.
end procedure.
procedure m-all-rc-all-exe  :
  do on error undo, return error return-value :
    run cus/ord-pos.p (parparentproc,'rc':U,{&o-r},'all':U)     .
  end.
end procedure.

procedure m-po-new-exe  :
  do on error undo, return error return-value :
     run cus/ord-buy.p (parparentproc,{&p-o},{&g___new})  .
  end.
end procedure.

procedure m-po-reject-exe  :
  do on error undo, return error return-value :
     run cus/ord-buy.p (parparentproc,{&p-o},{&ord-rejection})  .
  end.
end procedure.

procedure m-po-rcv-exe  :
  do on error undo, return error return-value :
     run cus/ord-buy.p (parparentproc,{&p-o},{&ord-rcv})  .
  end.
end procedure.

procedure m-po-fact-exe :
  do on error undo, return error return-value :
     run cus/ord-buy.p (parparentproc,{&p-o},{&fact})  .
  end.
end procedure.

procedure m-po-all-exe :
  do on error undo, return error return-value :
     run cus/ord-buy.p (parparentproc,{&p-o},'all':U )  .
  end.
end procedure.

procedure m_util-upgrade-exe :
define variable ri-list as character no-undo .
  do
  on error undo, return error
  :
    run adm/ipckwork.w ( input parparentproc, input 1, input ?, input ?, input '':U, input '', input-output ri-list).
  end.

end procedure. /* m-ipckwork-upgrade */

procedure m_util-filework-exe :
define variable ri-list as character no-undo .
  do
  on error undo, return error
  :
    run adm/ipckwork.w ( input parparentproc, input 0, input ?, input ?, input '':U, input '', input-output ri-list).
  end.

end procedure. /* m-ipckwork-filework */

procedure m_util-xibmfilework-exe :
define variable ri-list as character no-undo .
  do
  on error undo, return error
  :
    run adm/ipckxibm.w ( input parparentproc
                       , input-output ri-list).
  end.

end procedure. /* m-ipckwork-filework */


procedure m_util-transfer-exe :
define variable ri-list as character no-undo .
  do
  on error undo, return error
  :
    run nws/sndfnws.w ( input parparentproc, input '':U, input ?, input ?, input '':U).
  end.

end procedure. /* m-ipckwork-transfer */
procedure c-obj-pst-exe :
  do
  on error undo, return error return-value
  :
  run dm-c-doc-exe in this-procedure (INPUT {&c-type}, INPUT ?, INPUT '?', INPUT {&inventory}, INPUT no,  INPUT {&TDEDT_Peresort}, INPUT ? ).
  end.
end procedure. /* c-obj-cmp-exe */
procedure c-obj-inv-exe :
  do
  on error undo, return error return-value
  :
  run dm-c-doc-exe in this-procedure (INPUT {&c-type}, INPUT ?, INPUT '?', INPUT {&inventory}, INPUT no,  INPUT {&TDEDT_Inv}, INPUT ? ).
  end.
end procedure. /* c-obj-cmp-exe */

PROCEDURE image-procedure-in-ov :
  do
  on error undo, return error return-value
  :
    /* todo - вызывать пункт меню */
    message
      "Переоценка после прихода. Функция вызывается через меню."
      view-as alert-box.
  end.

END PROCEDURE.
PROCEDURE image-procedure-cd :
  do
  on error undo, return error return-value
  :
    run str/cd-inf.p
      (input parparentproc
      ,input no
      ,input yes
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры" 'str/cd-inf.p':U skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    run image-display-cd in parparentproc .
  end.

END PROCEDURE.
PROCEDURE image-procedure-scales :
  do
  on error undo, return error return-value
  :
    /* todo - проверить параметры вызова */
    run str/diallog.w
      ( input parparentproc
      , input this-procedure
      , input "ref/sendscal.p":U
      , input (v-cntxt-obj-type + {&delim-par} + string(v-cntxt-obj-code) + {&delim-par} + {&question-mark} + {&delim-par} +
               "changed":U + {&delim-par} + '':U + {&delim-par} + "current":U + {&delim-par} +
               string(0))
      , input no /*p-auto-go*/
      , input "":U
      , input substitute("Отсылка изменений на весы")
      ) no-error.
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры" 'ref/sendscal.p':U skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    run image-display-scales in parparentproc .
  end.

END PROCEDURE.
PROCEDURE image-procedure-curses :
  do
  on error undo, return error return-value
  :
    /* todo - проверить параметры вызова */
    run str/diallog.w
      ( input parparentproc
      , input this-procedure
      , input "str/send-cur.p":U
      , input (v-cntxt-obj-type + {&delim-par} + string(v-cntxt-obj-code) + {&delim-par} + "U")
      , input no /*p-auto-go*/
      , input "":U
      , input substitute("Отсылка данных по курсам валют на кассы")
      ) no-error.
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры" 'str/send-cur.p':U skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    run image-display-curses in parparentproc .
  end.

END PROCEDURE.
PROCEDURE image-procedure-ck-gds :
  do
  on error undo, return error return-value
  :
    /* никаких действий */
  end.

END PROCEDURE.
PROCEDURE image-procedure-fls-ck :
  do
  on error undo, return error return-value
  :
    /* todo - открывать соответствующий пункт меню */

    /* есть ошибочные чеки смотрим их */
    run m-chk-free-exe in this-procedure  .
    run image-display-sales in parparentproc.
  end.

END PROCEDURE.
PROCEDURE image-procedure-gds-sl :
  do
  on error undo, return error return-value
  :
    /* todo - открывать соответствующий пункт меню */

    /* есть неучтенные чеки по товару делаем расчет продажи */
    run m-chk-sale-exe in this-procedure .
    run image-display-sales in parparentproc.
  end.
END PROCEDURE.
PROCEDURE image-procedure-ord-do :
  do
  on error undo, return error return-value
  :
  define variable v-kol-ord as integer no-undo .
    run cus/ord-cyc.p
      (input v-cntxt-obj-type ,
       input v-cntxt-obj-code ,
       input this-procedure ,
       output v-kol-ord
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры" 'cus/ord-cyc.p':U skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    run image-display-ord-do in parparentproc .
  end.
END PROCEDURE.
PROCEDURE image-procedure-ck-wth :
  do
  on error undo, return error return-value
  :
    /* todo - открывать соответствующий пункт меню */

    /* есть ошибочные чеки смотрим их */
  end.
END PROCEDURE.
PROCEDURE image-procedure-awth :
  do
  on error undo, return error return-value
  :
    /* todo - открывать соответствующий пункт меню */

    /*рассчитываем автодокументы*/
    run m-chk-wth-r-exe in this-procedure .
  end.
END PROCEDURE.
PROCEDURE image-procedure-nwsc :
  do
  on error undo, return error return-value
  :
define variable v-rid-list as character no-undo .
 run gbl/nwscolls.w (
                   input parparentproc
                  ,input '':U
                  ,input {&all}
                  ,input - 1  /*p-db-num*/
                  ,input '':U /*p-subject */
                  ,input '':U /*p-uniq-key-rec */
                  ,input-output v-rid-list
                  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры" 'gbl/nwscolls.w':U skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
  run image-display-nwsc in parparentproc .
  end.
END PROCEDURE.
PROCEDURE image-procedure-priper :
  do
  on error undo, return error return-value
  :
    /* есть внутренние приходы смотрим их */
    define variable loc-ref-list as character no-undo .
    run str/all-docs.w
      (input  parparentproc
      ,input  v-cntxt-host-code-obj
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  {&flag}
      ,input  {&wayb}
      ,input  {&income}
      ,input  yes
      ,input  yes
      ,input  "b-close"
      ,input  {&TDEDT_Pri_Perem}
      ,input  no
      ,input  ?
      ,output loc-ref-list
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры" 'str/all-docs.w':U skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    run image-display-priper in parparentproc .
    run image-display-ovrorc in parparentproc .
    run image-display-qntorc in parparentproc .
  end.
END PROCEDURE.
PROCEDURE image-procedure-vozper :
  do
  on error undo, return error return-value
  :
    /* есть внутренние возвраты, смотрим их */
    define variable loc-ref-list as character no-undo .
    run str/all-docs.w
      (input  parparentproc
      ,input  v-cntxt-host-code-obj
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  {&type}
      ,input  ?
      ,input  {&return}
      ,input  yes
      ,input  yes
      ,input  ""
      ,input  {&TDEDT_Vozvrat_Perem}
      ,input  no
      ,input  ?
      ,output loc-ref-list
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры" 'str/all-docs.w':U skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
  run image-display-vozper in parparentproc .
  end.

END PROCEDURE.

PROCEDURE image-procedure-ovrval :
  do
  on error undo, return error return-value
  :
    /* есть документы переоценки, смотрим их */
    define variable loc-ref-list as character no-undo .
    run str/pr-docs.w
      (input  parparentproc
      ,input  "b-mark"
      ,input  {&status}
      ,input  {&order}
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  ""
      ,output loc-ref-list
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры" 'str/pr-docs.w':U skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    run image-display-ovrval in parparentproc .
  end.
END PROCEDURE.

PROCEDURE image-procedure-ovrorc :
  do
  on error undo, return error return-value
  :
    /* есть документы переоценки, смотрим их */
    define variable loc-ref-list as character no-undo .
    run str/pr-docs.w
      (input  parparentproc
      ,input  "b-mark"
      ,input  {&status}
      ,input  {&act-overvalue}
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  ""
      ,output loc-ref-list
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры" 'str/pr-docs.w':U skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    run image-display-ovrorc in parparentproc .
  end.
END PROCEDURE.

PROCEDURE image-procedure-qntorc :
  do
  on error undo, return error return-value
  :
    message "Необходимое количество товара по запросу ИМЕЕТСЯ !" view-as alert-box information .
    run image-display-qntorc in parparentproc .
  end.
END PROCEDURE.


PROCEDURE image-procedure-ass-min :
  do
  on error undo, return error return-value
  :
    run ref/gds-amin.w ( parparentproc , v-cntxt-obj-type, v-cntxt-obj-code, "min") no-error .
    run image-display-as-min in parparentproc .
  end.
END PROCEDURE.

/*
PROCEDURE image-procedure-iztdel :
define variable v-ok as logical   no-undo .
  do
  on error undo, return error return-value
  :
    message  substitute("Удалить из ассортиментных матриц товары, срок действия ИЖТ <<&1>> уже прошел ?" , {&ass-izd-del} )
        view-as alert-box question
        buttons yes-no
        update v-ok
        .
    if v-ok  then do:
       run utl/deliztdel.p ( parparentproc ).
    end.
    run image-display-iztdel in parparentproc .
  end.
END PROCEDURE.
*/

PROCEDURE image-procedure-twotpl :
/* есть 2ки по ТПЛ смотрим их */
  do
  on error undo, return error return-value
  :
define variable v-rec-list as character no-undo .
define variable l-exist-twotpl as logical   no-undo .
define variable v-str as character no-undo .
define buffer buf1_price-list-type for ub.price-list-type  .
define buffer buf2_price-list-type for ub.price-list-type  .
define buffer buf_BatchProcess  for ub.BatchProcess  .
define buffer exec_batchprocess for ub.BatchProcess  .

   find first buf_BatchProcess no-lock
        where buf_BatchProcess.bp_type       = {&btpr-type-twotpl}
          and buf_BatchProcess.bp_status     = {&btpr-normal}
              no-error   .
    if available buf_BatchProcess
    then do:
         find first buf1_price-list-type no-lock where
              recid(buf1_price-list-type) = int(buf_BatchProcess.CharKey_One) no-error .
         find first buf2_price-list-type no-lock where
              recid(buf2_price-list-type) = int(buf_BatchProcess.CharKey_Two) no-error .
        if available buf2_price-list-type and available buf1_price-list-type then
           v-str = substitute("ТПЛ &1(&2) &3  и  ТПЛ &4(&5) &6 с приоритетом &7" ,
                    buf1_price-list-type.plt-id ,
                    buf1_price-list-type.plt-db-num,
                    buf1_price-list-type.name ,
                    buf2_price-list-type.plt-id ,
                    buf2_price-list-type.plt-db-num,
                    buf2_price-list-type.name ,
                    buf2_price-list-type.priority ) .
           else v-str = "" .
        v-rec-list = buf_BatchProcess.CharKey_One + ',' + buf_BatchProcess.CharKey_Two .

        run ref/typepric.w (parparentproc , "b-add,b-del,b-chg,mode=twotpl" , input-output v-rec-list ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры" 'ref/typepric.w':U skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        end.
      message
        "Сообщать о двойниках в дальнейшем " skip
         v-str
         '?'
        view-as alert-box question
        buttons yes-no
        update v-ok as log
        .
        if v-ok = false then do:
          { trg/btpr_upd.i
            &btpr-status="executing_deleted"
            &btpr-table="exec_batchprocess"
            &btpr-rowid="rowid(buf_batchprocess)"
            &btpr_user_id=v-cntxt-userid
          }
      end.
    end.
    else do:
         message 'НОВЫЕ Двойники по приоритету в ТПЛ не обнаружены !' view-as alert-box information .
    end.
  run image-display-twotpl in parparentproc .
  end.
END PROCEDURE.

procedure chk-is-adoc-nn :

  define output parameter p-enable-item as logical   no-undo .

  define variable v-edoc-nn as character no-undo .
  define variable par-type as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'edoc-nn':u"
      "'':u"
      "'':u"
      0
      "'':u"
      "'':u"
      "'':u"
      no
      v-edoc-nn
      par-type
      no-error
    }
    if error-status :error
    then do:
        assign
          p-enable-item = false
        .
      return .
    end.

    if v-edoc-nn = 'yes':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
        assign
          p-enable-item = false
        .
    end.
  end.

end procedure. /* chk-shift */
procedure m_clients-edoc-exe :
define variable v-rid-list as character no-undo .

  do
  on error undo, return error
  :
    run cus/edoc-cli.w ( input parparentproc
                        ,input (if v-cntxt-db-num > 0 then '':U else "b-add")
                        ,input {&all}
                        ,input '':U
                        ,input-output v-rid-list) no-error.
  end.

end procedure. /* m_clients-edoc-exe */

procedure m_clients-enum-exe :
define variable v-rid-list as character no-undo .

  do
  on error undo, return error
  :
    run cus/enum-cli.w ( input parparentproc
                        ,input (if v-cntxt-db-num > 0 then '':U else "b-add")
                        ,input {&all}
                        ,input '':U
                        ,input-output v-rid-list) no-error.
  end.

end procedure. /* m_clients-enum-exe */

procedure m_clients-contr-exe :
define variable v-rid-list as character no-undo .

  do
  on error undo, return error
  :
    run cus/eorg-cli.w ( input parparentproc
                        ,input (if v-cntxt-db-num > 0 then '':U else "b-add")
                        ,input {&all}
                        ,input '':U
                        ,input-output v-rid-list) no-error.
  end.

end procedure. /* m_clients-enum-exe */

procedure m_clients-diadok-exe :
define variable v-rid-list as character no-undo .

  do
  on error undo, return error
  :
    run cus/diadok-cli.w ( input parparentproc
                        ,input (if v-cntxt-db-num > 0 then '':U else "b-add")
                        ,input {&all}
                        ,input '':U
                        ,input-output v-rid-list) no-error.
  end.

end procedure. /* m_clients-enum-exe */

procedure m_clients-gln-exe :
define variable v-rid-list as character no-undo .

  do
  on error undo, return error
  :
    run ref/gln-clis.w ( input parparentproc
                        ,input (if v-cntxt-db-num > 0 then '':U else "b-add")
                        ,input '':U
                        ,input-output v-rid-list) no-error.
  end.
end procedure. /* m_clients-gln-exe */

procedure m_clients-exite-exe :
define variable v-rid-list as character no-undo .

  do
  on error undo, return error
  :
    run cus/exiteedi.w ( input parparentproc
                        ,input (if v-cntxt-db-num > 0 then '':U else "b-add")
                        ,input {&all}
                        ,input ''
                        ,input-output v-rid-list) no-error.
  end.
end procedure. /* m_clients-eexite-exe */

procedure m_layouts_screen_exe :

run m_layouts_exe in this-procedure ( input {&th-pos-screen}).

end procedure. /* m_layouts_screen_exe */

procedure m_layouts_keyboard_exe :

run m_layouts_exe in this-procedure ( input {&th-pos-keyboard}).

end procedure. /* m_layouts_keyboard_exe */


procedure m_layouts_exe :
define input parameter p-layout-type as character no-undo .
define variable v-rid-list as character no-undo .

  do
  on error undo, return error
  :
    run adm/layoutss.w ( input parparentproc
                        ,input "b-add"
                        ,input "layout-type"
                        ,input p-layout-type
                        ,input-output v-rid-list ) no-error.

  end.
END PROCEDURE.

procedure m_tsheets-all-exe:
    run str/travel-sheets.w(parparentproc).
end.

PROCEDURE image-procedure-srgdn :
define variable v-ok as logical   no-undo .

/*Товары с критическим сроком годности*/
  do
  on error undo, return error return-value
  :
    define variable v-tth     as handle no-undo .
    run str/defctpar.w ( parparentproc , this-procedure, v-cntxt-obj-type, v-cntxt-obj-code, "srok" , 0, output TABLE-HANDLE v-tth) no-error .
    run image-display-srgdn in parparentproc .
  end.
END PROCEDURE.


PROCEDURE image-procedure-defec :
define variable v-ok as logical   no-undo .
/*Фальсифицированные и забракованные товары*/
  do
  on error undo, return error return-value
  :
    define variable v-tth     as handle no-undo .
    run str/defctpar.w ( parparentproc , this-procedure, v-cntxt-obj-type, v-cntxt-obj-code, "defect" , 0 , output TABLE-HANDLE v-tth ) no-error .
    run image-display-defec in parparentproc .
  end.
END PROCEDURE.

PROCEDURE image-procedure-srgdn1 :
define variable v-ok as logical   no-undo .

/*Товары с критическим сроком годности*/
  do
  on error undo, return error return-value
  :
    define variable v-tth     as handle no-undo .
    run str/defctpar.w ( parparentproc , this-procedure, v-cntxt-obj-type, v-cntxt-obj-code, "srok" , 1, output TABLE-HANDLE v-tth) no-error .
    run image-display-srgdn in parparentproc .
  end.
END PROCEDURE.


PROCEDURE image-procedure-defec1 :
define variable v-ok as logical   no-undo .
/*Фальсифицированные и забракованные товары*/
  do
  on error undo, return error return-value
  :
    define variable v-tth     as handle no-undo .
    run str/defctpar.w ( parparentproc , this-procedure, v-cntxt-obj-type, v-cntxt-obj-code, "defect" , 1 , output TABLE-HANDLE v-tth ) no-error .
    run image-display-defec in parparentproc .
  end.
END PROCEDURE.


procedure chk-is-pharm :

  define output parameter p-enable-item as logical   no-undo .

  define variable v-is-pharm  as character no-undo .
  define variable par-type   as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/conf-rd.i
      "'is-pharm'"
      "'':u"
      "'':u"
      0
      "'':u"
      "'':u"
      "'':u"
      no
      v-is-pharm
      par-type
      no-error
    }
    if lookup( v-is-pharm, "yes,no" ) = 0
    or v-is-pharm = ?
    or par-type <> {&type-log}
    or error-status :error
    then do:
      assign
        v-is-pharm = "no"
      .
    end.

    if v-is-pharm = 'no':u
    then do:
      assign
        p-enable-item = false
      .
    end.
    else do:
      assign
        p-enable-item = true
      .
    end.
  end.
end procedure.
/* 04/III-2019 не используется. Работа с кассовыми книгами перенесена в БПА
procedure chk-cash-book :

  define output parameter p-enable-item as logical   no-undo .

  define variable v-cash-book as logical   no-undo .
  define variable cash-book-int as integer no-undo .
  define variable v-mess as character no-undo .
  define variable v-obj-db-num as integer no-undo .
  define buffer buf_sysconf for ub.sysconf.

  do
  on error undo, return error return-value
  :
    if  v-cntxt-obj-code <> ?
    and v-cntxt-obj-code <> 0
    then do:
       { gbl/cashbook.i v-cntxt-obj-type v-cntxt-obj-code cash-book-int }
       if cash-book-int = integer({&cash-book-object}) then do:
          { gbl/objdbnum.i
        v-cntxt-obj-type
        v-cntxt-obj-code
            v-obj-db-num
        }
          if v-obj-db-num = v-cntxt-db-num then do:
            v-cash-book = yes.
          end.
       end.
       else do:
          find first buf_sysconf no-lock where
                  buf_sysconf.host-code = v-cntxt-host-code-obj.
          if buf_sysconf.firm-db-num = v-cntxt-db-num then do:
            v-cash-book = yes.
          end.
       end.

    end.
    else do:
      assign
        v-cash-book = ?
      .
    end.

    if v-cash-book = true
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.

end procedure. /* chk-cash-book */
*/

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE image-procedure-pharm W-Win
PROCEDURE image-procedure-pharm :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE image-procedure-petrol W-Win
PROCEDURE image-procedure-petrol :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE image-procedure-petrol W-Win
PROCEDURE image-procedure-pr-fin :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  Пиктограмма наличия просроченных фин.обязательств
  Notes:
-------------------------------------------------------------*/
  do
  on error undo, return error return-value:
     run str/fi-liab1.p (input parparentproc , input 14 , v-cntxt-host-code-obj) .
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */

&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE promosend W-Win
procedure promosend :
define input parameter p-pos-type as character no-undo .
define input parameter p-action as character no-undo .
 run str/diallog.w (
        input parparentproc
      , input this-procedure
      , input "str/promosend.p":U
      , input (p-pos-type + {&delim-par} + v-cntxt-obj-type + {&delim-par} + string(v-cntxt-obj-code) + {&delim-par} + p-action + {&delim-par} + "")
      , input no /*p-auto-go*/
      , input "":U
      , input substitute("Отсылка промоакций на кассы &1", p-pos-type, {&cd-type-IBm-XML})
  ) no-error.
end procedure. /* promosend */
/* _UIB-CODE-BLOCK-END */

&ANALYZE-RESUME
