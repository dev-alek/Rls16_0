define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "загрузка товара для КАНРУ".
define input  parameter file-name as char no-undo .
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
def new shared var vattaxcd as integer no-undo.
def new shared var slttaxcd as integer no-undo.
define variable text-string as char no-undo.
define variable impc as integer No-UNDO.
define variable imp-save as integer No-UNDO.
define variable i-artic as char no-undo.
define variable i-scale as char no-undo.
define variable i-name as char no-undo.
define variable i-unit-name as char no-undo.
define variable i-VAT-code AS integer NO-UNDO.
define variable i-NP-code AS integer NO-UNDO.
define variable i-grp as integer no-undo.
define variable i-gds-code like ub.goods.gds-code NO-UNDO.
define variable j-gds-code like ub.goods.gds-code NO-UNDO.
define variable i-grp-code AS integer NO-UNDO.
define variable i-grp-name as char no-undo.
define variable i-city as char init ? no-undo.
DEFINE VARIABLE var-bc-code as integer no-undo .
define buffer buf-goods for ub.goods.
define buffer buf_bar-code for ub.bar-code.
define variable i-prod-bc as character no-undo.
define variable v_os-file as character no-undo.
define variable prt-name as character no-undo.
define variable rt as recid NO-UNDO.
define variable tax-rate-rid as character no-undo init "".
define variable taxvalue like ub.tax-rate-value.rate-value no-undo.
define temp-table tbl-grp no-undo
field Num-grp    as int
field Name-grp  as char
field Short-Name-grp  as char
field code like ub.gds-grp.node-code
index pi is unique primary
Num-grp.
define variable grp-full as character no-undo .
define variable N-grp as integer no-undo .
def buffer buf_grp for ub.gds-grp.
def buffer buf_prt for ub.gds-prt.
define variable i-color as char no-undo.
define variable i-size as char no-undo.
define variable add-scale as log no-undo.
define variable reply as log no-undo.
define variable NDS-code like  ub.tax-rate-value.rate-value  no-undo .
define variable NP-code  like  ub.tax-rate-value.rate-value init ? no-undo .
define variable  log-save as log no-undo.
def temp-table ld no-undo
field num  as integer
field ord  as integer
field name like ub.gds-prt.node-name
index name is primary unique name .
define buffer buf_clients for ub.clients.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "Выполнить"
     SIZE 15 BY 1.13
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "Выход"
     SIZE 15 BY 1.13
     BGCOLOR 8 .
DEFINE BUTTON Imly-City
     LABEL "Страна"
     SIZE 10.5 BY 1.2.
DEFINE BUTTON Imply-Cli
     LABEL "Производитель"
     SIZE 14.1 BY 1.13.
DEFINE VARIABLE city1 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.9 BY 1.2
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE city2 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 48.5 BY 1.2
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE Cli-code AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 8.9 BY 1.13
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE Cli-Name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 34.5 BY 1.13
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE Cli-type AS CHARACTER FORMAT "X(8)":U
      VIEW-AS TEXT
     SIZE 4.6 BY 1.13
     BGCOLOR 15  NO-UNDO.
DEFINE FRAME Dialog-Frame
     Imply-Cli AT ROW 2.27 COL 1
     Imly-City AT ROW 5.5 COL 1
     b-exit AT ROW 7.27 COL 11
     b-quit AT ROW 7.27 COL 43
     Cli-code AT ROW 2.27 COL 14 COLON-ALIGNED NO-LABEL
     Cli-type AT ROW 2.27 COL 23.5 COLON-ALIGNED NO-LABEL
     Cli-Name AT ROW 2.27 COL 28.5 COLON-ALIGNED NO-LABEL
     city1 AT ROW 5.5 COL 10 COLON-ALIGNED NO-LABEL
     city2 AT ROW 5.5 COL 14.5 COLON-ALIGNED NO-LABEL
     "       Не обязательные параметры подставляемые по умолчанию" VIEW-AS TEXT
          SIZE 64 BY 1 AT ROW 4 COL 1
          BGCOLOR 8 FGCOLOR 0
     "                         Необходимо указать" VIEW-AS TEXT
          SIZE 64 BY .93 AT ROW 1 COL 1
          BGCOLOR 8 FGCOLOR 0
     SPACE(0.00) SKIP(6.64)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Импорт товаров из текстового файла"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
