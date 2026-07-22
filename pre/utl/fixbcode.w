CREATE WIDGET-POOL.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр и изменение диапазонов кодов".
define variable conf-par as character no-undo.
define variable mode-erprn as logical no-undo.
define variable par-type as character no-undo.
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
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
function diff-list returns character (
  input parfirst-list  as character,
  input parsecond-list as character,
  input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, parsecond-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function add-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  def var v-num-parsecond-list as integer no-undo .
  assign
    v-num-parsecond-list = num-entries(parsecond-list, pardelim)
  .
  do ind = 1 to v-num-parsecond-list
  :
    assign
      v-elem = entry(ind, parsecond-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function cross-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0
    and lookup(v-elem, parsecond-list, pardelim) > 0
    then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character)
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons)
                          ), par-rs-radio-buttons
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
function m-radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character,
 input par-delim as character
 )
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim)
                          ), par-rs-radio-buttons, par-delim
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
FUNCTION mixlist returns character
(
 input parfirst-list  as character
 ,input parsecond-list as character
 ,input pardelim       as character
 ,input pardelim-result as character ) :
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem1 as character no-undo .
  def var v-elem2 as character no-undo .
  def var v-result-list as character no-undo init "".
  do ind = 1 to num-entries(parfirst-list, pardelim)
  :
    assign
      v-elem1 = entry(ind, parfirst-list, pardelim)
      v-elem2 = entry(ind, parsecond-list, pardelim)
    .
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim-result else "")
                      + v-elem1 + pardelim-result + v-elem2
      .
  end.
  return v-result-list .
END FUNCTION.
define stream getmc-stream .
procedure get-max-code :
  define input  parameter p-action         as   character                 no-undo .
  define input  parameter p-db-num         like ub.db.db-num             no-undo .
  define input  parameter p-curr-type-cdrg like ub.code-range.range-type no-undo .
  define input  parameter p-first-code     like ub.code-range.first-code no-undo .
  define input  parameter p-last-code      like ub.code-range.last-code  no-undo .
  define input  parameter p-view-mess      as   logical                   no-undo .
  define output parameter v-b-code         as   integer                   no-undo .
  do
  on error undo, return error return-value
  :
    define variable v-main-bcode     like ub.bar-code.b-code no-undo .
    define variable l-prod-bc-global as   logical             no-undo .
    define variable l-prod-bc-weight as   logical             no-undo .
    define variable l-prod-bc-pgweight as   logical             no-undo .
    define variable rec-cnt          as   integer             no-undo .
    define variable str-u-f          as   character           no-undo .
    define variable str-u-f-rng      as   character           no-undo .
    define variable ind              as   integer             no-undo .
    define variable v-msg              as   character           no-undo initial "":U.
    define variable v-ret-msg          as   character           no-undo initial "":U.
    define frame get-max-code-inf
      rec-cnt label "Просмотрено"
      with view-as dialog-box side-labels row 11 centered
      title "..........................................." three-d
    .
    define buffer buf_code-range   for ub.code-range .
    define buffer buf-c_code-range for ub.code-range .
    define buffer buf_bar-code     for ub.bar-code .
    define buffer buf_place        for ub.place .
    define buffer buf_goods        for ub.goods .
    define buffer buf_units        for ub.units .
    define buffer buf_prod-bc      for ub.prod-bc .
    define buffer buf_dis-card     for ub.dis-card .
    define buffer buf_dis-rule     for ub.dis-rule .
    define buffer buf_dis-time-rule     for ub.dis-time-rule .
    define buffer buf_firm         for ub.firm .
    define buffer buf_person       for ub.person .
    define buffer buf_contract     for ub.contract .
    if p-curr-type-cdrg = 'sslc':U
    or p-curr-type-cdrg = 'ssgb':U
    then do:
      assign
        v-b-code = ?
      .
      return.
    end.
    if p-curr-type-cdrg = 'sclc':U
    or p-curr-type-cdrg = 'pglc':U
      or p-curr-type-cdrg = 'sslc':U
    then do:
      assign
        p-db-num = 0
      .
    end.
    case p-action :
      when "get-m-code":U then do:
        assign
          v-b-code = p-first-code
        .
      end.
      when "f-u":U then do:
        assign
          v-b-code = 0
        .
      end.
    end case.
    case p-curr-type-cdrg :
      when 'dcgb':U then do:
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-ii2 as integer   no-undo .
define variable v-table-name2 as character no-undo .
define variable v-field-name2 as character no-undo .
define variable buf_h2 as handle no-undo .
define variable q_h2 as handle no-undo .
define variable v-avail2 as integer   no-undo .
define variable v-code-mess2 as character no-undo .
define variable glog2 as logical   no-undo .
define variable v-code_2 as integer   no-undo .
case p-action :
  when "get-m-code":U then do:
    do v-ii2 = 1 to num-entries('ub.dis-card'):
      assign
      v-table-name2 = entry(v-ii2, 'ub.dis-card')
      v-field-name2 = entry(v-ii2, 'card-num')
      .
      create buffer buf_h2 for table v-table-name2.
      create query q_h2.
      q_h2:SET-BUFFERS(buf_h2).
      q_h2:QUERY-PREPARE(substitute(" for each &1 WHERE &1.&2 >= &3 and &1.&2 <= &4 by &1.&2 descending"
                        ,v-table-name2
                        ,v-field-name2
                        ,p-first-code
                        ,p-last-code)
                        ).
      q_h2:QUERY-OPEN.
      REPEAT while  q_h2:get-next().
        assign
          v-code_2 = buf_h2:buffer-field(v-field-name2):buffer-value
        .
        leave .
      END.
      q_h2:QUERY-CLOSE().
      delete object q_h2.
      delete object buf_h2.
      v-b-code = max(v-code_2, v-b-code).
    end.
  end.
  when "f-u":U then do:
    for each buf_code-range share-lock
        where ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "f":U
              ) or
              ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "u":U
              )
    on error undo, return error
    :
      v-avail2 = 0.
      do v-ii2 = 1 to num-entries('ub.dis-card'):
        assign
        v-table-name2 = entry(v-ii2, 'ub.dis-card')
        v-field-name2 = entry(v-ii2, 'card-num')
        .
        create buffer buf_h2 for table v-table-name2.
        glog2 = buf_h2:find-first ( substitute(" where &1.&2 >= &3 and &1.&2 <= &4 "
                                , v-table-name2
                                , v-field-name2
                                , buf_code-range.first-code
                                , buf_code-range.last-code)
                                ) no-error .
        if buf_h2:available then do:
          assign
          v-avail2 = v-avail2 + 1
          .
          if v-avail2 = 1 then do:
            v-code-mess2 = string(buf_h2:buffer-field(v-field-name2):buffer-value)
            .
          end.
        end.
        delete object buf_h2.
     end.
     if v-avail2 > 0
        and buf_code-range.stts = "f":U
      then do:
        assign
          buf_code-range.stts = "u":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'u' т.к. существующий код &4 попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                            , v-code-mess2
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
      if v-avail2 = 0
        and buf_code-range.stts = "u":U
      then do:
        find first buf-c_code-range exclusive-lock
          where rowid( buf-c_code-range ) = rowid( buf_code-range )
        .
        assign
          buf-c_code-range.stts = "c":U
        .
        release buf-c_code-range .
        assign
          buf_code-range.stts = "f":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'f' т.к. нет ни одного кода который попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
    end.
  end.
end case.
      end.
      when 'ctgb':U then do:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-ii3 as integer   no-undo .
define variable v-table-name3 as character no-undo .
define variable v-field-name3 as character no-undo .
define variable buf_h3 as handle no-undo .
define variable q_h3 as handle no-undo .
define variable v-avail3 as integer   no-undo .
define variable v-code-mess3 as character no-undo .
define variable glog3 as logical   no-undo .
define variable v-code_3 as integer   no-undo .
case p-action :
  when "get-m-code":U then do:
    do v-ii3 = 1 to num-entries('ub.contract'):
      assign
      v-table-name3 = entry(v-ii3, 'ub.contract')
      v-field-name3 = entry(v-ii3, 'contract-code')
      .
      create buffer buf_h3 for table v-table-name3.
      create query q_h3.
      q_h3:SET-BUFFERS(buf_h3).
      q_h3:QUERY-PREPARE(substitute(" for each &1 WHERE &1.&2 >= &3 and &1.&2 <= &4 by &1.&2 descending"
                        ,v-table-name3
                        ,v-field-name3
                        ,p-first-code
                        ,p-last-code)
                        ).
      q_h3:QUERY-OPEN.
      REPEAT while  q_h3:get-next().
        assign
          v-code_3 = buf_h3:buffer-field(v-field-name3):buffer-value
        .
        leave .
      END.
      q_h3:QUERY-CLOSE().
      delete object q_h3.
      delete object buf_h3.
      v-b-code = max(v-code_3, v-b-code).
    end.
  end.
  when "f-u":U then do:
    for each buf_code-range share-lock
        where ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "f":U
              ) or
              ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "u":U
              )
    on error undo, return error
    :
      v-avail3 = 0.
      do v-ii3 = 1 to num-entries('ub.contract'):
        assign
        v-table-name3 = entry(v-ii3, 'ub.contract')
        v-field-name3 = entry(v-ii3, 'contract-code')
        .
        create buffer buf_h3 for table v-table-name3.
        glog3 = buf_h3:find-first ( substitute(" where &1.&2 >= &3 and &1.&2 <= &4 "
                                , v-table-name3
                                , v-field-name3
                                , buf_code-range.first-code
                                , buf_code-range.last-code)
                                ) no-error .
        if buf_h3:available then do:
          assign
          v-avail3 = v-avail3 + 1
          .
          if v-avail3 = 1 then do:
            v-code-mess3 = string(buf_h3:buffer-field(v-field-name3):buffer-value)
            .
          end.
        end.
        delete object buf_h3.
     end.
     if v-avail3 > 0
        and buf_code-range.stts = "f":U
      then do:
        assign
          buf_code-range.stts = "u":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'u' т.к. существующий код &4 попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                            , v-code-mess3
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
      if v-avail3 = 0
        and buf_code-range.stts = "u":U
      then do:
        find first buf-c_code-range exclusive-lock
          where rowid( buf-c_code-range ) = rowid( buf_code-range )
        .
        assign
          buf-c_code-range.stts = "c":U
        .
        release buf-c_code-range .
        assign
          buf_code-range.stts = "f":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'f' т.к. нет ни одного кода который попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
    end.
  end.
end case.
      end.
      when 'cagb':U then do:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-ii4 as integer   no-undo .
define variable v-table-name4 as character no-undo .
define variable v-field-name4 as character no-undo .
define variable buf_h4 as handle no-undo .
define variable q_h4 as handle no-undo .
define variable v-avail4 as integer   no-undo .
define variable v-code-mess4 as character no-undo .
define variable glog4 as logical   no-undo .
define variable v-code_4 as integer   no-undo .
case p-action :
  when "get-m-code":U then do:
    do v-ii4 = 1 to num-entries('ub.rule-by-call'):
      assign
      v-table-name4 = entry(v-ii4, 'ub.rule-by-call')
      v-field-name4 = entry(v-ii4, 'call#_id')
      .
      create buffer buf_h4 for table v-table-name4.
      create query q_h4.
      q_h4:SET-BUFFERS(buf_h4).
      q_h4:QUERY-PREPARE(substitute(" for each &1 WHERE &1.&2 >= &3 and &1.&2 <= &4 by &1.&2 descending"
                        ,v-table-name4
                        ,v-field-name4
                        ,p-first-code
                        ,p-last-code)
                        ).
      q_h4:QUERY-OPEN.
      REPEAT while  q_h4:get-next().
        assign
          v-code_4 = buf_h4:buffer-field(v-field-name4):buffer-value
        .
        leave .
      END.
      q_h4:QUERY-CLOSE().
      delete object q_h4.
      delete object buf_h4.
      v-b-code = max(v-code_4, v-b-code).
    end.
  end.
  when "f-u":U then do:
    for each buf_code-range share-lock
        where ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "f":U
              ) or
              ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "u":U
              )
    on error undo, return error
    :
      v-avail4 = 0.
      do v-ii4 = 1 to num-entries('ub.rule-by-call'):
        assign
        v-table-name4 = entry(v-ii4, 'ub.rule-by-call')
        v-field-name4 = entry(v-ii4, 'call#_id')
        .
        create buffer buf_h4 for table v-table-name4.
        glog4 = buf_h4:find-first ( substitute(" where &1.&2 >= &3 and &1.&2 <= &4 "
                                , v-table-name4
                                , v-field-name4
                                , buf_code-range.first-code
                                , buf_code-range.last-code)
                                ) no-error .
        if buf_h4:available then do:
          assign
          v-avail4 = v-avail4 + 1
          .
          if v-avail4 = 1 then do:
            v-code-mess4 = string(buf_h4:buffer-field(v-field-name4):buffer-value)
            .
          end.
        end.
        delete object buf_h4.
     end.
     if v-avail4 > 0
        and buf_code-range.stts = "f":U
      then do:
        assign
          buf_code-range.stts = "u":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'u' т.к. существующий код &4 попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                            , v-code-mess4
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
      if v-avail4 = 0
        and buf_code-range.stts = "u":U
      then do:
        find first buf-c_code-range exclusive-lock
          where rowid( buf-c_code-range ) = rowid( buf_code-range )
        .
        assign
          buf-c_code-range.stts = "c":U
        .
        release buf-c_code-range .
        assign
          buf_code-range.stts = "f":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'f' т.к. нет ни одного кода который попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
    end.
  end.
