block-level on error undo, throw.
define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-silent as logical   no-undo .
define input  parameter dif-pdbc as logical no-undo initial no.
define input  parameter pbc-veto  as logical no-undo.
define input  parameter send-ref as logical   no-undo .
define input  parameter p-cdrg-type as character no-undo .
define input  parameter p-ean-type as character no-undo .
define parameter buffer buf_goods for ub.goods.
define input  parameter p-b-code as integer   no-undo .
define input  parameter p-nedeMark as logical   no-undo .
define input-output  parameter p-b-str as character no-undo .
define output parameter p-recid as recid no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сохранение ДопБК".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function is-numeral return logical
  (input p-string   as character ,
   input char-avail as character) :
  define variable p-replace-string as character no-undo .
  define variable log-result       as logical  no-undo .
  if p-string = ? then
    return false .
  p-replace-string = p-string.
  if lookup ("*", char-avail) > 0 then
      p-replace-string = replace (p-replace-string, '*', '9').
  if lookup ("digit", char-avail) > 0 then
    assign
      p-replace-string = replace (p-replace-string, '0', '9')
      p-replace-string = replace (p-replace-string, '1', '9')
      p-replace-string = replace (p-replace-string, '2', '9')
      p-replace-string = replace (p-replace-string, '3', '9')
      p-replace-string = replace (p-replace-string, '4', '9')
      p-replace-string = replace (p-replace-string, '5', '9')
      p-replace-string = replace (p-replace-string, '6', '9')
      p-replace-string = replace (p-replace-string, '7', '9')
      p-replace-string = replace (p-replace-string, '8', '9')
      .
  else
     p-replace-string = replace (p-replace-string, '9', chr(15))
      .
  if lookup ("letter", char-avail) > 0 then
    assign
      p-replace-string = replace (p-replace-string, 'A', '9')
      p-replace-string = replace (p-replace-string, 'B', '9')
      p-replace-string = replace (p-replace-string, 'C', '9')
      p-replace-string = replace (p-replace-string, 'D', '9')
      p-replace-string = replace (p-replace-string, 'E', '9')
      p-replace-string = replace (p-replace-string, 'F', '9')
      p-replace-string = replace (p-replace-string, 'G', '9')
      p-replace-string = replace (p-replace-string, 'H', '9')
      p-replace-string = replace (p-replace-string, 'I', '9')
      p-replace-string = replace (p-replace-string, 'J', '9')
      p-replace-string = replace (p-replace-string, 'K', '9')
      p-replace-string = replace (p-replace-string, 'L', '9')
      p-replace-string = replace (p-replace-string, 'M', '9')
      p-replace-string = replace (p-replace-string, 'N', '9')
      p-replace-string = replace (p-replace-string, 'O', '9')
      p-replace-string = replace (p-replace-string, 'P', '9')
      p-replace-string = replace (p-replace-string, 'Q', '9')
      p-replace-string = replace (p-replace-string, 'R', '9')
      p-replace-string = replace (p-replace-string, 'S', '9')
      p-replace-string = replace (p-replace-string, 'T', '9')
      p-replace-string = replace (p-replace-string, 'U', '9')
      p-replace-string = replace (p-replace-string, 'V', '9')
      p-replace-string = replace (p-replace-string, 'W', '9')
      p-replace-string = replace (p-replace-string, 'X', '9')
      p-replace-string = replace (p-replace-string, 'Y', '9')
      p-replace-string = replace (p-replace-string, 'Z', '9')
      p-replace-string = replace (p-replace-string, '_', '9')
      .
  return p-replace-string = fill ('9', length (p-string)).
