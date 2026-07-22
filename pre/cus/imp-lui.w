define input  parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Импорт из текстового файла".
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
define new shared buffer buf_goods for ub.goods.
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
define buffer buf_bar-code  for ub.bar-code.
define buffer buf_price-doc for ub.price-doc.
define buffer buf_sys-ctrl  for ub.sys-ctrl.
define buffer buf_gds-prt   for ub.gds-prt.
define buffer buf_gds-grp   for ub.gds-grp.
define buffer buf_clients   for ub.clients.
def var v_os-file as char no-undo.
define variable v-ok AS LOG NO-UNDO.
DEFINE VARIABLE chExcelApplication AS COM-HANDLE no-undo .
define variable chWorkBook   as com-handle no-undo .
define variable chWorkSheet  as com-handle no-undo .
define variable ch-range   as com-handle no-undo .
define variable Cell AS CHAR NO-UNDO.
DEF VAR i-LINE AS INT NO-UNDO.
define variable I-Artic AS CHAR NO-UNDO.
define variable I-Name AS CHAR NO-UNDO.
define variable I-Vol AS CHAR NO-UNDO.
define variable I-Prix AS CHAR NO-UNDO.
define variable I-Price AS CHAR NO-UNDO.
define variable I-Eng-Name AS CHAR NO-UNDO.
define variable Var-Dec AS DEC NO-UNDO.
DEFINE var i-grp-code AS integer NO-UNDO.
DEFINE var i-grp-name as char INIT "test"  no-undo.
DEFINE var i-scale as char INIT "_Пустая шкала" no-undo.
DEFINE var i-Cli-type as char INIT "орг"  no-undo.
DEFINE var i-Cli-code as INTEGER INIT 4  no-undo.
DEFINE var i-city as CHAR INIT "FR" no-undo.
define variable v-host-code  as integer  no-undo.
define variable v-recid  as RECID  no-undo.
DEFINE var j-gds-code like ub.goods.gds-code NO-UNDO.
DEFINE var impc-save AS INT NO-UNDO.
define variable impc-update as integer no-undo .
def stream err.
def var i-doc-num       like   ub.price-doc.doc-num no-undo .
DEF VAR loc-ref-list      as    char no-undo .
define variable v-log as logical   no-undo .
define variable f-name     as character no-undo .
def stream txt-temp.
DEFINE BUTTON B-file
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Выход"
     SIZE 15 BY 1.13
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK
     LABEL "Выполнить"
     SIZE 15 BY 1.13
     BGCOLOR 8 .
DEFINE VARIABLE file-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Файл для импорта"
     VIEW-AS FILL-IN
     SIZE 52.5 BY 1 NO-UNDO.
DEFINE VARIABLE Tumbler AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "В справочник товаров", 1,
"В документ переоценки", 2,
"В файл для последующей загрузки в приходный документ", 3
     SIZE 56 BY 2 NO-UNDO.
DEFINE FRAME Dialog-Frame
     file-name AT ROW 2.25 COL 1
     B-file AT ROW 2.25 COL 71.5
     Tumbler AT ROW 5 COL 15 NO-LABEL
     Btn_OK AT ROW 7.25 COL 16
     Btn_Cancel AT ROW 7.25 COL 41
     "              Куда будем импортировать данные из файла" VIEW-AS TEXT
          SIZE 73.5 BY 1 AT ROW 3.5 COL 1
          BGCOLOR 8
     "          Укажите файл из которого необходимо произвести импорт" VIEW-AS TEXT
          SIZE 73.5 BY .67 AT ROW 1.25 COL 1
          BGCOLOR 8
     SPACE(0.24) SKIP(6.74)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Импорт из текстового файла"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-file IN FRAME Dialog-Frame
DO:
    DEF VAR ll_commit AS LOG    NO-UNDO INIT NO.
    SYSTEM-DIALOG GET-FILE v_os-file
        TITLE "Выберите файл для импорта"
              FILTERS "Excel (*.xls)" "*.xls"
              MUST-EXIST
              USE-FILENAME
        update ll_commit
        default-extension "xls"
        .
    IF ll_commit <> YES THEN do:
       RETURN NO-APPLY.
    end.
    IF v_os-file = PROGRAM-NAME( 1 ) THEN DO:
        BELL.
        MESSAGE "Рекурсия!" VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.
    ASSIGN file-name = ( IF SEARCH( v_os-file ) = ? THEN v_os-file ELSE SEARCH( v_os-file ) ).
    DISP file-name WITH FRAME Dialog-Frame.