end case.
      end.
      when 'fdgb':U then do:
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-ii5 as integer   no-undo .
define variable v-table-name5 as character no-undo .
define variable v-field-name5 as character no-undo .
define variable buf_h5 as handle no-undo .
define variable q_h5 as handle no-undo .
define variable v-avail5 as integer   no-undo .
define variable v-code-mess5 as character no-undo .
define variable glog5 as logical   no-undo .
define variable v-code_5 as integer   no-undo .
case p-action :
  when "get-m-code":U then do:
    do v-ii5 = 1 to num-entries('ub.fin-doc'):
      assign
      v-table-name5 = entry(v-ii5, 'ub.fin-doc')
      v-field-name5 = entry(v-ii5, 'fin-doc-code')
      .
      create buffer buf_h5 for table v-table-name5.
      create query q_h5.
      q_h5:SET-BUFFERS(buf_h5).
      q_h5:QUERY-PREPARE(substitute(" for each &1 WHERE &1.&2 >= &3 and &1.&2 <= &4 by &1.&2 descending"
                        ,v-table-name5
                        ,v-field-name5
                        ,p-first-code
                        ,p-last-code)
                        ).
      q_h5:QUERY-OPEN.
      REPEAT while  q_h5:get-next().
        assign
          v-code_5 = buf_h5:buffer-field(v-field-name5):buffer-value
        .
        leave .
      END.
      q_h5:QUERY-CLOSE().
      delete object q_h5.
      delete object buf_h5.
      v-b-code = max(v-code_5, v-b-code).
    end.
  end.
  when "f-u":U then do:
    for each buf_code-range share-lock
        where ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "f":U
              ) or
              ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "u":U
              )
    on error undo, return error
    :
      v-avail5 = 0.
      do v-ii5 = 1 to num-entries('ub.fin-doc'):
        assign
        v-table-name5 = entry(v-ii5, 'ub.fin-doc')
        v-field-name5 = entry(v-ii5, 'fin-doc-code')
        .
        create buffer buf_h5 for table v-table-name5.
        glog5 = buf_h5:find-first ( substitute(" where &1.&2 >= &3 and &1.&2 <= &4 "
                                , v-table-name5
                                , v-field-name5
                                , buf_code-range.first-code
                                , buf_code-range.last-code)
                                ) no-error .
        if buf_h5:available then do:
          assign
          v-avail5 = v-avail5 + 1
          .
          if v-avail5 = 1 then do:
            v-code-mess5 = string(buf_h5:buffer-field(v-field-name5):buffer-value)
            .
          end.
        end.
        delete object buf_h5.
     end.
     if v-avail5 > 0
        and buf_code-range.stts = "f":U
      then do:
        assign
          buf_code-range.stts = "u":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'u' т.к. существующий код &4 попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                            , v-code-mess5
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
      if v-avail5 = 0
        and buf_code-range.stts = "u":U
      then do:
        find first buf-c_code-range exclusive-lock
          where rowid( buf-c_code-range ) = rowid( buf_code-range )
        .
        assign
          buf-c_code-range.stts = "c":U
        .
        release buf-c_code-range .
        assign
          buf_code-range.stts = "f":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'f' т.к. нет ни одного кода который попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
    end.
  end.
end case.
      end.
      when 'fmgb':U then do:
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-ii6 as integer   no-undo .
define variable v-table-name6 as character no-undo .
define variable v-field-name6 as character no-undo .
define variable buf_h6 as handle no-undo .
define variable q_h6 as handle no-undo .
define variable v-avail6 as integer   no-undo .
define variable v-code-mess6 as character no-undo .
define variable glog6 as logical   no-undo .
define variable v-code_6 as integer   no-undo .
case p-action :
  when "get-m-code":U then do:
    do v-ii6 = 1 to num-entries('ub.firm'):
      assign
      v-table-name6 = entry(v-ii6, 'ub.firm')
      v-field-name6 = entry(v-ii6, 'firm-code')
      .
      create buffer buf_h6 for table v-table-name6.
      create query q_h6.
      q_h6:SET-BUFFERS(buf_h6).
      q_h6:QUERY-PREPARE(substitute(" for each &1 WHERE &1.&2 >= &3 and &1.&2 <= &4 by &1.&2 descending"
                        ,v-table-name6
                        ,v-field-name6
                        ,p-first-code
                        ,p-last-code)
                        ).
      q_h6:QUERY-OPEN.
      REPEAT while  q_h6:get-next().
        assign
          v-code_6 = buf_h6:buffer-field(v-field-name6):buffer-value
        .
        leave .
      END.
      q_h6:QUERY-CLOSE().
      delete object q_h6.
      delete object buf_h6.
      v-b-code = max(v-code_6, v-b-code).
    end.
  end.
  when "f-u":U then do:
    for each buf_code-range share-lock
        where ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "f":U
              ) or
              ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "u":U
              )
    on error undo, return error
    :
      v-avail6 = 0.
      do v-ii6 = 1 to num-entries('ub.firm'):
        assign
        v-table-name6 = entry(v-ii6, 'ub.firm')
        v-field-name6 = entry(v-ii6, 'firm-code')
        .
        create buffer buf_h6 for table v-table-name6.
        glog6 = buf_h6:find-first ( substitute(" where &1.&2 >= &3 and &1.&2 <= &4 "
                                , v-table-name6
                                , v-field-name6
                                , buf_code-range.first-code
                                , buf_code-range.last-code)
                                ) no-error .
        if buf_h6:available then do:
          assign
          v-avail6 = v-avail6 + 1
          .
          if v-avail6 = 1 then do:
            v-code-mess6 = string(buf_h6:buffer-field(v-field-name6):buffer-value)
            .
          end.
        end.
        delete object buf_h6.
     end.
     if v-avail6 > 0
        and buf_code-range.stts = "f":U
      then do:
        assign
          buf_code-range.stts = "u":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'u' т.к. существующий код &4 попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                            , v-code-mess6
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
      if v-avail6 = 0
        and buf_code-range.stts = "u":U
      then do:
        find first buf-c_code-range exclusive-lock
          where rowid( buf-c_code-range ) = rowid( buf_code-range )
        .
        assign
          buf-c_code-range.stts = "c":U
        .
        release buf-c_code-range .
        assign
          buf_code-range.stts = "f":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'f' т.к. нет ни одного кода который попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
    end.
  end.
end case.
      end.
      when 'pngb':U then do:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-ii7 as integer   no-undo .
define variable v-table-name7 as character no-undo .
define variable v-field-name7 as character no-undo .
define variable buf_h7 as handle no-undo .
define variable q_h7 as handle no-undo .
define variable v-avail7 as integer   no-undo .
define variable v-code-mess7 as character no-undo .
define variable glog7 as logical   no-undo .
define variable v-code_7 as integer   no-undo .
case p-action :
  when "get-m-code":U then do:
    do v-ii7 = 1 to num-entries('ub.person'):
      assign
      v-table-name7 = entry(v-ii7, 'ub.person')
      v-field-name7 = entry(v-ii7, 'psn-code')
      .
      create buffer buf_h7 for table v-table-name7.
      create query q_h7.
      q_h7:SET-BUFFERS(buf_h7).
      q_h7:QUERY-PREPARE(substitute(" for each &1 WHERE &1.&2 >= &3 and &1.&2 <= &4 by &1.&2 descending"
                        ,v-table-name7
                        ,v-field-name7
                        ,p-first-code
                        ,p-last-code)
                        ).
      q_h7:QUERY-OPEN.
      REPEAT while  q_h7:get-next().
        assign
          v-code_7 = buf_h7:buffer-field(v-field-name7):buffer-value
        .
        leave .
      END.
      q_h7:QUERY-CLOSE().
      delete object q_h7.
      delete object buf_h7.
      v-b-code = max(v-code_7, v-b-code).
    end.
  end.
  when "f-u":U then do:
    for each buf_code-range share-lock
        where ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "f":U
              ) or
              ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "u":U
              )
    on error undo, return error
    :
      v-avail7 = 0.
      do v-ii7 = 1 to num-entries('ub.person'):
        assign
        v-table-name7 = entry(v-ii7, 'ub.person')
        v-field-name7 = entry(v-ii7, 'psn-code')
        .
        create buffer buf_h7 for table v-table-name7.
        glog7 = buf_h7:find-first ( substitute(" where &1.&2 >= &3 and &1.&2 <= &4 "
                                , v-table-name7
                                , v-field-name7
                                , buf_code-range.first-code
                                , buf_code-range.last-code)
                                ) no-error .
        if buf_h7:available then do:
          assign
          v-avail7 = v-avail7 + 1
          .
          if v-avail7 = 1 then do:
            v-code-mess7 = string(buf_h7:buffer-field(v-field-name7):buffer-value)
            .
          end.
        end.
        delete object buf_h7.
     end.
     if v-avail7 > 0
        and buf_code-range.stts = "f":U
      then do:
        assign
          buf_code-range.stts = "u":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'u' т.к. существующий код &4 попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                            , v-code-mess7
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
      if v-avail7 = 0
        and buf_code-range.stts = "u":U
      then do:
        find first buf-c_code-range exclusive-lock
          where rowid( buf-c_code-range ) = rowid( buf_code-range )
        .
        assign
          buf-c_code-range.stts = "c":U
        .
        release buf-c_code-range .
        assign
          buf_code-range.stts = "f":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'f' т.к. нет ни одного кода который попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
    end.
  end.
end case.
      end.
      when 'drgb':U then do:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-ii8 as integer   no-undo .
define variable v-table-name8 as character no-undo .
define variable v-field-name8 as character no-undo .
define variable buf_h8 as handle no-undo .
define variable q_h8 as handle no-undo .
define variable v-avail8 as integer   no-undo .
define variable v-code-mess8 as character no-undo .
define variable glog8 as logical   no-undo .
define variable v-code_8 as integer   no-undo .
case p-action :
  when "get-m-code":U then do:
    do v-ii8 = 1 to num-entries('ub.dis-rule,ub.dis-time-rule'):
      assign
      v-table-name8 = entry(v-ii8, 'ub.dis-rule,ub.dis-time-rule')
      v-field-name8 = entry(v-ii8, 'rule-num,time-rule-num')
      .
      create buffer buf_h8 for table v-table-name8.
      create query q_h8.
      q_h8:SET-BUFFERS(buf_h8).
      q_h8:QUERY-PREPARE(substitute(" for each &1 WHERE &1.&2 >= &3 and &1.&2 <= &4 by &1.&2 descending"
                        ,v-table-name8
                        ,v-field-name8
                        ,p-first-code
                        ,p-last-code)
                        ).
      q_h8:QUERY-OPEN.
      REPEAT while  q_h8:get-next().
        assign
          v-code_8 = buf_h8:buffer-field(v-field-name8):buffer-value
        .
        leave .
      END.
      q_h8:QUERY-CLOSE().
      delete object q_h8.
      delete object buf_h8.
      v-b-code = max(v-code_8, v-b-code).
    end.
  end.
  when "f-u":U then do:
    for each buf_code-range share-lock
        where ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "f":U
              ) or
              ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "u":U
              )
    on error undo, return error
    :
      v-avail8 = 0.
      do v-ii8 = 1 to num-entries('ub.dis-rule,ub.dis-time-rule'):
        assign
        v-table-name8 = entry(v-ii8, 'ub.dis-rule,ub.dis-time-rule')
        v-field-name8 = entry(v-ii8, 'rule-num,time-rule-num')
        .
        create buffer buf_h8 for table v-table-name8.
        glog8 = buf_h8:find-first ( substitute(" where &1.&2 >= &3 and &1.&2 <= &4 "
                                , v-table-name8
                                , v-field-name8
                                , buf_code-range.first-code
                                , buf_code-range.last-code)
                                ) no-error .
        if buf_h8:available then do:
          assign
          v-avail8 = v-avail8 + 1
          .
          if v-avail8 = 1 then do:
            v-code-mess8 = string(buf_h8:buffer-field(v-field-name8):buffer-value)
            .
          end.
        end.
        delete object buf_h8.
     end.
     if v-avail8 > 0
        and buf_code-range.stts = "f":U
      then do:
        assign
          buf_code-range.stts = "u":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'u' т.к. существующий код &4 попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                            , v-code-mess8
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
      if v-avail8 = 0
        and buf_code-range.stts = "u":U
      then do:
        find first buf-c_code-range exclusive-lock
          where rowid( buf-c_code-range ) = rowid( buf_code-range )
        .
        assign
          buf-c_code-range.stts = "c":U
        .
        release buf-c_code-range .
        assign
          buf_code-range.stts = "f":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'f' т.к. нет ни одного кода который попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
    end.
  end.
