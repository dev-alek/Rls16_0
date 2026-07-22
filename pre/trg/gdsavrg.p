block-level on error undo, throw.
define input parameter  p-price-type as character no-undo .
define input parameter  p-obj-type   like ub.gds-obj.obj-type   no-undo .
define input parameter  p-obj-code   like ub.gds-obj.obj-code   no-undo .
define input parameter  p-host-code  like ub.gds-obj.host-code no-undo .
define input parameter  p-artic      like ub.gds-obj.artic      no-undo .
define input parameter  p-prod-type  like ub.gds-obj.prod-type  no-undo .
define input parameter  p-prod-code  like ub.gds-obj.prod-code  no-undo .
define output parameter p-price-base like ub.gds-obj.avrg-base no-undo .
define output parameter p-price-rubl like ub.gds-obj.avrg-rubl no-undo .
define output parameter p-tax-road-base like ub.gds-obj.avrg-base no-undo .
define output parameter p-tax-road-rubl like ub.gds-obj.avrg-rubl no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Процедура определения средней учетной цены товара по различным схемам".
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
define buffer buf_goods   for ub.goods .
define buffer buf_gds-obj for ub.gds-obj .
define variable v-total-avrg-base as decimal no-undo .
define variable v-total-avrg-rubl as decimal no-undo .
define variable v-total-avrg-qnty as decimal no-undo .
define variable v-last-in-code  like ub.gds-obj.in-code  no-undo .
define variable v-last-obj-type like ub.gds-obj.obj-type no-undo .
define variable v-last-obj-code like ub.gds-obj.obj-code no-undo .
find first buf_goods no-lock
  where buf_goods.artic     = p-artic
    and buf_goods.prod-type = p-prod-type
    and buf_goods.prod-code = p-prod-code
  no-error .
if not available buf_goods then do:
  message
    vss-workfile vss-revision vss-description skip
    "Не найден товар" skip
    "Артикул" p-artic p-prod-type p-prod-code skip
    view-as alert-box .
  undo, return error .
