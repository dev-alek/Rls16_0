define input parameter parparentproc as widget-handle no-undo .
define input  parameter file-name as char no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "".
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
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
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
define variable vss-include-info2 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure grplib-get-full-name :
   define input parameter p-node-code  as integer      no-undo.
   define output parameter p-full-name as character    no-undo.
   do
on error undo, return error
:
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_gds-grp.node-name
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
end .
procedure grplib-get-node-from-full-name :
define input parameter p-full-name as character no-undo .
define output parameter p-node-code as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-root-code as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_gds-grp       for ub.gds-grp.
do
on error undo, return error
:
  find first buf_gds-grp no-lock
      where buf_gds-grp.upper-code = 0
  no-error .
  if not available buf_gds-grp
  then do:
      undo, return error substitute("Не найдена корневая группа товаров (upper-code = 0)").
  end.
  else do:
    assign
    v-root-code = buf_gds-grp.node-code
    .
  end.
  v-upper-code = v-root-code.
  do v-ii = 1 to num-entries(p-full-name, chr(47)):
    assign
    v-entry = entry(v-ii, p-full-name, chr(47)).
    if v-entry = '' then leave.
    find first buf_gds-grp no-lock where
              buf_gds-grp.node-name = v-entry
          and buf_gds-grp.upper-code = v-upper-code
          no-error.
    if not available buf_gds-grp then do:
      undo, return error substitute("Не найдена подгруппа &1 в группе с вн. кодом &2", v-entry, v-upper-code).
    end.
    else do:
      p-node-code = buf_gds-grp.node-code.
      v-upper-code = buf_gds-grp.node-code.
    end.
  end.
end.
end .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
  define new shared temp-table  tt-tax no-undo
field tax-code    like ub.tax.tax-code
FIELD individual  like ub.tax.individual
FIELD tax-name    like ub.tax.tax-name format "X(12)" column-label "Налог"
field rate-code   like ub.tax-rate.rate-code
FIELD rate-name   like ub.tax-rate.rate-name FORMAT "X(12)"
FIELD tax-type    like ub.tax.tax-type
field rate-value  like ub.tax-rate-value.rate-value
FIELD tax-rate-gds-rc  as recid
FIELD to-cashdesk like ub.tax.to-cashdesk
FIELD fact-date like ub.tax-rate-value.fact-date
FIELD fact-order like ub.tax-rate-value.fact-order
FIELD next-order like ub.tax-rate-value.fact-order
FIELD corr-user-name like ub.tax-rate-gds.corr-user-name
FIELD corr-user-db-num   like ub.tax-rate-gds.corr-user-db-num
FIELD corr-date like ub.tax-rate-gds.corr-date
FIELD corr-time like ub.tax-rate-gds.corr-time
index tax-code is unique primary tax-code fact-order descending rate-code.
define new shared buffer goods for ub.goods.
define variable ref-list as char no-undo.
define stream imp.
define stream err.
define new shared var vattaxcd as integer no-undo.
define new shared variable slttaxcd as integer no-undo.
define variable g-grp   as char no-undo.
DEFINE variable grp-code like ub.gds-grp.node-code No-UNDO.
DEFINE variable text-string as char no-undo.
DEFINE variable impc as integer No-UNDO.
DEFINE variable imp-save as integer No-UNDO.
DEFINE variable i-name as char no-undo.
DEFINE variable i-artic as char no-undo.
DEFINE variable i-size as char no-undo.
DEFINE variable i-color as char no-undo.
DEFINE variable i-scale as char no-undo.
DEFINE variable i-sertif  as char no-undo.
DEFINE variable i-sostav  as char no-undo.
DEFINE variable i-prav  as char no-undo.
DEFINE variable varrate-code LIKE ub.tax-rate-gds-grp.rate-code NO-UNDO.
DEFINE variable i-grp as integer no-undo.
DEFINE variable i-gds-code like goods.gds-code NO-UNDO.
DEFINE variable j-gds-code like goods.gds-code NO-UNDO.
DEFINE variable i-city as char init ? no-undo.
DEFINE VARIABLE var-bc-code as integer no-undo .
define buffer buf-goods for ub.goods.
define buffer buf_bar-code for ub.bar-code.
DEFINE variable i-prod-bc as char no-undo.
define variable v_os-file as char no-undo.
define variable prt-name as char no-undo.
DEFine variable rt as recid NO-UNDO.
DEFine variable tax-rate-rid as char no-undo init "".
define variable taxvalue like ub.tax-rate-value.rate-value no-undo.
DEFine variable cod-size-color like ub.gds-prt.node-code no-undo.
DEFine variable end-cod like ub.gds-prt.upper-code no-undo.
DEFine variable cod-size like ub.gds-prt.upper-code no-undo.
DEFine variable cod-color like ub.gds-prt.upper-code no-undo.
define temp-table tbl-grp NO-UNDO
       field Num-grp    as int
       field Name-grp  as char
       field Short-Name-grp  as char
       field code like ub.gds-grp.node-code
   index pi is unique primary
       Num-grp.