end case.
      end.
      when 'bcgb':U then do:
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-ii9 as integer   no-undo .
define variable v-table-name9 as character no-undo .
define variable v-field-name9 as character no-undo .
define variable buf_h9 as handle no-undo .
define variable q_h9 as handle no-undo .
define variable v-avail9 as integer   no-undo .
define variable v-code-mess9 as character no-undo .
define variable glog9 as logical   no-undo .
define variable v-code_9 as integer   no-undo .
case p-action :
  when "get-m-code":U then do:
    do v-ii9 = 1 to num-entries('ub.bar-code,ub.place'):
      assign
      v-table-name9 = entry(v-ii9, 'ub.bar-code,ub.place')
      v-field-name9 = entry(v-ii9, 'b-code,pl-code')
      .
      create buffer buf_h9 for table v-table-name9.
      create query q_h9.
      q_h9:SET-BUFFERS(buf_h9).
      q_h9:QUERY-PREPARE(substitute(" for each &1 WHERE &1.&2 >= &3 and &1.&2 <= &4 by &1.&2 descending"
                        ,v-table-name9
                        ,v-field-name9
                        ,p-first-code
                        ,p-last-code)
                        ).
      q_h9:QUERY-OPEN.
      REPEAT while  q_h9:get-next().
        assign
          v-code_9 = buf_h9:buffer-field(v-field-name9):buffer-value
        .
        leave .
      END.
      q_h9:QUERY-CLOSE().
      delete object q_h9.
      delete object buf_h9.
      v-b-code = max(v-code_9, v-b-code).
    end.
  end.
  when "f-u":U then do:
    for each buf_code-range share-lock
        where ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "f":U
              ) or
              ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "u":U
              )
    on error undo, return error
    :
      v-avail9 = 0.
      do v-ii9 = 1 to num-entries('ub.bar-code,ub.place'):
        assign
        v-table-name9 = entry(v-ii9, 'ub.bar-code,ub.place')
        v-field-name9 = entry(v-ii9, 'b-code,pl-code')
        .
        create buffer buf_h9 for table v-table-name9.
        glog9 = buf_h9:find-first ( substitute(" where &1.&2 >= &3 and &1.&2 <= &4 "
                                , v-table-name9
                                , v-field-name9
                                , buf_code-range.first-code
                                , buf_code-range.last-code)
                                ) no-error .
        if buf_h9:available then do:
          assign
          v-avail9 = v-avail9 + 1
          .
          if v-avail9 = 1 then do:
            v-code-mess9 = string(buf_h9:buffer-field(v-field-name9):buffer-value)
            .
          end.
        end.
        delete object buf_h9.
     end.
     if v-avail9 > 0
        and buf_code-range.stts = "f":U
      then do:
        assign
          buf_code-range.stts = "u":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'u' т.к. существующий код &4 попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                            , v-code-mess9
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
      if v-avail9 = 0
        and buf_code-range.stts = "u":U
      then do:
        find first buf-c_code-range exclusive-lock
          where rowid( buf-c_code-range ) = rowid( buf_code-range )
        .
        assign
          buf-c_code-range.stts = "c":U
        .
        release buf-c_code-range .
        assign
          buf_code-range.stts = "f":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'f' т.к. нет ни одного кода который попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
    end.
  end.
end case.
      end.
      when 'scgb':U
      or when 'sclc':U
      then do:
        case p-action :
          when "get-m-code":U then do:
            assign
              frame get-max-code-inf :title = "Поиск максимального значения кода"
            .
          end.
          when "f-u":U then do:
            assign
              frame get-max-code-inf :title = "Корректировка статуса code-range"
            .
            run mark-all-used-as-free in this-procedure (
                                       input  p-db-num
                                      ,input  p-curr-type-cdrg
                                      ,output str-u-f
                                      ,output str-u-f-rng
                                    ).
          end.
        end case.
        view frame get-max-code-inf.
        assign
          rec-cnt = 0
        .
        display
          rec-cnt
          with frame get-max-code-inf
        .
        for each buf_units no-lock
            where lookup('вес':U, buf_units.type) > 0
        on error undo, return error
        :
          for each buf_goods no-lock
            where buf_goods.unit-base = buf_units.unit-name
          on error undo, return error
          :
            assign
              rec-cnt = rec-cnt + 1
            .
            if ( rec-cnt modulo 10 ) = 0 then do:
              display
                rec-cnt
                with frame get-max-code-inf
              .
            end.
            run mc_gdsbcode in this-procedure (
                             input  buf_goods.gds-code
                            ,input  ?
                            ,output v-main-bcode
                          ) no-error .
            if error-status :error then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при поиске корневого бар-кода" skip
                "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            for each buf_prod-bc no-lock
                where buf_prod-bc.b-code = v-main-bcode
            on error undo, return error
            :
              if p-curr-type-cdrg = 'sclc':U
                and buf_prod-bc.bc-on = FALSE
              then do:
                next.
              end.
              run mc_prodbcat in this-procedure (
                               buffer buf_prod-bc
                              ,input  'global=request':u
                              ,output l-prod-bc-global
                            ) no-error .
              if error-status :error then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Ошибка при определении типа дополнительного бар-кода prodbcat" skip
                  "Основной бар-код" buf_prod-bc.b-code skip
                  "Дополнительный бар-код" buf_prod-bc.b-str skip
                  "Действие global=request" skip
                  error-status :get-message(1) skip
                  return-value skip
                  view-as alert-box error .
                undo, return error .
              end.
              run mc_prodbcat in this-procedure (
                               buffer buf_prod-bc
                              ,input  'weight=request':u
                              ,output l-prod-bc-weight
                            ) no-error .
              if error-status :error then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Ошибка при определении типа дополнительного бар-кода prodbcat" skip
                  "Основной бар-код" buf_prod-bc.b-code skip
                  "Дополнительный бар-код" buf_prod-bc.b-str skip
                  "Действие weight=request" skip
                  error-status :get-message(1) skip
                  return-value skip
                  view-as alert-box error .
                undo, return error .
              end.
              if l-prod-bc-weight
                and ( ( l-prod-bc-global
                        and p-curr-type-cdrg = 'scgb':U
                      )
                      or
                      ( not l-prod-bc-global
                        and p-curr-type-cdrg = 'sclc':U
                      )
                    )
              then do:
                case p-action :
                  when "get-m-code":U then do:
                    if integer( buf_prod-bc.b-str ) >= p-first-code
                      and integer( buf_prod-bc.b-str ) <= p-last-code
                      and integer( buf_prod-bc.b-str ) > v-b-code
                    then do:
                      assign
                        v-b-code = integer( buf_prod-bc.b-str )
                      .
                    end.
                  end.
                  when "f-u":U then do:
                    for each buf_code-range
                      where buf_code-range.db-num     = p-db-num
                        and buf_code-range.range-type = p-curr-type-cdrg
                        and buf_code-range.stts       = "f":U
                        and buf_code-range.first-code <= integer( buf_prod-bc.b-str )
                        and buf_code-range.last-code  >= integer( buf_prod-bc.b-str )
                    on error undo, return error
                    :
                      assign
                        buf_code-range.stts = "u":U
                      .
                      if lookup( string( buf_code-range.first-code ) + "-":U + string( buf_code-range.last-code ), str-u-f-rng ) <> 0 then do:
                        assign
                          str-u-f-rng = diff-list( str-u-f-rng
                                                  ,string( buf_code-range.first-code ) + "-":U + string( buf_code-range.last-code )
                                                  ,",":U
                                                  )
                        .
                      end.
                      if lookup( buf_code-range.range-type + chr(3) + string( buf_code-range.first-code ), str-u-f ) = 0 then do:
                        assign
                          v-b-code = v-b-code + 1
                          v-msg     = substitute( "Диапазон кодов с &2 по &3&1"
                                                  + "Помечен как 'u' т.к. существующий код &4 попадает в данный диапазон.&1"
                                                  , chr(10)
                                                  , buf_code-range.first-code
                                                  , buf_code-range.last-code
                                                  , buf_prod-bc.b-str
                                                )
                          v-ret-msg = v-ret-msg + v-msg
                        .
                        if p-view-mess = true then do:
                          message
                            v-msg
                            view-as alert-box information.
                        end.
                      end.
                    end.
                  end.
                end case.
              end.
            end.
          end.
        end.
        if p-action = "f-u":U then do:
          do ind = 1 to num-entries( str-u-f-rng ):
            assign
              v-b-code  = v-b-code + 1
              v-msg     = substitute( "Диапазон кодов &2&1"
                                      + "Помечен как 'f' т.к. нет ни одного кода который попадает в данный диапазон.&1"
                                      , chr(10)
                                      , entry( ind, str-u-f-rng )
                                    )
              v-ret-msg = v-ret-msg + chr(10) + v-msg
            .
            if p-view-mess = true then do:
              message
                v-msg
                view-as alert-box information.
            end.
          end.
        end.
        hide frame get-max-code-inf no-pause .
      end.
      when 'pglc':U
      then do:
        case p-action :
          when "get-m-code":U then do:
            assign
              frame get-max-code-inf :title = "Поиск максимального значения кода"
            .
          end.
          when "f-u":U then do:
            assign
              frame get-max-code-inf :title = "Корректировка статуса code-range"
            .
            run mark-all-used-as-free in this-procedure (
                                       input  p-db-num
                                      ,input  p-curr-type-cdrg
                                      ,output str-u-f
                                      ,output str-u-f-rng
                                    ).
          end.
        end case.
        view frame get-max-code-inf.
        assign
          rec-cnt = 0
        .
        display
          rec-cnt
          with frame get-max-code-inf
        .
        for each buf_prod-bc no-lock where
                buf_prod-bc.b-str >= "00100"
            and buf_prod-bc.b-str <= "99999"
            and buf_prod-bc.bc-on-type = 'pglc':U
            and length(buf_prod-bc.b-str) = 5
        on error undo, return error
        :
            assign
              rec-cnt = rec-cnt + 1
            .
            if ( rec-cnt modulo 10 ) = 0 then do:
              display
                rec-cnt
                with frame get-max-code-inf
              .
            end.
            if p-curr-type-cdrg = 'pglc':U
              and buf_prod-bc.bc-on = FALSE
            then do:
              next.
            end.
            run mc_prodbcat in this-procedure (
                              buffer buf_prod-bc
                            ,input  'pgweight=request':u
                            ,output l-prod-bc-pgweight
                          ) no-error .
            if error-status :error then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при определении типа дополнительного бар-кода prodbcat" skip
                "Основной бар-код" buf_prod-bc.b-code skip
                "Дополнительный бар-код" buf_prod-bc.b-str skip
                "Действие weight=request" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            if l-prod-bc-pgweight
            and p-curr-type-cdrg = 'pglc':U
            then do:
              case p-action :
                when "get-m-code":U then do:
                  if integer( buf_prod-bc.b-str ) >= p-first-code
                    and integer( buf_prod-bc.b-str ) <= p-last-code
                    and integer( buf_prod-bc.b-str ) > v-b-code
                  then do:
                    assign
                      v-b-code = integer( buf_prod-bc.b-str )
                    .
                  end.
                end.
                when "f-u":U then do:
                  for each buf_code-range
                    where buf_code-range.db-num     = p-db-num
                      and buf_code-range.range-type = p-curr-type-cdrg
                      and buf_code-range.stts       = "f":U
                      and buf_code-range.first-code <= integer( buf_prod-bc.b-str )
                      and buf_code-range.last-code  >= integer( buf_prod-bc.b-str )
                  on error undo, return error
                  :
                  assign
                  buf_code-range.stts = "u":U
                    .
                  if lookup( string( buf_code-range.first-code ) + "-":U + string( buf_code-range.last-code ), str-u-f-rng ) <> 0 then do:
                      assign
                        str-u-f-rng = diff-list( str-u-f-rng
                                                ,string( buf_code-range.first-code ) + "-":U + string( buf_code-range.last-code )
                                                ,",":U
                                                )
                      .
                  end.
                  if lookup( buf_code-range.range-type + chr(3) + string( buf_code-range.first-code ), str-u-f ) = 0 then do:
                      assign
                        v-b-code = v-b-code + 1
                        v-msg     = substitute( "Диапазон кодов с &2 по &3&1"
                                                + "Помечен как 'u' т.к. существующий код &4 попадает в данный диапазон.&1"
                                                , chr(10)
                                                , buf_code-range.first-code
                                                , buf_code-range.last-code
                                                , buf_prod-bc.b-str
                                              )
                        v-ret-msg = v-ret-msg + v-msg
                      .
                    if p-view-mess = true then do:
                      message
                        v-msg
                        view-as alert-box information.
                    end.
                  end.
                end.
              end.
            end case.
          end.
        end.
        if p-action = "f-u":U then do:
          do ind = 1 to num-entries( str-u-f-rng ):
            assign
              v-b-code = v-b-code + 1
              v-msg     = substitute( "Диапазон кодов &2&1"
                                      + "Помечен как 'f' т.к. нет ни одного кода который попадает в данный диапазон.&1"
                                      , chr(10)
                                      , entry( ind, str-u-f-rng )
                                    )
              v-ret-msg = v-ret-msg + chr(10) + v-msg
            .
            if p-view-mess = true then do:
              message
                v-msg
                view-as alert-box information.
            end.
          end.
        end.
        hide frame get-max-code-inf no-pause .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "get-max-code" skip
          "Непредусмотрена обработка диапазона кодов " p-curr-type-cdrg
          view-as alert-box error.
        return error.
      end.
    end case.
  end.
  return v-ret-msg.
