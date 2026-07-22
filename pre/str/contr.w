def var vss-revision    as character no-undo init "$Revision$":u .
def var vss-author      as character no-undo init "$Author$":u .
def var vss-date        as character no-undo init "$Date$":u .
def var vss-workfile    as character no-undo init "$Workfile$":u .
def var vss-archive     as character no-undo init "$Archive$":u .
def var vss-description as character no-undo init "Карточка договора" .
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
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-b-code :
  define input  parameter type-code like ub.code-range.range-type no-undo .
  define output parameter p-b-code  like ub.bar-code.b-code       no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-b-code). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (gen-b-code). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-b-code). endkey", vss-workfile )
  :
    define buffer buf_thbj-attr     for ub.thbj-attr .
    define buffer buf_sys-ctrl   for ub.sys-ctrl .
    define buffer buf_code-range for ub.code-range .
    define variable l-code         as   integer              no-undo .
    define variable v-db-num       like ub.db.db-num         no-undo .
    define variable cfg-param-code like ub.thbj-attr.prop-code no-undo .
    if type-code = 'sslc':U
    or type-code = 'ssgb':U
    then do:
      message
        "Нельзя генерировать локальный или глобальный взвешиваемый код." skip
        "Обратитесь к администратору системы."
        view-as alert-box error .
      undo, return error (if type-code = 'sslc':U then "loc-ss-code":U else "gbl-ss-code" ) .
    end.
    run trg/getpcode.p ( input  type-code
                   ,output cfg-param-code
                  ).
    run get-next-seq( input  type-code,
                      output l-code
                    ).
    find first buf_sys-ctrl no-lock.
    if type-code = 'sclc':U
    or type-code = 'pglc':U
    then do:
      assign
        v-db-num = 0
      .
    end.
    else do:
      assign
        v-db-num = buf_sys-ctrl.db-num
      .
    end.
    find first buf_code-range no-lock
      where buf_code-range.db-num     = v-db-num
        and buf_code-range.range-type = type-code
        and buf_code-range.stts       = "a"
      use-index stts
      no-error .
    if available buf_code-range
       and l-code <= buf_code-range.last-code
       and l-code >= buf_code-range.first-code then do:
      assign
        p-b-code = l-code
      .
    end.
    else do:
      if available buf_code-range
         and l-code < buf_code-range.last-code then do:
        message
          substitute( "Последовательность для создания кодов с типом &1 имеет неверное значение.", type-code ) skip
          "Обратитесь к администратору системы."
          view-as alert-box error .
        undo, return error "sequence":U .
      end.
      do transaction
      on error undo, return error
      :
        find first buf_thbj-attr exclusive-lock
          where buf_thbj-attr.upper-prop-code = 'code-range':U
            and buf_thbj-attr.prop-code = cfg-param-code
            and buf_thbj-attr.obj-type   = 'БД':U
            and buf_thbj-attr.obj-code   = v-db-num
          no-error .
        if not available buf_thbj-attr then do:
          find first buf_thbj-attr exclusive-lock
            where buf_thbj-attr.upper-prop-code = 'code-range':U
              and buf_thbj-attr.prop-code = cfg-param-code
              and buf_thbj-attr.obj-type   = ''
              and buf_thbj-attr.obj-code   = 0
            no-error .
          if not available buf_thbj-attr then do:
            if not locked buf_thbj-attr then do:
              message
                substitute( "Отсутствует параметр 'длина диапазона кодов' (&1) для БД &2.", cfg-param-code, buf_sys-ctrl.db-num ) skip
                "Обратитесь к администратору системы."
                view-as alert-box error .
            end.
            undo, return error "config":U .
          end.
        end.
        run get-next-seq( input type-code,
                          output l-code
                        ).
        find first buf_code-range
          where buf_code-range.db-num     = v-db-num
            and buf_code-range.range-type = type-code
            and buf_code-range.stts       = "a"
          use-index stts
          no-error .
        if available buf_code-range
        and l-code <= buf_code-range.last-code
        and l-code >= buf_code-range.first-code
        then do:
          assign
            p-b-code = l-code
          .
        end.
        else do:
          if available buf_code-range then do:
            assign
              buf_code-range.stts = "u"
            .
          end.
          find first buf_code-range
            where buf_code-range.db-num     = v-db-num
              and buf_code-range.range-type = type-code
              and buf_code-range.stts       = "f"
            use-index stts
            no-error .
          if not available buf_code-range then do:
            message
              substitute( "Отсутствует свободный диапазон для кодов с типом &1.", type-code ) skip
              "Обратитесь к администратору системы"
              view-as alert-box error .
            undo, return error "code-range":U .
          end.
          assign
            buf_code-range.stts           = "a"
          .
          if buf_code-range.first-code = 1 then do:
            run set-seq-cr( input type-code,
                            input buf_code-range.first-code
                          ).
            assign
              p-b-code = 1
            .
          end.
          else do:
            run set-seq-cr( input type-code,
                            input ( buf_code-range.first-code - 1 )
                          ).
            run get-next-seq( input type-code,
                              output p-b-code
                            ).
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure get-next-seq :
  define input  parameter type-code like ub.code-range.range-type no-undo .
  define output parameter next-seq  as   integer                  no-undo .
  do
  on error  undo, return error substitute( "&1 (get-next-seq). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (get-next-seq). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (get-next-seq). endkey", vss-workfile )
  :
    case type-code:
      when 'bcgb':U then do:
        assign
          next-seq = next-value(s-bcgb-code, ub)
        .
      end.
      when 'scgb':U then do:
        assign
          next-seq = next-value(s-scgb-code, ub)
        .
      end.
      when 'sclc':U then do:
        assign
          next-seq = next-value(s-sclc-code, ub)
        .
      end.
      when 'pglc':U then do:
        assign
          next-seq = next-value(s-pglc-code, ub)
        .
      end.
      when 'dcgb':U then do:
        assign
          next-seq = next-value(s-dcgb-code, ub)
        .
      end.
      when 'ctgb':U then do:
        assign
          next-seq = next-value(s-ctgb-code, ub)
        .
      end.
      when 'drgb':U then do:
        assign
          next-seq = next-value(s-drgb-code, ub)
        .
      end.
      when 'fmgb':U then do:
        assign
          next-seq = next-value(s-fmgb-code, ub)
        .
      end.
      when 'pngb':U then do:
        assign
          next-seq = next-value(s-pngb-code, ub)
        .
      end.
      when 'cagb':U then do:
        assign
          next-seq = next-value(s-cagb-code, ub)
        .
      end.
      when 'fdgb':U then do:
        assign
          next-seq = next-value(s-fin-doc, ub)
        .
      end.
    end case.
  end.
end procedure.
procedure set-seq-cr :
  define input parameter type-code like ub.code-range.range-type no-undo .
  define input parameter set-val   like ub.code-range.first-code no-undo .
  do
  on error  undo, return error substitute( "&1 (set-seq-cr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (set-seq-cr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (set-seq-cr). endkey", vss-workfile )
  :
    case type-code:
      when 'bcgb':U then do:
        assign
          current-value(s-bcgb-code, ub) = set-val
        .
      end.
      when 'scgb':U then do:
        assign
          current-value(s-scgb-code, ub) = set-val
        .
      end.
      when 'sclc':U then do:
        assign
          current-value(s-sclc-code, ub) = set-val
        .
      end.
      when 'pglc':U then do:
        assign
          current-value(s-pglc-code, ub) = set-val
        .
      end.
      when 'dcgb':U then do:
        assign
          current-value(s-dcgb-code, ub) = set-val
        .
      end.
      when 'ctgb':U then do:
        assign
          current-value(s-ctgb-code, ub) = set-val
        .
      end.
      when 'drgb':U then do:
        assign
          current-value(s-drgb-code, ub) = set-val
        .
      end.
      when 'fmgb':U then do:
        assign
          current-value(s-fmgb-code, ub) = set-val
        .
      end.
      when 'pngb':U then do:
        assign
          current-value(s-pngb-code, ub) = set-val
        .
      end.
      when 'cagb':U then do:
        assign
          current-value(s-cagb-code, ub) = set-val
        .
      end.
      when 'fdgb':U then do:
        assign
          current-value(s-fin-doc, ub) = set-val
        .
      end.
    end case.
  end.
end procedure.
procedure new-bcod-gen-code-range :
  do
  on error  undo, return error substitute( "&1 (new-bcod-gen-code-range). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (new-bcod-gen-code-range). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (new-bcod-gen-code-range). endkey", vss-workfile )
  :
    define input parameter p-db-num  like ub.db.db-num             no-undo .
    define input parameter type-code like ub.code-range.range-type no-undo .
    define buffer buf_code-range      for ub.code-range .
    define buffer last_code-range     for ub.code-range .
    define buffer last-1_code-range   for ub.code-range .
    define buffer last-2_code-range   for ub.code-range .
    define buffer last-3_code-range   for ub.code-range .
    define buffer buf_sys-ctrl        for ub.sys-ctrl .
    define variable conf-par       as character no-undo .
    define variable par-type       as character no-undo .
    define variable cfg-param-code like ub.thbj-attr.prop-code no-undo .
    define variable v-cre-cdrg as logical   no-undo .
    define variable v-cre-str  as character no-undo .
    define variable v-cr1      as integer no-undo .
    define variable v-cr2      as integer no-undo .
    define variable v-cr3      as integer no-undo .
    define variable v-cmax     as integer no-undo .
    find first buf_sys-ctrl no-lock .
    if buf_sys-ctrl.db-num <> 0 and type-code <> 'cagb':U then do:
      undo, return error substitute("&1 &2 &3&4Диапазоны кодов можно создавать только в ГБД&4База данных &5"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,chr(10)
                                    , p-db-num
                                   ).
    end.
    run trg/getpcode.p ( input  type-code
                   ,output cfg-param-code
                  ).
    for each buf_code-range
      where buf_code-range.db-num     = -1
        and buf_code-range.range-type = type-code
        and buf_code-range.stts       = "f"
    by buf_code-range.first-code
    on error  undo, return error substitute( "&1 (new-bcod-gen-code-range). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    on stop   undo, return error substitute( "&1 (new-bcod-gen-code-range). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (new-bcod-gen-code-range). endkey", vss-workfile )
    :
      assign
        buf_code-range.db-num = p-db-num
      .
      return .
    end.
    assign
      v-cre-cdrg = TRUE
    .
    case type-code:
      when 'sclc':U
      or when 'scgb':U
      or when 'pglc':U
      then do:
        find last last-1_code-range no-lock
          where last-1_code-range.range-type = 'sclc':U
          no-error .
        if available last-1_code-range then do:
          v-cr1 = last-1_code-range.last-code.
        end.
        find last last-2_code-range no-lock
          where last-2_code-range.range-type = 'scgb':U
          no-error .
        if available last-2_code-range then do:
          v-cr2 = last-2_code-range.last-code.
          end.
        find last last-3_code-range no-lock
          where last-3_code-range.range-type = 'pglc':U
          no-error .
        if available last-3_code-range then do:
          v-cr3 = last-3_code-range.last-code.
        end.
        v-cmax = maximum(v-cr1, v-cr2, v-cr3)
        .
        if v-cmax = v-cr1  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-1_code-range )
              .
          end.
        if v-cmax = v-cr2  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-2_code-range )
              .
          end.
        if v-cmax = v-cr3  then do:
          find last last_code-range no-lock
            where recid( last_code-range ) = recid( last-3_code-range )
            .
        end.
        if last_code-range.last-code + 1 > 99999 then do:
          assign
            v-cre-cdrg = FALSE
          .
        end.
      end.
      when 'bcgb':U
      or when 'sslc':U
      or when 'ssgb':U
      then do:
        find last last-1_code-range no-lock
          where last-1_code-range.range-type = 'sslc':U
          no-error .
        if available last-1_code-range then do:
          v-cr1 = last-1_code-range.last-code.
        end.
        find last last-2_code-range no-lock
          where last-2_code-range.range-type = 'bcgb':U
          no-error .
        if available last-2_code-range then do:
          v-cr2 = last-2_code-range.last-code.
          end.
        find last last-3_code-range no-lock
          where last-3_code-range.range-type = 'ssgb':U
          no-error .
        if available last-3_code-range then do:
          v-cr3 = last-3_code-range.last-code.
        end.
        v-cmax = maximum(v-cr1, v-cr2, v-cr3)
        .
        if v-cmax = v-cr1  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-1_code-range )
              .
          end.
        if v-cmax = v-cr2  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-2_code-range )
              .
          end.
        if v-cmax = v-cr3  then do:
          find last last_code-range no-lock
            where recid( last_code-range ) = recid( last-3_code-range )
            .
        end.
      end.
      otherwise do:
        find last last_code-range no-lock
          where last_code-range.range-type = type-code
          no-error .
      end.
    end case.
    if not available last_code-range then do:
      undo, return error substitute("&1 &2 &3&4В БД нет ни одного диапазона с типом &5&4Не была проведена инициализация диапазонов!"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    , chr(10)
                                    , type-code
                                   ) .
    end.
    define variable v-mes0 as character no-undo .
    define variable v-param-type0 as character no-undo .
    define variable v-value-character0 as INTEGER no-undo .
    define variable v-value-date0 as date no-undo .
    define variable v-value-decimal0 as decimal no-undo .
    define variable v-value-integer0 AS integer no-undo .
    define variable v-value-logical0 AS LOGICAL no-undo .
    define variable v-tth0 as handle no-undo .
    run adm/shattri.p (
        input "get":U
        ,input  'БД':U
        ,input  p-db-num
        ,input  'code-range':U
        ,input  cfg-param-code
        ,output v-value-character0
        ,output v-value-date0
        ,output v-value-decimal0
        ,output v-value-integer0
        ,output v-value-logical0
        ,output v-param-type0
        ,INPUT-OUTPUT table-handle v-tth0
        ) no-error .
    if error-status :error then do:
      delete object v-tth0.
      v-mes0 = substitute("Ошибка при получении размера диапазона собственных глобальных кодов&2&1&2&3"
                         , error-status:get-message(1)
                         , chr(10)
                         , return-value ).
      undo, return error v-mes0.
    end.
    delete object v-tth0.
    if v-cre-cdrg = TRUE then do:
      create buf_code-range .
      assign
        buf_code-range.db-num     = p-db-num
        buf_code-range.range-type = type-code
        buf_code-range.stts       = "f"
        buf_code-range.first-code = last_code-range.last-code + 1
        buf_code-range.last-code  = last_code-range.last-code + integer(v-value-integer0)
        v-cre-str = "Свободный диапазон успешно создан"
      .
    end.
    else do:
      assign
        v-cre-str = "Нет возможности создать свободный диапазон." + chr(10)
                    + substitute( "Превышен предел диапазонов c типом &1", type-code )
      .
    end.
  end.
  return v-cre-str .