define variable grp-full as char.
define variable N-grp as integer.
define buffer buf-grp for ub.gds-grp.
define buffer buf-prt for ub.gds-prt.
DEFINE variable add-scale as log no-undo.
DEFINE variable reply as log no-undo.
DEFINE variable NDS-code like  ub.tax-rate-value.rate-value  no-undo .
DEFINE variable NP-code     like  ub.tax-rate-value.rate-value init ? no-undo .
DEFINE variable  N-param AS DEC NO-UNDO.
DEFINE variable  log-save as log no-undo.
define variable dif-pdbc as logical no-undo initial no.
define variable pbc-veto  as logical no-undo.
define variable v-param-type                as character                no-undo.
define variable v-value-character           as character                no-undo.
define variable v-value-date                as date                     no-undo.
define variable v-value-decimal             as decimal                  no-undo.
define variable v-value-integer             as INTEGER                  no-undo.
define variable v-value-logical             AS LOGICAL                  no-undo.
define variable v-tth                       as handle                   no-undo.
define temp-table ld no-undo
    field num  as integer
    field ord  as integer
    field name like ub.gds-prt.node-name
    index name is primary unique name .
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Выход"
     SIZE 15 BY 1.13
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Выполнить"
     SIZE 15 BY 1.13
     BGCOLOR 8 .
DEFINE BUTTON grp
     LABEL "Группа"
     SIZE 10.5 BY 1.21.
DEFINE BUTTON Imly-City
     LABEL "Страна"
     SIZE 10.5 BY 1.21.
DEFINE BUTTON Imply-Cli
     LABEL "Производитель"
     SIZE 14.13 BY 1.13.
DEFINE VARIABLE city1 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.88 BY 1.21
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE city2 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 48.5 BY 1.21
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE Cli-code AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 8.88 BY 1.13
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE Cli-Name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 34.5 BY 1.13
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE Cli-type AS CHARACTER FORMAT "X(8)":U
      VIEW-AS TEXT
     SIZE 4.63 BY 1.13
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE grp-txt AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 53 BY 1.21
     BGCOLOR 15  NO-UNDO.
DEFINE FRAME Dialog-Frame
     Imply-Cli AT ROW 2.25 COL 1
     grp AT ROW 5 COL 1
     Imly-City AT ROW 6.75 COL 1
     Btn_OK AT ROW 8.25 COL 11
     Btn_Cancel AT ROW 8.25 COL 43
     Cli-code AT ROW 2.25 COL 14 COLON-ALIGNED NO-LABEL
     Cli-type AT ROW 2.25 COL 23.5 COLON-ALIGNED NO-LABEL
     Cli-Name AT ROW 2.25 COL 28.5 COLON-ALIGNED NO-LABEL
     grp-txt AT ROW 5 COL 10 COLON-ALIGNED NO-LABEL
     city1 AT ROW 6.75 COL 10 COLON-ALIGNED NO-LABEL
     city2 AT ROW 6.75 COL 14.5 COLON-ALIGNED NO-LABEL
     "                         Необходимо указать" VIEW-AS TEXT
          SIZE 64 BY .92 AT ROW 1 COL 1
          BGCOLOR 8 FGCOLOR 0
     "       Не обязательные параметры подставляемые по умолчанию" VIEW-AS TEXT
          SIZE 64 BY 1 AT ROW 3.75 COL 1
          BGCOLOR 8 FGCOLOR 0
     SPACE(0.00) SKIP(4.74)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Импорт товаров из текстового файла"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame
DO:
    define variable l-is-weight as logical no-undo .
    define variable l-is-pgweight as logical no-undo .
    define variable l-is-petrolium as logical no-undo .
   if cli-code = 0 then do:
            message "Не задан производитель "
            view-as alert-box ERROR.
            return no-apply.
   end.
   if trim(grp-txt) = "" then do:
            message "Не задана группа товаров "
            view-as alert-box ERROR.
            return no-apply.
   end.
   if trim(city1) = "" then do:
            message "Не задана страна "
            view-as alert-box ERROR.
            return no-apply.
   end.
   if trim(file-name) = "" then do:
            message "Не задан файл для импорта "
            view-as alert-box ERROR.
            return no-apply.
   end.
   add-scale = false.
   input stream imp from value (file-name) .
   repeat:
        IMPORT stream imp UNFORMATTED text-string  .
        if trim(text-string) = "" then   leave.
        impc = impc + 1.
        if num-entries (text-string, ";") < 24 then do:
               N-param = num-entries (text-string, ";").
               OUTPUT stream Err TO value ("Imp_goods.err") append.
                  put stream Err unformatted
                    string(today, "99/99/9999") " "
                    string(time, "HH:MM")
                    " Неправильное число параметров в строке, должно быть 24 "  N-param skip.
                  export stream  Err text-string .
               output stream Err close.
               next.
        end.
        IF trim(ENTRY( 9, text-string, ";")) = "Article name" THEN NEXT.
        assign
            i-artic  = trim(ENTRY( 9, text-string, ";") + "-" + ENTRY( 10, text-string, ";"))
            i-size   = ENTRY( 11, text-string, ";")
            i-color  = ENTRY( 13, text-string, ";")
            i-prod-bc = ENTRY( 19, text-string, ";")
            i-name   = trim(ENTRY( 8, text-string, ";"))
            i-scale  =  i-size + "/" +  i-color
            i-sertif = trim(ENTRY( 14, text-string, ";") + " " + ENTRY( 15, text-string, ";") + " " + ENTRY( 16, text-string, ";"))
            i-sostav = trim(ENTRY( 23, text-string, ";"))
            i-prav   = trim(ENTRY( 24, text-string, ";"))
            log-save      = false
        .
        if num-entries (text-string, ";") = 21 THEN
           ASSIGN i-name  = i-name + " " + TRIM(ENTRY( 21, text-string, ";")).
        if trim(i-artic) = "" THEN DO:
            OUTPUT stream Err TO value ("Imp_goods.err") append.
               put stream Err unformatted
                  string(today, "99/99/9999") " "
                  string(time, "HH:MM")
                  " Не задан артикул товара, см. строку " impc skip.
               export stream  Err text-string .
            output stream Err close.
            next.
        END.
        if trim(i-size) = "" AND trim(i-color) = "" THEN
           ASSIGN  i-scale =  "_Пустая шкала".
        ELSE DO:
           if trim(i-size) = "" THEN i-size = "Б.Р.".
           if trim(i-color) = "" THEN i-color = "Б.Ц.".
           i-scale =  i-size + "/" +  i-color.
        END.
        if trim(i-prod-bc) = "" THEN DO:
            OUTPUT stream Err TO value ("Imp_goods.err") append.
               put stream Err unformatted
                  string(today, "99/99/9999") " "
                  string(time, "HH:MM")
                  " Не задан бар-код товара, см. строку " impc  skip.
               export stream  Err text-string .
            output stream Err close.
            next.
        END.
        IF trim(i-name) = "" THEN DO:
            OUTPUT stream Err TO value ("Imp_goods.err") append.
               put stream Err unformatted
                  string(today, "99/99/9999") " "
                  string(time, "HH:MM")
                  " Не заданно наименование товара, см. строку " impc skip.
               export stream  Err text-string .
            output stream Err close.
            next.
        END.
        display
                 impc  label "Прочитано"
                 imp-save label "Сохранено"
                 i-artic format "x(10)" label "Артикул"
                 text-string format "x(40)" label "Строка файла"
              with frame ff view-as dialog-box
              title ": Импорт справочника товаров из файла".
        pause 0.
        find first buf-prt where
             buf-prt.root    = no and
             buf-prt.f-name = i-scale  no-lock no-error.
        if not avail buf-prt then do:
                find first buf-prt where
             buf-prt.upper-code = cod-size-color and
                      buf-prt.root       = no and
                      buf-prt.node-name = i-size  no-lock no-error.
                if not avail buf-prt then do:
                      run add-color (input i-size, output reply ).
                      if reply = false then do:
                               OUTPUT stream Err TO value ("Imp_goods.err") append.
                               put stream err unformatted
                                  string(today, "99/99/9999") " "
                                  string(time, "HH:MM")
                                  " Такая шкала  размера отсутствует в БД, см. строку " impc skip.
                               export stream  err text-string .
                               output stream err close.
                         next.
                      end.
                      add-scale = true.
                end.
                find first buf-prt where
                     buf-prt.root    = no and
                     buf-prt.node-name = i-color  no-lock no-error.
                if not avail buf-prt then do:
                     run add-size (input i-color, output reply ).
                     if reply = false then do:
                         OUTPUT stream Err TO value ("Imp_goods.err") append.
                         put stream err unformatted
                           string(today, "99/99/9999") " "
                           string(time, "HH:MM")
                           " Такая шкала цвета отсутствует в БД, см. строку " impc skip.
                         export stream  err text-string .
                         output stream err close.
                        next.
                     end.
                     add-scale = true.
                end.
        end.
        if  trim(city1) <> "" then  i-city = city1 .
        find first ub.lvl-name no-lock no-error.
        find first ub.gds-prt where
             ub.gds-prt.prt-root  = ub.lvl-name.upper-code and
             ub.gds-prt.is-term   = no  and
             ub.gds-prt.upper-code = ub.lvl-name.upper-code
        no-lock no-error.
        if not avail gds-prt then do:
                  OUTPUT stream Err TO value ("Imp_goods.err") append.
                  put stream err unformatted
                    string(today, "99/99/9999") " "
                    string(time, "HH:MM")
                    " Корневая шкала не найдена" skip.
                  export stream  err text-string .
                  output stream err close.
                  next.
        end.
        find goods where
                   goods.artic = i-artic and
                   goods.prod-type = cli-type and
                   goods.prod-code = cli-code
        no-lock no-error.
        if not avail goods then do:
             do transaction:
                     define variable v-host-code     as integer           no-undo.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  )  .
                     run ref/dtaxgdss.p (
                           input no
                         , input   "шт."
                         , input   grp-code
                         , input ?
                         , input ?
                         , input    v-host-code
                         , input    v-cntxt-obj-type
                         , input   v-cntxt-obj-code
                     ).
                     define variable v-recid         as recid             no-undo.
            run ref/goods01.p (
                  input parparentproc
                , input 'ДОБАВЛЕНИЕ':U
                , input no
                , input 0
                , input no
                , input yes
                , input YES
                , input no
                , input yes
                , input v-host-code
                , input v-cntxt-obj-type
                , input v-cntxt-obj-code
                , input yes
                , input ?
                , input 0
                , input i-artic
                , input cli-type
                , input cli-code
                , input gds-prt.node-code
                , input  grp-code
                , input i-name
                , input ""
                , input ""
                , input i-name
                , input replace( replace( i-name, chr( 39 ), "" ), chr( 34 ), "" )
                , input i-city
                , input "шт."
                , input "шт."
                , input 0.0
                , input 0.0
                , input 1
                , input 1
                , input 0
                , input 0
                , input 0
                , input 0
                , input 'Группа':U
                , input 0
                , input yes
                , input 0
                , input 0
                , input ""
                , input ""
                , input ""
                , input i-prav
                , input i-sertif
                , input i-sostav
                , input 0
                , input 0
                , input ""
                , input 0.0
                , input 0
                , input 0
                , input ""
                , input ""
                , input ""
                , input 0
                , input ?
                , input ""
                , input no
                , input no
                , input no
                , input no
                , input "no"
                , input yes
                , input no
                , input no
                , input 0
                , input-output v-recid
                , output j-gds-code
            ) no-error .
            if error-status :error
            then do:
                message
                         vss-workfile vss-revision vss-description
                    skip "Ошибка создания или изменения карточки товара."
                    skip return-value
                    skip i-artic
                    skip trim(error-status :get-message(1))
                         trim(error-status :get-message(2))
                         trim(error-status :get-message(3))
                view-as alert-box error.
            end.
                    log-save = true.
             end.
        end.
        find goods where
                   goods.artic = i-artic and
                   goods.prod-type = cli-type and
                   goods.prod-code = cli-code
        no-lock no-error.
        if not avail goods then do:
               OUTPUT stream Err TO value ("Imp_goods.err") append.
                  put stream Err unformatted
                    string(today, "99/99/9999") " "
                    string(time, "HH:MM")
                    " Уже есть такой товар, см. строку " impc skip.
                  export stream  Err text-string .
               output stream Err close.
        end.
        find first ub.prod-bc where  ub.prod-bc.b-str  = i-prod-bc no-lock no-error.
        if  not avail ub.prod-bc then do:
              find ub.gds-prt where
                  ub.gds-prt.prt-root = ub.lvl-name.upper-code and
                  ub.gds-prt.f-name = i-scale  no-lock no-error.
              if  avail gds-prt then do:
                   do transaction  :
                         find first ub.bar-code where ub.bar-code.gds-code = ub.goods.gds-code and
                             ub.bar-code.node-code = ub.gds-prt.node-code no-lock no-error.
                         if not avail ub.bar-code then do:
                                run gen-b-code IN THIS-PROCEDURE (
                                               input 'bcgb':U
                                              ,output var-bc-code
                                              ) no-error.
                                if error-status:error then do:
                                     return .
                                end.
                                else do:
                                   create buf_bar-code.
                                   assign
                                         buf_bar-code.b-code        = var-bc-code
                                         buf_bar-code.node-code     = ub.gds-prt.node-code
                                         buf_bar-code.gds-code      = ub.goods.gds-code
                                         buf_bar-code.in-code       = "":U
                                         buf_bar-code.part-code     = "":U
                                         buf_bar-code.unit-cli      = ub.goods.unit-base
                                         buf_bar-code.cli-base-rate = 1
                                   .
                                end.
                                find first ub.bar-code where ub.bar-code.gds-code = ub.goods.gds-code and
                                       ub.bar-code.node-code = ub.gds-prt.node-code no-lock no-error.
                         end.
                   end.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbctv in g#library
  (input i-prod-bc
  ,input  ub.bar-code.unit-cli
  ,input  ub.goods.unit-base
  ,input  'weight=request':u
  ,output l-is-weight
  )  .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbctv in g#library
  (input i-prod-bc
  ,input  ub.bar-code.unit-cli
  ,input  ub.goods.unit-base
  ,input  'pgweight=request':u
  ,output l-is-pgweight
  )  .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbctv in g#library
  (input i-prod-bc
  ,input  ub.bar-code.unit-cli
  ,input  ub.goods.unit-base
  ,input  'petrolium=request':u
  ,output l-is-petrolium
  )  .
                  if (l-is-weight
                  or l-is-pgweight
                  or l-is-petrolium
                  ) then do:
                   OUTPUT stream Err TO value ("Imp_goods.err") append.
                      put stream err unformatted
                       string(today, "99/99/9999") " "
                       string(time, "HH:MM")
                       " ДопБК Весовой или топливый невозможно проимпортировать, см. строку " impc skip.
                      export stream  err text-string .
                   output stream err close.
                  end.
                  else do:
                   do transaction:
                      define variable rid as recid no-undo .
                      rid = ?.
                      run trg/prod-bc1.p (
                                          input  parparentproc
                                          ,input yes
                                          ,input dif-pdbc
                                          ,input pbc-veto
                                          ,input no
                                          ,input ''
                                          ,input ""
                                          ,buffer ub.goods
                                          ,input ub.bar-code.b-code
                                          ,input-output i-prod-bc
                                          ,output rid
                                          ) no-error.
                      if error-status :error then do:
                        OUTPUT stream Err TO value ("Imp_goods.err") append.
                            put stream err unformatted
                            string(today, "99/99/9999") " "
                            string(time, "HH:MM")
                            substitute(" Ошибка при импорте ДопБК (&1&2&3), см. строку &4"
                                      , error-status:get-message(1)
                                      , chr(10)
                                      , return-value
                                      ,impc )
                                      skip.
                            export stream  err text-string .
                        output stream err close.
                      end.
                      else if rid = ? then do:
                        OUTPUT stream Err TO value ("Imp_goods.err") append.
                            put stream err unformatted
                            string(today, "99/99/9999") " "
                            string(time, "HH:MM")
                            substitute(" Невозможен импорт ДопБК (&1), см. строку &2"
                                      , return-value
                                      ,impc )
                                      skip.
                            export stream  err text-string .
                        output stream err close.
                      end.
                         log-save = true.
                   end.
                   end.
              end.
              else do:
                   OUTPUT stream Err TO value ("Imp_goods.err") append.
                      put stream err unformatted
                       string(today, "99/99/9999") " "
                       string(time, "HH:MM")
                       " Такая шкала отсутствует в БД, см. строку " impc skip.
                      export stream  err text-string .
                   output stream err close.
              end.
        end.
        else do:
                   OUTPUT stream Err TO value ("Imp_goods.err") append.
                      put stream err unformatted
                        string(today, "99/99/9999") " "
                        string(time, "HH:MM")
                        " Такой Доп-БК уже существует в БД, см. строку " impc skip.
                      export stream  err text-string .
                   output stream err close.
        end.
        if   log-save = true then imp-save = imp-save + 1.
   end.
   input stream imp close.
    message ("Импорт из файла " + file-name + " закончен, прочитано " + string(impc) +
             ",  сохранено " + string(imp-save) ) skip
             "Все строки из файла которые не удалось импортировать можно посмотреть в файле Imp_goods.err "
    view-as alert-box  INFORMATION.