end procedure.
procedure mark-all-used-as-free :
  define input  parameter p-db-num         like ub.db.db-num             no-undo .
  define input  parameter p-curr-type-cdrg like ub.code-range.range-type no-undo .
  define output parameter p-str-u-f        as   character                 no-undo .
  define output parameter p-str-u-f-rng    as   character                 no-undo .
  do
  on error undo, return error
  :
    define buffer buf_code-range   for ub.code-range.
    define buffer buf-c_code-range for ub.code-range .
    assign
      p-str-u-f     = "":U
      p-str-u-f-rng = "":U
    .
    for each buf_code-range share-lock
        where buf_code-range.db-num     = p-db-num
          and buf_code-range.range-type = p-curr-type-cdrg
          and buf_code-range.stts       = "u":U
    on error undo, return error
    :
      find first buf-c_code-range exclusive-lock
        where rowid( buf-c_code-range ) = rowid( buf_code-range )
      .
      assign
        buf-c_code-range.stts = "c":U
      .
      release buf-c_code-range .
      assign
        buf_code-range.stts = "f":U
        p-str-u-f     = p-str-u-f + ",":U + buf_code-range.range-type + chr(3) + string( buf_code-range.first-code )
        p-str-u-f-rng = p-str-u-f-rng + ",":U + string( buf_code-range.first-code ) + "-":U + string( buf_code-range.last-code )
      .
    end.
    assign
      p-str-u-f     = substring( p-str-u-f, 2, length( p-str-u-f ) - 1 )
      p-str-u-f-rng = substring( p-str-u-f-rng, 2, length( p-str-u-f-rng ) - 1 )
    .
  end.
end procedure.
procedure mc_prodbcat :
  do
  on error undo, return error
  :
    define parameter buffer buf_prod-bc  for ub.prod-bc .
    define input  parameter p-action           as character no-undo .
    define output parameter p-return-attribute as logical no-undo .
    def var vss-description as character no-undo init "prodbcat-01: определение параметров дополнительного бар-кода".
    define buffer buf_bar-code   for ub.bar-code   .
    define buffer buf_units      for ub.units      .
    define buffer buf_code-range for ub.code-range .
    define variable p-code-int as integer no-undo .
    define variable v-cdrg-type as character no-undo .
    if not available buf_prod-bc then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не задан дополнительный бар-код" skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_bar-code no-lock
      where buf_bar-code.b-code = buf_prod-bc.b-code
      no-error .
    if not available buf_bar-code then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильная ссылка на основной бар-код" skip
        "Основной бар-код" buf_prod-bc.b-code skip
        "Дополнительный бар-код" buf_prod-bc.b-str skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_units no-lock
      where buf_units.unit-name = buf_bar-code.unit-cli
      no-error .
    if not available buf_units then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена единица измерения основного бар-кода" skip
        "Основной бар-код" buf_bar-code.b-code skip
        "Единица измерения" buf_bar-code.unit-cli skip
        view-as alert-box error .
      undo, return error .
    end.
    def var ind                    as integer   no-undo .
    def var v-num-entries-p-action as integer   no-undo .
    def var v-action               as character no-undo .
    assign
      v-num-entries-p-action = num-entries(p-action)
    .
    assign
      p-return-attribute = true
    .
    _ind:
    do ind = 1 to v-num-entries-p-action
    :
     if ind > 1 and p-return-attribute = false then return.
      assign
        v-action = entry(ind, p-action)
      .
      case v-action :
        when "global=request":u
        then do:
          if not (buf_prod-bc.bc-on-type = ''
          or buf_prod-bc.bc-on-type = 'scgb':U
          or buf_prod-bc.bc-on-type = 'ssgb':U) then do:
            assign
              p-return-attribute = false
            .
          end.
        end.
        when "weight=request":u
        then do:
          if not (buf_prod-bc.bc-on-type = 'sclc':U
          or buf_prod-bc.bc-on-type = 'scgb':U) then do:
            assign
              p-return-attribute = false.
          end.
        end.
        when "pgweight=request":u
        then do:
          if not (buf_prod-bc.bc-on-type = 'pglc':U) then do:
            assign
              p-return-attribute = false.
          end.
        end.
        when "petrolium=request":u
        then do:
          if not (buf_prod-bc.bc-on-type = 'ptlc':U) then do:
            assign
              p-return-attribute = false.
          end.
        end.
        when "scaleable=request":u
        then do:
          if not (buf_prod-bc.bc-on-type = 'sslc':U
          or buf_prod-bc.bc-on-type = 'ssgb':U) then do:
            assign
              p-return-attribute = false.
          end.
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестное значение параметра v-action " skip
            "v-action" v-action skip
            "p-action" p-action skip
            view-as alert-box error .
          undo, return error .
        end.
      end case.
    end.
  end.