end procedure.
procedure gen-new-code-range-if-neces :
  define input parameter v-db-num           like ub.db.db-num             no-undo .
  define input parameter v-range-type       like ub.code-range.range-type no-undo .
  define input parameter v-cur-code         as   integer                  no-undo .
  define input parameter v-g#news           as   logical                  no-undo .
  define input parameter v-g#db-num         like ub.db.db-num             no-undo .
  define input parameter v-g#news-source-db like ub.db.db-num             no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-new-code-range-if-neces). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (gen-new-code-range-if-neces). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-new-code-range-if-neces). endkey", vss-workfile )
  :
    define variable l-code-range-exist as logical   no-undo init false .
    define variable v-db-for-send      as character no-undo .
    define buffer buf_code-range  for ub.code-range .
    define buffer buf1_code-range for ub.code-range .
    define buffer buf_db          for ub.db .
    find first buf_code-range
      where buf_code-range.range-type = v-range-type
        and buf_code-range.last-code >= v-cur-code
      use-index last-codei
      no-error .
    if
    (
       available buf_code-range
       and
      (buf_code-range.db-num = v-db-num
        and
      buf_code-range.first-code <= v-cur-code
      )
    or
      (
        v-range-type = 'drgb':U
        AND
        v-cur-code = 0
      )
   )
   then do:
      assign
        l-code-range-exist = true
      .
      if v-g#news
      and buf_code-range.stts = "f" then do:
        assign
          buf_code-range.stts = "u"
        .
      end.
    end.
    if not l-code-range-exist
       and v-g#news-source-db <> 0
    then do:
      undo, return error substitute("&1 &2 &3&4Отсутствует диапазон кодов для БД &5 Тип диапазона кодов &6 Код &7"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,chr(10)
                                    ,v-db-num
                                    ,v-range-type
                                    ,v-cur-code
                                   ).
    end.
    if (not l-code-range-exist
        or ( v-cur-code >= int( (buf_code-range.first-code + buf_code-range.last-code) / 2 ) )
       )
    and ( not can-find (first buf1_code-range no-lock
                        where buf1_code-range.db-num = v-db-num
                          and buf1_code-range.range-type = v-range-type
                          and buf1_code-range.stts = "f"
                       )
        )
    then do:
      if v-g#db-num = 0 then do:
        run new-bcod-gen-code-range in this-procedure
          (input v-db-num,
           input v-range-type
          ) no-error .
        if error-status :error then do:
          undo, return error substitute("Ошибка при создании нового свободного диапазона &1 Тип диапазона кодов &2 Код &3:&4&5 &6"
                                        , substitute("&1 &2 &3", vss-workfile, vss-revision, vss-description)
                                        ,v-db-num
                                        ,v-range-type
                                        ,v-cur-code
                                        ,chr(10)
                                        ,error-status:get-message(1)
                                        ,return-value
                                       ).
        end.
      end.
      else do:
        if v-range-type = 'sclc':U
        or v-range-type = 'pglc':U
        then do:
          assign
            v-db-for-send = "":U
          .
          if v-g#db-num = 0 then do:
            for each buf_db no-lock
              where buf_db.db-num > 0
                and buf_db.db-num <> v-g#news-source-db
            on error  undo, return error substitute( "&1 (gen-new-code-range-if-neces). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
            :
              assign
                v-db-for-send = v-db-for-send + chr(1) + string( buf_db.db-num )
              .
            end.
            assign
              v-db-for-send = right-trim( v-db-for-send, chr(1) )
            .
          end.
          else do:
            if not v-g#news then do:
              assign
                v-db-for-send = "0":U
              .
            end.
          end.
          run nws/cr-route.p ( input 'send-cmd':U
                        ,input ("command":U + chr(1) + "create":U + chr(1) +
                               "code-range":U + chr(1) +
                               (if v-range-type = 'sclc':U
                                then string( current-value(s-sclc-code, ub))
                                else string( current-value(s-pglc-code, ub))
                                ) + chr(1) +
                                v-range-type)
                        ,input ?
                        ,input v-db-for-send
                        ) no-error .
          if error-status :error then do:
            undo, return error return-value.
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure cre-loc-sc-code-range :
  define input parameter v-cur-code as integer no-undo .
define input parameter p-cdrg-type as character no-undo .
  do
  on error  undo, return error substitute( "&1 (cre-loc-sc-code-range). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (cre-loc-sc-code-range). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (cre-loc-sc-code-range). endkey", vss-workfile )
  :
    define buffer buf_code-range for ub.code-range .
    find first buf_code-range
         where buf_code-range.range-type = p-cdrg-type
           and buf_code-range.first-code >= v-cur-code
         no-error .
    if not available buf_code-range then do:
      run new-bcod-gen-code-range in this-procedure
        ( input 0,
          input p-cdrg-type
        ) no-error .
      if error-status :error then do:
        undo, return error substitute( "Ошибка при создании нового свободного диапазона локальных весовых или штучных кодов&1"
                                       + "Код &2&1&3 &4"
                                      , chr(10)
                                      , v-cur-code
                                      , error-status:get-message(1)
                                      , return-value
                                     ) .
      end.
    end.
  end.
end procedure.
procedure mark-used-if-need :
define input parameter p-cur-code as integer no-undo .
define input parameter p-range-type like ub.code-range.range-type no-undo .
define input parameter p-db-num like ub.code-range.db-num no-undo .
  do
  on error  undo, return error substitute( "&1 (mark-used-if-need). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (mark-used-if-need). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (mark-used-if-need). endkey", vss-workfile )
  :
    DEFINE VARIABLE v-db-num like ub.code-range.db-num no-undo .
    define buffer buf_code-range for ub.code-range .
    assign
    v-db-num = if p-range-type = 'sclc':U
               then 0
               else p-db-num
    .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer locK-batchprocess1 for ub.batchprocess.
run gbl/lock-prc.p
    (input 'lscc':U
    ,input 0
    ,input 0
    ,input 0
    ,input ""
    ,input ""
    ,input ""
    ,input (
            ",,,Вкл/выкл лок. вес. кодов"
           )
    ,input true
    ,buffer lock-batchprocess1
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "В данный момент идет процесс вкл/выкл лок. вес. кодов" skip
      view-as alert-box error .
    undo, return error .
  end.
    find first buf_code-range
         where buf_code-range.range-type = p-range-type
           and buf_code-range.first-code >= p-cur-code
           and buf_code-range.last-code <= p-cur-code
           and buf_code-range.db-num = v-db-num
         no-error .
    if not available buf_code-range then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при создании поиске диапазона" skip
        "База данных" p-db-num skip
        "Код" p-cur-code skip
        "Тип" p-range-type
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_code-range.stts = "f":U then do:
      assign
      buf_code-range.stts = "u":U
      .
    end.
  end.
end procedure.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
procedure thbjattr_code :
   define input  parameter p-upper-code     as character no-undo .
   define input  parameter p-code           as character no-undo .
   define output parameter p-label          as character no-undo .
   define output parameter p-user-can-edit  as logical   no-undo .
   define output parameter p-output-display as logical   no-undo .
   define output parameter p-other          as character no-undo .
   define output parameter p-prop-list      as character no-undo .
   define output parameter p-prop-type-list as character no-undo .
   define output parameter p-prop-label-list as character no-undo .
   define output parameter p-global          as logical no-undo .
   define output parameter p-host           as logical no-undo .
   define output parameter p-shop           as logical no-undo .
   define output parameter p-store          as logical no-undo .
   define output parameter p-db             as logical no-undo .
   define variable p-region as logical no-undo.
   run thbjattr_code_reg in this-procedure (
                                            p-upper-code,
                                            p-code,
                                            output p-label,
                                            output p-user-can-edit,
                                            output p-output-display,
                                            output p-other,
                                            output p-prop-list,
                                            output p-prop-type-list,
                                            output p-prop-label-list,
                                            output p-global,
                                            output p-host,
                                            output p-shop,
                                            output p-store,
                                            output p-db,
                                            output p-region
                                            ).
end procedure.
procedure thbjattr_code_reg :
define input  parameter p-upper-code     as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-label          as character no-undo .
define output parameter p-user-can-edit  as logical   no-undo .
define output parameter p-output-display as logical   no-undo .
define output parameter p-other          as character no-undo .
define output parameter p-prop-list      as character no-undo .
define output parameter p-prop-type-list as character no-undo .
define output parameter p-prop-label-list as character no-undo .
define output parameter p-global          as logical no-undo .
define output parameter p-host           as logical no-undo .
define output parameter p-shop           as logical no-undo .
define output parameter p-store          as logical no-undo .
define output parameter p-db             as logical no-undo .
define output parameter p-region         as logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_code in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-label
    ,output p-user-can-edit
    ,output p-output-display
    ,output p-other
    ,output p-prop-list
    ,output p-prop-type-list
    ,output p-prop-label-list
    ,output p-global
    ,output p-host
    ,output p-shop
    ,output p-store
    ,output p-db
    ,output p-region
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info2, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_tooltip :
define input  parameter p-upper-code  as character no-undo .
define input  parameter p-code      as character no-undo .
define output parameter p-tooltip   as character no-undo .
define output parameter p-label     as character no-undo .
define output parameter p-tooltip-code as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_tooltip in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-tooltip
    ,output p-label
    ,output p-tooltip-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_legacy :
define input  parameter p-upper-code     as character no-undo .
define output parameter p-level-way      as character no-undo .
define output parameter p-up-way         as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_legacy in g#attr-lib
    (input  p-upper-code
    ,output p-level-way
    ,output p-up-way
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info2, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_value :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define output parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define output parameter p-value-date    like ub.thbj-attr.property-value-date no-undo .
define output parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define output parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define output parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
define output parameter p-type     as character no-undo .
define output parameter p-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_value in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-value-character
    ,output p-value-date
    ,output p-value-decimal
    ,output p-value-integer
    ,output p-value-logical
    ,output p-type
    ,output p-found
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_get-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-param-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-mode as character no-undo .
define input-output parameter table-handle p-tth.
define output parameter p-all-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_get-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-param-code
    ,input  p-mode
    ,input-output table-handle p-tth
    ,output p-all-found
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_write :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define input  parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define input  parameter p-value-date like ub.thbj-attr.property-value-date no-undo .
define input  parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define input  parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define input  parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_write in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,input  p-value-character
    ,input  p-value-date
    ,input  p-value-decimal
    ,input  p-value-integer
    ,input  p-value-logical
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_set-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter table-handle p-tth.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_set-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  table-handle p-tth
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_delete :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code       like ub.thbj-attr.prop-code  no-undo .
define output parameter p-deleted  as logical no-undo.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-deleted
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_delete-section :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_manual-edit :
define input  parameter p-ucode          as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-section-num    as integer no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_manual-edit in g#attr-lib
    (input  p-ucode
    ,input  p-code
    ,output  p-section-num
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE VARIABLE v-S_CONTRACT               AS CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE v-S_CODE_LAST_MASTER_NUM   AS CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE v-DELIM_CHR_3              AS CHARACTER NO-UNDO INITIAL "".
ASSIGN
   v-S_CONTRACT                = "Contract":U
   v-S_CODE_LAST_MASTER_NUM    = "LastMasterNum":U
   v-DELIM_CHR_3               = ","
   .
DEFINE VARIABLE i-gl-Host-Code      AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE i-gl-Contract-Code  AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE i-gl-Extent3        AS INTEGER NO-UNDO INITIAL 0 EXTENT 3.
FUNCTION Can-Find-Spec RETURN LOGICAL (
   INPUT iHost-Code    AS INTEGER,
   INPUT iContract-Num AS INTEGER,
   INPUT iGds-Code     AS INTEGER ):
   DEFINE BUFFER buf_Spec FOR ub.Contract-Specif.
   DEFINE VARIABLE iTmp-Host-Code     AS INTEGER NO-UNDO INITIAL 0.
   DEFINE VARIABLE iTmp-Contract-Num  AS INTEGER NO-UNDO INITIAL 0.
   DEFINE VARIABLE iTmp-Extent3       AS INTEGER NO-UNDO INITIAL 0 EXTENT 3.
   DEFINE VARIABLE lRet               AS LOGICAL NO-UNDO INITIAL FALSE.
   RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
       INPUT  iHost-Code,
       INPUT  iContract-Num,
       OUTPUT iTmp-Extent3
       ).
   IF iTmp-Extent3[1] = 2 THEN DO:
      ASSIGN
         iTmp-Host-Code      = iTmp-Extent3[2]
         iTmp-Contract-Num   = iTmp-Extent3[3]
         .
   END. ELSE DO:
      ASSIGN
         iTmp-Host-Code      = iHost-Code
         iTmp-Contract-Num   = iContract-Num
         .
   END.
   IF iGds-Code = ? THEN DO:
      ASSIGN
         lRet = CAN-FIND(FIRST buf_Spec NO-LOCK WHERE
                               buf_Spec.Host-Code     = iTmp-Host-Code
                           AND buf_Spec.Contract-Num  = iTmp-Contract-Num
                        ).
   END. ELSE DO:
         lRet = CAN-FIND(FIRST buf_Spec NO-LOCK WHERE
                               buf_Spec.Host-Code     = iTmp-Host-Code
                           AND buf_Spec.Contract-Num  = iTmp-Contract-Num
                           AND buf_Spec.Gds-Code      = iGds-Code
                         ).
   END.
   RETURN (lRet).
END FUNCTION.
PROCEDURE MS-Contract-EXTENT-3:
   DEFINE INPUT  PARAMETER i-Host-Code     AS INTEGER NO-UNDO.
   DEFINE INPUT  PARAMETER i-Contract-Code AS INTEGER NO-UNDO.
   DEFINE OUTPUT PARAMETER i-Ret           AS INTEGER NO-UNDO EXTENT 3 INITIAL 0.
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-Classif.
   DEFINE BUFFER buf_Cont        FOR ub.Contract.
   DEFINE BUFFER buf_Cont-2      FOR ub.Contract.
   FIND FIRST buf_Cont-2 WHERE
              buf_Cont-2.Host-Code      = i-Host-Code
          AND buf_Cont-2.Contract-Code  = i-Contract-Code
        NO-LOCK NO-ERROR.
   IF NOT AVAILABLE buf_Cont-2 THEN DO:
      RETURN.
   END.
   FOR FIRST buf_Ext-Classif WHERE
             buf_Ext-Classif.Classif-name = v-S_CONTRACT
        AND  buf_Ext-Classif.CharKey_One  = STRING(i-Host-code) + v-DELIM_CHR_3 +
                                            STRING(i-Contract-code)
        AND  buf_Ext-classif.db-num       = buf_Cont-2.Db-num
       NO-LOCK,
       EACH buf_Cont WHERE
            buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3 ))
        AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
       NO-LOCK:
       ASSIGN
          i-Ret[1] = 1
          i-Ret[2] = buf_Cont.Host-code
          i-Ret[3] = buf_Cont.Contract-code
          .
       LEAVE.
   END.
   IF i-Ret[1] <> 1 THEN DO:
      FOR FIRST buf_Ext-Classif WHERE
                buf_Ext-Classif.Classif-name = v-S_CONTRACT
           AND  buf_Ext-Classif.CharKey_Two  = STRING(i-Host-code) + v-DELIM_CHR_3 +
                                               STRING(i-Contract-code)
           AND  buf_Ext-classif.db-num       = buf_Cont-2.Db-num
          NO-LOCK,
          EACH buf_Cont WHERE
               buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
           AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
          NO-LOCK:
          ASSIGN
             i-Ret[1] = 2
             i-Ret[2] = buf_Cont.Host-code
             i-Ret[3] = buf_Cont.Contract-code
             .
          LEAVE.
      END.
   END.
   RETURN.
END PROCEDURE.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE VARIABLE v-gl-UVEDOMLENIE as CHARACTER NO-UNDO INITIAL "Uvedomlenie":U.
FUNCTION Get-Contract-Attr RETURN CHARACTER(
         INPUT iHost-Code AS INTEGER,
         INPUT iContract-Code  AS INTEGER,
         INPUT cAttr-code      AS CHARACTER):
   DEFINE BUFFER buf_Contract-Attr FOR ub.Contract-Attr.
   FIND FIRST buf_Contract-Attr WHERE
              buf_Contract-Attr.Host-code     = iHost-Code
          AND buf_Contract-Attr.Contract-code = iContract-Code
          AND buf_Contract-Attr.Attr-code     = cAttr-code
        NO-LOCK NO-ERROR.
   RETURN (IF AVAILABLE buf_Contract-Attr THEN buf_Contract-Attr.Attr-value ELSE ?).
END FUNCTION.
PROCEDURE Modify-Contract-Attr:
   DEFINE INPUT  PARAMETER iHost-Code      AS INTEGER   NO-UNDO.
   DEFINE INPUT  PARAMETER iContract-Code  AS INTEGER   NO-UNDO.
   DEFINE INPUT  PARAMETER cAttr-code      AS CHARACTER NO-UNDO.
   DEFINE INPUT  PARAMETER cAttr-value     AS CHARACTER NO-UNDO.
   DEFINE OUTPUT PARAMETER cError          AS CHARACTER NO-UNDO INITIAL "".
   DEFINE BUFFER buf_Contract-Attr FOR  ub.Contract-Attr.
   Tran:
   DO TRANSACTION
      ON ENDKEY UNDO Tran, RETRY Tran
      ON ERROR  UNDO Tran, RETRY Tran
      ON QUIT   UNDO Tran, RETRY Tran
      ON STOP   UNDO Tran, RETRY Tran:
      IF RETRY THEN DO:       cError = "Ошибка транзакции:":U + PROGRAM-NAME(1) + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE.        UNDO Tran, LEAVE Tran.    END.
      FIND FIRST buf_Contract-Attr WHERE
                 buf_Contract-Attr.Host-Code      = iHost-Code
             AND buf_Contract-Attr.Contract-Code  = iContract-Code
             AND buf_Contract-Attr.Attr-code      = cAttr-code
           NO-LOCK NO-ERROR.
      IF NOT AVAILABLE buf_Contract-Attr THEN DO:
         CREATE buf_Contract-Attr NO-ERROR.
         IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      END. ELSE DO:
         FIND CURRENT buf_Contract-Attr EXCLUSIVE-LOCK NO-ERROR.
         IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      END.
      ASSIGN
         buf_Contract-Attr.Host-Code      = iHost-Code
         buf_Contract-Attr.Contract-Code  = iContract-Code
         buf_Contract-Attr.Attr-code      = cAttr-code
         buf_Contract-Attr.Attr-value     = cAttr-value
         NO-ERROR.
      IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      RELEASE buf_Contract-Attr NO-ERROR.
      IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
   END.
   RETURN.
END PROCEDURE.
PROCEDURE Create-Contract-Attr:
   DEFINE INPUT  PARAMETER iHost-Code      AS INTEGER   NO-UNDO.
   DEFINE INPUT  PARAMETER iContract-Code  AS INTEGER   NO-UNDO.
   DEFINE INPUT  PARAMETER cAttr-code      AS CHARACTER NO-UNDO.
   DEFINE INPUT  PARAMETER cAttr-value     AS CHARACTER NO-UNDO.
   DEFINE OUTPUT PARAMETER cError          AS CHARACTER NO-UNDO INITIAL "".
   DEFINE BUFFER buf_Contract-Attr FOR  ub.Contract-Attr.
   Tran:
   DO TRANSACTION
      ON ENDKEY UNDO Tran, RETRY Tran
      ON ERROR  UNDO Tran, RETRY Tran
      ON QUIT   UNDO Tran, RETRY Tran
      ON STOP   UNDO Tran, RETRY Tran:
      IF RETRY THEN DO:       cError = "Ошибка транзакции:":U + PROGRAM-NAME(1) + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE.        UNDO Tran, LEAVE Tran.    END.
      CREATE buf_Contract-Attr NO-ERROR.
      IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      ASSIGN
         buf_Contract-Attr.Host-Code      = iHost-Code
         buf_Contract-Attr.Contract-Code  = iContract-Code
         buf_Contract-Attr.Attr-code      = cAttr-code
         buf_Contract-Attr.Attr-value     = cAttr-value
         NO-ERROR.
      IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      RELEASE buf_Contract-Attr NO-ERROR.
      IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
   END.
   RETURN.
END PROCEDURE.
FUNCTION Is-MS-Contract RETURN LOGICAL(BUFFER buf_Master FOR ub.Contract, BUFFER buf_Slave  FOR ub.Contract) FORWARD.
FUNCTION Is-Master-Slave-Contract RETURN CHARACTER( BUFFER buf_Contract FOR ub.Contract) FORWARD.
FUNCTION Is-MS-Contract-Int RETURN INTEGER (BUFFER buf_Contract FOR ub.Contract) FORWARD.
PROCEDURE Delete-Contract-Specif:
   DEFINE PARAMETER BUFFER buf_Contract FOR ub.Contract.
   DEFINE OUTPUT PARAMETER cError AS CHARACTER NO-UNDO INITIAL "".
   DEFINE BUFFER buf_Specif      FOR ub.Contract-Specif.
   DEFINE BUFFER buf_Specif-Attr FOR ub.Contract-Specif-Attr.
   Tran:
   DO TRANSACTION
      ON ENDKEY UNDO Tran, RETRY Tran
      ON ERROR  UNDO Tran, RETRY Tran
      ON QUIT   UNDO Tran, RETRY Tran
      ON STOP   UNDO Tran, RETRY Tran:
      IF RETRY THEN DO:       cError = "Ошибка транзакции ":U + PROGRAM-NAME(1) + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE.        UNDO Tran, LEAVE Tran.    END.
      FOR EACH buf_Specif-Attr WHERE
               buf_Specif-Attr.Host-code     = buf_Contract.Host-code
           AND buf_Specif-Attr.Contract-Num  = buf_Contract.Contract-code
          EXCLUSIVE-LOCK:
          DELETE buf_Specif-Attr NO-ERROR.
          IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      END.
      FOR EACH buf_Specif WHERE
               buf_Specif.Host-code     = buf_Contract.Host-code
           AND buf_Specif.Contract-Num  = buf_Contract.Contract-code
          EXCLUSIVE-LOCK:
          DELETE buf_Specif NO-ERROR.
         IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      END.
   END.
   RETURN.
END PROCEDURE.
PROCEDURE Modify-Slave-Contract:
   DEFINE PARAMETER BUFFER buf_Master FOR ub.Contract.
   DEFINE OUTPUT PARAMETER cError AS CHARACTER NO-UNDO INITIAL "".
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-classif.
   DEFINE BUFFER buf_Slave FOR ub.Contract.
   Tran:
   DO TRANSACTION
      ON ENDKEY UNDO Tran, RETRY Tran
      ON ERROR  UNDO Tran, RETRY Tran
      ON QUIT   UNDO Tran, RETRY Tran
      ON STOP   UNDO Tran, RETRY Tran:
      IF RETRY THEN DO:       cError = "Ошибка транзакции ":U + PROGRAM-NAME(1) + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE.        UNDO Tran, LEAVE Tran.    END.
      FOR EACH buf_Ext-Classif WHERE
               buf_Ext-Classif.Classif-name = v-S_CONTRACT
           AND buf_Ext-Classif.CharKey_One  = STRING(buf_Master.Host-Code) + v-DELIM_CHR_3 + STRING(buf_Master.Contract-code)
           AND buf_Ext-Classif.DB-num       = buf_Master.Db-num
          NO-LOCK,
          FIRST buf_Slave WHERE
                buf_Slave.Host-Code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
            AND buf_Slave.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
          EXCLUSIVE-LOCK:
          BUFFER-COPY
            buf_Master
          EXCEPT
            Host-code                               Contract-code                           Own-name                                an-uchet-code-out                       cel-nazn-code-out                       cor-acc-out                             cor-acc1-out                            an-uchet-code-in                        cel-nazn-code-in                        cor-acc-in                              cor-acc1-in                             an-uchet-code-out-cash                  cel-nazn-code-out-cash                  cor-acc-out-cash                        cor-acc1-out-cash                       an-uchet-code-in-cash                   cel-nazn-code-in-cash                   cor-acc-in-cash                         cor-acc1-in-cash                        an-uchet-code-out-payoff                cel-nazn-code-out-payoff                cor-acc-out-payoff                      cor-acc1-out-payoff                     an-uchet-code-in-payoff                 cel-nazn-code-in-payoff                 cor-acc-in-payoff                       cor-acc1-in-payoff                      transport-cli-type                      transport-cli-code                      transport-host                          transport-contract                      transport-uslov                         transport-value                         own-code-schet-start                    own-sign-post                           own-sign                                contract-city                           fin-VAT-pc                              srok-opl                                gen-factur-srok                         own-addres                              own-inn                                 own-kpp
          TO buf_Slave
          NO-ERROR.
          IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
          RELEASE buf_Slave NO-ERROR.
          IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      END.
   END.
   RETURN.
END PROCEDURE.
PROCEDURE Change-Stat-Slave-Contract:
   DEFINE PARAMETER BUFFER buf_Master FOR ub.Contract.
   DEFINE INPUT PARAMETER cStatus  AS CHARACTER NO-UNDO.
   DEFINE OUTPUT PARAMETER cError AS CHARACTER NO-UNDO INITIAL "".
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-classif.
   DEFINE BUFFER buf_Slave FOR ub.Contract.
   Tran:
   DO TRANSACTION
      ON ENDKEY UNDO Tran, RETRY Tran
      ON ERROR  UNDO Tran, RETRY Tran
      ON QUIT   UNDO Tran, RETRY Tran
      ON STOP   UNDO Tran, RETRY Tran:
      IF RETRY THEN DO:       cError = "Ошибка транзакции ":U + PROGRAM-NAME(1) + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE.        UNDO Tran, LEAVE Tran.    END.
      FOR EACH buf_Ext-Classif WHERE
               buf_Ext-Classif.Classif-name = v-S_CONTRACT
           AND buf_Ext-Classif.CharKey_One  = STRING(buf_Master.Host-Code) + v-DELIM_CHR_3 + STRING(buf_Master.Contract-code)
           AND buf_Ext-Classif.DB-num       = buf_Master.Db-num
          NO-LOCK,
          FIRST buf_Slave WHERE
                buf_Slave.Host-Code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
            AND buf_Slave.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
          EXCLUSIVE-LOCK:
          ASSIGN
             buf_Slave.Status_ = cStatus
             NO-ERROR.
          IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
          RELEASE buf_Slave NO-ERROR.
          IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      END.
   END.
   RETURN.
END PROCEDURE.
PROCEDURE Delete-Ref-Master-Slave:
   DEFINE PARAMETER BUFFER buf_Master FOR ub.Contract.
   DEFINE PARAMETER BUFFER buf_Slave  FOR ub.Contract.
   DEFINE OUTPUT PARAMETER cError AS CHARACTER NO-UNDO INITIAL "".
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-classif.
   IF NOT Is-MS-Contract(BUFFER buf_Master, BUFFER buf_Slave) THEN DO:
      cError = PROGRAM-NAME(1) + ":" + "Между договорами нет связи Master->Slave".
      RETURN.
   END.
   Tran:
   FOR FIRST buf_Ext-Classif WHERE
             buf_Ext-Classif.Classif-name = v-S_CONTRACT
         AND buf_Ext-Classif.CharKey_One  = STRING(buf_Master.Host-Code) + v-DELIM_CHR_3 + STRING(buf_Master.Contract-code)
         AND buf_Ext-Classif.CharKey_Two  = STRING(buf_Slave.Host-Code)  + v-DELIM_CHR_3 + STRING(buf_Slave.Contract-code)
         AND buf_Ext-Classif.DB-num       = buf_Master.Db-num
       EXCLUSIVE-LOCK
       TRANSACTION
       ON ENDKEY UNDO Tran, RETRY Tran
       ON ERROR  UNDO Tran, RETRY Tran
       ON QUIT   UNDO Tran, RETRY Tran
       ON STOP   UNDO Tran, RETRY Tran:
       IF RETRY THEN DO:       cError = "Ошибка транзакции ":U + PROGRAM-NAME(1) + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE.        UNDO Tran, LEAVE Tran.    END.
       DELETE buf_Ext-Classif NO-ERROR.
       IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
   END.
   RETURN.
END PROCEDURE.
PROCEDURE Create-Ref-Master-Slave:
   DEFINE PARAMETER BUFFER buf_Master FOR ub.Contract.
   DEFINE PARAMETER BUFFER buf_Slave  FOR ub.Contract.
   DEFINE OUTPUT PARAMETER cError AS CHARACTER NO-UNDO INITIAL "".
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-classif.
   DEFINE VARIABLE cKeyRec AS CHARACTER NO-UNDO INITIAL "".
   IF Is-MS-Contract(BUFFER buf_Master, BUFFER buf_Slave) THEN DO:
      cError = PROGRAM-NAME(1) + ":" + "Между договорами  уже есть связь Master->Slave".
      RETURN.
   END.
   RUN gen-key-rec IN THIS-PROCEDURE(
       INPUT  v-S_CONTRACT,
       INPUT  BUFFER buf_Master:HANDLE,
       OUTPUT cKeyRec
       ) NO-ERROR.
   IF ERROR-STATUS:ERROR THEN DO:
      cError = PROGRAM-NAME(1) + ":" + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE.
      RETURN.
   END.
   Tran:
   DO TRANSACTION
      ON ENDKEY UNDO Tran, RETRY Tran
      ON ERROR  UNDO Tran, RETRY Tran
      ON QUIT   UNDO Tran, RETRY Tran
      ON STOP   UNDO Tran, RETRY Tran:
      IF RETRY THEN DO:       cError = "Ошибка транзакции ":U + PROGRAM-NAME(1) + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE.        UNDO Tran, LEAVE Tran.    END.
      CREATE buf_Ext-Classif NO-ERROR.
      IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      ASSIGN
         buf_Ext-Classif.Classif-name    = v-S_CONTRACT
         buf_Ext-Classif.Classif-subject = v-S_CONTRACT
         buf_Ext-Classif.CharKey_One     = STRING(buf_Master.Host-Code) + v-DELIM_CHR_3 + STRING(buf_Master.Contract-code)
         buf_Ext-Classif.CharKey_Two     = STRING(buf_Slave.Host-Code)  + v-DELIM_CHR_3 + STRING(buf_Slave.Contract-code)
         buf_Ext-Classif.DB-num          = buf_Master.Db-num
         buf_Ext-Classif.Uniq-key-rec    = cKeyRec
         NO-ERROR.
      IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      RELEASE buf_Ext-Classif NO-ERROR.
      IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
   END.
   RETURN.
END PROCEDURE.
FUNCTION Is-MS-Contract-Int-2 RETURN INTEGER (
                              i-Host-Code AS INTEGER,
                              i-Contract-Code AS INTEGER):
   DEFINE BUFFER buf_Contract FOR ub.Contract.
   DEFINE VARIABLE iRet AS INTEGER NO-UNDO INITIAL 0.
   FIND FIRST buf_Contract WHERE
              buf_Contract.Host-Code      = i-Host-Code
          AND buf_Contract.Contract-code  = i-Contract-Code
        NO-LOCK NO-ERROR.
   IF AVAILABLE buf_Contract THEN DO:
      ASSIGN
         iRet = Is-MS-Contract-Int(BUFFER buf_Contract).
   END.
   RETURN (iRet).
END FUNCTION.
FUNCTION Is-MS-Contract-Int RETURN INTEGER (BUFFER buf_Contract FOR ub.Contract):
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-Classif.
   DEFINE BUFFER buf_Cont        FOR ub.Contract.
   DEFINE VARIABLE iRet AS INTEGER NO-UNDO INITIAL 0.
   FOR FIRST buf_Ext-Classif WHERE
             buf_Ext-Classif.Classif-name = v-S_CONTRACT
        AND  buf_Ext-Classif.CharKey_One  = STRING(buf_Contract.Host-code) + v-DELIM_CHR_3 +
                                            STRING(buf_Contract.contract-code)
        AND  buf_Ext-classif.db-num       = buf_Contract.db-num
       NO-LOCK,
       EACH buf_Cont WHERE
            buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3 ))
        AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
       NO-LOCK:
       ASSIGN
          iRet = 1.
       LEAVE.
   END.
   IF iRet <> 1 THEN DO:
      FOR FIRST buf_Ext-Classif WHERE
                buf_Ext-Classif.Classif-name = v-S_CONTRACT
           AND  buf_Ext-Classif.CharKey_Two  = STRING(buf_Contract.Host-code) + v-DELIM_CHR_3 +
                                               STRING(buf_Contract.contract-code)
           AND  buf_Ext-classif.db-num       = buf_Contract.db-num
          NO-LOCK,
          EACH buf_Cont WHERE
               buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
           AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
          NO-LOCK:
          ASSIGN
             iRet = 2.
          LEAVE.
      END.
   END.
   RETURN (iRet).