end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure gds-attr-name :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-name in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-value :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-write :
  define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define input parameter p-value    like ub.goods-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-write in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-exist :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-delete :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy-to :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy-to in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-ptrl-divis :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-ptrl-divis in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-glob-sum-grps :
  define input  parameter p-mode        as character no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input-output parameter p-value as integer no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-glob-sum-grps in g#attr-lib
      (input p-mode
      ,input p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-ptrl-densities :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-ptrl-densities in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-CommodityCode :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-CommodityCode in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-office-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-office-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-mark-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-mark-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-emrc-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-emrc-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-group-np :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-group-np in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-item-matter-mark :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-item-matter-mark in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-type-method-calc :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-type-method-calc in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-is-loyalty-payment :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-is-loyalty-payment in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-15x80 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-15x80 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-8x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-8x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-6x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-6x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-manual-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-batch-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-energy-value :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-energy-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-set-dt-seasons :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-can-set  as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-set-dt-seasons in g#attr-lib
      (input  p-gds-code
      ,output p-can-set
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isExemplarGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isExemplarGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isVolumArticGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isVolumArticGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable glog as logical   no-undo .
define variable v-on as logical   no-undo .
define variable v-code as integer   no-undo .
define variable v-mess as character no-undo .
define variable v-b-str as character no-undo .
define variable add-on as logical   no-undo .
define variable dopi as integer   no-undo .
define variable bar_code as character no-undo .
define variable v-b-code as integer   no-undo .
define variable f-sc-code as integer   no-undo .
define variable v-empty-scale as logical no-undo .
define variable v-is-weight as logical no-undo .
define variable v-is-pgweight as logical no-undo .
define variable v-is-global as logical no-undo .
define variable dopst as character no-undo .
define variable par-bc-pfx  as character no-undo.
define variable par-pl-pfx  as character no-undo.
define variable par-bc-frmt as character no-undo.
define variable par-pl-frmt as character no-undo.
define variable v-param-type                as character                no-undo.
define variable v-value-character           as character                no-undo.
define variable v-value-date                as date                     no-undo.
define variable v-value-decimal             as decimal                  no-undo.
define variable v-value-integer             as INTEGER                  no-undo.
define variable v-value-logical             AS LOGICAL                  no-undo.
define variable v-tth                       as handle                   no-undo.
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_prod-bc-attr for ub.prod-bc-attr.
define buffer buf2_prod-bc for ub.prod-bc.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_units for ub.units.
define buffer u-base for ub.units.
define buffer buf_code-range for ub.code-range.
define buffer dubl_prod-bc for ub.prod-bc .
define buffer same-prod-bc for ub.prod-bc.
define buffer same-bar-code for ub.bar-code.
define buffer same-goods for ub.goods.
define buffer same-gds-prt  for ub.gds-prt.
  find first buf_bar-code no-lock where
            buf_bar-code.b-code = p-b-code no-error.
  if not available buf_bar-code then do:
    v-mess = substitute("Не найден бар-код &1, к которому добавляется ДопБК &2"
                       , p-b-code
                       , p-b-str).
    run err-mess in this-procedure ( input-output v-mess).
    undo, return error (if p-silent then v-mess else '').
  end.
  if buf_bar-code.gds-code <> buf_goods.gds-code then do:
    v-mess = substitute("&1 Неверно заданы параметры: товара с кодом  &2, бар-код &3 для товара с кодом &4"
                       , vss-workfile
                       , buf_goods.gds-code
                       , buf_bar-code.b-code
                       , buf_bar-code.gds-code).
    run err-mess in this-procedure ( input-output v-mess).
    undo, return error (if p-silent then v-mess else '').
  end.
  find buf_units no-lock where
       buf_units.unit-name = buf_bar-code.unit-cli .
  find u-base no-lock where
       u-base.unit-name = buf_goods.unit-base  .
  if  lookup( 'сте':U, u-base.type ) > 0
  and buf_goods.unit-base <> buf_bar-code.unit-cli
  then do:
    v-mess = substitute( "Нельзя создать код для неосновной единицы измерения&1" +
                         "к товару, у которого основная единица измерения типа &2"
                         , chr(10)
                         ,'сте':U).
    run err-mess in this-procedure ( input-output v-mess).
    undo, return error (if p-silent then v-mess else '').
  end.
  if dif-pdbc = ? then do:
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
  end.
  if pbc-veto = ? then do:
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
  end.
  define variable v-attr-sale-trk as character no-undo .
  define variable v-attr-type as character no-undo .
  run gds-attr-value in this-procedure (
                               input buf_goods.gds-code
                              ,input 'ptrl-as-good':U
                              ,output v-attr-sale-trk
                              ,output v-attr-type) no-error.
  case p-cdrg-type:
    when 'sclc':U then do:
      if lookup('вес':U, u-base.type) = 0 then do:
        v-mess = substitute("Локальный весовой код можно создать только для товара, у которого основная единица измерения ВЕСОВАЯ").
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
      end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output v-b-code
  )  .
      if v-b-code <> p-b-code then do:
        v-mess = substitute("Локальный весовой код можно создать только для ГЛАВНОГО бар-кода товара").
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
      end.
      if p-b-str <> ''
      and p-b-str <> ? then do:
        assign
        v-is-weight = no
        v-is-global = ?
        .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbctv in g#library
  (input p-b-str
  ,input  buf_bar-code.unit-cli
  ,input  buf_goods.unit-base
  ,input  'weight=request'
  ,output v-is-weight
  ) no-error .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbctv in g#library
  (input p-b-str
  ,input  buf_bar-code.unit-cli
  ,input  buf_goods.unit-base
  ,input  'global=request'
  ,output v-is-global
  ) no-error .
         if not (v-is-weight and (not v-is-global)) then do:
            v-mess = substitute("Заданный код &1 не является локальным весовым кодом", p-b-str).
            run err-mess in this-procedure ( input-output v-mess).
            undo, return error (if p-silent then v-mess else '').
         end.
      end.
      else do:
      assign
      f-sc-code = - 1
      .
      _sc-code:
      do while (v-code = 0 or v-code <> f-sc-code):
        assign
        f-sc-code = if f-sc-code = - 1
                    then v-code
                    else f-sc-code
        .
        run gen-b-code IN THIS-PROCEDURE (input 'sclc':U, output v-code) no-error.
        if v-code = 0
        or v-code = ?
        or error-status:error then do:
          v-mess = substitute("Не удалось создать глобальный весовой код&1&2&1&3"
                              , chr(10)
                              , error-status:get-message(1)
                              , return-value ).
          run err-mess in this-procedure ( input-output v-mess).
          return (if p-silent then v-mess else '').
        end.
        find first dubl_prod-bc No-lock where
                  dubl_prod-bc.b-str = string(v-code, '99999':U)
              AND  dubl_prod-bc.bc-on = yes no-error .
        if not avail dubl_prod-bc then do:
          assign
          f-sc-code = 0
          .
          LEAVE _sc-code.
        end.
      end.
      if v-code = f-sc-code then do:
        v-mess = substitute("Не удалось создать весовой код&1"  +
                            "Диапазоны локальных весовых кодов ПОЛНОСТЬЮ заняты&1"  +
                            "Выключите неиспользуемые локальные весовые коды&1"  +
                            "И повторите попытку"
                            ,chr(10)).
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
      end.
        p-b-str = string(v-code, "99999":U).
      end.
      if p-silent then do:
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer dub-prod-bc6 for ub.prod-bc.
FIND FIRST dub-prod-bc6 No-LOCK WHERE
            dub-prod-bc6.b-str = string(v-code, '99999':U) AND
            dub-prod-bc6.bc-on = yes No-error.
if avail dub-prod-bc6 then do:
   return error  ("Невозможно создать весовой код для товара" + chr(32) +
                  string(buf_goods.artic) + chr(32) +
                  string(buf_goods.prod-type) + chr(32) +
                  string(buf_goods.prod-code) + chr(10) +
                  "Уже имеется в БД товар с включенным дополнительным кодом равным" +
                   chr(32) +
                   dub-prod-bc6.b-str).
end.
      end.
      else do:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer dub-prod-bc7 for ub.prod-bc.
FIND FIRST dub-prod-bc7 No-LOCK WHERE
            dub-prod-bc7.b-str = string(v-code, '99999':U) AND
            dub-prod-bc7.bc-on = yes No-error.
if avail dub-prod-bc7 then do:
  message
  "Невозможно создать весовой или штучный код для весов для товара" skip
  buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
  "Уже имеется в БД товар с включенным дополнительным кодом равным"
   dub-prod-bc7.b-str
   view-as alert-box ERROR.
   return error '':U.
end.
      end.
      add-on = yes.
    end.
    when 'scgb':U then do:
      if lookup('вес':U, u-base.type) = 0 then do:
        v-mess = substitute("Глобальный весовой код можно создать только для товара, у которого основная единица измерения ВЕСОВАЯ").
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
      end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output v-b-code
  )  .
      if v-b-code <> p-b-code then do:
        v-mess = substitute("Глобальный весовой код можно создать только для ГЛАВНОГО бар-кода товара").
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
      end.
      if p-b-str <> ''
      and p-b-str <> ? then do:
        assign
        v-is-weight = no
        v-is-global = no
        .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbctv in g#library
  (input p-b-str
  ,input  buf_bar-code.unit-cli
  ,input  buf_goods.unit-base
  ,input  'weight=request'
  ,output v-is-weight
  ) no-error .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbctv in g#library
  (input p-b-str
  ,input  buf_bar-code.unit-cli
  ,input  buf_goods.unit-base
  ,input  'global=request'
  ,output v-is-global
  ) no-error .
         if not (v-is-weight and v-is-global) then do:
            v-mess = substitute("Заданный код &1 не является глобальным весовым кодом", p-b-str).
            run err-mess in this-procedure ( input-output v-mess).
            undo, return error (if p-silent then v-mess else '').
         end.
      end.
      else do:
      run trg/isvescod.p ( input p-b-code
                          ,input yes
                          ,input yes
                          ,input yes
                          ,input ""
                          ,output glog
                          ,output v-on
                          ,output v-b-str ) no-error.
      if error-status:error then undo, return error return-value .
      if glog and v-on then do:
        v-mess = substitute("У товара уже есть глобальный весовой код").
        run err-mess in this-procedure ( input-output v-mess).
        return (if p-silent then v-mess else '').
      end.
      run gen-b-code IN THIS-PROCEDURE (input 'scgb':U, output v-code) no-error.
      if v-code = 0
      or v-code = ?
      or error-status:error then do:
        v-mess = substitute("Не удалось создать глобальный весовой код&1&2&1&3"
                            , chr(10)
                            , error-status:get-message(1)
                            , return-value ).
        run err-mess in this-procedure ( input-output v-mess).
        return (if p-silent then v-mess else '').
      end.
        p-b-str = string(v-code, "99999":U).
      end.
        if p-silent then do:
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer dub-prod-bc10 for ub.prod-bc.
FIND FIRST dub-prod-bc10 No-LOCK WHERE
            dub-prod-bc10.b-str = string(v-code, '99999':U) AND
            dub-prod-bc10.bc-on = yes No-error.