END.
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame
DO:
    assign
        Tumbler.
    if  trim(file-name) = "" then do:
            message "Не задан файл для импорта "
            view-as alert-box ERROR.
            return no-apply.
    end.
    create "Excel.Application" chExcelApplication no-error.
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        return no-apply .
    end.
    assign
       chExcelApplication:interactive = false
       chExcelApplication:ScreenUpdating = FALSE
       chExcelApplication:visible = FALSE
       i-line       = 0
       impc-save    = 0
       impc-update  = 0
     .
    chWorkBook   = chExcelApplication:WorkBooks:open( file-name ).
    chWorkSheet  = chExcelApplication:Sheets:item (1).
    if Tumbler = 2  THEN do:
        run str/pr-docs.w (input parparentproc
                    ,input "b-sel":U
                    ,input 'работа':U
                    ,input 'новый':U
                    ,input v-cntxt-obj-type
                    ,input v-cntxt-obj-code
                    ,input ""
                    ,output loc-ref-list).
        if loc-ref-list  = '':U
        or loc-ref-list  = ?
        then do:
          message
            "Переоценка не выбрана."
          view-as alert-box error.
          return .
        end.
        find buf_price-doc no-lock
          where recid (buf_price-doc) = integer(entry(1, loc-ref-list))
        no-error .
        if not available buf_price-doc then do:
          message
            substitute("Переоценка с recid &1 не найдена", integer(entry(1, loc-ref-list)))
          view-as alert-box .
          return .
        end.
        if buf_price-doc.status_ <> 'новый':U then do:
          message
            "Статус переоценки должен быть 'новый'."
          view-as alert-box error.
          return .
        end.
        i-doc-num = buf_price-doc.doc-num.
    END.
    ELSE if Tumbler = 3  THEN do:
        system-dialog get-file f-name
            TITLE "Экспорт в файл для последующей загрузки в приходный документ"
          filters "Файл для экспорта (*.adb) " "*.adb"
          ask-overwrite
          save-as
          use-filename
          update v-log
          default-extension "adb".
        if not v-log then return.
    END.
    repeat:
        i-line = i-line + 1.
        I-Artic   = (chWorkSheet:range ("A" + string(i-LINE)):value) no-error.
        I-Eng-Name = (chWorkSheet:range ("B" + string(i-LINE)):value) no-error.
        I-Vol     = (chWorkSheet:range ("C" + string(i-LINE)):value) no-error.
        I-Prix    = (chWorkSheet:range ("D" + string(i-LINE)):value) no-error.
        I-Price   = (chWorkSheet:range ("E" + string(i-LINE)):value) no-error.
        I-Name    = (chWorkSheet:range ("F" + string(i-LINE)):value) no-error.
        if error-status :error then message "Не верно задана строка " i-LINE  view-as alert-box information .
        IF I-Artic = "AARCOD" THEN DO:
            NEXT.
        END.
        IF DEC (I-Vol) = ? THEN do:
            i-line = i-line - 1.
            LEAVE.
        END.
        display
                 i-line       label "Работаю со строкой":U
                 impc-save    label "Сохранено":U
                 impc-update  label "Изменено":U
           with frame ff view-as dialog-box
        title ": Импорт из файла".
        pause 0.
        IF TRIM(i-artic) = "" THEN DO:
            OUTPUT stream Err TO value ("Imp_Lui.err") append.
            put stream Err unformatted
                string(today, "99/99/9999") " "
                string(time, "HH:MM")
                " Строка - " i-line " - ячейка АРТИКУЛ (A) не должна быть пустой" skip .
            output stream Err close.
            next.
        END.
        IF TRIM(I-Name) = "" THEN DO:
            OUTPUT stream Err TO value ("Imp_Lui.err") append.
            put stream Err unformatted
                string(today, "99/99/9999") " "
                string(time, "HH:MM")
                " Строка - " i-line " - ячейка НАИМЕНОВАНИЕ (F) не должна быть пустой" skip .
            output stream Err close.
            next.
        END.
        find buf_goods where
             buf_goods.artic = i-artic and
             buf_goods.prod-type = i-cli-type and
             buf_goods.prod-code = i-cli-code
        no-lock no-error.
        if not available buf_goods then do:
            if Tumbler = 1 then do:
                  run proc-imp-goods in this-procedure ( input 'ДОБАВЛЕНИЕ':U , input ? ).
            end.
            if Tumbler = 2 OR Tumbler = 3 then DO:
                OUTPUT stream Err TO value ("Imp_Lui.err") append.
                put stream ERR UNFORMATTED
                    string(today, "99/99/9999") " "
                    string(time, "HH:MM")
                    " Строка - " i-line " - товар отсутствует в БД, пропускаем" skip.
                output stream Err close.
                NEXT.
            END.
        END.
        ELSE DO:
            if Tumbler = 1 then DO:
              run proc-imp-goods in this-procedure ( input 'ИЗМЕНЕНИЕ':U , input buf_goods.gds-code ).
              assign
                impc-update = impc-update + 1
              .
            END.
        END.
        if Tumbler = 2  THEN do:
              Var-Dec = DEC (I-Price) NO-ERROR.
              IF ERROR-STATUS:ERROR OR Var-Dec <= 0 THEN DO:
                  OUTPUT stream Err TO value ("Imp_Lui.err") append.
                  put stream Err unformatted
                      string(today, "99/99/9999") " "
                      string(time, "HH:MM")
                      " Строка - " i-line " - в ячейке ЦЕНА (E) стоит что-то не перевариваемое" skip .
                  output stream Err close.
                  next.
              END.
              find first buf_bar-code no-lock
                where buf_bar-code.gds-code = buf_goods.gds-code
              no-error .
              if not available buf_bar-code
              then do:
                 OUTPUT stream Err TO value ("Imp_Lui.err") append.
                 put stream Err unformatted
                     string(today, "99/99/9999") " "
                     string(time, "HH:MM")
                     " Строка - " i-line " - У товара нет собственного Бар-Кода" skip .
                 output stream Err close.
                 next.
              end.
              run proc-imp-price .
        end.
        ELSE if Tumbler = 3 THEN do:
             Var-Dec = DEC (I-Vol) NO-ERROR.
             IF ERROR-STATUS:ERROR OR Var-Dec <= 0 THEN DO:
                OUTPUT stream Err TO value ("Imp_Lui.err") append.
                put stream Err unformatted
                    string(today, "99/99/9999") " "
                    string(time, "HH:MM")
                    " Строка - " i-line " - в ячейке КОЛИЧЕСТВО (C) стоит что-то не перевариваемое" skip .
                output stream Err close.
                next.
             END.
             Var-Dec = DEC (I-Prix) NO-ERROR.
             IF ERROR-STATUS:ERROR OR Var-Dec <= 0 THEN DO:
                OUTPUT stream Err TO value ("Imp_Lui.err") append.
                put stream Err unformatted
                    string(today, "99/99/9999") " "
                    string(time, "HH:MM")
                    " Строка - " i-line " - в ячейке ЦЕНА ПРИХОДА (D) стоит что-то не перевариваемое" skip .
                output stream Err close.
                next.
             END.
             OUTPUT stream txt-temp TO value (f-name) append.
                 put stream txt-temp  unformatted
                     "ITEM:" +
                      buf_goods.artic + ";" +
                      trim(string(buf_goods.prod-code)) + ";;;;" +
                      trim(string(I-Prix)) + ";" +
                      trim(string(I-Vol)) + ";;;;;;;;;" SKIP.
             output stream txt-temp close.
             impc-save = impc-save + 1.
        end.
    END.
    OUTPUT stream err close.
    release object chWorkSheet   no-error .
    RELEASE object chWorkBook   no-error .
    assign
       v-ok = chExcelApplication:Quit() no-error
     .
    release object chExcelApplication   no-error .
    message ("Импорт из файла " + file-name + " закончен" + chr(10) + "прочитано " + string(i-line) +
             ",  сохранено " + string(impc-save) + ", из них изменено " + string(impc-update) + '.' +
             chr(10) + " Все ошибки выведены в файл - Imp_Lui.err" )
    view-as alert-box  INFORMATION.