END FUNCTION.
FUNCTION Is-Master-Slave-Contract RETURN CHARACTER( BUFFER buf_Contract FOR ub.Contract):
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-Classif.
   DEFINE BUFFER buf_Cont        FOR ub.Contract.
   DEFINE VARIABLE cRet AS CHARACTER NO-UNDO INITIAL "".
   FOR FIRST buf_Ext-Classif WHERE
             buf_Ext-Classif.Classif-name = v-S_CONTRACT
        AND  buf_Ext-Classif.CharKey_One  = STRING(buf_Contract.Host-code) + v-DELIM_CHR_3 +
                                            STRING(buf_Contract.contract-code)
        AND  buf_Ext-classif.db-num       = buf_Contract.db-num
       NO-LOCK,
       EACH buf_Cont WHERE
            buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3 ))
        AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
       NO-LOCK:
       ASSIGN
          cRet = "+".
       LEAVE.
   END.
   IF cRet = "" THEN DO:
      FOR FIRST buf_Ext-Classif WHERE
                buf_Ext-Classif.Classif-name = v-S_CONTRACT
           AND  buf_Ext-Classif.CharKey_Two  = STRING(buf_Contract.Host-code) + v-DELIM_CHR_3 +
                                               STRING(buf_Contract.contract-code)
           AND  buf_Ext-classif.db-num       = buf_Contract.db-num
          NO-LOCK,
          EACH buf_Cont WHERE
               buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
           AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
          NO-LOCK:
          ASSIGN
             cRet = (IF buf_Cont.Contract-prn-code = "" THEN  STRING(buf_Cont.Contract-code) ELSE buf_Cont.Contract-prn-code).
          LEAVE.
      END.
   END.
   RETURN (cRet).
END FUNCTION.
FUNCTION Is-MS-Contract RETURN LOGICAL(
         BUFFER buf_Master FOR ub.Contract,
         BUFFER buf_Slave  FOR ub.Contract):
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-classif.
   RETURN CAN-FIND ( FIRST buf_Ext-Classif WHERE
                       buf_Ext-Classif.Classif-name = v-S_CONTRACT
                   AND buf_Ext-Classif.CharKey_One  = STRING(buf_Master.Host-Code) + v-DELIM_CHR_3 + STRING(buf_Master.Contract-code)
                   AND buf_Ext-Classif.CharKey_Two  = STRING(buf_Slave.Host-Code)  + v-DELIM_CHR_3 + STRING(buf_Slave.Contract-code)
                   AND buf_Ext-Classif.DB-num       = buf_Master.Db-num
                 NO-LOCK).
END FUNCTION.
FUNCTION Get-Num-Slave-Contract RETURN CHARACTER(
         BUFFER buf_Master FOR ub.Contract,
         INPUT iSlave-Host-Code AS INTEGER
         ):
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-classif.
   DEFINE BUFFER buf_Contract    FOR ub.Contract.
   DEFINE VARIABLE cRet AS CHARACTER NO-UNDO INITIAL "".
   FIND FIRST buf_Ext-Classif WHERE
              buf_Ext-Classif.Classif-name = v-S_CONTRACT
          AND buf_Ext-Classif.CharKey_One  = STRING(buf_Master.Host-Code)  + v-DELIM_CHR_3 + STRING(buf_Master.Contract-code)
          AND buf_Ext-Classif.CharKey_Two  BEGINS STRING(iSlave-Host-Code) + v-DELIM_CHR_3
          AND buf_Ext-Classif.DB-num       = buf_Master.Db-num
        NO-LOCK NO-ERROR.
   IF AVAILABLE buf_Ext-Classif THEN DO:
      IF CAN-FIND (FIRST buf_Contract WHERE
                         buf_Contract.Host-Code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
                     AND buf_Contract.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
                    NO-LOCK) THEN DO:
         ASSIGN
            cRet = ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3).
      END. ELSE DO:
         ASSIGN
            cRet = "ERROR:" + "Ошибка связи мастер договора " +
                   STRING(buf_Master.Host-Code) + "," + STRING(buf_Master.Contract-code) + " " +
                   "c Host-code=" + STRING(iSlave-Host-Code).
      END.
   END.
   RETURN (cRet).
END FUNCTION.
define input  parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input  parameter p-host-code as integer   no-undo .
define input  parameter ref-mode    as character no-undo .
define input  parameter p-doc-type  as character no-undo .
define input-output parameter ri    as recid     no-undo .
define variable agnt-list as character no-undo .
define variable p-contr-type as character no-undo .
define  shared variable br-handle as handle  no-undo .
define  shared variable next-prev as logical no-undo .
DEFINE  SHARED BUFFER buf_contract FOR ub.contract .
define variable v-own-code-schet    as integer   no-undo .
define variable v-cli-code-schet    as integer   no-undo .
define variable v-posr-code-schet   as integer   no-undo .
define variable v-agnt-code-schet   as integer   no-undo .
define variable v-own-code-schet-2  as integer   no-undo .
define variable v-cli-code-schet-2  as integer   no-undo .
define variable v-posr-code-schet-2 as integer   no-undo .
define variable v-agnt-code-schet-2 as integer   no-undo .
define variable v-own-point-code    as integer   no-undo .
define variable v-own-point-db-num  as integer   no-undo .
define variable v-agnt-point-code   as integer   no-undo .
define variable v-agnt-point-db-num as integer   no-undo .
define variable v-cli-point-code    as integer   no-undo .
define variable v-cli-point-db-num  as integer   no-undo .
define variable v-posr-point-code   as integer   no-undo .
define variable v-posr-point-db-num as integer   no-undo .
define variable  v-transport-cli-type   like  ub.contract.transport-cli-type         .
define variable  v-transport-cli-code   like  ub.contract.transport-cli-code         .
define variable  v-transport-host       like  ub.contract.transport-host        .
define variable  v-transport-contract   like  ub.contract.transport-contract    .
define variable  v-transport-uslov      like  ub.contract.transport-uslov       .
define variable  v-transport-value      like  ub.contract.transport-value       .
define variable  v-transport-type       like  ub.contract.transport-type       .
define variable inn-own        as character no-undo .
define variable kpp-own        as character no-undo .
define variable addres-own     as character no-undo .
define variable sign-own       as character no-undo .
define variable sign-post-own  as character no-undo .
define variable inn-cli        as character no-undo .
define variable kpp-cli        as character no-undo .
define variable addres-cli     as character no-undo .
define variable sign-cli       as character no-undo .
define variable sign-post-cli  as character no-undo .
define variable inn-posr       as character no-undo .
define variable kpp-posr       as character no-undo .
define variable addres-posr    as character no-undo .
define variable sign-posr      as character no-undo .
define variable sign-post-posr as character no-undo .
define variable inn-agnt       as character no-undo .
define variable kpp-agnt       as character no-undo .
define variable addres-agnt    as character no-undo .
define variable sign-agnt      as character no-undo .
define variable sign-post-agnt as character no-undo .
define variable a-code-an-uchet as integer extent 6  no-undo .
define variable a-code-cel-nazn as integer extent 6  no-undo .
define variable a-code-cor-acc  as integer extent 6  no-undo .
define variable a-code-cor-acc-2  as integer extent 6  no-undo .
define variable g-log   as logical   no-undo .
define variable ref-rec as recid no-undo .
DEFINE VARIABLE v-Character   AS CHARACTER  NO-UNDO .
DEFINE VARIABLE v-Date        AS DATE       NO-UNDO .
DEFINE VARIABLE v-Decimal     AS DECIMAL    NO-UNDO .
DEFINE VARIABLE v-iMcMode     AS INTEGER    NO-UNDO .
DEFINE VARIABLE v-Logical     AS LOGICAL    NO-UNDO .
DEFINE VARIABLE v-Param-Type  AS CHARACTER  NO-UNDO .
DEFINE VARIABLE iTmp-Host-Code     AS INTEGER   NO-UNDO INITIAL 0.
DEFINE VARIABLE iTmp-Contract-Code AS INTEGER   NO-UNDO INITIAL 0.
DEFINE VARIABLE cTmp-Mode-W        AS CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE i-Cont-Ret         AS INTEGER   NO-UNDO INITIAL 0 EXTENT 3.
define buffer b_contract for ub.contract.
define buffer buf_c-contract for ub.c-contract.
define buffer buf_firm for ub.firm.
define buffer buf_clients for ub.clients.
define buffer buf_contract-attr for ub.contract-attr .
define variable v-log as logical no-undo.
DEFINE BUTTON B-Add-Inf
     LABEL "Доп.инфо"
     SIZE 10 BY 1.
DEFINE BUTTON b-an-uchet
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2"
     SIZE 2.88 BY 1.
DEFINE BUTTON b-bank-agnt
     LABEL "&Реквизиты"
     SIZE 10 BY 1.
DEFINE BUTTON b-bank-cli
     LABEL "&Реквизиты"
     SIZE 10 BY 1.
DEFINE BUTTON b-bank-own
     LABEL "&Реквизиты"
     SIZE 10 BY 1.
DEFINE BUTTON b-bank-posr
     LABEL "&Реквизиты"
     SIZE 10 BY 1.
DEFINE BUTTON b-cel-nazn
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2"
     SIZE 2.88 BY 1.
DEFINE BUTTON b-cor-acc
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2"
     SIZE 2.88 BY 1.
DEFINE BUTTON b-cor-acc-2
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2"
     SIZE 2.88 BY 1.
DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "&Отмена":L
     SIZE 10 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-hist
     LABEL "Ис&тория":L
     SIZE 10 BY 1.
DEFINE BUTTON b-next AUTO-GO
     LABEL "&>>"
     SIZE 5 BY 1.
DEFINE BUTTON b-OK AUTO-GO
     LABEL "&Ввод ":L
     SIZE 10 BY 1.
DEFINE BUTTON b-prev AUTO-GO
     LABEL "&<<"
     SIZE 5 BY 1.
DEFINE BUTTON b-spec
     LABEL "Спецификация"
     SIZE 14 BY 1.
DEFINE BUTTON B-transport
     LABEL "Т&ранспорт"
     SIZE 10 BY 1.
DEFINE BUTTON BUTTON-agnt
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2"
     SIZE 2.88 BY 1.
DEFINE BUTTON BUTTON-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2"
     SIZE 2.88 BY 1.
DEFINE BUTTON BUTTON-curr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "1"
     SIZE 3.38 BY 1.13.
DEFINE BUTTON BUTTON-mngr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "3"
     SIZE 2.88 BY 1.
DEFINE BUTTON BUTTON-posr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2"
     SIZE 2.88 BY 1.
DEFINE VARIABLE COMBO-auto-pay AS CHARACTER FORMAT "X(256)":U
     LABEL "Статус"
     VIEW-AS COMBO-BOX INNER-LINES 5
     DROP-DOWN-LIST
     SIZE 16 BY 1 TOOLTIP "Конечный статус сгенеренного финансового обязательства" NO-UNDO.
DEFINE VARIABLE COMBO-auto-pay-2 AS CHARACTER FORMAT "X(256)":U
     LABEL "Статус"
     VIEW-AS COMBO-BOX INNER-LINES 5
     DROP-DOWN-LIST
     SIZE 16 BY 1 TOOLTIP "Конечный статус сгенеренного счета-фактуры" NO-UNDO.
DEFINE VARIABLE COMBO-return-type AS INTEGER FORMAT "->,>>>,>>9" INITIAL 0
     LABEL "Схема возврата"
     VIEW-AS COMBO-BOX INNER-LINES 3
     LIST-ITEM-PAIRS "",0,
                     "Обратная продажа",23,
                     "Корректировка поступления",25
     DROP-DOWN-LIST
     SIZE 26.25 BY 1 TOOLTIP "Схема возврата поставщику" NO-UNDO.
DEFINE VARIABLE COMBO-type-contr AS CHARACTER FORMAT "X(256)":U
     LABEL "Тип"
     VIEW-AS COMBO-BOX INNER-LINES 7
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 40.5 BY 1 NO-UNDO.
DEFINE VARIABLE COMBO-usl-opl AS CHARACTER FORMAT "X(256)":U
     LABEL "ФО"
     VIEW-AS COMBO-BOX INNER-LINES 18
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 40.25 BY 1 TOOLTIP "Условие генерации финансового обязательства" NO-UNDO.
DEFINE VARIABLE COMBO-usl-opl-2 AS CHARACTER FORMAT "X(256)":U
     LABEL "Счета-фактуры"
     VIEW-AS COMBO-BOX INNER-LINES 9
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 40.25 BY 1 TOOLTIP "Условие генерации счетов-фактур" NO-UNDO.
DEFINE VARIABLE agnt-code AS INTEGER FORMAT ">>>>>>>>>>>9" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 10 BY 1.
DEFINE VARIABLE agnt-name AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 52 BY 1.
DEFINE VARIABLE agnt-type AS CHARACTER FORMAT "X(3)"
     VIEW-AS FILL-IN
     SIZE 4.38 BY 1.
DEFINE VARIABLE an-uchet AS CHARACTER FORMAT "X(256)":U
     LABEL "Код аналитического учета"
     VIEW-AS FILL-IN
     SIZE 40 BY 1 NO-UNDO.
DEFINE VARIABLE balance-fo AS DECIMAL FORMAT "->>>,>>>,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "Баланс"
     VIEW-AS FILL-IN
     SIZE 17.88 BY 1 NO-UNDO.
DEFINE VARIABLE cel-nazn AS CHARACTER FORMAT "X(256)":U
     LABEL "Код целевого назначения"
     VIEW-AS FILL-IN
     SIZE 40 BY 1 NO-UNDO.
DEFINE VARIABLE cli-code AS INTEGER FORMAT ">>>>>>>>>>>9" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 10 BY 1.
DEFINE VARIABLE cli-name AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 52 BY 1.
DEFINE VARIABLE cli-type AS CHARACTER FORMAT "X(3)"
     VIEW-AS FILL-IN
     SIZE 4.38 BY 1.
DEFINE VARIABLE contract-city AS CHARACTER FORMAT "X(20)"
     LABEL "Город"
     VIEW-AS FILL-IN
     SIZE 19.5 BY 1.
