define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Импорт товаров".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info3 as character format "X(65)" no-undo
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
define variable g-grp   as char no-undo.
define variable ref-list as char no-undo.
define stream imp.
define stream err.
define stream attem .
def new shared var vattaxcd as integer no-undo.
def new shared var slttaxcd as integer no-undo.
define variable f-name as char no-undo.
define variable p-artic     AS integer NO-UNDO init 1.
define variable p-name      AS integer NO-UNDO init 2.
define variable p-engl-name AS integer NO-UNDO.
define variable p-lab-name  AS integer NO-UNDO.
define variable p-SLT-code  AS integer NO-UNDO.
define variable p-VAT-code  AS integer NO-UNDO.
define variable p-unit-base AS integer NO-UNDO.
define variable p-struct    AS integer NO-UNDO.
define variable p-client    AS integer NO-UNDO.
define variable p-grp       AS integer NO-UNDO.
define variable p-city      AS integer NO-UNDO.
define variable p-gds-prt   AS integer NO-UNDO.
define variable p-11 AS integer NO-UNDO.
define variable p-22 AS integer NO-UNDO.
define variable p-33 AS integer NO-UNDO.
define variable p-44 AS integer NO-UNDO.
define variable choice as integer no-undo.
define variable i      AS integer NO-UNDO.
define variable i-artic     as character no-undo.
define variable i-name      as character no-undo.
define variable i-engl-name as character no-undo.
define variable i-lab-name  as character no-undo.
define variable i-SLT-code  AS integer   NO-UNDO.
define variable i-unit-base as character no-undo.
define variable i-VAT-code  AS integer   NO-UNDO.
define variable i-11 AS character NO-UNDO.
define variable i-22 AS character NO-UNDO.
define variable i-33 AS character NO-UNDO.
define variable i-44 AS character NO-UNDO.
define variable i-struct as character no-undo.
define variable i-grp-code    AS integer   NO-UNDO.
define variable i-grp-name    as character no-undo.
define variable i-city        as character no-undo.
define variable i-client-type as character no-undo.
define variable i-client-code AS integer   NO-UNDO.
define variable i-gds-prt     AS integer   NO-UNDO.
define variable i-gds-code like ub.goods.gds-code NO-UNDO.
define variable text-string as character no-undo.
define variable ii          as integer No-UNDO.
define variable impc        as integer No-UNDO.
define variable impc-save   as integer No-UNDO.
define variable grp-code like ub.gds-grp.node-code No-UNDO.
define variable t-gds-prt AS integer NO-UNDO.
define variable txt       as character no-undo.
define temp-table temp_grplib_found-grp no-undo
    field full-name  as character
    field node-code  as integer
    field level      as integer
    index pi is primary unique full-name
    index lv level
.
define buffer buf-goods for ub.goods.
DEFINE VARIABLE var-bc-code as integer no-undo .
define buffer buf_bar-code for ub.bar-code.
define variable NDS like  ub.tax-rate-value.rate-value  no-undo .
define variable NP  like  ub.tax-rate-value.rate-value  no-undo .
define variable reply as log no-undo.
define variable line as int no-undo.
define variable j-gds-code like ub.goods.gds-code NO-UNDO.
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 15 BY 1.13
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK
     LABEL "Старт"
     SIZE 15 BY 1.13
     BGCOLOR 8 .
DEFINE BUTTON B-help
     LABEL "&Помощь"
     SIZE 15 BY 1.13
     .
DEFINE BUTTON File
     LABEL "Файл и настройки"
     SIZE 18.88 BY 1.33.
DEFINE BUTTON grp
     LABEL "Группа"
     SIZE 10.5 BY 1.21.
DEFINE BUTTON Imly-City
     LABEL "Страна"
     SIZE 10.5 BY 1.21.
DEFINE BUTTON Imply-Cli
     LABEL "Производитель"
     SIZE 14.13 BY 1.13.
DEFINE BUTTON measure
     LABEL "Ед. изм."
     SIZE 10.5 BY 1.21.
DEFINE BUTTON prt
     LABEL "Шкала"
     SIZE 10.5 BY 1.21.