end.
case p-price-type :
  when 'Учетная':U then do:
    if buf_goods.gds-type = 'т':U then do:
      if p-host-code = 0
      or p-host-code = ? then do:
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output p-host-code
  ) no-error .
        if error-status:error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно найти фирму для объекта " p-obj-type p-obj-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
      assign
        v-total-avrg-base = 0
        v-total-avrg-rubl = 0
        v-total-avrg-qnty = 0
      .
      for each buf_gds-obj no-lock
        where buf_gds-obj.host-code = p-host-code
          and buf_gds-obj.artic     = p-artic
          and buf_gds-obj.prod-type = p-prod-type
          and buf_gds-obj.prod-code = p-prod-code
      on error undo, return error
      :
        if buf_gds-obj.avrg-base > 0 then do:
          assign
            v-total-avrg-base = v-total-avrg-base
                              + (buf_gds-obj.avrg-base * buf_gds-obj.avrg-qnty)
            v-total-avrg-rubl = v-total-avrg-rubl
                              + (buf_gds-obj.avrg-rubl * buf_gds-obj.avrg-qnty)
            v-total-avrg-qnty = v-total-avrg-qnty
                              + buf_gds-obj.avrg-qnty
          .
        end.
      end.
      if v-total-avrg-qnty > 0 then do:
        assign
          p-price-base = v-total-avrg-base / v-total-avrg-qnty
          p-price-rubl = v-total-avrg-rubl / v-total-avrg-qnty
        .
      end.
      else do:
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lastindc in g#library
  (input  p-host-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-last-in-code
  ,output v-last-obj-type
  ,output v-last-obj-code
  )  .
        find first buf_gds-obj no-lock
          where buf_gds-obj.obj-type  = v-last-obj-type
            and buf_gds-obj.obj-code  = v-last-obj-code
            and buf_gds-obj.artic     = p-artic
            and buf_gds-obj.prod-type = p-prod-type
            and buf_gds-obj.prod-code = p-prod-code
          no-error .
        if available buf_gds-obj then do:
          assign
            p-price-base = buf_gds-obj.last-base
            p-price-rubl = buf_gds-obj.last-rubl
          .
        end.
        else do:
              find first buf_gds-obj no-lock
                where buf_gds-obj.obj-type  = p-obj-type
                  and buf_gds-obj.obj-code  = p-obj-code
                  and buf_gds-obj.artic     = p-artic
                  and buf_gds-obj.prod-type = p-prod-type
                  and buf_gds-obj.prod-code = p-prod-code
                no-error .
              if available buf_gds-obj then do:
                assign
                  p-price-base = buf_gds-obj.last-base
                  p-price-rubl = buf_gds-obj.last-rubl
                .
              end.
        end.
      end.
    end.
    else do:
      assign
        p-price-base = ?
        p-price-rubl = ?
      .
    end.
  end.
  when 'Учет-объект':U then do:
    find first buf_gds-obj no-lock
      where buf_gds-obj.obj-type  = p-obj-type
        and buf_gds-obj.obj-code  = p-obj-code
        and buf_gds-obj.artic     = p-artic
        and buf_gds-obj.prod-type = p-prod-type
        and buf_gds-obj.prod-code = p-prod-code
      no-error .
    if available buf_gds-obj then do:
      if buf_goods.gds-type = 'т':U then do:
        if buf_gds-obj.avrg-qnty > 0 then do:
          assign
            p-price-base = buf_gds-obj.avrg-base
            p-price-rubl = buf_gds-obj.avrg-rubl
          .
        end.
        else do:
          assign
            p-price-base = buf_gds-obj.last-base
            p-price-rubl = buf_gds-obj.last-rubl
          .
        end.
      end.
      else do:
        assign
          p-price-base = buf_gds-obj.price-base
          p-price-rubl = buf_gds-obj.price-rubl
        .
      end.
    end.
  end.
  when 'Учет-резерв':U then do:
    if buf_goods.gds-type = 'т':U then do:
      define buffer buf_parts for ub.parts .
      for each buf_parts no-lock
        where buf_parts.obj-type  = p-obj-type
          and buf_parts.obj-code  = p-obj-code
          and buf_parts.artic     = p-artic
          and buf_parts.prod-type = p-prod-type
          and buf_parts.prod-code = p-prod-code
          and buf_parts.status_   = no
          and buf_parts.out-code  = 'free-zone':U
          and buf_parts.qnty      > 0
      on error undo, return error
      :
          assign
          v-total-avrg-base = v-total-avrg-base
                            + (buf_parts.price-base * buf_parts.qnty)
          v-total-avrg-rubl = v-total-avrg-rubl
                            + (buf_parts.price-rubl * buf_parts.qnty)
          v-total-avrg-qnty = v-total-avrg-qnty
                            + buf_parts.qnty
        .
      end.
      if v-total-avrg-qnty > 0 then do:
        assign
          p-price-base = v-total-avrg-base / v-total-avrg-qnty
          p-price-rubl = v-total-avrg-rubl / v-total-avrg-qnty
        .
      end.
      else do:
        find first buf_gds-obj no-lock
          where buf_gds-obj.obj-type  = p-obj-type
            and buf_gds-obj.obj-code  = p-obj-code
            and buf_gds-obj.artic     = p-artic
            and buf_gds-obj.prod-type = p-prod-type
            and buf_gds-obj.prod-code = p-prod-code
          no-error .
        if available buf_gds-obj then do:
          assign
            p-price-base = buf_gds-obj.last-base
            p-price-rubl = buf_gds-obj.last-rubl
          .
        end.
      end.
    end.
    else do:
      find first buf_gds-obj no-lock
        where buf_gds-obj.obj-type  = p-obj-type
          and buf_gds-obj.obj-code  = p-obj-code
          and buf_gds-obj.artic     = p-artic
          and buf_gds-obj.prod-type = p-prod-type
          and buf_gds-obj.prod-code = p-prod-code
        no-error .
      if available buf_gds-obj then do:
        assign
          p-price-base = buf_gds-obj.price-base
          p-price-rubl = buf_gds-obj.price-rubl
        .
      end.
      else do:
        assign
          p-price-base = ?
          p-price-rubl = ?
        .
      end.
    end.
  end.
  when 'Приходная':U then do:
    if buf_goods.gds-type = 'т':U then do:
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lastindc in g#library
  (input  p-host-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-last-in-code
  ,output v-last-obj-type
  ,output v-last-obj-code
  )  .
      find first buf_gds-obj no-lock
        where buf_gds-obj.obj-type  = v-last-obj-type
          and buf_gds-obj.obj-code  = v-last-obj-code
          and buf_gds-obj.artic     = p-artic
          and buf_gds-obj.prod-type = p-prod-type
          and buf_gds-obj.prod-code = p-prod-code
        no-error .
      if available buf_gds-obj then do:
        assign
          p-price-base = buf_gds-obj.last-base
          p-price-rubl = buf_gds-obj.last-rubl
        .
      end.
    end.
  end.
  when 'Прих-объект':U then do:
    if buf_goods.gds-type = 'т':U then do:
      find first buf_gds-obj no-lock
        where buf_gds-obj.obj-type  = p-obj-type
          and buf_gds-obj.obj-code  = p-obj-code
          and buf_gds-obj.artic     = p-artic
          and buf_gds-obj.prod-type = p-prod-type
          and buf_gds-obj.prod-code = p-prod-code
        no-error .
      if available buf_gds-obj then do:
        assign
          p-price-base = buf_gds-obj.last-base
          p-price-rubl = buf_gds-obj.last-rubl
        .
      end.
      else do:
        assign
          p-price-base = ?
          p-price-rubl = ?
        .
      end.
    end.
    else do:
      assign
        p-price-base = ?
        p-price-rubl = ?
      .
    end.
  end.
  otherwise do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Недопустимое значение аргумента p-price-type" p-price-type skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      view-as alert-box error .
    undo, return error .
  end.
end case.
if p-price-base = 0 then do:
  assign
    p-price-base = ?
  .
end.
if p-price-rubl = 0 then do:
  assign
    p-price-rubl = ?
  .
end.
if (p-price-base = ?) <> (p-price-rubl = ?) then do:
  message
    vss-workfile vss-revision vss-description skip
    "Учетная цена в одной из валют не задана" skip
    "p-price-base" p-price-base skip
    "p-price-rubl" p-price-rubl skip
    view-as alert-box error .
  undo, return error .
end.