end procedure.
procedure mc_gdsbcode :
  define input  parameter p-gds-code  like ub.bar-code.gds-code  no-undo .
  define input  parameter p-node-code like ub.bar-code.node-code no-undo .
  define output parameter p-b-code    like ub.bar-code.b-code    no-undo .
  def var vss-description as character no-undo init "gdsbcode-01: определение первичного бар-кода признака".
  def var vss-proc-revision as character no-undo init "library.p gdsbcode-01" .
  define buffer buf_bar-code for ub.bar-code .
  def var v-unit-base like ub.goods.unit-base no-undo .
  do
  on error undo, return error
  :
    if p-node-code = ? then do:
      run mc_gdsrootnode in this-procedure (
         input  p-gds-code
        ,output p-node-code
        ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении корневого признака товара" skip
          "Код товара" p-gds-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
    run mc_unitbase in this-procedure (
       input  p-gds-code
      ,output v-unit-base
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка определения базовой единицы измерения товара" skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_bar-code no-lock
      where buf_bar-code.gds-code  = p-gds-code
        and buf_bar-code.node-code = p-node-code
        and buf_bar-code.part-code = ""
        and buf_bar-code.in-code   = ""
        and buf_bar-code.unit-cli  = v-unit-base
      no-error .
    if not available buf_bar-code then do:
      undo, return error vss-proc-revision + ":" + chr(10)
        + "Не найден первичный бар-кода признака " + chr(10)
        + "Код товара " + string(p-gds-code) + chr(10)
        + "Код признака " + string(p-node-code) + chr(10)
        + "Базовая единица измерения " + string(v-unit-base) + chr(10)
        .
    end.
    assign
      p-b-code = buf_bar-code.b-code
    .
  end.
end procedure.
procedure mc_gdsrootnode :
  define input  parameter p-gds-code  like ub.goods.gds-code no-undo .
  define output parameter p-root-node like ub.goods.prt-root no-undo .
  def var vss-description as character no-undo init "gdsrootnode-01: определение корневого признака товара по коду товара".
  define buffer buf_goods   for ub.goods .
  do
  on error undo, return error
  :
    find first buf_goods no-lock
      where buf_goods.gds-code  = p-gds-code
      no-error .
    if not available buf_goods then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error .
    end.
    run mc_prt-root-to-node-code in this-procedure (
       input  buf_goods.prt-root
      ,output p-root-node
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры prt-root-to-node-code" skip
        "Товар" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
        "Указатель на корень шкалы" buf_goods.prt-root skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure mc_prt-root-to-node-code :
  define input  parameter p-prt-root  like ub.goods.prt-root no-undo .
  define output parameter p-root-node like ub.goods.prt-root no-undo .
  def var vss-description as character no-undo init "prt-root-to-node-code-01: определение корневого признака шкалы по коду шкалы".
  define buffer buf_gds-prt for ub.gds-prt .
  do
  on error undo, return error
  :
    find buf_gds-prt no-lock
      where buf_gds-prt.upper-code = p-prt-root
      no-error .
    if not available buf_gds-prt then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден корень шкалы" skip
        "Указатель на корень шкалы" p-prt-root skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      p-root-node = buf_gds-prt.node-code
    .
  end.
end procedure.
procedure mc_unitbase :
  define input  parameter p-gds-code  like ub.goods.gds-code  no-undo .
  define output parameter p-unit-base like ub.goods.unit-base no-undo .
  def var vss-description as character no-undo init "unitbase-01: определение базовой единицы измерения товара".
  define buffer buf_goods for ub.goods .
  do
  on error undo, return error
  :
    find first buf_goods no-lock
      where buf_goods.gds-code = p-gds-code
      no-error .
    if not available buf_goods then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      p-unit-base = buf_goods.unit-base
    .
  end.
end procedure.
define variable v-curr-db-num    like ub.db.db-num             no-undo .
define variable v-curr-type-cdrg like ub.code-range.range-type no-undo .
define temp-table temp-b-code-info no-undo
  field db-num            like ub.db.db-num
  field curr-value-seq    as integer format ">>>>>>>>>>>>9" column-label "Текущее значение кода"
  field active-exist      as logical format "yes/no"    column-label "Активный"
  field active-first-code like ub.code-range.first-code column-label "Активный c"
  field active-last-code  like ub.code-range.last-code  column-label "Активный по"
  field active-b-code     like ub.bar-code.b-code format ">>>>>>>>>>>>9"
  field free-exist        as logical format "yes/no"    column-label "Свободный"
  field free-first-code   like ub.code-range.first-code column-label "Свободный c"
  field free-last-code    like ub.code-range.last-code  column-label "Свободный по"
  field free-b-code       like ub.bar-code.b-code
  field error-message     as character
  index xpk is primary unique db-num
.
DEFINE BUTTON b-active DEFAULT
     LABEL "Активн."
     SIZE 10 BY 1.
DEFINE BUTTON b-coderg DEFAULT
     LABEL "Детально"
     SIZE 10 BY 1.
DEFINE BUTTON b-exit AUTO-END-KEY DEFAULT
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-f-u DEFAULT
     LABEL "Использ."
     SIZE 10 BY 1.
DEFINE BUTTON b-gen-free DEFAULT
     LABEL "Свободн."
     SIZE 10 BY 1.
DEFINE BUTTON b-help DEFAULT
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE sel-type-code-range AS CHARACTER FORMAT "X(45)":U INITIAL "глобальных собственных кодов"
     LABEL "Диапазоны"
     VIEW-AS COMBO-BOX INNER-LINES 11
     LIST-ITEM-PAIRS "1","1",
                     "2","2",
                     "3","3",
                     "4","4",
                     "5","5",
                     "6","6",
                     "7","7",
                     "8","8",
                     "9","9",
                     "10","10",
                     "11","11"
     DROP-DOWN-LIST
     SIZE 52.5 BY 1 NO-UNDO.
DEFINE VARIABLE EDITOR-error-message AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 84.5 BY 2.83
     BGCOLOR 15  NO-UNDO.
DEFINE QUERY BROWSE-1 FOR
      temp-b-code-info SCROLLING.
DEFINE BROWSE BROWSE-1
  QUERY BROWSE-1 DISPLAY
      db-num
        curr-value-seq
        active-exist
        active-first-code
        active-last-code
        active-b-code
        free-exist
        free-first-code
        free-last-code
        free-b-code
        error-message
    WITH NO-ROW-MARKERS SEPARATORS SIZE 84.5 BY 11.58
         BGCOLOR 15 .
DEFINE FRAME D-Dialog
     b-exit AT ROW 1.17 COL 2
     b-gen-free AT ROW 1.17 COL 12
     b-active AT ROW 1.17 COL 22
     b-f-u AT ROW 1.17 COL 32
     b-coderg AT ROW 1.17 COL 42
     b-help AT ROW 1.17 COL 76.5
     sel-type-code-range AT ROW 2.5 COL 1.13
     BROWSE-1 AT ROW 4 COL 2
     EDITOR-error-message AT ROW 15.75 COL 2 NO-LABEL
     SPACE(0.99) SKIP(0.29)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Диапазоны кодов"
         CANCEL-BUTTON b-exit.
DEFINE VAR adm-object-hdl       AS HANDLE NO-UNDO.
DEFINE VAR adm-query-opened        AS LOGICAL NO-UNDO INIT NO.
DEFINE VAR adm-row-avail-state     AS LOGICAL NO-UNDO INIT ?.
DEFINE VAR adm-initial-lock        AS CHARACTER NO-UNDO INIT "NO-LOCK":U.
DEFINE VAR adm-new-record          AS LOGICAL NO-UNDO INIT no.
DEFINE VAR adm-updating-record     AS LOGICAL NO-UNDO INIT no.
DEFINE VAR adm-check-modified-all  AS LOGICAL NO-UNDO INIT no.
DEFINE NEW GLOBAL SHARED VAR adm-broker-hdl    AS HANDLE  NO-UNDO.
    ASSIGN adm-object-hdl = FRAME D-Dialog:HANDLE.
RUN ensure-broker.
THIS-PROCEDURE:ADM-DATA =
     'ADM1.1~`':U +
     'SmartDialog~`':U +
     'DIALOG-BOX~`':U +
     'NO ~`':U +
     '~`':U +
     'temp-b-code-info~`':U +
     '~`':U +
     (IF adm-object-hdl = ? THEN "":U ELSE STRING(adm-object-hdl))
        + "~`":U +
     'Layout,Hide-on-Init~`':U +
     '~`':U +
     '~`':U +
     '~`~`~`~`~`~`~`~`~`~`~`':U +
     IF THIS-PROCEDURE:ADM-DATA = "":U OR THIS-PROCEDURE:ADM-DATA = ?
         THEN "^^":U
     ELSE "^":U + ENTRY(2, THIS-PROCEDURE:ADM-DATA, "^":U) +
          "^":U + ENTRY(3, THIS-PROCEDURE:ADM-DATA, "^":U).
PROCEDURE adm-apply-entry :
  RUN broker-apply-entry IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-destroy :
 RUN broker-destroy IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-disable :
    DISABLE b-exit b-gen-free b-active b-f-u b-coderg b-help sel-type-code-range BROWSE-1 EDITOR-error-message WITH FRAME D-Dialog.
    RUN dispatch ('disable-fields':U).
    RUN set-attribute-list ('ENABLED=no':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-edit-attribute-list :
      RUN adm/support/contnrd.w (INPUT THIS-PROCEDURE).
      RETURN.
END PROCEDURE.
PROCEDURE adm-enable :
    ENABLE UNLESS-HIDDEN b-exit b-gen-free b-active b-f-u b-coderg b-help sel-type-code-range BROWSE-1 EDITOR-error-message WITH FRAME D-Dialog.
    RUN enable_UI IN THIS-PROCEDURE NO-ERROR.
    RUN set-attribute-list ('ENABLED=yes':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-exit :
     RUN notify ('exit':U).
  RETURN.
END PROCEDURE.
PROCEDURE adm-hide :
  RUN broker-hide IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-initialize :
  RUN broker-initialize IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-show-errors :
    DEFINE VARIABLE        cntr                  AS INTEGER   NO-UNDO.
    DO cntr = 1 TO ERROR-STATUS:NUM-MESSAGES:
        MESSAGE ERROR-STATUS:GET-MESSAGE(cntr).
    END.
    RETURN.
END PROCEDURE.
PROCEDURE adm-UIB-mode :
  RUN broker-UIB-mode IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-view :
  RUN broker-view IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE dispatch :
    DEFINE INPUT PARAMETER p-method-name    AS CHARACTER NO-UNDO.
    RUN broker-dispatch IN adm-broker-hdl
        (THIS-PROCEDURE, p-method-name) NO-ERROR.
    IF RETURN-VALUE = "ADM-ERROR":U THEN RETURN "ADM-ERROR":U.
END PROCEDURE.
PROCEDURE ensure-broker :
RUN get-attribute IN adm-broker-hdl ('TYPE':U) NO-ERROR.
IF RETURN-VALUE NE "ADM-Broker":U THEN
DO:
    RUN adm/objects/broker.p PERSISTENT set adm-broker-hdl.
    RUN set-broker-owner IN adm-broker-hdl (THIS-PROCEDURE).
END.
END PROCEDURE.
PROCEDURE get-attribute :
  DEFINE INPUT PARAMETER p-attr-name    AS CHARACTER NO-UNDO.
  RUN broker-get-attribute IN adm-broker-hdl
      (INPUT THIS-PROCEDURE, INPUT p-attr-name) NO-ERROR.
  RETURN RETURN-VALUE.
END PROCEDURE.
PROCEDURE get-attribute-list :
  DEFINE OUTPUT PARAMETER p-attr-list AS CHARACTER NO-UNDO.
  RUN broker-get-attribute-list IN adm-broker-hdl
      (INPUT THIS-PROCEDURE,
       INPUT ?,
       OUTPUT p-attr-list) NO-ERROR.
  RETURN.
END PROCEDURE.
PROCEDURE new-state :
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
  RUN broker-new-state IN adm-broker-hdl (THIS-PROCEDURE, p-state) NO-ERROR.
  RETURN.
END PROCEDURE.
PROCEDURE notify :
  DEFINE INPUT PARAMETER p-method AS CHARACTER NO-UNDO.
  RUN broker-notify IN adm-broker-hdl (THIS-PROCEDURE, p-method) NO-ERROR.
  IF RETURN-VALUE = "ADM-ERROR":U THEN
      RETURN "ADM-ERROR":U.
  RETURN.
END PROCEDURE.
PROCEDURE set-attribute-list :
  DEFINE INPUT PARAMETER p-attr-list    AS CHARACTER NO-UNDO.
  RUN ensure-broker.
  RUN broker-set-attribute-list IN adm-broker-hdl
      (INPUT THIS-PROCEDURE, INPUT p-attr-list) NO-ERROR.
  RETURN.
END PROCEDURE.
PROCEDURE set-position :
    DEFINE INPUT PARAMETER p-row    AS DECIMAL NO-UNDO.
    DEFINE INPUT PARAMETER p-col    AS DECIMAL NO-UNDO.
    IF VALID-HANDLE(adm-object-hdl) THEN
    DO:
        DEFINE VARIABLE parent-hdl AS HANDLE NO-UNDO.
        IF adm-object-hdl:TYPE = "WINDOW":U THEN
        DO:
          IF p-row = 0 THEN p-row =
            (SESSION:HEIGHT-CHARS - adm-object-hdl:HEIGHT-CHARS) / 2.
          IF p-col = 0 THEN p-col =
            (SESSION:WIDTH-CHARS - adm-object-hdl:WIDTH-CHARS) / 2.
        END.
        ELSE IF adm-object-hdl:TYPE = "DIALOG-BOX":U THEN
        DO:
          parent-hdl = adm-object-hdl:PARENT.
          IF p-row = 0 THEN p-row =
            ((SESSION:HEIGHT-CHARS - adm-object-hdl:HEIGHT-CHARS) / 2) -
              parent-hdl:ROW.
          IF p-col = 0 THEN p-col =
            ((SESSION:WIDTH-CHARS - adm-object-hdl:WIDTH-CHARS) / 2) -
              parent-hdl:COL.
        END.
        IF p-row GE 0 AND p-row < 1 THEN p-row = 1.
        IF p-col GE 0 AND p-col < 1 THEN p-col = 1.
      ASSIGN adm-object-hdl:ROW    =   p-row
             adm-object-hdl:COLUMN =   p-col.
    END.
    RETURN.
END PROCEDURE.
RUN set-attribute-list ("CURRENT-PAGE=0,ADM-OBJECT-HANDLE=":U +
    STRING(adm-object-hdl)).
PAUSE 0 BEFORE-HIDE.
PROCEDURE adm-change-page :
  RUN broker-change-page IN adm-broker-hdl (INPUT THIS-PROCEDURE) NO-ERROR.
  END PROCEDURE.
PROCEDURE delete-page :
  DEFINE INPUT PARAMETER p-page# AS INTEGER NO-UNDO.
  RUN broker-delete-page IN adm-broker-hdl
      (INPUT THIS-PROCEDURE, INPUT p-page#).
  END PROCEDURE.
PROCEDURE init-object :
  DEFINE INPUT PARAMETER  p-proc-name   AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER  p-parent-hdl  AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER  p-attr-list   AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-proc-hdl    AS HANDLE    NO-UNDO.
  RUN broker-init-object IN adm-broker-hdl
      (INPUT THIS-PROCEDURE, INPUT p-proc-name, INPUT p-parent-hdl,
       INPUT p-attr-list, OUTPUT p-proc-hdl) NO-ERROR.
  RETURN.
END PROCEDURE.
PROCEDURE init-pages :
  DEFINE INPUT PARAMETER p-page-list      AS CHARACTER NO-UNDO.
  RUN broker-init-pages IN adm-broker-hdl (INPUT THIS-PROCEDURE,
      INPUT p-page-list) NO-ERROR.
  END PROCEDURE.
PROCEDURE select-page :
  DEFINE INPUT PARAMETER p-page#     AS INTEGER   NO-UNDO.
  RUN broker-select-page IN adm-broker-hdl (INPUT THIS-PROCEDURE,
      INPUT p-page#) NO-ERROR.
  END PROCEDURE.
PROCEDURE view-page :
  DEFINE INPUT PARAMETER p-page#      AS INTEGER   NO-UNDO.
  RUN broker-view-page IN adm-broker-hdl (INPUT THIS-PROCEDURE,
      INPUT p-page#).
  END PROCEDURE.
ASSIGN
       FRAME D-Dialog:SCROLLABLE       = FALSE
       FRAME D-Dialog:HIDDEN           = TRUE.
ASSIGN
       BROWSE-1:NUM-LOCKED-COLUMNS IN FRAME D-Dialog     = 1.
ASSIGN
       EDITOR-error-message:READ-ONLY IN FRAME D-Dialog        = TRUE.
ON WINDOW-CLOSE OF FRAME D-Dialog
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-active IN FRAME D-Dialog
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
  if available temp-b-code-info then do:
    if v-curr-type-cdrg = 'sslc':U
    or v-curr-type-cdrg = 'ssgb':U
    then do:
      message
        "Текущее значение sequence" skip
        "для диапазона взвешиваемых кодов задавать нельзя." skip
        view-as alert-box information .
      return no-apply.
    end.
    if temp-b-code-info.db-num <> v-curr-db-num
      and v-curr-type-cdrg <> 'sclc':U
      and v-curr-type-cdrg <> 'sslc':U
      and v-curr-type-cdrg <> 'ssgb':U
      and v-curr-type-cdrg <> 'pglc':U
    then do:
      message
        "Текущее значение sequence можно задавать только для текущей базы данных" skip
        "Текущая база данных" v-curr-db-num skip
        "Выбрана база данных" temp-b-code-info.db-num skip
        view-as alert-box information .
      return no-apply.
    end.
    run put-into-active in this-procedure
      (input temp-b-code-info.db-num
      ) .
    run reopen-query in this-procedure .
  end.
END.
ON CHOOSE OF b-coderg IN FRAME D-Dialog
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
  define variable v-db-num as integer no-undo.
  if available temp-b-code-info then do:
    if v-curr-type-cdrg = 'sslc':U
      or v-curr-type-cdrg = 'sclc':U
    or v-curr-type-cdrg = 'pglc':U
    then do:
      assign
        v-db-num = ?
      .
    end.
    else do:
      assign
        v-db-num = temp-b-code-info.db-num
      .
    end.
    run utl/v-coderg.w ( input v-db-num
                   ,input v-curr-type-cdrg
                   ,input sel-type-code-range
                  ).
    run reopen-query in this-procedure .
  end.
END.
ON CHOOSE OF b-f-u IN FRAME D-Dialog
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
  define variable v-b-code         like ub.bar-code.b-code no-undo .
  if available temp-b-code-info then do:
    if v-curr-type-cdrg = 'sslc':U
    or v-curr-type-cdrg = 'ssgb':U
    then do:
      message
        "Помечать свободный диапазон как использованный" skip
        "для диапазона взвешиваемых кодов нельзя." skip
        view-as alert-box information .
      return no-apply.
    end.
    if temp-b-code-info.db-num <> v-curr-db-num
      and v-curr-type-cdrg <> 'sclc':U
      and v-curr-type-cdrg <> 'pglc':U
    then do:
      message
        "Помечать свободный диапазон как использованный," skip
        "если есть хоть один код внутри этого диапазона," skip
        "можно только для текущей базы данных" skip
        "Текущая база данных" v-curr-db-num skip
        "Выбрана база данных" temp-b-code-info.db-num skip
        view-as alert-box information .
      return no-apply.
    end.
    run get-max-code in this-procedure
      ( input "f-u":U
       ,input v-curr-db-num
       ,input v-curr-type-cdrg
       ,input ?
       ,input ?
       ,input TRUE
       ,output v-b-code
      ).
    message
      "Просмотр окончен." skip
      "Исправлено статусов диапазонов" v-b-code
      view-as alert-box information
    .
    run reopen-query in this-procedure .
  end.
END.
ON CHOOSE OF b-gen-free IN FRAME D-Dialog
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
  if available temp-b-code-info then do:
    run gen-free-code-range in this-procedure
      (input temp-b-code-info.db-num
      ) .
    run reopen-query in this-procedure .
  end.
END.
ON VALUE-CHANGED OF BROWSE-1 IN FRAME D-Dialog
DO:
  run display-dependent-info in this-procedure .
END.
ON VALUE-CHANGED OF sel-type-code-range IN FRAME D-Dialog
DO:
  assign sel-type-code-range .
  if mode-erprn
     and can-do("bcgb,fmgb,pngb,fdgb,ctgb,drgb,sclc,sslc,pglc,cagb",sel-type-code-range)
  then do:
     if sel-type-code-range = 'cagb':U then
     enable
     b-active
     b-gen-free
     b-f-u
     b-coderg
     with frame D-Dialog .
     else
     disable
     b-active
     b-gen-free
     b-f-u
     b-coderg
     with frame D-Dialog .
  end.
  else
     assign
        b-active:SENSITIVE = yes
        b-gen-free:SENSITIVE = yes
        b-f-u:SENSITIVE = yes
        b-coderg:SENSITIVE = yes
     .
  assign
  v-curr-type-cdrg = sel-type-code-range .
  run fill-temp-b-code-info .
  run reopen-query in this-procedure .
END.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame D-Dialog
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
on choose of b-help in frame D-Dialog
do:
  apply "help":u to frame D-Dialog .
end.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame D-Dialog:width - 0.3
                fh            = frame D-Dialog:first-child
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame D-Dialog :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame D-Dialog :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame D-Dialog :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame D-Dialog :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame D-Dialog :height = v-frame-height
          .
          if frame D-Dialog :scrollable = true
          then do:
            assign
              frame D-Dialog :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame D-Dialog :scrollable = true
          then do:
            assign
              frame D-Dialog :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame D-Dialog :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame D-Dialog :height
      v-frame-virtual-height = frame D-Dialog :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame D-Dialog :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame D-Dialog
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame D-Dialog :scrollable = true
      then do:
        assign
          frame D-Dialog :virtual-height = frame D-Dialog :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame D-Dialog :height = frame D-Dialog :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame D-Dialog :height = frame D-Dialog :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame D-Dialog :scrollable = true
      then do:
        assign
          frame D-Dialog :virtual-height = frame D-Dialog :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame D-Dialog :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame D-Dialog :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame D-Dialog :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame D-Dialog :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame D-Dialog :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame D-Dialog :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame D-Dialog :width = v-frame-width
          .
          if frame D-Dialog :scrollable = true
          then do:
            assign
              frame D-Dialog :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame D-Dialog :scrollable = true
          then do:
            assign
              frame D-Dialog :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame D-Dialog :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame D-Dialog :width
      v-frame-virtual-width = frame D-Dialog :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame D-Dialog :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame D-Dialog
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame D-Dialog :scrollable = true
      then do:
        assign
          frame D-Dialog :virtual-width = frame D-Dialog :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame D-Dialog :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame D-Dialog :width = frame D-Dialog :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame D-Dialog :scrollable = true
      then do:
        assign
          frame D-Dialog :virtual-width = frame D-Dialog :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame D-Dialog :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame D-Dialog :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame D-Dialog
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame D-Dialog :height - v-diasize-resize-button :height
                  - 1
                  - (frame D-Dialog :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame D-Dialog :width - v-diasize-resize-button :width
                  - 1
                  - (frame D-Dialog :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame D-Dialog
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame D-Dialog :height
      v-col-delta = v-new-col - frame D-Dialog :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame D-Dialog :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame D-Dialog :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame D-Dialog :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame D-Dialog :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame D-Dialog :width
      v-diasize-current-frame-height = frame D-Dialog :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame D-Dialog
    :
      assign
        v-diasize-orig-frame-height = frame D-Dialog :height
        v-diasize-orig-frame-width  = frame D-Dialog :width
        v-diasize-browse-handle     = browse BROWSE-1 :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame D-Dialog :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-erpRN'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  NO
  ,output conf-par
  ,output par-type
  ) no-error .
          if not error-status:error and conf-par = "yes":U then mode-erprn = yes.
          else mode-erprn = no.
define buffer buf_sys-ctrl for ub.sys-ctrl .
assign
  sel-type-code-range:list-item-pairs  in frame D-Dialog =
  "глобальных собственных кодов" + chr(44) + 'bcgb':U + chr(44) +
  "глобальных весовых кодов" + chr(44) + 'scgb':U  + chr(44) +
  "локальных весовых кодов" + chr(44) + 'sclc':U + chr(44) +
  "локальных штучных кодов для весов" + chr(44) + 'pglc':U + chr(44) +
  "глобальных взвешиваемых кодов" + chr(44) + 'ssgb':U + chr(44) +
  "локальных взвешиваемых кодов" + chr(44) + 'sslc':U + chr(44) +
  "глобальных кодов правил скидок и расписаний" + chr(44) + 'drgb':U + chr(44) +
  "внутренних кодов дисконтных карт" + chr(44) +  'dcgb':U + chr(44) +
  "глобальных кодов организаций" + chr(44) +  'fmgb':U + chr(44) +
  "глобальных кодов физ.лиц" + chr(44) + 'pngb':U + chr(44) +
  "глобальных кодов договоров" + chr(44) + 'ctgb':U + chr(44) +
  "глобальных кодов точек привязки" + chr(44) + 'cagb':U + chr(44) +
  "глобальных кодов фин.документов" + chr(44) + 'fdgb':U
.
assign
  sel-type-code-range = 'bcgb':U
  sel-type-code-range:screen-value = 'bcgb':U
.
do:
  browse BROWSE-1 :set-repositioned-row( 5, "conditional" ) .
end.
apply "value-changed" to sel-type-code-range in frame D-Dialog .
find first buf_sys-ctrl no-lock .
assign
  frame D-Dialog:title = frame D-Dialog:title + chr(32) + substitute( "(БД &1)", buf_sys-ctrl.db-num )
.
IF THIS-PROCEDURE:PERSISTENT THEN DO:
    MESSAGE "A SmartDialog is not intended ":U SKIP
            "to be run Persistent or to be placed ":U SKIP
            "in another SmartObject at UIB design time.":U
            VIEW-AS ALERT-BOX ERROR.
    RUN disable_UI.
    DELETE PROCEDURE THIS-PROCEDURE.
    RETURN.
END.
RUN dispatch ('create-objects':U).
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME D-Dialog:PARENT eq ?
THEN FRAME D-Dialog:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN dispatch IN THIS-PROCEDURE ('initialize':U).
  WAIT-FOR GO OF FRAME D-Dialog.
END.
RUN dispatch IN THIS-PROCEDURE ('destroy':U).
PROCEDURE adm-create-objects :
END PROCEDURE.
PROCEDURE adm-row-available :
  DEFINE VARIABLE tbl-list           AS CHARACTER INIT "":U NO-UNDO.
  DEFINE VARIABLE rowid-list         AS CHARACTER NO-UNDO.
  DEFINE VARIABLE row-avail-cntr     AS INTEGER INIT 0 NO-UNDO.
  DEFINE VARIABLE row-avail-rowid    AS ROWID NO-UNDO.
  DEFINE VARIABLE row-avail-enabled  AS LOGICAL NO-UNDO.
  DEFINE VARIABLE link-handle        AS CHARACTER NO-UNDO.
  DEFINE VARIABLE record-source-hdl  AS HANDLE NO-UNDO.
  DEFINE VARIABLE different-row      AS LOGICAL NO-UNDO INIT no.
  DEFINE VARIABLE key-name           AS CHARACTER INIT ? NO-UNDO.
  DEFINE VARIABLE key-value          AS CHARACTER INIT ? NO-UNDO.
  RUN check-modified IN THIS-PROCEDURE ('check':U) NO-ERROR.
  IF adm-updating-record THEN RETURN.
  RUN get-attribute ('FIELDS-ENABLED':U).
  row-avail-enabled = IF RETURN-VALUE = "YES":U THEN yes ELSE no.
  RUN get-link-handle IN adm-broker-hdl (THIS-PROCEDURE, 'RECORD-SOURCE':U,
      OUTPUT link-handle) NO-ERROR.
  IF link-handle = "":U THEN
      RETURN.
  ASSIGN record-source-hdl = WIDGET-HANDLE(ENTRY(1,link-handle)).
  IF NUM-ENTRIES(link-handle) > 1 THEN
      MESSAGE "row-available in ":U THIS-PROCEDURE:FILE-NAME
          "encountered more than one RECORD-SOURCE.":U SKIP
          "The first - ":U record-source-hdl:file-name " - will be used.":U
             VIEW-AS ALERT-BOX ERROR.
  RUN get-attribute ('Key-Name':U).
  key-name = RETURN-VALUE.
  IF key-name = "":U THEN key-name = ?.
  IF key-name NE ? THEN DO:
    RUN send-key IN record-source-hdl (INPUT key-name, OUTPUT key-value)
      NO-ERROR.
    IF key-value NE ? THEN
      RUN set-attribute-list (SUBSTITUTE ('Key-Value="&1"':U, key-value)).
  END.
IF VALID-HANDLE (adm-object-hdl) THEN
    RUN dispatch IN THIS-PROCEDURE ('display-fields':U).
RUN notify IN THIS-PROCEDURE ('row-available':U).
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME D-Dialog.
END PROCEDURE.
PROCEDURE display-dependent-info :
  do
  on error undo, return error
  :
    if available temp-b-code-info then do:
      do with frame D-Dialog
      :
        assign
          editor-error-message :screen-value = temp-b-code-info.error-message
        .
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY sel-type-code-range EDITOR-error-message
      WITH FRAME D-Dialog.
  ENABLE b-exit b-gen-free b-active b-f-u b-coderg b-help sel-type-code-range
         BROWSE-1 EDITOR-error-message
      WITH FRAME D-Dialog.
  VIEW FRAME D-Dialog.
  run reopen-query in this-procedure .
END PROCEDURE.
PROCEDURE fill-temp-b-code-info :
  do
  on error undo, return error
  :
    define buffer buf_temp-b-code-info for temp-b-code-info .
    define buffer buf_db               for ub.db .
    define buffer buf_code-range       for ub.code-range .
    define buffer buf_bar-code         for ub.bar-code .
    define buffer buf_dis-card         for ub.dis-card.
    define buffer buf_dis-rule         for ub.dis-rule.
    define buffer buf_dis-time-rule    for ub.dis-time-rule.
    define buffer buf_clients          for ub.clients.
    define buffer buf_contract         for ub.contract.
    define buffer buf_rule-by-call     for ub.rule-by-call.
    define buffer buf_sysconf          for ub.sysconf.
    define buffer buf_fin-doc          for ub.fin-doc.
    define variable v-code-1           as integer no-undo .
    define variable v-code-2           as integer no-undo .
    define buffer buf_sys-ctrl for ub.sys-ctrl .
    find first buf_sys-ctrl no-lock .
    assign
      v-curr-db-num = buf_sys-ctrl.db-num
    .
    for each buf_temp-b-code-info
    :
      delete buf_temp-b-code-info .
    end.
    for each buf_db
          by buf_db.db-num
    on error undo, return error
    :
      create buf_temp-b-code-info .
      assign
        buf_temp-b-code-info.db-num = buf_db.db-num
      .
      if buf_db.db-num = v-curr-db-num
         or v-curr-type-cdrg = 'sclc':U
         or v-curr-type-cdrg = 'pglc':U
         or v-curr-type-cdrg = 'sslc':U
      then do:
        case v-curr-type-cdrg:
          when 'bcgb':U then do:
            assign
              buf_temp-b-code-info.curr-value-seq = current-value(s-bcgb-code, ub)
            .
          end.
          when 'scgb':U then do:
            assign
              buf_temp-b-code-info.curr-value-seq = current-value(s-scgb-code, ub)
            .
          end.
          when 'sclc':U then do:
            assign
              buf_temp-b-code-info.curr-value-seq = current-value(s-sclc-code, ub)
            .
          end.
          when 'pglc':U then do:
            assign
              buf_temp-b-code-info.curr-value-seq = current-value(s-pglc-code, ub)
            .
          end.
          when 'ssgb':U then do:
            assign
              buf_temp-b-code-info.curr-value-seq = ?
            .
          end.
          when 'sslc':U then do:
            assign
              buf_temp-b-code-info.curr-value-seq = ?
            .
          end.
          when 'fmgb':U then do:
            assign
              buf_temp-b-code-info.curr-value-seq = current-value(s-fmgb-code, ub)
            .
          end.
          when 'pngb':U then do:
            assign
              buf_temp-b-code-info.curr-value-seq = current-value(s-pngb-code, ub)
            .
          end.
          when 'drgb':U then do:
            assign
              buf_temp-b-code-info.curr-value-seq = current-value(s-drgb-code, ub)
            .
          end.
          when 'dcgb':U then do:
            assign
              buf_temp-b-code-info.curr-value-seq = current-value(s-dcgb-code, ub)
            .
          end.
          when 'ctgb':U then do:
            assign
              buf_temp-b-code-info.curr-value-seq = current-value(s-ctgb-code, ub)
            .
          end.
          when 'cagb':U then do:
            assign
              buf_temp-b-code-info.curr-value-seq = current-value(s-cagb-code, ub)
            .
          end.
          when 'fdgb':U then do:
            assign
              buf_temp-b-code-info.curr-value-seq = current-value(s-fin-doc, ub)
            .
          end.
        end case.
      end.
      else do:
        assign
          buf_temp-b-code-info.curr-value-seq = ?
        .
      end.
      find first buf_code-range no-lock
        where buf_code-range.db-num     = buf_db.db-num
          and buf_code-range.range-type = v-curr-type-cdrg
          and buf_code-range.stts       = "a"
        no-error .
      if available buf_code-range then do:
        assign
          buf_temp-b-code-info.active-exist      = true
          buf_temp-b-code-info.active-first-code = buf_code-range.first-code
          buf_temp-b-code-info.active-last-code  = buf_code-range.last-code
          buf_temp-b-code-info.active-b-code = ?
          v-code-1 = 0
          v-code-2 = 0
        .
        case v-curr-type-cdrg:
          when 'bcgb':U then do:
            for each buf_bar-code no-lock
              where buf_bar-code.b-code >= buf_code-range.first-code
                and buf_bar-code.b-code <= buf_code-range.last-code
            by buf_bar-code.b-code descending
            :
              assign
                buf_temp-b-code-info.active-b-code = buf_bar-code.b-code
              .
              leave .
            end.
          end.
          when 'dcgb':U then do:
            for each buf_dis-card no-lock
              where buf_dis-card.card-num >= buf_code-range.first-code
                and buf_dis-card.card-num <= buf_code-range.last-code
            by buf_dis-card.card-num descending
            :
              assign
                buf_temp-b-code-info.active-b-code = buf_dis-card.card-num
              .
              leave .
            end.
          end.
          when 'fmgb':U
          or
          when 'pngb':U
          then do:
            for each buf_clients no-lock
              where buf_clients.obj-type = (if v-curr-type-cdrg = 'fmgb':U then 'орг':U else 'чел':U)
                and buf_clients.obj-code >= buf_code-range.first-code
                and buf_clients.obj-code <= buf_code-range.last-code
            by buf_clients.obj-code descending
            :
              assign
                buf_temp-b-code-info.active-b-code = buf_clients.obj-code
              .
              leave .
            end.
          end.
          when 'drgb':U then do:
            for each buf_dis-rule no-lock
              where buf_dis-rule.rule-num >= buf_code-range.first-code
                and buf_dis-rule.rule-num <= buf_code-range.last-code
            by buf_dis-rule.rule-num descending
            :
              assign
                v-code-1 = buf_dis-rule.rule-num
              .
              leave .
            end.
            for each buf_dis-time-rule no-lock
              where buf_dis-time-rule.time-rule-num >= buf_code-range.first-code
                and buf_dis-time-rule.time-rule-num <= buf_code-range.last-code
            by buf_dis-time-rule.time-rule-num descending
            :
              assign
              v-code-2 = buf_dis-time-rule.time-rule-num
              .
              leave .
            end.
            assign
              buf_temp-b-code-info.active-b-code = maximum (v-code-1, v-code-2)
            .
          end.
          when 'sclc':U then do:
          end.
          when 'pglc':U then do:
          end.
          when 'ctgb':U then do:
            for each buf_contract no-lock
              where buf_contract.contract-code >= buf_code-range.first-code
                and buf_contract.contract-code <= buf_code-range.last-code
            by buf_contract.contract-code descending
            :
              assign
                buf_temp-b-code-info.active-b-code = buf_contract.contract-code
              .
              leave .
            end.
          end.
          when 'cagb':U then do:
            for each buf_rule-by-call no-lock
              where buf_rule-by-call.call#_id >= buf_code-range.first-code
                and buf_rule-by-call.call#_id <= buf_code-range.last-code
            by buf_rule-by-call.call#_id descending
            :
              assign
                buf_temp-b-code-info.active-b-code = buf_rule-by-call.call#_id
              .
              leave .
            end.
          end.
          when 'fdgb':U then do:
            for each buf_sysconf no-lock:
              _fin-doc:
              for each buf_fin-doc no-lock
              where buf_fin-doc.host-code = buf_sysconf.host-code
                and buf_fin-doc.fin-doc-code >= buf_code-range.first-code
                and buf_fin-doc.fin-doc-code <= buf_code-range.last-code
              by buf_fin-doc.fin-doc-code descending
              :
                if buf_fin-doc.fin-doc-code > buf_temp-b-code-info.active-b-code then do:
                  assign
                    buf_temp-b-code-info.active-b-code = buf_fin-doc.fin-doc-code
                  .
                  leave _fin-doc.
                end.
                if buf_fin-doc.fin-doc-code <= buf_temp-b-code-info.active-b-code then do:
                  leave _fin-doc.
                end.
              end.
            end.
          end.
        END CASE.
      end.
      find first buf_code-range no-lock
        where buf_code-range.db-num     = buf_db.db-num
          and buf_code-range.range-type = v-curr-type-cdrg
          and buf_code-range.stts       = "f"
        no-error .
      if available buf_code-range then do:
        assign
          buf_temp-b-code-info.free-exist      = true
          buf_temp-b-code-info.free-first-code = buf_code-range.first-code
          buf_temp-b-code-info.free-last-code  = buf_code-range.last-code
        .
        for each buf_bar-code no-lock
          where buf_bar-code.b-code >= buf_code-range.first-code
            and buf_bar-code.b-code <= buf_code-range.last-code
        by buf_bar-code.b-code descending
        :
          assign
            buf_temp-b-code-info.free-b-code = buf_bar-code.b-code
          .
          leave .
        end.
      end.
      assign
        buf_temp-b-code-info.error-message
          = "База данных " + string(buf_temp-b-code-info.db-num)
      .
      if  buf_temp-b-code-info.active-exist = false
      and buf_temp-b-code-info.free-exist   = false then do:
        assign
          buf_temp-b-code-info.error-message
            = buf_temp-b-code-info.error-message
            + chr(10)
            + "У базы отсутствуют активный и свободные диапазоны"
        .
      end.
      if  buf_temp-b-code-info.active-exist = true
      and buf_temp-b-code-info.db-num = v-curr-db-num
      and buf_temp-b-code-info.curr-value-seq > ( buf_temp-b-code-info.active-first
                                            + buf_temp-b-code-info.active-last ) / 2
      and buf_temp-b-code-info.free-exist   = false
      then do:
        assign
          buf_temp-b-code-info.error-message
            = buf_temp-b-code-info.error-message
            + chr(10)
            + "Текущее значение sequence превышает середину активного диапазона "
            + "и не создан свободный диапазон"
            + (if   buf_temp-b-code-info.db-num <> 0
               then chr(10) + "Для удаленной базы данных это может быть вызвано "
                + "задержкой передачи информации по новостям"
               else ""
              )
        .
      end.
      if v-curr-type-cdrg = 'sclc':U
         or v-curr-type-cdrg = 'sslc':U
         or v-curr-type-cdrg = 'pglc':U
      then do:
        leave.
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE gen-free-code-range :
  do
  on error undo, return error
  :
    define input parameter p-db-num like ub.db.db-num no-undo .
    define buffer buf_temp-b-code-info for temp-b-code-info .
    define variable lok as logical   no-undo .
    find first buf_temp-b-code-info
      where buf_temp-b-code-info.db-num = p-db-num
      no-error .
    if buf_temp-b-code-info.free-exist then do:
      assign
        lok = false
      .
      message
        "Для базы данных уже существует свободный диапазон." skip
        "База данных" p-db-num skip
        "Вы уверены, что хотите сгенерировать ЕЩЕ ОДИН свободный диапазон?" skip
        view-as alert-box question buttons yes-no update lok .
      if lok <> true then do:
        return .
      end.
    end.
    else do:
      assign
        lok = false
      .
      message
        "База данных" p-db-num skip
        "Вы хотите сгенерировать свободный диапазон?" skip
        view-as alert-box question buttons yes-no update lok .
      if lok <> true then do:
        return .
      end.
    end.
    run new-bcod-gen-code-range in this-procedure
      (input p-db-num,
       input v-curr-type-cdrg
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при создании нового свободного диапазона" skip
        "База данных" p-db-num skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    else do:
      message
        return-value skip
        "База данных" p-db-num skip
        view-as alert-box information .
    end.
  end.
END PROCEDURE.
PROCEDURE put-into-active :
  do
  on error undo, return error
  :
    define input parameter p-db-num like ub.db.db-num no-undo .
    define variable v-b-code         like ub.bar-code.b-code no-undo .
    define variable v-old-value      as integer              no-undo .
    define variable v-new-value      as integer              no-undo .
    define variable lok              as logical              no-undo .
    define buffer buf_code-range for ub.code-range .
    define buffer buf_bar-code   for ub.bar-code .
    find first buf_code-range no-lock
      where buf_code-range.db-num     = p-db-num
        and buf_code-range.range-type = v-curr-type-cdrg
        and buf_code-range.stts       = "a":U
      no-error .
    if not available buf_code-range then do:
      message
        "Отсутствует активный диапазон" skip
        "Невозможно установить значение sequence внутрь активного диапазона" skip
        "База данных" p-db-num skip
        view-as alert-box information .
      return .
    end.
    else do:
      run get-max-code ( input "get-m-code":U
                        ,input buf_code-range.db-num
                        ,input buf_code-range.range-type
                        ,input buf_code-range.first-code
                        ,input buf_code-range.last-code
                        ,input TRUE
                        ,output v-b-code
                       ).
      if v-b-code <= buf_code-range.last-code then do:
        case v-curr-type-cdrg:
          when 'bcgb':U then do:
assign
  v-old-value = current-value(s-bcgb-code, ub)
  v-new-value = max(buf_code-range.first-code, v-b-code)
.
if v-new-value = v-old-value then do:
  message
    "Значение sequence s-bcgb-code находится внутри активного диапазона" skip
    "и не требует коррекции" skip
    "Текущее значение" v-old-value skip
    "Новое значение" v-new-value skip
    view-as alert-box information .
end.
else do:
  message
    "Вы хотите откорректировать значение sequence s-bcgb-code?" skip
    "Текущее значение" v-old-value skip
    "Новое значение" v-new-value skip
    view-as alert-box question buttons yes-no update lok .
  if lok = true then do:
    assign
      current-value(s-bcgb-code, ub) = v-new-value
    .
  end.
end.
          end.
          when 'scgb':U then do:
assign
  v-old-value = current-value(s-scgb-code, ub)
  v-new-value = max(buf_code-range.first-code, v-b-code)
.
if v-new-value = v-old-value then do:
  message
    "Значение sequence s-scgb-code находится внутри активного диапазона" skip
    "и не требует коррекции" skip
    "Текущее значение" v-old-value skip
    "Новое значение" v-new-value skip
    view-as alert-box information .
end.
else do:
  message
    "Вы хотите откорректировать значение sequence s-scgb-code?" skip
    "Текущее значение" v-old-value skip
    "Новое значение" v-new-value skip
    view-as alert-box question buttons yes-no update lok .
  if lok = true then do:
    assign
      current-value(s-scgb-code, ub) = v-new-value
    .
  end.
end.
          end.
          when 'sclc':U then do:
assign
  v-old-value = current-value(s-sclc-code, ub)
  v-new-value = max(buf_code-range.first-code, v-b-code)
.
if v-new-value = v-old-value then do:
  message
    "Значение sequence s-sclc-code находится внутри активного диапазона" skip
    "и не требует коррекции" skip
    "Текущее значение" v-old-value skip
    "Новое значение" v-new-value skip
    view-as alert-box information .
end.
else do:
  message
    "Вы хотите откорректировать значение sequence s-sclc-code?" skip
    "Текущее значение" v-old-value skip
    "Новое значение" v-new-value skip
    view-as alert-box question buttons yes-no update lok .
  if lok = true then do:
    assign
      current-value(s-sclc-code, ub) = v-new-value
    .
  end.
end.
          end.
          when 'pglc':U then do:
assign
  v-old-value = current-value(s-pglc-code, ub)
  v-new-value = max(buf_code-range.first-code, v-b-code)
.
if v-new-value = v-old-value then do:
  message
    "Значение sequence s-pglc-code находится внутри активного диапазона" skip
    "и не требует коррекции" skip
    "Текущее значение" v-old-value skip
    "Новое значение" v-new-value skip
    view-as alert-box information .
end.
else do:
  message
    "Вы хотите откорректировать значение sequence s-pglc-code?" skip
    "Текущее значение" v-old-value skip
    "Новое значение" v-new-value skip
    view-as alert-box question buttons yes-no update lok .
  if lok = true then do:
    assign
      current-value(s-pglc-code, ub) = v-new-value
    .
  end.
end.
          end.
          when 'drgb':U then do:
assign
  v-old-value = current-value(s-drgb-code, ub)
  v-new-value = max(buf_code-range.first-code, v-b-code)
.
if v-new-value = v-old-value then do:
  message
    "Значение sequence s-drgb-code находится внутри активного диапазона" skip
    "и не требует коррекции" skip
    "Текущее значение" v-old-value skip
    "Новое значение" v-new-value skip
    view-as alert-box information .
end.
else do:
  message
    "Вы хотите откорректировать значение sequence s-drgb-code?" skip
    "Текущее значение" v-old-value skip
    "Новое значение" v-new-value skip
    view-as alert-box question buttons yes-no update lok .
  if lok = true then do:
    assign
      current-value(s-drgb-code, ub) = v-new-value
    .
  end.
end.
          end.
          when 'fmgb':U then do:
assign
  v-old-value = current-value(s-fmgb-code, ub)
  v-new-value = max(buf_code-range.first-code, v-b-code)
.
if v-new-value = v-old-value then do:
  message
    "Значение sequence s-fmgb-code находится внутри активного диапазона" skip
    "и не требует коррекции" skip
    "Текущее значение" v-old-value skip
    "Новое значение" v-new-value skip
    view-as alert-box information .
end.
else do:
  message
    "Вы хотите откорректировать значение sequence s-fmgb-code?" skip
    "Текущее значение" v-old-value skip
    "Новое значение" v-new-value skip
    view-as alert-box question buttons yes-no update lok .
  if lok = true then do:
    assign
      current-value(s-fmgb-code, ub) = v-new-value
    .
  end.
end.
          end.
          when 'pngb':U then do:
assign
  v-old-value = current-value(s-pngb-code, ub)
  v-new-value = max(buf_code-range.first-code, v-b-code)
.
if v-new-value = v-old-value then do:
  message
    "Значение sequence s-pngb-code находится внутри активного диапазона" skip
    "и не требует коррекции" skip
    "Текущее значение" v-old-value skip
    "Новое значение" v-new-value skip
    view-as alert-box information .
end.
else do:
  message
    "Вы хотите откорректировать значение sequence s-pngb-code?" skip
    "Текущее значение" v-old-value skip
    "Новое значение" v-new-value skip
    view-as alert-box question buttons yes-no update lok .
  if lok = true then do:
    assign
      current-value(s-pngb-code, ub) = v-new-value
    .
  end.
end.
          end.
          when 'dcgb':U then do:
assign
  v-old-value = current-value(s-dcgb-code, ub)
  v-new-value = max(buf_code-range.first-code, v-b-code)
.
if v-new-value = v-old-value then do:
  message
    "Значение sequence s-dcgb-code находится внутри активного диапазона" skip
    "и не требует коррекции" skip
    "Текущее значение" v-old-value skip
    "Новое значение" v-new-value skip
    view-as alert-box information .
end.
else do:
  message
    "Вы хотите откорректировать значение sequence s-dcgb-code?" skip
    "Текущее значение" v-old-value skip
    "Новое значение" v-new-value skip
    view-as alert-box question buttons yes-no update lok .
  if lok = true then do:
    assign
      current-value(s-dcgb-code, ub) = v-new-value
    .
  end.
end.
          end.
          when 'ctgb':U then do:
assign
  v-old-value = current-value(s-ctgb-code, ub)
  v-new-value = max(buf_code-range.first-code, v-b-code)
.
if v-new-value = v-old-value then do:
  message
    "Значение sequence s-ctgb-code находится внутри активного диапазона" skip
    "и не требует коррекции" skip
    "Текущее значение" v-old-value skip
    "Новое значение" v-new-value skip
    view-as alert-box information .
end.
else do:
  message
    "Вы хотите откорректировать значение sequence s-ctgb-code?" skip
    "Текущее значение" v-old-value skip
    "Новое значение" v-new-value skip
    view-as alert-box question buttons yes-no update lok .
  if lok = true then do:
    assign
      current-value(s-ctgb-code, ub) = v-new-value
    .
  end.
end.
          end.
          when 'cagb':U then do:
assign
  v-old-value = current-value(s-cagb-code, ub)
  v-new-value = max(buf_code-range.first-code, v-b-code)
.
if v-new-value = v-old-value then do:
  message
    "Значение sequence s-cagb-code находится внутри активного диапазона" skip
    "и не требует коррекции" skip
    "Текущее значение" v-old-value skip
    "Новое значение" v-new-value skip
    view-as alert-box information .
end.
else do:
  message
    "Вы хотите откорректировать значение sequence s-cagb-code?" skip
    "Текущее значение" v-old-value skip
    "Новое значение" v-new-value skip
    view-as alert-box question buttons yes-no update lok .
  if lok = true then do:
    assign
      current-value(s-cagb-code, ub) = v-new-value
    .
  end.
end.
          end.
          when 'fdgb':U then do:
assign
  v-old-value = current-value(s-fin-doc, ub)
  v-new-value = max(buf_code-range.first-code, v-b-code)
.
if v-new-value = v-old-value then do:
  message
    "Значение sequence s-fin-doc находится внутри активного диапазона" skip
    "и не требует коррекции" skip
    "Текущее значение" v-old-value skip
    "Новое значение" v-new-value skip
    view-as alert-box information .
end.
else do:
  message
    "Вы хотите откорректировать значение sequence s-fin-doc?" skip
    "Текущее значение" v-old-value skip
    "Новое значение" v-new-value skip
    view-as alert-box question buttons yes-no update lok .
  if lok = true then do:
    assign
      current-value(s-fin-doc, ub) = v-new-value
    .
  end.
end.
          end.
        end case.
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE reopen-query :
  do
  on error undo, return error
  :
    define buffer buf_temp-b-code-info for temp-b-code-info .
    define variable v-reposition-db-num like ub.db.db-num no-undo .
    if available temp-b-code-info then do:
      assign
        v-reposition-db-num = temp-b-code-info.db-num
      .
    end.
    run fill-temp-b-code-info in this-procedure .
    OPEN QUERY BROWSE-1 FOR EACH temp-b-code-info .
    if v-reposition-db-num <> 0 then do:
      find first buf_temp-b-code-info
        where buf_temp-b-code-info.db-num = v-reposition-db-num
        no-error .
      if available buf_temp-b-code-info then do:
        reposition BROWSE-1 to rowid rowid(buf_temp-b-code-info) no-error .
      end.
    end.
    run display-dependent-info in this-procedure .
  end.
END PROCEDURE.
PROCEDURE send-records :
  DEFINE INPUT PARAMETER p-tbl-list AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-rowid-list AS CHARACTER NO-UNDO.
  DEFINE VARIABLE i            AS INTEGER   NO-UNDO.
  DEFINE VARIABLE link-handle  AS CHARACTER NO-UNDO.
  DEFINE VARIABLE rowid-string AS CHARACTER NO-UNDO.
  DO i = 1 TO NUM-ENTRIES(p-tbl-list):
      IF i > 1 THEN p-rowid-list = p-rowid-list + ",":U.
      CASE ENTRY(i, p-tbl-list):
    WHEN "temp-b-code-info":U THEN p-rowid-list = p-rowid-list +
        IF AVAILABLE temp-b-code-info THEN STRING(ROWID(temp-b-code-info))
        ELSE "?":U.
        OTHERWISE
        DO:
            RUN get-link-handle IN adm-broker-hdl (INPUT THIS-PROCEDURE,
                INPUT "RECORD-SOURCE":U, OUTPUT link-handle) NO-ERROR.
            IF link-handle NE "":U THEN
            DO:
                IF NUM-ENTRIES(link-handle) > 1 THEN
                    MESSAGE "send-records in ":U THIS-PROCEDURE:FILE-NAME
                            "encountered more than one RECORD-SOURCE.":U SKIP
                            "The first will be used.":U
                            VIEW-AS ALERT-BOX ERROR.
                RUN send-records IN WIDGET-HANDLE(ENTRY(1,link-handle))
                    (INPUT ENTRY(i, p-tbl-list), OUTPUT rowid-string).
                p-rowid-list = p-rowid-list + rowid-string.
            END.
            ELSE
            DO:
                MESSAGE "Requested table":U ENTRY(i, p-tbl-list)
                        "does not match tables in send-records":U
                        "in procedure":U THIS-PROCEDURE:FILE-NAME ".":U SKIP
                        "Check that objects are linked properly and that":U
                        "database qualification is consistent.":U
                    VIEW-AS ALERT-BOX ERROR.
                RETURN ERROR.
            END.
        END.
        END CASE.
    END.
END PROCEDURE.
PROCEDURE state-changed :
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
END PROCEDURE.