if avail dub-prod-bc10 then do:
   return error  ("Невозможно создать весовой код для товара" + chr(32) +
                  string(buf_goods.artic) + chr(32) +
                  string(buf_goods.prod-type) + chr(32) +
                  string(buf_goods.prod-code) + chr(10) +
                  "Уже имеется в БД товар с включенным дополнительным кодом равным" +
                   chr(32) +
                   dub-prod-bc10.b-str).
end.
        end.
        else do:
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer dub-prod-bc11 for ub.prod-bc.
FIND FIRST dub-prod-bc11 No-LOCK WHERE
            dub-prod-bc11.b-str = string(v-code, '99999':U) AND
            dub-prod-bc11.bc-on = yes No-error.
if avail dub-prod-bc11 then do:
  message
  "Невозможно создать весовой или штучный код для весов для товара" skip
  buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
  "Уже имеется в БД товар с включенным дополнительным кодом равным"
   dub-prod-bc11.b-str
   view-as alert-box ERROR.
   return error '':U.
end.
        end.
      add-on = yes.
    end.
    when 'pglc':U then do:
      if lookup('шту':U, u-base.type) = 0 then do:
        v-mess = substitute("Локальный штучный код для весов можно создать только для товара, у которого основная единица измерения ШТУЧНАЯ").
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
      end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscdat in g#library
  (input  buf_goods.gds-code
  ,input  'empty-scale=request':u
  ,output v-empty-scale
  )  .
      if v-empty-scale = false then do:
        v-mess = substitute("Локальный штучный код для весов можно создать только для товара с пустой шкалой").
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
      end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output v-b-code
  )  .
      if v-b-code <> p-b-code then do:
        v-mess = substitute("Локальный штучный код для весов можно создать только для ГЛАВНОГО бар-кода товара").
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
      end.
      run trg/ispgwcod.p (
                          input p-b-code
                        ,input yes
                        ,input no
                        ,input yes
                        ,input ""
                        ,output glog
                        ,output v-on
                        ,output v-b-str ) no-error.
      if error-status:error then undo, return error return-value .
      if glog and v-on then do:
        v-mess = substitute("У товара уже есть локальный штучный код для весов").
        run err-mess in this-procedure ( input-output v-mess).
        return (if p-silent then v-mess else '').
      end.
      if p-b-str <> ''
      and p-b-str <> ? then do:
        assign
        v-is-pgweight = no
        v-is-global = ?
        .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbctv in g#library
  (input p-b-str
  ,input  buf_bar-code.unit-cli
  ,input  buf_goods.unit-base
  ,input  'pgweight=request'
  ,output v-is-pgweight
  ) no-error .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbctv in g#library
  (input p-b-str
  ,input  buf_bar-code.unit-cli
  ,input  buf_goods.unit-base
  ,input  'global=request'
  ,output v-is-global
  ) no-error .
         if not (v-is-pgweight and not (v-is-global)) then do:
            v-mess = substitute("Заданный код &1 не является локальным штучным кодов для весов", p-b-str).
            run err-mess in this-procedure ( input-output v-mess).
            undo, return error (if p-silent then v-mess else '').
         end.
      end.
      else do:
      run gen-b-code IN THIS-PROCEDURE (input 'pglc':U, output v-code) no-error.
      if v-code = 0
      or v-code = ?
      or error-status:error then do:
        v-mess = substitute("Не удалось создать локальный штучный код для весов&1&2&1&3"
                            , chr(10)
                            , error-status:get-message(1)
                            , return-value ).
        run err-mess in this-procedure ( input-output v-mess).
        return (if p-silent then v-mess else '').
      end.
        p-b-str = string(v-code, "99999":U).
      end.
        if p-silent then do:
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer dub-prod-bc14 for ub.prod-bc.
FIND FIRST dub-prod-bc14 No-LOCK WHERE
            dub-prod-bc14.b-str = string(v-code, '99999':U) AND
            dub-prod-bc14.bc-on = yes No-error.