DEFINE VARIABLE contract-code AS INTEGER FORMAT ">>>>>>>>>" INITIAL 0
     LABEL "Вн.№."
      VIEW-AS TEXT
     SIZE 11.38 BY .67
     FGCOLOR 4 .
DEFINE VARIABLE contract-date AS DATE FORMAT "99/99/9999" INITIAL 10/13/03
     LABEL "Дата"
     VIEW-AS FILL-IN
     SIZE 11.13 BY 1.
DEFINE VARIABLE contract-date-beg AS DATE FORMAT "99/99/9999" INITIAL 10/13/03
     LABEL "Действие с"
     VIEW-AS FILL-IN
     SIZE 11.13 BY 1 TOOLTIP "Начало действия договора".
DEFINE VARIABLE contract-date-end AS DATE FORMAT "99/99/9999"
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 TOOLTIP "Окончание дейстия договора".
DEFINE VARIABLE contract-name AS CHARACTER FORMAT "X(85)"
     LABEL "Заголовок"
     VIEW-AS FILL-IN
     SIZE 66.5 BY 1.
DEFINE VARIABLE contract-prn-code AS CHARACTER FORMAT "X(48)"
     LABEL "№"
     VIEW-AS FILL-IN
     SIZE 31 BY 1.
DEFINE VARIABLE cor-acc AS CHARACTER FORMAT "X(256)":U
     LABEL "Корреспондирующий счет"
     VIEW-AS FILL-IN
     SIZE 40 BY 1 NO-UNDO.
DEFINE VARIABLE cor-acc-2 AS CHARACTER FORMAT "X(256)":U
     LABEL "Корресп. счет (касса)"
     VIEW-AS FILL-IN
     SIZE 40 BY 1 NO-UNDO.
DEFINE VARIABLE curr-code AS INTEGER FORMAT ">>9" INITIAL 0
     LABEL "Валюта договора"
     VIEW-AS FILL-IN
     SIZE 3.75 BY 1
     FGCOLOR 4 .
DEFINE VARIABLE curr-name AS CHARACTER FORMAT "X(5)":U
      VIEW-AS TEXT
     SIZE 4.75 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fin-VAT-pc AS DECIMAL FORMAT ">9.9<%" INITIAL 0
     LABEL "НДС"
     VIEW-AS FILL-IN
     SIZE 6 BY 1.
DEFINE VARIABLE kredit-sum AS DECIMAL FORMAT "->>>,>>>,>>>,>>>,>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 18.13 BY 1 NO-UNDO.
DEFINE VARIABLE mngr-code AS INTEGER FORMAT ">>>>>>>>>>>9" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 10 BY 1.
DEFINE VARIABLE mngr-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 52 BY 1 NO-UNDO.
DEFINE VARIABLE own-code AS INTEGER FORMAT ">>>>>>>>9" INITIAL 0
      VIEW-AS TEXT
     SIZE 10 BY 1.
DEFINE VARIABLE own-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 60.5 BY .75 NO-UNDO.
DEFINE VARIABLE posr-code AS INTEGER FORMAT ">>>>>>>>>>>9" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 10 BY 1.
DEFINE VARIABLE posr-name AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 52 BY 1.
DEFINE VARIABLE posr-type AS CHARACTER FORMAT "X(3)"
     VIEW-AS FILL-IN
     SIZE 4.38 BY 1.
DEFINE VARIABLE srok-opl AS INTEGER FORMAT ">>9" INITIAL 0
     LABEL "Срок"
     VIEW-AS FILL-IN
     SIZE 4.38 BY 1.
DEFINE VARIABLE srok-opl-2 AS INTEGER FORMAT ">>9" INITIAL 0
     LABEL "Срок"
     VIEW-AS FILL-IN
     SIZE 4.38 BY 1.
DEFINE VARIABLE str-uslov-oplat AS CHARACTER FORMAT "X(30)"
     LABEL "Условия оплаты"
     VIEW-AS FILL-IN
     SIZE 46.5 BY 1 TOOLTIP "Условия оплаты".
DEFINE VARIABLE b-nal AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "б/н", 1,
"нал.", 2,
"АПЗ", 3
     SIZE 9 BY 2.08 TOOLTIP "Форма платежа" NO-UNDO.
DEFINE VARIABLE RADIO-SET-1 AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "РПП", 1,
"ППП", 2,
"РКО", 3,
"ПКО", 4,
"Рс.АПЗ", 5,
"Пр.АПЗ", 6
     SIZE 9.5 BY 4.21 TOOLTIP "Тип платежа" NO-UNDO.
DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 97.38 BY 2.75.
DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 97.38 BY 7.67.
DEFINE VARIABLE kredit-limit AS LOGICAL INITIAL no
     LABEL "Ограничение кредита"
     VIEW-AS TOGGLE-BOX
     SIZE 22.25 BY 1 NO-UNDO.
DEFINE VARIABLE T-diadoc AS LOGICAL INITIAL no
     LABEL "Поставки через Диадок"
     VIEW-AS TOGGLE-BOX
     SIZE 24.5 BY .83 NO-UNDO.
DEFINE VARIABLE T-edi AS LOGICAL INITIAL no
     LABEL "Поставки через ЭДО"
     VIEW-AS TOGGLE-BOX
     SIZE 21.5 BY .83 NO-UNDO.
DEFINE VARIABLE T-edi-order AS LOGICAL INITIAL no
     LABEL "Электронные заказы EDI"
     VIEW-AS TOGGLE-BOX
     SIZE 24.5 BY .83 NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      contract SCROLLING.
DEFINE FRAME Dialog-Frame
     b-OK AT ROW 1 COL 1
     b-exit AT ROW 1 COL 11
     b-prev AT ROW 1 COL 21
     b-next AT ROW 1 COL 26
     b-spec AT ROW 1 COL 35
     B-transport AT ROW 1 COL 49
     B-Add-Inf AT ROW 1 COL 59 WIDGET-ID 10
     b-hist AT ROW 1 COL 78
     B-Help AT ROW 1 COL 88
     T-edi AT ROW 1.13 COL 70 WIDGET-ID 12
     T-diadoc AT ROW 1.88 COL 70 WIDGET-ID 14
     T-edi-order AT ROW 2.63 COL 70 WIDGET-ID 16
     contract-prn-code AT ROW 3.58 COL 2.5 COLON-ALIGNED
     contract-date AT ROW 3.58 COL 39.75 COLON-ALIGNED
     contract-city AT ROW 3.58 COL 58.5 COLON-ALIGNED
     contract-name AT ROW 4.67 COL 12 COLON-ALIGNED
     BUTTON-curr AT ROW 5.58 COL 89
     contract-date-beg AT ROW 5.67 COL 12 COLON-ALIGNED
     contract-date-end AT ROW 5.67 COL 27.63 COLON-ALIGNED
     curr-code AT ROW 5.67 COL 83 COLON-ALIGNED
     COMBO-return-type AT ROW 6.58 COL 70 COLON-ALIGNED
     COMBO-type-contr AT ROW 6.67 COL 12 COLON-ALIGNED
     b-bank-own AT ROW 7.58 COL 85.13
     b-bank-cli AT ROW 8.58 COL 85.13
     cli-code AT ROW 8.45 COL 12 COLON-ALIGNED NO-LABEL
     cli-type AT ROW 8.45 COL 22.13 COLON-ALIGNED NO-LABEL
     BUTTON-cli AT ROW 8.45 COL 28.75
     b-bank-posr AT ROW 9.58 COL 85.13
     posr-code AT ROW 9.23 COL 12 COLON-ALIGNED NO-LABEL
     posr-type AT ROW 9.23 COL 22.13 COLON-ALIGNED NO-LABEL
     BUTTON-posr AT ROW 9.23 COL 28.75
     b-bank-agnt AT ROW 10.58 COL 85.13
     agnt-code AT ROW 10.75 COL 12 COLON-ALIGNED NO-LABEL
     agnt-type AT ROW 10.75 COL 22.13 COLON-ALIGNED NO-LABEL
     BUTTON-agnt AT ROW 10.75 COL 28.75
     mngr-code AT ROW 10.03 COL 12 COLON-ALIGNED NO-LABEL
     BUTTON-mngr AT ROW 10.03 COL 28.75
     COMBO-usl-opl AT ROW 13.46 COL 16 COLON-ALIGNED
     srok-opl AT ROW 13.46 COL 65 COLON-ALIGNED
     COMBO-auto-pay AT ROW 13.46 COL 79.5 COLON-ALIGNED
     COMBO-usl-opl-2 AT ROW 14.54 COL 16 COLON-ALIGNED
     srok-opl-2 AT ROW 14.54 COL 65 COLON-ALIGNED
     COMBO-auto-pay-2 AT ROW 14.54 COL 79.5 COLON-ALIGNED
     kredit-limit AT ROW 16.67 COL 2.5
     kredit-sum AT ROW 16.67 COL 23 COLON-ALIGNED NO-LABEL
     balance-fo AT ROW 16.67 COL 77.63 COLON-ALIGNED
     str-uslov-oplat AT ROW 17.71 COL 23 COLON-ALIGNED
     fin-VAT-pc AT ROW 17.71 COL 77.63 COLON-ALIGNED
     RADIO-SET-1 AT ROW 19.33 COL 2.5 NO-LABEL
     b-nal AT ROW 19.33 COL 14 NO-LABEL
     cor-acc AT ROW 19.5 COL 53.5 COLON-ALIGNED
     b-cor-acc AT ROW 19.5 COL 94.88
     an-uchet AT ROW 20.5 COL 53.5 COLON-ALIGNED
     b-an-uchet AT ROW 20.5 COL 94.88
     cel-nazn AT ROW 21.5 COL 53.5 COLON-ALIGNED
     b-cel-nazn AT ROW 21.5 COL 94.88
     cor-acc-2 AT ROW 22.5 COL 53.5 COLON-ALIGNED
     b-cor-acc-2 AT ROW 22.5 COL 94.88
     contract-code AT ROW 3.58 COL 85.63 COLON-ALIGNED
     curr-name AT ROW 5.58 COL 90.5 COLON-ALIGNED NO-LABEL
     own-code AT ROW 7.67 COL 12.25 COLON-ALIGNED NO-LABEL
     own-name AT ROW 7.83 COL 21.5 COLON-ALIGNED NO-LABEL
     cli-name AT ROW 8.45 COL 31.75 NO-LABEL
     posr-name AT ROW 9.23 COL 31.75 NO-LABEL
     agnt-name AT ROW 10.75 COL 31.75 NO-LABEL
     mngr-name AT ROW 10.03 COL 31.75 NO-LABEL
     "ГЕНЕРАЦИЯ" VIEW-AS TEXT
          SIZE 10.5 BY .83 AT ROW 12.0 COL 1.5 WIDGET-ID 2
          FGCOLOR 4
     "Фирма:" VIEW-AS TEXT
          SIZE 6.13 BY .92 AT ROW 7.67 COL 7
          FGCOLOR 4
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE .
DEFINE FRAME Dialog-Frame
     "Контрагент:" VIEW-AS TEXT
          SIZE 11.5 BY 1 AT ROW 8.45 COL 2
          FGCOLOR 4
     "Посредник:" VIEW-AS TEXT
          SIZE 10.13 BY 1 AT ROW 9.23 COL 2.88
          FGCOLOR 4
     "Исполнитель:" VIEW-AS TEXT
          SIZE 12 BY 1 AT ROW 9.95 COL 1.13
          FGCOLOR 4
     "Агент:" VIEW-AS TEXT
          SIZE 6.13 BY 1 AT ROW 10.75 COL 6.88
          FGCOLOR 4
     "ОПЛАТА" VIEW-AS TEXT
          SIZE 7 BY .83 AT ROW 14.58 COL 1.5
          FGCOLOR 4
     RECT-8 AT ROW 13.13 COL 1.25 WIDGET-ID 4
     RECT-9 AT ROW 16.13 COL 1.25 WIDGET-ID 6
     SPACE(0.61) SKIP(0.19)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Договор".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       an-uchet:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       B-Add-Inf:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       b-next:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       b-prev:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       balance-fo:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       cel-nazn:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       contract-code:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       cor-acc:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       cor-acc-2:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON END-ERROR OF FRAME Dialog-Frame
DO:
  if ref-mode = 'ИЗМЕНЕНИЕ':U or ref-mode = 'ДОБАВЛЕНИЕ':U then do:
    message "Отменить сделанные изменения?"  view-as alert-box QUESTION BUTTONS YES-NO update g-log .
    if g-log = no then return no-apply.
    next-prev = ?.
  end.
END.
ON LEAVE OF agnt-code IN FRAME Dialog-Frame
DO:
  if agnt-code = int ( agnt-code:screen-value ) then return.
  assign agnt-code.
  run find-cli in this-procedure (input 3, input agnt-type, input agnt-code) .
END.
ON RETURN OF agnt-code IN FRAME Dialog-Frame
DO:
  if agnt-code = int ( agnt-code:screen-value ) then return.
  assign agnt-code.
  run find-cli in this-procedure (input 3, input agnt-type, input agnt-code) .
END.
ON LEAVE OF agnt-type IN FRAME Dialog-Frame
DO:
  assign agnt-type.
  run find-cli in this-procedure (input 3, input agnt-type, input agnt-code) .
END.
ON CHOOSE OF B-Add-Inf IN FRAME Dialog-Frame
DO:
   DEF VAR cError AS CHARACTER NO-UNDO INITIAL "".
   RUN str/contaddi.w(
           INPUT parParentProc,
           INPUT THIS-PROCEDURE:HANDLE,
           INPUT ref-mode,
           INPUT p-doc-type,
           INPUT ri,
           OUTPUT cError
          ).
   IF cError <> ""  THEN DO:
      MESSAGE cError
          VIEW-AS ALERT-BOX INFO BUTTONS OK.
   END.
   RETURN NO-APPLY.
END.
ON CHOOSE OF b-an-uchet IN FRAME Dialog-Frame
DO:
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  define variable rid-list as  char no-undo .
  define variable p-rec    as recid no-undo.
  assign p-rec = ? .
  if a-code-an-uchet [RADIO-SET-1] <> ? then do:
    find first ub.fin-code-an-uchet no-lock where ub.fin-code-an-uchet.fin-code = a-code-an-uchet [RADIO-SET-1] and ub.fin-code-an-uchet.host-code = p-host-code no-error .
    if available ub.fin-code-an-uchet then assign p-rec = recid (ub.fin-code-an-uchet) .
  end.
  run ref/fwcode-3.w  ( input parParentProc, input "b-sel", input 'фирма':U, input p-rec, input p-host-code, output rid-list )  .
  if rid-list <> "" then do:
    find first ub.fin-code-an-uchet no-lock where RECID(ub.fin-code-an-uchet) = int (rid-list) no-error .
    if available ub.fin-code-an-uchet then
      assign
        an-uchet = ub.fin-code-an-uchet.code-value + "  " + ub.fin-code-an-uchet.descr
        a-code-an-uchet [RADIO-SET-1] = ub.fin-code-an-uchet.fin-code
      .
    else assign a-code-an-uchet [RADIO-SET-1] = ?  an-uchet = "" .
  end.
  else assign a-code-an-uchet [RADIO-SET-1] = ?  an-uchet = "" .
  display an-uchet with frame Dialog-Frame.
END.
ON CHOOSE OF b-bank-agnt IN FRAME Dialog-Frame
DO:
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  if agnt-code > 0 and ( agnt-type = 'чел':U or agnt-type = 'орг':U ) then do:
    run str/cont-rcw.w (input parParentProc, input p-host-code, input 3, input ref-mode, input agnt-code, input agnt-type,
                  input-output agnt-name, input-output v-agnt-code-schet, input-output v-agnt-code-schet-2, input-output kpp-agnt,
                  input-output inn-agnt, input-output addres-agnt, input-output sign-agnt, input-output sign-post-agnt,
                  input-output v-agnt-point-code,input-output v-agnt-point-db-num
                  ).
    display agnt-name with frame Dialog-Frame.
  end.
  else do:
    message "Не выбран агент!"  view-as alert-box.
    apply "ENTRY" to agnt-code in frame Dialog-Frame .
  end.
END.
ON CHOOSE OF b-bank-cli IN FRAME Dialog-Frame
DO:
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  if cli-code > 0 and ( cli-type = 'чел':U or cli-type = 'орг':U ) then do:
    run str/cont-rcw.w (input parParentProc, input p-host-code, input 1, input ref-mode, input cli-code, input cli-type,
                  input-output cli-name, input-output v-cli-code-schet, input-output v-cli-code-schet-2, input-output kpp-cli,
                  input-output inn-cli, input-output addres-cli, input-output sign-cli, input-output sign-post-cli,
                  input-output v-cli-point-code,input-output v-cli-point-db-num
                  ).
    display cli-name with frame Dialog-Frame.
  end.
  else do:
    message "Не выбран контрагент!"  view-as alert-box.
    apply "ENTRY" to cli-code in frame Dialog-Frame .
  end.
END.
ON CHOOSE OF b-bank-own IN FRAME Dialog-Frame
DO:
define variable vss-include-info10 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  run str/cont-rcw.w (input parParentProc, input p-host-code, input 0, input ref-mode, input p-host-code, input 'орг':U,
                  input-output own-name, input-output v-own-code-schet, input-output v-own-code-schet-2, input-output kpp-own,
                  input-output inn-own, input-output addres-own, input-output sign-own, input-output sign-post-own,
                  input-output v-own-point-code,input-output v-own-point-db-num
                  ).
  display own-name with frame Dialog-Frame.
END.
ON CHOOSE OF b-bank-posr IN FRAME Dialog-Frame
DO:
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  if posr-code > 0 and ( posr-type = 'чел':U or posr-type = 'орг':U ) then do:
    run str/cont-rcw.w (input parParentProc, input p-host-code, input 2, input ref-mode, input posr-code, input posr-type,
                  input-output posr-name, input-output v-posr-code-schet, input-output v-posr-code-schet-2, input-output kpp-posr,
                  input-output inn-posr, input-output addres-posr, input-output sign-posr, input-output sign-post-posr,
                  input-output v-posr-point-code,input-output v-posr-point-db-num
                  ).
    display posr-name with frame Dialog-Frame.
  end.
  else do:
    message "Не выбран посредник!"  view-as alert-box.
    apply "ENTRY" to posr-code in frame Dialog-Frame .
  end.
END.
ON CHOOSE OF b-cel-nazn IN FRAME Dialog-Frame
DO:
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  define variable rid-list as  char no-undo .
  define variable p-rec    as recid no-undo.
  assign p-rec = ? .
  if a-code-cel-nazn [RADIO-SET-1] <> ? then do:
    find first ub.fin-code-cel-nazn no-lock where ub.fin-code-cel-nazn.fin-code = a-code-cel-nazn [RADIO-SET-1] and ub.fin-code-cel-nazn.host-code = p-host-code no-error .
    if available ub.fin-code-cel-nazn then assign p-rec = recid (ub.fin-code-cel-nazn) .
  end.
  run ref/fwcode-2.w  ( input parParentProc, input "b-sel", input 'фирма':U, input p-rec, input p-host-code, output rid-list )  .
  if rid-list <> "" then do:
    find first ub.fin-code-cel-nazn no-lock where RECID(ub.fin-code-cel-nazn) = int (rid-list) no-error .
    if available ub.fin-code-cel-nazn then
      assign
        cel-nazn = ub.fin-code-cel-nazn.code-value + "  " + ub.fin-code-cel-nazn.descr
        a-code-cel-nazn [RADIO-SET-1] = ub.fin-code-cel-nazn.fin-code
      .
    else assign a-code-cel-nazn [RADIO-SET-1] = ?  cel-nazn = "" .
  end.
  else assign a-code-cel-nazn [RADIO-SET-1] = ?  cel-nazn = "" .
  display cel-nazn with frame Dialog-Frame.