define variable v-rate-value as decimal no-undo .
define variable v-is-new as logical no-undo .
define variable v-b-str as character no-undo .
define variable v-rid as recid no-undo .
define buffer buf_goods for ub.goods.
define buffer buf_gds-grp for ub.gds-grp.
define buffer buf_gds-prt for ub.gds-prt.
define buffer buf_tax-rate for ub.tax-rate.
define buffer buf_lvl-name for ub.lvl-name.
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_bar-code for ub.bar-code.
if cli-code = 0 then do:
  message "Не задан производитель "
  view-as alert-box ERROR.
  return no-apply.
end.
if trim(file-name) = "" then do:
  message "Не задан файл для импорта "
  view-as alert-box ERROR.
  return no-apply.
end.
for each buf_gds-grp  no-lock:
find first buf_grp where
          buf_grp.upper-code = buf_gds-grp.node-code no-lock no-error.
if avail buf_grp then next.
 run grplib-get-full-name in this-procedure ( input buf_gds-grp.node-code
                                             ,output grp-full).
 if index(buf_gds-grp.node-name, "-") = 0 then do:
   message
  "Существуют группы товаров которые начинаются не с номера в начале названия," skip
  "в начале названия должен стоять номер и символ -" skip
   buf_gds-grp.node-name  skip
   view-as alert-box ERROR   .
   return no-apply.
 end.
 N-grp = integer(substring(buf_gds-grp.node-name, 1, index(buf_gds-grp.node-name, "-") - 1)).
 find first tbl-grp where tbl-grp.num-grp = n-grp no-lock no-error.
 if not avail tbl-grp then do:
    create tbl-grp.
    assign
    tbl-grp.num-grp = n-grp
    tbl-grp.name-grp = grp-full
    tbl-grp.Short-Name-grp = buf_gds-grp.node-name
    tbl-grp.code = buf_gds-grp.node-code.
  end.
  else do:
    message
    "Существуют группы товаров с одинаковым номером " N-grp " в начале названия" skip
    buf_gds-grp.node-name  skip
    tbl-grp.Short-Name-grp  skip
    "В одном из них измените начальный номер на другой. "
     view-as alert-box ERROR   .
     return no-apply.
  end.
