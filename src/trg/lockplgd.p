block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Блокировка и разблокировка товаров на складских местах

Автор: Уханов Дмитрий Юрьевич
Дата создания: 12/17/07
Author: Dmitry Ukhanov
Creation date: 12/17/07

Автор1: Перваков Михаил Сергеевич
Дата создания1: 11/10/00

Параметры:
p-obj-type - объект
p-obj-code
p-pl-code   - складское место
p-gds-code  - код товара
p-action    - действие, которое необходимо выполнить
  Возможные значения:
  assign-rvs-on=true   установить блокировку на pl-gds
  assign-rvs-on=false  снять блокировку c pl-gds
  check-rvs-on=true    проверить, что pl-gds заблокирован
  check-rvs-on=false   проверить, что pl-gds не заблокирован
p-no-check-rvs-code - сверка, которая может находится в статусе разрешен,
                      при разблокировке товаров

*/

define input parameter p-obj-type          like ub.pl-gds.obj-type no-undo .
define input parameter p-obj-code          like ub.pl-gds.obj-code no-undo .
define input parameter p-pl-code           like ub.pl-gds.pl-code  no-undo .
define input parameter p-gds-code          like ub.pl-gds.pl-code  no-undo .
define input parameter p-action            as   character          no-undo .
define input parameter p-no-check-rvs-code as   character          no-undo .
define input parameter p-is-berate         as   logical            no-undo .

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Блокировка и разблокировка товаров на складских местах":U .

{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/library.i }

define buffer buf_goods    for ub.goods .
define buffer buf_pl-gds   for ub.pl-gds .
define buffer buf_gds-obj  for ub.gds-obj .
define buffer buf_rvs-doc  for ub.rvs-doc .
define buffer buf_rvs-line for ub.rvs-line .

define variable v-check-rvs-code as character no-undo .
define variable ii as integer no-undo .