END.
ON CHOOSE OF b-cor-acc IN FRAME Dialog-Frame
DO:
define variable vss-include-info13 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  define variable rid-list as  char no-undo .
  define variable p-rec    as recid no-undo.
  assign p-rec = ? .
  if a-code-cor-acc [RADIO-SET-1]<> ? then do:
    find first ub.fin-code-cor-acc no-lock where ub.fin-code-cor-acc.fin-code = a-code-cor-acc [RADIO-SET-1]and ub.fin-code-cor-acc.host-code = p-host-code no-error .
    if available ub.fin-code-cor-acc then assign p-rec = recid (ub.fin-code-cor-acc) .
  end.
  run ref/fwcode-1.w  ( input parParentProc, input "b-sel", input 'фирма':U, input p-rec, input p-host-code, output rid-list )  .
  if rid-list <> "" then do:
    find first ub.fin-code-cor-acc no-lock where RECID(ub.fin-code-cor-acc) = int (rid-list) no-error .
    if available ub.fin-code-cor-acc then
      assign
        cor-acc = ub.fin-code-cor-acc.code-value + "  " + ub.fin-code-cor-acc.descr
        a-code-cor-acc [RADIO-SET-1]= ub.fin-code-cor-acc.fin-code
      .
    else assign a-code-cor-acc [RADIO-SET-1]= ?  cor-acc = "" .
  end.
  else assign a-code-cor-acc [RADIO-SET-1]= ?  cor-acc = "" .
  display cor-acc with frame Dialog-Frame.
END.
ON CHOOSE OF b-cor-acc-2 IN FRAME Dialog-Frame
DO:
define variable vss-include-info14 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  define variable rid-list as  char no-undo .
  define variable p-rec    as recid no-undo.
  assign p-rec = ? .
  if a-code-cor-acc-2 [RADIO-SET-1]<> ? then do:
    find first ub.fin-code-cor-acc no-lock where ub.fin-code-cor-acc.fin-code = a-code-cor-acc-2 [RADIO-SET-1]and ub.fin-code-cor-acc.host-code = p-host-code no-error .
    if available ub.fin-code-cor-acc then assign p-rec = recid (ub.fin-code-cor-acc) .
  end.
  run ref/fwcode-1.w  ( input parParentProc, input "b-sel", input 'фирма':U, input p-rec, input p-host-code, output rid-list )  .
  if rid-list <> "" then do:
    find first ub.fin-code-cor-acc no-lock where RECID(ub.fin-code-cor-acc) = int (rid-list) no-error .
    if available ub.fin-code-cor-acc then
      assign
        cor-acc-2 = ub.fin-code-cor-acc.code-value + "  " + ub.fin-code-cor-acc.descr
        a-code-cor-acc-2 [RADIO-SET-1]= ub.fin-code-cor-acc.fin-code
      .
    else assign a-code-cor-acc-2 [RADIO-SET-1]= ?  cor-acc-2 = "" .
  end.
  else assign a-code-cor-acc-2 [RADIO-SET-1]= ?  cor-acc-2 = "" .
  display cor-acc-2 with frame Dialog-Frame.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
  next-prev = ?.
  if ref-mode = 'ИЗМЕНЕНИЕ':U or ref-mode = 'ДОБАВЛЕНИЕ':U then do:
    message "Отменить сделанные изменения?"  view-as alert-box QUESTION BUTTONS YES-NO update g-log .
    if g-log = no then return no-apply.
  end.
END.
ON CHOOSE OF b-hist IN FRAME Dialog-Frame
DO:
  if ref-mode = 'ИЗМЕНЕНИЕ':U or ref-mode = 'ПРОСМОТР':U then do:
    define variable v-ri as character initial "" no-undo .
    if available b_contract then run str/contr-c.w (input parparentproc,input p-host-code, input b_contract.contract-code,input "",input-output v-ri) .
  end.
END.
ON VALUE-CHANGED OF b-nal IN FRAME Dialog-Frame
DO:
  assign b-nal .
END.
ON CHOOSE OF b-next IN FRAME Dialog-Frame
DO:
run step-next.
END.
ON CHOOSE OF b-OK IN FRAME Dialog-Frame
DO:
  next-prev = ? .
  if ref-mode = 'ИЗМЕНЕНИЕ':U or ref-mode = 'ДОБАВЛЕНИЕ':U then do:
define variable vss-include-info15 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
    assign
      contract-date COMBO-type-contr COMBO-usl-opl srok-opl contract-name contract-prn-code contract-city own-name
      contract-date-beg  contract-date-end  curr-code cli-type cli-code posr-type posr-code  agnt-type
      agnt-code mngr-code str-uslov-oplat COMBO-auto-pay RADIO-SET-1 COMBO-usl-opl-2 COMBO-auto-pay-2 srok-opl-2 T-edi t-diadoc
      COMBO-return-type T-edi-order
    .
    run create-proc in this-procedure no-error .
    if error-status:error then return no-apply.
  end.
END.
ON CHOOSE OF b-prev IN FRAME Dialog-Frame
DO:
   run step-prev.
END.
ON CHOOSE OF b-spec IN FRAME Dialog-Frame
DO:
  define variable v-rid-list as char no-undo.
  ASSIGN
     iTmp-Host-Code       = p-host-code
     iTmp-Contract-Code   = buf_contract.contract-code
     cTmp-Mode-W          = ref-mode
     .
  IF v-iMcMode = 1 OR v-iMcMode = 2 THEN DO:
     RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
         INPUT  p-Host-Code,
         INPUT  contract-code,
         OUTPUT i-Cont-Ret
         ).
     IF i-Cont-Ret[1] = 2 THEN DO:
        ASSIGN
           iTmp-Host-Code       = i-Cont-Ret[2]
           iTmp-Contract-Code   = i-Cont-Ret[3]
           cTmp-Mode-W          = 'ПРОСМОТР':U
           .
     END.
  END.
  RUN str/contspec.w (
      INPUT  parparentproc,
      INPUT  "b-mark",
      INPUT  cTmp-Mode-W,
      INPUT  iTmp-Host-Code,
      INPUT  iTmp-Contract-Code,
      OUTPUT v-rid-list
      ).
END.
ON CHOOSE OF B-transport IN FRAME Dialog-Frame
DO:
  run adm/conftran.w ( input if ref-mode = 'ДОБАВЛЕНИЕ':U then 'ИЗМЕНЕНИЕ':U else ref-mode ,
                       input "contract",
                       input p-host-code,
                       input parParentProc,
                       input-output v-transport-cli-type ,
                       input-output v-transport-cli-code ,
                       input-output v-transport-host,
                       input-output v-transport-contract,
                       input-output v-transport-uslov,
                       input-output v-transport-value,
                       input-output v-transport-type
                       ).
END.
ON CHOOSE OF BUTTON-agnt IN FRAME Dialog-Frame
DO:
  run ref/cli-all.w ( parParentProc, "b-sel", 'все':U, 'все':U, 'текущие':U, ?, ",,,,,,NO,,":u, "without-obj":U, output agnt-list ) .
  if agnt-list <> "" then do:
    find first ub.clients no-lock where RECID(ub.clients) = int (agnt-list) no-error.
    if ub.clients.obj-type <> 'чел':U and ub.clients.obj-type <> 'орг':U then do:
      message
        "Агент может быть только " 'орг':U " или " 'чел':U
        view-as alert-box ERROR .
      return no-apply.
    end.
    run find-cli in this-procedure (input 3, input ub.clients.obj-type, input ub.clients.obj-code) .
  end.
  else do:
    assign agnt-name = ""  inn-agnt = ""  addres-agnt = ""  agnt-code = ?  agnt-type = ? .
    display agnt-name   agnt-code    agnt-type  with frame Dialog-Frame.
  end.
END.
ON CHOOSE OF BUTTON-cli IN FRAME Dialog-Frame
DO:
  run ref/cli-all.w (parParentProc, "b-sel", 'все':U, 'все':U, 'текущие':U, ?, ",,,,,,NO,,":u, "without-obj":U, output agnt-list ) .
  if agnt-list <> "" then do:
    find first ub.clients no-lock where RECID(ub.clients) = int (agnt-list) no-error.
    if ub.clients.obj-type <> 'чел':U and ub.clients.obj-type <> 'орг':U then do:
      message
        "Контрагент может быть только " 'орг':U " или " 'чел':U
        view-as alert-box ERROR .
      return no-apply.
    end.
    run find-cli in this-procedure (input 1, input ub.clients.obj-type, input ub.clients.obj-code) .
  end.
  else do:
    assign cli-name = ""  inn-cli = ""  addres-cli = ""  cli-code = ?  cli-type  = ? .
    display cli-name    cli-code     cli-type   with frame Dialog-Frame.
  end.
END.
ON CHOOSE OF BUTTON-curr IN FRAME Dialog-Frame
DO:
  assign
  ref-rec = ?.
  run ref/currency.w (input parparentproc, "b-sel", input-output ref-rec ).
  if ref-rec = ? then return no-apply.
  find ub.currency where recid ( ub.currency ) = ref-rec no-lock.
  assign
    curr-code = ub.currency.curr-code
    curr-name = ub.currency.curr-abbr
  .
  display curr-name curr-code with frame Dialog-Frame.
END.
ON CHOOSE OF BUTTON-mngr IN FRAME Dialog-Frame
DO:
  run ref/cli-all.w ( parParentProc, "b-sel", 'чел':U, 'все':U, 'текущие':U, ?, ",,,,,,NO,,":u, "without-obj":U, output agnt-list ) .
  if agnt-list <> "" then do:
    find first ub.clients no-lock where RECID(ub.clients) = int (agnt-list) no-error.
    if ub.clients.obj-type <> 'чел':U  then do:
      message
        "Исполнитель может быть только " 'чел':U
        view-as alert-box ERROR .
      return no-apply.
    end.
    if available ub.clients then assign  mngr-name = ub.clients.obj-name   mngr-code = ub.clients.obj-code  .
    else                      assign  mngr-name = ""                 mngr-code = ? .
  end.
  else assign mngr-name = ""  mngr-code = ? .
  display mngr-name  mngr-code with frame Dialog-Frame.
END.
ON CHOOSE OF BUTTON-posr IN FRAME Dialog-Frame
DO:
  run ref/cli-all.w ( parParentProc, "b-sel", 'все':U, 'все':U, 'текущие':U, ?, ",,,,,,NO,,":u, "without-obj":U, output agnt-list ) .
  if agnt-list <> "" then do:
    find first ub.clients no-lock where RECID(ub.clients) = int (agnt-list) no-error.
    if ub.clients.obj-type <> 'чел':U and ub.clients.obj-type <> 'орг':U then do:
      message
        "Посредник может быть только " 'орг':U " или " 'чел':U
        view-as alert-box ERROR .
      return no-apply.
    end.
    run find-cli in this-procedure (input 2, input ub.clients.obj-type, input ub.clients.obj-code) .
  end.
  else do:
    assign posr-name = ""  inn-posr = ""  addres-posr = ""  posr-code = ?  posr-type = ? .
    display posr-name   posr-code    posr-type  with frame Dialog-Frame.
  end.
END.
ON LEAVE OF cli-code IN FRAME Dialog-Frame
DO:
  if cli-code = int ( cli-code:screen-value ) then return.
  assign cli-code.
  run find-cli in this-procedure (input 1, input cli-type, input cli-code)  .
END.
ON RETURN OF cli-code IN FRAME Dialog-Frame
DO:
  if cli-code = int ( cli-code:screen-value ) then return.
  assign cli-code.
  run find-cli in this-procedure (input 1, input cli-type, input cli-code)  .
END.
ON LEAVE OF cli-type IN FRAME Dialog-Frame
DO:
  assign cli-type.
  run find-cli in this-procedure (input 1, input cli-type, input cli-code)  .
END.
ON VALUE-CHANGED OF COMBO-usl-opl IN FRAME Dialog-Frame
DO:
  assign COMBO-usl-opl .
  assign srok-opl = 0 .
  if p-doc-type = 'при':U then do:
    if COMBO-usl-opl = 'По реализации части приход. накладной':U then assign srok-opl:label = "> %" .
       else assign srok-opl:label = "Срок" .
    if   COMBO-usl-opl = 'Отсрочка платежа (по реализации)':U
      or COMBO-usl-opl = 'Отсрочка платежа (по поставке)':U
      or COMBO-usl-opl = 'По реализации части приход. накладной':U
      or COMBO-usl-opl = 'Отсрочка платежа по поставке заказа':U
      or COMBO-usl-opl = 'Отсрочка платежа по заказу':U
      or COMBO-usl-opl = 'Отсрочка платежа по спецификации':U
      then do:
        display srok-opl with frame Dialog-Frame.
        enable srok-opl with frame Dialog-Frame.
      end.
      else do:
        disable srok-opl with frame Dialog-Frame.
      end.
  end.
  else do:
    if COMBO-usl-opl = 'Предоплата(%)':U then assign srok-opl:label = "> %" .
       else assign srok-opl:label = "Срок" .
    if COMBO-usl-opl = 'Предоплата(%)':U or COMBO-usl-opl:screen-value = 'Отсрочка платежа по поставке':U
      then  do:
         display srok-opl with frame Dialog-Frame.
         enable srok-opl with frame Dialog-Frame.
      end.
      else do:
         disable srok-opl with frame Dialog-Frame.
      end.
  end.
  display srok-opl with frame Dialog-Frame.
END.
ON VALUE-CHANGED OF COMBO-usl-opl-2 IN FRAME Dialog-Frame
DO:
  assign COMBO-usl-opl-2 .
  assign srok-opl-2 = 0 .
  disable srok-opl-2 with frame Dialog-Frame.
  display srok-opl-2 with frame Dialog-Frame.
END.
ON LEAVE OF curr-code IN FRAME Dialog-Frame
DO:
  assign curr-code .
  find first ub.currency where ub.currency.curr-code = curr-code no-error.
  if not available ub.currency then do:
    assign
    ref-rec = ?.
    run ref/currency.w (input parparentproc, "b-sel", input-output ref-rec ).
    if ref-rec = ? then return no-apply.
    find ub.currency where recid ( ub.currency ) = ref-rec.
  end.
  assign curr-name = ub.currency.curr-abbr .
  display curr-name with frame Dialog-Frame.
END.
ON RETURN OF curr-code IN FRAME Dialog-Frame
DO:
  assign curr-code .
  find first ub.currency where ub.currency.curr-code = curr-code no-error.
  if not available ub.currency then do:
    assign
    ref-rec = ?.
    run ref/currency.w (input parparentproc, "b-sel", input-output ref-rec ).
    if ref-rec = ? then return no-apply.
    find ub.currency where recid ( ub.currency ) = ref-rec.
  end.
  assign curr-name = ub.currency.curr-abbr .
  display curr-name with frame Dialog-Frame.
END.
ON VALUE-CHANGED OF kredit-limit IN FRAME Dialog-Frame
DO:
  assign kredit-limit .
  if kredit-limit = no  then  disable kredit-sum with frame Dialog-Frame.
  else                        enable  kredit-sum with frame Dialog-Frame.
END.
ON LEAVE OF mngr-code IN FRAME Dialog-Frame
DO:
  assign mngr-code.
  find first ub.clients no-lock where ub.clients.obj-type = 'чел':U and ub.clients.obj-code = mngr-code no-error.
  if not available ub.clients then do:
    if mngr-code = 0 then assign mngr-code = ? .
    if mngr-code = ? then do:
      assign  mngr-name = "" .
      display mngr-name with frame Dialog-Frame.
    end.
    else apply "CHOOSE" to BUTTON-mngr IN FRAME Dialog-Frame .
  end.
  else do:
    assign  mngr-name = ub.clients.obj-name .
    display mngr-name with frame Dialog-Frame.
  end.
END.
ON RETURN OF mngr-code IN FRAME Dialog-Frame
DO:
  assign mngr-code.
  find first ub.clients no-lock where ub.clients.obj-type = 'чел':U and ub.clients.obj-code = mngr-code no-error.
  if not available ub.clients then do:
    if mngr-code = 0 then assign mngr-code = ? .
    if mngr-code = ? then do:
      assign  mngr-name = "" .
      display mngr-name with frame Dialog-Frame.
    end.
    else apply "CHOOSE" to BUTTON-mngr IN FRAME Dialog-Frame .
  end.
  else do:
    assign  mngr-name = ub.clients.obj-name .
    display mngr-name with frame Dialog-Frame.
  end.
END.
ON LEAVE OF posr-code IN FRAME Dialog-Frame
DO:
  if posr-code = int ( posr-code:screen-value ) then return.
  assign posr-code.
  run find-cli in this-procedure (input 2, input posr-type, input posr-code)  .
END.
ON RETURN OF posr-code IN FRAME Dialog-Frame
DO:
  if posr-code = int ( posr-code:screen-value ) then return.
  assign posr-code.
  run find-cli in this-procedure (input 2, input posr-type, input posr-code)  .
END.
ON LEAVE OF posr-type IN FRAME Dialog-Frame
DO:
  assign posr-type.
  run find-cli in this-procedure (input 2, input posr-type, input posr-code)  .
END.
ON VALUE-CHANGED OF RADIO-SET-1 IN FRAME Dialog-Frame
DO:
  assign RADIO-SET-1 .
  find first ub.fin-code-an-uchet no-lock where ub.fin-code-an-uchet.fin-code = a-code-an-uchet [RADIO-SET-1] and ub.fin-code-an-uchet.host-code = p-host-code no-error .
  if available ub.fin-code-an-uchet then  assign an-uchet = ub.fin-code-an-uchet.code-value + "  " + ub.fin-code-an-uchet.descr  .
  else assign an-uchet = "" .
  find first ub.fin-code-cel-nazn no-lock where ub.fin-code-cel-nazn.fin-code  = a-code-cel-nazn [RADIO-SET-1] and ub.fin-code-cel-nazn.host-code = p-host-code no-error .
  if available ub.fin-code-cel-nazn then assign cel-nazn = ub.fin-code-cel-nazn.code-value + "  " + ub.fin-code-cel-nazn.descr .
  else assign cel-nazn = "" .
  find first ub.fin-code-cor-acc no-lock where ub.fin-code-cor-acc.fin-code  = a-code-cor-acc [RADIO-SET-1]and ub.fin-code-cor-acc.host-code = p-host-code no-error .
  if available ub.fin-code-cor-acc  then assign cor-acc = ub.fin-code-cor-acc.code-value + "  " + ub.fin-code-cor-acc.descr .
  else assign cor-acc = "" .
  find first ub.fin-code-cor-acc no-lock where ub.fin-code-cor-acc.fin-code  = a-code-cor-acc-2 [RADIO-SET-1]and ub.fin-code-cor-acc.host-code = p-host-code no-error .
  if available ub.fin-code-cor-acc  then assign   cor-acc-2 = ub.fin-code-cor-acc.code-value + "  " + ub.fin-code-cor-acc.descr .
  else assign cor-acc-2 = "" .
  display cor-acc-2 cor-acc cel-nazn an-uchet with frame Dialog-Frame.
  if RADIO-SET-1 > 2 then ENABLE  b-cor-acc-2 WITH FRAME Dialog-Frame.
  else  DISABLE  b-cor-acc-2 WITH FRAME Dialog-Frame.
END.
ON VALUE-CHANGED OF T-diadoc IN FRAME Dialog-Frame
DO:
  assign t-diadoc .
END.
ON VALUE-CHANGED OF T-edi IN FRAME Dialog-Frame
DO:
  assign t-edi .
END.
ON VALUE-CHANGED OF T-edi-order IN FRAME Dialog-Frame
DO:
  assign T-edi-order .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
ON WINDOW-CLOSE OF FRAME Dialog-Frame APPLY "END-ERROR":U TO SELF.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of contract-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of contract-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of contract-date in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of contract-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of contract-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of contract-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date19
    MENU-ITEM m-ed-date19-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date19-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date19-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date19-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if contract-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      contract-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date19 :HANDLE
      contract-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle19 as handle no-undo .
  assign
    v-label-handle19 = contract-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle19)
  then do:
    if v-label-handle19 :tooltip = ""
    or v-label-handle19 :tooltip = ?
    then do:
      assign
        v-label-handle19 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date19-1 in menu m-ed-date19 DO:
    apply "ctrl-b":U to contract-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date19-2 in menu m-ed-date19 DO:
    apply "ctrl-d":U to contract-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date19-3 in menu m-ed-date19 DO:
    apply "ctrl-e":U to contract-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date19-4 in menu m-ed-date19 DO:
    apply "ctrl-f":U to contract-date in frame Dialog-Frame .
  END.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of contract-date-beg in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of contract-date-beg in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of contract-date-beg in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of contract-date-beg in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of contract-date-beg in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of contract-date-beg in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date21
    MENU-ITEM m-ed-date21-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date21-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date21-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date21-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if contract-date-beg :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      contract-date-beg :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date21 :HANDLE
      contract-date-beg :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle21 as handle no-undo .
  assign
    v-label-handle21 = contract-date-beg :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle21)
  then do:
    if v-label-handle21 :tooltip = ""
    or v-label-handle21 :tooltip = ?
    then do:
      assign
        v-label-handle21 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date21-1 in menu m-ed-date21 DO:
    apply "ctrl-b":U to contract-date-beg in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date21-2 in menu m-ed-date21 DO:
    apply "ctrl-d":U to contract-date-beg in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date21-3 in menu m-ed-date21 DO:
    apply "ctrl-e":U to contract-date-beg in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date21-4 in menu m-ed-date21 DO:
    apply "ctrl-f":U to contract-date-beg in frame Dialog-Frame .
  END.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of contract-date-end in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of contract-date-end in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of contract-date-end in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of contract-date-end in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of contract-date-end in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of contract-date-end in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date23
    MENU-ITEM m-ed-date23-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date23-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date23-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date23-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if contract-date-end :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      contract-date-end :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date23 :HANDLE
      contract-date-end :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle23 as handle no-undo .
  assign
    v-label-handle23 = contract-date-end :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle23)
  then do:
    if v-label-handle23 :tooltip = ""
    or v-label-handle23 :tooltip = ?
    then do:
      assign
        v-label-handle23 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date23-1 in menu m-ed-date23 DO:
    apply "ctrl-b":U to contract-date-end in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date23-2 in menu m-ed-date23 DO:
    apply "ctrl-d":U to contract-date-end in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date23-3 in menu m-ed-date23 DO:
    apply "ctrl-e":U to contract-date-end in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date23-4 in menu m-ed-date23 DO:
    apply "ctrl-f":U to contract-date-end in frame Dialog-Frame .
  END.