DEFINE VARIABLE city1 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.88 BY 1.21
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE city2 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 53.88 BY 1.21
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE Cli-code AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 8.88 BY 1.13
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE Cli-Name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 43.63 BY 1.13
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE Cli-type AS CHARACTER FORMAT "X(8)":U
      VIEW-AS TEXT
     SIZE 4.63 BY 1.13
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE File-txt AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 53.5 BY 1.25
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE grp-txt AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 58.13 BY 1.21
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE measure-txt1 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6.5 BY 1.21
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE measure-txt2 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 22.25 BY 1.21
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE measure-txt3 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 28.63 BY 1.21
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE prt-txt AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 58.13 BY 1.21
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE R-S-stop AS INTEGER INITIAL 2
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Без останова", 1,
"Останов по ошибке", 2
     SIZE 21 BY 1.75 NO-UNDO.
DEFINE FRAME Dialog-Frame
     File AT ROW 1.42 COL 1.75
     Imply-Cli AT ROW 4.5 COL 1.38
     grp AT ROW 5.75 COL 5
     Imly-City AT ROW 7.25 COL 5
     measure AT ROW 8.75 COL 5
     prt AT ROW 10.25 COL 5
     R-S-stop AT ROW 11.75 COL 5.5 NO-LABEL
     Btn_OK AT ROW 13.75 COL 21
     Btn_Cancel AT ROW 13.75 COL 41.5
     b-help AT ROW 1.42 COL 71.5
     File-txt AT ROW 1.46 COL 19.5 COLON-ALIGNED NO-LABEL
     Cli-code AT ROW 4.5 COL 14.63 COLON-ALIGNED NO-LABEL
     Cli-type AT ROW 4.5 COL 24 COLON-ALIGNED NO-LABEL
     Cli-Name AT ROW 4.5 COL 29.13 COLON-ALIGNED NO-LABEL
     grp-txt AT ROW 5.75 COL 14.63 COLON-ALIGNED NO-LABEL
     city1 AT ROW 7.25 COL 14.63 COLON-ALIGNED NO-LABEL
     city2 AT ROW 7.25 COL 19 COLON-ALIGNED NO-LABEL
     measure-txt1 AT ROW 8.71 COL 14.63 COLON-ALIGNED NO-LABEL
     measure-txt2 AT ROW 8.71 COL 21.63 COLON-ALIGNED NO-LABEL
     measure-txt3 AT ROW 8.71 COL 44.38 COLON-ALIGNED NO-LABEL
     prt-txt AT ROW 10.25 COL 14.5 COLON-ALIGNED NO-LABEL
     "            Параметры подставляемые по умолчанию" VIEW-AS TEXT
          SIZE 73.38 BY .92 AT ROW 3.08 COL 1.5
          BGCOLOR 8 FGCOLOR 0
     SPACE(0.36) SKIP(9.12)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE BGCOLOR 0 FGCOLOR 15 "Импорт товаров в справочник из файла"
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
  assign
    R-S-stop
    impc-save = 0
    impc = 0
  .
 if p-client = 0 and Cli-type = "" then do:
         message "Производитель должен быть заведен в файле импорта или выбран какого подставлять по умолчанию" view-as alert-box.
 end.
 else do:
    if p-client = 0 then do:
          assign
            i-client-type = Cli-type
            i-client-code = Cli-code
          .
    end.
    find first ub.gds-prt no-lock
        where  ub.gds-prt.node-name = '_Пустая шкала':U
    no-error.
    CASE choice:
        WHEN 1 then do:
            input stream imp from value (f-name) convert source "1251".
        END.
        WHEN 2 then do:
            input stream imp from value (f-name) convert source "KOI8-R".
        END.
    END CASE.
    OUTPUT stream err close.
    OUTPUT stream attem close.
    OUTPUT stream err TO value ("err.txt").
    OUTPUT stream attem TO value ("attem.txt").
    repeat:
        IMPORT stream imp UNFORMATTED text-string NO-ERROR.
        if trim(text-string) = "" then leave.
        assign impc = impc + 1.
        if NUm-ENTRIES(text-string, ";") <> line then do:
                  put stream err "В строчке " impc " неверное кол-во полей - " NUm-ENTRIES(text-string, ";")
                       "должно быть" line
                  skip.
                  export stream  err text-string .
                  IF r-s-stop = 1 THEN next.
                  ELSE RETURN.
        end.
        run next-good (output reply).
        display
                 impc
                 i-artic format "x(20)"
                 impc-save
              with frame ff view-as dialog-box
              title ": Загрузка справочника товаров из файла".
        pause 0.
        if  reply = false then do:
                next.
        end.
        if i-client-type = "" then do:
                if Cli-type = "" then do:
                          export stream  err text-string "Не задан производитель товаров".
                          IF r-s-stop = 1 THEN next.
                          ELSE RETURN.
                end.
                else
                  assign
                      i-client-type = Cli-type
                      i-client-code = Cli-code
                  .
        end.
        if i-grp-name = "" then do:
              if grp-txt = "" then do:
                     export stream  err text-string "Не задана группа товаров" .
                     IF r-s-stop = 1 THEN next.
                     ELSE RETURN.
              end.
              else
                     assign
                        i-grp-code = grp-code
                        i-grp-name = grp-txt.
        end.
        if i-unit-base = "" then do:
               if measure-txt1 = "" then do:
                     export stream  err text-string "Не задана единица измерения товаров".
                     IF r-s-stop = 1 THEN next.
                     ELSE RETURN.
               end.
               else   assign    i-unit-base = measure-txt1.
        end.
        if i-city = ""  then i-city = city1 .
        if p-gds-prt = 0 and prt-txt <> "" then do:
            find first ub.gds-prt no-lock  where
                       ub.gds-prt.root = TRUE and
                       ub.gds-prt.node-name = prt-txt
            no-error.
            if available ub.gds-prt then  i-gds-prt = ub.gds-prt.node-code.
            else do:
                    export stream  err text-string "Не задана шкала товаров".
                    IF r-s-stop = 1 THEN next.
                    ELSE RETURN.
            end.
        end.
        find first goods where
                   goods.artic = i-artic and
                   goods.prod-type = i-client-type and
                   goods.prod-code = i-client-code
        no-lock no-error.
        if available goods then do:
                  put stream attem "Такой товар уже есть в БД" skip.
                  export stream  attem text-string .
                  IF r-s-stop = 1 THEN next.
                  ELSE RETURN.
        end.
        do transaction:
                define variable v-host-code     as integer           no-undo.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  )  .
                run ref/dtaxgdss.p (
                      input yes
                    , input   i-unit-base
                    , input   ub.gds-prt.node-code
                    , input ?
                    , input ?
                    , input   v-host-code
                    , input    v-cntxt-obj-type
                    , input    v-cntxt-obj-code
                ).
                IF p-VAT-code > 0 THEN DO:
                  find first tt-tax
                      where tt-tax.tax-code = integer( '1':U )
                  no-error.
                  if available tt-tax   then do:
                      assign
                          tt-tax.rate-code = NDS .
                  end.
                END.
                if p-SLT-code > 0  then DO:
                  find first tt-tax
                      where tt-tax.tax-code = integer( '2':U )
                  no-error.
                  if available tt-tax  then do:
                      assign
                          tt-tax.rate-code = NP  .
                  end.
                END.
            define variable v-recid         as recid             no-undo.
            run ref/goods01.p (
                  input parparentproc
                , input 'ДОБАВЛЕНИЕ':U
                , input no
                , input 0
                , input no
                , input yes
                , input no
                , input no
                , input yes
                , input v-host-code
                , input v-cntxt-obj-type
                , input v-cntxt-obj-code
                , input yes
                , input ?
                , input 0
                , input i-artic
                , input i-client-type
                , input i-client-code
                , input i-gds-prt
                , input i-grp-code
                , input i-name
                , input ""
                , input i-name
                , input i-name
                , input replace( replace( i-name, chr( 39 ), "" ), chr( 34 ), "" )
                , input i-city
                , input i-unit-base
                , input i-unit-base
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
                , input no
                , input 0
                , input 0
                , input ""
                , input i-11
                , input i-22
                , input i-33
                , input i-44
                , input i-struct
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
                IF r-s-stop = 2 THEN RETURN.
            end.
            else  impc-save = impc-save + 1.
        end.
    END.
    input stream imp close.
    OUTPUT stream err close.
    OUTPUT stream attem close.
    message ("Импорт из файла " + f-name + " закончен" + chr(10) + "прочитано " + string(impc) +
             ",  сохранено " + string(impc-save) )
    view-as alert-box  INFORMATION.
 end.
END.
ON CHOOSE OF File IN FRAME Dialog-Frame
DO:
      disable Btn_OK with frame Dialog-Frame.
      disable grp with frame Dialog-Frame.
      disable Imly-city with frame Dialog-Frame.
      disable measure with frame Dialog-Frame.
      disable prt with frame Dialog-Frame.
      disable Imply-Cli with frame Dialog-Frame.
      run utl/strtimp1.w (
                  input vattaxcd,
                  input slttaxcd,
                  output f-name,
                  output choice,
                  output p-artic,
                  OUTPUT p-name,
                  OUTPUT p-engl-name,
                  OUTPUT p-unit-base,
                  OUTPUT p-VAT-code,
                  OUTPUT p-SLT-code,
                  OUTPUT p-struct,
                  OUTPUT p-11,
                  OUTPUT p-22,
                  OUTPUT p-33,
                  OUTPUT p-44,
                  OUTPUT p-city,
                  OUTPUT p-grp,
                  OUTPUT p-gds-prt,
                  OUTPUT p-client,
                  OUTPUT line
                  ) no-error.
      if  error-status:error or f-name = "" then do:
              message
                vss-workfile vss-revision vss-description skip
                "Не выбран файл для импорта" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              return .
      end.
      assign
            file-txt = f-name.
      enable Btn_OK with frame Dialog-Frame.
      if p-grp = 0 then
           enable grp with frame Dialog-Frame.
      if p-city = 0 then
           enable Imly-city with frame Dialog-Frame.
      if p-unit-base  = 0 then
           enable measure with frame Dialog-Frame.
      if p-gds-prt = 0 then
           enable prt with frame Dialog-Frame.
      if p-client = 0 then
           enable Imply-Cli with frame Dialog-Frame.
      disp
           file-txt
      with frame Dialog-Frame.
END.
ON CHOOSE OF grp IN FRAME Dialog-Frame
DO:
    run ref/gds-grp.w (  input parparentproc
                  , input "b-sel"
                  , input v-cntxt-obj-type
                  , input v-cntxt-obj-code
                  , input-output g-grp ).
    if g-grp <> "" then do:
       FIND FIRST ub.gds-grp WHERE
         recid (ub.gds-grp) = integer (g-grp) NO-LOCK.
       if available ub.gds-grp then do:
            g-grp = "".
            run grplib-get-full-name in this-procedure ( input ub.gds-grp.node-code, output g-grp ) .
            assign
               grp-code = ub.gds-grp.node-code
               grp-txt = g-grp.
            disp
                grp-txt
            with frame Dialog-Frame.
       end.
    end.
END.
ON CHOOSE OF Imly-City IN FRAME Dialog-Frame
DO:
define variable v-rid-list as character no-undo .
run ref/countris.w (input parparentproc,  "b-sel", input-output v-rid-list ).
if v-rid-list <> "" then     do:
    FIND ub.country WHERE recid (ub.country) = integer(v-rid-list) NO-LOCK.
    if available ub.country then
          assign
              city1  = ub.country.alpha1
              city2  = ub.country.long-name
          .
            disp
              city1
              city2
         with frame Dialog-Frame.
    end.
END.
ON CHOOSE OF Imply-Cli IN FRAME Dialog-Frame
DO:
define variable v-ref-rec as recid no-undo .
    run ref/cli-all.w ( parparentproc, input "b-sel", 'орг':U, ?, ?, ?, ?, ?, output  ref-list).
    v-ref-rec = integer (ref-list).
    if  v-ref-rec <> ? then do:
        FIND ub.clients WHERE recid (ub.clients) = v-ref-rec NO-LOCK .
        if available ub.clients then
           assign
           Cli-type = ub.clients.obj-type
           Cli-code = ub.clients.obj-code
           Cli-name = ub.clients.obj-name
           .
           disp
             Cli-type
             Cli-code
             Cli-name
        with frame Dialog-Frame.
    end.
END.
ON CHOOSE OF measure IN FRAME Dialog-Frame
DO:
define variable v-ref-rec as recid no-undo .
    run ref/units.w ( input parparentproc, yes, output v-ref-rec ).
    if v-ref-rec <> ? then  do:
        FIND ub.units WHERE recid (ub.units) = v-ref-rec NO-LOCK.
        assign
          measure-txt1 = ub.units.unit-name
          measure-txt2 = ub.units.long-name
          measure-txt3 = ub.units.type
        .
        disp
          measure-txt1
          measure-txt2
          measure-txt3
        with frame Dialog-Frame.
    end.
END.
ON CHOOSE OF prt IN FRAME Dialog-Frame
DO:
 define variable v-ref-rec as recid no-undo .
    run ref/gdsprts.w (parparentproc, yes, output v-ref-rec).
    if v-ref-rec <> ? then do:
         FIND ub.gds-prt WHERE recid (ub.gds-prt) = v-ref-rec.
         if available ub.gds-prt then do:
            assign
              t-gds-prt = ub.gds-prt.prt-root
              prt-txt = ub.gds-prt.node-name
            .
            disp
                prt-txt
            with frame Dialog-Frame.
       end.
    end.
END.
find first ub.sys-ctrl.
if ub.sys-ctrl.db-num <> 0 then do:
  message "Данная утилита может работать только в ГБД.".
  return.
end.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  DISPLAY R-S-stop File-txt Cli-code Cli-type Cli-Name grp-txt city1 city2
          measure-txt1 measure-txt2 measure-txt3 prt-txt
      WITH FRAME Dialog-Frame.
  ENABLE File R-S-stop Btn_Cancel File-txt Cli-code Cli-type Cli-Name grp-txt
         city1 city2 measure-txt1 measure-txt2 measure-txt3 prt-txt
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY R-S-stop File-txt Cli-code Cli-type Cli-Name grp-txt city1 city2
          measure-txt1 measure-txt2 measure-txt3 prt-txt
      WITH FRAME Dialog-Frame.
  ENABLE File R-S-stop Btn_Cancel File-txt Cli-code Cli-type Cli-Name grp-txt
         city1 city2 measure-txt1 measure-txt2 measure-txt3 prt-txt
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE get-node-code :
define input parameter p-search-name  as character    no-undo.
define output parameter cod-grp  like ub.gds-grp.node-code no-undo.
define variable p-fill-path     as logical          no-undo.
define variable v-upper-code    as integer          no-undo.
define variable v-not-found     as logical init yes no-undo.
define variable v-counter       as integer          no-undo.
define variable v-level         as integer          no-undo.
define variable v-full-name     as character        no-undo.
define buffer buf_gds-grp       for ub.gds-grp.
cod-grp = ?.
run grplib-get-root-code ( output v-upper-code ) no-error .
if error-status :error  then do:
        undo, return error "grplib-expand-name: Ошибка при поиске корневого узла".
end.
assign
    v-full-name  = ""
    v-level      = num-entries( p-search-name, chr(47) ) .
for each temp_grplib_found-grp    :
    delete temp_grplib_found-grp.
end.
start-name-analyze:
do v-counter = 1 to v-level :
    if v-counter < v-level  then do:
            find first buf_gds-grp no-lock
                 where buf_gds-grp.upper-code = v-upper-code
                   and buf_gds-grp.node-name  = entry( v-counter, p-search-name, chr(47) )
            no-error .
            if not available buf_gds-grp   then do:
                assign
                    v-full-name  = p-search-name
                .
            end.
            else do:
                assign
                    v-full-name = v-full-name + (if v-full-name = "" then "" else chr(47)) + buf_gds-grp.node-name
                    v-upper-code = buf_gds-grp.node-code
                .
                if p-fill-path = yes
                then do:
                    create temp_grplib_found-grp.
                    assign
                        temp_grplib_found-grp.full-name = v-full-name
                        temp_grplib_found-grp.node-code = v-upper-code
                        temp_grplib_found-grp.level     = v-counter
                    .
                end.
            end.
    end.
    else do:
            for each buf_gds-grp no-lock
               where buf_gds-grp.upper-code = v-upper-code
                 and buf_gds-grp.node-name begins entry( v-counter, p-search-name, chr(47) )
            :
                assign
                    v-not-found = no
                .
                create temp_grplib_found-grp.
                assign
                    temp_grplib_found-grp.full-name = v-full-name
                                                        + (if v-full-name = "" then "" else chr(47))
                                                        + buf_gds-grp.node-name
                    temp_grplib_found-grp.node-code = buf_gds-grp.node-code
                    temp_grplib_found-grp.level     = v-level
                .
            end.
            if v-not-found = yes   then do:
                assign
                    v-full-name  = p-search-name
                .
                for each temp_grplib_found-grp
                :
                    delete temp_grplib_found-grp.
                end.
            end.
    end.
end.
for each temp_grplib_found-grp no-lock:
  assign cod-grp =  temp_grplib_found-grp.node-code.
end.
END PROCEDURE.
PROCEDURE grplib-get-root-code :
do
on error undo, return error
:
define output parameter p-root-code as integer      no-undo.
define buffer buf_gds-grp       for ub.gds-grp.
    find first buf_gds-grp no-lock
        where buf_gds-grp.upper-code = 0
    no-error .
    if not available buf_gds-grp
    then do:
        undo, return error .
    end.
    else do:
        assign
            p-root-code = buf_gds-grp.node-code
        .
    end.
end.
END PROCEDURE.
PROCEDURE next-good :
define output parameter reply-out as log   no-undo.
  assign
      i-artic = ""
      i-name = ""
      i-engl-name = ""
      i-lab-name = ""
      i-SLT-code = 0
      i-unit-base = ""
      i-VAT-code = 0
      i-11 = ""
      i-22 = ""
      i-33 = ""
      i-44 = ""
      i-struct = ""
      i-grp-code = 0
      i-grp-name = ""
      i-city = ""
      i-gds-prt = 0
      i-client-type = ""
      i-client-code = 0
      reply-out = true
  .
  assign
    i-artic = ENTRY(p-artic, text-string, ";")
    i-name  = ENTRY(p-name,  text-string, ";")
  .
  if p-engl-name > 0  then
        assign  i-engl-name = ENTRY(p-engl-name, text-string, ";").
  if p-lab-name > 0  then
        assign  i-lab-name = ENTRY(p-lab-name, text-string, ";").
  if p-struct > 0  then  assign i-struct = ENTRY(p-struct, text-string, ";").
  ASSIGN
    NDS = ?
    NP  = ?
  .
  if p-VAT-code > 0 then do:
       assign   i-vat-code = integer(ENTRY(p-vat-code, text-string, ";")).
       find last ub.tax-rate-value where
                 ub.tax-rate-value.tax-code  = 1 and
                 ub.tax-rate-value.rate-code = i-vat-code no-lock no-error.
       IF NOT available ub.tax-rate-value then do:
            put stream err "Нет в БД ставки НДС с кодом "
                    i-vat-code
            skip.
            export stream  err text-string .
            assign reply-out = false.
            return .
       END.
       else NDS = ub.tax-rate-value.rate-code.
  end.
  else do:
       find last ub.tax-rate-value where
                 ub.tax-rate-value.tax-code  = 1 and
                 ub.tax-rate-value.rate-code = 1 no-lock no-error.
       assign
         i-VAT-code =  ub.tax-rate-value.rate-code.
         NDS = ub.tax-rate-value.rate-code
       .
  end.
  if p-SLT-code > 0  then do:
       assign   i-SLT-code = integer(ENTRY(p-SLT-code, text-string, ";")).
       find last ub.tax-rate-value where
                 ub.tax-rate-value.tax-code  = 2 and
                 ub.tax-rate-value.rate-code = i-SLT-code no-lock no-error.
       IF NOT available ub.tax-rate-value then do:
            put stream err "Нет в БД ставки НП "
                    i-SLT-code
            skip.
            export stream  err text-string .
            assign reply-out = false.
            return .
       END.
       else  NP = tax-rate-value.rate-code .
  end.
  else do:
       find last ub.tax-rate-value where
                 ub.tax-rate-value.tax-code  = 2 and
                 ub.tax-rate-value.rate-code = 22 no-lock no-error.
       assign
         i-SLT-code = ub.tax-rate-value.rate-code
         NP = ub.tax-rate-value.rate-code
       .
  end.
  if p-unit-base > 0  then do:
       FIND FIRST ub.units NO-LOCK where
          ub.units.unit-name = ENTRY(p-unit-base, text-string, ";")
       No-ERROR.
       IF NOT available ub.units then do:
            put stream err "Нет в БД единицы измерения "
                    ENTRY(p-unit-base, text-string, ";")
            skip.
            export stream  err text-string .
            assign reply-out = false.
            return .
       END.
       assign  i-unit-base = ENTRY(p-unit-base, text-string, ";").
  end.
  if p-grp > 0  then do:
       assign i-grp-name = ENTRY(p-grp, text-string, ";").
       run get-node-code (input i-grp-name, output i-grp-code) .
       FIND FIRST ub.gds-grp NO-LOCK where
                  ub.gds-grp.node-code = i-grp-code
       No-ERROR.
       IF NOT available ub.gds-grp then do:
               put stream err "Нет в БД такой группы товаров "
                   ENTRY(p-grp, text-string, ";") format "x(50)"
               skip.
               export stream  err text-string .
               assign
                 i-grp-name = ""
                 i-grp-code = 0.
                 reply-out = false
               .
               return .
       END.
  end.
  if p-city > 0  then  do:
      assign i-city = ENTRY(p-city, text-string, ";").
      if trim(i-city) <> "" then do:
         find first ub.country where
                    ub.country.alpha1 = i-city no-lock no-error.
         if not available ub.country then do:
             put stream err "Нет в БД такой страны "
                    i-city
             skip.
             export stream  err text-string .
             assign
                i-city = ""
                reply-out = false
             .
             return.
         end.
      end.
  end.
  if p-client > 0  then  do:
     assign
         i-client-type = "орг"
         i-client-code = integer(ENTRY(p-client, text-string, ";")).
     find first ub.clients where
                ub.clients.obj-type = i-client-type  and
                ub.clients.obj-code = i-client-code no-lock no-error.
     if not available ub.clients then do:
          put stream err "Нет в БД такого производителя "
                    i-client-code
         skip.
         export stream  err text-string .
         assign
            i-client-type = ""
            i-client-code = 0
            reply-out = false
         .
         return .
     end.
  end.
  if p-gds-prt > 0  then   do:
         find first ub.gds-prt where
              ub.gds-prt.root = TRUE and
              ub.gds-prt.node-name = ENTRY(p-gds-prt, text-string, ";")  no-lock no-error.
         if  not  available  ub.gds-prt  then do:
             put stream err "Нет в БД такой шкалы "
                    ENTRY(p-gds-prt, text-string, ";")
             skip.
             export stream  err text-string .
             assign
                 i-gds-prt = 0
                 reply-out = false
             .
             return.
         end.
         else i-gds-prt = ub.gds-prt.prt-root .
  end.
  if p-struct > 0  then  assign i-struct = ENTRY(p-struct, text-string, ";").
  if p-11 > 0  then  assign i-11 = ENTRY(p-11, text-string, ";").
  if p-22 > 0  then  assign i-22 = ENTRY(p-22, text-string, ";").
  if p-33 > 0  then  assign i-33 = ENTRY(p-33, text-string, ";").
  if p-44 > 0  then  assign i-44 = ENTRY(p-44, text-string, ";").
END PROCEDURE.