END.
ON LEAVE OF file-name IN FRAME Dialog-Frame
DO:
    ASSIGN file-name.
    IF SEARCH( file-name ) <> ? AND SEARCH( file-name ) <> "":U THEN DO:
        ASSIGN FILE-INFO:FILE-NAME = file-name.
        IF FILE-INFO:FULL-PATHNAME <> ? THEN ASSIGN file-name = FILE-INFO:FULL-PATHNAME.
        DISP file-name WITH FRAME Dialog-Frame.
    END.
    APPLY "TAB":U TO file-name IN FRAME Dialog-Frame.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   message  "Импорт из Excel данных по товарам." skip
           "При импорте используется работа с Excel, поэтому не прерывайте работу Excel и не нарушайте уже установленную связь!"
           skip "Продолжать ?"
           view-as alert-box question buttons ok-cancel update v-ok .
   if v-ok <> TRUE THEN DO:
       return no-apply.
   END.
   message  "Прежде чем продолжить работу данной программы убедитесь, что в файле, который вы ":U skip
            "хотите закачать в ТН, колонка, содержащая АРТИКУЛ, была отформатирована как числовая ":U SKIP
            "без десятичных знаков. В случае если артикул будет состоять из одних цифр, например 111011,":U SKIP
             "в ТН он закачается как 111011.00. ":U
           skip "Продолжать ?":U
           view-as alert-box WARNING  buttons OK-CANCEL TITLE "В Н И М А Н И Е" update v-ok .
   if v-ok <> TRUE THEN DO:
       return no-apply.
   END.
   find first buf_sys-ctrl.
   if buf_sys-ctrl.db-num <> 0 then do:
     message "Данная утилита может работать только в ГБД.". PAUSE.
     return.
   end.
   find first buf_gds-prt no-lock
    where buf_gds-prt.root      = YES
      and buf_gds-prt.node-name = i-scale
   no-error.
   if not available buf_gds-prt then do:
       message "Нет шкалы " i-scale. pause.
       return.
   END.
   find first buf_gds-grp no-lock
    where buf_gds-grp.lvl-num   = buf_gds-grp.upper-code
      and buf_gds-grp.node-name = i-grp-name
   no-error.
   if not avail buf_gds-grp then do:
       message "Нет группы " i-grp-name. pause.
       return.
   END.
   find first buf_clients no-lock
    where buf_clients.obj-type = i-cli-type
      and buf_clients.obj-code = i-cli-code
   no-error.
   if not available buf_clients then do:
       message "Нет клиента " i-cli-type i-cli-code. pause.
       return.
   END.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY file-name Tumbler
      WITH FRAME Dialog-Frame.
  ENABLE file-name B-file Tumbler Btn_OK Btn_Cancel
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-imp-goods :
define input  parameter p-mode      as character            no-undo .
define input  parameter p-gds-code  like ub.goods.gds-code  no-undo .
   if p-mode <> 'ДОБАВЛЕНИЕ':U and p-mode <> 'ИЗМЕНЕНИЕ':U then do:
    message
      "Неверное значение параметра p-mode в процедуре proc-imp-goods = " p-mode
    view-as alert-box error.
    return.
   end.
   do transaction:
            if p-mode = 'ДОБАВЛЕНИЕ':U then do :
              run ref/dtaxgdss.p ( input no
                                 , input "шт":U
                                 , input buf_gds-grp.node-code
                                 , input ?
                                 , input ?
                                 , input v-cntxt-host-code-obj
                                 , input v-cntxt-obj-type
                                 , input v-cntxt-obj-code
                                 ).
            end.
            run ref/goods01.p (
                  input parparentproc
                , input p-mode
                , input no
                , input 0
                , input no
                , input yes
                , input no
                , input no
                , input yes
                , input v-cntxt-host-code-obj
                , input v-cntxt-obj-type
                , input v-cntxt-obj-code
                , input yes
                , input ?
                , input p-gds-code
                , input i-artic
                , input i-cli-type
                , input i-cli-code
                , input buf_gds-prt.node-code
                , input buf_gds-grp.node-code
                , input i-name
                , input ""
                , input I-Eng-Name
                , input i-name
                , input replace( replace( i-name, chr( 39 ), "" ), chr( 34 ), "" )
                , input i-city
                , input "шт"
                , input "шт"
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
                , input ""
                , input ""
                , input ""
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
                    skip string(
                                if p-mode = 'ДОБАВЛЕНИЕ':U then "Ошибка создания карточки товара.":U
                                else "Ошибка редактирования карточки товара.":U
                               )
                    skip return-value
                    skip i-artic
                    skip trim(error-status :get-message(1))
                         trim(error-status :get-message(2))
                         trim(error-status :get-message(3))
                view-as alert-box error.
            end.
            ELSE
               ASSIGN
                  impc-save = impc-save + 1.
   end.
END PROCEDURE.
PROCEDURE proc-imp-price :
  define buffer buf_price-list for ub.price-list.
do
on error undo, return error return-value
:
  find buf_price-list
    where buf_price-list.doc-num    = i-doc-num       and
          buf_price-list.price-type = ""              and
          buf_price-list.b-code     = buf_bar-code.b-code
  no-error.
  if available buf_price-list then do:
    next.
  end.
  else do:
    create buf_price-list.
    assign
      buf_price-list.doc-num     = i-doc-num
      buf_price-list.b-code      = buf_bar-code.b-code
      buf_price-list.artic       = buf_goods.artic
      buf_price-list.prod-type   = buf_goods.prod-type
      buf_price-list.prod-code   = buf_goods.prod-code
      buf_price-list.main-price  = yes
      buf_price-list.calc-method = 'Отсутствует':U
      buf_price-list.obj-code    = buf_price-doc.obj-code
      buf_price-list.obj-type    = buf_price-doc.obj-type
    .
  end.
  assign
    buf_price-list.price-sale = dec(I-Price)
    impc-save = impc-save + 1
  .
end.
END PROCEDURE.