next-prev = yes.
n-p: do while next-prev :
RUN adm/shattri.p (
      INPUT  "get":U,
      INPUT  "",
      INPUT  0,
      INPUT  "fin-global",
      INPUT  "fo-mc-mode",
      OUTPUT v-Character,
      OUTPUT v-Date,
      OUTPUT v-Decimal,
      OUTPUT v-iMcMode,
      OUTPUT v-Logical,
      OUTPUT v-Param-Type,
      INPUT-OUTPUT TABLE thbjattr_thbj-attr
    ) NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
   MESSAGE
      "Ошибка определения глобалоного параметра fin-global/fo-mc-mode" SKIP
      PROGRAM-NAME(1) ERROR-STATUS:GET-MESSAGE(1) RETURN-VALUE
      VIEW-AS ALERT-BOX.
END.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if p-doc-type begins "contract-type" then
      assign
        p-contr-type = entry(2,p-doc-type,"=")
        p-doc-type   = 'при':U
      .
  run enable_ui in this-procedure .
  run go-proc in this-procedure no-error.
  if error-status:error then return no-apply.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
end.
RUN disable_UI.
PROCEDURE create-proc :
  define variable  p-sys-date     as date      no-undo .
  define variable  p-sys-time     as character no-undo .
  define variable  p-sys-time-int as integer   no-undo .
  define variable  f-code         as integer   no-undo .
  define variable is-dup as logical no-undo .
  DEFINE VARIABLE v-cError AS CHARACTER NO-UNDO INITIAL "".
  DEFINE VARIABLE lChoice AS LOGICAL NO-UNDO INITIAL FALSE.
  if contract-date-beg <> ? and contract-date-end <> ? then do:
    if contract-date-beg > contract-date-end then do:
      message "Дата начала действия позже даты окончания действия!" view-as alert-box ERROR.
      return error.
    end.
  end.
  if (COMBO-usl-opl = 'По реализации части приход. накладной':U or COMBO-usl-opl = 'Предоплата(%)':U ) and srok-opl = 0 then do:
    message "Процент реализации не может быть 0 !" view-as alert-box ERROR.
    return error.
  end.
  if (COMBO-usl-opl = 'По реализации части приход. накладной':U or COMBO-usl-opl = 'Предоплата(%)':U ) and srok-opl > 100 then do:
    message "Процент реализации не может быть > 100 !" view-as alert-box ERROR.
    return error.
  end.
  if ( COMBO-usl-opl = 'Отсрочка платежа (по реализации)':U
    or COMBO-usl-opl = 'Отсрочка платежа (по поставке)':U
    or COMBO-usl-opl = 'Отсрочка платежа по поставке заказа':U
    or COMBO-usl-opl = 'Отсрочка платежа по поставке':U
    or COMBO-usl-opl = 'Отсрочка платежа по заказу':U
    or COMBO-usl-opl = 'Отсрочка платежа по спецификации':U )
    and srok-opl = 0 then do:
      message "Срок отсрочки не может быть 0 !" view-as alert-box ERROR.
      return error.
  end.
  if COMBO-return-type > 0
  then do :
    find first trn-reason no-lock where trn-reason.reason-code = COMBO-return-type no-error .
    if not available trn-reason
    then do :
      message "Указанная схема возврата в системе отсутствует. Для выбора данной схемы в договоре необходимо в справочник оснований добавить основание с кодом " string(COMBO-return-type) view-as alert-box ERROR.
      return error .
    end .
  end .
  if ref-mode = 'ДОБАВЛЕНИЕ':U then do:
    if p-doc-type <>  'при':U and  p-doc-type <> 'рас':U then do:
      message "Невозможно добавить договор неизвестного вида" view-as alert-box ERROR.
      return error.
    end.
    if cli-code = 0 or cli-code = ? then do:
      message "Не задан контрагент" view-as alert-box ERROR.
      apply "CHOOSE" to cli-code in frame Dialog-Frame .
      return error.
    end.
    if COMBO-type-contr = 'Ответственного хранения':U then do:
      if    COMBO-usl-opl <> 'Не определено':U
        and COMBO-usl-opl <> 'По факту реализации':U
        and COMBO-usl-opl <> 'Отсрочка платежа (по реализации)':U then do:
        message
        "Условия генерации для договора ответственного хранения " skip
        "допустимы только <По факту реализации>," skip
        "<Отсрочка платежа (по реализации)> и <Не определено>"
        view-as alert-box error .
        apply "CHOOSE" to COMBO-usl-opl in frame Dialog-Frame .
        return error .
      end.
    end.
    if COMBO-type-contr = 'Продажи через ТПСИ':U then do:
      if cli-type <> 'орг':U or not can-find(first ub.sysconf no-lock where ub.sysconf.host-code = cli-code) then do:
        message
        "Нельзя оформить договор типа <Продажа через ТПСИ>" skip
        "на контрагента, не являющегося СВОЕЙ ФИРМОЙ"
        view-as alert-box error .
        apply "CHOOSE" to cli-code in frame Dialog-Frame .
        return error .
      end.
      if can-find(first ub.contract no-lock where
                       ub.contract.host-code = p-host-code
                   AND ub.contract.cli-type = cli-type
                   AND ub.contract.cli-code = cli-code
                   and ub.contract.contract-type = 'Продажи через ТПСИ':U
                   and ub.contract.status_       = 'тек':U
                   ) then do:
        message
        "Нельзя оформить договор типа <Продажа через ТПСИ>," skip
        "уже есть действующий договор этого типа с фирмой" cli-code
        view-as alert-box error .
        apply "CHOOSE" to cli-code in frame Dialog-Frame .
        return error .
      end.
    end.
    find first ub.contract no-lock
      where ub.contract.contract-date     = contract-date
        and ub.contract.contract-prn-code = contract-prn-code
        and ub.contract.cli-type          = cli-type
        and ub.contract.cli-code          = cli-code
        and ub.contract.host-code         = p-host-code
    no-error .
    if available ub.contract then do:
      message substitute ("Уже есть договор № &1 от &2 с контрагентом &3 ! Продолжать &4 договора?" ,
             contract-prn-code ,
             string(contract-date,"99/99/9999"),
             cli-name ,
             ref-mode )
             view-as alert-box QUESTION BUTTONS YES-NO UPDATE is-dup .
      if is-dup = no then return error.
    end.
    run gen-b-code in this-procedure ( input 'ctgb':U, output f-code) no-error .
    if error-status:error then do:
      message "Ошибка при генерации внутреннего № договора" view-as alert-box ERROR.
      return error.
    end.
    create b_contract .
    ri = recid(b_contract).
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdburt in g#library
  (output b_contract.user-db-num
  ,output b_contract.user-name
  ,output p-sys-date
  ,output p-sys-time
  ,output p-sys-time-int
  )  .
    assign
      b_contract.doc-type      = p-doc-type
      b_contract.contract-code = f-code
      b_contract.host-code     = p-host-code
      b_contract.contract-type = COMBO-type-contr
      b_contract.status_       = 'тек':U
      b_contract.curr-code     = curr-code
      b_contract.own-name      = own-name
      b_contract.cli-type      = cli-type
      b_contract.cli-code      = cli-code
      b_contract.cli-name      = cli-name
      b_contract.db-num        = b_contract.user-db-num
    .
  end.
  else do:
    find first b_contract exclusive-lock where recid(b_contract) = ri no-error .
    if ref-mode = 'ИЗМЕНЕНИЕ':U then do:
      find first ub.contract no-lock
        where ub.contract.contract-date     = contract-date
          and ub.contract.contract-prn-code = contract-prn-code
          and ub.contract.cli-type          = cli-type
          and ub.contract.cli-code          = cli-code
          and ub.contract.host-code         = p-host-code
          and ub.contract.contract-code     <> b_contract.contract-code
      no-error .
      if available ub.contract then do:
         message substitute ("Уже есть договор № &1 от &2 с контрагентом &3 ! Продолжать &4 договора ?" ,
                  contract-prn-code ,
                  string(contract-date,"99/99/9999"),
                  cli-name ,
                  ref-mode )
                view-as alert-box QUESTION BUTTONS YES-NO UPDATE is-dup .
        if is-dup = no then return error.
      end.
    end.
  end.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdburt in g#library
  (output b_contract.user-db-num
  ,output b_contract.user-name
  ,output p-sys-date
  ,output p-sys-time
  ,output p-sys-time-int
  )  .
  if v-own-code-schet-2  = ? or v-own-code-schet-2  = 0 then assign v-own-code-schet-2  = v-own-code-schet  .
  if v-cli-code-schet-2  = ? or v-cli-code-schet-2  = 0 then assign v-cli-code-schet-2  = v-cli-code-schet  .
  if v-posr-code-schet-2 = ? or v-posr-code-schet-2 = 0 then assign v-posr-code-schet-2 = v-posr-code-schet .
  if v-agnt-code-schet-2 = ? or v-agnt-code-schet-2 = 0 then assign v-agnt-code-schet-2 = v-agnt-code-schet .
  assign fin-VAT-pc mngr-code .
  define variable ii as integer   no-undo .
  do ii = 1 to 6 :
    if a-code-an-uchet  [ii] = ? then  a-code-an-uchet  [ii] = 0 .
    if a-code-cel-nazn  [ii] = ? then  a-code-cel-nazn  [ii] = 0 .
    if a-code-cor-acc   [ii] = ? then  a-code-cor-acc   [ii] = 0 .
    if a-code-cor-acc-2 [ii] = ? then  a-code-cor-acc-2 [ii] = 0 .
  end.
  case b-nal :
    when 1 then assign b_contract.pay-nal = no .
    when 2 then assign b_contract.pay-nal = yes .
    when 3 then assign b_contract.pay-nal = ? .
  end.
  case COMBO-usl-opl-2 :
    when 'Не определено':U     then assign  b_contract.gen-factur = 0 .
    when 'По приходной накладной':U        then assign  b_contract.gen-factur = 1 .
    when 'По фин. обязательству':U        then assign  b_contract.gen-factur = 2 .
    when 'По платежу':U       then assign  b_contract.gen-factur = 3 .
    when 'По накл. смены типа преобр.':U       then assign  b_contract.gen-factur = 4 .
    when 'По расходной накладной':U        then assign  b_contract.gen-factur = 5 .
  end.
  assign b_contract.gen-factur-srok = srok-opl-2 .
  if COMBO-auto-pay-2:screen-value = "факт" and b_contract.gen-factur <> 0 then assign b_contract.gen-factur = b_contract.gen-factur + 100 .
  assign kredit-sum .
  assign
    b_contract.cli-name          = cli-name
    b_contract.str-uslov-oplat   = str-uslov-oplat
    b_contract.usl-opl           = COMBO-usl-opl
    b_contract.srok-opl          = srok-opl
    b_contract.contract-date     = contract-date
    b_contract.contract-name     = contract-name
    b_contract.contract-prn-code = contract-prn-code
    b_contract.contract-city     = contract-city
    b_contract.contract-date-beg = contract-date-beg
    b_contract.contract-date-end = contract-date-end
    b_contract.transport-cli-type  = v-transport-cli-type
    b_contract.transport-cli-code  = v-transport-cli-code
    b_contract.transport-host      = v-transport-host
    b_contract.transport-contract  = v-transport-contract
    b_contract.transport-uslov     = v-transport-uslov
    b_contract.transport-value     = v-transport-value
    b_contract.transport-type      = v-transport-type
    b_contract.kredit-sum        = kredit-sum
    b_contract.kredit-limit      = kredit-limit
    b_contract.posr-type         = posr-type
    b_contract.posr-code         = posr-code
    b_contract.posr-name         = posr-name
    b_contract.agnt-type         = agnt-type
    b_contract.agnt-code         = agnt-code
    b_contract.agnt-name         = agnt-name
    b_contract.mngr-code         = mngr-code
    b_contract.own-name          = own-name
    b_contract.own-sign-post     = sign-post-own
    b_contract.own-sign          = sign-own
    b_contract.own-addres        = addres-own
    b_contract.own-inn           = inn-own
    b_contract.own-kpp           = kpp-own
    b_contract.cli-sign-post     = sign-post-cli
    b_contract.cli-sign          = sign-cli
    b_contract.cli-addres        = addres-cli
    b_contract.cli-inn           = inn-cli
    b_contract.cli-kpp           = kpp-cli
    b_contract.posr-sign-post    = sign-post-posr
    b_contract.posr-sign         = sign-posr
    b_contract.posr-addres       = addres-posr
    b_contract.posr-inn          = inn-posr
    b_contract.posr-kpp          = kpp-posr
    b_contract.agnt-sign-post    = sign-post-agnt
    b_contract.agnt-sign         = sign-agnt
    b_contract.agnt-addres       = addres-agnt
    b_contract.agnt-inn          = inn-agnt
    b_contract.agnt-kpp          = kpp-agnt
    b_contract.own-code-schet        = v-own-code-schet-2
    b_contract.cli-code-schet        = v-cli-code-schet-2
    b_contract.posr-code-schet       = v-posr-code-schet-2
    b_contract.agnt-code-schet       = v-agnt-code-schet-2
    b_contract.own-code-schet-start  = v-own-code-schet
    b_contract.cli-code-schet-start  = v-cli-code-schet
    b_contract.posr-code-schet-start = v-posr-code-schet
    b_contract.agnt-code-schet-start = v-agnt-code-schet
    b_contract.own-point-code        = v-own-point-code
    b_contract.own-point-db-num      = v-own-point-db-num
    b_contract.agnt-point-code       = v-agnt-point-code
    b_contract.agnt-point-db-num     = v-agnt-point-db-num
    b_contract.cli-point-code        = v-cli-point-code
    b_contract.cli-point-db-num      = v-cli-point-db-num
    b_contract.posr-point-code       = v-posr-point-code
    b_contract.posr-point-db-num     = v-posr-point-db-num
    b_contract.spec-check      = COMBO-return-type
    b_contract.fin-VAT-pc      = fin-VAT-pc
    b_contract.own-bank-name  = ""
    b_contract.own-bik        = ""
    b_contract.own-r-schet    = ""
    b_contract.own-c-schet    = ""
    b_contract.cli-bank-name  = ""
    b_contract.cli-bik        = ""
    b_contract.cli-r-schet    = ""
    b_contract.cli-c-schet    = ""
    b_contract.posr-bank-name = ""
    b_contract.posr-bik       = ""
    b_contract.posr-r-schet   = ""
    b_contract.posr-c-schet   = ""
    b_contract.agnt-bank-name = ""
    b_contract.agnt-bik       = ""
    b_contract.agnt-r-schet   = ""
    b_contract.agnt-c-schet   = ""
    b_contract.an-uchet-code-out        = a-code-an-uchet  [1]
    b_contract.cel-nazn-code-out        = a-code-cel-nazn  [1]
    b_contract.cor-acc-out              = a-code-cor-acc   [1]
    b_contract.cor-acc1-out             = a-code-cor-acc-2 [1]
    b_contract.an-uchet-code-in         = a-code-an-uchet  [2]
    b_contract.cel-nazn-code-in         = a-code-cel-nazn  [2]
    b_contract.cor-acc-in               = a-code-cor-acc   [2]
    b_contract.cor-acc1-in              = a-code-cor-acc-2 [2]
    b_contract.an-uchet-code-out-cash   = a-code-an-uchet  [3]
    b_contract.cel-nazn-code-out-cash   = a-code-cel-nazn  [3]
    b_contract.cor-acc-out-cash         = a-code-cor-acc   [3]
    b_contract.cor-acc1-out-cash        = a-code-cor-acc-2 [3]
    b_contract.an-uchet-code-in-cash    = a-code-an-uchet  [4]
    b_contract.cel-nazn-code-in-cash    = a-code-cel-nazn  [4]
    b_contract.cor-acc-in-cash          = a-code-cor-acc   [4]
    b_contract.cor-acc1-in-cash         = a-code-cor-acc-2 [4]
    b_contract.an-uchet-code-out-payoff = a-code-an-uchet  [5]
    b_contract.cel-nazn-code-out-payoff = a-code-cel-nazn  [5]
    b_contract.cor-acc-out-payoff       = a-code-cor-acc   [5]
    b_contract.cor-acc1-out-payoff      = a-code-cor-acc-2 [5]
    b_contract.an-uchet-code-in-payoff  = a-code-an-uchet  [6]
    b_contract.cel-nazn-code-in-payoff  = a-code-cel-nazn  [6]
    b_contract.cor-acc-in-payoff        = a-code-cor-acc   [6]
    b_contract.cor-acc1-in-payoff       = a-code-cor-acc-2 [6]
  .
  if b_contract.usl-opl = 'По спецификации':U or b_contract.usl-opl = 'Отсрочка платежа по спецификации':U  then do:
    assign b_contract.need-fo = 1 .
  end.
  if v-own-code-schet <> ? then do:
    find first ub.fin-schet no-lock where ub.fin-schet.host-code = p-host-code and ub.fin-schet.code-schet = v-own-code-schet no-error .
    if available ub.fin-schet then do:
      find first ub.fin-bank no-lock where ub.fin-bank.host-code = p-host-code and ub.fin-bank.code-bank = ub.fin-schet.code-bank no-error .
      assign
        b_contract.own-bank-name = ub.fin-bank.bank-name
        b_contract.own-bik       = ub.fin-bank.bik
        b_contract.own-r-schet   = ub.fin-schet.r-schet
        b_contract.own-c-schet   = ub.fin-schet.c-schet
      .
    end.
  end.
  if v-cli-code-schet <> ? then do:
    find first ub.fin-schet no-lock where ub.fin-schet.host-code = p-host-code and ub.fin-schet.code-schet = v-cli-code-schet no-error .
    if available ub.fin-schet then do:
      find first ub.fin-bank no-lock where ub.fin-bank.host-code = p-host-code and ub.fin-bank.code-bank = ub.fin-schet.code-bank no-error .
      assign
        b_contract.cli-bank-name = ub.fin-bank.bank-name
        b_contract.cli-bik       = ub.fin-bank.bik
        b_contract.cli-r-schet   = ub.fin-schet.r-schet
        b_contract.cli-c-schet   = ub.fin-schet.c-schet
      .
    end.
  end.
  if v-posr-code-schet <> ? then do:
    find first ub.fin-schet no-lock where ub.fin-schet.host-code = p-host-code and ub.fin-schet.code-schet = v-posr-code-schet no-error .
    if available ub.fin-schet then do:
      find first ub.fin-bank no-lock where ub.fin-bank.host-code = p-host-code and ub.fin-bank.code-bank = ub.fin-schet.code-bank no-error .
      assign
        b_contract.posr-bank-name = ub.fin-bank.bank-name
        b_contract.posr-bik       = ub.fin-bank.bik
        b_contract.posr-r-schet   = ub.fin-schet.r-schet
        b_contract.posr-c-schet   = ub.fin-schet.c-schet
      .
    end.
  end.
  if v-agnt-code-schet <> ? then do:
    find first ub.fin-schet no-lock where ub.fin-schet.host-code = p-host-code and ub.fin-schet.code-schet = v-agnt-code-schet no-error .
    if available ub.fin-schet then do:
      find first ub.fin-bank no-lock where ub.fin-bank.host-code = p-host-code and ub.fin-bank.code-bank = ub.fin-schet.code-bank no-error .
      assign
        b_contract.agnt-bank-name = ub.fin-bank.bank-name
        b_contract.agnt-bik       = ub.fin-bank.bik
        b_contract.agnt-r-schet   = ub.fin-schet.r-schet
        b_contract.agnt-c-schet   = ub.fin-schet.c-schet
      .
    end.
  end.
  case COMBO-auto-pay:screen-value :
    when "фин.об. авто" then b_contract.auto-pay = 0 .
    when "фин.об. факт" then b_contract.auto-pay = 1 .
    when "платеж новый" then b_contract.auto-pay = 2 .
    when "платеж разр"  then b_contract.auto-pay = 3 .
    when "платеж факт"  then b_contract.auto-pay = 4 .
  end.
  find first buf_contract-attr exclusive-lock where buf_contract-attr.contract-code = b_contract.contract-code
  and buf_contract-attr.host-code = b_contract.host-code and buf_contract-attr.attr-code = "contract-edi" no-error .
  if available (buf_contract-attr) then buf_contract-attr.attr-value = string(T-edi) .
  else do:
    create buf_contract-attr .
    assign
    buf_contract-attr.host-code = b_contract.host-code
    buf_contract-attr.contract-code = b_contract.contract-code
    buf_contract-attr.attr-code = "contract-edi"
    buf_contract-attr.attr-value = string (T-edi)
    .
  end.
  find first buf_contract-attr exclusive-lock where buf_contract-attr.contract-code = b_contract.contract-code
  and buf_contract-attr.host-code = b_contract.host-code and buf_contract-attr.attr-code = "contract-diadoc" no-error .
  if available (buf_contract-attr) then buf_contract-attr.attr-value = string(T-diadoc) .
  else do:
    create buf_contract-attr .
    assign
    buf_contract-attr.host-code = b_contract.host-code
    buf_contract-attr.contract-code = b_contract.contract-code
    buf_contract-attr.attr-code = "contract-diadoc"
    buf_contract-attr.attr-value = string (T-diadoc)
    .
  end.
  IF ref-mode = 'ИЗМЕНЕНИЕ':U AND Is-MS-Contract-Int (BUFFER b_Contract) = 1
     THEN DO:
     MESSAGE
     "Распространить изменение шапки мастер договора на " SKIP
     "подчиненные договора ?"
     VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
     UPDATE lChoice.
     IF lChoice = TRUE THEN DO:
        RUN Modify-Slave-Contract in THIS-PROCEDURE(
            BUFFER b_Contract,
            OUTPUT v-cError
            ).
        IF v-cError <> "" THEN DO:
           MESSAGE
              v-cError
              VIEW-AS ALERT-BOX INFO BUTTONS OK.
           RETURN ERROR v-cError.
        END.
     END.
  END.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH contract SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY T-edi T-diadoc T-edi-order contract-prn-code contract-date
          contract-city contract-name contract-date-beg contract-date-end
          curr-code COMBO-return-type COMBO-type-contr cli-code cli-type
          posr-code posr-type agnt-code agnt-type mngr-code COMBO-usl-opl
          srok-opl COMBO-auto-pay COMBO-usl-opl-2 srok-opl-2 COMBO-auto-pay-2
          kredit-limit kredit-sum balance-fo str-uslov-oplat fin-VAT-pc
          RADIO-SET-1 b-nal cor-acc an-uchet cel-nazn cor-acc-2 contract-code
          curr-name own-code own-name cli-name posr-name agnt-name mngr-name
      WITH FRAME Dialog-Frame.
  ENABLE b-OK b-exit b-spec B-transport b-hist B-Help RECT-8 RECT-9 T-edi
         T-diadoc T-edi-order contract-prn-code contract-date contract-city
         contract-name BUTTON-curr contract-date-beg contract-date-end
         curr-code COMBO-return-type COMBO-type-contr b-bank-own b-bank-cli
         cli-code cli-type BUTTON-cli b-bank-posr posr-code posr-type
         BUTTON-posr b-bank-agnt agnt-code agnt-type BUTTON-agnt mngr-code
         BUTTON-mngr COMBO-usl-opl srok-opl COMBO-auto-pay COMBO-usl-opl-2
         srok-opl-2 COMBO-auto-pay-2 kredit-limit kredit-sum balance-fo
         str-uslov-oplat fin-VAT-pc RADIO-SET-1 b-nal b-cor-acc b-an-uchet
         b-cel-nazn b-cor-acc-2 contract-code own-code
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE find-cli :
  define input  parameter p-type     as integer   no-undo .
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define variable str  as character initial "" no-undo .
  define variable str1 as character initial "" no-undo .
  define variable str2 as character initial "" no-undo .
  define variable str3 as character initial "" no-undo .
  if p-obj-type <> 'орг':U and p-obj-type <> 'чел':U then do:
    find first buf_clients no-lock where buf_clients.obj-type = 'орг':U and buf_clients.obj-code = p-obj-code no-error.
    if not available buf_clients then do:
      find first buf_clients no-lock where buf_clients.obj-type = 'чел':U and buf_clients.obj-code = p-obj-code no-error.
    end.
  end.
  else find first buf_clients no-lock where buf_clients.obj-type = p-obj-type and buf_clients.obj-code = p-obj-code no-error.
  if not available buf_clients then do:
    if p-obj-code = 0 then assign p-obj-code = ? .
    if p-obj-code = ? then do:
      case p-type :
        when 1 then do:
          assign cli-name = "" kpp-cli = "" inn-cli = ""  addres-cli = ""  cli-code = ?  cli-type  = ? .
          display cli-name    cli-code     cli-type   with frame Dialog-Frame.
        end.
        when 2 then do:
          assign posr-name = "" kpp-posr = ""  inn-posr = ""  addres-posr = ""  posr-code = ?  posr-type = ? .
          display posr-name   posr-code    posr-type  with frame Dialog-Frame.
        end.
        when 3 then do:
          assign agnt-name = "" kpp-agnt = ""  inn-agnt = ""  addres-agnt = ""  agnt-code = ?  agnt-type = ? .
          display agnt-name   agnt-code    agnt-type  with frame Dialog-Frame.
        end.
      end case.
    end.
    else do:
      case p-type :
        when 1 then apply "CHOOSE" to BUTTON-cli IN FRAME Dialog-Frame .
        when 2 then apply "CHOOSE" to BUTTON-posr IN FRAME Dialog-Frame .
        when 3 then apply "CHOOSE" to BUTTON-agnt IN FRAME Dialog-Frame .
      end case.
    end.
    return.
  end.
  if buf_clients.obj-type = 'орг':U then do:
    find first buf_firm no-lock where buf_firm.firm-code = buf_clients.obj-code no-error.
    if available buf_firm then assign str1 = buf_firm.inn   str2 = buf_firm.addres1  str3 = buf_firm.kpp .
  end.
  else do:
    find first ub.person no-lock where ub.person.psn-code = buf_clients.obj-code no-error.
    if available ub.person then assign  str2 = ub.person.address   str3 = ub.person.kpp .
  end.
  case p-type :
    when 1 then do:
      assign cli-name  = buf_clients.obj-name kpp-cli = str3   inn-cli  = str1  addres-cli  = str2  cli-code  = p-obj-code  cli-type  = buf_clients.obj-type.
      display cli-name    cli-code     cli-type   with frame Dialog-Frame.
    end.
    when 2 then do:
      assign posr-name = buf_clients.obj-name  kpp-posr = str3  inn-posr = str1  addres-posr = str2  posr-code = p-obj-code  posr-type = buf_clients.obj-type.
      display posr-name   posr-code    posr-type  with frame Dialog-Frame.
    end.
    when 3 then do:
      assign agnt-name = buf_clients.obj-name  kpp-agnt = str3 inn-agnt = str1  addres-agnt = str2  agnt-code = p-obj-code  agnt-type = buf_clients.obj-type.
      display agnt-name   agnt-code    agnt-type  with frame Dialog-Frame.
    end.
  end case.