END.
ON CHOOSE OF grp IN FRAME Dialog-Frame
DO:
    run ref/gds-grp.w ( input parparentproc
                 , input "b-sel"
                 , input v-cntxt-obj-type
                 , input v-cntxt-obj-code
                 , input-output g-grp ).
    if g-grp <> "" then do:
       FIND FIRST ub.gds-grp WHERE
         recid (ub.gds-grp) = integer (g-grp) NO-LOCK.
       if avail ub.gds-grp then do:
            g-grp = "".
            run grplib-get-full-name in this-procedure ( input ub.gds-grp.node-code, output g-grp ) .
            assign
               grp-code = ub.gds-grp.node-code
               grp-txt = g-grp.
            disp
                grp-txt
            with frame Dialog-Frame.
            FOR EACH ub.tax No-LOCK WHERE
                     ub.tax.individual = no:
                  if ub.tax.individual = yes then next .
                  FIND LAST ub.tax-rate-gds-grp No-LOCK WHERE
                        ub.tax-rate-gds-grp.node-code = grp-code AND
                        ub.tax-rate-gds-grp.tax-code = ub.tax.tax-code AND
                        ub.tax-rate-gds-grp.host-code = 0 AND
                        ub.tax-rate-gds-grp.obj-type = "" AND
                        ub.tax-rate-gds-grp.obj-code = 0 NO-ERROR.
                  if avail ub.tax-rate-gds-grp THEN
                    assign
                          varrate-code = ub.tax-rate-gds-grp.rate-code.
                  FIND FIRST ub.tax-rate No-LOCK WHERE
                              ub.tax-rate.tax-code = ub.tax.tax-code AND
                              ub.tax-rate.rate-code = varrate-code No-ERROR.
                  if error-status:error or not avail ub.tax-rate then do:
                    message
                         vss-workfile vss-revision vss-description skip
                         "Не найдена запись ставки налога:"
                         "код налога" ub.tax.tax-code "код ставки" varrate-code
                     view-as alert-box error .
                  end.
                  IF ub.tax-rate-gds-grp.tax-code = 1 THEN NDS-code = ub.tax-rate-gds-grp.rate-code.
                  IF ub.tax-rate-gds-grp.tax-code = 2 THEN NP-code = ub.tax-rate-gds-grp.rate-code.
            end.
       end.
    end.