if avail dub-prod-bc14 then do:
   return error  ("Невозможно создать весовой код для товара" + chr(32) +
                  string(buf_goods.artic) + chr(32) +
                  string(buf_goods.prod-type) + chr(32) +
                  string(buf_goods.prod-code) + chr(10) +
                  "Уже имеется в БД товар с включенным дополнительным кодом равным" +
                   chr(32) +
                   dub-prod-bc14.b-str).
end.
        end.
        else do:
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer dub-prod-bc15 for ub.prod-bc.
FIND FIRST dub-prod-bc15 No-LOCK WHERE
            dub-prod-bc15.b-str = string(v-code, '99999':U) AND
            dub-prod-bc15.bc-on = yes No-error.
if avail dub-prod-bc15 then do:
  message
  "Невозможно создать весовой или штучный код для весов для товара" skip
  buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
  "Уже имеется в БД товар с включенным дополнительным кодом равным"
   dub-prod-bc15.b-str
   view-as alert-box ERROR.
   return error '':U.
end.
        end.
      add-on = yes.
    end.
    when  ''
    or
    when 'sslc':U
    or
    when 'ssgb':U
    then do:
      if p-b-str = '' then do:
        v-mess = "Не задан ДопБк".
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
      end.
      if lookup ('вес':U, buf_units.type) > 0
      then do:
        v-mess =  "Для собственного кода с весовой единицей измерения нельзя создать дополнительный код.".
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
      end.
      dopi = 0.
      assign
      dopi = integer(p-b-str) no-error .
      if p-cdrg-type = 'sslc':U
      or p-cdrg-type = 'ssgb':U then do:
        if  not (lookup('вес':U, u-base.type) > 0
        and buf_units.type = 'дро':U)
        then do:
          v-mess = "Взвешиваемый код можно задать только для товара, у которого основная единица измерения ВЕСОВАЯ и только для бар-кода с единицой измерения ДРОБНАЯ".
          run err-mess in this-procedure ( input-output v-mess).
          undo, return error (if p-silent then v-mess else '').
        end.
        if dopi = 0
        then do:
          v-mess = "Взвешиваемый код должен быть целым положительным числом, не превышающим 2147483647".
          run err-mess in this-procedure ( input-output v-mess).
          undo, return error (if p-silent then v-mess else '').
        end.
        if trim(string(dopi, ">>>>>>>>9")) <> p-b-str then do:
          v-mess =  "Взвешиваемый код не должен содержать лидирующих нулей,&1" +
                   "десятичных разделителей и других спец. символов" .
          run err-mess in this-procedure ( input-output v-mess).
          undo, return error (if p-silent then v-mess else '').
        end.
        if p-cdrg-type = 'sslc':U then do:
          find first buf_code-range no-lock
            where buf_code-range.range-type  = 'sslc':U
              and buf_code-range.db-num      = 0
              and buf_code-range.first-code <= dopi
              and buf_code-range.last-code  >= dopi
            no-error .
        end.
        if p-cdrg-type =  'ssgb':U then do:
          find first buf_code-range no-lock
            where buf_code-range.range-type  = 'ssgb':U
              and buf_code-range.db-num      = g#db-num
              and buf_code-range.first-code <= dopi
              and buf_code-range.last-code  >= dopi
            no-error .
        end.
        if not available buf_code-range
        then do:
          v-mess = substitute("Введенное Вами значение &1 лежит вне диапазона кодов для взвешивания товара&2" +
                              "или в системе нет таких диапазонов"
                             , p-b-str
                             , chr(10)).
          run err-mess in this-procedure ( input-output v-mess).
          undo, return error (if p-silent then v-mess else '').
        end.
      end.
      else do:
        if can-find( first buf_code-range no-lock
          where buf_code-range.range-type  = 'ssgb':U
            and buf_code-range.db-num      = g#db-num
            and buf_code-range.first-code <= dopi
            and buf_code-range.last-code  >= dopi)
        or can-find(first buf_code-range no-lock
            where buf_code-range.range-type  = 'ssgb':U
              and buf_code-range.first-code <= dopi
              and buf_code-range.last-code  >= dopi) then do:
          v-mess = substitute("Значение &1 лежит в диапазоне кодов для взвешивания товара&2"  +
                              "такой код можно ввести только для товара с ВЕСОВОЙ основной ед изм&2"  +
                              "и бар-кода с дополнительной ед. изм. типа ДРОБНАЯ"
                              ,p-b-str
                              , chr(10)).
          run err-mess in this-procedure ( input-output v-mess).
          undo, return error (if p-silent then v-mess else '').
        end.
        if length(p-b-str) < 6 and not v-attr-sale-trk = 'yes' then do:
          v-mess =  "ДопБк должен быть длиннее 5 разрядов.".
          run err-mess in this-procedure ( input-output v-mess).
          undo, return error (if p-silent then v-mess else '').
        end.
      end.
    end.
    when 'ptlc':U
    then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output v-b-code
  )  .
      if v-b-code <> p-b-code then do:
        v-mess = substitute("Топливынй код можно создать только для ГЛАВНОГО бар-кода товара").
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
      end.
      if p-b-str = '' then do:
        v-mess = "Не задан ДопБк".
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
      end.
      if not (lookup ('топ':U,  u-base.type) > 0
            and lookup ('дро':U, u-base.type) > 0
            and buf_goods.gds-type = 'т':U)
      then do:
        v-mess = substitute("Топливный код можно задать только для товара (но не услуги) с основной единицей измерения типа &1 &2"
                           , 'топ':U
                           ,'дро':U).
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
      end.
      if length(p-b-str) > 2 then do:
        v-mess = substitute("Топливный код не должен быть длиннее 2 разрядов").
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
      end.
      dopi = 0.
      assign
      dopi = integer(p-b-str) no-error .
      if trim(string(dopi, ">>>>>>>>9")) <> p-b-str then do:
      v-mess =  "Топливный код не должен содержать лидирующих нулей,&1" +
                  "десятичных разделителей и других спец. символов" .
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
      end.
    end.
    when 'unq-artc' then do:
      if buf_goods.artic <> p-b-str then do:
        v-mess =  substitute("При включенной настройке unq-artc &1<Уникальный цифровой артикул, ДопБК=артикулу>&1 ДопБК должен быть равен артикулу", chr(10)).
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
      end.
      dopi = ?.
      dopi = integer(buf_goods.artic) no-error.
      if dopi = 0
      or dopi = ?
      or trim(string(dopi, ">>>>>>9")) <> buf_goods.artic
      or length(buf_goods.artic) > 7 then do:
        v-mess =  substitute("При включенной настройке unq-artc &1<Уникальный цифровой артикул, ДопБК=артикулу>&1" +
                             "ДопБК не может=0, ДоБК не может =?, ДопБК не может быть> 9999999"
                             , chr(10)).
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
      end.
      p-cdrg-type = ''.
    end.
    when 'GTIN':U then do:
        end.
    otherwise do:
      v-mess = substitute("Задан неизвестный тип диапазона для ДопбК = &1", p-cdrg-type).
      run err-mess in this-procedure ( input-output v-mess).
      undo, return error (if p-silent then v-mess else '').
    end.
  end case.
  if p-cdrg-type eq 'GTIN':U
  then do:
      if length(p-b-str) > 2 and lookup ('топ':U,  u-base.type) > 0
        then do:
        v-mess = substitute("Топливный код не должен быть длиннее 2 разрядов").
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
      end.
      dopi = 0.
      assign
      dopi = integer(p-b-str) no-error .
     if length(p-b-str) ne 14  and lookup ('топ':U, u-base.type) = 0
     then do:
        v-mess = "В GTIN должно быть 14 цифр.".
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
     end.
     else if not is-numeral (p-b-str,"digit")
     then do:
        v-mess = "В GTIN должны быть только цифры.".
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
     end.
  end.
  else do:
     if (
          length (p-b-str) > 13 and
          not is-numeral ((p-b-str),
                            "letter,digit")) or
          (
          length (p-b-str) <= 13 and
          not is-numeral ((p-b-str),
                            "digit"))
      then do:
        v-mess = "В бар-коде не должно быть пробелов и недопустимых символов.".
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
      end.
  end.
  bar_code = substr (p-b-str, 1, length (p-b-str) - 1).
  run str/chk-sum.p
    (input-output bar_code
    ) no-error .
  if error-status :error
  then do:
     if p-ean-type = "EAN"
     then do:
        v-mess = "Бар-код должен быть EAN8 или EAN13.".
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
     end.
     else if p-cdrg-type eq 'GTIN':U
     then do:
        v-mess = "Бар-код должен быть GTIN.".
        run err-mess in this-procedure ( input-output v-mess).
        undo, return error (if p-silent then v-mess else '').
     end.
  end.
  if     p-cdrg-type eq 'GTIN':U
     and substr (bar_code, length (bar_code), 1) <> substr (p-b-str, length (bar_code), 1)
  then do:
     v-mess = "Бар-код должен быть GTIN." .
     if session:debug-alert
     then
        v-mess = v-mess + " Ваш код " + p-b-str + " Правильный GTIN " + bar_code.
     run err-mess in this-procedure ( input-output v-mess).
     undo, return error (if p-silent then v-mess else '').
  end.
  else if ((length (p-b-str) <> 8 and
        length (p-b-str) <> 13) or
      substr (bar_code, length (bar_code), 1) <> substr (p-b-str, length (bar_code), 1)) and
      p-ean-type = "EAN"
  then do:
    v-mess = "Бар-код должен быть EAN8 или EAN13.".
    if session:debug-alert
       and (   length (p-b-str) eq 8
            or length (p-b-str) eq 13)
     then
        v-mess = v-mess + " Ваш код " + p-b-str + " Правильный EAN " + bar_code.
    run err-mess in this-procedure ( input-output v-mess).
    undo, return error (if p-silent then v-mess else '').
  end.
  run gbl/conf-rd.p ( input "bc-pfx"
                      ,input  ""
                      ,input ""
                      ,input 0
                      ,input ""
                      ,input ""
                      ,input ""
                      ,input yes
                      ,output par-bc-pfx
                      ,output dopst) no-error.
  if error-status :error
  or dopst <> "C":U
  then do:
    v-mess = substitute("Ошибка при определении параметра bc-pfx.&1&2", error-status:get-message(1) ).
    run err-mess in this-procedure ( input-output v-mess).
    undo, return error (if p-silent then v-mess else '').
  end.
  run gbl/conf-rd.p ( input "bc-frmt"
                      ,input ""
                      ,input ""
                      ,input 0
                      ,input ""
                      ,input ""
                      ,input ""
                      ,input yes
                      ,output par-bc-frmt
                      ,output dopst) no-error.
  if error-status :error
  or dopst <> "C":U
  then do:
    v-mess = substitute("Ошибка при определении параметра bc-frmt.&1&2", error-status:get-message(1) ).
    run err-mess in this-procedure ( input-output v-mess).
    undo, return error (if p-silent then v-mess else '').
  end.
  run gbl/conf-rd.p ( input "pl-pfx"
                      ,input ""
                      ,input ""
                      ,input 0
                      ,input ""
                      ,input ""
                      ,input ""
                      ,input no
                      ,output par-pl-pfx
                      ,output dopst) no-error.
  if error-status :error or dopst <> "C":U then
    par-pl-pfx = ?.
  run gbl/conf-rd.p ( input "pl-frmt"
                      ,input ""
                      ,input ""
                      ,input 0
                      ,input ""
                      ,input ""
                      ,input ""
                      ,input no
                      ,output par-pl-frmt
                      ,output dopst) no-error.
  if error-status :error or dopst <> "C":U then
    par-pl-frmt = ?.
  if p-b-str begins par-bc-pfx and
      (length (p-b-str) = 13 and
      par-bc-frmt = "EAN13" or
      length (p-b-str) = 8 and
      par-bc-frmt = "EAN8") or
      (p-b-str begins par-pl-pfx and
      par-pl-pfx <> ? and
      par-pl-frmt <> ?) and
      (length (p-b-str) = 13 and
      par-pl-frmt = "EAN13" or
      length (p-b-str) = 8 and
      par-pl-frmt = "EAN8")
  then do:
    v-mess = "Бар-код имеет префикс, зарезервированный для собственных товарных (складских мест) бар-кодов.".
    run err-mess in this-procedure ( input-output v-mess).
    undo, return error (if p-silent then v-mess else '').
  end.
  p-b:
  do transaction
  on error undo, return error return-value
  :
    add-on = yes.
    for each same-prod-bc
        where same-prod-bc.b-str = p-b-str
    on error undo p-b, return error return-value
    :
      if same-prod-bc.b-code = p-b-code
      then do:
        v-mess = "Такой дополнительный бар-код уже существует.".
        run err-mess in this-procedure ( input-output v-mess).
        undo p-b, return (if p-silent then v-mess else '') .
      end.
      if length (p-b-str) < 3
      then do:
        v-mess =  "Повторные дополнительные коды для топливных товаров запрещены.".
        run err-mess in this-procedure ( input-output v-mess).
        undo p-b, return (if p-silent then v-mess else '') .
      end.
      find same-bar-code where
            same-bar-code.b-code = same-prod-bc.b-code no-lock no-error.
      if available same-bar-code then do:
        find same-goods where
              same-goods.gds-code = same-bar-code.gds-code no-lock no-error.
        if available same-goods then do:
          if  same-goods.prod-type = buf_goods.prod-type
          and same-goods.prod-code = buf_goods.prod-code
          and dif-pdbc = yes
          then do:
            v-mess = substitute("Такой дополнительный бар-код уже существует для производителя: &1&2"
                                ,buf_goods.prod-type
                                ,buf_goods.prod-code).
            run err-mess in this-procedure ( input-output v-mess).
            undo p-b, return (if p-silent then v-mess else '') .
          end.
          find  same-gds-prt where
                same-gds-prt.node-code = same-bar-code.node-code no-lock no-error.
          if available same-gds-prt then do:
            v-mess = substitute("Для добавляемого дополнительного бар-кода найден повторный бар-код :&1&2&1&1" +
                                  "Артикул :&3&1" +
                                  "Код товара :&4&1" +
                                  "Название :&5&1" +
                                  "Единица измерения :&6&1&1" +
                                  "Признак :&7&1" +
                                  "Номер партии :&8&1" +
                                  "Номер ПН :&9"
                                ,chr(10)
                                ,p-b-str
                                ,same-goods.artic
                                ,same-goods.gds-code
                                ,same-goods.gds-name
                                ,same-bar-code.unit-cli
                                ,same-gds-prt.f-name
                                ,same-bar-code.part-code
                                ,same-bar-code.in-code).
            if not p-silent
            and not g#news then do:
              message
              v-mess
              view-as alert-box warning.
            end.
            if p-cdrg-type eq 'GTIN':U
            then
               undo p-b, return (if p-silent then v-mess else '') .
          end.
          if pbc-veto = yes then do:
            if same-goods.gds-code <> buf_goods.gds-code then do:
              v-mess = substitute("Такой дополнительный бар-код  (&1) уже существует для товара:&2&3" +
                                  "Код товара: &4&2" +
                                  "Артикул: &5&2" +
                                  "Производитель: &6&7&2" +
                                  "Наименование: &8&2" +
                                  "Добавление повторных бар-кодов запрещено."
                                  ,p-b-str
                                  ,chr(10)
                                  ,chr(9)
                                  ,same-goods.gds-code
                                  ,same-goods.prod-type
                                  ,same-goods.prod-code
                                  ,same-goods.artic
                                  ,same-goods.gds-name ).
              run err-mess in this-procedure ( input-output v-mess).
              undo p-b, return (if p-silent then v-mess else '') .
            end.
          end.
        end.
      end.
      run trg/bc-upd.p
        (input parparentproc
        ,input p-b-code
        ,input p-b-str
        ,input yes
        ,input p-silent
        ,input send-ref
        ,input recid(same-prod-bc)
        ,input ?
        ) no-error .
      if error-status :error
      then do:
        if return-value <> "":U
        then do:
          v-mess = return-value .
          run err-mess in this-procedure ( input-output v-mess).
        end.
        undo p-b, return (if p-silent then v-mess else '') .
      end.
      assign
        add-on = no
      .
    end.
    if not add-on
    and not p-silent
    then do:
      define variable v-ok as logical   no-undo .
      assign
        v-ok = true
      .
      message
        "Добавляемый бар-код будет добавлен как ВЫКЛЮЧЕННЫЙ" skip
        "(поскольку были найдены повторные бар-коды)." skip
        "Продолжить?" skip
        view-as alert-box question buttons yes-no update v-ok .
      if v-ok <> true
      then do:
        undo p-b, return (if p-silent then v-mess else '') .
      end.
    end.
  end.
do
on error undo, return error return-value
:
  create buf_prod-bc.
  assign
  buf_prod-bc.b-str = p-b-str
  buf_prod-bc.b-code = p-b-code
  buf_prod-bc.bc-on = add-on
  buf_prod-bc.bc-on-type = p-cdrg-type
  p-recid = recid(buf_prod-bc)
  .
  if p-nedeMark
  then do:
     create buf_prod-bc-attr.
     assign
        buf_prod-bc-attr.b-str  = p-b-str
        buf_prod-bc-attr.b-code = p-b-code
        buf_prod-bc-attr.attr-code = 'mark':U
        buf_prod-bc-attr.attr-value = "yes"
     .
  end.
end.
PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Создание ДопБК для товара с кодом &1 на бар-код &2:&3&4"
                         , buf_goods.gds-code
                         , p-b-code
                         , chr(10)
                         , p-mess)
      .
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.
