block-level on error undo, throw.
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define buffer buf_goods    for ub.goods .
define buffer buf_pl-gds   for ub.pl-gds .
define buffer buf_gds-obj  for ub.gds-obj .
define buffer buf_rvs-doc  for ub.rvs-doc .
define buffer buf_rvs-line for ub.rvs-line .
define variable v-check-rvs-code as character no-undo .
define variable ii as integer no-undo .
main-block :
do transaction
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
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
                                              chr(10),
                                              p-obj-type,
                                              p-obj-code,
                                              p-pl-code,
                                              p-gds-code ) .
  end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,buffer buf_gds-obj
  ) no-error .
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
                                              chr(10),
                                              p-obj-type,
                                              p-obj-code,
                                              p-gds-code,
                                              error-status :get-message( 1 ),
                                              return-value ) .
  end.
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
                                              chr(10),
                                              p-obj-type,
                                              p-obj-code,
                                              p-pl-code,
                                              p-gds-code ) .
  end.
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
            and ( buf_rvs-doc.status_  = 'разрешен':U
                  or buf_rvs-doc.status_ = 'нередакт':U
                )
        on error undo main-block, return error
        :
          if lookup( buf_rvs-doc.rvs-code, p-no-check-rvs-code ) > 0
          or buf_rvs-doc.rvs-type = 'проверка':U
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
                                                      chr(10),
                                                      p-obj-type,
                                                      p-obj-code,
                                                      p-pl-code,
                                                      p-gds-code,
                                                      buf_rvs-doc.rvs-code,
                                                      buf_rvs-doc.status_ ) .
          end.
        end.
        if not g#auto or not g#news then do:
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
                                                      chr(10),
                                                      p-obj-type,
                                                      p-obj-code,
                                                      p-pl-code,
                                                      p-gds-code ) .
        end.
      end.
    end.
    when "assign-rvs-on=false" then do:
      if buf_pl-gds.rvs-on = true then do:
        if not g#news
        then do :
        rvs-docs_ :
          for each buf_rvs-doc no-lock
            where buf_rvs-doc.obj-type = buf_pl-gds.obj-type
              and buf_rvs-doc.obj-code = buf_pl-gds.obj-code
              and ( buf_rvs-doc.status_  = 'разрешен':U
                    or buf_rvs-doc.status_ = 'нередакт':U
                  )
          on error undo main-block, return error
          :
            if lookup( buf_rvs-doc.rvs-code, p-no-check-rvs-code ) > 0
            or buf_rvs-doc.rvs-type = 'проверка':U
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
                                                        chr(10),
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
        if not g#auto or not g#news then do:
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
                                                      chr(10),
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
          for each buf_rvs-doc no-lock
            where buf_rvs-doc.obj-type = buf_pl-gds.obj-type
              and buf_rvs-doc.obj-code = buf_pl-gds.obj-code
              and ( buf_rvs-doc.status_  = 'разрешен':U
                    or buf_rvs-doc.status_ = 'нередакт':U
                  )
          on error undo main-block, return error
          :
            if lookup( buf_rvs-doc.rvs-code, p-no-check-rvs-code ) > 0
            or buf_rvs-doc.rvs-type = 'проверка':U
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
                                                        chr(10),
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
      else do:
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
                                                  chr(10),
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
            and ( buf_rvs-doc.status_  = 'разрешен':U
                  or buf_rvs-doc.status_ = 'нередакт':U
                )
        on error undo main-block, return error
        :
          if buf_rvs-doc.rvs-type = 'проверка':U then next .
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
                                                      chr(10),
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
                                                chr(10),
                                                p-action ) .
    end.
  end case .
  release buf_pl-gds .
end.