END.
ON CHOOSE OF Imly-City IN FRAME Dialog-Frame
DO:
define variable v-rid-list as character no-undo .
    run ref/countris.w ( input parparentproc
                  , input "b-sel"
                  , input-output v-rid-list ).
if v-rid-list <> '' then  do:
  FIND ub.country WHERE recid (ub.country) = integer(v-rid-list) NO-LOCK.
  if avail country then
          assign
          city1 = ub.country.alpha1
          city2 = ub.country.long-name.
            disp
              city1
              city2
         with frame Dialog-Frame.
    end.
END.
ON CHOOSE OF Imply-Cli IN FRAME Dialog-Frame
DO:
define variable ref-rec as recid no-undo .
    run ref/cli-all.w ( parparentproc, input "b-sel", 'орг':U, ?, ?, ?, ?, ?, output  ref-list).
    if ref-list = '' then do:
      return no-apply.
    end.
    ref-rec = integer (ref-list).
    if  ref-rec <> ? then do:
        FIND ub.clients WHERE recid (ub.clients) = ref-rec NO-LOCK .
        if avail ub.clients then
           assign
           Cli-type = ub.clients.obj-type
           Cli-code = ub.clients.obj-code
           Cli-name = ub.clients.obj-name .
           disp
             Cli-type
             Cli-code
             Cli-name
        with frame Dialog-Frame.
    end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
   find gds-prt where
        gds-prt.root    = YES and
        gds-prt.node-name = "Размер + Цвет" no-lock no-error.
   if not avail gds-prt then do:
            message "Не найдена шкала - Размер + Цвет  "
            view-as alert-box ERROR.
            return no-apply.
   end.
   else
      assign
          end-cod = gds-prt.upper-code
          cod-size-color = gds-prt.node-code.
   enable Imply-Cli with frame Dialog-Frame.
  run adm/shattri.p (
      input "get":U
      ,input  '':U
      ,input  0
      ,input  'gds-ref':U
      ,input  'dif-pdbc':U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output dif-pdbc
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error.
  delete object v-tth.
  run adm/shattri.p (
      input "get":U
      ,input  '':U
      ,input  0
      ,input  'gds-ref':U
      ,input  'pbc-veto':U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output pbc-veto
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error.
  delete object v-tth.
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE add-color :
define input  parameter new-scale like ub.gds-prt.f-name no-undo .
define output parameter reply  as log no-undo .
define buffer buf-gds-prt-1  for ub.gds-prt.
define buffer buf-gds-prt-2  for ub.gds-prt.
define variable u-c like ub.gds-prt.upper-code no-undo.
define variable p-n like ub.gds-prt.prt-num no-undo.
define variable n-c like ub.gds-prt.node-code no-undo.
define variable p-r like ub.gds-prt.prt-root no-undo.
for each ld :
  delete ld.
end.
     reply = false.
     for each ub.gds-prt where
           ub.gds-prt.upper-code = 1233  and
           ub.gds-prt.node-name <> ub.gds-prt.f-name and
           ub.gds-prt.is-term = yes
      no-lock:
          find ld where ld.name = ub.gds-prt.node-name no-lock no-error.
          if not avail ld then do:
              create ld.
                 assign
                    ld.name = ub.gds-prt.node-name
                    ld.num    = ub.gds-prt.prt-num .
          end.
     end.
     find first ub.lvl-name no-lock no-error.
      if not avail ub.lvl-name then do:
            reply = false.
            return.
      end.
     find gds-prt where
           gds-prt.upper-code = lvl-name.upper-code and
           gds-prt.prt-num    = 0
      no-lock no-error.
      if not avail gds-prt then do:
            reply = false.
            return.
      end.
      u-c = gds-prt.node-code .
      find last gds-prt  no-lock use-index pi no-error.
      if not avail gds-prt then do:
            reply = false.
            return.
      end.
      n-c = gds-prt.node-code.
      find last gds-prt no-lock  where
          gds-prt.upper-code =  u-c
      use-index level no-error.
      if not avail gds-prt then do:
            reply = false.
            return.
      end.
      p-n = gds-prt.prt-num.
      do transaction:
           create buf-gds-prt-1.
           assign
               buf-gds-prt-1.node-code   =  n-c + 1
               buf-gds-prt-1.upper-code  = u-c
               buf-gds-prt-1.node-name    = new-scale
               buf-gds-prt-1.prt-num     = p-n + 1
               buf-gds-prt-1.root        = no
               buf-gds-prt-1.lvl-num     = lvl-name.level
               buf-gds-prt-1.f-name      = new-scale
               buf-gds-prt-1.is-term     = no
               buf-gds-prt-1.prt-root    = lvl-name.upper-code
            .
            n-c = n-c + 1.
            for each ld no-lock :
                 create buf-gds-prt-2.
                 assign
                     buf-gds-prt-2.node-code   = n-c  + 1
                     buf-gds-prt-2.upper-code  = buf-gds-prt-1.node-code
                     buf-gds-prt-2.node-name    = ld.name
                     buf-gds-prt-2.prt-num     = ld.num
                     buf-gds-prt-2.root        = no
                     buf-gds-prt-2.lvl-num     = 1
                     buf-gds-prt-2.f-name      = trim(buf-gds-prt-1.f-name) + "/" + trim(ld.name)                     buf-gds-prt-2.is-term     = yes
                     buf-gds-prt-2.prt-root    = lvl-name.upper-code
                 .
                 n-c = n-c + 1.
            end.
            reply = true.
      end.
      current-value (s-gds-prt, ub) = n-c.
END PROCEDURE.
PROCEDURE add-size :
define input  parameter new-scale like ub.gds-prt.f-name no-undo .
define output parameter reply  as log no-undo .
define buffer buf-gds-prt-1  for ub.gds-prt.
define buffer buf-gds-prt-2  for ub.gds-prt.
define variable u-c like ub.gds-prt.upper-code no-undo.
define variable p-n like ub.gds-prt.prt-num no-undo.
define variable n-c like ub.gds-prt.node-code no-undo.
define variable p-r like ub.gds-prt.prt-root no-undo.
for each ld :
  delete ld.
end.
      reply = false.
      p-n = 0.
      find last ub.gds-prt no-lock where
           ub.gds-prt.upper-code = 1233  use-index level no-error.
      if not avail ub.gds-prt then do:
            reply = false.
            return.
      end.
      p-n = ub.gds-prt.prt-num.
      for each ub.gds-prt where
           ub.gds-prt.upper-code = 1232  and
           ub.gds-prt.node-name = ub.gds-prt.f-name and
           ub.gds-prt.is-term = no
      no-lock:
          find ld where ld.name = ub.gds-prt.node-name no-lock no-error.
          if not avail ld then do:
              create ld.
                 assign
                    ld.name = ub.gds-prt.node-name
                    ld.num    = ub.gds-prt.prt-num
                    ld.ord     = ub.gds-prt.node-code .
          end.
      end.
     find first ub.lvl-name no-lock no-error.
      if not avail ub.lvl-name then do:
            reply = false.
            return.
      end.
      find last ub.gds-prt  no-lock use-index pi no-error.
      if not avail ub.gds-prt then do:
            reply = false.
            return.
      end.
      n-c = ub.gds-prt.node-code.
      do transaction:
           for each ld no-lock:
                create buf-gds-prt-1.
                assign
                    buf-gds-prt-1.node-code    =  n-c + 1
                    buf-gds-prt-1.upper-code   = ld.ord
                    buf-gds-prt-1.node-name    = new-scale
                    buf-gds-prt-1.prt-num      = p-n + 1
                    buf-gds-prt-1.root         = no
                    buf-gds-prt-1.lvl-num      = 1
                    buf-gds-prt-1.f-name       = ld.name + "/" + new-scale
                    buf-gds-prt-1.is-term      = yes
                    buf-gds-prt-1.prt-root     = ub.lvl-name.upper-code
                 .
            n-c = n-c + 1.
            reply = true.
           end.
      end.
      current-value (s-gds-prt, ub) = n-c.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY Cli-code Cli-type Cli-Name grp-txt city1 city2
      WITH FRAME Dialog-Frame.
  ENABLE grp Imly-City Btn_OK Btn_Cancel Cli-code Cli-type Cli-Name grp-txt
         city1 city2
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE res-t :
END PROCEDURE.