main-block :
do transaction
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if lookup( p-action
    , "assign-rvs-on=true":U  + ",":U
    + "assign-rvs-on=false":U + ",":U
    + "check-rvs-on=true":U   + ",":U
    + "check-rvs-on=false":U ) = 0
  then do:
    if p-is-berate = yes then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестное значение p-action" skip
        "p-action" p-action skip
      view-as alert-box error .
    end.
    undo main-block, return error substitute( '&1: ошибка задания входного параметра p-action (неизвестное значение) "&2"',
                                              vss-workfile,
                                              p-action ) .
  end.

  find first buf_goods no-lock
    where buf_goods.gds-code = p-gds-code
    no-error .
  if not available buf_goods then do:
    if p-is-berate = yes then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Код товара" p-gds-code skip
      view-as alert-box error .
    end.
    undo main-block, return error substitute( '&1: ошибка задания входного параметра "Код товара": &2',
                                              vss-workfile,
                                              p-gds-code ) .
  end.

  find first buf_pl-gds no-lock
    where buf_pl-gds.obj-type = p-obj-type
      and buf_pl-gds.obj-code = p-obj-code
      and buf_pl-gds.pl-code  = p-pl-code
      and buf_pl-gds.gds-code = p-gds-code
    no-error .
  if not available buf_pl-gds then do:
    if p-is-berate = yes then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Объект" p-obj-type p-obj-code skip
        "Складское место" p-pl-code skip
        "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
        "Код товара" p-gds-code skip
      view-as alert-box error .
    end.
    undo main-block, return error substitute( '&1: ошибка задания входных параметров.&2' +
                                              'Объект &3 &4&2Складское место&5&2Код товара&6',
                                              vss-workfile,
                                              {&new-line},
                                              p-obj-type,
                                              p-obj-code,
                                              p-pl-code,
                                              p-gds-code ) .
  end.

  /* блокируем товар на объекте */
  { gbl/gdsobjcr.i
    p-obj-type
    p-obj-code
    buf_goods.artic
    buf_goods.prod-type
    buf_goods.prod-code
    buf_gds-obj
    no-error
  }
  if error-status :error then do:
    if p-is-berate = yes then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при поиске товара на объекте" skip
        "obj-type"  p-obj-type skip
        "obj-code"  p-obj-code skip
        "artic"     buf_goods.artic skip
        "prod-type" buf_goods.prod-type skip
        "prod-code" buf_goods.prod-code skip
        error-status :get-message(1) skip
        return-value skip
      view-as alert-box error .
    end.
    undo main-block, return error substitute( '&1: ошибка при поиске товара на объекте.&2' +
                                              'Объект &3 &4&2Код товара&5&2&6&2&7',
                                              vss-workfile,
                                              {&new-line},
                                              p-obj-type,
                                              p-obj-code,
                                              p-gds-code,
                                              error-status :get-message( 1 ),
                                              return-value ) .
  end.

  /* блокируем товар на объекте */
  find current buf_gds-obj exclusive-lock .
  release buf_gds-obj .

  find current buf_pl-gds exclusive-lock .

  if buf_pl-gds.rvs-on = ? then do:
    if p-is-berate = yes then do:
      message
        vss-workfile vss-revision vss-description skip
        "Объект на месте хранения имеет неопределенный статус" skip
        "Объект" p-obj-type p-obj-code skip
        "Место хранения" p-pl-code skip
        "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
        "buf_pl-gds.rvs-on" buf_pl-gds.rvs-on skip
      view-as alert-box error .
    end.
    undo main-block, return error substitute( '&1: бъект на месте хранения имеет неопределенный статус.&2' +
                                              'Объект &3 &4&2Место хранения &5&2Код товара&6',
                                              vss-workfile,
                                              {&new-line},
                                              p-obj-type,
                                              p-obj-code,
                                              p-pl-code,
                                              p-gds-code ) .
  end.


  /* производим действие, запрошенное пользователем */
  case p-action :
    when "assign-rvs-on=true" then do:
      if buf_pl-gds.rvs-on = false then do:
        do
        on error undo main-block, return error
        :
          assign
            buf_pl-gds.rvs-on = true
          .
        end.
      end.
      else if not g#news then do:
        for each buf_rvs-doc no-lock
          where buf_rvs-doc.obj-type = buf_pl-gds.obj-type
            and buf_rvs-doc.obj-code = buf_pl-gds.obj-code
            and ( buf_rvs-doc.status_  = {&permitted}
                  or buf_rvs-doc.status_ = {&rvs-froze}
                )
        on error undo main-block, return error
        :
          if lookup( buf_rvs-doc.rvs-code, p-no-check-rvs-code ) > 0
          or buf_rvs-doc.rvs-type = {&test-asi}
          then do:
            next.
          end.
          for each buf_rvs-line no-lock
            where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
              and buf_rvs-line.obj-type = buf_pl-gds.obj-type
              and buf_rvs-line.obj-code = buf_pl-gds.obj-code
              and buf_rvs-line.pl-code  = buf_pl-gds.pl-code
              and buf_rvs-line.gds-code = buf_pl-gds.gds-code
          on error undo main-block, return error
          :
            if p-is-berate = yes then do:
              message
                "Невозможно заблокировать товар на месте хранения" skip
                "Товар уже является заблокированным" skip
                "Объект" p-obj-type p-obj-code skip
                "Место хранения" p-pl-code skip
                "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
                "Существует сверка" buf_rvs-doc.rvs-code skip
                "Статус сверки" buf_rvs-doc.status_ skip
              view-as alert-box information .
            end.
            undo main-block, return error substitute( 'Невозможно заблокировать товар на месте хранения.&1' +
                                                      'Товар уже является заблокированным.&1' +
                                                      'Объект &2 &3&1Место хранения &4&1Код товара&5&1' +
                                                      'Существует сверка &6 (статус "&7")',
                                                      {&new-line},
                                                      p-obj-type,
                                                      p-obj-code,
                                                      p-pl-code,
                                                      p-gds-code,
                                                      buf_rvs-doc.rvs-code,
                                                      buf_rvs-doc.status_ ) .
          end.
        end.
        if not g#auto or not g#news then do:  /* автосверки и новости не должны вставать  */
            if p-is-berate = yes then do:
              message
                vss-workfile vss-revision vss-description skip
                "Невозможно заблокировать товар на месте хранения" skip
                "Товар уже является заблокированным" skip
                "Объект" p-obj-type p-obj-code skip
                "Место хранения" p-pl-code skip
                "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
              view-as alert-box error .
            end.
            undo main-block, return error substitute( 'Невозможно заблокировать товар на месте хранения.&1' +
                                                      'Товар уже является заблокированным.&1' +
                                                      'Объект &2 &3&1Место хранения &4&1Код товара&5&1',
                                                      {&new-line},
                                                      p-obj-type,
                                                      p-obj-code,
                                                      p-pl-code,
                                                      p-gds-code ) .
        end.                                          
      end.
    end.
    when "assign-rvs-on=false" then do:
      if buf_pl-gds.rvs-on = true then do:
        /* проверяем, что не существует документов сверки */
        /* в статусах {&permitted}, {&rvs-froze} */
        if not g#news
        then do :
        rvs-docs_ :
          for each buf_rvs-doc no-lock
            where buf_rvs-doc.obj-type = buf_pl-gds.obj-type
              and buf_rvs-doc.obj-code = buf_pl-gds.obj-code
              and ( buf_rvs-doc.status_  = {&permitted}
                    or buf_rvs-doc.status_ = {&rvs-froze}
                  )
          on error undo main-block, return error
          :
            if lookup( buf_rvs-doc.rvs-code, p-no-check-rvs-code ) > 0
            or buf_rvs-doc.rvs-type = {&test-asi}
            then do:
              next rvs-docs_ .
            end.
            do ii = 1 to num-entries(p-no-check-rvs-code) :
              v-check-rvs-code = entry(ii, p-no-check-rvs-code) .
              if (num-entries(v-check-rvs-code, "-") = 3 and entry(1, v-check-rvs-code, "-") = entry(1, buf_rvs-doc.rvs-code, "-"))
              then do :
                next rvs-docs_ .
              end .
            end .
            for each buf_rvs-line no-lock
              where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                and buf_rvs-line.obj-type = buf_pl-gds.obj-type
                and buf_rvs-line.obj-code = buf_pl-gds.obj-code
                and buf_rvs-line.pl-code  = buf_pl-gds.pl-code
                and buf_rvs-line.gds-code = buf_pl-gds.gds-code
            on error undo main-block, return error
            :
              if p-is-berate = yes then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Невозможно снять блокировку на товар на месте хранения" skip
                  "Объект" p-obj-type p-obj-code skip
                  "Место хранения" p-pl-code skip
                  "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
                  "Существует сверка" buf_rvs-doc.rvs-code skip
                  "Статус сверки" buf_rvs-doc.status_ skip
                view-as alert-box information .
              end.
              undo main-block, return error substitute( 'Невозможно снять блокировку на товар на месте хранения.&1' +
                                                        'Объект &2 &3&1Место хранения &4&1Код товара&5&1' +
                                                        'Существует сверка &6 (статус "&7")',
                                                        {&new-line},
                                                        p-obj-type,
                                                        p-obj-code,
                                                        p-pl-code,
                                                        p-gds-code,
                                                        buf_rvs-doc.rvs-code,
                                                        buf_rvs-doc.status_ ) .
            end.
          end.
        end .
        do
        on error undo main-block, return error
        :
          assign
            buf_pl-gds.rvs-on = false
          .
        end.
      end.
      else do:
        if not g#auto or not g#news then do:  /* автосверки и новости не должны вставать  */  
            if p-is-berate = yes then do:
              message
                vss-workfile vss-revision vss-description skip
                "Невозможно разблокировать товар на месте хранения" skip
                "Товар не является заблокированным" skip
                "Объект" p-obj-type p-obj-code skip
                "Место хранения" p-pl-code skip
                "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
              view-as alert-box error .
            end.
            undo main-block, return error substitute( 'Невозможно снять блокировку на товар на месте хранения.&1' +
                                                      'Товар не является заблокированным.&1' +
                                                      'Объект &2 &3&1Место хранения &4&1Код товара&5&1',
                                                      {&new-line},
                                                      p-obj-type,
                                                      p-obj-code,
                                                      p-pl-code,
                                                      p-gds-code ) .
                                                  
       end.
      end.
    end.
    when "check-rvs-on=true" then do:
      if buf_pl-gds.rvs-on = true then do:
        if p-no-check-rvs-code <> "":U then do:
          /* проверяем, что заблокировано именно для этих (p-no-check-rvs-code) документов сверки */
          for each buf_rvs-doc no-lock
            where buf_rvs-doc.obj-type = buf_pl-gds.obj-type
              and buf_rvs-doc.obj-code = buf_pl-gds.obj-code
              and ( buf_rvs-doc.status_  = {&permitted}
                    or buf_rvs-doc.status_ = {&rvs-froze}
                  )
          on error undo main-block, return error
          :
            if lookup( buf_rvs-doc.rvs-code, p-no-check-rvs-code ) > 0
            or buf_rvs-doc.rvs-type = {&test-asi}
            then do:
              next.
            end.
            for each buf_rvs-line no-lock
              where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                and buf_rvs-line.obj-type = buf_pl-gds.obj-type
                and buf_rvs-line.obj-code = buf_pl-gds.obj-code
                and buf_rvs-line.pl-code  = buf_pl-gds.pl-code
                and buf_rvs-line.gds-code = buf_pl-gds.gds-code
            on error undo main-block, return error
            :
              if p-is-berate = yes then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Блокировка на товар на месте хранения установлена для другого документа сверки" skip
                  "Объект" p-obj-type p-obj-code skip
                  "Место хранения" p-pl-code skip
                  "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
                  "Сверка" buf_rvs-doc.rvs-code skip
                  "Статус сверки" buf_rvs-doc.status_ skip
                view-as alert-box information .
              end.
              undo main-block, return error substitute( 'Блокировка на товар на месте хранения установлена для другого документа сверки.&1' +
                                                        'Объект &2 &3&1Место хранения &4&1Код товара&5&1' +
                                                        'Сверка &6 (статус "&7")',
                                                        {&new-line},
                                                        p-obj-type,
                                                        p-obj-code,
                                                        p-pl-code,
                                                        p-gds-code,
                                                        buf_rvs-doc.rvs-code,
                                                        buf_rvs-doc.status_ ) .
            end.
          end.
        end.
      end.
      else do: /* buf_pl-gds.rvs-on <> true */
        if p-is-berate = yes then do:
          message
            vss-workfile vss-revision vss-description skip
            "Товар на месте хранения не является заблокированным" skip
            "Объект" p-obj-type p-obj-code skip
            "Место хранения" p-pl-code skip
            "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
          view-as alert-box information .
        end.
        undo main-block, return error substitute( 'Товар на месте хранения не является заблокированным.&1' +
                                                  'Объект &2 &3&1Место хранения &4&1Код товара&5',
                                                  {&new-line},
                                                  p-obj-type,
                                                  p-obj-code,
                                                  p-pl-code,
                                                  p-gds-code ) .
      end.
    end.
    when "check-rvs-on=false" then do:
      if buf_pl-gds.rvs-on = true then do:
        for each buf_rvs-doc no-lock
          where buf_rvs-doc.obj-type = buf_pl-gds.obj-type
            and buf_rvs-doc.obj-code = buf_pl-gds.obj-code
            and ( buf_rvs-doc.status_  = {&permitted}
                  or buf_rvs-doc.status_ = {&rvs-froze}
                )
        on error undo main-block, return error
        :
          if buf_rvs-doc.rvs-type = {&test-asi} then next .
          
          for each buf_rvs-line no-lock
            where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
              and buf_rvs-line.obj-type = buf_pl-gds.obj-type
              and buf_rvs-line.obj-code = buf_pl-gds.obj-code
              and buf_rvs-line.pl-code  = buf_pl-gds.pl-code
              and buf_rvs-line.gds-code = buf_pl-gds.gds-code
          on error undo main-block, return error
          :
            if p-no-check-rvs-code <> "":U
              and lookup( buf_rvs-doc.rvs-code, p-no-check-rvs-code ) > 0
            then do:
              /* проверяем, что заблокировано именно для этих (p-no-check-rvs-code) документов сверки */
              next.
            end.
            if p-is-berate = yes then do:
              message
                vss-workfile vss-revision vss-description skip
                "Товар на месте хранения является заблокированным" skip
                "Объект" p-obj-type p-obj-code skip
                "Место хранения" p-pl-code skip
                "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
                "Сверка" buf_rvs-doc.rvs-code skip
                "Статус сверки" buf_rvs-doc.status_ skip
              view-as alert-box information .
            end.
            undo main-block, return error substitute( 'Товар на месте хранения является заблокированным.&1' +
                                                      'Объект &2 &3&1Место хранения &4&1Код товара&5&1' +
                                                      'Сверка &6 (статус "&7")',
                                                      {&new-line},
                                                      p-obj-type,
                                                      p-obj-code,
                                                      p-pl-code,
                                                      p-gds-code,
                                                      buf_rvs-doc.rvs-code,
                                                      buf_rvs-doc.status_ ) .
          end.
        end.
      end.
    end.
    otherwise do:
      if p-is-berate = yes then do:
        message
          vss-workfile vss-revision vss-description skip
          "Внутрення ошибка" skip
          "Неизвестное значение p-action" skip
          "p-action" p-action skip
        view-as alert-box error .
      end.
      undo main-block, return error substitute( '&1: Внутрення ошибка.&2' +
                                                'Неизвестное значение параметра p-action "&3"',
                                                vss-workfile,
                                                {&new-line},
                                                p-action ) .
    end.
  end case .
  release buf_pl-gds .
end. /* main-block */