END PROCEDURE.
PROCEDURE go-proc :
do
on error undo, return error
on stop undo, return error
:
define variable par-type as character no-undo .
define variable v-is-add as character no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-addch':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output v-is-add
  ,output par-type
  ) no-error .
  enable COMBO-type-contr with frame Dialog-Frame.
  if v-is-add = 'yes' then COMBO-type-contr:list-items = 'Купли-продажи,Консигнации,Ответственного хранения,Агентский договор,Давальческого сырья,Продажи через ТПСИ,о Дополнительных расходах':U .
                      else COMBO-type-contr:list-items = 'Купли-продажи,Консигнации,Ответственного хранения,Агентский договор,Давальческого сырья,Продажи через ТПСИ':U .
  COMBO-auto-pay:list-items = "фин.об. авто" + "," + "фин.об. факт" + "," + "платеж новый"  .
  COMBO-auto-pay-2:list-items = "новый" + "," + "факт" .
  if p-doc-type = 'при':U then do:
    COMBO-usl-opl:list-items = 'Не определено,По заказу,По поставке заказа,Отсрочка платежа по заказу,Отсрочка платежа по поставке заказа,По факту поставки,По факту реализации,Отсрочка платежа (по поставке),Отсрочка платежа (по реализации),По реализации части приход. накладной,По спецификации,Отсрочка платежа по спецификации':U.
    COMBO-usl-opl-2:list-items   = 'Не определено':U + ","  + 'По приходной накладной':U + ","  + 'По фин. обязательству':U + ","  + 'По платежу':U + ","  + 'По накл. смены типа преобр.':U  .
  end.
  else do:
    COMBO-usl-opl:list-items = 'Не определено,Предоплата,Предоплата(%),По факту поставки покупателю,Отсрочка платежа по поставке':U .
    COMBO-usl-opl-2:list-items   = 'Не определено':U + ","  + 'По расходной накладной':U + ","  + 'По фин. обязательству':U + ","  + 'По платежу':U .
  end.
  if p-doc-type = 'при':U
  then do :
    enable COMBO-return-type WITH FRAME Dialog-Frame.
  end .
  else do :
    hide COMBO-return-type in FRAME Dialog-Frame.
  end .
  case ref-mode :
    when 'ДОБАВЛЕНИЕ':U then do:
      define buffer buf_sysconf for ub.sysconf .
      find first buf_sysconf no-lock where buf_sysconf.host-code = p-host-code .
      disable srok-opl-2 with frame Dialog-Frame.
      B-spec:visible = no .
      assign
        a-code-an-uchet  [1] = buf_sysconf.an-uchet-code-out
        a-code-cel-nazn  [1] = buf_sysconf.cel-nazn-code-out
        a-code-cor-acc   [1] = buf_sysconf.cor-acc-out
        a-code-cor-acc-2 [1] = buf_sysconf.cor-acc1-out
        a-code-an-uchet  [2] = buf_sysconf.an-uchet-code-in
        a-code-cel-nazn  [2] = buf_sysconf.cel-nazn-code-in
        a-code-cor-acc   [2] = buf_sysconf.cor-acc-in
        a-code-cor-acc-2 [2] = buf_sysconf.cor-acc1-in
        a-code-an-uchet  [3] = buf_sysconf.an-uchet-code-out-cash
        a-code-cel-nazn  [3] = buf_sysconf.cel-nazn-code-out-cash
        a-code-cor-acc   [3] = buf_sysconf.cor-acc-out-cash
        a-code-cor-acc-2 [3] = buf_sysconf.cor-acc1-out-cash
        a-code-an-uchet  [4] = buf_sysconf.an-uchet-code-in-cash
        a-code-cel-nazn  [4] = buf_sysconf.cel-nazn-code-in-cash
        a-code-cor-acc   [4] = buf_sysconf.cor-acc-in-cash
        a-code-cor-acc-2 [4] = buf_sysconf.cor-acc1-in-cash
        a-code-an-uchet  [5] = buf_sysconf.an-uchet-code-out-payoff
        a-code-cel-nazn  [5] = buf_sysconf.cel-nazn-code-out-payoff
        a-code-cor-acc   [5] = buf_sysconf.cor-acc-out-payoff
        a-code-cor-acc-2 [5] = buf_sysconf.cor-acc1-out-payoff
        a-code-an-uchet  [6] = buf_sysconf.an-uchet-code-in-payoff
        a-code-cel-nazn  [6] = buf_sysconf.cel-nazn-code-in-payoff
        a-code-cor-acc   [6] = buf_sysconf.cor-acc-in-payoff
        a-code-cor-acc-2 [6] = buf_sysconf.cor-acc1-in-payoff
        v-transport-cli-type = buf_sysconf.transport-cli-type
        v-transport-cli-code = buf_sysconf.transport-cli-code
        v-transport-host     = buf_sysconf.transport-host
        v-transport-contract = buf_sysconf.transport-contract
        v-transport-uslov    = buf_sysconf.transport-uslov
        v-transport-value    = buf_sysconf.transport-value
      .
      if buf_sysconf.pay-code-schet-rubl > 0 then assign v-own-code-schet = buf_sysconf.pay-code-schet-rubl .
      find first buf_clients no-lock where buf_clients.obj-type = 'орг':U and buf_clients.obj-code = p-host-code no-error .
      assign
        own-name = buf_clients.obj-name
        own-code = p-host-code
      .
      find first buf_firm no-lock where buf_firm.firm-code = p-host-code no-error .
      assign
        kpp-own           = buf_firm.kpp
        inn-own           = buf_firm.inn
        addres-own        = buf_firm.addres1
        contract-city     = buf_sysconf.contract-city
        sign-post-own     = buf_sysconf.pay-sign-post
        sign-own          = buf_sysconf.pay-sign
        contract-date     = today
        contract-date-beg = today
        fin-VAT-pc        = buf_sysconf.fin-VAT-pc
        srok-opl = buf_sysconf.srok-opl
        srok-opl-2 = buf_sysconf.srok-opl-sf
      .
      if buf_sysconf.usl-opl-sf <> "" and   buf_sysconf.usl-opl-sf <> ? then do:
        if lookup ( buf_sysconf.usl-opl-sf, COMBO-usl-opl-2:list-items) = 0 then COMBO-usl-opl-2:screen-value    = 'Не определено':U .
        else COMBO-usl-opl-2:screen-value =  buf_sysconf.usl-opl-sf .
      end.
      else COMBO-usl-opl-2:screen-value    = 'Не определено':U .
      case buf_sysconf.auto-pay-sf :
        when 0 then COMBO-auto-pay-2:screen-value = "новый" .
        when 1 then COMBO-auto-pay-2:screen-value = "факт" .
      end.
      if buf_sysconf.contract-type <> "" and buf_sysconf.contract-type <> ?  and buf_sysconf.contract-type <> "Не задан" then do:
        COMBO-type-contr:screen-value = buf_sysconf.contract-type .
      end.
      else COMBO-type-contr:screen-value = 'Купли-продажи':U .
      if buf_sysconf.usl-opl <> "" and   buf_sysconf.usl-opl <> ? then do:
        if lookup ( buf_sysconf.usl-opl, COMBO-usl-opl:list-items) = 0 then COMBO-usl-opl:screen-value    = 'Не определено':U .
        else COMBO-usl-opl:screen-value =  buf_sysconf.usl-opl .
      end.
      else COMBO-usl-opl:screen-value    = 'Не определено':U .
      case buf_sysconf.auto-pay :
        when 0 then COMBO-auto-pay:screen-value = "фин.об. авто" .
        when 1 then COMBO-auto-pay:screen-value = "фин.об. факт" .
        when 2 then COMBO-auto-pay:screen-value = "платеж новый" .
        when 3 then COMBO-auto-pay:screen-value = "платеж разр" .
        when 4 then COMBO-auto-pay:screen-value = "платеж факт" .
      end.
      if   COMBO-usl-opl:screen-value = 'Не определено':U
        or COMBO-usl-opl:screen-value = 'Предоплата':U
        or COMBO-usl-opl:screen-value = 'По факту поставки покупателю':U
        or COMBO-usl-opl:screen-value = 'По факту поставки':U
        or COMBO-usl-opl:screen-value = 'По факту реализации':U  then  disable srok-opl with frame Dialog-Frame.
      disable b-hist b-cor-acc-2 with frame Dialog-Frame.
      if p-contr-type <> "" then do:
         COMBO-type-contr:screen-value = p-contr-type.
         disable COMBO-type-contr with frame Dialog-Frame .
      end.
    end.
    when 'ИЗМЕНЕНИЕ':U or when 'ПРОСМОТР':U then do:
      find first b_contract no-lock where recid(b_contract) = ri .
      COMBO-type-contr:screen-value = b_contract.contract-type .
      COMBO-usl-opl:screen-value =  b_contract.usl-opl .
      COMBO-return-type = b_contract.spec-check .
      display COMBO-return-type WITH FRAME Dialog-Frame.
      if b_contract.gen-factur > 100 then assign COMBO-auto-pay-2:screen-value = "факт" .
      else                                assign COMBO-auto-pay-2:screen-value = "новый" .
      case b_contract.gen-factur :
        when 0 then               assign COMBO-usl-opl-2:screen-value = 'Не определено':U .
        when 1  or when 101 then  assign COMBO-usl-opl-2:screen-value = 'По приходной накладной':U .
        when 2  or when 102 then  assign COMBO-usl-opl-2:screen-value = 'По фин. обязательству':U .
        when 3  or when 103 then  assign COMBO-usl-opl-2:screen-value = 'По платежу':U .
        when 4  or when 104 then  assign COMBO-usl-opl-2:screen-value = 'По накл. смены типа преобр.':U .
        when 5  or when 105 then  assign COMBO-usl-opl-2:screen-value = 'По расходной накладной':U .
      end.
      assign srok-opl-2 = b_contract.gen-factur-srok .
      if b_contract.gen-factur < 10 or b_contract.gen-factur > 10 and b_contract.gen-factur < 110 then  disable srok-opl-2 with frame Dialog-Frame.
      if   b_contract.usl-opl = 'Отсрочка платежа (по реализации)':U
        or b_contract.usl-opl = 'Отсрочка платежа (по поставке)':U
        or b_contract.usl-opl = 'Предоплата(%)':U
        or b_contract.usl-opl = 'Отсрочка платежа по поставке':U
        or b_contract.usl-opl = 'По реализации части приход. накладной':U
        or b_contract.usl-opl = 'Отсрочка платежа по поставке заказа':U
        or b_contract.usl-opl = 'Отсрочка платежа по заказу':U
        or b_contract.usl-opl = 'Отсрочка платежа по спецификации':U
      then do:
        assign srok-opl = b_contract.srok-opl .
        if b_contract.usl-opl = 'По реализации части приход. накладной':U or b_contract.usl-opl = 'Предоплата(%)':U then assign srok-opl:label = "> %" .
      end.
      case b_contract.pay-nal :
        when no then  assign b-nal = 1 .
        when yes then assign b-nal = 2 .
        when ? then   assign b-nal = 3 .
      end.
      assign
        contract-code     = b_contract.contract-code
        contract-prn-code = b_contract.contract-prn-code
        contract-date     = b_contract.contract-date
        contract-city     = b_contract.contract-city
        contract-name     = b_contract.contract-name
        contract-date-beg = b_contract.contract-date-beg
        contract-date-end = b_contract.contract-date-end
        curr-code         = b_contract.curr-code
        own-code          = b_contract.host-code
        cli-code          = b_contract.cli-code
        cli-type          = b_contract.cli-type
        agnt-code         = b_contract.agnt-code
        agnt-type         = b_contract.agnt-type
        posr-code         = b_contract.posr-code
        posr-type         = b_contract.posr-type
        v-own-point-code      = b_contract.own-point-code
        v-own-point-db-num    = b_contract.own-point-db-num
        v-agnt-point-code     = b_contract.agnt-point-code
        v-agnt-point-db-num   = b_contract.agnt-point-db-num
        v-cli-point-code      = b_contract.cli-point-code
        v-cli-point-db-num    = b_contract.cli-point-db-num
        v-posr-point-code     = b_contract.posr-point-code
        v-posr-point-db-num   = b_contract.posr-point-db-num
        kredit-sum    = b_contract.kredit-sum
        kredit-limit  = b_contract.kredit-limit.
        if p-doc-type = 'при':U then balance-fo    = b_contract.balance-fo-rubl + b_contract.balance-plat-rubl.
        else balance-fo    = b_contract.balance-fo-rubl - b_contract.balance-plat-rubl.