end.
add-scale = false.
input stream imp from value (file-name) .
repeat:
  IMPORT stream imp UNFORMATTED text-string  .
  if trim(text-string) = "" then   leave.
  impc = impc + 1.
  if num-entries (text-string, ";") <> 11 then do:
    OUTPUT stream Err TO value ("Imp_goods.err") append.
    put stream Err unformatted
    string(today, "99/99/9999") " "
    string(time, "HH:MM")
    " Неправильное число параметров в строке, должно быть 10, в конце строки должен стоять знак ;" skip.
    export stream  Err text-string .
    output stream Err close.
   next.
  end.
  assign
  i-artic          = ENTRY( 1, text-string, ";")
  i-name        = ENTRY( 2, text-string, ";")
  i-unit-name = ENTRY( 3, text-string, ";")
  i-grp            = integer(ENTRY( 4, text-string, ";"))
  i-vat-code    = integer(ENTRY(5, text-string, ";"))
  i-NP-code      = integer(ENTRY(6, text-string, ";"))
  i-prod-bc       = ENTRY(8, text-string, ";")
  log-save      = false
  .
    i-scale  = "/".
    overlay ( i-artic, r-index(i-artic, "-"), 1) = i-scale.
    i-scale = substring( i-artic, r-index(i-artic, "-") + 1 ).
    i-artic = substring( i-artic, 1, r-index(i-artic, "-") - 1 ).
    display
    impc  label "Прочитано"
    imp-save label "Сохранено"
    i-artic format "x(10)" label "Артикул"
    text-string format "x(40)" label "Строка файла"
    with frame ff view-as dialog-box
    title ": Импорт справочника товаров из файла".
    pause 0.
    if i-unit-name = "th" then do:
      i-unit-name = "шт".
    end.
    else  do:
      OUTPUT stream Err TO value ("Imp_goods.err") append.
      put stream Err unformatted
      string(today, "99/99/9999") " "
      string(time, "HH:MM")
      " Неизвестная единица измерения товара" skip.
      export stream  Err text-string .
      output stream Err close.
      next.
    end.
    find first tbl-grp where
             tbl-grp.num-grp = i-grp no-lock no-error.
    if not avail tbl-grp then do:
      OUTPUT stream Err TO value ("Imp_goods.err") append.
      put stream err unformatted
      string(today, "99/99/9999") " "
      string(time, "HH:MM")
      " Группа к которой хотят привезать товар отсутствует в БД" skip.
      export stream  err text-string .
      output stream err close.
      next.
    end.
    _tax-rate:
    for each buf_tax-rate no-lock where
            buf_tax-rate.tax-code = integer('1':U):
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftaxval in g#library
  (input  ?
  ,input  buf_tax-rate.tax-code
  ,input  buf_tax-rate.rate-code
  ,input  ?
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-rate-value
  ) no-error .
      if not error-status:error then do:
        if v-rate-value = i-vat-code then do:
          leave.
        end.
      end.
    end.
    if not avail buf_tax-rate then do:
      OUTPUT stream Err TO value ("Imp_goods.err") append.
      put stream err unformatted
      string(today, "99/99/9999") " "
      string(time, "HH:MM")
      substitute(" Ставка НДС с таким процентом (&1) отсутствует в БД", i-vat-code) skip.
      export stream  err text-string .
      output stream err close.
      next.
    end.
    else  do:
      NDS-code = buf_tax-rate.rate-code.
    end.
    _tax-rate:
    for each buf_tax-rate no-lock where
            buf_tax-rate.tax-code = integer('2':U):
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftaxval in g#library
  (input  ?
  ,input  buf_tax-rate.tax-code
  ,input  buf_tax-rate.rate-code
  ,input  ?
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-rate-value
  ) no-error .
      if not error-status:error then do:
        if v-rate-value = i-np-code then do:
          leave.
        end.
      end.
    end.
    if not avail buf_tax-rate then do:
      OUTPUT stream Err TO value ("Imp_goods.err") append.
      put stream err unformatted
      string(today, "99/99/9999") " "
      string(time, "HH:MM")
      substitute(" Ставка НП с таким процентом (&1) отсутствует в БД", i-np-code) skip.
      export stream  err text-string .
      output stream err close.
      next.
    end.
    else  do:
      NP-code = buf_tax-rate.rate-code.
    end.
    find first buf_prt where
          buf_prt.root    = no and
          buf_prt.f-name = i-scale  no-lock no-error.
    if not avail buf_prt then do:
      i-color = substring( i-scale, 1, r-index(i-scale, "/") - 1 ).
      i-size = substring( i-scale, r-index(i-scale, "/") + 1 ).
      find first buf_prt where
              buf_prt.root    = no and
              buf_prt.node-name = i-color  no-lock no-error.
      if not avail buf_prt then do:
         run add-color in this-procedure  ( input i-color
                                          , output reply ).
         if reply = false then do:
            OUTPUT stream Err TO value ("Imp_goods.err") append.
            put stream err unformatted
            string(today, "99/99/9999") " "
            string(time, "HH:MM")
            " Такая шкала отсутствует в БД" skip.
            export stream  err text-string .
            output stream err close.
            next.
         end.
       add-scale = true.
       end.
       find first buf_prt where
                buf_prt.root    = no
            and buf_prt.node-name = i-size  no-lock no-error.
       if not avail buf_prt then do:
         run add-size in this-procedure  ( input i-size
                                          , output reply ).
         if reply = false then do:
            OUTPUT stream Err TO value ("Imp_goods.err") append.
            put stream err unformatted
            string(today, "99/99/9999") " "
            string(time, "HH:MM")
            " Такая шкала отсутствует в БД" skip.
            export stream  err text-string .
            output stream err close.
            next.
          end.
          add-scale = true.
        end.
    end.
    if  trim(city1) <> "" then  i-city = city1 .
    find first buf_lvl-name no-lock no-error.
    find first buf_gds-prt where
          buf_gds-prt.prt-root  = buf_lvl-name.upper-code
      and buf_gds-prt.is-term   = no
      and buf_gds-prt.upper-code = buf_lvl-name.upper-code
    no-lock no-error.
    if not avail buf_gds-prt then do:
      OUTPUT stream Err TO value ("Imp_goods.err") append.
      put stream err unformatted
      string(today, "99/99/9999") " "
      string(time, "HH:MM")
      " Корневая шкала не найдена" skip.
      export stream  err text-string .
      output stream err close.
      next.
    end.
    find first buf_goods where
               buf_goods.artic = i-artic
          and  buf_goods.prod-type = cli-type
          and  buf_goods.prod-code = cli-code
    no-lock no-error.
    if not avail buf_goods then do:
      do transaction:
        run ref/dtaxgdss.p (
              input no
            , input   i-unit-name
            , input   buf_gds-prt.node-code
            , input ?
            , input ?
            , input    v-cntxt-host-code-obj
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
            , input no
            , input no
            , input yes
            , input v-cntxt-host-code-obj
            , input v-cntxt-obj-type
            , input v-cntxt-obj-code
            , input yes
            , input ?
            , input 0
            , input i-artic
            , input cli-type
            , input cli-code
            , input buf_gds-prt.node-code
            , input tbl-grp.code
            , input i-name
            , input ""
            , input i-name
            , input i-name
            , input replace( replace( i-name, chr( 39 ), "" ), chr( 34 ), "" )
            , input i-city
            , input i-unit-name
            , input i-unit-name
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
            , input 0
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
  find first buf_goods where
            buf_goods.artic = i-artic
      and  buf_goods.prod-type = cli-type
      and  buf_goods.prod-code = cli-code
  no-lock no-error.
  if not avail buf_goods then do:
    OUTPUT stream Err TO value ("Imp_goods.err") append.
      put stream Err unformatted
        string(today, "99/99/9999") " "
        string(time, "HH:MM")
        " Нет такого товара" skip.
      export stream  Err text-string .
    output stream Err close.
  end.
  find first buf_prod-bc where
            buf_prod-bc.b-str  = i-prod-bc no-lock no-error.
  if  not avail buf_prod-bc then do:
    find first buf_gds-prt where
        buf_gds-prt.prt-root = buf_lvl-name.upper-code and
        buf_gds-prt.f-name = i-scale  no-lock no-error.
    if  avail buf_gds-prt then do:
      do transaction  :
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run barcodcr in g#library
  (input  buf_goods.gds-code
  ,input  buf_gds-prt.node-code
  ,input  ''
  ,input  ''
  ,input  buf_goods.unit-base
  ,input  1
  ,output v-is-new
  ,buffer buf_bar-code
  ) no-error .
        v-b-str = i-prod-bc.
        run trg/prod-bc1.p (
                           input parparentproc
                          ,input yes
                          ,input yes
                          ,input yes
                          ,input no
                          ,input ''
                          ,input ''
                          ,buffer buf_goods
                          ,input buf_bar-code.b-code
                          ,input-output v-b-str
                          ,output v-rid
                           ) no-error .
         if not error-status:error then do:
           log-save = true.
         end.
         else do:
            OUTPUT stream Err TO value ("Imp_goods.err") append.
            put stream err unformatted
            string(today, "99/99/9999") " "
            string(time, "HH:MM")
            substitute("Ошибка при сохранении ДопБК:&1&2&1&3", chr(10), error-status:get-message(1) , return-value ) skip.
            export stream  err text-string .
            output stream err close.
         end.
        end.
      end.
      else do:
        OUTPUT stream Err TO value ("Imp_goods.err") append.
        put stream err unformatted
        string(today, "99/99/9999") " "
        string(time, "HH:MM")
        " Такая шкала отсутствует в БД" skip.
        export stream  err text-string .
        output stream err close.
    end.
  end.
  else do:
    OUTPUT stream Err TO value ("Imp_goods.err") append.
    put stream err unformatted
    string(today, "99/99/9999") " "
    string(time, "HH:MM")
    " Такой Доп-БК уже существует в БД" skip.
    export stream  err text-string .
    output stream err close.
  end.
  if   log-save = true then imp-save = imp-save + 1.
end.
input stream imp close.
message
substitute("Импорт из файла &1 закончен, прочитано &2, сохранено &3&4" +
           "Все строки из файла которые не удалось импортировать можно посмотреть в файле Imp_goods.err "
           , file-name
           , impc
           , imp-save
           , chr(10)
)
view-as alert-box  INFORMATION.
END.
ON CHOOSE OF Imly-City IN FRAME Dialog-Frame
DO:
define variable v-rid-list as character no-undo .
define buffer buf_country for ub.country.
run ref/countris.w ( input parparentproc
                    ,input "b-sel"
                    ,input-output v-rid-list ).
if v-rid-list <> '' then     do:
 FIND first buf_country no-lock WHERE
         recid (buf_country) = integer(v-rid-list) no-error.
 if avail buf_country then
  assign
  city1 = buf_country.alpha1
  city2  =  buf_country.long-name
  .
  display
  city1
  city2
  with frame Dialog-Frame.
end.
END.
ON CHOOSE OF Imply-Cli IN FRAME Dialog-Frame
DO:
define variable ref-list as character no-undo .
define variable ref-rec as recid no-undo .
  run ref/cli-all.w ( input parparentproc
                     ,input "b-sel"
                     ,input 'орг':U
                     ,input ?
                     ,input ?
                     ,input ?
                     ,input ?
                     ,input ?
                     ,output  ref-list).
 ref-rec = integer (ref-list).
if  ref-rec <> ? then do:
  FIND first buf_clients no-lock WHERE recid (buf_clients) = ref-rec NO-error.
  if avail buf_clients then do:
    assign
    Cli-type = buf_clients.obj-type
    Cli-code = buf_clients.obj-code
    Cli-name = buf_clients.obj-name .
  end.
  display
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
  FIND first buf_clients no-lock WHERE
            buf_clients.obj-type = 'орг':U
        and buf_clients.obj-code = 8 no-error.
  if avail buf_clients then do:
    assign
    Cli-type = buf_clients.obj-type
    Cli-code = buf_clients.obj-code
    Cli-name = buf_clients.obj-name .
    display
    Cli-type
    Cli-code
    Cli-name
    with frame Dialog-Frame.
  end.
  else do:
    enable
    Imply-Cli
    with frame Dialog-Frame.
  end.
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE add-color :
define input  parameter new-scale like ub.gds-prt.f-name no-undo .
define output parameter reply  as log no-undo .
define buffer buf-gds-prt-1  for ub.gds-prt.
define buffer buf-gds-prt-2  for ub.gds-prt.
define buffer buf_gds-prt for ub.gds-prt.
define buffer buf_lvl-name for ub.lvl-name.
define variable u-c like ub.gds-prt.upper-code no-undo.
define variable p-n like ub.gds-prt.prt-num no-undo.
define variable n-c like ub.gds-prt.node-code no-undo.
define variable p-r like ub.gds-prt.prt-root no-undo.
for each ld :
  delete ld.
end.
reply = false.
for each buf_gds-prt where
      buf_gds-prt.upper-code = 4 and
      buf_gds-prt.node-name <> buf_gds-prt.f-name and
      buf_gds-prt.is-term = yes
no-lock:
    find first ld where
             ld.name = buf_gds-prt.node-name no-lock no-error.
    if not avail ld then do:
        create ld.
        assign
        ld.name = buf_gds-prt.node-name
        ld.num  = buf_gds-prt.prt-num
        .
    end.
end.
find first buf_lvl-name no-lock no-error.
if not avail buf_lvl-name then do:
  reply = false.
  return.
end.
find buf_gds-prt where
      buf_gds-prt.upper-code = buf_lvl-name.upper-code and
      buf_gds-prt.prt-num    = 0
no-lock no-error.
if not avail buf_gds-prt then do:
  reply = false.
  return.
end.
u-c = buf_gds-prt.node-code .
find last buf_gds-prt  no-lock use-index pi no-error.
if not avail buf_gds-prt then do:
  reply = false.
  return.
end.
n-c = buf_gds-prt.node-code.
find last buf_gds-prt no-lock  where
         buf_gds-prt.upper-code =  u-c
use-index level no-error.
if not avail buf_gds-prt then do:
  reply = false.
  return.
end.
p-n = buf_gds-prt.prt-num.
do transaction:
  create buf-gds-prt-1.
  assign
  buf-gds-prt-1.node-code   =  n-c + 1
  buf-gds-prt-1.upper-code  = u-c
  buf-gds-prt-1.node-name    = new-scale
  buf-gds-prt-1.prt-num     = p-n + 1
  buf-gds-prt-1.root        = no
  buf-gds-prt-1.lvl-num     = ub.lvl-name.level
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
    buf-gds-prt-2.f-name      = trim(buf-gds-prt-1.f-name) + "/" + trim(ld.name)
    buf-gds-prt-2.is-term     = yes
    buf-gds-prt-2.prt-root    = lvl-name.upper-code
    .
    n-c = n-c + 1.
  end.
  reply = true.
end.
END PROCEDURE.
PROCEDURE add-size :
define input  parameter new-scale like ub.gds-prt.f-name no-undo .
define output parameter reply  as log no-undo .
define buffer buf_gds-prt for ub.gds-prt.
define buffer buf-gds-prt-1  for ub.gds-prt.
define buffer buf-gds-prt-2  for ub.gds-prt.
define buffer buf_lvl-name for ub.lvl-name.
define variable u-c like ub.gds-prt.upper-code no-undo.
define variable p-n like ub.gds-prt.prt-num no-undo.
define variable n-c like ub.gds-prt.node-code no-undo.
define variable p-r like ub.gds-prt.prt-root no-undo.
for each ld :
  delete ld.
end.
reply = false.
p-n = 0.
find last buf_gds-prt no-lock where
    buf_gds-prt.upper-code = 4 use-index level no-error.
if not avail buf_gds-prt then do:
  reply = false.
  return.
end.
p-n = buf_gds-prt.prt-num.
for each buf_gds-prt where
    buf_gds-prt.upper-code = 3
and buf_gds-prt.node-name = buf_gds-prt.f-name
and buf_gds-prt.is-term = no
no-lock:
  find first ld where
     ld.name = buf_gds-prt.node-name no-lock no-error.
  if not avail ld then do:
    create ld.
    assign
    ld.name = buf_gds-prt.node-name
    ld.num    = buf_gds-prt.prt-num
    ld.ord     = buf_gds-prt.node-code
    .
  end.
end.
find first buf_lvl-name no-lock no-error.
if not avail buf_lvl-name then do:
  reply = false.
  return.
end.
find last buf_gds-prt  no-lock use-index pi no-error.
if not avail buf_gds-prt then do:
  reply = false.
  return.
end.
n-c = buf_gds-prt.node-code.
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
    buf-gds-prt-1.prt-root     = buf_lvl-name.upper-code
      .
    n-c = n-c + 1.
    reply = true.
  end.
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY Cli-code Cli-type Cli-Name city1 city2
      WITH FRAME Dialog-Frame.
  ENABLE Imly-City b-exit b-quit Cli-code Cli-type Cli-Name city1 city2
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