assign
        own-name      = b_contract.own-name
        inn-own       = b_contract.own-inn
        kpp-own       = b_contract.own-kpp
        addres-own    = b_contract.own-addres
        sign-own      = b_contract.own-sign
        sign-post-own = b_contract.own-sign-post
        v-own-code-schet    = b_contract.own-code-schet-start
        v-cli-code-schet    = b_contract.cli-code-schet-start
        v-posr-code-schet   = b_contract.posr-code-schet-start
        v-agnt-code-schet   = b_contract.agnt-code-schet-start
        v-own-code-schet-2  = b_contract.own-code-schet
        v-cli-code-schet-2  = b_contract.cli-code-schet
        v-posr-code-schet-2 = b_contract.posr-code-schet
        v-agnt-code-schet-2 = b_contract.agnt-code-schet
        cli-name      = b_contract.cli-name
        addres-cli    = b_contract.cli-addres
        inn-cli       = b_contract.cli-inn
        kpp-cli       = b_contract.cli-kpp
        sign-cli      = b_contract.cli-sign
        sign-post-cli = b_contract.cli-sign-post
        posr-name      = b_contract.posr-name
        addres-posr    = b_contract.posr-addres
        inn-posr       = b_contract.posr-inn
        kpp-posr       = b_contract.posr-kpp
        sign-posr      = b_contract.posr-sign
        sign-post-posr = b_contract.posr-sign-post
        agnt-name      = b_contract.agnt-name
        addres-agnt    = b_contract.agnt-addres
        inn-agnt       = b_contract.agnt-inn
        kpp-agnt       = b_contract.agnt-kpp
        sign-agnt      = b_contract.agnt-sign
        sign-post-agnt = b_contract.agnt-sign-post
        fin-VAT-pc     = b_contract.fin-VAT-pc
        mngr-code       = b_contract.mngr-code
        str-uslov-oplat = b_contract.str-uslov-oplat
        v-transport-cli-type = b_contract.transport-cli-type
        v-transport-cli-code = b_contract.transport-cli-code
        v-transport-host     = b_contract.transport-host
        v-transport-contract = b_contract.transport-contract
        v-transport-uslov    = b_contract.transport-uslov
        v-transport-value    = b_contract.transport-value
        v-transport-type    = b_contract.transport-type
        a-code-an-uchet  [1] = b_contract.an-uchet-code-out
        a-code-cel-nazn  [1] = b_contract.cel-nazn-code-out
        a-code-cor-acc   [1] = b_contract.cor-acc-out
        a-code-cor-acc-2 [1] = b_contract.cor-acc1-out
        a-code-an-uchet  [2] = b_contract.an-uchet-code-in
        a-code-cel-nazn  [2] = b_contract.cel-nazn-code-in
        a-code-cor-acc   [2] = b_contract.cor-acc-in
        a-code-cor-acc-2 [2] = b_contract.cor-acc1-in
        a-code-an-uchet  [3] = b_contract.an-uchet-code-out-cash
        a-code-cel-nazn  [3] = b_contract.cel-nazn-code-out-cash
        a-code-cor-acc   [3] = b_contract.cor-acc-out-cash
        a-code-cor-acc-2 [3] = b_contract.cor-acc1-out-cash
        a-code-an-uchet  [4] = b_contract.an-uchet-code-in-cash
        a-code-cel-nazn  [4] = b_contract.cel-nazn-code-in-cash
        a-code-cor-acc   [4] = b_contract.cor-acc-in-cash
        a-code-cor-acc-2 [4] = b_contract.cor-acc1-in-cash
        a-code-an-uchet  [5] = b_contract.an-uchet-code-out-payoff
        a-code-cel-nazn  [5] = b_contract.cel-nazn-code-out-payoff
        a-code-cor-acc   [5] = b_contract.cor-acc-out-payoff
        a-code-cor-acc-2 [5] = b_contract.cor-acc1-out-payoff
        a-code-an-uchet  [6] = b_contract.an-uchet-code-in-payoff
        a-code-cel-nazn  [6] = b_contract.cel-nazn-code-in-payoff
        a-code-cor-acc   [6] = b_contract.cor-acc-in-payoff
        a-code-cor-acc-2 [6] = b_contract.cor-acc1-in-payoff
      .
      if   COMBO-usl-opl:screen-value = 'Не определено':U
        or COMBO-usl-opl:screen-value = 'По факту поставки покупателю':U
        or COMBO-usl-opl:screen-value = 'По факту поставки':U
        or COMBO-usl-opl:screen-value = 'По факту реализации':U  then  disable srok-opl with frame Dialog-Frame.
      disable COMBO-type-contr curr-code BUTTON-curr cli-code cli-type srok-opl-2 BUTTON-cli b-cor-acc-2 with frame Dialog-Frame.
      case b_contract.auto-pay :
        when 0 then COMBO-auto-pay:screen-value = "фин.об. авто" .
        when 1 then COMBO-auto-pay:screen-value = "фин.об. факт" .
        when 2 then COMBO-auto-pay:screen-value = "платеж новый" .
        when 3 then COMBO-auto-pay:screen-value = "платеж разр" .
        when 4 then COMBO-auto-pay:screen-value = "платеж факт" .
      end.
      for first buf_contract-attr no-lock where buf_contract-attr.host-code = b_contract.host-code and
      buf_contract-attr.contract-code = b_contract.contract-code and buf_contract-attr.attr-code = "contract-edi":
        T-edi = logical (buf_contract-attr.attr-value) .
      end.
      display t-edi with frame Dialog-Frame .
      for first buf_contract-attr no-lock where buf_contract-attr.host-code = b_contract.host-code and
      buf_contract-attr.contract-code = b_contract.contract-code and buf_contract-attr.attr-code = "contract-edi_orders":
        T-edi-order = logical (buf_contract-attr.attr-value) .
      end.
      display t-edi-order with frame Dialog-Frame .
      for first buf_contract-attr no-lock where buf_contract-attr.host-code = b_contract.host-code and
      buf_contract-attr.contract-code = b_contract.contract-code and buf_contract-attr.attr-code = "contract-diadoc":
        T-diadoc = logical (buf_contract-attr.attr-value) .
      end.
      display t-diadoc with frame Dialog-Frame .
      if ref-mode = 'ПРОСМОТР':U then do:
        disable contract-prn-code contract-date contract-city contract-name contract-date-beg contract-date-end  fin-VAT-pc b-nal
          agnt-code agnt-type BUTTON-agnt BUTTON-mngr posr-code posr-type BUTTON-posr  mngr-code  b-cor-acc b-cor-acc-2 b-an-uchet
          b-cel-nazn COMBO-usl-opl COMBO-usl-opl-2 str-uslov-oplat COMBO-auto-pay COMBO-auto-pay-2 RADIO-SET-1 kredit-sum contract-code kredit-limit
          srok-opl T-edi COMBO-return-type
        with frame Dialog-Frame.
        b-OK:label in frame Dialog-Frame = "&Выход" .
        b-exit:visible = no .
      end.
      if p-doc-type = 'рас':U THEN DO:
         ASSIGN
            b-Add-Inf:VISIBLE   = TRUE
            b-Add-Inf:SENSITIVE = TRUE
            .
      END.
    end.
    when "history" then do:
      find first buf_c-contract no-lock where recid(buf_c-contract) = ri .
      COMBO-type-contr:screen-value = buf_c-contract.contract-type .
      COMBO-usl-opl:list-items = 'Не определено,По заказу,По поставке заказа,Отсрочка платежа по заказу,Отсрочка платежа по поставке заказа,По факту поставки,По факту реализации,Отсрочка платежа (по поставке),Отсрочка платежа (по реализации),По реализации части приход. накладной,По спецификации,Отсрочка платежа по спецификации,Предоплата,Предоплата(%),По факту поставки покупателю,Отсрочка платежа по поставке':U .
      COMBO-usl-opl:screen-value =  buf_c-contract.usl-opl .
      B-spec:visible = no .
      if   buf_c-contract.usl-opl = 'Отсрочка платежа (по реализации)':U
        or buf_c-contract.usl-opl = 'Отсрочка платежа (по поставке)':U
        or buf_c-contract.usl-opl = 'Предоплата(%)':U
        or buf_c-contract.usl-opl = 'Отсрочка платежа по поставке':U
        or buf_c-contract.usl-opl = 'По реализации части приход. накладной':U
        or buf_c-contract.usl-opl = 'Отсрочка платежа по поставке заказа':U
        or buf_c-contract.usl-opl = 'Отсрочка платежа по заказу':U
        or buf_c-contract.usl-opl = 'Отсрочка платежа по спецификации':U
        then do:
        assign srok-opl = buf_c-contract.srok-opl .
        if buf_c-contract.usl-opl = 'По реализации части приход. накладной':U or buf_c-contract.usl-opl = 'Предоплата(%)':U then assign srok-opl:label = "> %" .
      end.
      if buf_c-contract.gen-factur > 100 then assign COMBO-auto-pay-2:screen-value = "факт" .
      else                                    assign COMBO-auto-pay-2:screen-value = "новый" .
      case buf_c-contract.gen-factur :
        when 0 then               assign COMBO-usl-opl-2:screen-value = 'Не определено':U .
        when 1  or when 101 then  assign COMBO-usl-opl-2:screen-value = 'По приходной накладной':U .
        when 2  or when 102 then  assign COMBO-usl-opl-2:screen-value = 'По фин. обязательству':U .
        when 3  or when 103 then  assign COMBO-usl-opl-2:screen-value = 'По платежу':U .
        when 4  or when 104 then  assign COMBO-usl-opl-2:screen-value = 'По накл. смены типа преобр.':U .
        when 5  or when 105 then  assign COMBO-usl-opl-2:screen-value = 'По расходной накладной':U .
      end.
      assign srok-opl-2 = buf_c-contract.gen-factur-srok .
      case buf_c-contract.pay-nal :
        when no then  assign b-nal = 1 .
        when yes then assign b-nal = 2 .
        when ? then   assign b-nal = 3 .
      end.
      assign
        contract-code     = buf_c-contract.contract-code
        contract-prn-code = buf_c-contract.contract-prn-code
        contract-date     = buf_c-contract.contract-date
        contract-city     = buf_c-contract.contract-city
        contract-name     = buf_c-contract.contract-name
        contract-date-beg = buf_c-contract.contract-date-beg
        contract-date-end = buf_c-contract.contract-date-end
        curr-code         = buf_c-contract.curr-code
        own-code          = buf_c-contract.host-code
        cli-code          = buf_c-contract.cli-code
        cli-type          = buf_c-contract.cli-type
        agnt-code         = buf_c-contract.agnt-code
        agnt-type         = buf_c-contract.agnt-type
        posr-code         = buf_c-contract.posr-code
        posr-type         = buf_c-contract.posr-type
        kredit-sum        = buf_c-contract.kredit-sum
        kredit-limit      = buf_c-contract.kredit-limit
        balance-fo        = buf_c-contract.balance-fo-rubl - buf_c-contract.balance-plat-rubl
        v-own-point-code      = buf_c-contract.own-point-code
        v-own-point-db-num    = buf_c-contract.own-point-db-num
        v-agnt-point-code     = buf_c-contract.agnt-point-code
        v-agnt-point-db-num   = buf_c-contract.agnt-point-db-num
        v-cli-point-code      = buf_c-contract.cli-point-code
        v-cli-point-db-num    = buf_c-contract.cli-point-db-num
        v-posr-point-code     = buf_c-contract.posr-point-code
        v-posr-point-db-num   = buf_c-contract.posr-point-db-num
        own-name      = buf_c-contract.own-name
        inn-own       = buf_c-contract.own-inn
        kpp-own       = buf_c-contract.own-kpp
        addres-own    = buf_c-contract.own-addres
        sign-own      = buf_c-contract.own-sign
        sign-post-own = buf_c-contract.own-sign-post
        v-own-code-schet    = buf_c-contract.own-code-schet-start
        v-cli-code-schet    = buf_c-contract.cli-code-schet-start
        v-posr-code-schet   = buf_c-contract.posr-code-schet-start
        v-agnt-code-schet   = buf_c-contract.agnt-code-schet-start
        v-own-code-schet-2  = buf_c-contract.own-code-schet
        v-cli-code-schet-2  = buf_c-contract.cli-code-schet
        v-posr-code-schet-2 = buf_c-contract.posr-code-schet
        v-agnt-code-schet-2 = buf_c-contract.agnt-code-schet
        cli-name      = buf_c-contract.cli-name
        addres-cli    = buf_c-contract.cli-addres
        inn-cli       = buf_c-contract.cli-inn
        kpp-cli       = buf_c-contract.cli-kpp
        sign-cli      = buf_c-contract.cli-sign
        sign-post-cli = buf_c-contract.cli-sign-post
        posr-name      = buf_c-contract.posr-name
        addres-posr    = buf_c-contract.posr-addres
        inn-posr       = buf_c-contract.posr-inn
        kpp-posr       = buf_c-contract.posr-kpp
        sign-posr      = buf_c-contract.posr-sign
        sign-post-posr = buf_c-contract.posr-sign-post
        agnt-name      = buf_c-contract.agnt-name
        addres-agnt    = buf_c-contract.agnt-addres
        inn-agnt       = buf_c-contract.agnt-inn
        kpp-agnt       = buf_c-contract.agnt-kpp
        sign-agnt      = buf_c-contract.agnt-sign
        sign-post-agnt = buf_c-contract.agnt-sign-post
        v-transport-cli-type = buf_c-contract.transport-cli-type
        v-transport-cli-code = buf_c-contract.transport-cli-code
        v-transport-host     = buf_c-contract.transport-host
        v-transport-contract = buf_c-contract.transport-contract
        v-transport-uslov    = buf_c-contract.transport-uslov
        v-transport-value    = buf_c-contract.transport-value
        v-transport-type     = buf_c-contract.transport-type
        fin-VAT-pc     = buf_c-contract.fin-VAT-pc
        mngr-code       = buf_c-contract.mngr-code
        str-uslov-oplat = buf_c-contract.str-uslov-oplat
        a-code-an-uchet  [1] = buf_c-contract.an-uchet-code-out
        a-code-cel-nazn  [1] = buf_c-contract.cel-nazn-code-out
        a-code-cor-acc   [1] = buf_c-contract.cor-acc-out
        a-code-cor-acc-2 [1] = buf_c-contract.cor-acc1-out
        a-code-an-uchet  [2] = buf_c-contract.an-uchet-code-in
        a-code-cel-nazn  [2] = buf_c-contract.cel-nazn-code-in
        a-code-cor-acc   [2] = buf_c-contract.cor-acc-in
        a-code-cor-acc-2 [2] = buf_c-contract.cor-acc1-in
        a-code-an-uchet  [3] = buf_c-contract.an-uchet-code-out-cash
        a-code-cel-nazn  [3] = buf_c-contract.cel-nazn-code-out-cash
        a-code-cor-acc   [3] = buf_c-contract.cor-acc-out-cash
        a-code-cor-acc-2 [3] = buf_c-contract.cor-acc1-out-cash
        a-code-an-uchet  [4] = buf_c-contract.an-uchet-code-in-cash
        a-code-cel-nazn  [4] = buf_c-contract.cel-nazn-code-in-cash
        a-code-cor-acc   [4] = buf_c-contract.cor-acc-in-cash
        a-code-cor-acc-2 [4] = buf_c-contract.cor-acc1-in-cash
        a-code-an-uchet  [5] = buf_c-contract.an-uchet-code-out-payoff
        a-code-cel-nazn  [5] = buf_c-contract.cel-nazn-code-out-payoff
        a-code-cor-acc   [5] = buf_c-contract.cor-acc-out-payoff
        a-code-cor-acc-2 [5] = buf_c-contract.cor-acc1-out-payoff
        a-code-an-uchet  [6] = buf_c-contract.an-uchet-code-in-payoff
        a-code-cel-nazn  [6] = buf_c-contract.cel-nazn-code-in-payoff
        a-code-cor-acc   [6] = buf_c-contract.cor-acc-in-payoff
        a-code-cor-acc-2 [6] = buf_c-contract.cor-acc1-in-payoff
      .
      disable b-hist COMBO-type-contr curr-code BUTTON-curr cli-code cli-type srok-opl BUTTON-cli b-cor-acc-2  contract-prn-code
        contract-date contract-city contract-name contract-date-beg contract-date-end  fin-VAT-pc b-nal srok-opl-2
        agnt-code agnt-type BUTTON-agnt BUTTON-mngr posr-code posr-type BUTTON-posr  mngr-code  b-cor-acc b-cor-acc-2 b-an-uchet
        b-cel-nazn COMBO-usl-opl COMBO-usl-opl-2 str-uslov-oplat COMBO-auto-pay RADIO-SET-1 COMBO-auto-pay-2 kredit-sum contract-code kredit-limit
      with frame Dialog-Frame.
      b-OK:label in frame Dialog-Frame = "&Выход" .
      b-exit:visible = no .
      case buf_c-contract.auto-pay :
        when 0 then COMBO-auto-pay:screen-value = "фин.об. авто" .
        when 1 then COMBO-auto-pay:screen-value = "фин.об. факт" .
        when 2 then COMBO-auto-pay:screen-value = "платеж новый" .
        when 3 then COMBO-auto-pay:screen-value = "платеж разр" .
        when 4 then COMBO-auto-pay:screen-value = "платеж факт" .
      end.
    end.
  end.
  find first ub.fin-code-an-uchet no-lock where ub.fin-code-an-uchet.fin-code = a-code-an-uchet [1] and ub.fin-code-an-uchet.host-code = p-host-code no-error .
  if available ub.fin-code-an-uchet then  assign an-uchet = ub.fin-code-an-uchet.code-value + "  " + ub.fin-code-an-uchet.descr .
  find first ub.fin-code-cel-nazn no-lock where ub.fin-code-cel-nazn.fin-code  = a-code-cel-nazn [1] and ub.fin-code-cel-nazn.host-code = p-host-code no-error .
  if available ub.fin-code-cel-nazn then assign cel-nazn = ub.fin-code-cel-nazn.code-value + "  " + ub.fin-code-cel-nazn.descr .
  find first ub.fin-code-cor-acc no-lock where ub.fin-code-cor-acc.fin-code  = a-code-cor-acc [1] and ub.fin-code-cor-acc.host-code = p-host-code no-error .
  if available ub.fin-code-cor-acc then assign cor-acc = ub.fin-code-cor-acc.code-value + "  " + ub.fin-code-cor-acc.descr  .
  find first ub.fin-code-cor-acc no-lock where ub.fin-code-cor-acc.fin-code  = a-code-cor-acc-2 [1] and ub.fin-code-cor-acc.host-code = p-host-code no-error .
  if available ub.fin-code-cor-acc then assign cor-acc-2 = ub.fin-code-cor-acc.code-value + "  " + ub.fin-code-cor-acc.descr  .
  display T-edi T-diadoc T-edi-order contract-prn-code contract-date contract-city contract-name contract-date-beg contract-date-end curr-code COMBO-return-type COMBO-type-contr cli-code cli-type posr-code posr-type agnt-code agnt-type mngr-code COMBO-usl-opl srok-opl COMBO-auto-pay COMBO-usl-opl-2 srok-opl-2 COMBO-auto-pay-2 kredit-limit kredit-sum balance-fo str-uslov-oplat fin-VAT-pc RADIO-SET-1 b-nal cor-acc an-uchet cel-nazn cor-acc-2 contract-code curr-name own-code own-name cli-name posr-name agnt-name mngr-name with frame Dialog-Frame.
  if mngr-code <> 0 and mngr-code <> ? then apply "LEAVE"  to mngr-code  IN FRAME Dialog-Frame .
  apply "entry"  to contract-prn-code IN FRAME Dialog-Frame .
  apply "LEAVE"  to curr-code  IN FRAME Dialog-Frame .
  apply "VALUE-CHANGED"  to b-nal IN FRAME Dialog-Frame .
end.
END PROCEDURE.
PROCEDURE step-next :
  do on error undo, return error return-value :
    if valid-handle (br-handle) then do:
      g-log = br-handle:select-next-row() no-error .
      if error-status :error then do:
        message "Это режим просмотра одного документа." .
        g-log = false .
      end.
      if not g-log then message "Это последний документ списка.".
    end.
    ri = recid ( buf_contract ).
    next-prev = yes.
  end.
END PROCEDURE.
PROCEDURE step-prev :
 do
 on error undo, return error return-value
 :
if valid-handle (br-handle) then do:
  g-log = br-handle:select-prev-row() no-error .
  if error-status :error then do:
     message "Это режим просмотра одного документа." .
     g-log = false .
  end.
  if not g-log then do: message "Это первый документ списка.".   end.
end.
ri = recid (buf_contract).
next-prev = yes .
  end.
END PROCEDURE.
