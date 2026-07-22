block-level on error undo, throw.
using ibs.th.gbl.gbl-hndllib from propath.
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Библиотека  процедур".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-pl-wth no-undo
  field w-p-code        like ub.wth-pobj.w-p-code
  field incass-bank-pl  like ub.wth-pobj.incass-bank-pl
  field incass-other-pl like ub.wth-pobj.incass-other-pl
  field incass-pl       like ub.wth-pobj.incass-pl
  field income-cassa-pl like ub.wth-pobj.income-cassa-pl
  field income-other-pl like ub.wth-pobj.income-other-pl
  field income-pl       like ub.wth-pobj.income-pl
  field incass-cassa-pl like ub.wth-pobj.incass-cassa-pl
  index xpk is primary unique w-p-code
.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    define variable v-mes1 as character no-undo .
    define variable v-param-type1 as character no-undo .
    define variable v-value-character1 as INTEGER no-undo .
    define variable v-value-date1 as date no-undo .
    define variable v-value-decimal1 as decimal no-undo .
    define variable v-value-integer1 AS integer no-undo .
    define variable v-value-logical1 AS LOGICAL no-undo .
    define variable v-tth1 as handle no-undo .
    run adm/shattri.p (
        input "get":U
        ,input  'БД':U
        ,input  p-db-num
        ,input  'code-range':U
        ,input  cfg-param-code
        ,output v-value-character1
        ,output v-value-date1
        ,output v-value-decimal1
        ,output v-value-integer1
        ,output v-value-logical1
        ,output v-param-type1
        ,INPUT-OUTPUT table-handle v-tth1
        ) no-error .
    if error-status :error then do:
      delete object v-tth1.
      v-mes1 = substitute("Ошибка при получении размера диапазона собственных глобальных кодов&2&1&2&3"
                         , error-status:get-message(1)
                         , chr(10)
                         , return-value ).
      undo, return error v-mes1.
    end.
    delete object v-tth1.
    if v-cre-cdrg = TRUE then do:
      create buf_code-range .
      assign
        buf_code-range.db-num     = p-db-num
        buf_code-range.range-type = type-code
        buf_code-range.stts       = "f"
        buf_code-range.first-code = last_code-range.last-code + 1
        buf_code-range.last-code  = last_code-range.last-code + integer(v-value-integer1)
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer locK-batchprocess2 for ub.batchprocess.
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
    ,buffer lock-batchprocess2
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure gdsoattr-name :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-name in g#attr-lib
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
end.
procedure gdsoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-value :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-value in g#attr-lib
      (input  p-code
      ,input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-gds-code :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-gds-code in g#attr-lib
      (input  p-code
      ,input  p-value
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-gds-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-write :
  define input parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-write in g#attr-lib
      (input p-gds-code
      ,input p-obj-type
      ,input p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-exist :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-delete :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-doc-tickets :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-doc-tickets in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-dop-alt-name :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-dop-alt-name in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-gds-margins :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-gds-margins in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-normal-wastage :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-normal-wastage in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr-margin-value :
  define input  parameter p-gds-code         as integer   no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define output parameter p-min-value        as decimal   no-undo initial ? .
  define output parameter p-max-value        as decimal   no-undo initial ? .
  define output parameter p-increase-pc      as decimal   no-undo initial ? .
  define output parameter p-rmethod          as character no-undo initial '':U .
  define output parameter p-base             as decimal   no-undo initial ? .
  define output parameter p-range-margin     as integer   no-undo .
  define output parameter p-exists-margin    as logical   no-undo .
  define output parameter p-range-increase   as integer   no-undo .
  define output parameter p-exists-increase  as logical   no-undo .
  define output parameter p-range-rmethod    as integer   no-undo .
  define output parameter p-exists-rmethod   as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-margin-value in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-min-value
      ,output p-max-value
      ,output p-increase-pc
      ,output p-rmethod
      ,output p-base
      ,output p-range-margin
      ,output p-exists-margin
      ,output p-range-increase
      ,output p-exists-increase
      ,output p-range-rmethod
      ,output p-exists-rmethod
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-o-normal-wastage-value :
  define input-output parameter objNormWast as class ibs.th.ref.normwastsub no-undo.
do
on error undo, return error
:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-o-normal-wastage-value in g#attr-lib
      (input-output objNormWast
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr_check-code-dt-seasons :
  define input  parameter p-code     like ub.goods.gds-code   no-undo .
  define input  parameter p-obj-type like ub.clients.obj-type no-undo .
  define input  parameter p-obj-code like ub.clients.obj-code no-undo .
  define output parameter p-gds-code like ub.goods.gds-code   no-undo .
  define output parameter p-dt-code  as   integer             no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-code-dt-seasons in g#attr-lib
      (input p-code
      ,input p-obj-type
      ,input p-obj-code
      ,output p-gds-code
      ,output p-dt-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure factord :
  define input  parameter p-fact-date            as date    no-undo .
  define input  parameter p-fact-time            as integer no-undo .
  define input  parameter p-fact-num             as integer no-undo .
  define input  parameter p-shift-date           as date    no-undo .
  define input  parameter p-shift-num            as integer no-undo .
  define input  parameter p-shift-on             as logical no-undo .
  define output parameter p-fact-order           as decimal no-undo .
  define output parameter p-shift-end-fact-order as decimal no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  define variable vss-description as character no-undo init "factord: Определение порядкового номера документа".
  if p-fact-date = ?
  then do:
    return error "Не указана фактическая дата" .
  end.
  define variable v-fact-date-num as integer no-undo .
  assign
    v-fact-date-num = integer(p-fact-date)
  .
  if p-fact-num = ?
  or p-fact-num = 0
  then do:
    return error "Не задан p-fact-num " + string(p-fact-num) .
  end.
  if p-fact-num < 0
  then do:
    return error "Отрицательный fact-num " + string(p-fact-num) .
  end.
  if p-fact-num >= 100000000
  then do:
    return error "Недопустимо большой fact-num " + string(p-fact-num) .
  end.
  if p-shift-on = true
  then do:
    if p-shift-date = ?
    then do:
      return error "Не задана дата смены" .
    end.
    if p-shift-num = ?
    or p-shift-num = 0
    then do:
      return error "Не задан номер смены" .
    end.
  end.
  else do:
    assign
      p-shift-date = p-fact-date
      p-shift-num  = 24
    .
  end.
  define variable v-shift-offset as integer no-undo .
  if p-shift-date = p-fact-date
  then do:
    assign
      v-shift-offset = 1
    .
  end.
  if p-shift-date < p-fact-date
  then do:
    assign
      v-shift-offset = 0
    .
  end.
  if p-shift-date > p-fact-date
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная дата закрытия смены" skip
      "Дата закрытия не смены не может быть раньше чем дата открытия смены" skip
      view-as alert-box error .
    undo, return error
      substitute("Дата закрытия не смены &1 не может быть раньше чем дата открытия смены &2"
        ,string(p-fact-date, '99/99/9999':U)
        ,string(p-shift-date, '99/99/9999':U)
        )
    .
  end.
  if p-shift-num < 1
  or p-shift-num > 24
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный номер смены" skip
      "p-shift-num" p-shift-num skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    p-fact-order           = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02 - 0.01
                           + p-fact-num     * 0.0000000001
    p-shift-end-fact-order = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02
    p-day-end-fact-order   = v-fact-date-num
                           + 0.99
  .
  if p-fact-order           <= v-fact-date-num
  or p-shift-end-fact-order <= v-fact-date-num
  or p-fact-order           >= p-shift-end-fact-order - 0.0000000001
  or p-shift-end-fact-order >= p-day-end-fact-order
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Внутренняя ошибка при генерации фактического номера" skip
      "p-fact-date"            p-fact-date            skip
      "p-fact-time"            p-fact-time            skip
      "p-fact-num"             p-fact-num             skip
      "p-shift-date"           p-shift-date           skip
      "p-shift-num"            p-shift-num            skip
      "p-shift-on"             p-shift-on             skip
      "p-shift-end-fact-order" p-shift-end-fact-order skip
      "p-day-end-fact-order"   p-day-end-fact-order   skip
      "v-fact-date-num"        v-fact-date-num        skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end procedure.
procedure day-begin-fact-order :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-begin-fact-order as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      assign
        p-day-begin-fact-order = 0
      .
    end.
    else do:
      assign
        p-day-begin-fact-order = integer(p-fact-date)
      .
    end.
  end.
end procedure.
procedure factord-max-fact-order :
  define output parameter p-max-fact-order as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    run day-begin-fact-order in this-procedure
      (input  date(1, 1, 5000)
      ,output p-max-fact-order
      ) .
  end.
end procedure.
procedure factord-cut-archive :
  define input  parameter p-obj-type             as character no-undo .
  define input  parameter p-obj-code             as integer   no-undo .
  define input  parameter p-fact-date            as date      no-undo .
  define output parameter p-shift-on             as logical   no-undo .
  define output parameter p-shift-date           as date      no-undo .
  define output parameter p-shift-num            as integer   no-undo .
  define output parameter p-day-end-fact-order   as decimal   no-undo .
  define output parameter p-shift-end-fact-order as decimal   no-undo .
  define variable v-fact-order as decimal   no-undo .
  define buffer buf_shift-obj for ub.shift-obj .
  do
  on error undo, return error return-value
  :
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output p-shift-on
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута объекта" skip
        "Объект" p-obj-type p-obj-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-shift-on = false
    then do:
      assign
        p-shift-date               = ?
        p-shift-num                = 0
      .
    end.
    else do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно вычислить последнюю смену" skip
          "Отсутствует закрытая смена с датой большей чем дата инициализации архива" skip
          "Объект" p-obj-type p-obj-code skip
          "Дата" p-fact-date skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find last buf_shift-obj share-lock
        where buf_shift-obj.obj-type = p-obj-type
          and buf_shift-obj.obj-code = p-obj-code
          and buf_shift-obj.shift-date <= p-fact-date
        use-index pi
        no-error .
      if available buf_shift-obj
      then do:
        if  buf_shift-obj.status_ = 'зкр':U
        then do:
          assign
            p-shift-date = buf_shift-obj.shift-date
            p-shift-num  = buf_shift-obj.shift-num
          .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно вычислить последнюю смену" skip
            "Статус смены отличен от статуса" 'зкр':U skip
            "Объект" p-obj-type p-obj-code skip
            "Дата" p-fact-date skip
            "Смена" buf_shift-obj.shift-date buf_shift-obj.shift-num skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
      else do:
        assign
          p-shift-date = p-fact-date - 1
          p-shift-num  = 1
        .
      end.
    end.
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  p-shift-date
      ,input  p-shift-num
      ,input  p-shift-on
      ,output v-fact-order
      ,output p-shift-end-fact-order
      ,output p-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры factord"
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure factord-lock-shift :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .
  define parameter buffer buf_shift-obj for ub.shift-obj .
  define variable v-shift-on      as logical   no-undo .
  define variable v-extra-message as character no-undo .
  define variable v-error as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  ) no-error .
    if error-status :error
    then do:
      v-error = substitute("Ошибка при определении атрибута объекта  &1 &2 &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value) .
      undo, return error v-error .
    end.
    if v-shift-on = true
    then do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        find last buf_shift-obj
          where buf_shift-obj.obj-type = p-obj-type
            and buf_shift-obj.obj-code = p-obj-code
            and buf_shift-obj.status_  = 'зкр':U
          use-index stts
          no-error .
        if available buf_shift-obj
        then do:
          assign
            v-extra-message =
                  substitute("Дата начала последеней закрытой смены на объекте &1"
                            ,string(buf_shift-obj.shift-date, '99/99/9999':u)
                            )
          .
        end.
        v-error = substitute("Ошибка при блокировке смены объекта  &1 &2 Отсутствует закрытая смена с датой большей чем указанная дата  &5  &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value , p-fact-date) .
        undo, return error v-error .
      end.
    end.
  end.
end procedure.
procedure factord-end-day :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      return error "Не указана фактическая дата" .
    end.
    assign
      p-day-end-fact-order = integer(p-fact-date) + 0.99
    .
  end.
end procedure.
procedure factord-to-date :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-date  as date    no-undo .
  define variable v-ref-date  as date      no-undo .
  define variable v-ref-delta as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
      v-ref-date  = date(1, 1, 2000)
    .
    assign
      v-ref-delta = integer(truncate(p-fact-order, 0)) - integer(v-ref-date)
    .
    assign
      p-fact-date = v-ref-date + v-ref-delta
    .
  end.
end procedure.
procedure factord-to-fact-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-num   as integer no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)
    .
    assign
      p-fact-num = (p-fact-order - v-fact-order-trunc ) * 10000000000
    .
  end.
end procedure.
procedure factord-to-shift-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-shift-num   as integer no-undo .
  define variable  p-shift-numd  as decimal   no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)  - truncate(p-fact-order,0)
    .
    if v-fact-order-trunc < 0.5 then do:
      v-fact-order-trunc = v-fact-order-trunc + 0.5.
    end.
    assign
      p-shift-numd = (( v-fact-order-trunc  * 100 - 50 ) + 1 ) / 2
      .
     assign
      p-shift-num = truncate (p-shift-numd , 0)
    .
  end.
end procedure.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-drt-prop no-undo like ub.drt-prop.
procedure disrules-fill-properties:
define input  parameter p-templ-rl-root as integer   no-undo .
define buffer buf_drt-prop for ub.drt-prop.
define buffer buf_temp-drt-prop for temp-drt-prop.
do
on error undo, return error return-value
:
  for each buf_temp-drt-prop:
    delete buf_temp-drt-prop.
  end.
  for each buf_drt-prop where buf_drt-prop.templ-rl-root = p-templ-rl-root:
    create buf_temp-drt-prop.
    buffer-copy buf_drt-prop to buf_temp-drt-prop.
  end.
end.
end procedure.
~
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure discfgru-check :
define input parameter p-table-name as character no-undo .
define input parameter p-templ-rl-root as integer no-undo .
define input parameter p-time-templ-rl-root as integer no-undo .
define input parameter p-pos-type as character no-undo .
define output parameter p-disnct-role as character no-undo .
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
  do
  on error undo, return error return-value
  :
    find first buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.table-name = p-table-name
        and buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root
        and (p-time-templ-rl-root = ? or  buf_dis-cfg-rule.time-templ-rl-root = p-time-templ-rl-root)
        and buf_dis-cfg-rule.pos-type = p-pos-type no-error.
    if not available buf_dis-cfg-rule
    or p-pos-type = "":U
    then do:
       return error substitute("Для места использования типа &1 не определен тип скидки с шаблоном &2 &3"
                               ,entry (lookup (p-pos-type, 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,InfoKiosk,pricecheck-Servis+,Emulator-NKT-IBM,MARIA,-,bo,Autotank':U), 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,R-KEEPER,InfoKiosk,Прайс-чекер Servis+,Emulator-NKT-IBM,MARIA,Накладная,Бэкофис,Autotank':U)
                               , p-templ-rl-root
                               , (if p-time-templ-rl-root = ?
                                  then '':U
                                  else substitute("с расписанием типа &1", p-time-templ-rl-root)
                                  )
                               ).
    end.
    assign
    p-disnct-role = buf_dis-cfg-rule.discnt-role
    .
  end.
end procedure.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION get-region RETURNS CHARACTER
  ( input parhost-code as integer, input parobj-type as character, input parobj-code as integer ) :
  define variable par-region as character no-undo.
  if parhost-code = 0 and
       parobj-type = "":U and
       parobj-code = 0 then do:
       par-region = "Глобально".
       return par-region.
    end.
    if parobj-type = 'орг':U then do:
       par-region = fill(chr(32), 2) + "Фирма" + chr(32) + string(parhost-code).
       return par-region.
    end.
    if parobj-type = 'регион':U
    then do:
       par-region = fill(chr(32), 2) + "Регион" + chr(32) + string(parobj-code).
       return par-region.
    end.
    par-region = fill(chr(32), 4) + parobj-type + chr(32) + string(parobj-code).
    return par-region.
END FUNCTION.
FUNCTION get-objregion RETURNS CHARACTER
  (  input parobj-type as character, input parobj-code as integer ) :
  define variable par-region as character no-undo.
  if  parobj-type = "":U and
      parobj-code = 0
  then do:
     par-region = "Глобально".
  end.
  else if parobj-type = 'орг':U
  then do:
     par-region = fill(chr(32), 2) + "Фирма" + chr(32) + string(parobj-code).
  end.
  else if parobj-type = 'регион':U
  then do:
     par-region = fill(chr(32), 2) + "Регион" + chr(32) + string(parobj-code).
  end.
  else
     par-region = fill(chr(32), 4) + parobj-type + chr(32) + string(parobj-code).
  return par-region.
END FUNCTION.
procedure disgdsru-name :
define buffer buf_dis-rule for ub.dis-rule.
do
  on error undo, return error
  :
  define input  parameter p-templ-rl-root  as integer no-undo .
  define output parameter p-label          as character no-undo .
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = p-templ-rl-root no-error.
  if available buf_dis-rule
  then do:
    if buf_dis-rule.rule-num > 0 then
    p-label = buf_dis-rule.des.
  end.
  else do:
    p-label = substitute("Неизвестный тип правила скидки &1", p-templ-rl-root).
  end.
end.
end procedure.
function disgdsru-get-disc-label returns character ( input p-templ-rl-root as integer):
define variable v-rule-label as character no-undo .
run disgdsru-name in this-procedure ( input p-templ-rl-root
                                     ,output v-rule-label) no-error.
return v-rule-label.
end function.
function disgdsru-get-disc-role-label returns character ( input p-discnt-role as character):
define variable v-rule-label as character no-undo .
return entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u).
end function.
procedure disgdsru-write :
  do
  on error undo, return error
  :
    define input parameter p-obj-type       like ub.dis-gds-rule.obj-type   no-undo .
    define input parameter p-obj-code       like ub.dis-gds-rule.obj-code   no-undo .
    define input parameter p-gds-code       like ub.dis-gds-rule.gds-code   no-undo .
    define input parameter p-pos-type       like ub.dis-gds-rule.pos-type   no-undo .
    define input parameter p-discnt-role    like ub.dis-gds-rule.discnt-role no-undo .
    define input parameter p-templ-rl-root  like ub.dis-gds-rule.templ-rl-root  no-undo .
    define input parameter p-time-templ-rl-root  like ub.dis-gds-rule.time-templ-rl-root  no-undo .
    define input parameter p-rule-num       like ub.dis-gds-rule.rule-num    no-undo .
    define input parameter p-nonunique      like ub.dis-gds-rule.nonunique   no-undo .
    define buffer buf_dis-gds-rule for ub.dis-gds-rule .
    define buffer buf_dis-rule for ub.dis-rule.
    define buffer lock_dis-gds-rule for ub.dis-gds-rule .
    define variable v-label          as character no-undo .
    define variable v-discnt-role as character no-undo .
    run discfgru-check in this-procedure (
                                          input 'dis-gds-rule':U
                                         ,input p-templ-rl-root
                                         ,input p-time-templ-rl-root
                                         ,input p-pos-type
                                         ,output v-discnt-role
                                          ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    if p-discnt-role = ? then do:
      p-discnt-role = v-discnt-role.
    end.
    if p-discnt-role <> v-discnt-role then do:
      undo, return error substitute("Товар &1 &2&3 место использ. &4 скидка типа &5&6не может быть по шаблону &7 и расписанию &8"
                              ,p-gds-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                              ,chr(10)
                              ,p-templ-rl-root
                              ,p-rule-num).
    end.
    if p-pos-type = ? then do:
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type12 as character no-undo .
define variable v-value-date12 as date no-undo .
define variable v-value-decimal12 as decimal no-undo .
define variable v-value-integer12 as INTEGER no-undo .
define variable v-value-logical12 AS LOGICAL no-undo .
define variable v-tth12 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output p-pos-type
    ,output v-value-date12
    ,output v-value-decimal12
    ,output v-value-integer12
    ,output v-value-logical12
    ,output v-param-type12
    ,INPUT-OUTPUT table-handle v-tth12
    )  .
delete object v-tth12 no-error.
    end.
    find first buf_dis-rule no-lock where
              buf_dis-rule.rule-num = p-rule-num no-error.
    if not available buf_Dis-rule then do:
      undo, return error substitute("Товар &1 &2&3 место использ. &4 скидка типа &5&6не найдено правило скидки &7"
                              ,p-gds-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                              ,chr(10)
                              ,p-rule-num).
    end.
    if buf_dis-rule.root <> yes then do:
      undo, return error substitute("Товар &1 &2&3 место использ. &4 скидка типа &5&6правило скидки &7 - некорневое"
                              ,p-gds-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                              ,chr(10)
                              ,p-rule-num).
    end.
    if not (p-obj-type = buf_dis-rule.obj-type
        and p-obj-code = buf_dis-rule.obj-code)
    and not ( (p-obj-type = 'маг':U or p-obj-type = 'скл':U )
             and
             (buf_dis-rule.obj-type = 'орг':U or buf_dis-rule.obj-type = ""))
     then do:
      undo, return error (substitute("Товар &1 &2&3 место использ. &4 скидка типа &5&6"
                              ,p-gds-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                              ,chr(10)
                              ) +
                          substitute("Правило скидки &1 определено для &2&3" +
                                     "а привязка к товару для &4"
                                     ,buf_dis-rule.rule-num
                                     ,get-objregion( buf_dis-rule.obj-type, buf_Dis-rule.obj-code)
                                     ,chr(10)
                                     ,get-objregion( p-obj-type, p-obj-code)
                                     ))
                              .
    end.
    find first buf_dis-gds-rule exclusive-lock where
               buf_dis-gds-rule.gds-code  = p-gds-code
           AND buf_dis-gds-rule.obj-type  = buf_dis-rule.obj-type
           AND buf_dis-gds-rule.obj-code  = buf_dis-rule.obj-code
           AND buf_dis-gds-rule.pos-type  = p-pos-type
           AND buf_dis-gds-rule.discnt-role = p-discnt-role
           and buf_dis-gds-rule.nonunique = p-nonunique
           no-error .
    if not available buf_dis-gds-rule then do:
      find first buf_dis-gds-rule exclusive-lock where
                buf_dis-gds-rule.gds-code  = p-gds-code
            AND buf_dis-gds-rule.obj-type  = buf_dis-rule.obj-type
            AND buf_dis-gds-rule.obj-code  = buf_dis-rule.obj-code
            AND buf_dis-gds-rule.pos-type  = p-pos-type
            AND buf_dis-gds-rule.discnt-role = p-discnt-role
            no-error .
      if available buf_Dis-gds-rule then do:
        if p-nonunique = ''
        and available buf_dis-gds-rule
        then do:
          return error substitute("Скидка типа &1 на товар с кодом &2 &3&4 уже существует (детализ. &3)"
                                   , entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                                   , p-gds-code
                                   , buf_Dis-rule.obj-type
                                   , buf_Dis-rule.obj-code
                                   , p-nonunique
                                  ).
        end.
        if available buf_dis-gds-rule
        and buf_dis-gds-rule.nonunique = ''
        and p-nonunique <> ''then do:
          return error substitute("Скидка типа &1 на товар с кодом &2 &3&4 уже существует"
                                   , entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                                   , p-gds-code
                                   , buf_Dis-rule.obj-type
                                   , buf_Dis-rule.obj-code
                                  ).
        end.
      end.
      create buf_dis-gds-rule .
      assign
      buf_dis-gds-rule.gds-code  = p-gds-code
      buf_dis-gds-rule.obj-type  = buf_dis-rule.obj-type
      buf_dis-gds-rule.obj-code  = buf_dis-rule.obj-code
      buf_dis-gds-rule.pos-type = p-pos-type
      buf_dis-gds-rule.discnt-role = v-discnt-role
      buf_dis-gds-rule.rule-num = p-rule-num
      buf_dis-gds-rule.nonunique = p-nonunique
      no-error
      .
    end.
    ASSIGN
    buf_dis-gds-rule.rule-num = p-rule-num
    buf_dis-gds-rule.rl-root = buf_Dis-rule.rl-root
    buf_dis-gds-rule.time-templ-rl-root = p-time-templ-rl-root
    buf_dis-gds-rule.templ-rl-root = p-templ-rl-root
    buf_dis-gds-rule.nonunique = p-nonunique
    no-error.
  end.
end procedure.
PROCEDURE cmp-disgdsru-write :
do
on error undo, return error
:
  define input parameter p-gds-code like ub.dis-gds-rule.gds-code   no-undo .
  define input parameter p-obj-type like ub.dis-gds-rule.obj-type   no-undo .
  define input parameter p-obj-code like ub.dis-gds-rule.obj-code   no-undo .
  define input parameter p-pos-type like ub.dis-gds-rule.pos-type   no-undo .
  define input parameter p-templ-rl-root     like ub.dis-gds-rule.templ-rl-root  no-undo .
  define input parameter p-time-templ-rl-root     like ub.dis-gds-rule.time-templ-rl-root  no-undo .
  define input parameter p-discnt-role like ub.dis-gds-rule.discnt-role no-undo .
  define input parameter p-rule-num    like ub.dis-gds-rule.rule-num no-undo .
  define input parameter p-nonunique like ub.dis-gds-rule.nonunique no-undo .
  define variable v-rule-label          as character no-undo .
  define buffer buf_tt0-dis-gds-rule for ub.dis-gds-rule .
  define buffer buf_dis-rule     for ub.dis-rule.
  run disgdsru-name in this-procedure (
                                      input  p-templ-rl-root
                                      ,output v-rule-label
                                      ) no-error .
  if error-status :error then do:
    undo, return error return-value .
  end.
  find first buf_tt0-dis-gds-rule exclusive-lock where
              buf_tt0-dis-gds-rule.gds-code  = p-gds-code
          AND buf_tt0-dis-gds-rule.obj-type  = p-obj-type
          AND buf_tt0-dis-gds-rule.obj-code  = p-obj-code
          AND buf_tt0-dis-gds-rule.pos-type  = p-pos-type
          AND buf_tt0-dis-gds-rule.discnt-role = p-discnt-role
          AND buf_tt0-dis-gds-rule.nonunique = p-nonunique
          no-error .
  if not available buf_tt0-dis-gds-rule then do:
    create buf_tt0-dis-gds-rule .
    assign
    buf_tt0-dis-gds-rule.gds-code  = p-gds-code
    buf_tt0-dis-gds-rule.obj-type  = p-obj-type
    buf_tt0-dis-gds-rule.obj-code  = p-obj-code
    buf_tt0-dis-gds-rule.pos-type  = p-pos-type
    buf_tt0-dis-gds-rule.nonunique = p-nonunique
    buf_tt0-dis-gds-rule.discnt-role = p-discnt-role
    no-error
    .
  end.
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = p-rule-num.
  ASSIGN
  buf_tt0-dis-gds-rule.templ-rl-root = p-templ-rl-root
  buf_tt0-dis-gds-rule.rule-num = p-rule-num
  buf_tt0-dis-gds-rule.time-templ-rl-root = p-time-templ-rl-root
  buf_tt0-dis-gds-rule.nonunique = p-nonunique
  buf_tt0-dis-gds-rule.templ-rl-root = p-templ-rl-root
  buf_tt0-dis-gds-rule.rl-root = buf_Dis-rule.rl-root
  no-error.
  release buf_tt0-dis-gds-rule no-error .
  if error-status:error then do:
    undo, return error return-value .
  end.
end.
END PROCEDURE.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure db-attr-code :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-code in g#attr-lib
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
procedure db-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-tooltip in g#attr-lib
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
procedure db-attr-value :
  define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
  define output parameter p-value     like ub.db-attr.attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-value in g#attr-lib
      (input  p-db-num
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
procedure db-attr-write :
  define input parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input parameter p-code      like ub.db-attr.attr-code  no-undo .
  define input parameter p-value     like ub.db-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-write in g#attr-lib
      (input p-db-num
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-exist :
  define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-exist in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-delete :
  define input  parameter p-db-num   like ub.db-attr.db-num     no-undo .
  define input  parameter p-code     like ub.db-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-delete in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info15, return-value, chr(10), error-status :get-message (1)).
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info15, return-value, chr(10), error-status :get-message (1)).
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define new global shared variable g#lib-log as handle no-undo .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-nws as handle no-undo .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gds-objh_write-gds-obj-proc  :
define parameter buffer buf_gds-obj for ub.gds-obj .
define input parameter p-action as integer no-undo .
define input parameter p-source-type like ub.c-gds-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-gds-hist.source-ref no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-current-db-num as integer no-undo .
define variable v-news as logical no-undo .
define variable v-esys as logical no-undo .
define variable v-userid as character no-undo .
define variable v-h as handle no-undo .
define buffer buf_c-gds-hist for ub.c-gds-hist.
define buffer buf_c-gds-obj-ref for ub.c-gds-obj-ref.
  do
  on error undo, return error
  :
    if not available buf_gds-obj then do:
      undo, return error (vss-workfile + chr(32) + vss-revision + chr(32) + vss-description  + chr(10) +
                    "Ошибка задания входных параметров:Не определен товар на объекте" ).
    end.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run calltree in g#library
  (input  'mainhandle_parentproc_indicator'
  ,input  this-procedure:handle
  ,input  ?
  ,output v-h
  )  .
    run get-news in v-h ( output v-news) no-error.
    if v-news or not valid-handle(v-h) then return ''.
    run get-db-num in v-h ( output v-current-db-num).
    run get-userid in v-h ( output v-userid).
    run get-esys in v-h ( output v-esys).
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-gds-obj-ref.
    buffer-copy buf_gds-obj to buf_c-gds-obj-ref
    assign
    buf_c-gds-obj-ref.gds-code           = buf_gds-obj.gds-code
    buf_c-gds-obj-ref.obj-type           = buf_gds-obj.obj-type
    buf_c-gds-obj-ref.obj-code           = buf_gds-obj.obj-code
    buf_c-gds-obj-ref.chip-num           = next-value (s-gds-chip, ub)
    buf_c-gds-obj-ref.corr-time          = v-time
    buf_c-gds-obj-ref.corr-user-db-num   = v-current-db-num
    buf_c-gds-obj-ref.corr-user-name     = (if v-news then (chr(4) +  'СПН':U)
                                      else (if v-esys
                                            then (chr(4) +  'ВС':U)
                                            else v-userid)
                                            )
    buf_c-gds-obj-ref.corr-date          = v-date
    .
    create buf_c-gds-hist.
    buffer-copy buf_c-gds-obj-ref to buf_c-gds-hist
    assign
    buf_c-gds-hist.action =  p-action
    buf_c-gds-hist.subject = 'gds-obj':U
    buf_c-gds-hist.is-news = v-news
    buf_c-gds-hist.source-type = p-source-type
    buf_c-gds-hist.source-ref = p-source-ref
    .
    run nws/cr-route.p ( input 'send-tbl':U
                       , input 'c-gds-obj-ref':U
                       , input buffer buf_c-gds-obj-ref:handle
                       , input '' ) .
    run nws/cr-route.p ( input 'send-tbl':U
                       , input 'c-gds-hist':U
                       , input buffer buf_c-gds-hist:handle
                       , input '' ) .
  end.
end procedure.
if valid-handle (g#library)
and g#library <> this-procedure :handle
and g#library :get-signature('library_testproc':u) <> ""
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Попытка повторной загрузки библиотеки" skip
    g#library skip
    g#library :type skip
    g#library :file-name skip
    valid-handle(g#library) skip
    this-procedure :handle skip
    this-procedure :type skip
    this-procedure :file-name skip
    valid-handle(this-procedure) skip
    view-as alert-box error .
  undo, return error return-value .
end.
else do:
  assign
    g#library = this-procedure :handle
  .
  def var gbl-hndllibObj as class gbl-hndllib no-undo.
  gbl-hndllibObj = new gbl-hndllib ().
  gbl-hndllibObj:InitHndl("g#library", g#library).
  delete object gbl-hndllibObj.
end.
if this-procedure :persistent <> true
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка запуска библиотеки" program-name(1) skip
    "Попытка запустить ее как обычную процедуру" skip
    view-as alert-box error .
end.
on delete of this-procedure do:
  assign
    g#library = ?
  .
  def var gbl-hndllibObj as class gbl-hndllib no-undo.
  gbl-hndllibObj = new gbl-hndllib ().
  gbl-hndllibObj:InitHndl("g#library", g#library).
  delete object gbl-hndllibObj.
end.
define variable l-last-hostcode-exist     as logical                  no-undo initial false .
define variable v-last-hostcode-obj-type  like ub.price-doc.obj-type  no-undo .
define variable v-last-hostcode-obj-code  like ub.price-doc.obj-code  no-undo .
define variable v-last-hostcode-host-code like ub.price-doc.host-code no-undo .
define variable l-last-hostname-exist     as logical                  no-undo initial false .
define variable v-last-hostname-obj-type  like ub.price-doc.obj-type  no-undo .
define variable v-last-hostname-obj-code  like ub.price-doc.obj-code  no-undo .
define variable v-last-hostname-host-name like ub.clients.obj-name    no-undo .
define variable l-last-regcode-exist     as logical    no-undo initial false .
define variable v-last-regcode-obj-type  as character  no-undo .
define variable v-last-regcode-obj-code  as integer    no-undo .
define variable v-last-regcode-reg-code  as integer    no-undo .
define stream librout .
procedure library_testproc :
  define buffer buf_cli-gds    for ub.cli-gds .
  define buffer buf_gds-dtl    for ub.gds-dtl .
  define buffer buf_bar-code   for ub.bar-code .
  define buffer buf_wth-obj    for ub.wth-obj .
end.
procedure hostcode :
do
on error undo, return error return-value
:
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define output parameter p-host-code as integer   no-undo .
  define variable vss-description as character no-undo initial "hostcode-01: код фирмы для объекта".
  if  l-last-hostcode-exist = true
  and p-obj-type            = v-last-hostcode-obj-type
  and p-obj-code            = v-last-hostcode-obj-code
  then do:
    assign
      p-host-code = v-last-hostcode-host-code
    .
    return .
  end.
  define buffer buf_store   for ub.store .
  define buffer buf_shop    for ub.shop .
  case p-obj-type :
    when 'скл':U
    then do:
      find first buf_store no-lock
        where buf_store.obj-code = p-obj-code
        no-error .
      if not available buf_store
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найден склад" skip
          "p-obj-type" p-obj-type skip
          "p-obj-code" p-obj-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      assign
        p-host-code = buf_store.host-code
      .
    end.
    when 'маг':U
    then do:
      find first buf_shop no-lock
        where buf_shop.obj-code = p-obj-code
        no-error .
      if not available buf_shop
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найден магазин" skip
          "p-obj-type" p-obj-type skip
          "p-obj-code" p-obj-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      assign
        p-host-code = buf_shop.host-code
      .
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Неизвестный тип объекта" skip
        "p-obj-type" p-obj-type skip
        "p-obj-code" p-obj-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
  assign
    l-last-hostcode-exist     = true
    v-last-hostcode-obj-type  = p-obj-type
    v-last-hostcode-obj-code  = p-obj-code
    v-last-hostcode-host-code = p-host-code
  .
end.
end procedure.
procedure hostname :
do
on error undo, return error return-value
:
  define input  parameter p-obj-type  like ub.price-doc.obj-type  no-undo .
  define input  parameter p-obj-code  like ub.price-doc.obj-code  no-undo .
  define output parameter p-host-code like ub.price-doc.host-code no-undo .
  define output parameter p-host-name like ub.clients.obj-name    no-undo .
  define variable vss-description as character no-undo initial "hostname-01: имя фирмы для объекта".
  if  l-last-hostname-exist = true
  and p-obj-type            = v-last-hostname-obj-type
  and p-obj-code            = v-last-hostname-obj-code
  then do:
    assign
      p-host-code = v-last-hostcode-host-code
      p-host-name = v-last-hostname-host-name
    .
    return .
  end.
  if  l-last-hostname-exist = true
  and p-obj-type = 'орг':U
  and v-last-hostcode-host-code = p-obj-code then do:
    assign
      p-host-code = v-last-hostcode-host-code
      p-host-name = v-last-hostname-host-name
    .
    return .
  end.
  define buffer buf_store   for ub.store .
  define buffer buf_shop    for ub.shop .
  define buffer buf_clients for ub.clients.
  define buffer buf_sysconf for ub.sysconf .
  case p-obj-type :
    when 'скл':U
    then do:
      find first buf_store no-lock
           where buf_store.obj-code = p-obj-code
      no-error .
      if not available buf_store
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найден склад" skip
          "p-obj-type" p-obj-type skip
          "p-obj-code" p-obj-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      assign
        p-host-code = buf_store.host-code
      .
    end.
    when 'маг':U
    then do:
      find first buf_shop no-lock
           where buf_shop.obj-code = p-obj-code
      no-error .
      if not available buf_shop
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найден магазин" skip
          "p-obj-type" p-obj-type skip
          "p-obj-code" p-obj-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      assign
        p-host-code = buf_shop.host-code
      .
    end.
    when 'орг':U
    then do:
      find first buf_sysconf no-lock
           where buf_sysconf.host-code = p-host-code
      no-error.
      if not available buf_sysconf
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найдена СВОЯ фирма" skip
          "p-obj-type" p-obj-type skip
          "p-obj-code" p-obj-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      assign
        p-host-code = buf_sysconf.host-code
      .
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Неизвестный тип объекта" skip
        "p-obj-type" p-obj-type skip
        "p-obj-code" p-obj-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
  if p-obj-type <> 'орг':U then do:
    assign
      l-last-hostcode-exist     = true
      v-last-hostcode-obj-type  = p-obj-type
      v-last-hostcode-obj-code  = p-obj-code
      v-last-hostcode-host-code = p-host-code
    .
  end.
  find first buf_clients no-lock
       where buf_clients.obj-type = 'орг':U
         and buf_clients.obj-code = p-host-code
  no-error.
  if not available buf_clients
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найдена фирма" skip
      "p-host-code" p-host-code skip
    view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    p-host-name               = buf_clients.obj-name
  .
  if p-obj-type <> 'орг':U then do:
    assign
      l-last-hostname-exist     = true
      v-last-hostname-obj-type  = p-obj-type
      v-last-hostname-obj-code  = p-obj-code
      v-last-hostname-host-name = p-host-name
    .
  end.
end.
end procedure.
procedure hostcvat :
do
on error undo, return error return-value
:
  define input  parameter p-host-code   like ub.sysconf.host-code   no-undo .
  define output parameter p-cons-vat-pc like ub.sysconf.cons-vat-pc no-undo .
  define buffer buf_sysconf   for ub.sysconf.
  define variable vss-description as character no-undo initial "hostcvat-01: Консигнационный НДС для фирмы".
  find first buf_sysconf
       where buf_sysconf.host-code = p-host-code
  no-error.
  if error-status :error
  then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена фирма." skip
        "p-host-code" p-host-code skip
      view-as alert-box error .
      undo, return error return-value .
  end.
  assign
    p-cons-vat-pc = buf_sysconf.cons-vat-pc
  .
end.
end procedure.
procedure gdsobjcr :
  define input parameter  p-obj-type  like ub.gds-obj.obj-type  no-undo .
  define input parameter  p-obj-code  like ub.gds-obj.obj-code  no-undo .
  define input parameter  p-artic     like ub.gds-obj.artic     no-undo .
  define input parameter  p-prod-type like ub.gds-obj.prod-type no-undo .
  define input parameter  p-prod-code like ub.gds-obj.prod-code no-undo .
  define parameter buffer buf_gds-obj for ub.gds-obj .
  define variable vss-description as character no-undo initial "gdsobjcr-03: поиск и, при необходимости, cоздание записи товар на объекте".
  define buffer buf_goods for ub.goods .
  define buffer buf_units for ub.units .
  define buffer buf_dis-thbj-rule  for ub.dis-thbj-rule.
  define buffer buf_batchprocess for ub.batchprocess .
  do
  on error undo, return error return-value
  :
    find first buf_gds-obj no-lock
      where buf_gds-obj.obj-type  = p-obj-type
        and buf_gds-obj.obj-code  = p-obj-code
        and buf_gds-obj.artic     = p-artic
        and buf_gds-obj.prod-type = p-prod-type
        and buf_gds-obj.prod-code = p-prod-code
      no-error .
    if not available buf_gds-obj
    then do:
      do transaction
      on error undo, return error return-value
      :
        run gbl/lockgdoc.p
          (input  p-obj-type
          ,input  p-obj-code
          ,input  'gdoc':U
          ,input  'enable':U
          ,buffer buf_batchprocess
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при проверке возможности создания записей товара на объекте" skip
            "Объект" p-obj-type p-obj-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        find first buf_goods share-lock
          where buf_goods.artic     = p-artic
            and buf_goods.prod-type = p-prod-type
            and buf_goods.prod-code = p-prod-code
          no-error .
        if not available buf_goods
        then do:
          message
            "Не найдена запись товара" skip
            "Объект" p-obj-type p-obj-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            "Если товар переименован ждите повторной передачи пакета новостей с новым артикулом товара."
            view-as alert-box .
          undo, return error return-value .
        end.
        find first buf_gds-obj exclusive-lock
          where buf_gds-obj.obj-type  = p-obj-type
            and buf_gds-obj.obj-code  = p-obj-code
            and buf_gds-obj.artic     = p-artic
            and buf_gds-obj.prod-type = p-prod-type
            and buf_gds-obj.prod-code = p-prod-code
          no-error .
        if not available buf_gds-obj
        then do:
          create buf_gds-obj.
          assign
            buf_gds-obj.obj-type  = p-obj-type
            buf_gds-obj.obj-code  = p-obj-code
            buf_gds-obj.artic     = p-artic
            buf_gds-obj.prod-type = p-prod-type
            buf_gds-obj.prod-code = p-prod-code
            buf_gds-obj.grp-name  = buf_goods.grp-name
            buf_gds-obj.stts      = buf_goods.stts
            buf_gds-obj.gds-code  = buf_goods.gds-code
          .
          run gds-objh_write-gds-obj-proc in this-procedure ( buffer buf_gds-obj
                                                            ,integer('1':U)
                                                            ,input ''
                                                            ,input '').
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output buf_gds-obj.host-code
  ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при определении кода фирмы для объекта" skip
              "Объект" p-obj-type p-obj-code skip
              "Артикул" p-artic p-prod-type p-prod-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          define variable v-cur-db-num like ub.db.db-num no-undo .
          define variable v-obj-db-num like ub.db.db-num no-undo .
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-cur-db-num
  ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при определении номера текущей БД" skip
              "Объект" p-obj-type p-obj-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-obj-db-num
  ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при определении номера БД объекта" skip
              "Объект" p-obj-type p-obj-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          if v-cur-db-num = v-obj-db-num
          then do:
            define buffer buf_dis-rule for ub.dis-rule.
            define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
            for each buf_dis-thbj-rule share-lock
              where buf_dis-thbj-rule.discnt-role = 'dflt-gds-temp-disc':U
                and buf_dis-thbj-rule.obj-type    = p-obj-type
                and buf_dis-thbj-rule.obj-code    = p-obj-code
                and string(buf_dis-thbj-rule.rule-num) = buf_dis-thbj-rule.nonunique,
                first buf_dis-rule share-lock where
                      buf_dis-rule.rule-num = buf_dis-thbj-rule.rule-num
                  and buf_dis-rule.rule-num = buf_dis-rule.rl-root,
                first buf_dis-cfg-rule no-lock where
                     buf_dis-cfg-rule.table-name = 'dis-thbj-rule':U
                and buf_dis-cfg-rule.templ-rl-root = buf_dis-rule.templ-rl-root
                and buf_dis-cfg-rule.link-prop = integer('3':U)
             on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
             on stop   undo , return error substitute( "&1. stop", vss-workfile )
             on endkey undo , return error substitute( "&1. endkey", vss-workfile )
             :
              run disgdsru-write  in this-procedure (
                  input p-obj-type
                  ,input p-obj-code
                  ,input buf_goods.gds-code
                  ,input buf_dis-thbj-rule.pos-type
                  ,input ?
                  ,input buf_dis-rule.templ-rl-root
                  ,input buf_dis-cfg-rule.time-templ-rl-root
                  ,input buf_dis-rule.rule-num
                  ,input ""
                  ) no-error.
              if error-status :error
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Ошибка при создании скидки товара на объекте" skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Код товара" buf_goods.gds-code
                  "Правило скидки" buf_dis-thbj-rule.rule-num
                  error-status :get-message(1) skip
                  return-value skip
                  view-as alert-box error .
                undo, return error return-value .
              end.
              leave.
            end.
          end.
          find buf_units no-lock
            where buf_units.unit-name = buf_goods.unit-base
            no-error .
          if not available buf_units
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Не найдена базовая единица измерения" skip
              "Объект" p-obj-type p-obj-code skip
              "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
              "Базовая единица измерения" buf_goods.unit-base skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          define variable v-cp as logical no-undo .
          v-cp = ?.
          if v-cp = ?
          and lookup('сер':U, buf_units.type) > 0
          then do:
            v-cp = yes.
          end.
          if v-cp = ?
          and (lookup('вес':U, buf_units.type) > 0
          or buf_goods.gds-type = 'у':U) then do:
            v-cp = no.
          end.
          if v-cp = ? then do:
            define variable v-is-petrolium as logical no-undo .
            define variable v-is-pieces as logical no-undo .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input p-artic
  ,  input p-prod-type
  ,  input p-prod-code
  , output v-is-petrolium
  , output v-is-pieces
  ) .
            if v-is-petrolium and
            not v-is-pieces then do:
              v-cp = no.
            end.
          end.
          if v-cp = ? then do:
            define buffer buf_gds-prt for ub.gds-prt.
            FIND FIRST buf_gds-prt No-LOCK WHERE
                  buf_gds-prt.upper-code = buf_goods.prt-root No-ERROR.
            if available buf_gds-prt
            and buf_gds-prt.node-name <> '_Пустая шкала':U  then do:
              define variable l-doc-prt as logical no-undo .
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'doc-prt=request':u
  ,output l-doc-prt
  ) no-error .
            end.
            IF NOT AVAIL buf_gds-prt
            OR (buf_gds-prt.node-name <> '_Пустая шкала':U and l-doc-prt) then do:
              v-cp = no.
            end.
          end.
          if v-cp = ? then do:
            define variable v-attr-value as character no-undo .
            define variable v-attr-type as character no-undo .
            run gds-attr-value in this-procedure
              (input  buf_gds-obj.gds-code
              ,input  'cash-parts':U
              ,output v-attr-value
              ,output v-attr-type
              ) .
            assign
              v-cp = lookup(v-attr-value, 'true,yes':u) > 0
            .
          end.
          assign
          buf_gds-obj.cash-parts = v-cp
          .
          if  lookup('топ':U,  buf_units.type) > 0
          and lookup('дро':U, buf_units.type) > 0
          then do:
            assign
              buf_gds-obj.place-rsrv = true
            .
          end.
          if lookup('вес':U, buf_units.type) > 0
          then do:
            run sclcdattr in this-procedure
              (input  buf_goods.gds-code
              ,input  p-obj-type
              ,input  p-obj-code
              ,input  ?
              ,input  yes
              ) no-error.
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при создании атрибута ВЕСОВОЙ КОД ТОВАРА НА ОБЪЕКТЕ" skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                "Код товара" buf_goods.gds-code
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error return-value .
            end.
          end.
          define variable v-exist as logical no-undo .
          run gds-attr-exist in this-procedure ( input buf_gds-obj.gds-code
                                                ,input  'dflt-insalepr':U
                                                ,output v-exist).
          if v-exist then do:
            run gds-attr-value in this-procedure
              (input  buf_gds-obj.gds-code
              ,input  'dflt-insalepr':U
              ,output v-attr-value
              ,output v-attr-type
              ) .
            buf_gds-obj.insalepr = integer(logical(v-attr-value)).
          end.
          assign
            buf_gds-obj.first-doc = today
            buf_gds-obj.last-doc  = today
          .
          define buffer buf_prt-obj for ub.prt-obj .
          for each buf_prt-obj no-lock
            where buf_prt-obj.obj-type  = p-obj-type
              and buf_prt-obj.obj-code  = p-obj-code
              and buf_prt-obj.artic     = p-artic
              and buf_prt-obj.prod-type = p-prod-type
              and buf_prt-obj.prod-code = p-prod-code
          on error undo, return error return-value
          :
            if buf_prt-obj.fact-qnty <> 0
            or buf_prt-obj.free-qnty <> 0
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при создании товара на объекте" skip
                "Уже существует признак на объекте с ненулевыми количествами" skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                "Ссылка на шкалу" buf_prt-obj.prt-code skip
                "Фактическое количество" buf_prt-obj.fact-qnty skip
                "Свободное количество" buf_prt-obj.free-qnty skip
                view-as alert-box error .
              undo, return error return-value .
            end.
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure gohist :
  define input  parameter p-obj-type           as character no-undo .
  define input  parameter p-obj-code           as integer   no-undo .
  define input  parameter p-gds-code           as integer   no-undo .
  define input  parameter p-action-type        as character no-undo .
  define input  parameter p-fact-qnty          as decimal   no-undo .
  define input  parameter p-fact-cli-qnty      as decimal   no-undo .
  define input  parameter p-fact-base          as decimal   no-undo .
  define input  parameter p-fact-rubl          as decimal   no-undo .
  define input  parameter p-fact-sale          as decimal   no-undo .
  define input  parameter p-old-fact-qnty      as decimal   no-undo .
  define input  parameter p-old-fact-cli-qnty  as decimal   no-undo .
  define input  parameter p-old-fact-base      as decimal   no-undo .
  define input  parameter p-old-fact-rubl      as decimal   no-undo .
  define input  parameter p-old-fact-sale      as decimal   no-undo .
  define input  parameter p-source-type        as character no-undo .
  define input  parameter p-source-ref         as character no-undo .
  define input  parameter p-source-date        as date      no-undo .
  define input  parameter p-corr-user-db-num   as integer   no-undo .
  define input  parameter p-corr-user-name     as character no-undo .
  define input  parameter p-corr-date          as date      no-undo .
  define input  parameter p-corr-time          as integer   no-undo .
  define input  parameter p-corr-time-str      as character no-undo .
  define variable v-new-chip-num as integer   no-undo .
  define buffer buf_c-gds-obj for ub.c-gds-obj .
  do
  for buf_c-gds-obj
  transaction
  on error undo, return error return-value
  :
    find last buf_c-gds-obj exclusive-lock
      where buf_c-gds-obj.obj-type = p-obj-type
        and buf_c-gds-obj.obj-code = p-obj-code
        and buf_c-gds-obj.gds-code = p-gds-code
      use-index pi
      no-error .
    if available buf_c-gds-obj
    then do:
      assign
        v-new-chip-num = buf_c-gds-obj.chip-num + 1
      .
    end.
    else do:
      assign
        v-new-chip-num = 1
      .
    end.
    create buf_c-gds-obj .
    assign
      buf_c-gds-obj.obj-type          = p-obj-type
      buf_c-gds-obj.obj-code          = p-obj-code
      buf_c-gds-obj.gds-code          = p-gds-code
      buf_c-gds-obj.chip-num          = v-new-chip-num
      buf_c-gds-obj.action-type       = p-action-type
      buf_c-gds-obj.fact-qnty         = p-fact-qnty
      buf_c-gds-obj.fact-cli-qnty     = p-fact-cli-qnty
      buf_c-gds-obj.fact-base         = p-fact-base
      buf_c-gds-obj.fact-rubl         = p-fact-rubl
      buf_c-gds-obj.fact-sale         = p-fact-sale
      buf_c-gds-obj.old-fact-qnty     = p-old-fact-qnty
      buf_c-gds-obj.old-fact-cli-qnty = p-old-fact-cli-qnty
      buf_c-gds-obj.old-fact-base     = p-old-fact-base
      buf_c-gds-obj.old-fact-rubl     = p-old-fact-rubl
      buf_c-gds-obj.old-fact-sale     = p-old-fact-sale
      buf_c-gds-obj.source-type       = p-source-type
      buf_c-gds-obj.source-ref        = p-source-ref
      buf_c-gds-obj.source-date       = p-source-date
      buf_c-gds-obj.corr-user-db-num  = p-corr-user-db-num
      buf_c-gds-obj.corr-user-name    = p-corr-user-name
      buf_c-gds-obj.corr-date         = p-corr-date
      buf_c-gds-obj.corr-time         = p-corr-time
      buf_c-gds-obj.corr-time-str     = p-corr-time-str
    .
  end.
end procedure.
procedure plgohist :
  define input  parameter p-obj-type           as character no-undo .
  define input  parameter p-obj-code           as integer   no-undo .
  define input  parameter p-pl-code            as integer   no-undo .
  define input  parameter p-gds-code           as integer   no-undo .
  define input  parameter p-action-type        as character no-undo .
  define input  parameter p-fact-qnty          as decimal   no-undo .
  define input  parameter p-cli-qnty           as decimal   no-undo .
  define input  parameter p-free-qnty          as decimal   no-undo .
  define input  parameter p-cli-fact-qnty      as decimal   no-undo .
  define input  parameter p-cli-free-qnty      as decimal   no-undo .
  define input  parameter p-old-fact-qnty      as decimal   no-undo .
  define input  parameter p-old-cli-qnty       as decimal   no-undo .
  define input  parameter p-old-free-qnty      as decimal   no-undo .
  define input  parameter p-old-cli-fact-qnty  as decimal   no-undo .
  define input  parameter p-old-cli-free-qnty  as decimal   no-undo .
  define input  parameter p-source-type        as character no-undo .
  define input  parameter p-source-ref         as character no-undo .
  define input  parameter p-source-date        as date      no-undo .
  define input  parameter p-corr-user-db-num   as integer   no-undo .
  define input  parameter p-corr-user-name     as character no-undo .
  define input  parameter p-corr-date          as date      no-undo .
  define input  parameter p-corr-time          as integer   no-undo .
  define input  parameter p-corr-time-str      as character no-undo .
  define variable v-new-chip-num as integer   no-undo .
  define buffer buf_c-pl-gds-obj for ub.c-pl-gds-obj .
  do
  for buf_c-pl-gds-obj
  transaction
  on error undo, return error return-value
  :
    find last buf_c-pl-gds-obj exclusive-lock
      where buf_c-pl-gds-obj.obj-type = p-obj-type
        and buf_c-pl-gds-obj.obj-code = p-obj-code
        and buf_c-pl-gds-obj.gds-code = p-gds-code
        and buf_c-pl-gds-obj.pl-code = p-pl-code
      use-index pi
      no-error .
    if available buf_c-pl-gds-obj
    then do:
      assign
        v-new-chip-num = buf_c-pl-gds-obj.chip-num + 1
      .
    end.
    else do:
      assign
        v-new-chip-num = 1
      .
    end.
    create buf_c-pl-gds-obj .
    assign
      buf_c-pl-gds-obj.obj-type          = p-obj-type
      buf_c-pl-gds-obj.obj-code          = p-obj-code
      buf_c-pl-gds-obj.gds-code          = p-gds-code
      buf_c-pl-gds-obj.pl-code           = p-pl-code
      buf_c-pl-gds-obj.chip-num          = v-new-chip-num
      buf_c-pl-gds-obj.action-type       = p-action-type
      buf_c-pl-gds-obj.fact-qnty         = p-fact-qnty
      buf_c-pl-gds-obj.cli-qnty          = p-cli-qnty
      buf_c-pl-gds-obj.free-qnty         = p-free-qnty
      buf_c-pl-gds-obj.cli-fact-qnty     = p-cli-fact-qnty
      buf_c-pl-gds-obj.cli-free-qnty     = p-cli-free-qnty
      buf_c-pl-gds-obj.old-fact-qnty     = p-old-fact-qnty
      buf_c-pl-gds-obj.old-cli-qnty      = p-old-cli-qnty
      buf_c-pl-gds-obj.old-free-qnty     = p-old-free-qnty
      buf_c-pl-gds-obj.old-cli-fact-qnty = p-old-cli-fact-qnty
      buf_c-pl-gds-obj.old-cli-free-qnty = p-old-cli-free-qnty
      buf_c-pl-gds-obj.source-type       = p-source-type
      buf_c-pl-gds-obj.source-ref        = p-source-ref
      buf_c-pl-gds-obj.source-date       = p-source-date
      buf_c-pl-gds-obj.corr-user-db-num  = p-corr-user-db-num
      buf_c-pl-gds-obj.corr-user-name    = p-corr-user-name
      buf_c-pl-gds-obj.corr-date         = p-corr-date
      buf_c-pl-gds-obj.corr-time         = p-corr-time
      buf_c-pl-gds-obj.corr-time-str     = p-corr-time-str
    .
  end.
end procedure.
procedure prtobjcr :
  define input parameter  v-obj-type   like ub.prt-obj.obj-type  no-undo .
  define input parameter  v-obj-code   like ub.prt-obj.obj-code  no-undo .
  define input parameter  v-artic      like ub.prt-obj.artic     no-undo .
  define input parameter  v-prod-type  like ub.prt-obj.prod-type no-undo .
  define input parameter  v-prod-code  like ub.prt-obj.prod-code no-undo .
  define input parameter  v-prt-code   like ub.prt-obj.prt-code  no-undo .
  define parameter buffer buf_prt-obj  for  ub.prt-obj .
  define variable vss-description as character no-undo initial "prtobjcr-02: поиск/создание записи о признаке на объекте".
  find first buf_prt-obj no-lock
    where buf_prt-obj.obj-type  = v-obj-type
      and buf_prt-obj.obj-code  = v-obj-code
      and buf_prt-obj.artic     = v-artic
      and buf_prt-obj.prod-type = v-prod-type
      and buf_prt-obj.prod-code = v-prod-code
      and buf_prt-obj.prt-code  = v-prt-code
    no-error.
  if not available buf_prt-obj
  then do:
    do transaction
    on error undo, return error return-value
    :
      create buf_prt-obj.
      assign
        buf_prt-obj.obj-type  = v-obj-type
        buf_prt-obj.obj-code  = v-obj-code
        buf_prt-obj.artic     = v-artic
        buf_prt-obj.prod-type = v-prod-type
        buf_prt-obj.prod-code = v-prod-code
        buf_prt-obj.prt-code  = v-prt-code
      .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtobjup in g#library
  (buffer buf_prt-obj
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при обновлении информации в признаке на объекте" skip
          "Объект" v-obj-type v-obj-code skip
          "Артикул" v-artic v-prod-type v-prod-code skip
          "Признак" v-prt-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.
end procedure.
procedure prtobjup :
  define parameter buffer buf_prt-obj for ub.prt-obj .
  define variable vss-description as character no-undo initial "prtobjup-02: обновление информации в признаке товара на объекте".
  define variable v-root-node     like ub.prt-obj.prt-code no-undo .
  define variable l-terminal-prt  as logical no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_prt-obj.obj-type
  ,input  buf_prt-obj.obj-code
  ,output buf_prt-obj.host-code
  ) no-error .
    if error-status :error
    then do:
      undo, return error
        "Ошибка при определении кода фирмы для объекта"
        .
    end.
    define buffer buf_goods    for ub.goods    .
    find first buf_goods no-lock
      where buf_goods.artic     = buf_prt-obj.artic
        and buf_goods.prod-type = buf_prt-obj.prod-type
        and buf_goods.prod-code = buf_prt-obj.prod-code
      no-error .
    if not available buf_goods
    then do:
      undo, return error
        "Не найден товар"
        .
    end.
    define buffer buf_gds-prt for ub.gds-prt .
    find first buf_gds-prt no-lock
      where buf_gds-prt.node-code = buf_prt-obj.prt-code
      no-error .
    if not available buf_gds-prt
    then do:
      undo, return error
        "Не найден признак"
       .
    end.
    if buf_gds-prt.prt-root <> buf_goods.prt-root
    then do:
      undo, return error
        "Задан код признака из шкалы, которая не принадлежит товару" + chr(10)
        + "Код шкалы товара" + string(buf_goods.prt-root)
        + "Код шкалы признака" + string(buf_gds-prt.prt-root)
        .
    end.
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  buf_prt-obj.artic
  ,input  buf_prt-obj.prod-type
  ,input  buf_prt-obj.prod-code
  ,output v-root-node
  ) no-error .
    if error-status :error
    then do:
      undo, return error
        "Ошибка при определении корня шкалы для товара"
        .
    end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  buf_prt-obj.prt-code
  ,input  'terminal-prt=request':u
  ,output l-terminal-prt
  ) no-error .
    if error-status :error
    then do:
      undo, return error
        "Ошибка при определении атрибута признака"
        .
    end.
    assign
      buf_prt-obj.is-term = l-terminal-prt
    .
    if  buf_prt-obj.prt-code <> v-root-node
    and l-terminal-prt = false
    then do:
      assign
        buf_prt-obj.price-sale = ?
      .
    end.
    else do:
      define buffer buf_bar-code for ub.bar-code .
      define variable v-is-new as logical no-undo .
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run barcodcr in g#library
  (input  buf_goods.gds-code
  ,input  buf_prt-obj.prt-code
  ,input  '':U
  ,input  '':U
  ,input  buf_goods.unit-base
  ,input  1
  ,output v-is-new
  ,buffer buf_bar-code
  ) no-error .
      if error-status :error
      then do:
        undo, return error
          "Ошибка при поиске бар-кода"
          .
      end.
      define variable v-doc-num    like ub.price-list.doc-num    no-undo .
      define variable v-price-sale like ub.price-list.price-sale no-undo .
      define variable v-road-tax   like ub.price-list.road-tax   no-undo .
      define variable v-excise     like ub.price-list.excise     no-undo .
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf_prt-obj.obj-type
  ,input  buf_prt-obj.obj-code
  ,input  buf_bar-code.b-code
  ,input  0
  ,input  0
  ,output v-doc-num
  ,output v-price-sale
  ,output v-road-tax
  ,output v-excise
  ) no-error .
      if error-status :error
      then do:
        undo, return error
          "Ошибка при определение цены признака на объекте"
          .
      end.
      if v-price-sale = ?
      then do:
        assign
          buf_prt-obj.price-sale = 0
        .
      end.
      else do:
        assign
          buf_prt-obj.price-sale = v-price-sale
        .
      end.
    end.
    if buf_prt-obj.fact-qnty = ?
    or buf_prt-obj.free-qnty = ?
    then do:
      undo, return error
        "В признаке на объекте заданы неопределенные количества"
        .
    end.
  end.
end procedure.
procedure gdscr :
  define input parameter p-obj-type       like ub.prt-obj.obj-type   no-undo .
  define input parameter p-obj-code       like ub.prt-obj.obj-code   no-undo .
  define input parameter p-artic          like ub.prt-obj.artic      no-undo .
  define input parameter p-prod-type      like ub.prt-obj.prod-type  no-undo .
  define input parameter p-prod-code      like ub.prt-obj.prod-code  no-undo .
  define input parameter p-root-node      like ub.prt-obj.prt-code   no-undo .
  define variable vss-description as character no-undo initial "gdscr-01: поиск/создание записей о товаре в базе данных".
  define parameter buffer buf_gds-obj  for ub.gds-obj .
  define parameter buffer buf_prt-obj  for ub.prt-obj .
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Невозможно найти gds-obj" skip
      "p-obj-type"  p-obj-type  skip
      "p-obj-code"  p-obj-code  skip
      "p-artic"     p-artic     skip
      "p-prod-type" p-prod-type skip
      "p-prod-code" p-prod-code skip
      "p-root-node" p-root-node skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box.
    undo, return error return-value .
  end.
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  p-root-node
  ,buffer buf_prt-obj
  ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Невозможно найти prt-obj для корневого признака" skip
      "p-obj-type"  p-obj-type  skip
      "p-obj-code"  p-obj-code  skip
      "p-artic"     p-artic     skip
      "p-prod-type" p-prod-type skip
      "p-prod-code" p-prod-code skip
      "p-root-node" p-root-node skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box.
    undo, return error return-value .
  end.
end procedure.
procedure gdsat :
  do
  on error undo, return error return-value
  :
    define input  parameter p-artic            like ub.goods.artic     no-undo .
    define input  parameter p-prod-type        like ub.goods.prod-type no-undo .
    define input  parameter p-prod-code        like ub.goods.prod-code no-undo .
    define input  parameter p-action           as character            no-undo .
    define output parameter p-return-attribute as logical              no-undo .
    define variable vss-description as character no-undo initial "gdsat-03: Получить атрибут товара".
    define variable ind      as integer   no-undo .
    define variable v-action as character no-undo .
    define buffer buf_goods for ub.goods .
    define buffer buf_units for ub.units .
    for first buf_goods field(gds-code) no-lock
      where buf_goods.artic     = p-artic
        and buf_goods.prod-type = p-prod-type
        and buf_goods.prod-code = p-prod-code:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscdat in g#library
  (input  buf_goods.gds-code
  ,input  p-action
  ,output p-return-attribute
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найден товар" skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "Действие" p-action skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.
end procedure.
procedure gdscdat :
  do
  on error undo, return error return-value
  :
    define input  parameter p-gds-code         like ub.goods.gds-code  no-undo .
    define input  parameter p-action           as character            no-undo .
    define output parameter p-return-attribute as logical              no-undo .
    define variable vss-description as character no-undo initial "gdscdat-01: Получить атрибут товара".
    define variable ind      as integer   no-undo .
    define variable v-action as character no-undo .
    define buffer buf_goods for ub.goods .
    define buffer buf_units for ub.units .
    find first buf_goods no-lock
      where buf_goods.gds-code = p-gds-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Код товара" p-gds-code skip
        "Действие" p-action skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    define variable v-num-entries-p-action as integer no-undo .
    assign
      v-num-entries-p-action = num-entries(p-action)
    .
    do ind = 1 to v-num-entries-p-action
    :
      assign
        v-action = entry(ind, p-action)
      .
      case v-action :
        when 'gds-goods=request':u
        then do:
          assign
            p-return-attribute = (buf_goods.gds-type = 'т':U)
          .
        end.
        when 'empty-scale=request':u
        then do:
          define variable v-root-node   like ub.gds-dtl.prt-code no-undo .
          define variable l-empty-scale as logical no-undo .
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsrtnod in g#library
  (input  p-gds-code
  ,output v-root-node
  ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при определении корневого признака шкалы" skip
              "Код товара" p-gds-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  v-root-node
  ,input  'empty-scale=request':u
  ,output l-empty-scale
  ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при определении атрибута шкалы" skip
              "Код товара" p-gds-code skip
              "Код признака" v-root-node skip
              "Запрашивался атрибут" "empty-scale=request" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            p-return-attribute = l-empty-scale
          .
        end.
        when 'serial=request':u
        then do:
          find first buf_units no-lock
            where buf_units.unit-name = buf_goods.unit-base
            no-error .
          if not available buf_units
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Не найдена базовая единица измерения" skip
              "Код товара" p-gds-code skip
              "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
              "Базовая единица измерения" buf_goods.unit-base skip
              view-as alert-box .
            undo, return error return-value .
          end.
          assign
            p-return-attribute = (lookup('сер':U, buf_units.type) > 0)
          .
        end.
        when 'twounit=request':u
        then do:
          find buf_units no-lock
            where buf_units.unit-name = buf_goods.unit-base
            no-error .
          if not available buf_units
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Не найдена базовая единица измерения" skip
              "Код товара" p-gds-code skip
              "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
              "Базовая единица измерения" buf_goods.unit-base skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            p-return-attribute = (lookup('2ед':U, buf_units.type) > 0)
          .
        end.
        when 'bottle=request':u
        then do:
          find buf_units no-lock
            where buf_units.unit-name = buf_goods.unit-base
            no-error .
          if not available buf_units
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Не найдена базовая единица измерения" skip
              "Код товара" p-gds-code skip
              "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
              "Базовая единица измерения" buf_goods.unit-base skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            p-return-attribute = (lookup('сте':U, buf_units.type) > 0)
          .
        end.
        when 'alcohol-prod=request':u
        then do:
          define variable v-attr-value as character no-undo .
          define variable v-attr-type  as character no-undo .
          run gds-attr-value in this-procedure
            (input  p-gds-code
            ,input  'alcohol-prod':U
            ,output v-attr-value
            ,output v-attr-type
            ) .
          assign
            p-return-attribute = lookup(v-attr-value, 'true,yes':u) > 0
          .
        end.
        when 'mercur_FGIS=request':u
        then do:
          run gds-attr-value in this-procedure
            (input  p-gds-code
            ,input  'mercur_FGIS':U
            ,output v-attr-value
            ,output v-attr-type
            ) .
          assign
            p-return-attribute = lookup(v-attr-value, 'true,yes':u) > 0
          .
        end.
        when 'production-only=request':u
        then do:
          run gds-attr-value in this-procedure
            (input  p-gds-code
            ,input  'production-only':U
            ,output v-attr-value
            ,output v-attr-type
            ) .
          assign
            p-return-attribute = lookup(v-attr-value, 'true,yes':u) > 0
          .
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестный параметр вызова." skip
            "Код товара" p-gds-code skip
            "Список действий" p-action skip
            "Действие" v-action skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end case .
    end.
  end.
end procedure.
procedure gdsobjat :
  define input  parameter p-obj-type         like ub.gds-obj.obj-type  no-undo .
  define input  parameter p-obj-code         like ub.gds-obj.obj-code  no-undo .
  define input  parameter p-artic            like ub.gds-obj.artic     no-undo .
  define input  parameter p-prod-type        like ub.gds-obj.prod-type no-undo .
  define input  parameter p-prod-code        like ub.gds-obj.prod-code no-undo .
  define input  parameter p-action           as character no-undo .
  define output parameter p-return-attribute as logical no-undo .
  define variable vss-description as character no-undo initial "gdsobjat-02: задает/получает признаки товара на объекте".
  define variable ind      as integer no-undo .
  define variable v-action as character no-undo .
  define variable l-find-gds-obj as logical no-undo initial false .
  define buffer buf_gds-obj for ub.gds-obj .
  define variable v-num-entries-p-action as integer no-undo .
  assign
    v-num-entries-p-action = num-entries(p-action)
  .
  do ind = 1 to v-num-entries-p-action
  :
    assign
      v-action = entry(ind, p-action)
    .
    if lookup(v-action, "in-ov=request,inv-on=request,ov-on=request,exist-gds-obj=request") > 0
    then do:
      find first buf_gds-obj no-lock
        where buf_gds-obj.obj-type  = p-obj-type
          and buf_gds-obj.obj-code  = p-obj-code
          and buf_gds-obj.artic     = p-artic
          and buf_gds-obj.prod-type = p-prod-type
          and buf_gds-obj.prod-code = p-prod-code
        no-error .
    end.
    else do:
      if l-find-gds-obj <> true
      then do:
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно найти gds-obj" skip
            "p-obj-type"  p-obj-type  skip
            "p-obj-code"  p-obj-code  skip
            "p-artic"     p-artic     skip
            "p-prod-type" p-prod-type skip
            "p-prod-code" p-prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        assign
          l-find-gds-obj = true
        .
      end.
    end.
    case v-action :
      when "exist-gds-obj=request"
      then do:
        assign
          p-return-attribute = (available buf_gds-obj)
        .
      end.
      when "in-ov=true" or
      when "in-ov=yes"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj exclusive-lock .
          if buf_gds-obj.in-ov <> true
          then do:
            assign
              buf_gds-obj.in-ov = true
            .
          end.
          assign
            p-return-attribute = buf_gds-obj.in-ov
          .
        end.
      end.
      when "in-ov=false" or
      when "in-ov=no"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj exclusive-lock .
          if buf_gds-obj.in-ov <> false
          then do:
            assign
              buf_gds-obj.in-ov = false
            .
          end.
          assign
            p-return-attribute = buf_gds-obj.in-ov
          .
        end.
      end.
      when "in-ov=request"
      then do:
        if available buf_gds-obj
        then do:
          assign
            p-return-attribute = buf_gds-obj.in-ov
          .
        end.
        else do:
          assign
            p-return-attribute = false
          .
        end.
      end.
      when "in-ov=request:exclusive"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj exclusive-lock .
          assign
            p-return-attribute = buf_gds-obj.in-ov
          .
        end.
      end.
      when "in-ov=request:share"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj share-lock .
          assign
            p-return-attribute = buf_gds-obj.in-ov
          .
        end.
      end.
      when "inv-on=true" or
      when "inv-on=yes"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj exclusive-lock .
          if buf_gds-obj.inv-on <> true
          then do:
            assign
              buf_gds-obj.inv-on = true
            .
          end.
          else do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при установке признака 'Товар находится в инвентаризации'."
              "p-obj-type"  p-obj-type  skip
              "p-obj-code"  p-obj-code  skip
              "p-artic"     p-artic     skip
              "p-prod-type" p-prod-type skip
              "p-prod-code" p-prod-code skip
              "v-action"    v-action    skip
              "p-action"    p-action    skip
              "gds-obj.inv-on" buf_gds-obj.inv-on skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            p-return-attribute = buf_gds-obj.inv-on
          .
        end.
      end.
      when "inv-on=false" or
      when "inv-on=no"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj exclusive-lock .
          if buf_gds-obj.inv-on <> false
          then do:
            assign
              buf_gds-obj.inv-on = false
            .
          end.
          else do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при сбрасывании признака 'Товар находится в инвентаризации'."
              "p-obj-type"  p-obj-type  skip
              "p-obj-code"  p-obj-code  skip
              "p-artic"     p-artic     skip
              "p-prod-type" p-prod-type skip
              "p-prod-code" p-prod-code skip
              "v-action"    v-action    skip
              "p-action"    p-action    skip
              "gds-obj.inv-on" buf_gds-obj.inv-on skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            p-return-attribute = buf_gds-obj.inv-on
          .
        end.
      end.
      when "inv-on=request"
      then do:
        if available buf_gds-obj
        then do:
          assign
            p-return-attribute = buf_gds-obj.inv-on
          .
        end.
        else do:
          assign
            p-return-attribute = false
          .
        end.
      end.
      when "inv-on=request:exclusive"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj exclusive-lock .
          assign
            p-return-attribute = buf_gds-obj.inv-on
          .
        end.
      end.
      when "inv-on=request:share"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj exclusive-lock .
          assign
            p-return-attribute = buf_gds-obj.inv-on
          .
        end.
      end.
      when "ov-on=true" or
      when "ov-on=yes"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj exclusive-lock .
          if buf_gds-obj.ov-on <> true
          then do:
            assign
              buf_gds-obj.ov-on = true
            .
          end.
          else do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при установке признака 'Товар находится в переоценке'."
              "p-obj-type"  p-obj-type  skip
              "p-obj-code"  p-obj-code  skip
              "p-artic"     p-artic     skip
              "p-prod-type" p-prod-type skip
              "p-prod-code" p-prod-code skip
              "v-action"    v-action    skip
              "p-action"    p-action    skip
              "gds-obj.ov-on" buf_gds-obj.ov-on skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            p-return-attribute = buf_gds-obj.ov-on
          .
        end.
      end.
      when "ov-on=false" or
      when "ov-on=no"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj exclusive-lock .
          if buf_gds-obj.ov-on <> false
          then do:
            assign
              buf_gds-obj.ov-on = false
            .
          end.
          else do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при сбрасывании признака 'Товар находится в переоценке'."
              "p-obj-type"  p-obj-type  skip
              "p-obj-code"  p-obj-code  skip
              "p-artic"     p-artic     skip
              "p-prod-type" p-prod-type skip
              "p-prod-code" p-prod-code skip
              "v-action"    v-action    skip
              "p-action"    p-action    skip
              "gds-obj.ov-on" buf_gds-obj.ov-on skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            p-return-attribute = buf_gds-obj.ov-on
          .
        end.
      end.
      when "ov-on=request"
      then do:
        if available buf_gds-obj
        then do:
          assign
            p-return-attribute = buf_gds-obj.ov-on
          .
        end.
        else do:
          assign
            p-return-attribute = false
          .
        end.
      end.
      when "ov-on=request:exclusive"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj exclusive-lock .
          assign
            p-return-attribute = buf_gds-obj.ov-on
          .
        end.
      end.
      when "ov-on=request:share"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj share-lock .
          assign
            p-return-attribute = buf_gds-obj.ov-on
          .
        end.
      end.
      when "ov-on=message"
      then do:
        run trg/gdsobjms.p
          (input p-obj-type
          ,input p-obj-code
          ,input p-artic
          ,input p-prod-type
          ,input p-prod-code
          ,input "ov-on"
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры gdsobjms.p" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
      when "cash-parts=true" or
      when "cash-parts=yes" or
      when "cash-parts=false" or
      when "cash-parts=no"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj exclusive-lock .
          case v-action:
            when "cash-parts=true"
            or
            when  "cash-parts=yes"  then do:
              define buffer buf_goods for ub.goods.
              find first buf_goods no-lock where
                        buf_goods.gds-code = buf_gds-obj.gds-code no-error.
              if not available buf_goods then do:
                message
                  "Не найдена запись товара" skip
                  "Объект" p-obj-type p-obj-code skip
                  "Код товара" buf_gds-obj.gds-code skip
                  "Если товар переименован ждите повторной передачи пакета новостей с новым артикулом товара."
                  view-as alert-box .
                undo, return error return-value .
              end.
              define buffer buf_units for ub.units.
              find buf_units no-lock
                where buf_units.unit-name = buf_goods.unit-base
                no-error .
              if not available buf_units
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Не найдена базовая единица измерения" skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
                  "Базовая единица измерения" buf_goods.unit-base skip
                  view-as alert-box error .
                undo, return error return-value .
              end.
              define variable v-cp as logical no-undo .
              if lookup('вес':U, buf_units.type) > 0
              then do:
                undo, return error substitute("Нельзя установить флаг продажи по партиям для весового товара. Код товара &1"
                                              , buf_gds-obj.gds-code).
              end.
              if buf_goods.gds-type = 'у':U then do:
                undo, return error substitute("Нельзя установить флаг продажи по партиям для услуги. Код товара &1"
                                              , buf_gds-obj.gds-code).
              end.
              define variable v-is-petrolium as logical no-undo .
              define variable v-is-pieces as logical no-undo .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input p-artic
  ,  input p-prod-type
  ,  input p-prod-code
  , output v-is-petrolium
  , output v-is-pieces
  ) .
              if v-is-petrolium and
              not v-is-pieces then do:
                undo, return error substitute("Нельзя установить флаг продажи по партиям для топливного товара. Код товара &1"
                                              , buf_gds-obj.gds-code).
              end.
              define buffer buf_gds-prt for ub.gds-prt.
              FIND FIRST buf_gds-prt No-LOCK WHERE
                    buf_gds-prt.upper-code = buf_goods.prt-root No-ERROR.
              if available buf_gds-prt
              and buf_gds-prt.node-name <> '_Пустая шкала':U  then do:
                define variable l-cp-doc-prt as logical no-undo .
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'doc-prt=request':u
  ,output l-cp-doc-prt
  ) no-error .
              end.
              IF NOT AVAIL buf_gds-prt
              OR (buf_gds-prt.node-name <> '_Пустая шкала':U and l-cp-doc-prt) then do:
                undo, return error substitute("Нельзя установить флаг продажи по партиям для партионного товара. Код товара &1"
                                              , buf_gds-obj.gds-code).
              end.
              if buf_gds-obj.cash-parts <> true
              then do:
                run gds-objh_write-gds-obj-proc in this-procedure ( buffer buf_gds-obj
                                                                  ,integer('1':U)
                                                                  ,input ''
                                                                  ,input '').
                assign
                  buf_gds-obj.cash-parts = true
                .
              end.
            end.
            when "cash-parts=false" or
            when "cash-parts=no"
            then do:
              if buf_gds-obj.cash-parts <> false
              then do:
                run gds-objh_write-gds-obj-proc in this-procedure ( buffer buf_gds-obj
                                                                  ,integer('1':U)
                                                                  ,input ''
                                                                  ,input '').
                assign
                  buf_gds-obj.cash-parts = false
                .
              end.
            end.
          end case.
          assign
            p-return-attribute = buf_gds-obj.cash-parts
          .
          define variable v-cur-db-num like ub.db.db-num no-undo .
          define variable v-obj-db-num like ub.db.db-num no-undo .
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-cur-db-num
  ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при определении номера текущей БД" skip
              "Объект" buf_gds-obj.obj-type buf_gds-obj.obj-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          if v-cur-db-num = 0 then do:
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  buf_gds-obj.obj-type
  ,input  buf_gds-obj.obj-code
  ,output v-obj-db-num
  ) no-error .
          end.
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при определении номера БД объекта" skip
              "Объект" buf_gds-obj.obj-type buf_gds-obj.obj-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          if v-obj-db-num <> v-cur-db-num
          or v-cur-db-num > 0 then do:
            define variable v-cmd as character no-undo .
            assign
              v-cmd = "command":U + chr(1)
                      + "create":U + chr(1)
                      + "cash-parts":U + chr(1)
                      + substitute( "&1", buf_gds-obj.obj-type ) + chr(1)
                      + substitute( "&1", buf_gds-obj.obj-code ) + chr(1)
                      + substitute( "&1", buf_gds-obj.artic ) + chr(1)
                      + substitute( "&1", buf_gds-obj.prod-type ) + chr(1)
                      + substitute( "&1", buf_gds-obj.prod-code ) + chr(1)
                      + substitute( "&1", buf_gds-obj.cash-parts ) + chr(1)
            .
            run nws/cr-route.p
              ( input 'send-cmd':U
                ,input v-cmd
                ,input ?
                ,input (if v-cur-db-num > 0
                        then "0"
                        else string(v-obj-db-num)
                        )
              ).
          end.
        end.
      end.
      when "cash-parts=request"
      then do:
        if available buf_gds-obj
        then do:
          assign
            p-return-attribute = buf_gds-obj.cash-parts
          .
        end.
        else do:
          assign
            p-return-attribute = false
          .
        end.
      end.
      when "cash-parts=request:exclusive"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj exclusive-lock .
          assign
            p-return-attribute = buf_gds-obj.cash-parts
          .
        end.
      end.
      when "cash-parts=request:share"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj share-lock .
          assign
            p-return-attribute = buf_gds-obj.cash-parts
          .
        end.
      end.
      when "insalepr=true" or
      when "insalepr=yes" or
      when "insalepr=false" or
      when "insalepr=no"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj exclusive-lock .
          case v-action:
            when "insalepr=true"
            or
            when  "insalepr=yes"  then do:
              if buf_gds-obj.insalepr <> integer('1':U)
              then do:
                run gds-objh_write-gds-obj-proc in this-procedure ( buffer buf_gds-obj
                                                                  ,integer('1':U)
                                                                  ,input ''
                                                                  ,input '').
                assign
                  buf_gds-obj.insalepr = integer('1':U)
                .
              end.
              assign
                p-return-attribute = yes
              .
            end.
            when "insalepr=false" or
            when "insalepr=no"
            then do:
              if buf_gds-obj.insalepr <> integer('0':U)
              then do:
                run gds-objh_write-gds-obj-proc in this-procedure ( buffer buf_gds-obj
                                                                  ,integer('1':U)
                                                                  ,input ''
                                                                  ,input '').
                assign
                  buf_gds-obj.insalepr = integer('0':U)
                .
              end.
              assign
                p-return-attribute = no
              .
            end.
          end case.
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-cur-db-num
  ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при определении номера текущей БД" skip
              "Объект" buf_gds-obj.obj-type buf_gds-obj.obj-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          if v-cur-db-num = 0 then do:
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  buf_gds-obj.obj-type
  ,input  buf_gds-obj.obj-code
  ,output v-obj-db-num
  ) no-error .
          end.
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при определении номера БД объекта" skip
              "Объект" buf_gds-obj.obj-type buf_gds-obj.obj-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          if v-obj-db-num <> v-cur-db-num
          or v-cur-db-num > 0 then do:
            assign
              v-cmd = "command":U + chr(1)
                      + "create":U + chr(1)
                      + "insalepr":U + chr(1)
                      + substitute( "&1", buf_gds-obj.obj-type ) + chr(1)
                      + substitute( "&1", buf_gds-obj.obj-code ) + chr(1)
                      + substitute( "&1", buf_gds-obj.artic ) + chr(1)
                      + substitute( "&1", buf_gds-obj.prod-type ) + chr(1)
                      + substitute( "&1", buf_gds-obj.prod-code ) + chr(1)
                      + substitute( "&1", buf_gds-obj.insalepr ) + chr(1)
            .
            run nws/cr-route.p
              ( input 'send-cmd':U
                ,input v-cmd
                ,input ?
                ,input (if v-cur-db-num > 0
                        then "0"
                        else string(v-obj-db-num)
                        )
              ).
          end.
        end.
      end.
      when "insalepr=request"
      then do:
        if available buf_gds-obj
        then do:
          assign
            p-return-attribute = (if buf_gds-obj.insalepr = integer('1':U)
                                  then yes
                                  else no)
          .
        end.
        else do:
          assign
            p-return-attribute = false
          .
        end.
      end.
      when "insalepr=request:exclusive"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj exclusive-lock .
          assign
            p-return-attribute = (if buf_gds-obj.insalepr = integer('1':U)
                                  then yes
                                  else no)
          .
        end.
      end.
      when "insalepr=request:share"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj share-lock .
          assign
            p-return-attribute = (if buf_gds-obj.insalepr = integer('1':U)
                                  then yes
                                  else no)
          .
        end.
      end.
      when "place-rsrv=true" or
      when "place-rsrv=yes"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj exclusive-lock .
          if buf_gds-obj.place-rsrv <> true
          then do:
            run gds-objh_write-gds-obj-proc in this-procedure ( buffer buf_gds-obj
                                                              ,integer('1':U)
                                                              ,input ''
                                                              ,input '').
            assign
              buf_gds-obj.place-rsrv = true
            .
          end.
          assign
            p-return-attribute = buf_gds-obj.place-rsrv
          .
        end.
      end.
      when "place-rsrv=false" or
      when "place-rsrv=no"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj exclusive-lock .
          if buf_gds-obj.place-rsrv <> false
          then do:
            run gds-objh_write-gds-obj-proc in this-procedure ( buffer buf_gds-obj
                                                              ,integer('1':U)
                                                              ,input ''
                                                              ,input '').
            assign
              buf_gds-obj.place-rsrv = false
            .
          end.
          assign
            p-return-attribute = buf_gds-obj.place-rsrv
          .
        end.
      end.
      when "place-rsrv=request"
      then do:
        if available buf_gds-obj
        then do:
          assign
            p-return-attribute = buf_gds-obj.place-rsrv
          .
        end.
        else do:
          assign
            p-return-attribute = false
          .
        end.
      end.
      when "place-rsrv=request:exclusive"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj exclusive-lock .
          assign
            p-return-attribute = buf_gds-obj.place-rsrv
          .
        end.
      end.
      when "place-rsrv=request:share"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_gds-obj share-lock .
          assign
            p-return-attribute = buf_gds-obj.place-rsrv
          .
        end.
      end.
      when "create-bar-code=request"
      then do:
        define variable l-goods-serial    as logical no-undo .
        define variable l-cash-parts      as logical no-undo .
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'serial=request':u
  ,output l-goods-serial
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при определении атрибута товара" skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            'serial=request':u skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'cash-parts=request':u
  ,output l-cash-parts
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при определении признака товара на объекте" skip
            "Объект" p-obj-type p-obj-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            "Запрашиваемый атрибут" "cash-parts=request":u skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        if l-goods-serial
        or l-cash-parts
        then do:
          assign
            p-return-attribute = true
          .
        end.
        else do:
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ''
  ,input 0
  ,input 'rezerv-global':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
          for each thbjattr_thbj-attr :
              if thbjattr_thbj-attr.prop-code = 'parts-bc'  then p-return-attribute  = thbjattr_thbj-attr.property-value-logical.
          end.
          empty temp-table thbjattr_thbj-attr.
        end.
      end.
      when "cr-root-gds-dtl=request":u
      then do:
        define variable v-root-node   like ub.gds-dtl.prt-code no-undo .
        define variable l-empty-scale as logical   no-undo .
        define variable l-doc-prt     as logical   no-undo .
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-root-node
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при определении корневого признака шкалы" skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  v-root-node
  ,input  'empty-scale=request':u
  ,output l-empty-scale
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при определении атрибута шкалы" skip
            "Код признака" v-root-node skip
            "Запрашивался атрибут" "empty-scale=request" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'doc-prt=request':u
  ,output l-doc-prt
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при определении атрибута объекта" skip
            "Объект" p-obj-type p-obj-code skip
            "Запрашивался атрибут" "doc-prt=request" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        assign
          p-return-attribute = (l-empty-scale = true)
                               or
                               (l-doc-prt = false)
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестное значение параметра v-action " skip
          "v-action" v-action skip
          "p-action" p-action skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.
end procedure.
procedure gdsoattr-increase-pc :
define input parameter p-gds-code like ub.goods.gds-code no-undo .
define input parameter p-obj-type like ub.gds-obj.obj-type no-undo .
define input parameter p-obj-code like ub.gds-obj.obj-code no-undo .
define output parameter p-increase-pc like ub.goods.increase-pc no-undo .
DEFINE VARIABLE v-exist as logical no-undo .
DEFINE VARIABLE v-attr-value as character no-undo .
DEFINE VARIABLE v-attr-type as character no-undo .
define variable vss-description as character no-undo initial "gdsoattr-increase-pc-01: получение значения наценки на объекте".
define buffer buf_goods for ub.goods .
  do
  on error undo, return error return-value
  :
    find first buf_goods no-lock
      where buf_goods.gds-code     = p-gds-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run gdsoattr-exist in this-procedure(
                                      input p-gds-code,
                                      input p-obj-type,
                                      input p-obj-code,
                                      input 'increase-pc':U,
                                      output v-exist).
   if not v-exist
   then do:
      assign
      p-increase-pc = buf_goods.increase-pc
      .
    end.
    else do:
      run gdsoattr-value ( input 'increase-pc':U,
                          input p-gds-code,
                          input p-obj-type,
                          input p-obj-code,
                          output v-attr-value,
                          output v-attr-type ) no-error .
      if not error-status :error
      then do:
        assign
        p-increase-pc = decimal(v-attr-value)
        no-error
        .
      end.
      if error-status :error
      then do:
        message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара на объекте" skip
        "Код товара" p-gds-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.
end procedure.
procedure check-cfg-param :
  define input  parameter p-conf-type     like ub.config.conf-type     no-undo .
  define input  parameter p-param-code    like ub.config.param-code    no-undo .
  define input  parameter p-db-num        like ub.config.db-num        no-undo .
  define input  parameter p-param-value   like ub.config.param-value   no-undo .
  define input  parameter p-beg-date      like ub.config.beg-date      no-undo .
  define input  parameter p-end-date      like ub.config.end-date      no-undo .
  define input  parameter p-param-encoded like ub.config.param-encoded no-undo .
  define input  parameter p-host-code     like ub.config.host-code     no-undo .
  define input  parameter p-obj-type      like ub.config.obj-type      no-undo .
  define input  parameter p-obj-code      like ub.config.obj-code      no-undo .
  define input  parameter p-msg-on        as logical   no-undo .
  define output parameter p-attach-level  as character no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define variable v-ok               as logical   no-undo .
    define variable v-assignment-type  as character no-undo .
    define variable v-assignment-ind   as integer   no-undo .
    define buffer buf_db for ub.db .
    if lookup( p-conf-type, 'к,п':U ) > 0
    then do:
      find first buf_db no-lock
        where buf_db.db-num = p-db-num
        no-error .
      if not available buf_db
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найдена запись таблицы базы данных" skip
          "База данных" p-db-num skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      run check-enc in this-procedure
        (input  p-db-num
        ,input  buf_db.db-key
        ,input  p-param-code
        ,input  p-param-value
        ,input  p-beg-date
        ,input  p-end-date
        ,input  p-param-encoded
        ,output v-ok
        ) no-error.
      if error-status :error
      then do:
        if p-msg-on = true
        then do:
          message
            vss-workfile vss-revision vss-description skip
            substitute ("Параметр &1. Ошибка при проверке кодирования.", p-param-code ) skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        end.
        undo, return error substitute ("Параметр &1. Ошибка при проверке кодирования. &2", p-param-code, error-status :get-message( error-status :num-messages ) ).
      end.
      if v-ok <> true
      then do:
        if p-msg-on = true
        then do:
          message
            vss-workfile vss-revision vss-description skip
            substitute("Некорректное кодированное значение параметра &1", p-param-code) skip
            view-as alert-box error.
        end.
        undo, return error substitute("Некорректное кодированное значение параметра &1", p-param-code).
      end.
      if p-host-code <> 0
      or p-obj-type  <> ""
      or p-obj-code  <> 0
      then do:
        if p-msg-on = true
        then do:
          message
            vss-workfile vss-revision vss-description skip
            substitute("Кодированые параметры могут быть только без привязки! Параметр &1", p-param-code) skip
            view-as alert-box error.
        end.
        undo, return error substitute("Кодированые параметры могут быть только без привязки! Параметр &1", p-param-code).
      end.
      assign
        p-attach-level = 'global':U
      .
    end.
    else do:
      assign
        v-assignment-type = ( if  p-host-code = 0
                              then "0":u
                              else "1":u
                            )
                          + ( if  p-obj-type  = ""
                              and p-obj-code  = 0
                              then "0":u
                              else "1":u
                            )
      .
      assign
        v-assignment-ind = lookup( v-assignment-type, "00,10,11":u )
      .
      if v-assignment-ind = 0
      then do:
        if p-msg-on = TRUE
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Неправильная привязка параметра конфигурации" skip
            "param-code" p-param-code      skip
            "host-code"  p-host-code       skip
            "obj-type"   p-obj-type        skip
            "obj-code"   p-obj-code        skip
            "привязка"   v-assignment-type skip
            view-as alert-box error .
        end.
        undo, return error substitute ("Неправильная привязка параметра конфигурации &1", p-param-code ).
      end.
      assign
        p-attach-level = entry(v-assignment-ind
                              ,'global':U
                              + chr(44) + 'firm':U
                              + chr(44) + 'object':U
                              )
      .
    end.
    if p-beg-date = ?
    or p-end-date = ?
    then do:
      if p-msg-on = true
      then do:
        message
          vss-workfile vss-revision vss-description skip
          substitute("Ошибка задания срока действия параметра &1. Дата начала &2. Дата окончания &3"
                    ,p-param-code
                    ,p-beg-date
                    ,p-end-date
                    ) skip
          view-as alert-box error.
      end.
      undo, return error  substitute("Ошибка задания срока действия параметра &1. Дата начала &2. Дата окончания &3"
                              ,p-param-code
                              ,p-beg-date
                              ,p-end-date
                              ) .
    end.
  end.
end procedure.
procedure confrddb :
  define input  parameter p-code   as character no-undo .
  define input  parameter p-db-num as integer   no-undo .
  define input  parameter h-code   as integer   no-undo .
  define input  parameter o-type   as character no-undo .
  define input  parameter o-code   as integer   no-undo .
  define input  parameter msg-on   as logical   no-undo .
  define output parameter p-value  as character no-undo .
  define output parameter p-type   as character no-undo .
  define variable vss-description as character no-undo initial "confrddb: Чтение параметров конфигурации для заданной БД".
  do
  on error undo, return error return-value
  :
    define variable v-today            as date      no-undo .
    define variable v-time             as integer   no-undo .
    define variable l-object-specified as logical   no-undo .
    define variable v-host-code        as integer   no-undo .
    define variable v-level            as character no-undo .
    define variable v-db-num        as integer   no-undo .
    define buffer buf_config     for ub.config .
    define buffer buf-all_config for ub.config .
    if p-db-num < 0 then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute("Ошибка задания входных параметров. Параметр &1 БД &2", p-code, p-db-num ) skip
        view-as alert-box error.
      undo, return error substitute("&1.&2 Ошибка задания входных параметров. Параметр &3 БД &4", vss-description, chr(10), p-code, p-db-num ) .
    end.
    if p-db-num = ? then do:
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output p-db-num
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении номера базы данных" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
    assign
      p-value            = ?
      l-object-specified = false
    .
        run cur-time in this-procedure
          ( output v-today
           ,output v-time
          ) no-error .
    if length(p-code) > 8
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Длина имени параметра не может превышать 8 символов" skip
        "p-code" p-code skip
        view-as alert-box error .
    end.
    find first buf_config no-lock
      where buf_config.param-code = p-code
        and buf_config.db-num     = p-db-num
      no-error .
    if not available buf_config
    then do:
      if msg-on = TRUE
      then do:
        message
          "Параметр" p-code "отсутствует в БД." skip
          "Параметры задаются через 'АРМ Администратор/Справочники/Настройки и конфигурация системы'" skip
          "или при первоначальной настройке системы" skip
          view-as alert-box error.
      end.
      undo, return error substitute ("Параметр &1 отсутствует в БД. Параметры задаются через 'АРМ Администратор/Справочники/Настройки и конфигурация системы' или при первоначальной настройке системы", p-code ).
    end.
    else do:
      if lookup( buf_config.conf-type, 'к,п':U ) > 0
      and ( buf_config.param-type = 'L':U
            or buf_config.param-type = 'I':U
          )
      then do:
        if error-status :error
        then do:
          if msg-on = TRUE
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при определении текущего времени" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
          end.
          undo, return error "Ошибка при определении текущего времени" .
        end.
        if buf_config.param-type = 'I':U
        then do:
          assign
            p-type  = buf_config.param-type
          .
          for each buf-all_config no-lock
            where buf-all_config.param-code = p-code
              and buf-all_config.host-code  = 0
              and buf-all_config.obj-type   = ""
              and buf-all_config.obj-code   = 0
              and buf-all_config.beg-date   <= v-today
              and buf-all_config.end-date   >= v-today
              and buf-all_config.db-num     = p-db-num
          on error undo, return error return-value
          :
            run check-cfg-param in this-procedure
              ( input buf-all_config.conf-type
               ,input buf-all_config.param-code
               ,input buf-all_config.db-num
               ,input buf-all_config.param-value
               ,input buf-all_config.beg-date
               ,input buf-all_config.end-date
               ,input buf-all_config.param-encoded
               ,input buf-all_config.host-code
               ,input buf-all_config.obj-type
               ,input buf-all_config.obj-code
               ,input msg-on
               ,output v-level
              ) no-error .
            if error-status :error
            then do:
              undo, return error return-value .
            end.
            if p-value = ?
            then do:
              assign
                p-value = buf-all_config.param-value
              .
            end.
            else do:
              assign
                p-value = string( integer( p-value ) + integer( buf-all_config.param-value ) )
              .
            end.
          end.
          if p-value = ?
            or trim( p-value ) = "":U
          then do:
            for each buf-all_config no-lock
              where buf-all_config.param-code = p-code
                and buf-all_config.host-code  = 0
                and buf-all_config.obj-type   = ""
                and buf-all_config.obj-code   = 0
                and buf-all_config.beg-date   <= v-today
                and buf-all_config.end-date   >= v-today
                and buf-all_config.db-num     = p-db-num
            on error undo, return error return-value
            :
              run check-cfg-param in this-procedure
                ( input buf-all_config.conf-type
                 ,input buf-all_config.param-code
                 ,input buf-all_config.db-num
                 ,input buf-all_config.param-value
                 ,input buf-all_config.beg-date
                 ,input buf-all_config.end-date
                 ,input buf-all_config.param-encoded
                 ,input buf-all_config.host-code
                 ,input buf-all_config.obj-type
                 ,input buf-all_config.obj-code
                 ,input msg-on
                 ,output v-level
                ) no-error .
              if error-status :error
              then do:
                undo, return error return-value.
              end.
              if p-value = ?
              then do:
                assign
                  p-value = buf-all_config.param-value
                .
              end.
              else do:
                assign
                  p-value = string( integer( p-value ) + integer( buf-all_config.param-value ) )
                .
              end.
            end.
            if p-value = ?
              or trim( p-value ) = "":U
            then do:
              if msg-on = TRUE
              then do:
                message
                  "Параметр" p-code "действующий в данный момент отсутствует в БД" skip
                  view-as alert-box error.
              end.
              undo, return error substitute ("Параметр &1 действующий в данный момент отсутствует в БД.", p-code ).
            end.
          end.
        end.
        if buf_config.param-type = 'L':U
        then do:
          assign
            p-type  = buf_config.param-type
          .
          find first buf_config no-lock
            where buf_config.param-code = p-code
              and buf_config.host-code  = 0
              and buf_config.obj-type   = ""
              and buf_config.obj-code   = 0
              and buf_config.beg-date   <= v-today
              and buf_config.end-date   >= v-today
              and buf_config.db-num     = p-db-num
              and buf_config.param-value = "yes":U
            no-error .
          if not available buf_config
          then do:
            find first buf_config no-lock
              where buf_config.param-code = p-code
                and buf_config.host-code  = 0
                and buf_config.obj-type   = ""
                and buf_config.obj-code   = 0
                and buf_config.beg-date   <= v-today
                and buf_config.end-date   >= v-today
                and buf_config.db-num     = p-db-num
              no-error .
          end.
          if available buf_config then do:
            run check-cfg-param in this-procedure
              ( input buf_config.conf-type
               ,input buf_config.param-code
               ,input buf_config.db-num
               ,input buf_config.param-value
               ,input buf_config.beg-date
               ,input buf_config.end-date
               ,input buf_config.param-encoded
               ,input buf_config.host-code
               ,input buf_config.obj-type
               ,input buf_config.obj-code
               ,input msg-on
               ,output v-level
              ) no-error .
            if error-status :error
            then do:
              undo, return error return-value .
            end.
            assign
              p-value = buf_config.param-value
            .
          end.
          else do:
            if msg-on = TRUE
            then do:
              message
                "Параметр" p-code "действующий в данный момент отсутствует в БД." skip
                "или имеет ошибочную привязку" skip
                view-as alert-box error.
            end.
            undo, return error substitute ("Параметр &1 действующий в данный момент отсутствует в БД.", p-code ).
          end.
        end.
      end.
      else do:
        if o-type <> ""
          and o-code <> 0
        then do:
          assign
            l-object-specified = true
          .
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  o-type
  ,input  o-code
  ,output v-host-code
  ) no-error .
          if error-status :error
          then do:
            if msg-on = TRUE
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при определении кода фирмы для объекта" skip
                "o-type" o-type skip
                "o-code" o-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
            end.
            undo, return error substitute( "Ошибка при определении кода фирмы для объекта &1 &2", o-type, o-code ) .
          end.
          if h-code = 0
            or h-code = ?
          then do:
            assign
              h-code = v-host-code
            .
          end.
          else do:
            if h-code <> v-host-code
            then do:
              if msg-on = TRUE
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Объект привязки не соответствует фирме для поиска параметра конфигурации" skip
                  "param-code" p-code skip
                  "host-code"  h-code skip
                  "obj-type"   o-type skip
                  "obj-code"   o-code skip
                  view-as alert-box error .
              end.
              undo, return error substitute ("Объект привязки (&1 &2) не соответствует фирме (&3) для поиска параметра конфигурации &4", o-type, o-code, h-code, p-code ).
            end.
          end.
        end.
        find first buf_config no-lock
          where buf_config.param-code = p-code
            and buf_config.host-code  = h-code
            and buf_config.obj-type   = o-type
            and buf_config.obj-code   = o-code
            and buf_config.db-num     = p-db-num
            and buf_config.beg-date   <= v-today
            and buf_config.end-date   >= v-today
        no-error .
        if not available buf_config then
        find first buf_config no-lock
          where buf_config.param-code = p-code
            and buf_config.host-code  = h-code
            and buf_config.obj-type   = o-type
            and buf_config.obj-code   = o-code
            and buf_config.db-num     = p-db-num
        no-error .
        if not available buf_config
        then do:
          if h-code <> 0
          or o-type <> ""
          or o-code <> 0
          then do:
            if l-object-specified
            then do:
              find first buf_config no-lock
                where buf_config.param-code = p-code
                  and buf_config.host-code  = h-code
                  and buf_config.obj-type   = ""
                  and buf_config.obj-code   = 0
                  and buf_config.db-num     = p-db-num
                no-error .
            end.
            if not available buf_config
            then do:
              find first buf_config no-lock
                where buf_config.param-code = p-code
                  and buf_config.host-code  = 0
                  and buf_config.obj-type   = ""
                  and buf_config.obj-code   = 0
                  and buf_config.db-num     = p-db-num
                no-error .
            end.
          end.
        end.
        if available buf_config then do:
          run check-cfg-param in this-procedure
            ( input buf_config.conf-type
             ,input buf_config.param-code
             ,input buf_config.db-num
             ,input buf_config.param-value
             ,input buf_config.beg-date
             ,input buf_config.end-date
             ,input buf_config.param-encoded
             ,input buf_config.host-code
             ,input buf_config.obj-type
             ,input buf_config.obj-code
             ,input msg-on
             ,output v-level
            ) no-error .
          if error-status :error
          then do:
            undo, return error return-value.
          end.
          assign
            p-type  = buf_config.param-type
            p-value = buf_config.param-value
          .
        end.
        else do:
          if msg-on = TRUE
          then do:
            message
              "Параметр" p-code "отсутствует в БД." skip
              "Параметры задаются через 'АРМ Администратор/Справочники/Настройки и конфигурация системы'" skip
              "или при первоначальной настройке системы" skip
              view-as alert-box error.
          end.
          undo, return error substitute ("Параметр &1 отсутствует в БД. Параметры задаются через 'АРМ Администратор/Справочники/Настройки и конфигурация системы' или при первоначальной настройке системы", p-code ).
        end.
      end.
    end.
  end.
end procedure.
procedure conf-rd :
  define input  parameter p-code  as character no-undo .
  define input  parameter h-code  as integer   no-undo .
  define input  parameter o-type  as character no-undo .
  define input  parameter o-code  as integer   no-undo .
  define input  parameter g-name  as character no-undo .
  define input  parameter u-name  as character no-undo .
  define input  parameter e-name  as character no-undo .
  define input  parameter msg-on  as logical   no-undo .
  define output parameter p-value as character no-undo .
  define output parameter p-type  as character no-undo .
  define variable vss-description as character no-undo initial "conf-rd: Чтение параметров конфигурации для текущей БД".
  define variable v-db-num        as integer   no-undo .
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении номера базы данных" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  run confrddb in this-procedure
   ( input p-code
    ,input v-db-num
    ,input h-code
    ,input o-type
    ,input o-code
    ,input msg-on
    ,output p-value
    ,output p-type
   ) no-error .
  if error-status :error then do:
    if error-status :get-message(1) <> "" then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры confrddb" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    undo, return error return-value .
  end.
end procedure.
procedure unitbase :
  define input  parameter p-gds-code  like ub.goods.gds-code  no-undo .
  define output parameter p-unit-base like ub.goods.unit-base no-undo .
  define variable vss-description as character no-undo initial "unitbase-01: определение базовой единицы измерения товара".
  define buffer buf_goods for ub.goods .
  do
  on error undo, return error return-value
  :
    find first buf_goods no-lock
      where buf_goods.gds-code = p-gds-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      p-unit-base = buf_goods.unit-base
    .
  end.
end procedure.
procedure gdsbcode :
  define input  parameter p-gds-code  like ub.bar-code.gds-code  no-undo .
  define input  parameter p-node-code like ub.bar-code.node-code no-undo .
  define output parameter p-b-code    like ub.bar-code.b-code    no-undo .
  define variable vss-description as character no-undo initial "gdsbcode-01: определение первичного бар-кода признака".
  define variable vss-proc-revision as character no-undo initial "library.p gdsbcode-01" .
  define buffer buf_bar-code for ub.bar-code .
  define variable v-unit-base like ub.goods.unit-base no-undo .
  do
  on error undo, return error return-value
  :
    if p-node-code = ?
    then do:
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsrtnod in g#library
  (input  p-gds-code
  ,output p-node-code
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении корневого признака товара" skip
          "Код товара" p-gds-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run unitbase in g#library
  (input  p-gds-code
  ,output v-unit-base
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка определения базовой единицы измерения товара" skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for first buf_bar-code field(b-code) no-lock
      where buf_bar-code.gds-code  = p-gds-code
        and buf_bar-code.node-code = p-node-code
        and buf_bar-code.part-code = ""
        and buf_bar-code.in-code   = ""
        and buf_bar-code.unit-cli  = v-unit-base
        :
    assign
      p-b-code = buf_bar-code.b-code
    .
    end.
    if p-b-code = 0
    then do:
      undo, return error vss-proc-revision + ":" + chr(10)
        + "Не найден первичный бар-кода признака " + chr(10)
        + "Код товара " + string(p-gds-code) + chr(10)
        + "Код признака " + string(p-node-code) + chr(10)
        + "Базовая единица измерения " + string(v-unit-base) + chr(10)
        .
    end.
  end.
end procedure.
procedure gdspcode :
define input  parameter p-gds-code  like ub.bar-code.gds-code  no-undo .
define input  parameter p-node-code like ub.bar-code.node-code no-undo .
define input  parameter p-in-code   like ub.bar-code.in-code   no-undo .
define input  parameter p-part-code like ub.bar-code.part-code   no-undo .
define output parameter p-b-code    like ub.bar-code.b-code    no-undo .
  define variable vss-description as character no-undo initial "gdspcode-01: определение первичного бар-кода партии".
  define variable vss-proc-revision as character no-undo initial "library.p gdspcode-01" .
  define buffer buf_bar-code for ub.bar-code .
  define variable v-unit-base like ub.goods.unit-base no-undo .
do
on error undo, return error return-value
:
    if p-node-code = ?
    then do:
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsrtnod in g#library
  (input  p-gds-code
  ,output p-node-code
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении корневого признака товара" skip
          "Код товара" p-gds-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run unitbase in g#library
  (input  p-gds-code
  ,output v-unit-base
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка определения базовой единицы измерения товара" skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for first buf_bar-code field(b-code) no-lock
      where buf_bar-code.gds-code  = p-gds-code
        and buf_bar-code.node-code = p-node-code
        and buf_bar-code.part-code = p-part-code
        and buf_bar-code.in-code   = p-in-code
        and buf_bar-code.unit-cli  = v-unit-base
        :
        assign
          p-b-code = buf_bar-code.b-code
        .
    end.
    if p-b-code = 0
    then do:
      undo, return error vss-proc-revision + ":" + chr(10)
        + "Не найден первичный бар-код партии " + chr(10)
        + "Код товара " + string(p-gds-code) + chr(10)
        + "Код признака " + string(p-node-code) + chr(10)
        + "Код ПН " + string(p-in-code) + chr(10)
        + "Код партии " + string(p-part-code) + chr(10)
        + "Базовая единица измерения " + string(v-unit-base) + chr(10)
        .
    end.
  end.
end procedure.
procedure partbcod :
  define parameter buffer buf_parts   for ub.parts .
  define output parameter p-b-code    like ub.bar-code.b-code    no-undo .
  define variable vss-description as character no-undo initial "partbcod-01: определение первичного бар-кода признака".
  define variable vss-proc-revision as character no-undo initial "library.p partbcod-01" .
  define buffer buf_goods    for ub.goods .
  define buffer buf_bar-code for ub.bar-code .
  define variable v-root-node like ub.prt-obj.prt-code no-undo .
  do
  on error undo, return error return-value
  :
    find first buf_goods no-lock
      where buf_goods.artic     = buf_parts.artic
        and buf_goods.prod-type = buf_parts.prod-type
        and buf_goods.prod-code = buf_parts.prod-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Артикул товара" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
        "Код партии" recid(buf_parts) skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run prt-root-to-node-code in this-procedure
      (input  buf_goods.prt-root
      ,output v-root-node
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры prt-root-to-node-code" skip
        "Товар" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
        "Указатель на корень шкалы" buf_goods.prt-root skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    find first buf_bar-code no-lock
      where buf_bar-code.gds-code  = buf_goods.gds-code
        and buf_bar-code.node-code = v-root-node
        and buf_bar-code.part-code = buf_parts.part-code
        and buf_bar-code.in-code   = buf_parts.in-code
        and buf_bar-code.unit-cli  = buf_goods.unit-base
      no-error .
    if not available buf_bar-code
    then do:
      undo, return error vss-proc-revision + ":" + chr(10)
        + "Не найден первичный бар-код партии " + chr(10)
        + "Код товара " + string(buf_goods.gds-code) + chr(10)
        + "Код признака " + string(v-root-node) + chr(10)
        + "Код партии " + string(buf_parts.part-code) + chr(10)
        + "Код ПН " + string(buf_parts.in-code) + chr(10)
        + "Базовая единица измерения " + string(buf_goods.unit-base) + chr(10)
        .
    end.
    assign
      p-b-code = buf_bar-code.b-code
    .
  end.
end procedure.
procedure barcodcr :
  define input  parameter p-gds-code      like ub.bar-code.gds-code      no-undo .
  define input  parameter p-node-code     like ub.bar-code.node-code     no-undo .
  define input  parameter p-part-code     like ub.bar-code.part-code     no-undo .
  define input  parameter p-in-code       like ub.bar-code.in-code       no-undo .
  define input  parameter p-unit-cli      like ub.bar-code.unit-cli      no-undo .
  define input  parameter p-cli-base-rate like ub.bar-code.cli-base-rate no-undo .
  define output parameter p-is-new        as logical                     no-undo .
  define parameter buffer buf_bar-code for ub.bar-code .
  define variable vss-description as character no-undo initial "barcodcr-03: поиск/создание бар-кода" .
  define variable v-new-b-code like ub.bar-code.b-code no-undo .
  define variable v-unit-base  like ub.goods.unit-base no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-is-new = false
    .
    find first buf_bar-code no-lock
      where buf_bar-code.gds-code  = p-gds-code
        and buf_bar-code.node-code = p-node-code
        and buf_bar-code.part-code = p-part-code
        and buf_bar-code.in-code   = p-in-code
        and buf_bar-code.unit-cli  = p-unit-cli
      no-error .
    if not available buf_bar-code
    then do
    transaction
    on error undo, return error return-value
    :
      run gen-b-code in this-procedure
        ( input 'bcgb':U,
          output v-new-b-code
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при получении номера бар-кода" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run unitbase in g#library
  (input  p-gds-code
  ,output v-unit-base
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка определения базовой единицы измерения товара" skip
          "Код товара" p-gds-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      if p-unit-cli = v-unit-base
      then do:
        assign
          p-cli-base-rate = 1
        .
      end.
      if p-cli-base-rate = ?
      or p-cli-base-rate = 0
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Не задана коэффициент преобразования из одной единицы измерения в другую" skip
          "Код товара" p-gds-code skip
          "p-unit-cli" p-unit-cli skip
          "v-unit-base" v-unit-base skip
          "p-cli-base-rate" p-cli-base-rate skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      assign
        p-is-new = true
      .
      create buf_bar-code .
      assign
        buf_bar-code.b-code        = v-new-b-code
        buf_bar-code.gds-code      = p-gds-code
        buf_bar-code.node-code     = p-node-code
        buf_bar-code.part-code     = p-part-code
        buf_bar-code.in-code       = p-in-code
        buf_bar-code.unit-cli      = p-unit-cli
        buf_bar-code.cli-base-rate = p-cli-base-rate
      .
    end.
    else do:
      if buf_bar-code.stts_ = integer('99':U)
      then do:
        undo, return error substitute("бар-код &1 для товара &2 помечен к удалению", buf_bar-code.b-code, p-gds-code).
      end.
    end.
  end.
end procedure.
procedure bcodeprc :
  define input parameter  v-obj-type    like ub.price-list.obj-type   no-undo .
  define input parameter  v-obj-code    like ub.price-list.obj-code   no-undo .
  define input parameter  v-b-code      like ub.bar-code.b-code       no-undo .
  define input parameter  v-root-b-code like ub.bar-code.b-code       no-undo .
  define input parameter  v-fact-order  like ub.price-doc.fact-order  no-undo .
  define output parameter v-doc-num     like ub.price-list.doc-num    no-undo .
  define output parameter v-price-sale  like ub.price-list.price-sale no-undo .
  define output parameter v-road-tax    like ub.price-list.road-tax   no-undo .
  define output parameter v-excise      like ub.price-list.excise     no-undo .
  define variable v-price-list-recid as recid no-undo .
  define variable v-cli-base-rate    like ub.bar-code.cli-base-rate no-undo .
  define variable vss-description as character no-undo initial "bcodeprc-03: получение продажной цены товара (признака)".
  define buffer buf_price-list      for ub.price-list .
  do
  on error undo, return error return-value
  :
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodepls in g#library
  (input  v-obj-type
  ,input  v-obj-code
  ,input  v-b-code
  ,input  v-root-b-code
  ,input  v-fact-order
  ,output v-price-list-recid
  ,output v-cli-base-rate
  )  .
    if v-price-list-recid = ?
    then do:
      assign
        v-doc-num    = ?
        v-price-sale = ?
        v-road-tax   = ?
        v-excise     = ?
      .
    end.
    else do:
      find first buf_price-list no-lock
        where recid(buf_price-list) = v-price-list-recid
        .
      assign
        v-doc-num    = buf_price-list.doc-num
        v-price-sale = buf_price-list.price-sale * v-cli-base-rate
        v-road-tax   = buf_price-list.road-tax   * v-cli-base-rate
        v-excise     = buf_price-list.excise     * v-cli-base-rate
      .
    end.
  end.
end procedure.
procedure bcprcex :
  define input  parameter v-obj-type    like ub.price-list.obj-type   no-undo .
  define input  parameter v-obj-code    like ub.price-list.obj-code   no-undo .
  define input  parameter v-b-code      like ub.bar-code.b-code       no-undo .
  define input  parameter v-root-b-code like ub.bar-code.b-code       no-undo .
  define input  parameter v-fact-order  like ub.price-doc.fact-order  no-undo .
  define output parameter v-doc-num     like ub.price-list.doc-num    no-undo .
  define output parameter v-price-sale  like ub.price-list.price-sale no-undo .
  define output parameter v-road-tax    like ub.price-list.road-tax   no-undo .
  define output parameter v-excise      like ub.price-list.excise     no-undo .
  define output parameter v-VAT-pc      like ub.price-list.VAT-pc     no-undo .
  define output parameter v-SLT-pc      like ub.price-list.SLT-pc     no-undo .
  define variable v-price-list-recid as recid no-undo .
  define variable v-cli-base-rate    like ub.bar-code.cli-base-rate no-undo .
  define variable vss-description as character no-undo initial "bcprcex-01: получение продажной цены бар-кода с налогами".
  define buffer buf_price-list      for ub.price-list .
  do
  on error undo, return error return-value
  :
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodepls in g#library
  (input  v-obj-type
  ,input  v-obj-code
  ,input  v-b-code
  ,input  v-root-b-code
  ,input  v-fact-order
  ,output v-price-list-recid
  ,output v-cli-base-rate
  )  .
    if v-price-list-recid = ?
    then do:
      assign
        v-doc-num    = ?
        v-price-sale = ?
        v-road-tax   = ?
        v-excise     = ?
        v-VAT-pc     = ?
        v-SLT-pc     = ?
      .
    end.
    else do:
      find first buf_price-list no-lock
        where recid(buf_price-list) = v-price-list-recid
        .
      assign
        v-doc-num    = buf_price-list.doc-num
        v-price-sale = buf_price-list.price-sale * v-cli-base-rate
        v-road-tax   = buf_price-list.road-tax   * v-cli-base-rate
        v-excise     = buf_price-list.excise     * v-cli-base-rate
        v-VAT-pc     = buf_price-list.VAT-pc
        v-SLT-pc     = buf_price-list.SLT-pc
      .
    end.
  end.
end procedure.
procedure bcodepls :
  define input  parameter v-obj-type         like ub.price-list.obj-type    no-undo .
  define input  parameter v-obj-code         like ub.price-list.obj-code    no-undo .
  define input  parameter v-b-code           like ub.bar-code.b-code        no-undo .
  define input  parameter v-root-b-code      like ub.bar-code.b-code        no-undo .
  define input  parameter v-fact-order       like ub.price-doc.fact-order   no-undo .
  define output parameter v-recid-price-list as recid                       no-undo .
  define output parameter v-cli-base-rate    like ub.bar-code.cli-base-rate no-undo .
  define variable vss-description as character no-undo initial "bcodepls-01: записи продажной цены признака".
  define buffer buf_root_bar-code   for ub.bar-code .
  define buffer buf_bar-code        for ub.bar-code .
  define buffer buf_root_price-list for ub.price-list .
  define buffer buf_price-list      for ub.price-list .
  define buffer buf_main_bar-code   for ub.bar-code .
  define variable  v-is-parts as logical   no-undo .
  do
  on error undo, return error return-value
  :
    find first buf_bar-code no-lock
      where buf_bar-code.b-code = v-b-code
      no-error .
    if not available buf_bar-code
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при задании входных параметров" skip
        "Не найден бар-код" v-b-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      v-cli-base-rate = buf_bar-code.cli-base-rate
    .
    if v-fact-order = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при задании входных параметров" skip
        "Должен быть задан порядковый номер документа" skip
        "Для определения текущей цены он должен быть равен 0" skip
        "Порядковый номер документа" v-fact-order skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if v-root-b-code = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при задании входных параметров" skip
        "Должен быть задан бар-код корневого признака" skip
        "Или он должен быть равен 0" skip
        "Бар-код корневого признака" v-root-b-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if v-root-b-code = 0
    then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_bar-code.gds-code
  ,input  ?
  ,output v-root-b-code
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении корневого бар-кода для товара" skip
          "Код товара"  buf_bar-code.gds-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
    else do:
      define variable v-check-root-b-code like ub.bar-code.b-code no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_bar-code.gds-code
  ,input  ?
  ,output v-check-root-b-code
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении корневого бар-кода для товара" skip
          "Код товара"  buf_bar-code.gds-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      if v-root-b-code <> v-check-root-b-code
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Код товара" buf_bar-code.gds-code skip
          "Основной бар-код товара" v-check-root-b-code skip
          "В качестве параметра передано" v-root-b-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
    find first buf_root_bar-code no-lock
      where buf_root_bar-code.b-code = v-root-b-code
      no-error .
    if not available buf_root_bar-code
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден бар-код корневого признака" skip
        "Код товара" buf_bar-code.gds-code skip
        "Бар-код" v-root-b-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if buf_root_bar-code.gds-code <> buf_bar-code.gds-code
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "В качестве параметров указаны бар-коды разных товаров" skip
        "Бар-код" buf_bar-code.b-code skip
        "Код товара" buf_bar-code.gds-code skip
        "Бар-код корневого признака" buf_root_bar-code.b-code skip
        "Код товара в бар-коде корневого признака" buf_root_bar-code.gds-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    v-is-parts = false .
    if buf_bar-code.in-code <> "" then do:
       v-is-parts = true .
    end.
    if v-is-parts = true then do:
        if v-fact-order = 0
        then do:
          find last buf_root_price-list no-lock
            where buf_root_price-list.obj-type   = v-obj-type
              and buf_root_price-list.obj-code   = v-obj-code
              and buf_root_price-list.b-code     = v-b-code
              and buf_root_price-list.price-type = ""
            use-index fact-close
            no-error.
        end.
        else do:
          find last buf_root_price-list no-lock
            where buf_root_price-list.obj-type   = v-obj-type
              and buf_root_price-list.obj-code   = v-obj-code
              and buf_root_price-list.b-code     = v-b-code
              and buf_root_price-list.price-type = ""
              and buf_root_price-list.fact-order < v-fact-order
            use-index fact-close
            no-error.
        end.
        if  available buf_root_price-list
        and buf_root_price-list.fact-order <> 0
        then do:
            assign
              v-recid-price-list = recid(buf_root_price-list)
              v-cli-base-rate    = 1
            .
            return .
        end.
        else do:
          if v-fact-order = 0
          then do:
            find last buf_root_price-list no-lock
              where buf_root_price-list.obj-type   = v-obj-type
                and buf_root_price-list.obj-code   = v-obj-code
                and buf_root_price-list.b-code     = v-root-b-code
                and buf_root_price-list.price-type = ""
              use-index fact-close
              no-error.
          end.
          else do:
            find last buf_root_price-list no-lock
              where buf_root_price-list.obj-type   = v-obj-type
                and buf_root_price-list.obj-code   = v-obj-code
                and buf_root_price-list.b-code     = v-root-b-code
                and buf_root_price-list.price-type = ""
                and buf_root_price-list.fact-order < v-fact-order
              use-index fact-close
              no-error.
          end.
          if  available buf_root_price-list
          and buf_root_price-list.fact-order <> 0
          then do:
              assign
                v-recid-price-list = recid(buf_root_price-list)
                v-cli-base-rate    = 1
              .
              return .
          end.
          else do:
              assign
                v-recid-price-list = ?
                v-cli-base-rate    = ?
              .
              return .
          end.
        end.
    end.
    if v-fact-order = 0
    then do:
      find last buf_root_price-list no-lock
        where buf_root_price-list.obj-type   = v-obj-type
          and buf_root_price-list.obj-code   = v-obj-code
          and buf_root_price-list.b-code     = v-root-b-code
          and buf_root_price-list.price-type = ""
        use-index fact-close
        no-error.
    end.
    else do:
      find last buf_root_price-list no-lock
        where buf_root_price-list.obj-type   = v-obj-type
          and buf_root_price-list.obj-code   = v-obj-code
          and buf_root_price-list.b-code     = v-root-b-code
          and buf_root_price-list.price-type = ""
          and buf_root_price-list.fact-order < v-fact-order
        use-index fact-close
        no-error.
    end.
    if  available buf_root_price-list
    and buf_root_price-list.fact-order <> 0
    then do:
      if v-b-code = v-root-b-code
      then do:
        assign
          v-recid-price-list = recid(buf_root_price-list)
          v-cli-base-rate    = 1
        .
        return .
      end.
      else do:
        find first buf_price-list no-lock
          where buf_price-list.doc-num    = buf_root_price-list.doc-num
            and buf_price-list.b-code     = v-b-code
            and buf_price-list.price-type = ""
          no-error.
        if available buf_price-list
        then do:
          assign
            v-recid-price-list = recid(buf_price-list)
            v-cli-base-rate    = 1
          .
          return .
        end.
        if buf_bar-code.unit-cli = buf_root_bar-code.unit-cli
        then do:
          assign
            v-recid-price-list = recid(buf_root_price-list)
            v-cli-base-rate    = 1
          .
          return .
        end.
        else do:
          define variable v-is-new as logical no-undo .
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run barcodcr in g#library
  (input  buf_bar-code.gds-code
  ,input  buf_bar-code.node-code
  ,input  buf_bar-code.part-code
  ,input  buf_bar-code.in-code
  ,input  buf_root_bar-code.unit-cli
  ,input  1
  ,output v-is-new
  ,buffer buf_main_bar-code
  ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при поиске бар-кода" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          find first buf_price-list no-lock
            where buf_price-list.doc-num    = buf_root_price-list.doc-num
              and buf_price-list.b-code     = buf_main_bar-code.b-code
              and buf_price-list.price-type = ""
            no-error.
          if available buf_price-list
          then do:
            assign
              v-recid-price-list = recid(buf_price-list)
            .
            return .
          end.
          else do:
            assign
              v-recid-price-list = recid(buf_root_price-list)
            .
            return .
          end.
        end.
      end.
    end.
    else do:
      assign
        v-recid-price-list = ?
        v-cli-base-rate    = ?
      .
      return .
    end.
    message
      vss-workfile vss-revision vss-description skip
      "Внутренняя ошибка при определении цены бар-кода" skip
      "Бар-код"    buf_bar-code.b-code skip
      "Код товара" buf_bar-code.gds-code skip
      "recid(root_price-list)" recid(buf_root_price-list) skip
      "recid(price-list)"      recid(buf_price-list) skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end procedure.
procedure bcodeqnt :
  define input parameter  v-obj-type    like ub.gds-obj.obj-type  no-undo .
  define input parameter  v-obj-code    like ub.gds-obj.obj-code  no-undo .
  define input parameter  v-b-code      like ub.bar-code.b-code   no-undo .
  define input parameter  v-root-b-code like ub.bar-code.b-code   no-undo .
  define output parameter v-fact-qnty   like ub.gds-obj.fact-qnty no-undo .
  define output parameter v-qnty-type   as character              no-undo .
  define output parameter v-qnty-recid  as recid                  no-undo .
  define variable vss-description as character no-undo initial "bcodeqnt-01: Определение текущего количества товара на объекте с данным бар-кодом".
  define buffer buf_root_bar-code   for ub.bar-code .
  define buffer buf_bar-code        for ub.bar-code .
  define buffer buf_root_price-list for ub.price-list .
  define buffer buf_price-list      for ub.price-list .
  define buffer buf_main_bar-code   for ub.bar-code .
  define buffer buf_goods for ub.goods .
  define buffer buf_parts for ub.parts .
  define buffer buf_prt-obj for ub.prt-obj .
  define buffer buf_gds-obj for ub.gds-obj .
  do
  on error undo, return error return-value
  :
    find first buf_bar-code no-lock
      where buf_bar-code.b-code = v-b-code
      no-error .
    if not available buf_bar-code
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при задании входных параметров" skip
        "Не найден бар-код" v-b-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if v-root-b-code = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при задании входных параметров" skip
        "Должен быть задан бар-код корневого признака" skip
        "Или он должен быть равено 0" skip
        "Бар-код корневого признака" v-root-b-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if v-root-b-code = 0
    then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_bar-code.gds-code
  ,input  ?
  ,output v-root-b-code
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении корневого бар-кода для товара" skip
          "Код товара"  buf_bar-code.gds-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
    find first buf_root_bar-code no-lock
      where buf_root_bar-code.b-code = v-root-b-code
      no-error .
    if not available buf_root_bar-code
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден бар-код корневого признака" skip
        "Код товара" buf_bar-code.gds-code skip
        "Бар-код" v-root-b-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if buf_root_bar-code.gds-code <> buf_bar-code.gds-code
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "В качестве параметров указаны бар-коды разных товаров" skip
        "Бар-код" buf_bar-code.b-code skip
        "Код товара" buf_bar-code.gds-code skip
        "Бар-код корневого признака" buf_root_bar-code.b-code skip
        "Код товара в бар-коде корневого признака" buf_root_bar-code.gds-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if buf_bar-code.unit-cli <> buf_root_bar-code.unit-cli
    then do:
      assign
        v-fact-qnty  = ?
        v-qnty-type  = "alt-unit":u
        v-qnty-recid = ?
      .
      return .
    end.
    find first buf_goods no-lock
      where buf_goods.gds-code = buf_bar-code.gds-code
      no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Бар-код" buf_bar-code.b-code skip
        "Код товара" buf_bar-code.gds-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if buf_bar-code.in-code <> ""
    then do:
      assign
        v-fact-qnty  = 0
        v-qnty-type  = "parts":u
        v-qnty-recid = ?
      .
      find first buf_parts no-lock
        where buf_parts.obj-type  = v-obj-type
          and buf_parts.obj-code  = v-obj-code
          and buf_parts.artic     = buf_goods.artic
          and buf_parts.prod-type = buf_goods.prod-type
          and buf_parts.prod-code = buf_goods.prod-code
          and buf_parts.in-code   = buf_bar-code.in-code
          and buf_parts.part-code = buf_bar-code.part-code
          and buf_parts.out-code  = 'free-zone':U
        no-error .
      if available buf_parts
      then do:
        assign
          v-fact-qnty  = buf_parts.fact-qnty
          v-qnty-recid = recid(buf_parts)
        .
      end.
      return .
    end.
    if buf_bar-code.b-code = buf_root_bar-code.b-code
    then do:
      assign
        v-fact-qnty  = 0
        v-qnty-type  = "gds-obj":u
        v-qnty-recid = ?
      .
      find first buf_gds-obj no-lock
        where buf_gds-obj.obj-type = v-obj-type
          and buf_gds-obj.obj-code = v-obj-code
          and buf_gds-obj.gds-code = buf_bar-code.gds-code
        no-error .
      if available buf_gds-obj
      then do:
        assign
          v-fact-qnty  = buf_gds-obj.fact-qnty
          v-qnty-recid = recid(buf_gds-obj)
        .
      end.
      return .
    end.
    else do:
      assign
        v-fact-qnty  = 0
        v-qnty-type  = "prt-obj":u
        v-qnty-recid = ?
      .
      find first buf_prt-obj no-lock
        where buf_prt-obj.obj-type  = v-obj-type
          and buf_prt-obj.obj-code  = v-obj-code
          and buf_prt-obj.artic     = buf_goods.artic
          and buf_prt-obj.prod-type = buf_goods.prod-type
          and buf_prt-obj.prod-code = buf_goods.prod-code
          and buf_prt-obj.prt-code  = buf_bar-code.node-code
        no-error .
      if available buf_prt-obj
      then do:
        assign
          v-fact-qnty  = buf_prt-obj.fact-qnty
          v-qnty-recid = recid(buf_prt-obj)
        .
      end.
      return .
    end.
    message
      vss-workfile vss-revision vss-description skip
      "Внутренняя ошибка при определении количества по бар-коду" skip
      "Бар-код"    buf_bar-code.b-code skip
      "Код товара" buf_bar-code.gds-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end procedure.
procedure prodbcat :
  do
  on error undo, return error return-value
  :
    define parameter buffer buf_prod-bc  for ub.prod-bc .
    define input  parameter p-action           as character no-undo .
    define output parameter p-return-attribute as logical no-undo .
    define variable vss-description as character no-undo initial "prodbcat-01: определение параметров дополнительного бар-кода".
    define buffer buf_bar-code   for ub.bar-code   .
    define buffer buf_goods      for ub.goods      .
    define buffer buf_units      for ub.units      .
    define buffer base_units     for ub.units      .
    define buffer buf_code-range for ub.code-range .
    define variable p-code-int as integer no-undo .
    define variable v-cdrg-type as character no-undo .
    if not available buf_prod-bc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не задан дополнительный бар-код" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if buf_prod-bc.bc-on-type eq 'GTIN':U
    then do:
       return.
    end.
    define variable ind                    as integer   no-undo .
    define variable v-num-entries-p-action as integer   no-undo .
    define variable v-action               as character no-undo .
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
              p-return-attribute = false
            .
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
          undo, return error return-value .
        end.
      end case.
    end.
  end.
end procedure.
procedure prodbctv :
  do
  on error undo, return error return-value
  :
    define input  parameter p-b-str    like ub.prod-bc.b-str   no-undo .
    define input  parameter p-unit-cli like ub.units.unit-name no-undo .
    define input  parameter p-unit-base like ub.units.unit-name no-undo .
    define input  parameter p-action           as character no-undo .
    define output parameter p-return-attribute as logical no-undo .
    define variable vss-description as character no-undo init "prodbctv-01: определение параметров ЗНАЧЕНИЯ дополнительного бар-кода".
    define buffer buf_units      for ub.units      .
    define buffer base_units     for ub.units      .
    define buffer buf_code-range for ub.code-range .
    define variable p-code-int as integer no-undo .
    define variable v-cdrg-type as character no-undo .
    find first buf_units no-lock
      where buf_units.unit-name = p-unit-cli
      no-error .
    if not available buf_units
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена единица измерения бар-кода" skip
        "Единица измерения" p-unit-cli skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    define variable ind                    as integer   no-undo .
    define variable v-num-entries-p-action as integer   no-undo .
    define variable v-action               as character no-undo .
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
          if lookup('вес':U, buf_units.type) > 0
          or (lookup('топ':U, buf_units.type)  > 0
              and lookup('дро':U, buf_units.type) > 0
            )
          or lookup('шту':U, buf_units.type) > 0
          then do:
            if length(p-b-str) < 6
            then do:
              if v-action = "global=request":u
                 and (lookup('вес':U, buf_units.type) > 0
                     or lookup('шту':U, buf_units.type) > 0
                    )
              then do:
                if lookup('вес':U, buf_units.type) > 0 then v-cdrg-type = 'sclc':U.
                if lookup('шту':U, buf_units.type) > 0 then v-cdrg-type = 'pglc':U.
                find first buf_code-range
                  where buf_code-range.range-type = v-cdrg-type
                    and buf_code-range.last-code >= int( p-b-str )
                  use-index last-codei
                  no-error .
                if  available buf_code-range
                and buf_code-range.first-code <= int( p-b-str )
                then do:
                  assign
                    p-return-attribute = false
                  .
                end.
              end.
              else do:
                assign
                  p-return-attribute = false
                .
              end.
            end.
          end.
          if lookup('дро':U, buf_units.type) > 0
          then do:
            find first buf_code-range
              where buf_code-range.range-type = 'sslc':U
                and buf_code-range.last-code >= int( p-b-str )
              use-index last-codei
              no-error .
            if  available buf_code-range
            and buf_code-range.first-code <= int( p-b-str )
            then do:
              assign
                p-return-attribute = false
              .
            end.
          end.
        end.
        when "weight=request":u
        then do:
          assign
            p-code-int         = integer( p-b-str ) no-error
          .
          if lookup('вес':U, buf_units.type) > 0
             and length(p-b-str) < 6
             and length( string( p-code-int ) ) < 6
             and length(p-b-str) > 2
             and length( string( p-code-int ) ) > 2
          then do:
            next _ind.
          end.
          else do:
            assign
              p-return-attribute = false
            .
          end.
        end.
        when "pgweight=request":u
        then do:
          assign
            p-code-int         = integer( p-b-str ) no-error
          .
          if lookup('шту':U, buf_units.type) > 0
             and length(p-b-str) < 6
             and length( string( p-code-int ) ) < 6
             and length(p-b-str) > 2
             and length( string( p-code-int ) ) > 2
          then do:
            next _ind.
          end.
          else do:
            assign
              p-return-attribute = true
            .
          end.
        end.
        when "petrolium=request":u
        then do:
          assign
            p-code-int         = integer( p-b-str ) no-error
          .
          if lookup( 'топ':U, buf_units.type )  > 0
             and lookup( 'дро':U, buf_units.type ) > 0
             and length( p-b-str ) <= 2
             and length( string( p-code-int ) ) <= 2
             and p-code-int <> 0
          then do:
            next _ind.
          end.
          else do:
            assign
              p-return-attribute = false
            .
          end.
        end.
        when "scaleable=request":u
        then do:
          assign
            p-code-int         = integer( p-b-str ) no-error
          .
          find first base_units no-lock
            where base_units.unit-name = p-unit-base
            no-error .
          if not available base_units
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Не найдена основная единица измерения" skip
              "Единица измерения" p-unit-base skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          if lookup('дро':U, buf_units.type) > 0
             and lookup('вес':U, base_units.type) > 0
          then do:
            p-code-int = 0.
            assign
            p-code-int = integer( p-b-str )
            no-error .
            if error-status :error or p-code-int <= 0
            then do:
              assign
                p-return-attribute = false
              .
              next _ind.
            end.
            if trim(string(p-code-int, ">>>>>>>>9":U)) <>  p-b-str
            then do:
              assign
                p-return-attribute = false
              .
              next _ind.
            end.
            find first buf_code-range
              where buf_code-range.range-type = 'sslc':U
                and buf_code-range.last-code >= p-code-int
                use-index last-codei
              no-error .
            if  available buf_code-range
            and buf_code-range.first-code <= p-code-int
            then do:
              next _ind.
            end.
            else do:
              find first buf_code-range
                where buf_code-range.range-type = 'ssgb':U
                  and buf_code-range.last-code >= p-code-int
                  use-index last-codei
                no-error .
              if  available buf_code-range
              and buf_code-range.first-code <= p-code-int
              then do:
                next _ind.
              end.
              else do:
                assign
                  p-return-attribute = false
                .
              end.
            end.
          end.
          else do:
            assign
              p-return-attribute = false
            .
          end.
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестное значение параметра v-action " skip
            "v-action" v-action skip
            "p-action" p-action skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end case.
    end.
  end.
end procedure.
procedure bc-ean :
  define input  parameter p-bc-frmt  as character no-undo .
  define input  parameter p-bc-pfx   as character no-undo .
  define input  parameter p-b-code   as integer   no-undo .
  define output parameter p-ean-code as character no-undo .
  define buffer buf_bar-code for ub.bar-code .
  define buffer buf_prod-bc for ub.prod-bc.
  define variable v-bc-frmt as character no-undo .
  define variable v-check-length as integer   no-undo .
  define variable v-check-code   as character no-undo .
  do
  on error undo, return error return-value
  :
    find first buf_bar-code no-lock
      where buf_bar-code.b-code = p-b-code
      no-error .
    if not available buf_bar-code
    then do:
      undo, return error substitute("Ошибка задания входных параметров. Не найден штрих-код &1"
                                   ,p-b-code
                                   ) .
    end.
    case p-bc-frmt :
      when 'EAN13':u
      then do:
        assign
          v-check-length = 13
        .
      end.
      when 'EAN8':u
      then do:
        assign
          v-check-length = 8
        .
      end.
      otherwise do:
        undo, return error substitute('Неизвестное значение параметра &1', p-bc-frmt) .
      end.
    end case .
    for each buf_prod-bc no-lock
      where buf_prod-bc.b-code = p-b-code
        and buf_prod-bc.bc-on  = true
    on error undo, return error return-value
    :
      if length(buf_prod-bc.b-str) = v-check-length
      then do:
        assign
          v-check-code = substring (buf_prod-bc.b-str
                                    ,1
                                    ,length (buf_prod-bc.b-str) - 1
                                    )
        .
        run str/chk-sum.p
          (input-output v-check-code
          ) no-error.
        if error-status :error <> true
        and v-check-code = buf_prod-bc.b-str
        then do:
          assign
            p-ean-code = buf_prod-bc.b-str
          .
          return .
        end.
      end.
    end.
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable tmp-str56  as character no-undo.
  define variable tmp-num56  as character no-undo.
  define variable i56        as integer   no-undo.
  define variable sum56      as integer   no-undo.
  define variable len-code56 as integer   no-undo.
  define variable varcont56  as logical   initial yes no-undo.
  CASE p-bc-frmt :
    WHEN "EAN13" THEN do:
      assign
        tmp-str56 = string( p-b-code, "999999999999" )
      .
    end.
    WHEN "EAN8" THEN do:
      assign
        tmp-str56 = string( p-b-code, "9999999" )
      .
    end.
    OTHERWISE DO:
          assign p-ean-code     = ""
                 varcont56 = no.
    END.
  END CASE.
  if varcont56 = yes then do:
    if integer( substring( tmp-str56, 1, length( p-bc-pfx ) ) ) <> 0
    then do:
         assign p-ean-code     = ""
                varcont56 = no.
    end.
    else do:
      assign
        p-ean-code = p-bc-pfx + substring( tmp-str56, length( p-bc-pfx ) + 1, length( tmp-str56 ) - length( p-bc-pfx ) )
        len-code56    = length( p-ean-code )
      .
      define variable v-sum-char56 as character no-undo .
      assign
        sum56 = 0
      .
      do i56 = 1 to len-code56 by 2
      :
        assign
          v-sum-char56 = substr(p-ean-code, len-code56 - i56 + 1, 1)
        .
        if v-sum-char56 < "0"
        or v-sum-char56 > "9"
        then do:
             assign p-ean-code     = ""
                    varcont56 = no.
        end.
        assign
          sum56 = sum56 + integer(v-sum-char56)
        .
      end.
      if varcont56 = yes then do:
        assign
          sum56 = sum56 * 3
        .
        do i56 = 2 to len-code56 by 2
        :
          assign
            v-sum-char56 = substr(p-ean-code, len-code56 - i56 + 1, 1)
          .
          if v-sum-char56 < "0"
          or v-sum-char56 > "9"
          then do:
               assign p-ean-code     = ""
                      varcont56 = no.
          end.
          assign
            sum56 = sum56 + integer(v-sum-char56)
          .
        end.
        if varcont56 = yes then do:
           if sum56 mod 10 = 0 then do:
             assign
               p-ean-code = p-ean-code + '0'
             .
           end.
           else do:
             assign
               p-ean-code = p-ean-code + string(10 - sum56 mod 10)
             .
           end.
        end.
      end.
    end.
  end.
  end.
end procedure.
procedure prt-root-to-node-code :
  define input  parameter p-prt-root  like ub.goods.prt-root no-undo .
  define output parameter p-root-node like ub.goods.prt-root no-undo .
  define variable vss-description as character no-undo initial "prt-root-to-node-code-01: определение корневого признака шкалы по коду шкалы".
  define buffer buf_gds-prt for ub.gds-prt .
  do
  on error undo, return error return-value
  :
    find buf_gds-prt no-lock
      where buf_gds-prt.upper-code = p-prt-root
      no-error .
    if not available buf_gds-prt
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден корень шкалы" skip
        "Указатель на корень шкалы" p-prt-root skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      p-root-node = buf_gds-prt.node-code
    .
  end.
end procedure.
procedure rootnode :
  define input  parameter p-artic     like ub.goods.artic     no-undo .
  define input  parameter p-prod-type like ub.goods.prod-type no-undo .
  define input  parameter p-prod-code like ub.goods.prod-code no-undo .
  define output parameter p-root-node like ub.goods.prt-root  no-undo .
  define variable vss-description as character no-undo initial "rootnode-01: определение корневого признака товара по артикулу".
  define buffer buf_goods for ub.goods .
  do
  on error undo, return error return-value
  :
    find first buf_goods no-lock
      where buf_goods.artic     = p-artic
        and buf_goods.prod-type = p-prod-type
        and buf_goods.prod-code = p-prod-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run prt-root-to-node-code in this-procedure
      (input  buf_goods.prt-root
      ,output p-root-node
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры prt-root-to-node-code" skip
        "Товар" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
        "Указатель на корень шкалы" buf_goods.prt-root skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gdsrtnod :
  define input  parameter p-gds-code  like ub.goods.gds-code no-undo .
  define output parameter p-root-node like ub.goods.prt-root no-undo .
  define variable vss-description as character no-undo initial "gdsrtnod-01: определение корневого признака товара по коду товара".
  define buffer buf_goods   for ub.goods .
  do
  on error undo, return error return-value
  :
    find first buf_goods no-lock
      where buf_goods.gds-code  = p-gds-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run prt-root-to-node-code in this-procedure
      (input  buf_goods.prt-root
      ,output p-root-node
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры prt-root-to-node-code" skip
        "Товар" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
        "Указатель на корень шкалы" buf_goods.prt-root skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure currdbat :
  define input  parameter p-action           as character no-undo .
  define output parameter p-return-attribute as logical no-undo .
  define variable vss-description as character no-undo initial "currdbat-01: определение атрибутов текущей базы данных".
  do
  on error undo, return error return-value
  :
    define variable v-db-num               as integer   no-undo .
    define variable v-num-entries-p-action as integer   no-undo .
    define variable v-ind                  as integer   no-undo .
    define variable v-action               as character no-undo .
    assign
      v-num-entries-p-action = num-entries(p-action)
    .
    do v-ind = 1 to v-num-entries-p-action
    on error undo, return error return-value
    :
      assign
        v-action = entry(v-ind, p-action)
      .
      case v-action :
        when 'office=request':u
        then do:
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при определении текущей БД" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          if v-db-num = 0
          then do:
            assign
              p-return-attribute = true
            .
          end.
          else do:
            assign
              p-return-attribute = false
            .
          end.
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка задания входных параметров" skip
            "p-action" p-action skip
            "v-action" v-action skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
    end.
  end.
end procedure.
procedure objat :
  define input  parameter p-obj-type         like ub.gds-obj.obj-type  no-undo .
  define input  parameter p-obj-code         like ub.gds-obj.obj-code  no-undo .
  define input  parameter p-action           as character no-undo .
  define output parameter p-return-attribute as logical no-undo .
  define variable vss-description as character no-undo initial "objat-03: Получить атрибут объекта (склад магазин)".
  define variable ind      as integer no-undo .
  define variable v-action as character no-undo .
  define variable l-in-ov       as logical   no-undo .
  define variable l-doc-prt     as logical   no-undo .
  define variable l-shift-on    as logical   no-undo .
  define variable v-no-eq       as logical   no-undo .
  define variable v-price-calc  as logical   no-undo .
  define variable v-inout-price as logical   no-undo .
  define variable v-host-code like ub.sysconf.host-code no-undo .
  define buffer buf_store   for ub.store .
  define buffer buf_shop    for ub.shop .
  define buffer buf_gds-obj for ub.gds-obj .
  do
  on error undo, return error return-value
  :
    case p-obj-type :
      when 'скл':U
      then do:
        find buf_store no-lock
          where buf_store.obj-code = p-obj-code
          no-error .
        if not available buf_store
        then do:
          undo, return error substitute("Не найден объект &1 &2", p-obj-type, p-obj-code).
        end.
        assign
          l-in-ov       = buf_store.in-ov
          l-doc-prt     = buf_store.doc-prt
          l-shift-on    = buf_store.shift-on
          v-no-eq       = buf_store.no-eq
          v-price-calc  = buf_store.price-calc
          v-inout-price = buf_store.inout-price
          v-host-code   = buf_store.host-code
        .
      end.
      when 'маг':U
      then do:
        find buf_shop no-lock
          where buf_shop.obj-code = p-obj-code
          no-error .
        if not available buf_shop
        then do:
          undo, return error substitute("Не найден объект &1 &2", p-obj-type, p-obj-code).
        end.
        assign
          l-in-ov       = buf_shop.in-ov
          l-doc-prt     = buf_shop.doc-prt
          l-shift-on    = buf_shop.shift-on
          v-no-eq       = buf_shop.no-eq
          v-price-calc  = buf_shop.price-calc
          v-inout-price = buf_shop.inout-price
          v-host-code   = buf_shop.host-code
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Задан неправильный тип для объекта" skip
          "p-obj-type" p-obj-type skip
          "p-obj-code" p-obj-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .
    define variable v-num-entries-p-action as integer no-undo .
    assign
      v-num-entries-p-action = num-entries(p-action)
    .
    do ind = 1 to v-num-entries-p-action
    on error undo, return error return-value
    :
      assign
        v-action = entry(ind, p-action)
      .
      case v-action :
        when 'check-exist':u
        then do:
          assign
            p-return-attribute = true
          .
        end.
        when 'doc-prt=request':u
        then do:
          assign
            p-return-attribute = l-doc-prt
          .
        end.
        when 'in-ov=request':u
        then do:
          assign
            p-return-attribute = l-in-ov
          .
        end.
        when 'shift-on=request':u
        then do:
          assign
            p-return-attribute = l-shift-on
          .
        end.
        when 'inout-price=request':u
        then do:
          assign
            p-return-attribute = v-inout-price
          .
        end.
        when 'exist-in-ov=request':u
        then do:
          if can-find (first buf_gds-obj no-lock
            where buf_gds-obj.obj-type = p-obj-type
              and buf_gds-obj.obj-code = p-obj-code
              and buf_gds-obj.in-ov    = yes
          )
          and l-in-ov
          then do:
            assign
              p-return-attribute = true
            .
          end.
          else do:
            assign
              p-return-attribute = false
            .
          end.
        end.
        when 'autodate=request':u
        then do:
          define variable v-param-name    as character no-undo .
          define variable v-default-value as logical   no-undo .
          define variable v-value-character as character  no-undo .
          define variable v-value-date      as date       no-undo .
          define variable v-value-decimal   as decimal    no-undo .
          define variable v-value-integer   as integer    no-undo .
          define variable v-value-logical   as logical    no-undo .
          define variable v-tth             as handle     no-undo .
          define variable v-param-type      as character no-undo .
          if l-shift-on = false
          then do:
              assign
                v-param-name    = 'autodate':u
                v-default-value = yes
              .
          end.
          else do:
              assign
                v-param-name    = 'autodtsh':u
                v-default-value = no
              .
          end.
          run adm/shattri.p ( input "get":U
                            , input  p-obj-type
                            , input  p-obj-code
                            , input  'obj-date':U
                            , input  v-param-name
                            , output v-value-character
                            , output v-value-date
                            , output v-value-decimal
                            , output v-value-integer
                            , output v-value-logical
                            , output v-param-type
                            , input-output table-handle v-tth
                            ) no-error .
          if error-status :error
          then do:
              assign
                p-return-attribute   = v-default-value
              .
          end.
          else do:
            assign
              p-return-attribute = v-value-logical
            .
          end.
          delete object v-tth no-error.
        end.
        when 'active=request':u
        then do:
          define variable v-db-num as integer   no-undo .
define variable vss-include-info58 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при определении текущей БД" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          define buffer buf_clients for ub.clients .
          find first buf_clients no-lock
            where buf_clients.obj-type = p-obj-type
              and buf_clients.obj-code = p-obj-code
            no-error.
          if not available buf_clients
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка задания входных параметров" skip
              substitute("Не найден объект &1 &2.", p-obj-type, p-obj-code) skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          if buf_clients.db-num = v-db-num
          then do:
            assign
              p-return-attribute = yes
            .
          end.
          else do:
            assign
              p-return-attribute = no
            .
          end.
        end.
        when 'no-eq=request':u
        then do:
          assign
            p-return-attribute = v-no-eq
          .
        end.
        when 'price-calc=request':u
        then do:
          assign
            p-return-attribute = v-price-calc
          .
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка задания входных параметров" skip
            "Объект" p-obj-type p-obj-code skip
            "Список действий" p-action skip
            "Действие" v-action skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end case .
    end.
  end.
end procedure.
procedure objretsp :
  define input parameter  p-obj-type    like ub.gds-obj.obj-type no-undo .
  define input parameter  p-obj-code    like ub.gds-obj.obj-code no-undo .
  define output parameter p-ret-sup-pay like ub.store.ret-sup-pay no-undo .
  define variable vss-description as character no-undo initial "objretsp-01: определение кода оплаты <<возврат поставщику>> для объекта".
  define buffer buf_store for ub.store .
  define buffer buf_shop  for ub.shop  .
  do
  on error undo, return error return-value
  :
    if p-obj-type = 'скл':U
    then do:
      find first buf_store no-lock
        where buf_store.obj-code = p-obj-code
        .
      assign
        p-ret-sup-pay = buf_store.ret-sup-pay
      .
    end.
    else do:
      find buf_shop no-lock
        where buf_shop.obj-code = p-obj-code
        .
      assign
        p-ret-sup-pay = buf_shop.ret-sup-pay
      .
    end.
  end.
end procedure.
procedure objoutp :
  define input parameter  p-obj-type like ub.gds-obj.obj-type no-undo .
  define input parameter  p-obj-code like ub.gds-obj.obj-code no-undo .
  define output parameter p-out-pay  like ub.store.out-pay no-undo .
  define variable vss-description as character no-undo initial "objretsp-01: определение кода оплаты <<возврат поставщику>> для объекта".
  define buffer buf_store for ub.store .
  define buffer buf_shop  for ub.shop  .
  do
  on error undo, return error return-value
  :
    if p-obj-type = 'скл':U
    then do:
      find first buf_store no-lock
        where buf_store.obj-code = p-obj-code
        .
      assign
        p-out-pay = buf_store.out-pay
      .
    end.
    else do:
      find buf_shop no-lock
        where buf_shop.obj-code = p-obj-code
        .
      assign
        p-out-pay = buf_shop.out-pay
      .
    end.
  end.
end procedure.
procedure objinpay :
  define input parameter  p-obj-type like ub.gds-obj.obj-type no-undo .
  define input parameter  p-obj-code like ub.gds-obj.obj-code no-undo .
  define output parameter p-in-pay  like ub.store.in-pay no-undo .
  define variable vss-description as character no-undo initial "objretsp-01: определение кода оплаты <<возврат поставщику>> для объекта".
  define buffer buf_store for ub.store .
  define buffer buf_shop  for ub.shop  .
  do
  on error undo, return error return-value
  :
    if p-obj-type = 'скл':U
    then do:
      find first buf_store no-lock
        where buf_store.obj-code = p-obj-code
        .
      assign
        p-in-pay = buf_store.in-pay
      .
    end.
    else do:
      find buf_shop no-lock
        where buf_shop.obj-code = p-obj-code
        .
      assign
        p-in-pay = buf_shop.in-pay
      .
    end.
  end.
end procedure.
procedure objdnpay :
  define input parameter  p-obj-type    like ub.gds-obj.obj-type no-undo .
  define input parameter  p-obj-code    like ub.gds-obj.obj-code no-undo .
  define output parameter p-down-pay    like ub.store.down-pay   no-undo .
  define variable vss-description as character no-undo initial "objdnpay-01: определение кода оплаты списания для объекта".
  define buffer buf_store for ub.store .
  define buffer buf_shop  for ub.shop  .
  do
  on error undo, return error return-value
  :
    if p-obj-type = 'скл':U
    then do:
      find first buf_store no-lock
        where buf_store.obj-code = p-obj-code
        .
      assign
        p-down-pay = buf_store.down-pay
      .
    end.
    else do:
      find buf_shop no-lock
        where buf_shop.obj-code = p-obj-code
        .
      assign
        p-down-pay = buf_shop.down-pay
      .
    end.
  end.
end procedure.
procedure objconsp :
  define input parameter  p-obj-type  like ub.gds-obj.obj-type   no-undo .
  define input parameter  p-obj-code  like ub.gds-obj.obj-code   no-undo .
  define output parameter p-cons-code like ub.sysconf.purch-code no-undo .
  define variable vss-description as character no-undo initial "objconsp-01: определение кода оплаты <<получение товара на консигнацию>> для объекта".
  do
  on error undo, return error return-value
  :
    assign
      p-cons-code = integer('2':U)
    .
  end.
end procedure.
procedure objatext :
  define input  parameter p-obj-type like ub.gds-obj.obj-type  no-undo .
  define input  parameter p-obj-code like ub.gds-obj.obj-code  no-undo .
  define input  parameter p-action   as character no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  define variable vss-description as character no-undo initial "objatext-01: получение расширенного атрибута объекта".
  do
  on error undo, return error return-value
  :
    define variable v-action-code as character no-undo .
    assign
      v-action-code = entry(1, p-action, '=':u)
    .
    case p-action :
      when "ret-sup-pay=request":u
      then do:
        run objretsp in this-procedure
          (input  p-obj-type
          ,input  p-obj-code
          ,output p-value
          ).
        assign
          p-type  = 'I':U
        .
      end.
      when "cons-pay=request":u
      then do:
        run objconsp in this-procedure
          (input  p-obj-type
          ,input  p-obj-code
          ,output p-value
          ).
        assign
          p-type  = 'I':U
        .
      end.
      when "out-pay=request":u
      then do:
        run objoutp in this-procedure
          (input  p-obj-type
          ,input  p-obj-code
          ,output p-value
          ).
        assign
          p-type  = 'I':U
        .
      end.
      when "in-pay=request":u
      then do:
        run objinpay in this-procedure
          (input  p-obj-type
          ,input  p-obj-code
          ,output p-value
          ).
        assign
          p-type  = 'I':U
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестный параметр вызова." skip
          "Объект" p-obj-type p-obj-code skip
          "p-action" p-action skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .
  end.
end procedure.
procedure prtcheck :
  define input parameter p-doc-prt    as logical no-undo .
  define input parameter p-node-code  like ub.gds-prt.node-code no-undo .
  define input parameter p-root-node  like ub.gds-prt.node-code no-undo .
  define variable vss-description as character no-undo initial "prtcheck-01: проверка допустимости признака для использования в gds-dtl".
  if p-doc-prt   = ?
  or p-node-code = ?
  or p-root-node = ?
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Входные параметры должны быть определены" skip
      "p-doc-prt"   p-doc-prt   skip
      "p-node-code" p-node-code skip
      "p-node-code" p-node-code skip
      "p-root-node" p-root-node skip
      "p-root-node" p-root-node skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  if p-doc-prt
  then do:
    define variable l-terminal-prt as logical no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  p-node-code
  ,input  'terminal-prt=request':U
  ,output l-terminal-prt
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута признака" skip
        "p-node-code" p-node-code skip
        "Запрашивался атрибут" "terminal-prt=request"
        error-status:get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if l-terminal-prt <> true
    then do:
      undo, return error
        vss-workfile + "Недопустимый признак" + chr(10)
        + "На объекте включены признаки" + chr(10)
        + "Указанный признак не является терминальным" + chr(10)
        + "p-node-code " + string(p-node-code) + chr(10)
        + "p-root-node " + string(p-root-node) + chr(10)
        .
    end.
  end.
  else do:
    if p-node-code <> p-root-node
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Недопустимый признак" skip
        "На объекте выключены признаки" skip
        "Указанный признак не является корневым" skip
        "p-node-code" p-node-code skip
        error-status:get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error
        vss-workfile + "Недопустимый признак" + chr(10)
        + "На объекте выключены признаки" + chr(10)
        + "Указанный признак не является корневым" + chr(10)
        + "p-node-code " + string(p-node-code) + chr(10)
        + "p-root-node " + string(p-root-node) + chr(10)
        .
    end.
  end.
end procedure.
procedure prtat :
  define input  parameter p-node-code        like ub.gds-prt.node-code no-undo .
  define input  parameter p-action           as character              no-undo .
  define output parameter p-return-attribute as logical                no-undo .
  define variable vss-description as character no-undo initial "prtat-01: Получить атрибут шкалы/признака".
  define variable ind      as integer   no-undo .
  define variable v-action as character no-undo .
  define buffer buf_gds-prt for ub.gds-prt .
  find first buf_gds-prt no-lock
    where buf_gds-prt.node-code = p-node-code
    no-error .
  if not available buf_gds-prt
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найдена шкала." skip
      "p-node-code" p-node-code skip
      "p-action"    p-action skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  define variable v-num-entries-p-action as integer no-undo .
  assign
    v-num-entries-p-action = num-entries(p-action)
  .
  do ind = 1 to v-num-entries-p-action
  :
    assign
      v-action = entry(ind, p-action)
    .
    case v-action :
      when 'empty-scale=request'
      then do:
        if buf_gds-prt.root <> true
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Переданный признак не является корнем шкалы." skip
            "p-node-code" p-node-code skip
            "p-action"    v-action skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        assign
          p-return-attribute = (buf_gds-prt.node-name = '_Пустая шкала':U )
        .
      end.
      when 'terminal-prt=request'
      then do:
        define variable l-terminal-prt as logical no-undo .
        assign
          l-terminal-prt = true
        .
        define buffer terminal_gds-prt for ub.gds-prt .
        find first terminal_gds-prt no-lock
          where terminal_gds-prt.upper-code = p-node-code
          no-error .
        if available terminal_gds-prt
        then do:
          assign
            l-terminal-prt = false
          .
        end.
        assign
          p-return-attribute = l-terminal-prt
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестный параметр вызова." skip
          "p-node-code" p-node-code skip
          "p-action" p-action skip
          "v-action" v-action skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .
  end.
end procedure.
define temp-table temp-pl-gds no-undo
  field pl-code          like ub.pl-gds.pl-code
  field fact-qnty        like ub.pl-gds.fact-qnty
  field free-qnty        like ub.pl-gds.free-qnty
  field db-fact-qnty     like ub.pl-gds.fact-qnty
  field db-free-qnty     like ub.pl-gds.free-qnty
  field cli-fact-qnty    like ub.pl-gds.cli-fact-qnty
  field cli-free-qnty    like ub.pl-gds.cli-free-qnty
  field db-cli-fact-qnty like ub.pl-gds.cli-fact-qnty
  field db-cli-free-qnty like ub.pl-gds.cli-free-qnty
  index xpk is primary unique pl-code
.
procedure gdscheck :
  define input parameter p-obj-type  like ub.gds-obj.obj-type  no-undo .
  define input parameter p-obj-code  like ub.gds-obj.obj-code  no-undo .
  define input parameter p-artic     like ub.gds-obj.artic     no-undo .
  define input parameter p-prod-type like ub.gds-obj.prod-type no-undo .
  define input parameter p-prod-code like ub.gds-obj.prod-code no-undo .
  define input parameter p-root-node like ub.prt-obj.prt-code  no-undo .
  define input parameter p-mode      as character              no-undo .
  define variable vss-description as character no-undo initial "gdscheck-01: Проверка целостности товара" .
  define buffer buf_goods       for ub.goods .
  define buffer buf_gds-obj     for ub.gds-obj .
  define buffer buf_prt-obj     for ub.prt-obj .
  define buffer buf_parts       for ub.parts .
  define buffer buf_units       for ub.units .
  define buffer buf_contract    for ub.contract .
  define buffer buf_temp-pl-gds for temp-pl-gds .
  define buffer buf_pl-gds      for ub.pl-gds .
  define variable l-bad-gds   as logical  initial true .
  define variable v-host-code as integer   no-undo .
  define variable v-message as character no-undo .
  if  p-mode <> ""
  and p-mode <> ?
  and p-mode <> "return"
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестное значение параметра p-mode" skip
      "p-mode" p-mode skip
      view-as alert-box information.
    undo, return error return-value .
  end.
  assign
    v-message = "Объект" + " " + string(p-obj-type) + " " + string(p-obj-code) + chr(10)
              + "Товар" + " " + string(p-artic) + " "
                + string(p-prod-type) + " " + string(p-prod-code) + chr(10)
  .
  check_block:
  do
  on error undo check_block, leave
  :
    assign
      l-bad-gds = false
    .
    find first buf_goods no-lock
      where buf_goods.artic     = p-artic
        and buf_goods.prod-type = p-prod-type
        and buf_goods.prod-code = p-prod-code
      no-error .
    if not available buf_goods
    then do:
      assign
        v-message = v-message
                  + "Не найдена запись товар" + chr(10)
        l-bad-gds = true
      .
      leave check_block.
    end.
    if buf_goods.PS begins "123321"
    then do:
      return .
    end.
define variable vss-include-info59 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении кода фирмы для объекта" skip
        "Объект" p-obj-type p-obj-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    define variable l-goods-twounit as logical no-undo .
define variable vss-include-info60 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,input  'twounit=request':U
  ,output l-goods-twounit
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
        'twounit=request':u skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    find first buf_gds-obj exclusive-lock
      where buf_gds-obj.obj-type  = p-obj-type
        and buf_gds-obj.obj-code  = p-obj-code
        and buf_gds-obj.artic     = p-artic
        and buf_gds-obj.prod-type = p-prod-type
        and buf_gds-obj.prod-code = p-prod-code
      no-error .
    if not available buf_gds-obj
    then do:
      assign
        v-message = v-message
                  + "Не найдена запись товара на объекте" + chr(10)
        l-bad-gds = true
      .
      leave check_block.
    end.
    if p-root-node = ?
    then do:
define variable vss-include-info61 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output p-root-node
  ) no-error .
      if error-status :error
      then do:
        assign
          v-message = v-message
                    + "Не найден корень шкалы" + chr(10)
          l-bad-gds = true
        .
        leave check_block.
      end.
    end.
    define variable v-total-prt-obj-fact-qnty like buf_prt-obj.fact-qnty no-undo .
    define variable v-total-prt-obj-free-qnty like buf_prt-obj.free-qnty no-undo .
    assign
      v-total-prt-obj-fact-qnty = 0
      v-total-prt-obj-free-qnty = 0
    .
    for each buf_prt-obj share-lock
      where buf_prt-obj.obj-type  = p-obj-type
        and buf_prt-obj.obj-code  = p-obj-code
        and buf_prt-obj.artic     = p-artic
        and buf_prt-obj.prod-type = p-prod-type
        and buf_prt-obj.prod-code = p-prod-code
        and buf_prt-obj.prt-code  = p-root-node
    on error undo check_block, leave check_block
    :
      assign
        v-total-prt-obj-fact-qnty = v-total-prt-obj-fact-qnty + buf_prt-obj.fact-qnty
        v-total-prt-obj-free-qnty = v-total-prt-obj-free-qnty + buf_prt-obj.free-qnty
      .
    end.
    if v-total-prt-obj-fact-qnty <> buf_gds-obj.fact-qnty
    or v-total-prt-obj-free-qnty <> buf_gds-obj.free-qnty
    then do:
      assign
        v-message = v-message
                  + "Количество по шкале не совпадает с количеством по товару" + chr(10)
                  + "По товару:" + chr(10)
                  + "  " + "фактически" + " " + string(buf_gds-obj.fact-qnty) + chr(10)
                  + "  " + "свободно" + " " + string(buf_gds-obj.free-qnty) + chr(10)
                  + "По шкале:" + chr(10)
                  + "  " + "фактически" + " " + string(v-total-prt-obj-fact-qnty) + chr(10)
                  + "  " + "свободно" + " " + string(v-total-prt-obj-free-qnty) + chr(10)
        l-bad-gds = true
      .
      leave check_block.
    end.
    find first buf_units no-lock
      where buf_units.unit-name = buf_goods.unit-base
      no-error .
    if not available buf_units
    then do:
      assign
        v-message = v-message
                  + "Не найдена базовая единица измерения"
                  + string(buf_goods.unit-base) + chr(10)
        l-bad-gds = true
      .
      leave check_block.
    end.
    define variable l-goods-serial as logical no-undo .
define variable vss-include-info62 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,input  'serial=request':u
  ,output l-goods-serial
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
        'twounit=request':u skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if l-goods-serial = true
    then do:
      if buf_gds-obj.cash-parts <> true
      then do:
        assign
          v-message = v-message
                    + "У серийного товара отсутствует признак продажи по партиям (cash-parts)"
                    + chr(10)
          l-bad-gds = true
        .
        leave check_block.
      end.
    end.
    if  lookup('топ':U,  buf_units.type) > 0
    and lookup('дро':U, buf_units.type) > 0
    then do:
      if buf_gds-obj.place-rsrv <> true
      then do:
        assign
          v-message = v-message
                    + "У дробного топливного товара отсутствует признак учета по местам хранения (place-rsrv)"
                    + chr(10)
          l-bad-gds = true
        .
        leave check_block.
      end.
    end.
    if buf_gds-obj.place-rsrv = true
    then do:
      for each buf_temp-pl-gds
      on error undo, return error return-value
      :
        delete buf_temp-pl-gds .
      end.
      for each buf_pl-gds share-lock
        where buf_pl-gds.gds-code = buf_goods.gds-code
          and buf_pl-gds.obj-type = p-obj-type
          and buf_pl-gds.obj-code = p-obj-code
      on error undo, return error return-value
      :
        create buf_temp-pl-gds .
        assign
          buf_temp-pl-gds.pl-code      = buf_pl-gds.pl-code
          buf_temp-pl-gds.fact-qnty    = 0.0
          buf_temp-pl-gds.free-qnty    = 0.0
          buf_temp-pl-gds.db-fact-qnty = buf_pl-gds.fact-qnty
          buf_temp-pl-gds.db-free-qnty = buf_pl-gds.free-qnty
        .
      end.
    end.
    define variable v-parts-fact-qnty     as decimal no-undo .
    define variable v-parts-free-qnty     as decimal no-undo .
    define variable v-parts-cli-qnty      as decimal no-undo .
    define variable v-parts-add-fact-qnty as decimal no-undo .
    define variable v-parts-add-free-qnty as decimal no-undo .
    define buffer buf_trn-doc for ub.trn-doc .
    assign
      v-parts-fact-qnty = 0
      v-parts-free-qnty = 0
      v-parts-cli-qnty  = 0
    .
    for each buf_parts share-lock
      where buf_parts.obj-type  = p-obj-type
        and buf_parts.obj-code  = p-obj-code
        and buf_parts.artic     = p-artic
        and buf_parts.prod-type = p-prod-type
        and buf_parts.prod-code = p-prod-code
        and buf_parts.status_   = no
        and buf_parts.rsrv-free = yes
    on error undo check_block, leave check_block
    :
      assign
        v-parts-add-fact-qnty = 0.0
        v-parts-add-free-qnty = 0.0
      .
      if buf_parts.out-code = 'out-zone':U
      then do:
        assign
          v-message = v-message
                    + "Партия по ПН" + " " + string(buf_parts.in-code) + chr(10)
                    + "в расходной зоне логически принадлежит приходной зоне (rsrv-free=yes)" + chr(10)
          l-bad-gds = true
        .
        leave check_block.
      end.
      if buf_gds-obj.place-rsrv = true
        and ( buf_parts.pl-code = ?
              or buf_parts.pl-code = 0
            )
      then do:
        assign
          v-message = v-message
                    + "Партия по ПН" + " " + string(buf_parts.in-code) + chr(10)
                    + "Имеет не заданное складское место (pl-code)" + chr(10)
          l-bad-gds = true
        .
        leave check_block.
      end.
      if buf_parts.out-code = 'free-zone':U
      then do:
        assign
          v-parts-add-fact-qnty = v-parts-add-fact-qnty + buf_parts.qnty
          v-parts-add-free-qnty = v-parts-add-free-qnty + buf_parts.qnty
        .
      end.
      else do:
        find first buf_trn-doc no-lock
          where buf_trn-doc.doc-code = buf_parts.out-code
          no-error .
        if not available buf_trn-doc
        then do:
          assign
            v-message = v-message
                      + "Партия по ПН" + " " + string(buf_parts.in-code) + chr(10)
                      + "Не найден документ для которого зарезервирована партия" + chr(10)
                      + "Документ" + " " + string(buf_parts.out-code) + chr(10)
            l-bad-gds = true
          .
          leave check_block.
        end.
        if buf_parts.in-code <> buf_parts.out-code
        then do:
          assign
            v-parts-add-fact-qnty = v-parts-add-fact-qnty + abs(buf_parts.qnty)
          .
        end.
        if buf_trn-doc.doc-type = 'инв':U
        then do:
          if buf_parts.qnty > 0
          then do:
            assign
              v-message = v-message
                        + "Партия по ПН" + " " + string(buf_parts.in-code) + chr(10)
                        + "Зарезервированная за документом инвентаризации" + " "
                          + string(buf_parts.out-code) + chr(10)
                        + "Имеет положительный знак количества" + chr(10)
                        + "  " + "buf_trn-doc.doc-type" + " " + string(buf_trn-doc.doc-type) + chr(10)
                        + "  " + "buf_parts.qnty" + " " + string(buf_parts.qnty) + chr(10)
              l-bad-gds = true
            .
            leave check_block.
          end.
          if buf_parts.in-code <> buf_parts.out-code
          then do:
            assign
              v-parts-add-free-qnty = v-parts-add-free-qnty + abs(buf_parts.qnty)
            .
          end.
        end.
        else do:
          if buf_parts.qnty < 0
          then do:
            assign
              v-message = v-message
                        + "Партия по ПН" + " " + string(buf_parts.in-code) + chr(10)
                        + "Зарезервированная за документом" + " " + string(buf_parts.out-code) + chr(10)
                        + "Имеет отрицательный знак количества" + chr(10)
                        + "  " + "buf_trn-doc.doc-type" + " " + string(buf_trn-doc.doc-type) + chr(10)
                        + "  " + "buf_parts.qnty" + " " + string(buf_parts.qnty) + chr(10)
              l-bad-gds = true
            .
            leave check_block.
          end.
          if buf_parts.in-code = buf_parts.out-code
          then do:
            assign
              v-parts-add-free-qnty = v-parts-add-free-qnty - abs(buf_parts.qnty)
            .
          end.
        end.
      end.
      assign
        v-parts-fact-qnty = v-parts-fact-qnty + v-parts-add-fact-qnty
        v-parts-free-qnty = v-parts-free-qnty + v-parts-add-free-qnty
      .
      if buf_gds-obj.place-rsrv = true then do:
        find first buf_temp-pl-gds
          where buf_temp-pl-gds.pl-code = buf_parts.pl-code
          no-error .
        if not available buf_temp-pl-gds then do:
          create buf_temp-pl-gds .
          assign
            buf_temp-pl-gds.pl-code = buf_parts.pl-code
          .
        end.
        assign
          buf_temp-pl-gds.fact-qnty = buf_temp-pl-gds.fact-qnty + v-parts-add-fact-qnty
          buf_temp-pl-gds.free-qnty = buf_temp-pl-gds.free-qnty + v-parts-add-free-qnty
        .
      end.
      if buf_parts.contract-code = ?
      then do:
        assign
          v-message = v-message
                    + "Партия по ПН" + " " + string(buf_parts.in-code) + chr(10)
                    + "Неопределённое значение поля contract-code" + chr(10)
          l-bad-gds = true
        .
        leave check_block.
      end.
      if buf_parts.contract-code <> 0
      then do:
        find first buf_contract no-lock
          where buf_contract.host-code     = v-host-code
            and buf_contract.contract-code = buf_parts.contract-code
          no-error .
        if not available buf_contract
        then do:
          assign
            v-message = v-message
                      + "Партия по ПН" + " " + string(buf_parts.in-code) + chr(10)
                      + substitute("Не найден контракт партии") + chr(10)
                      + substitute("Код фирмы &1", v-host-code) + chr(10)
                      + substitute("Код контракта &1", buf_parts.contract-code) + chr(10)
            l-bad-gds = true
          .
          leave check_block.
        end.
        if buf_parts.supp-type <> buf_contract.cli-type
        or buf_parts.supp-code <> buf_contract.cli-code
        then do:
          if not buf_contract.doc-type = 'рас':U then do:
          assign
            v-message = v-message
                      + "Партия по ПН" + " " + string(buf_parts.in-code) + chr(10)
                      + substitute("Отличаются поставщик партии и контрагент договора") + chr(10)
                      + substitute("Поставщик партии &1 &2", buf_parts.supp-type, buf_parts.supp-code) + chr(10)
                      + substitute("Контрагент договора &1 &2",buf_contract.cli-type, buf_contract.cli-code) + chr(10)
                      + substitute("Код фирмы &1", v-host-code) + chr(10)
                      + substitute("Код контракта &1", buf_contract.contract-code) + chr(10)
            l-bad-gds = true
          .
          leave check_block.
        end.
        end.
        if  buf_parts.supp-type = 'орг':U
        and buf_parts.supp-code = v-host-code
        then do:
          assign
            v-message = v-message
                      + "Партия по ПН" + " " + string(buf_parts.in-code) + chr(10)
                      + substitute("Нельзя указывать контракт для партии, поставщиком которой является собственная фирма") + chr(10)
                      + substitute("Поставщик партии &1 &2", buf_parts.supp-type, buf_parts.supp-code) + chr(10)
                      + substitute("Контрагент договора &1 &2",buf_contract.cli-type, buf_contract.cli-code) + chr(10)
                      + substitute("Код фирмы &1", v-host-code) + chr(10)
                      + substitute("Код контракта &1", buf_contract.contract-code) + chr(10)
            l-bad-gds = true
          .
          leave check_block.
        end.
        if buf_parts.exch-code <> buf_contract.curr-code
        then do:
          assign
            v-message = v-message
                      + "Партия по ПН" + " " + string(buf_parts.in-code) + chr(10)
                      + "Не совпадают валюта партии и валюта контракта" + chr(10)
                      + substitute("Валюта партии &1", buf_parts.exch-code) + chr(10)
                      + substitute("Валюта контракта &1", buf_contract.curr-code) + chr(10)
            l-bad-gds = true
          .
          leave check_block.
        end.
        define variable v-contract-purch-code as integer   no-undo .
define variable vss-include-info63 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cntpurch in g#library
  (input  buf_contract.contract-type
  ,output v-contract-purch-code
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при определении типа поставки для контракта" skip
            "Код фирмы" v-host-code skip
            "Код контракта" buf_contract.contract-code skip
            "Тип контракта" buf_contract.contract-type skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        if v-contract-purch-code = 3
        then do:
          if  buf_parts.purch-code <> 3
          and buf_parts.purch-code <> 1
          then do:
            assign
              v-message = v-message
                        + "Партия по ПН" + " " + string(buf_parts.in-code) + chr(10)
                        + "Не совпадают тип поставки партии и тип поставки контракта" + chr(10)
                        + substitute("Код фирмы &1", v-host-code) + chr(10)
                        + substitute("Код контракта &1", buf_contract.contract-code) + chr(10)
                        + substitute("Тип поставки партии &1", buf_parts.purch-code) + chr(10)
                        + substitute("Тип поставки контракта &1", v-contract-purch-code) + chr(10)
              l-bad-gds = true
            .
            leave check_block.
          end.
        end.
        else do:
          if buf_parts.purch-code <> v-contract-purch-code
          then do:
            assign
              v-message = v-message
                        + "Партия по ПН" + " " + string(buf_parts.in-code) + chr(10)
                        + "Не совпадают тип поставки партии и тип поставки контракта" + chr(10)
                        + substitute("Код фирмы &1", v-host-code) + chr(10)
                        + substitute("Код контракта &1", buf_contract.contract-code) + chr(10)
                        + substitute("Тип поставки партии &1", buf_parts.purch-code) + chr(10)
                        + substitute("Тип поставки контракта &1", v-contract-purch-code) + chr(10)
              l-bad-gds = true
            .
            leave check_block.
          end.
        end.
      end.
      if l-goods-twounit
      then do:
        if buf_parts.out-code = 'free-zone':U
        then do:
          assign
            v-parts-cli-qnty = v-parts-cli-qnty + buf_parts.cli-qnty
          .
        end.
        else do:
          if buf_parts.in-code <> buf_parts.out-code
          then do:
            assign
              v-parts-cli-qnty = v-parts-cli-qnty + abs(buf_parts.cli-qnty)
            .
          end.
        end.
      end.
    end.
    if buf_gds-obj.place-rsrv = true
    then do:
      define variable is-petrol as logical no-undo .
      define variable is-pieces as logical no-undo .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_goods.artic
  ,  input buf_goods.prod-type
  ,  input buf_goods.prod-code
  , output is-petrol
  , output is-pieces
  ) no-error.
      if error-status :error
      then do:
        assign
          is-petrol = ?
          is-pieces = ?
        .
      end.
      if not( is-petrol = true
              and is-pieces = false
            )
      then do:
        for each buf_temp-pl-gds
        on error undo check_block, leave check_block
        :
          if buf_temp-pl-gds.db-fact-qnty <> buf_temp-pl-gds.fact-qnty
          or buf_temp-pl-gds.db-free-qnty <> buf_temp-pl-gds.free-qnty
          then do:
            assign
              v-message = v-message
                        + "Количество по партиям свободной зоны и зарезервированным партиям" + chr(10)
                        + "не совпадает с количеством по месту резервирования" + chr(10)
                        + "Место хранения:" + " " + string(buf_temp-pl-gds.pl-code) + chr(10)
                        + "  " + "фактически" + " " + string(buf_temp-pl-gds.db-fact-qnty) + chr(10)
                        + "  " + "свободно" + " " + string(buf_temp-pl-gds.db-free-qnty) + chr(10)
                        + "По партиям:" + chr(10)
                        + "  " + "фактически" + " " + string(buf_temp-pl-gds.fact-qnty) + chr(10)
                        + "  " + "свободно" + " " + string(buf_temp-pl-gds.free-qnty) + chr(10)
              l-bad-gds = true
            .
            leave check_block.
          end.
        end.
      end.
    end.
    if v-parts-fact-qnty <> buf_gds-obj.fact-qnty
    or v-parts-free-qnty <> buf_gds-obj.free-qnty
    then do:
      assign
        v-message = v-message
                  + "Количество по партиям свободной зоны и зарезервированным партиям" + chr(10)
                  + "не совпадает с количеством по товару" + chr(10)
                  + "По товару:" + chr(10)
                  + "  " + "фактически" + " " + string(buf_gds-obj.fact-qnty) + chr(10)
                  + "  " + "свободно" + " " + string(buf_gds-obj.free-qnty) + chr(10)
                  + "По партиям:" + chr(10)
                  + "  " + "фактически" + " " + string(v-parts-fact-qnty) + chr(10)
                  + "  " + "свободно" + " " + string(v-parts-free-qnty) + chr(10)
        l-bad-gds = true
      .
      leave check_block.
    end.
    if l-goods-twounit
    then do:
      if v-parts-cli-qnty <> buf_gds-obj.fact-cli-qnty
      then do:
        assign
          v-message = v-message
                    + "Количество второй единицы измерения по партиям свободной зоны и зарезервированным партиям" + chr(10)
                    + "не совпадает с количеством второй единицы измерения по товару" + chr(10)
                    + "По товару:" + chr(10)
                    + "  " + "фактически" + " " + string(buf_gds-obj.fact-qnty) + chr(10)
                    + "  " + "свободно" + " " + string(buf_gds-obj.free-qnty) + chr(10)
                    + "  " + "вторая ед. изм." + " " + string(buf_gds-obj.fact-cli-qnty) + chr(10)
                    + "По партиям:" + chr(10)
                    + "  " + "фактически" + " " + string(v-parts-fact-qnty) + chr(10)
                    + "  " + "свободно" + " " + string(v-parts-free-qnty) + chr(10)
                    + "  " + "вторая ед. изм." + " " + string(v-parts-cli-qnty) + chr(10)
          l-bad-gds = true
        .
        leave check_block.
      end.
    end.
  end.
  if l-bad-gds
  then do:
    define variable v-return-value as character no-undo .
    if p-mode = ""
    or p-mode = ?
    then do:
      message
        vss-workfile + " " + vss-revision + " " + vss-description + chr(10)
        v-message + chr(10)
        view-as alert-box .
    end.
    if p-mode = "return"
    then do:
      assign
        v-return-value = v-message
      .
    end.
    undo, return error v-return-value .
  end.
end procedure.
procedure prtlevel :
  define input  parameter p-root-node  like ub.gds-prt.node-code no-undo .
  define output parameter p-prt-level  as integer no-undo .
  define variable vss-description as character no-undo initial "prtlevel-01: определяет количество уровней в шкале".
  do
  on error undo, return error return-value
  :
    define buffer buf_gds-prt for ub.gds-prt .
    find first buf_gds-prt no-lock
      where buf_gds-prt.node-code = p-root-node
      use-index level
      no-error.
    if not available buf_gds-prt
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найдена шкала" skip
        "p-root-node" p-root-node skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if buf_gds-prt.root <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Переданный признак не является корнем шкалы." skip
        "p-root-node" p-root-node skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      p-prt-level = 1
    .
    define variable terminal-n-c like ub.gds-prt.node-code no-undo .
    assign
      terminal-n-c = p-root-node
    .
    do while true:
      find first buf_gds-prt no-lock
        where buf_gds-prt.upper-code = terminal-n-c
        use-index level
        no-error.
      if not available buf_gds-prt
      then do:
        return .
      end.
      assign
        p-prt-level  = p-prt-level + 1
        terminal-n-c = buf_gds-prt.node-code
      .
    end.
  end.
end procedure.
procedure termnode :
  define input parameter  p-node-code  like ub.gds-prt.node-code no-undo .
  define output parameter terminal-n-c like ub.gds-prt.node-code no-undo .
  define variable vss-description as character no-undo initial "termnode-01: определение первого терминального признака для указанного признака".
  define buffer terminal_gds-prt for ub.gds-prt .
  assign
    terminal-n-c = p-node-code
  .
  do while true:
    find first terminal_gds-prt no-lock
      where terminal_gds-prt.upper-code = terminal-n-c
      use-index level
      no-error.
    if not available terminal_gds-prt
    then do:
      return .
    end.
    assign
      terminal-n-c = terminal_gds-prt.node-code
    .
  end.
end procedure.
procedure cligdscr :
  define input parameter  v-cli-type  like ub.cli-gds.cli-type  no-undo .
  define input parameter  v-cli-code  like ub.cli-gds.cli-code  no-undo .
  define input parameter  v-host-code like ub.cli-gds.host-code no-undo .
  define input parameter  v-artic     like ub.cli-gds.artic     no-undo .
  define input parameter  v-prod-type like ub.cli-gds.prod-type no-undo .
  define input parameter  v-prod-code like ub.cli-gds.prod-code no-undo .
  define parameter buffer buf_cli-gds for ub.cli-gds .
  define variable vss-description as character no-undo initial "cligdscr-01: поиск/cоздание записи остатков по объекту".
   find first buf_cli-gds no-lock
    where buf_cli-gds.cli-type  = v-cli-type
      and buf_cli-gds.cli-code  = v-cli-code
      and buf_cli-gds.host-code = v-host-code
      and buf_cli-gds.artic     = v-artic
      and buf_cli-gds.prod-type = v-prod-type
      and buf_cli-gds.prod-code = v-prod-code
    no-error.
  if not available buf_cli-gds
  then do:
    do transaction
    on error undo, return error return-value
    :
      create buf_cli-gds.
      assign
        buf_cli-gds.cli-type  = v-cli-type
        buf_cli-gds.cli-code  = v-cli-code
        buf_cli-gds.host-code = v-host-code
        buf_cli-gds.artic     = v-artic
        buf_cli-gds.prod-type = v-prod-type
        buf_cli-gds.prod-code = v-prod-code
      .
      assign
        buf_cli-gds.in-rubl   = 0
        buf_cli-gds.in-base   = 0
        buf_cli-gds.in-qnty   = 0
        buf_cli-gds.out-qnty  = 0
        buf_cli-gds.ret-qnty  = 0
      .
         release buf_cli-gds.
    end.
    find first buf_cli-gds no-lock
    where buf_cli-gds.cli-type  = v-cli-type
      and buf_cli-gds.cli-code  = v-cli-code
      and buf_cli-gds.host-code = v-host-code
      and buf_cli-gds.artic     = v-artic
      and buf_cli-gds.prod-type = v-prod-type
      and buf_cli-gds.prod-code = v-prod-code
    .
  end.
end procedure.
procedure unitqnty :
  define input parameter  p-unit-name        like ub.units.unit-name no-undo .
  define input parameter  p-artic            like ub.goods.artic     no-undo .
  define input parameter  p-prod-type        like ub.goods.prod-type no-undo .
  define input parameter  p-prod-code        like ub.goods.prod-code no-undo .
  define input parameter  p-unit-description as character            no-undo .
  define input parameter  p-qnty             as decimal              no-undo .
  define variable vss-description as character no-undo initial "unitqnty-01: Контроль допустимых количеств для данной единицы измерения (товара)".
  define buffer buf_units for ub.units .
  define buffer buf_goods for ub.goods .
  define variable v-artic as character no-undo .
  if p-unit-description = ''
  or p-unit-description = ?
  then do:
    assign
      p-unit-description = "Единица измерения"
    .
  end.
  if  p-unit-name <> ''
  and p-unit-name <> ?
  then do:
    find first buf_units no-lock
      where buf_units.unit-name = p-unit-name
      no-error .
    if not available buf_units
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена единица измерения" skip
        "p-unit-name"   p-unit-name skip
        "p-artic"       p-artic  skip
        "p-prod-type"   p-prod-type skip
        "p-proc-code"   p-prod-code skip
        "p-qnty"        p-qnty skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
  else do:
    find first buf_goods no-lock
      where buf_goods.artic     = p-artic
        and buf_goods.prod-type = p-prod-type
        and buf_goods.prod-code = p-prod-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "p-unit-name"   p-unit-name skip
        "p-artic"       p-artic  skip
        "p-prod-type"   p-prod-type skip
        "p-proc-code"   p-prod-code skip
        "p-qnty"        p-qnty skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    find first buf_units no-lock
      where buf_units.unit-name = buf_goods.unit-base
      no-error .
    if not available buf_units
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена единица измерения" skip
        "p-unit-name"   p-unit-name skip
        "p-artic"       p-artic  skip
        "p-prod-type"   p-prod-type skip
        "p-proc-code"   p-prod-code skip
        "p-qnty"        p-qnty skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      v-artic = "Артикул " + string(p-artic) + " " + string(p-prod-type)
              + " " + string(p-prod-code)
      p-unit-description = "Базовая единица измерения"
    .
  end.
  if lookup('шту':U, buf_units.type) > 0
  or lookup('сер':U, buf_units.type) > 0
  then do:
    if p-qnty <> truncate(p-qnty, 0)
    then do:
      message
        "Для штучного и серийного товаров резервируемое количество должно быть целым" skip
        v-artic skip
        p-unit-description buf_units.unit-name skip
        "Запрошено количество " p-qnty skip
        view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
function not-null-string returns character
  (input p-str as character )
:
  if p-str = ?
  then do:
    return '?' .
  end.
  return p-str .
end.
procedure usrnick :
define input parameter p-user-id as character        no-undo.
define output parameter p-nick   as character        no-undo.
   define buffer buf_user-account      for ub.user-account .
do
for buf_user-account
on error undo, return error
:
   find first buf_user-account no-lock
        where buf_user-account.user-id = p-user-id
   no-error.
   if available buf_user-account
   then do:
       assign
           p-nick = buf_user-account.nik
       .
   end.
   else do:
       assign
           p-nick = p-user-id
       .
   end.
end.
end procedure.
procedure chkextdt :
  define parameter buffer buf_trn-doc for ub.trn-doc .
  define variable vss-description as character no-undo initial "chkextdt-01: проверка соответствия типа и расширенного типа документа".
  do
  on error undo, return error return-value
  :
    case buf_trn-doc.ext-doc-type :
      when 'ie':U
      then do:
        if  buf_trn-doc.doc-type    = 'при':U
        and buf_trn-doc.internal    = false
        and buf_trn-doc.discnt-type = ""
        and buf_trn-doc.ret-supp    = false
        then do:
          return .
        end.
      end.
      when 'ee':U
      then do:
        if  buf_trn-doc.doc-type    = 'рас':U
        and buf_trn-doc.internal    = false
        and lookup(buf_trn-doc.discnt-type, 'процент,карта,группа,сумма,строка,прайс-лист':U) > 0
        and buf_trn-doc.ret-supp    = false
        then do:
          return .
        end.
      end.
      when 'ep':U
      then do:
        if  buf_trn-doc.doc-type    = 'рас':U
        and buf_trn-doc.internal    = false
        and lookup(buf_trn-doc.discnt-type, 'процент,карта,группа,сумма,строка,прайс-лист':U) > 0
        and buf_trn-doc.ret-supp    = true
        then do:
          return .
        end.
      end.
      when 'es':U
      then do:
        if  buf_trn-doc.doc-type    = 'рас':U
        and buf_trn-doc.internal    = false
        and buf_trn-doc.discnt-type = 'касс':U
        and buf_trn-doc.ret-supp    = false
        then do:
          return .
        end.
      end.
      when 're':U
      then do:
        if  buf_trn-doc.doc-type    = 'возврат':U
        and buf_trn-doc.internal    = false
        and lookup(buf_trn-doc.discnt-type, 'процент,карта,группа,сумма,строка,прайс-лист':U) > 0
        and buf_trn-doc.ret-supp    = false
        then do:
          return .
        end.
      end.
      when 'rs':U
      then do:
        if  buf_trn-doc.doc-type    = 'возврат':U
        and buf_trn-doc.internal    = false
        and buf_trn-doc.discnt-type = 'касс':U
        and buf_trn-doc.ret-supp    = false
        then do:
          return .
        end.
      end.
      when 'we':U
      then do:
        if  buf_trn-doc.doc-type    = 'спи':U
        and buf_trn-doc.internal    = false
        and lookup(buf_trn-doc.discnt-type, 'процент,карта,группа,сумма,строка,прайс-лист':U) > 0
        and buf_trn-doc.ret-supp    = false
        then do:
          return .
        end.
      end.
      when 'vt':U
      then do:
        if  buf_trn-doc.doc-type    = 'инв':U
        and buf_trn-doc.internal    = false
        and buf_trn-doc.discnt-type = ""
        and buf_trn-doc.ret-supp    = false
        then do:
          return .
        end.
      end.
      when 'vp':U
      then do:
        if  buf_trn-doc.doc-type    = 'инв':U
        and buf_trn-doc.internal    = false
        and buf_trn-doc.discnt-type = ""
        and buf_trn-doc.ret-supp    = false
        then do:
          return .
        end.
      end.
      when 'iv':U
      then do:
        if  buf_trn-doc.doc-type    = 'при':U
        and buf_trn-doc.internal    = true
        and buf_trn-doc.discnt-type = 'процент':U
        and buf_trn-doc.ret-supp    = false
        then do:
          return .
        end.
      end.
      when 'ev':U
      then do:
        if  buf_trn-doc.doc-type    = 'рас':U
        and buf_trn-doc.internal    = true
        and buf_trn-doc.discnt-type = 'процент':U
        and buf_trn-doc.ret-supp    = false
        then do:
          return .
        end.
      end.
      when 'io':U
      then do:
        if  buf_trn-doc.doc-type    = 'при':U
        and buf_trn-doc.internal    = true
        and buf_trn-doc.discnt-type = 'процент':U
        and buf_trn-doc.ret-supp    = false
        then do:
          return .
        end.
      end.
      when 'eo':U
      then do:
        if  buf_trn-doc.doc-type    = 'рас':U
        and buf_trn-doc.internal    = true
        and buf_trn-doc.discnt-type = 'процент':U
        and buf_trn-doc.ret-supp    = false
        then do:
          return .
        end.
      end.
      when 'rv':U
      then do:
        if  buf_trn-doc.doc-type    = 'возврат':U
        and buf_trn-doc.internal    = true
        and buf_trn-doc.discnt-type = 'процент':U
        and buf_trn-doc.ret-supp    = false
        then do:
          return .
        end.
      end.
      when 'em':U
      then do:
        if  buf_trn-doc.doc-type    = 'рас':U
        and buf_trn-doc.internal    = true
        and buf_trn-doc.discnt-type = 'прво':U
        and buf_trn-doc.ret-supp    = false
        then do:
          return .
        end.
      end.
      when 'wm':U
      then do:
        if  buf_trn-doc.doc-type    = 'спи':U
        and buf_trn-doc.internal    = true
        and buf_trn-doc.discnt-type = 'прво':U
        and buf_trn-doc.ret-supp    = false
        then do:
          return .
        end.
      end.
      when 'im':U
      then do:
        if  buf_trn-doc.doc-type    = 'при':U
        and buf_trn-doc.internal    = true
        and buf_trn-doc.discnt-type = 'прво':U
        and buf_trn-doc.ret-supp    = false
        then do:
          return .
        end.
      end.
      when 'ot':U
      then do:
      end.
      when 'ap':U
      then do:
        if  buf_trn-doc.doc-type    = 'инв':U
        and buf_trn-doc.internal    = false
        and buf_trn-doc.discnt-type = ""
        and buf_trn-doc.ret-supp    = false
        then do:
          return .
        end.
      end.
      when 'mp':U
      then do:
        if  buf_trn-doc.doc-type    = 'инв':U
        and buf_trn-doc.internal    = false
        and buf_trn-doc.discnt-type = ""
        and buf_trn-doc.ret-supp    = false
        then do:
          return .
        end.
      end.
      when 'pc':U
      then do:
        if  buf_trn-doc.doc-type    = 'инв':U
        and buf_trn-doc.internal    = false
        and buf_trn-doc.discnt-type = ""
        and buf_trn-doc.ret-supp    = false
        then do:
          return .
        end.
      end.
    end.
    return error substitute(vss-description
      + "Противоречивое состояние полей типа документа." + chr(10)
      + "doc-code &1" + chr(10)
      + "doc-type &2" + chr(10)
      + "internal &3" + chr(10)
      + "discnt-type &4" + chr(10)
      + "ret-supp &5" + chr(10)
      + "status_ &6" + chr(10)
      + "obj-type &7" + chr(10)
      + "obj-code &8" + chr(10)
      + "ext-doc-type &9" + chr(10)
      , buf_trn-doc.doc-code
      , buf_trn-doc.doc-type
      , buf_trn-doc.internal
      , buf_trn-doc.discnt-type
      , buf_trn-doc.ret-supp
      , buf_trn-doc.status_
      , buf_trn-doc.obj-type
      , buf_trn-doc.obj-code
      , buf_trn-doc.ext-doc-type
      ) .
  end.
end procedure.
procedure trnextdt :
  define input  parameter p-ext-doc-type as character no-undo .
  define output parameter p-doc-type     as character no-undo .
  define variable vss-description as character no-undo initial "trnextdt-01: возвращает тип документа в соответствии с его расширенным типом".
  do
  on error undo, return error return-value
  :
    case p-ext-doc-type
    :
      when 'ie':U
      then do:
        assign
          p-doc-type = 'при':U
        .
      end.
      when 'ee':U
      then do:
        assign
          p-doc-type = 'рас':U
        .
      end.
      when 'ep':U
      then do:
        assign
          p-doc-type = 'рас':U
        .
      end.
      when 'es':U
      then do:
        assign
          p-doc-type = 'рас':U
        .
      end.
      when 're':U
      then do:
        assign
          p-doc-type = 'возврат':U
        .
      end.
      when 'rs':U
      then do:
        assign
          p-doc-type = 'возврат':U
        .
      end.
      when 'we':U
      then do:
        assign
          p-doc-type = 'спи':U
        .
      end.
      when 'vt':U
      then do:
        assign
          p-doc-type = 'инв':U
        .
      end.
      when 'vp':U
      then do:
        assign
          p-doc-type = 'инв':U
        .
      end.
      when 'iv':U
      then do:
        assign
          p-doc-type = 'при':U
        .
      end.
      when 'ev':U
      then do:
        assign
          p-doc-type = 'рас':U
        .
      end.
      when 'io':U
      then do:
        assign
          p-doc-type = 'при':U
        .
      end.
      when 'eo':U
      then do:
        assign
          p-doc-type = 'рас':U
        .
      end.
      when 'rv':U
      then do:
        assign
          p-doc-type = 'возврат':U
        .
      end.
      when 'em':U
      then do:
        assign
          p-doc-type = 'рас':U
        .
      end.
      when 'wm':U
      then do:
        assign
          p-doc-type = 'спи':U
        .
      end.
      when 'im':U
      then do:
        assign
          p-doc-type = 'при':U
        .
      end.
      when 'ap':U
      then do:
        assign
          p-doc-type = 'инв':U
        .
      end.
      when 'mp':U
      then do:
        assign
          p-doc-type = 'инв':U
        .
      end.
      when 'pc':U
      then do:
        assign
          p-doc-type = 'инв':U
        .
      end.
      otherwise do:
        return error substitute(vss-description
          + "Неизвестный расширенный тип документа &1" + chr(10)
          , p-ext-doc-type
          ) .
      end.
    end.
  end.
end procedure.
procedure gdsdtlcr :
  define input parameter  v-root-node  like ub.gds-dtl.prt-code no-undo .
  define parameter buffer buf_doc-line for ub.doc-line .
  define parameter buffer buf_gds-dtl  for ub.gds-dtl .
  define variable vss-description as character no-undo initial "gdsdtlcr-02: Создается корневой gds-dtl в накладной на основании строки накладной".
  define buffer buf_trn-doc for ub.trn-doc .
  do
  on error undo, return error return-value
  :
    if v-root-node = ?
    then do:
define variable vss-include-info64 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,output v-root-node
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении корневого признака шкалы" skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
    find first buf_gds-dtl
      where buf_gds-dtl.doc-code  = buf_doc-line.doc-code
        and buf_gds-dtl.artic     = buf_doc-line.artic
        and buf_gds-dtl.prod-type = buf_doc-line.prod-type
        and buf_gds-dtl.prod-code = buf_doc-line.prod-code
        and buf_gds-dtl.prt-code  = v-root-node
      no-error .
    if not available buf_gds-dtl
    then do:
      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = buf_doc-line.doc-code
        no-error .
      if not available buf_trn-doc
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найден документ" skip
          "Документ" buf_doc-line.doc-code skip
          error-status :get-message(1) skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      define variable l-cr-root-gds-dtl as logical no-undo .
define variable vss-include-info65 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  buf_doc-line.obj-type
  ,input  buf_doc-line.obj-code
  ,input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,input  'cr-root-gds-dtl=request':U
  ,output l-cr-root-gds-dtl
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении признака товара на объекте" skip
          "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          "Запрашиваемый атрибут" "cash-parts=request":u skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      if l-cr-root-gds-dtl = false
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Недопустимо создавать корневой признак в накладной для товара" skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      create buf_gds-dtl.
      assign
        buf_gds-dtl.doc-code  = buf_doc-line.doc-code
        buf_gds-dtl.artic     = buf_doc-line.artic
        buf_gds-dtl.prod-code = buf_doc-line.prod-code
        buf_gds-dtl.prod-type = buf_doc-line.prod-type
        buf_gds-dtl.prt-code  = v-root-node
        buf_gds-dtl.obj-type  = buf_doc-line.obj-type
        buf_gds-dtl.obj-code  = buf_doc-line.obj-code
      .
      if buf_trn-doc.ext-doc-type = 'vt':U              or
         buf_trn-doc.ext-doc-type = 'vp':U         or
         buf_trn-doc.ext-doc-type = 'ap':U   or
         buf_trn-doc.ext-doc-type = 'mp':U or
         buf_trn-doc.ext-doc-type = 'pc':U   then do:
        assign
          buf_gds-dtl.doc-qnty  = buf_doc-line.fact-qnty
          buf_gds-dtl.fact-qnty = buf_doc-line.doc-qnty
        .
      end.
      else do:
        assign
          buf_gds-dtl.doc-qnty  = buf_doc-line.doc-qnty
          buf_gds-dtl.fact-qnty = buf_doc-line.fact-qnty
        .
      end.
    end.
  end.
end procedure.
procedure trnat :
  define input parameter  p-trn-doc-doc-type     like ub.trn-doc.doc-type     no-undo .
  define input parameter  p-trn-doc-internal     like ub.trn-doc.internal     no-undo .
  define input parameter  p-trn-doc-discnt-type  like ub.trn-doc.discnt-type  no-undo .
  define input parameter  p-trn-doc-status_      like ub.trn-doc.status_      no-undo .
  define input parameter  p-trn-doc-flag         like ub.trn-doc.flag_        no-undo .
  define input parameter  p-trn-doc-ext-doc-type like ub.trn-doc.ext-doc-type no-undo.
  define input  parameter p-action               as   character               no-undo .
  define output parameter p-return-attribute     as   character               no-undo .
  define variable vss-description as character no-undo initial "trnat-01: Задает/получает различные признаки товара на объекте".
  define variable ind      as integer no-undo .
  define variable v-action as character no-undo .
  define variable v-num-entries-p-action as integer no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-num-entries-p-action = num-entries(p-action)
    .
    do ind = 1 to v-num-entries-p-action
    :
      assign
        v-action = entry(ind, p-action)
      .
      case v-action :
        when "can-change-status-inv-on=request"
        then do:
          if  p-trn-doc-doc-type = 'инв':U
          then do:
            assign
              p-return-attribute = "true":u
            .
            next .
          end.
          if  p-trn-doc-doc-type = 'при':U
          and p-trn-doc-internal = false
          and p-trn-doc-status_  = 'накл':U
          then do:
            assign
              p-return-attribute = "true":u
            .
            next .
          end.
          assign
            p-return-attribute = "false":u
          .
        end.
        when "can-edit-inv-on=request":u
        then do:
          if  p-trn-doc-doc-type     = 'инв':U
          and p-trn-doc-ext-doc-type = 'vt':U
          and p-trn-doc-status_      = 'разрешен':U
          and p-trn-doc-flag         = true
          then do:
            assign
              p-return-attribute = "true":u
            .
            next .
          end.
          if  p-trn-doc-doc-type     = 'инв':U
          and p-trn-doc-ext-doc-type = 'vp':U
          and p-trn-doc-status_      = 'накл':U
          and p-trn-doc-flag         = false
          then do:
            assign
              p-return-attribute = "true":u
            .
            next .
          end.
          if  p-trn-doc-doc-type     = 'инв':U
          and p-trn-doc-ext-doc-type = 'ap':U
          and p-trn-doc-status_      = 'накл':U
          and p-trn-doc-flag         = false
          then do:
            assign
              p-return-attribute = "true":u
            .
            next .
          end.
          if  p-trn-doc-doc-type     = 'инв':U
          and p-trn-doc-ext-doc-type = 'mp':U
          and p-trn-doc-status_      = 'накл':U
          and p-trn-doc-flag         = false
          then do:
            assign
              p-return-attribute = "true":u
            .
            next .
          end.
          if  p-trn-doc-doc-type = 'при':U
          and p-trn-doc-internal = false
          and p-trn-doc-status_  = 'накл':U
          then do:
            assign
              p-return-attribute = "true":u
            .
            next .
          end.
          assign
            p-return-attribute = "false":u
          .
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестное значение параметра v-action " skip
            "v-action" v-action skip
            "p-action" p-action skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
    end.
  end.
end procedure.
procedure qntycalc :
  define input parameter  p-calc-method   as character                   no-undo .
  define input parameter  p-cli-base-rate like ub.doc-line.cli-base-rate no-undo .
  define input parameter  p-cli-qnty      like ub.doc-line.cli-qnty      no-undo .
  define input parameter  p-doc-qnty      like ub.doc-line.doc-qnty      no-undo .
  define output parameter p-new-cli-qnty  like ub.doc-line.cli-qnty      no-undo .
  define output parameter p-new-doc-qnty  like ub.doc-line.doc-qnty      no-undo .
  define variable vss-description as character no-undo initial "qntycalc-01: Пересчет количеств из одной единицы измерения в другую".
  do
  on error undo, return error return-value
  :
    if p-cli-base-rate <= 0
    or p-cli-base-rate = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Невозможно пересчитать количество при коэффициенте пересчета " skip
        string(p-cli-base-rate) chr(10)
        view-as alert-box error .
      undo, return error
        "Невозможно пересчитать количество при коэффициенте пересчета "
        + string(p-cli-base-rate) + chr(10)
        .
    end.
    define variable v-round-parameter as integer no-undo .
    if p-cli-base-rate = 1
    then do:
      assign
        v-round-parameter = 10
      .
    end.
    else do:
      assign
        v-round-parameter = 3
      .
    end.
    case p-calc-method :
      when "cli-qnty"
      then do:
        if abs(p-doc-qnty - round(p-cli-qnty * p-cli-base-rate, v-round-parameter)) < 0.0011
        then do:
          assign
            p-new-cli-qnty = p-cli-qnty
            p-new-doc-qnty = p-doc-qnty
          .
        end.
        else do:
          assign
            p-new-cli-qnty = round(p-doc-qnty / p-cli-base-rate, v-round-parameter)
          .
          assign
            p-new-doc-qnty = p-doc-qnty
          .
          if abs(p-new-doc-qnty - p-new-cli-qnty * p-cli-base-rate) > 0.001
          then do:
            undo, return error
              "Невозможно пересчитать количество по документу " + string(p-doc-qnty) + chr(10)
              + "в количество по ТТН" + chr(10)
              + "при коэффициенте пересчета " + string(p-cli-base-rate, "->>>,>>9.9999999999") + chr(10)
              + "p-new-doc-qnty " + string(p-new-doc-qnty) + chr(10)
              + "p-new-cli-qnty " + string(p-new-cli-qnty) + chr(10)
              + "p-new-cli-qnty * p-cli-base-rate " + string(p-new-cli-qnty * p-cli-base-rate) + chr(10)
              .
          end.
        end.
      end.
      when "doc-qnty"
      then do:
        assign
          p-new-cli-qnty = p-cli-qnty
          p-new-doc-qnty = round(p-cli-qnty * p-cli-base-rate, v-round-parameter)
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестное значение парметра" skip
          "p-calc-method" p-calc-method skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.
end procedure.
procedure needprts :
  define input  parameter p-ext-doc-type         like ub.trn-doc.ext-doc-type         no-undo .
  define input  parameter p-cli-type             like ub.trn-doc.cli-type             no-undo .
  define input  parameter p-cli-code             like ub.trn-doc.cli-code             no-undo .
  define input  parameter p-hold-doc-code-child  like ub.trn-doc.hold-doc-code-child  no-undo .
  define input  parameter p-hold-doc-code-parent like ub.trn-doc.hold-doc-code-parent no-undo .
  define input  parameter p-status               like ub.trn-doc.status_              no-undo .
  define output parameter p-result               as   character                       no-undo .
  define variable vss-description as character no-undo initial "needprts-01: Определяет способ резервирования партий за документом возврата поставщику".
  define buffer bf_sysconf for ub.sysconf.
  define variable varhold          as character no-undo.
  define variable varhold-type     as character no-undo.
  do for bf_sysconf
  on error undo, return error substitute ("&1 &2", return-value, error-status:get-message(1))
  :
    if p-ext-doc-type <> 'ep':U
    then do:
      assign
        p-result = 'all':u
      .
      return .
    end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'holding':U
  ,input  '':U
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  true
  ,output varhold
  ,output varhold-type
  )  .
    if lookup(varhold, 'true,yes':u) = 0
    then do:
      assign
        p-result = 'all':u
      .
    end.
    else do:
      if p-cli-type <> 'орг':U
      then do:
        assign
          p-result = 'all':u
        .
      end.
      else do:
        find first bf_sysconf no-lock
          where bf_sysconf.host-code = p-cli-code
          no-error.
        if not available bf_sysconf
        then do:
          assign
            p-result = 'all':u
          .
        end.
        else do:
          if  (p-hold-doc-code-child  = '':u
               or
               p-hold-doc-code-child  = 'no-hold':u
              )
          and (p-hold-doc-code-parent = '':u
               or
               p-hold-doc-code-parent = 'no-hold':u
              )
          then do:
            assign
              p-result = 'no-hold':u
            .
          end.
          else do:
            assign
              p-result = 'hold':u
            .
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure part-prc :
  define parameter buffer buf_parts               for ub.parts .
  define parameter buffer buf_trn-doc             for ub.trn-doc .
  define input  parameter p-reserv-single-part    as logical   no-undo .
  define input  parameter p-single-part-in-code   as character no-undo .
  define input  parameter p-single-part-part-code as character no-undo .
  define input  parameter p-pl-code               as decimal   no-undo .
  define input  parameter p-goods-twounit         as logical   no-undo .
  define input  parameter p-purch-code-list       as character no-undo .
  define input  parameter p-rsrv-qnty             as decimal   no-undo .
  define input  parameter p-check-negmanuf        as logical   no-undo .
  define output parameter p-reason                as character no-undo .
  define output parameter p-process-part          as logical   no-undo .
  define variable vss-description as character no-undo initial "Проверка возможности резервирования партии".
  define variable v-value-character as character no-undo .
  define variable v-value-date      as date      no-undo .
  define variable v-value-decimal   as decimal   no-undo .
  define variable v-value-integer   as integer   no-undo .
  define variable v-avail-on-date   as logical   no-undo .
  define variable v-avail-on-date-type as character no-undo .
  define variable v-tth             as handle no-undo .
  do
  on error undo, return error return-value
  :
    if not available buf_parts
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не задана запись партий"
        view-as alert-box error .
      undo, return error return-value .
    end.
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не задана запись документа"
        view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      p-process-part = true
    .
    define variable v-date-compare as date      no-undo .
    if buf_trn-doc.doc-type = 'рас':U and buf_parts.out-code = 'free-zone':U and
       buf_trn-doc.ext-doc-type <> 'ep':U  then do:
        if  buf_trn-doc.ext-doc-type = 'es':U  then do:
             v-date-compare =  buf_trn-doc.doc-date .
           end.
           else do:
             v-date-compare =  buf_trn-doc.fact-date .
           end.
       if v-date-compare < buf_parts.fact-date then do:
  delete object v-tth no-error.
  run adm/shattri.p (
      input "get":U
      ,input buf_trn-doc.obj-type
      ,input buf_trn-doc.obj-code
      ,input 'nakl_par':U
      ,input  "avail-on-date"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-avail-on-date
      ,output v-avail-on-date-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
      if error-status :error  then v-avail-on-date = false .
      delete object v-tth no-error.
      if v-avail-on-date = true then do:
            message  substitute("По товару &3 (&4&5)  дата прихода партии &2 позже даты расхода (док.дата &1 и факт.дата &6 ) !!!" ,buf_trn-doc.doc-date , buf_parts.fact-date , buf_parts.artic, buf_parts.prod-type , buf_parts.prod-code ,buf_trn-doc.fact-date) view-as alert-box error .
            p-reason        = substitute("По товару &3 (&4&5)  дата прихода партии &2 позже даты расхода (док.дата &1 и факт.дата &6 ) !!!" ,buf_trn-doc.doc-date , buf_parts.fact-date , buf_parts.artic, buf_parts.prod-type , buf_parts.prod-code ,buf_trn-doc.fact-date) .
            p-process-part  = false.
            return .
       end.
    end.
    end.
    define variable v-rsrv-type as character no-undo .
    run needprts in this-procedure
      (input  buf_trn-doc.ext-doc-type
      ,input  buf_trn-doc.cli-type
      ,input  buf_trn-doc.cli-code
      ,input  buf_trn-doc.hold-doc-code-child
      ,input  buf_trn-doc.hold-doc-code-parent
      ,input  buf_trn-doc.status_
      ,output v-rsrv-type
      ) .
    if v-rsrv-type = 'hold':u
    then do:
      define buffer buf_income_trn-doc for ub.trn-doc .
      find first buf_income_trn-doc no-lock
        where buf_income_trn-doc.doc-code = buf_parts.in-code
        no-error .
      if not available buf_income_trn-doc
      then do:
        assign
          p-reason        = vss-description + ":" + chr(10)
                          + substitute("Не найден документ прихода &1",buf_parts.in-code) + chr(10)
                          + "Невозможно зарезервировать партию " +  buf_parts.in-code + " " + buf_parts.part-code
          p-process-part  = false
        .
        return .
      end.
      if buf_income_trn-doc.cli-type <> buf_trn-doc.cli-type
      or buf_income_trn-doc.cli-code <> buf_trn-doc.cli-code
      then do:
        assign
          p-reason        = vss-description + ":" + chr(10)
                          + substitute("Документ прихода &1",buf_income_trn-doc.doc-code) + chr(10)
                          + substitute("Фирма на которую производится межфирменное перемещение &1 &2",buf_trn-doc.cli-type,buf_trn-doc.cli-code) + chr(10)
                          + substitute("Фирма с которой было межфирменное перемещение &1 &2",buf_income_trn-doc.cli-type,buf_income_trn-doc.cli-code) + chr(10)
                          + "Фирмы не совпадают" + chr(10)
                          + "Невозможно зарезервировать партию " +  buf_parts.in-code + " " + buf_parts.part-code
          p-process-part  = false
        .
        return .
      end.
      if buf_income_trn-doc.hold-obj-type <> buf_trn-doc.hold-obj-type
      or buf_income_trn-doc.hold-obj-code <> buf_trn-doc.hold-obj-code
      then do:
        assign
          p-reason        = vss-description + ":" + chr(10)
                          + substitute("Документ прихода &1",buf_income_trn-doc.doc-code) + chr(10)
                          + substitute("Объект на который производится межфирменное перемещение &1 &2",buf_trn-doc.hold-obj-type,buf_trn-doc.hold-obj-code) + chr(10)
                          + substitute("Объект с которого было межфирменное перемещение &1 &2",buf_income_trn-doc.hold-obj-type,buf_income_trn-doc.hold-obj-code) + chr(10)
                          + "Объекты не совпадают" + chr(10)
                          + "Невозможно зарезервировать партию " +  buf_parts.in-code + " " + buf_parts.part-code
          p-process-part  = false
        .
        return .
      end.
      if buf_trn-doc.hold-doc-code-parent = ""
      then do:
        assign
          p-reason        = vss-description + ":" + chr(10)
                          + substitute("Документ прихода &1",buf_income_trn-doc.doc-code) + chr(10)
                          + "Документ прихода не является документом межфирменного прихода" + chr(10)
                          + "Невозможно зарезервировать партию " +  buf_parts.in-code + " " + buf_parts.part-code
          p-process-part  = false
        .
        return .
      end.
    end.
    if p-goods-twounit = true
    then do:
      define variable v-parts-qnty like ub.parts.qnty no-undo .
      case buf_parts.out-code :
        when 'free-zone':U
        then do:
          assign
            v-parts-qnty = buf_parts.qnty
          .
        end.
        when 'out-zone':U
        then do:
          assign
            v-parts-qnty = - buf_parts.qnty
          .
        end.
        when buf_trn-doc.doc-code
        then do:
          if lookup(buf_trn-doc.doc-type, 'рас,спи':U) > 0
          then do:
            assign
              v-parts-qnty = - buf_parts.qnty
            .
          end.
          else do:
            assign
              v-parts-qnty = buf_parts.qnty
            .
          end.
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Попытка изменить партию, не принадлежащую документу" skip
            "Партия зарезервирована за документом" buf_parts.out-code skip
            "Текущий документ" buf_trn-doc.doc-code skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end case .
      if buf_parts.out-code <> buf_parts.in-code
      then do:
        if v-parts-qnty <> - p-rsrv-qnty
        then do:
          assign
            p-reason        = vss-description + ":" + chr(10)
                            + "Для товара с двумя ед.изм. партию можно зарезервировать только целиком" + chr(10)
                            + "Количество в партии" + " " + string(v-parts-qnty) + chr(10)
                            + "Было запрошено количество" + " " + string(p-rsrv-qnty) + chr(10)
                            + "Невозможно зарезервировать партию " +  buf_parts.in-code + " " + buf_parts.part-code
            p-process-part  = false
          .
          return .
        end.
      end.
      if buf_parts.cli-qnty <> 1
      then do:
        assign
          p-reason       = vss-description + ":" + chr(10)
                        + "Для товара с двумя ед.изм. количество по клиенту должно быть 1" + chr(10)
                        + "Невозможно зарезервировать партию " +  buf_parts.in-code + " " + buf_parts.part-code
          p-process-part = false
        .
        return .
      end.
    end.
    if  p-purch-code-list <> ?
    and p-purch-code-list <> '':u
    then do:
      if lookup(string(buf_parts.purch-code), p-purch-code-list) = 0
      then do:
        define variable v-ind              as integer   no-undo .
        define variable v-purch-code-list  as character no-undo .
        define variable v-parts-purch-code as character no-undo .
        assign
          v-purch-code-list = ""
        .
        do v-ind = 1 to num-entries(p-purch-code-list)
        :
                    assign
            v-purch-code-list = v-purch-code-list
                              + (if v-purch-code-list <> '':u then ',':u else '':u )
                              + entry (lookup (entry(v-ind,p-purch-code-list), '1,2,3,4':U), 'выкуп,консигнация,ответственное хранение,старая консигнация':U)
          .
        end.
                assign
          v-parts-purch-code = entry (lookup (string(buf_parts.purch-code), '1,2,3,4':U), 'выкуп,консигнация,ответственное хранение,старая консигнация':U)
        .
        assign
          p-reason        = vss-description + ":" + chr(10)
                          + substitute("Задано резервирование по типам приобретения &1", v-purch-code-list) + chr(10)
                          + substitute("Невозможно зарезервировать партию &1 &2", buf_parts.in-code, buf_parts.part-code) + chr(10)
                          + substitute("с типом приобретения &1", v-parts-purch-code)
          p-process-part  = false
        .
        return .
      end.
    end.
    if p-reserv-single-part
    then do:
    define buffer buf_goods for ub.goods  .
    define buffer buf_parts-attr for ub.parts-attr  .
    define variable v-is-ok as logical   no-undo .
    define buffer buf_trn-doc-parts for ub.trn-doc  .
    find first buf_trn-doc-parts no-lock where
               buf_trn-doc-parts.doc-code = p-single-part-in-code no-error .
     v-is-ok =  false .
      if not available buf_trn-doc-parts then do:
          v-is-ok = true .
      end.
      else do:
        if buf_trn-doc-parts.ext-doc-type <> 'ev':U then v-is-ok = true .
      end.
      if v-is-ok = true then do:
        find first buf_goods no-lock where
                   buf_goods.artic     = buf_parts.artic and
                   buf_goods.prod-type = buf_parts.prod-type and
                   buf_goods.prod-code = buf_parts.prod-code no-error .
        find first buf_parts-attr no-lock where
                   buf_parts-attr.gds-code  = buf_goods.gds-code  and
                   buf_parts-attr.part-code = buf_parts.part-code  and
                   buf_parts-attr.in-code =   buf_parts.in-code no-error .
                    if error-status :error then DO:
                        message
                          vss-workfile vss-revision vss-description skip
                          error-status :get-message(1) skip
                          return-value skip
                          "Нет атрибута партиии "
                          view-as alert-box error
                        .
                        return error return-value .
                    end.
          if buf_parts-attr.orig-in-code   <> p-single-part-in-code
          or buf_parts-attr.orig-part-code <> p-single-part-part-code
          then do:
            assign
              p-reason       = vss-description + ":" + chr(10)
                            + "Происходит резервирование конкретной партии"
                            + p-single-part-in-code + " " + p-single-part-part-code + chr(10)
                            + "Невозможно зарезервировать партию " +  buf_parts.in-code + " " + buf_parts.part-code
              p-process-part = false
            .
            return .
          end.
      end.
    end.
    if  p-pl-code <> ?
    and p-pl-code <> 0
    then do:
      if buf_parts.pl-code <> p-pl-code
      then do:
        assign
          p-reason        = vss-description + ":" + chr(10)
                          + substitute("Происходит резервирование партий на складском месте &1", p-pl-code) + chr(10)
                          + substitute("Невозможно зарезервировать партию &1 &2", buf_parts.in-code, buf_parts.part-code) + chr(10)
                          + substitute("со складского места &1", buf_parts.pl-code)
          p-process-part  = false
        .
        return .
      end.
    end.
    if buf_trn-doc.ext-doc-type = 'ep':U
    then do:
      if ( buf_parts.is-supp   = true
          and buf_parts.supp-type = buf_trn-doc.cli-type
          and buf_parts.supp-code = buf_trn-doc.cli-code
        )
      or ( buf_parts.is-supp   = false
        )
      then do:
      end.
      else do:
        assign
          p-reason       = vss-description + ":" + chr(10)
                        + "Для документа расход возврат поставщику" + chr(10)
                        + "Можно резервировать только партии, созданные документом внешнего прихода от поставщика "
                        + string (buf_trn-doc.cli-type) + " " + string(buf_trn-doc.cli-code)
                        + chr(10)
                        + "или созданные другими типами документов"
          p-process-part = false
        .
        return .
      end.
    end.
    if p-check-negmanuf = true
    then do:
      if buf_trn-doc.ext-doc-type = 'wm':U
      or buf_trn-doc.ext-doc-type = 'em':U
      then do:
        if buf_parts.in-code = buf_parts.out-code
        then do:
          define variable conf-par as character no-undo .
define variable vss-include-info66 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input buf_trn-doc.obj-type
  ,input buf_trn-doc.obj-code
  ,input 'rezerv-obj':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
          for each thbjattr_thbj-attr :
              if thbjattr_thbj-attr.prop-code = 'negmanuf'  then conf-par  = thbjattr_thbj-attr.property-value-character.
          end.
          empty temp-table thbjattr_thbj-attr.
          if conf-par = "disable"
          then do:
            assign
              p-reason       = vss-description + ":" + chr(10)
                              + "Для документа списание по производству запрещено порождение партий" + chr(10)
                              + "Параметр системы negmanuf" + chr(10)
              p-process-part = false
            .
            return .
          end.
        end.
      end.
    end.
    if  buf_parts.supp-type = buf_trn-doc.obj-type
    and buf_parts.supp-code = buf_trn-doc.obj-code
    then do:
      define variable v-is-hold as logical   no-undo .
define variable vss-include-info67 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  buf_trn-doc.doc-code
  ,output v-is-hold
  )  .
      if buf_trn-doc.ext-doc-type = 'ev':U
      or buf_trn-doc.ext-doc-type = 'eo':U
      or v-is-hold                = true
      then do:
        define buffer negative_parts for ub.parts .
        if buf_trn-doc.ext-doc-type = 'ev':U
        or buf_trn-doc.ext-doc-type = 'eo':U
        then do:
          find first negative_parts no-lock
            where negative_parts.obj-type  = buf_parts.obj-type
              and negative_parts.obj-code  = buf_parts.obj-code
              and negative_parts.artic     = buf_parts.artic
              and negative_parts.prod-type = buf_parts.prod-type
              and negative_parts.prod-code = buf_parts.prod-code
              and negative_parts.in-code   = buf_parts.in-code
              and negative_parts.out-code  = 'out-zone':U
              and negative_parts.part-code = buf_parts.part-code
            no-error .
          if available negative_parts
          and negative_parts.fact-qnty < 0
          then do:
            assign
              p-reason       = vss-description + ":" + chr(10)
                             + "Это порожденная партия. Ее нельзя зарезервировать за документом внутреннего перемещения." + chr(10)
                             + "В расходной зоне существует партия с отрицательным количеством"
              p-process-part = false
            .
            return .
          end.
        end.
        else do:
        end.
      end.
    end.
    return .
  end.
end procedure.
procedure gds-code :
  define input  parameter p-artic     like ub.goods.artic     no-undo .
  define input  parameter p-prod-type like ub.goods.prod-type no-undo .
  define input  parameter p-prod-code like ub.goods.prod-code no-undo .
  define output parameter p-gds-code  like ub.goods.gds-code  no-undo .
  define variable vss-description as character no-undo initial "gds-code-01: Поиск кода товара по артикулу и коду производителя".
  define buffer buf_goods    for ub.goods .
  do
  on error undo, return error return-value
  :
    find first buf_goods no-lock
      where buf_goods.artic     = p-artic
        and buf_goods.prod-type = p-prod-type
        and buf_goods.prod-code = p-prod-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error return-value  .
    end.
    if buf_goods.gds-code = 0
    or buf_goods.gds-code = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "У товара не задан первичный код" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "gds-code" buf_goods.gds-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      p-gds-code = buf_goods.gds-code
    .
  end.
end procedure.
procedure arptpc :
  define input  parameter p-gds-code  like ub.goods.gds-code  no-undo .
  define output parameter p-artic     like ub.goods.artic     no-undo .
  define output parameter p-prod-type like ub.goods.prod-type no-undo .
  define output parameter p-prod-code like ub.goods.prod-code no-undo .
  define variable vss-description as character no-undo initial "arptpc-01: Поиск артикула и кода производителя".
  define buffer buf_goods    for ub.goods .
  do
  on error undo, return error return-value
  :
    if p-gds-code = 0
    or p-gds-code = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не задан код товара" skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    find first buf_goods no-lock
      where buf_goods.gds-code = p-gds-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      p-artic     = buf_goods.artic
      p-prod-type = buf_goods.prod-type
      p-prod-code = buf_goods.prod-code
    .
  end.
end procedure.
procedure gds-arnm :
  define input  parameter p-artic     like ub.goods.artic     no-undo .
  define input  parameter p-prod-type like ub.goods.prod-type no-undo .
  define input  parameter p-prod-code like ub.goods.prod-code no-undo .
  define output parameter p-gds-name  like ub.goods.gds-name  no-undo .
  define variable vss-description as character no-undo initial "gds-arnm: Возвращает имя товара по артикулу".
  define buffer buf_goods for ub.goods .
  do
  on error undo, return error return-value
  :
    find first buf_goods no-lock
      where buf_goods.artic     = p-artic
        and buf_goods.prod-type = p-prod-type
        and buf_goods.prod-code = p-prod-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      p-gds-name = buf_goods.gds-name
    .
  end.
end procedure.
procedure gds-cdnm :
  define input  parameter p-gds-code  like ub.goods.gds-code  no-undo .
  define output parameter p-gds-name  like ub.goods.gds-name  no-undo .
  define variable vss-description as character no-undo initial "gds-cdnm: Возвращает имя товара по коду".
  define buffer buf_goods for ub.goods .
  do
  on error undo, return error return-value
  :
    find first buf_goods no-lock
      where buf_goods.gds-code  = p-gds-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Код" p-gds-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      p-gds-name = buf_goods.gds-name
    .
  end.
end procedure.
procedure basecode :
  define input parameter  p-host-code  like ub.sysconf.host-code     no-undo .
  define output parameter p-base-code  like ub.sysconf.base-code     no-undo .
  define variable vss-description as character no-undo initial "basecode-01: определение кода базовой валюты".
  do
  on error undo, return error return-value
  :
    define buffer buf_sysconf for ub.sysconf .
    find first buf_sysconf no-lock
      where buf_sysconf.host-code = p-host-code
      no-error .
    if not available buf_sysconf
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена фирма" skip
        "host-code" p-host-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      p-base-code = buf_sysconf.base-code
    .
  end.
end procedure.
procedure consvtpc :
  define input parameter  p-host-code   like ub.sysconf.host-code   no-undo .
  define output parameter p-cons-vat-pc like ub.sysconf.cons-vat-pc no-undo .
  define variable vss-description as character no-undo initial "consvtpc-01: определение налога по консигнации".
  do
  on error undo, return error return-value
  :
    define buffer buf_sysconf for ub.sysconf .
    find first buf_sysconf no-lock
      where buf_sysconf.host-code = p-host-code
      no-error .
    if not available buf_sysconf
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена фирма" skip
        "host-code" p-host-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      p-cons-vat-pc = buf_sysconf.cons-vat-pc
    .
  end.
end procedure.
procedure baserate :
  define input  parameter p-host-code  like ub.sysconf.host-code     no-undo .
  define input  parameter p-curr-date  as date no-undo .
  define output parameter p-base-rate  like ub.curr-accnt.exch-rate  no-undo .
  define output parameter p-base-scale like ub.curr-accnt.exch-scale no-undo .
  define variable vss-description as character no-undo initial "baserate-01: определение курса базовой валюты".
  define buffer buf_curr-accnt for ub.curr-accnt .
  define buffer buf_currency   for ub.currency .
  define variable v-base-code like ub.sysconf.base-code no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info68 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  p-host-code
  ,output v-base-code
  ) no-error .
    if error-status :error
    then do:
      undo, return error substitute("Ошибка при определении кода базовой валюты для фирмы &1", p-host-code) .
    end.
    if p-curr-date = ?
    then do:
      find last buf_curr-accnt no-lock
        where buf_curr-accnt.curr-code = v-base-code
        use-index pi
        no-error .
    end.
    else do:
      find last buf_curr-accnt no-lock
        where buf_curr-accnt.curr-code =  v-base-code
          and buf_curr-accnt.exch-date <= p-curr-date
        use-index pi
        no-error .
    end.
    if not available buf_curr-accnt
    then do:
      find first buf_currency no-lock
        where buf_currency.curr-code = v-base-code
        no-error .
      if not available buf_currency
      then do:
        undo, return error substitute("Не найдена базовая валюта &1", v-base-code) .
      end.
      undo, return error substitute("Базовая валюта") + chr(10)
        + substitute("Код &1", buf_currency.curr-code) + chr(10)
        + substitute("Краткое название &1", buf_currency.curr-abbr ) + chr(10)
        + substitute("Название &1", buf_currency.curr-name) + chr(10)
        + substitute("На дату &1 неизвестен курс базовой валюты", string(p-curr-date, "99/99/9999"))
        .
    end.
    assign
      p-base-rate  = buf_curr-accnt.exch-rate
      p-base-scale = buf_curr-accnt.exch-scale
    .
  end.
end procedure.
procedure exchrate :
  define input  parameter p-curr-code  like ub.currency.curr-code    no-undo .
  define input  parameter p-curr-date  as date no-undo .
  define output parameter p-exch-rate  like ub.curr-accnt.exch-rate  no-undo .
  define output parameter p-exch-scale like ub.curr-accnt.exch-scale no-undo .
  define output parameter p-curr-abbr  like ub.currency.curr-abbr    no-undo .
  define variable vss-description as character no-undo initial "exchrate-01: определение курса валюты по отношению к национальной".
  define buffer buf_curr-accnt for ub.curr-accnt .
  define buffer buf_currency   for ub.currency .
  do
  on error undo, return error return-value
  :
    find first buf_currency no-lock
      where buf_currency.curr-code = p-curr-code
      no-error .
    if not available buf_currency
    then do:
      undo, return error substitute("Не найдена валюта &1", p-curr-code) .
    end.
    find last buf_curr-accnt no-lock
      where buf_curr-accnt.curr-code =  p-curr-code
        and buf_curr-accnt.exch-date <= p-curr-date
      use-index pi
      no-error .
    if not available buf_curr-accnt
    then do:
      undo, return error substitute("Валюта") + chr(10)
        + substitute("Код &1", buf_currency.curr-code) + chr(10)
        + substitute("Краткое название &1", buf_currency.curr-abbr ) + chr(10)
        + substitute("Название &1", buf_currency.curr-name) + chr(10)
        + substitute("На дату &1 неизвестен курс валюты", string(p-curr-date, "99/99/9999"))
        .
    end.
    assign
      p-exch-rate  = buf_curr-accnt.exch-rate
      p-exch-scale = buf_curr-accnt.exch-scale
      p-curr-abbr  = buf_currency.curr-abbr
    .
  end.
end procedure.
procedure curshift :
  define input  parameter p-obj-type   like ub.shift-obj.obj-type   no-undo .
  define input  parameter p-obj-code   like ub.shift-obj.obj-code   no-undo .
  define output parameter p-shift-date like ub.shift-obj.shift-date no-undo .
  define output parameter p-shift-num  like ub.shift-obj.shift-num  no-undo .
  define output parameter p-shift-name like ub.shift-obj.shift-name no-undo.
  define variable vss-description as character no-undo initial "curshift-01: определение текущей смены".
  define buffer buf_shift-obj for ub.shift-obj .
  do
  on error undo, return error return-value
  :
    find first buf_shift-obj
      where buf_shift-obj.obj-type = p-obj-type
        and buf_shift-obj.obj-code = p-obj-code
        and buf_shift-obj.status_ = 'тек':U
      use-index stts
      no-error .
    if not available buf_shift-obj
    then do:
      undo, return error
        "Нет открытой смены на объекте: "
        + string(p-obj-type) + " " + string(p-obj-code) .
    end.
    assign
      p-shift-date = buf_shift-obj.shift-date
      p-shift-num  = buf_shift-obj.shift-num
      p-shift-name = buf_shift-obj.shift-name
    .
  end.
end procedure.
procedure lastindc :
  define input  parameter p-host-code  like ub.gds-obj.host-code no-undo .
  define input  parameter p-artic      like ub.gds-obj.artic     no-undo .
  define input  parameter p-prod-type  like ub.gds-obj.prod-type no-undo .
  define input  parameter p-prod-code  like ub.gds-obj.prod-code no-undo .
  define output parameter p-in-code    like ub.gds-obj.in-code   no-undo .
  define output parameter p-obj-type   like ub.gds-obj.obj-type  no-undo .
  define output parameter p-obj-code   like ub.gds-obj.obj-code  no-undo .
  define variable vss-description as character no-undo initial "lastincd-01: определение объекта на котором был последний приход" .
  define buffer buf_gds-obj for ub.gds-obj .
  define buffer buf_trn-doc for ub.trn-doc .
  do
  on error undo, return error return-value
  :
    assign
      p-in-code  = ""
      p-obj-type = ""
      p-obj-code = 0
    .
    for each buf_gds-obj no-lock
      where buf_gds-obj.host-code = p-host-code
        and buf_gds-obj.artic     = p-artic
        and buf_gds-obj.prod-type = p-prod-type
        and buf_gds-obj.prod-code = p-prod-code
    , first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = buf_gds-obj.in-code
        and buf_trn-doc.status_  = 'факт':U
    by buf_trn-doc.fact-order descending
    on error undo, return error return-value
    :
      assign
        p-in-code  = buf_gds-obj.in-code
        p-obj-type = buf_gds-obj.obj-type
        p-obj-code = buf_gds-obj.obj-code
      .
      leave .
    end.
  end.
end procedure.
procedure sclcdattr :
  define input  parameter p-gds-code  like ub.bar-code.gds-code  no-undo .
  define input  parameter p-obj-type  like ub.gds-obj.obj-type   no-undo .
  define input  parameter p-obj-code  like ub.gds-obj.obj-code   no-undo .
  define input  parameter p-b-str     like ub.prod-bc.b-str      no-undo.
  define input  parameter p-overwrite as logical no-undo .
  define variable vss-description as character no-undo initial "sclcdattr-01: создание атрибута ВЕСОВОЙ КОД ТОВАРА НА ОБЪЕКТЕ".
  define variable vss-proc-revision as character no-undo initial "library.p sclcdattr" .
  define buffer buf_bar-code for ub.bar-code .
  define buffer buf_prod-bc for ub.prod-bc .
  define buffer buf_gds-obj for ub.gds-obj .
  define buffer buf_clients for ub.clients .
  define buffer buf_units   for ub.units .
  define buffer buf_db       for ub.db .
  define variable v-db-num    as integer   no-undo .
  define variable v-node-code like ub.bar-code.node-code no-undo .
  define variable v-unit-base like ub.goods.unit-base no-undo .
  define variable p-b-code like ub.bar-code.b-code no-undo .
  define variable v-exist as logical no-undo .
  define variable v-b-str as integer no-undo .
  define variable l-prod-bc-weight as logical no-undo .
  define variable v-nw as logical no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info69 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении текущей БД" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    find first buf_db no-lock
      where buf_db.db-num = v-db-num
      no-error .
    if not available buf_db
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена запись таблицы базы данных" skip
        "База данных" v-db-num skip
        view-as alert-box error .
      undo, return error return-value .
    end.
define variable vss-include-info70 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsrtnod in g#library
  (input  p-gds-code
  ,output v-node-code
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении корневого признака товара" skip
        "Код товара" p-gds-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
define variable vss-include-info71 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run unitbase in g#library
  (input  p-gds-code
  ,output v-unit-base
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка определения базовой единицы измерения товара" skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    find first buf_units No-LOCK
      where buf_units.unit-name = v-unit-base No-ERROR.
    if not avail buf_units
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена базовая единица измерения товара" skip
        "Единица измерения" v-unit-base
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if lookup('вес':U, buf_units.type) = 0
    then do:
      if lookup('шту':U, buf_units.type) > 0 then do:
        v-nw = yes.
      end.
      else do:
      message
        vss-workfile vss-revision vss-description skip
        "Попытка присвоить атрибут товара на  объекте" skip
          "ВЕСОВОЙ КОД невесовому и не штучному товару" skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    end.
    find first buf_bar-code no-lock
      where buf_bar-code.gds-code  = p-gds-code
        and buf_bar-code.node-code = v-node-code
        and buf_bar-code.part-code = ""
        and buf_bar-code.in-code   = ""
        and buf_bar-code.unit-cli  = v-unit-base
      no-error .
    if not available buf_bar-code
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден первичный бар-кода признака " skip
        "Код товара" p-gds-code skip
        "Код признака" v-node-code skip
        "Базовая единица измерения" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      p-b-code = buf_bar-code.b-code
    .
    _prod-bc:
    for each  buf_prod-bc no-lock
      where buf_prod-bc.b-code = p-b-code
        and buf_prod-bc.bc-on = true
        and (p-b-str = ? or buf_prod-bc.b-str = p-b-str)
     on error undo, return error return-value
     :
      if v-nw then do:
        if (buf_prod-bc.bc-on-type = 'pglc':U) then do:
          leave _prod-bc.
        end.
        else do:
          next _prod-bc.
        end.
      end.
      else do:
define variable vss-include-info72 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer buf_prod-bc
  ,input  'weight=request':u
  ,output l-prod-bc-weight
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении типа дополнительного бар-кода prodbcat" skip
          "Основной бар-код" buf_prod-bc.b-code skip
          "Дополнительный бар-код" buf_prod-bc.b-str skip
          "Действие weight=request" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      if not l-prod-bc-weight
      then do:
        NEXT _prod-bc.
      end.
      ELSE do:
        LEAVE _prod-bc.
      end.
      end.
    END.
    if not avail buf_prod-bc
    then do:
      if p-b-str = ?
      then do:
        error-status:error = false.
        return.
      end.
      else do:
        if v-nw then do:
          message
            vss-workfile vss-revision vss-description skip
            "Не найден штучный код товара для весов" skip
            "Код товара" p-gds-code skip
            "Весовой код" p-b-str skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        else do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найден весовой код товара " skip
          "Код товара" p-gds-code skip
          "Весовой код" p-b-str skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      end.
    END.
    assign
    v-b-str = integer(buf_prod-bc.b-str) no-error.
    if error-status :error or v-b-str = ? or length(buf_prod-bc.b-str) > 6
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неверный весовой код " skip
        "Код товара" p-gds-code skip
        "Весовой код" buf_prod-bc.b-str skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    do
    on error undo, return error return-value
    :
      _clients:
      FOR EACH buf_clients No-LOCK WHERE
              buf_clients.db-num = buf_db.db-num
              on error undo, return error return-value
              :
        if p-obj-type <> "" and
          p-obj-code <> 0 and
          (buf_clients.obj-type <> p-obj-type OR
            buf_clients.obj-code <> p-obj-code) then NEXT _Clients.
        FIND FIRST buf_gds-obj no-LOCK WHERE
                  buf_gds-obj.gds-code = p-gds-code AND
                  buf_gds-obj.obj-type = buf_clients.obj-type AND
                  buf_gds-obj.obj-code = buf_clients.obj-code No-ERROR.
        if NOT avail buf_gds-obj then NEXT _clients.
        run gdsoattr-exist in this-procedure (
                                              input p-gds-code,
                                              input buf_clients.obj-type,
                                              input buf_clients.obj-code,
                                              input 'scales-code':U,
                                              output v-exist
                                            ) .
        if  v-exist
        and p-overwrite = false
        and (p-obj-type <> "" OR p-obj-code <> 0)
        then do:
          undo, return error vss-proc-revision + ":" + chr(10)
            + "Уже имеется  атрибут  товара  на  объекте  ВЕСОВОЙ  КОД " + chr(10)
            + "Код товара " + string(p-gds-code) + chr(10)
            + "Тип объекта " + string(buf_clients.obj-type) + chr(10)
            + "Код объекта " + string(buf_clients.obj-code) + chr(10)
            .
        end.
        run gdsoattr-write in this-procedure (
                                              input p-gds-code,
                                              input buf_clients.obj-type,
                                              input buf_clients.obj-code,
                                              input 'scales-code':U,
                                              input string(v-b-str, "99999")
                                            ) no-error.
        if error-status :error
        then do:
          undo, return error vss-proc-revision + ":" + chr(10)
            + "Ошибка при создания атрибута товара на объекте ВЕСОВОЙ КОД" + chr(10)
            + "Код товара " + string(p-gds-code) + chr(10)
            + "Тип объекта " + string(buf_clients.obj-type) + chr(10)
            + "Код объекта " + string(buf_clients.obj-code) + chr(10)
            + "Значение атрибута " + string(v-b-str, "99999") + chr(10)
            .
        end.
      END.
    END.
  end.
end procedure.
procedure pftaxval :
  define input  parameter par-rc       as recid     no-undo .
  define input  parameter partax-code  like ub.tax.tax-code no-undo .
  define input  parameter parrate-code like ub.tax-rate.rate-code no-undo .
  define input  parameter par-date     as date      no-undo .
  define input  parameter parhost-code like ub.sysconf.host-code no-undo .
  define input  parameter parobj-type  like ub.clients.obj-type no-undo .
  define input  parameter parobj-code  like ub.clients.obj-code no-undo .
  define output parameter partax-value as decimal no-undo initial ?.
  define variable vss-description as character no-undo initial "pftaxval: Значение по ставке налога в заданный момент  времени для заданного объекта и фирмы".
  define variable v-fact-order as decimal no-undo .
  define buffer buf_tax-rate for ub.tax-rate.
  define buffer buf_tax-rate-value for ub.tax-rate-value.
  define buffer buf_tax-rate-attr for ub.tax-rate-attr .
  do
  on error undo, return error return-value
  :
    if par-date = ?
    then do:
      assign
        par-date = today
      .
    end.
    run factord-end-day in this-procedure
      (input  par-date
      ,output v-fact-order
      ).
    if partax-code  = 0
    or parrate-code = 0
    then do:
      find first buf_tax-rate no-lock
        where recid(buf_tax-rate) = par-rc
        no-error .
      if not available buf_tax-rate
      then do:
        assign
          partax-value = ?
        .
        undo, return error
        "Не найдена ставка налога "
        + "recid " + string(par-rc)
        .
      end.
      assign
      partax-code = buf_tax-rate.tax-code
      parrate-code = buf_tax-rate.rate-code
      .
      if buf_tax-rate.status_ = 'удал':U
      then do:
        partax-value = ?.
        undo, return error
        "Ставка налога недействительна "
        + "налог: " + string(buf_tax-rate.tax-code) + " ставка: " + string(buf_tax-rate.rate-code) .
      end.
    END.
    FIND LAST buf_tax-rate-value NO-LOCK WHERE
                buf_tax-rate-value.tax-code  = partax-code  AND
                buf_tax-rate-value.rate-code = parrate-code AND
                buf_tax-rate-value.host-code = parhost-code AND
                buf_tax-rate-value.obj-type = parobj-type AND
                buf_tax-rate-value.obj-code = parobj-code AND
                buf_tax-rate-value.fact-order <= v-fact-order AND
                buf_tax-rate-value.status_ <> 'удал':U
                NO-ERROR.
    if avail buf_tax-rate-value
    then do:
      find first buf_tax-rate-attr no-lock where buf_tax-rate-attr.tax-code = integer('1':U)
      and buf_tax-rate-attr.attr-code = "envd" and buf_tax-rate-attr.rate-code = buf_tax-rate-value.rate-code no-error .
      if available (buf_tax-rate-attr) then partax-value = -1 .
      else partax-value = buf_tax-rate-value.rate-value.
      return.
    end.
    FIND LAST buf_tax-rate-value NO-LOCK WHERE
                buf_tax-rate-value.tax-code  = partax-code  AND
                buf_tax-rate-value.rate-code = parrate-code AND
                buf_tax-rate-value.host-code = parhost-code AND
                buf_tax-rate-value.obj-type = "" AND
                buf_tax-rate-value.obj-code = 0 AND
                buf_tax-rate-value.fact-order <= v-fact-order AND
                buf_tax-rate-value.status_ <> 'удал':U
                NO-ERROR.
    if avail buf_tax-rate-value
    then do:
      find first buf_tax-rate-attr no-lock where buf_tax-rate-attr.tax-code = integer('1':U)
      and buf_tax-rate-attr.attr-code = "envd" and buf_tax-rate-attr.rate-code = buf_tax-rate-value.rate-code no-error .
      if available (buf_tax-rate-attr) then partax-value = -1 .
      else partax-value = buf_tax-rate-value.rate-value.
      return.
    end.
    FIND LAST buf_tax-rate-value NO-LOCK WHERE
                buf_tax-rate-value.tax-code  = partax-code  AND
                buf_tax-rate-value.rate-code = parrate-code AND
                buf_tax-rate-value.host-code = 0 AND
                buf_tax-rate-value.obj-type = "" AND
                buf_tax-rate-value.obj-code = 0 AND
                buf_tax-rate-value.fact-order <= v-fact-order AND
                buf_tax-rate-value.status_ <> 'удал':U
                NO-ERROR.
    if avail buf_tax-rate-value
    then do:
      find first buf_tax-rate-attr no-lock where buf_tax-rate-attr.tax-code = integer('1':U)
      and buf_tax-rate-attr.attr-code = "envd" and buf_tax-rate-attr.rate-code = buf_tax-rate-value.rate-code no-error .
      if available (buf_tax-rate-attr) then partax-value = -1 .
      else partax-value = buf_tax-rate-value.rate-value.
      return.
    end.
  end.
end procedure.
procedure pftaxvlx :
  define input  parameter par-rc       as recid     no-undo .
  define input  parameter partax-code  like ub.tax.tax-code no-undo .
  define input  parameter parrate-code like ub.tax-rate.rate-code no-undo .
  define input  parameter par-date     as date      no-undo .
  define input  parameter parhost-code like ub.sysconf.host-code no-undo .
  define input  parameter parobj-type  like ub.clients.obj-type no-undo .
  define input  parameter parobj-code  like ub.clients.obj-code no-undo .
  define output parameter par-x-host-code like ub.sysconf.host-code no-undo .
  define output parameter par-x-obj-type  like ub.clients.obj-type no-undo .
  define output parameter par-x-obj-code  like ub.clients.obj-code no-undo .
  define variable vss-description as character no-undo initial "pftaxvlx: Область действия ставки налога в заданный момент  времени для заданного объекта и фирмы".
  define variable v-fact-order as decimal no-undo .
  define buffer buf_tax-rate for ub.tax-rate.
  define buffer buf_tax-rate-value for ub.tax-rate-value.
  do
  on error undo, return error return-value
  :
    if par-date = ?
    then do:
      assign
        par-date = today
      .
    end.
    run factord-end-day in this-procedure
      (input  par-date
      ,output v-fact-order
      ).
    if partax-code  = 0
    or parrate-code = 0
    then do:
      find first buf_tax-rate no-lock
        where recid(buf_tax-rate) = par-rc
        no-error .
      if not available buf_tax-rate
      then do:
        undo, return error
        "Не найдена ставка налога "
        + "recid " + string(par-rc)
        .
      end.
      assign
      partax-code = buf_tax-rate.tax-code
      parrate-code = buf_tax-rate.rate-code
      .
      if buf_tax-rate.status_ = 'удал':U
      then do:
        undo, return error
        "Ставка налога недействительна "
        + "налог: " + string(buf_tax-rate.tax-code) + " ставка: " + string(buf_tax-rate.rate-code) .
      end.
    END.
    FIND LAST buf_tax-rate-value NO-LOCK WHERE
                buf_tax-rate-value.tax-code  = partax-code  AND
                buf_tax-rate-value.rate-code = parrate-code AND
                buf_tax-rate-value.host-code = parhost-code AND
                buf_tax-rate-value.obj-type = parobj-type AND
                buf_tax-rate-value.obj-code = parobj-code AND
                buf_tax-rate-value.fact-order <= v-fact-order AND
                buf_tax-rate-value.status_ = 'тек':U
                NO-ERROR.
    if avail buf_tax-rate-value
    then do:
      assign
      par-x-host-code = buf_tax-rate-value.host-code
      par-x-obj-type = buf_tax-rate-value.obj-type
      par-x-obj-code = buf_tax-rate-value.obj-code
      .
      return.
    end.
    FIND LAST buf_tax-rate-value NO-LOCK WHERE
                buf_tax-rate-value.tax-code  = partax-code  AND
                buf_tax-rate-value.rate-code = parrate-code AND
                buf_tax-rate-value.host-code = parhost-code AND
                buf_tax-rate-value.obj-type = "" AND
                buf_tax-rate-value.obj-code = 0 AND
                buf_tax-rate-value.fact-order <= v-fact-order AND
                buf_tax-rate-value.status_ = 'тек':U
                NO-ERROR.
    if avail buf_tax-rate-value
    then do:
      assign
      par-x-host-code = buf_tax-rate-value.host-code
      par-x-obj-type = buf_tax-rate-value.obj-type
      par-x-obj-code = buf_tax-rate-value.obj-code
      .
      return.
    end.
    FIND LAST buf_tax-rate-value NO-LOCK WHERE
                buf_tax-rate-value.tax-code  = partax-code  AND
                buf_tax-rate-value.rate-code = parrate-code AND
                buf_tax-rate-value.host-code = 0 AND
                buf_tax-rate-value.obj-type = "" AND
                buf_tax-rate-value.obj-code = 0 AND
                buf_tax-rate-value.fact-order <= v-fact-order AND
                buf_tax-rate-value.status_ = 'тек':U
                NO-ERROR.
    if avail buf_tax-rate-value
    then do:
      assign
      par-x-host-code = buf_tax-rate-value.host-code
      par-x-obj-type = buf_tax-rate-value.obj-type
      par-x-obj-code = buf_tax-rate-value.obj-code
      .
      return.
    end.
  end.
end procedure.
procedure pftxvalg :
  define input parameter pargds-code like ub.goods.gds-code no-undo.
  define input parameter partax-code like ub.tax.tax-code no-undo.
  define input parameter par-date as date no-undo.
  define input parameter parhost-code like ub.sysconf.host-code no-undo .
  define input parameter parobj-type  like ub.clients.obj-type no-undo .
  define input parameter parobj-code  like ub.clients.obj-code no-undo .
  define output parameter partax-value as decimal no-undo .
  define variable vss-description as character no-undo initial "pftxvalg: значение по ставке налога на товар в выбранный момент времени".
  DEFINE VARIABLE v-fact-order as decimal no-undo .
  define buffer buf_tax-rate-gds for ub.tax-rate-gds.
  define buffer buf_goods for ub.goods.
  do
  on error undo, return error return-value
  :
    assign
      partax-value = ?
    .
    find first buf_goods no-lock
      where buf_goods.gds-code = pargds-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найден товар" skip
        "Код товара" pargds-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if par-date = ?
    then do:
      assign
        par-date = today
      .
    end.
    run factord-end-day in this-procedure
      (input  par-date
      ,output v-fact-order
      ).
    find last buf_tax-rate-gds no-lock
      where buf_tax-rate-gds.gds-code   = pargds-code
        and buf_tax-rate-gds.tax-code   = partax-code
        and buf_tax-rate-gds.host-code  = 0
        and buf_tax-rate-gds.obj-type   = ""
        and buf_tax-rate-gds.obj-code   = 0
        and buf_tax-rate-gds.fact-order <= v-fact-order
      no-error .
    IF AVAIL buf_tax-rate-gds
    then do:
define variable vss-include-info73 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalo in g#library
  (input  ?
  ,input  buf_tax-rate-gds.tax-code
  ,input  buf_tax-rate-gds.rate-code
  ,input  v-fact-order
  ,input  parhost-code
  ,input  parobj-type
  ,input  parobj-code
  ,output partax-value
  ) no-error .
      if error-status :error
      then do:
        undo, return error return-value .
      end.
      return.
    end.
  end.
end procedure.
procedure pgtxvalg :
  define input  parameter pargds-code  like ub.goods.gds-code no-undo .
  define input  parameter partax-code  like ub.tax.tax-code   no-undo .
  define input  parameter par-date     as date no-undo .
  define output parameter partax-value as decimal no-undo initial ? .
  define variable vss-description as character no-undo initial "pgtxvalg: корневое значение ставки налога на товар в выбранный момент времени".
  define variable v-fact-order as decimal no-undo .
  define buffer buf_tax-rate-gds for ub.tax-rate-gds.
  define buffer buf_goods for ub.goods.
  define buffer buf_tax-rate for ub.tax-rate .
  do
  on error undo, return error return-value
  :
    find first buf_goods no-lock
      where buf_goods.gds-code = pargds-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найден товар" skip
        "Код товара" pargds-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if par-date = ?
    then do:
      assign
        par-date = today
      .
    end.
    run factord-end-day in this-procedure
      (input  par-date
      ,output v-fact-order
      ).
    find last buf_tax-rate-gds no-lock
      where buf_tax-rate-gds.gds-code   = pargds-code
        and buf_tax-rate-gds.tax-code   = partax-code
        and buf_tax-rate-gds.host-code  = 0
        and buf_tax-rate-gds.obj-type   = ""
        and buf_tax-rate-gds.obj-code   = 0
        and buf_tax-rate-gds.fact-order <= v-fact-order
      no-error .
    if available buf_tax-rate-gds
    then do:
      FIND FIRST buf_tax-rate NO-LOCK
        WHERE buf_tax-rate.tax-code = buf_tax-rate-gds.tax-code
          AND buf_tax-rate.rate-code = buf_tax-rate-gds.rate-code
        NO-ERROR .
      if not avail buf_tax-rate
      then do:
        assign
          partax-value = ?
        .
        undo, return error
          "Не найдена ставка налога "
          + "налог: " + string(buf_tax-rate-gds.tax-code) + " ставка: " + string(buf_tax-rate-gds.rate-code)
          .
      end.
      if buf_tax-rate.status_ = 'удал':U
      then do:
        assign
          partax-value = ?
        .
        undo, return error
          "Ставка налога недействительна "
          + "налог: " + string(buf_tax-rate.tax-code) + " ставка: " + string(buf_tax-rate.rate-code)
          .
      end.
define variable vss-include-info74 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalo in g#library
  (input  ?
  ,input  buf_tax-rate-gds.tax-code
  ,input  buf_tax-rate-gds.rate-code
  ,input  v-fact-order
  ,input  0
  ,input  '':U
  ,input  0
  ,output partax-value
  ) no-error .
      if error-status :error
      then do:
        undo, return error return-value .
      end.
      return.
    end.
  end.
end procedure.
procedure pftxvalo :
  define input  parameter par-rc        as recid                          no-undo .
  define input  parameter partax-code   like ub.tax.tax-code              no-undo .
  define input  parameter parrate-code  like ub.tax-rate.rate-code        no-undo .
  define input  parameter parfact-order like ub.tax-rate-value.fact-order no-undo .
  define input  parameter parhost-code  like ub.sysconf.host-code         no-undo .
  define input  parameter parobj-type   like ub.clients.obj-type          no-undo .
  define input  parameter parobj-code   like ub.clients.obj-code          no-undo .
  define output parameter partax-value  as decimal no-undo .
  define variable vss-description as character no-undo initial "pftxvalo: Значение по ставке налога для данного fact-order для заданного объекта и фирмы".
  define buffer buf_tax-rate for ub.tax-rate.
  define buffer buf_tax-rate-value for ub.tax-rate-value.
  do
  on error undo, return error return-value
  :
    assign
      partax-value = ?
    .
    if partax-code  = 0
    or parrate-code = 0
    then do:
      if par-rc = ?
      then do:
        undo, return error "Неверный параметр - recid tax-rate" .
      end.
      find first buf_tax-rate no-lock
        where recid(buf_tax-rate) = par-rc
        no-error .
      if not available buf_tax-rate
      then do:
        undo, return error "Не найдена ставка налога " + "recid " + string(par-rc) .
      end.
      if buf_tax-rate.status_ = 'удал':U
      then do:
        undo, return error "Ставка налога недействительна "
        + "налог: " + string(buf_tax-rate.tax-code) + " ставка: " + string(buf_tax-rate.rate-code) .
      end.
      assign
        partax-code  = buf_tax-rate.tax-code
        parrate-code = buf_tax-rate.rate-code
      .
    end.
    find last buf_tax-rate-value no-lock
      where buf_tax-rate-value.tax-code   = partax-code
        and buf_tax-rate-value.rate-code  = parrate-code
        and buf_tax-rate-value.host-code  = parhost-code
        and buf_tax-rate-value.obj-type   = parobj-type
        and buf_tax-rate-value.obj-code   = parobj-code
        and buf_tax-rate-value.fact-order <= parfact-order
        and buf_tax-rate-value.status_    = 'тек':U
      no-error .
    if available buf_tax-rate-value
    then do:
      assign
        partax-value = buf_tax-rate-value.rate-value
      .
      return.
    end.
    find last buf_tax-rate-value no-lock
      where buf_tax-rate-value.tax-code   = partax-code
        and buf_tax-rate-value.rate-code  = parrate-code
        and buf_tax-rate-value.host-code  = parhost-code
        and buf_tax-rate-value.obj-type   = ""
        and buf_tax-rate-value.obj-code   = 0
        and buf_tax-rate-value.fact-order <= parfact-order
        and buf_tax-rate-value.status_    = 'тек':U
      no-error .
    if available buf_tax-rate-value
    then do:
      assign
        partax-value = buf_tax-rate-value.rate-value
      .
      return.
    end.
    find last buf_tax-rate-value no-lock
      where buf_tax-rate-value.tax-code   = partax-code
        and buf_tax-rate-value.rate-code  = parrate-code
        and buf_tax-rate-value.host-code  = 0
        and buf_tax-rate-value.obj-type   = ""
        and buf_tax-rate-value.obj-code   = 0
        and buf_tax-rate-value.fact-order <= parfact-order
        and buf_tax-rate-value.status_    = 'тек':U
      no-error .
    if available buf_tax-rate-value
    then do:
      assign
        partax-value = buf_tax-rate-value.rate-value
      .
      return.
    end.
  end.
end procedure.
procedure getListTaxRateValue :
  define input  parameter iTax       like ub.tax.tax-name              no-undo .
  define input  parameter iDate      like ub.tax-rate-value.fact-date  no-undo .
  define input  parameter iHostCode  like ub.sysconf.host-code         no-undo .
  define input  parameter iObjType   like ub.clients.obj-type          no-undo .
  define input  parameter iObjCode   like ub.clients.obj-code          no-undo .
  define output parameter oListTaxValue as character no-undo .
  define variable vss-description as character no-undo initial "getListTaxRateValue: Возвращает список действующих ставок налога на дату для заданного объекта".
  define variable vFactOrder as decimal no-undo.
  define buffer buf_tax            for ub.tax.
  define buffer buf_tax-rate       for ub.tax-rate.
  define buffer buf_tax-rate-value for ub.tax-rate-value.
  if iDate = ? then
    iDate = today.
  run factord-end-day in this-procedure
    (input  iDate
    ,output vFactOrder
    ).
  do
  on error undo, return error return-value
  :
    for first buf_tax where
              buf_tax.tax-name = iTax
          and buf_tax.status_  = 'тек':U no-lock,
        each buf_tax-rate where
             buf_tax-rate.tax-code = buf_tax.tax-code
         and buf_tax-rate.status_ <> 'удал':U
        no-lock,
        last buf_tax-rate-value where
             buf_tax-rate-value.tax-code = buf_tax-rate.tax-code
         and buf_tax-rate-value.rate-code = buf_tax-rate.rate-code
         and buf_tax-rate-value.host-code = iHostCode
         and buf_tax-rate-value.obj-type = iObjType
         and buf_tax-rate-value.obj-code = iObjCode
         and buf_tax-rate-value.fact-order <= vFactOrder
         and buf_tax-rate-value.status_ = 'тек':U
        no-lock by buf_tax-rate-value.rate-value:
      oListTaxValue = substitute(
        "&1&2&3",
        oListTaxValue,
        if oListTaxValue = "" then "" else ",",
        string(buf_tax-rate-value.rate-value)
      ).
    end.
  end.
end procedure.
procedure curobjdt :
  define input  parameter p-obj-type like ub.obj-date.obj-type   no-undo .
  define input  parameter p-obj-code like ub.obj-date.obj-code   no-undo .
  define output parameter p-sys-date like ub.obj-date.sys-date no-undo .
  define variable vss-description as character no-undo initial "curobjdt-01: определение текущей даты".
  do
  on error undo, return error return-value
  :
    define buffer bf_clients for ub.clients.
    define variable v-cur-sys-date  as date      no-undo .
    define variable v-db-sys-date   as date      no-undo .
    define variable v-obj-is-active as logical   no-undo.
    define variable diffshftvalue   as character no-undo initial ?.
    define variable diffshfttype    as character no-undo initial ?.
    define variable vardiffshft     as integer   no-undo initial ?.
    assign
      v-db-sys-date = today
    .
define variable vss-include-info75 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdtget in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-cur-sys-date
  ) no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры получить текущую дату объекта" skip
          "Объект" p-obj-type p-obj-code skip
          return-value skip
          error-status :get-message(1) skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
define variable vss-include-info76 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'active=request':U
  ,output v-obj-is-active
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не удалось определить активность объекта." skip
        "Объект" p-obj-type p-obj-code skip
        return-value skip
        error-status :get-message(1) skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if v-obj-is-active = yes
    then do:
      if v-cur-sys-date = ?
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "На объекте не задана текущая дата" skip
          "Объект" p-obj-type p-obj-code skip
          return-value skip
          error-status :get-message(1) skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      if v-cur-sys-date > v-db-sys-date
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Дата объекта не может быть больше, чем физическое время на сервере БД" skip
          "Объект" p-obj-type p-obj-code skip
          "Дата объекта" v-cur-sys-date skip
          "Физическое время на сервере БД" v-db-sys-date skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      if v-cur-sys-date = v-db-sys-date
      then do:
        assign
          p-sys-date = v-cur-sys-date
        .
        return .
      end.
      define variable l-shift-on  as logical   no-undo .
      define variable l-auto-date as logical   no-undo .
      if v-cur-sys-date < v-db-sys-date
      then do:
define variable vss-include-info77 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request':U
  ,output l-shift-on
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при определении атрибута объекта" skip
            "Объект" p-obj-type p-obj-code skip
            "Атрибут" 'shift-on=request':u skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
define variable vss-include-info78 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'autodate=request':u
  ,output l-auto-date
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при определении атрибута объекта" skip
            "Объект" p-obj-type p-obj-code skip
            "Атрибут" 'autodate=request':u skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        if l-shift-on = false
        then do:
          if l-auto-date = false
          then do:
            assign
              p-sys-date = v-cur-sys-date
            .
            return .
          end.
          else do:
define variable vss-include-info79 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdtset in g#library
  (input p-obj-type
  ,input p-obj-code
  ,input v-db-sys-date
  )  .
define variable vss-include-info80 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdtget in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output p-sys-date
  ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Не объекте не задана текущая дата" skip
                "Объект" p-obj-type p-obj-code skip
                return-value skip
                error-status :get-message(1) skip
                view-as alert-box error .
              undo, return error return-value .
            end.
            return .
          end.
        end.
        else do:
          if l-auto-date = false
          then do:
            assign
              p-sys-date = v-cur-sys-date
            .
            return .
          end.
          else do:
            define variable p-shift-date as date      no-undo .
            define variable p-shift-num  as integer   no-undo .
            define variable p-shift-name as character no-undo .
define variable vss-include-info81 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output p-shift-date
  ,output p-shift-num
  ,output p-shift-name
  ) no-error .
            if error-status :error
            then do:
              if error-status :get-message(1) <> ""
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Ошибка при вызове процедуры" 'curshift':u skip
                  error-status :get-message(1) skip
                  return-value skip
                  view-as alert-box error .
                undo, return error return-value .
              end.
            end.
            if p-shift-date <> ?
            then do:
              find first bf_clients where bf_clients.obj-type = p-obj-type and
                                          bf_clients.obj-code = p-obj-code no-lock no-error.
              if not available bf_clients then do:
                message "Не найден клиент: " p-obj-type p-obj-code skip
                vss-workfile vss-revision vss-description skip
                view-as alert-box error .
                undo, return error return-value .
              end.
               define variable v-value-character as character  no-undo .
               define variable v-value-date      as date       no-undo .
               define variable v-value-decimal   as decimal    no-undo .
               define variable v-value-integer   as integer    no-undo .
               define variable v-value-logical   as logical    no-undo .
               define variable v-tth             as handle     no-undo .
               define variable v-param-type            as character no-undo .
               run adm/shattri.p ( input "get":U
                                 , input  p-obj-type
                                 , input  p-obj-code
                                 , input  'obj-date':U
                                 , input  'diffshft':U
                                 , output v-value-character
                                 , output v-value-date
                                 , output v-value-decimal
                                 , output v-value-integer
                                 , output v-value-logical
                                 , output v-param-type
                                 , input-output table-handle v-tth
                                 ) no-error .
              if error-status :error then do:
                assign vardiffshft = 3.
              end.
              else do:
                assign
                  vardiffshft = v-value-integer no-error.
                if error-status :error
                or vardiffshft < 0
                then do:
                  message "Неверно задан параметр diffshft: " diffshftvalue skip
                          "Параметр может принимать целые значения > 0." skip
                  view-as alert-box error.
                  undo, return error substitute( "Неверно задан параметр diffshft: &1.&2" +
                                                 "Параметр может принимать целые значения > 0.",
                                                 diffshftvalue,
                                                 chr(10) ) .
                end.
              end.
              delete object v-tth no-error.
              if v-db-sys-date - p-shift-date > vardiffshft
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Нельзя изменить дату" skip
                  "Максимальный размер смены составляет " vardiffshft " суток" skip
                  "Объект" p-obj-type p-obj-code skip
                  view-as alert-box error .
                undo, return error return-value .
              end.
            end.
define variable vss-include-info82 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdtset in g#library
  (input p-obj-type
  ,input p-obj-code
  ,input v-db-sys-date
  )  .
define variable vss-include-info83 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdtget in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output p-sys-date
  ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Не объекте не задана текущая дата" skip
                "Объект" p-obj-type p-obj-code skip
                return-value skip
                error-status :get-message(1) skip
                view-as alert-box error .
              undo, return error return-value .
            end.
            return .
          end.
        end.
      end.
    end.
    else do:
      assign
        p-sys-date = v-cur-sys-date
      .
      if p-sys-date = ?
      then do:
        assign
          p-sys-date = today
        .
      end.
    end.
  end.
end procedure.
procedure objdtget :
  define input  parameter p-obj-type like ub.obj-date.obj-type no-undo .
  define input  parameter p-obj-code like ub.obj-date.obj-code no-undo .
  define output parameter p-sys-date like ub.obj-date.sys-date no-undo .
  define variable vss-description as character no-undo initial "objdtget-01: запросить текущую дату на объекте".
  do
  on error undo, return error return-value
  :
    define buffer buf_obj-date for ub.obj-date .
    find first buf_obj-date
      where buf_obj-date.obj-type = p-obj-type
        and buf_obj-date.obj-code = p-obj-code
        and buf_obj-date.status_  = 'тек':U
      no-error .
    if not available buf_obj-date
    then do:
      undo, return error substitute("На объекте не задана текущая дата. Объект &1 &2", p-obj-type, p-obj-code) .
    end.
    assign
      p-sys-date = buf_obj-date.sys-date
    .
    RELEASE buf_obj-date.
  end.
end procedure.
procedure objdtset :
  define input parameter p-obj-type like ub.obj-date.obj-type   no-undo .
  define input parameter p-obj-code like ub.obj-date.obj-code   no-undo .
  define input parameter p-sys-date like ub.obj-date.sys-date no-undo .
  define variable vss-description as character no-undo initial "objdtset-01: установить текущую дату на объекте".
  do transaction
  on error undo, return error return-value
  :
    define buffer buf_obj-date for ub.obj-date .
define variable vss-include-info84 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run odtclose in g#library
  (input p-obj-type
  ,input p-obj-code
  ,input p-sys-date
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры" 'odtclose':u skip
        "Объект" p-obj-type p-obj-code skip
        "Новая дата" p-sys-date skip
        return-value skip
        error-status :get-message(1) skip
        view-as alert-box error .
      undo, return error return-value .
    end.
define variable vss-include-info85 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdtcr in g#library
  (input p-obj-type
  ,input p-obj-code
  ,input p-sys-date
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры" 'objdtcr':u skip
        "Объект" p-obj-type p-obj-code skip
        "Новая дата" p-sys-date skip
        return-value skip
        error-status :get-message(1) skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure objdtcr :
  define input parameter p-obj-type like ub.obj-date.obj-type no-undo .
  define input parameter p-obj-code like ub.obj-date.obj-code no-undo .
  define input parameter p-sys-date like ub.obj-date.sys-date no-undo .
  define variable vss-description as character no-undo initial "objdtcr-01: создать новую текущую дату на объекте".
  define buffer buf_obj-date for ub.obj-date .
  do
  on error undo, return error return-value
  :
    create buf_obj-date .
    assign
      buf_obj-date.obj-type = p-obj-type
      buf_obj-date.obj-code = p-obj-code
      buf_obj-date.sys-date = p-sys-date
      buf_obj-date.status_  = 'тек':U
    .
    release buf_obj-date .
  end.
end procedure.
procedure odtclose :
  define input parameter p-obj-type like ub.obj-date.obj-type no-undo .
  define input parameter p-obj-code like ub.obj-date.obj-code no-undo .
  define input parameter p-sys-date like ub.obj-date.sys-date no-undo .
  define variable vss-description as character no-undo initial "odtclose-01: закрыть текущую дату на объекте".
  do transaction
  on error undo, return error return-value
  :
    define buffer buf_obj-date for ub.obj-date .
    find first buf_obj-date exclusive-lock
      where buf_obj-date.obj-type = p-obj-type
        and buf_obj-date.obj-code = p-obj-code
        and buf_obj-date.status_  = 'тек':U
      no-error .
    if not available buf_obj-date
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "На объекте не задана текущая дата" skip
        "Объект" p-obj-type p-obj-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-sys-date < buf_obj-date.sys-date
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Новая дата не может быть меньше текущей даты" skip
        "Объект" p-obj-type p-obj-code skip
        "Новая дата" p-sys-date skip
        "Текущая дата" buf_obj-date.sys-date skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      buf_obj-date.status_ = 'зкр':U
    .
    release buf_obj-date .
  end.
end procedure.
procedure curr-r-b :
  define output parameter p-r-b       as character no-undo .
  define variable vss-description as character no-undo initial "curr-r-b-1: определение типа валюты продажи".
  define buffer buf_sys-ctrl for ub.sys-ctrl .
  do
  on error undo, return error return-value
  :
    find first buf_sys-ctrl no-lock .
    assign
      p-r-b = buf_sys-ctrl.r-b
    .
    if  p-r-b <> 'rubl':U
    and p-r-b <> 'base':U
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Недопустимое значение типа валюты продажи" p-r-b skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure currsysk :
  define output parameter p-sys-key       as character no-undo .
  define variable vss-description as character no-undo initial "curr-sk: определение sys-key".
  define buffer buf_sys-ctrl for ub.sys-ctrl .
  do
  on error undo, return error return-value
  :
    find first buf_sys-ctrl no-lock .
    assign
      p-sys-key = buf_sys-ctrl.sys-key
    .
    if p-sys-key = ? then do:
      assign
        p-sys-key = "":U
      .
    end.
  end.
end procedure.
procedure rbisbase :
  define output parameter p-rb-is-base as logical   no-undo .
  do
  on error undo, return error return-value
  :
    define variable v-curr-r-b as character no-undo .
define variable vss-include-info86 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
    if v-curr-r-b = 'base':U
    then do:
      assign
        p-rb-is-base = true
      .
    end.
    else do:
      assign
        p-rb-is-base = false
      .
    end.
  end.
end procedure.
procedure r-b-curr :
  define input parameter  p-host-code  like ub.sysconf.host-code     no-undo .
  define output parameter p-curr-code  as integer   no-undo .
  define variable vss-description as character no-undo initial "r-b-curr-01: определение кода валюты r-b для фирмы".
  define variable v-curr-r-b  as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info87 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры curr-r-b" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if v-curr-r-b = 'rubl':U
    then do:
      assign
        p-curr-code = 0
      .
    end.
    else do:
define variable vss-include-info88 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  p-host-code
  ,output p-curr-code
  ) no-error .
      if error-status :error
      then do:
        undo, return error return-value .
      end.
    end.
  end.
end procedure.
procedure r-b-abbr :
  define input parameter  p-host-code  like ub.sysconf.host-code     no-undo .
  define output parameter p-r-b-abbr   as character no-undo .
  define variable vss-description as character no-undo initial "r-b-abbr-03: определение аббревиатуры валюты r-b для фирмы".
  define variable v-curr-code as integer   no-undo .
  define buffer buf_currency for ub.currency.
  do
  on error undo, return error return-value
  :
define variable vss-include-info89 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run r-b-curr in g#library
  (input  p-host-code
  ,output v-curr-code
  ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
    find first buf_currency no-lock
      where buf_currency.curr-code = v-curr-code
      no-error .
    if not available buf_currency
    then do:
      assign
        p-r-b-abbr = "?"
      .
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена валюта" skip
        "curr-code" v-curr-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      p-r-b-abbr = buf_currency.curr-abbr
    .
  end.
end procedure.
procedure objdpcnt :
  define input parameter p-type like ub.dis-card-type.type no-undo .
  define input parameter p-emitent-host-code like ub.dis-card-type.emitent-host-code no-undo .
  define input parameter p-host-code like ub.sysconf.host-code  no-undo .
  define input parameter p-obj-type like ub.clients.obj-type   no-undo .
  define input parameter p-obj-code like ub.clients.obj-code   no-undo .
  define input parameter p-discnt-role as character no-undo .
  define output parameter p-d-pcnt as decimal no-undo init ?.
  define variable vss-description as character no-undo initial "objdpcnt2: определение скидки по карте на объекте".
  do transaction
  on error undo, return error return-value
  :
    define buffer buf_dis-dct-rule for ub.dis-dct-rule .
    define buffer buf_dis-rule for ub.dis-rule.
    if NOT (p-discnt-role = 'def-pcnt':U
            OR
            p-discnt-role = 'def-cash-pcnt':U
            or
            p-discnt-role = 'def-categ':U
            )
    then do:
        message
          vss-workfile vss-revision vss-description skip
          "Неверные параметры вызова" skip
          "p-discnt-role" skip
          view-as alert-box error .
        undo, return error return-value .
    end.
    FIND FIRST buf_dis-dct-rule No-LOCK WHERE
                        buf_dis-dct-rule.type = p-type
                    AND buf_dis-dct-rule.emitent-host-code = p-emitent-host-code
                    AND buf_dis-dct-rule.host-code = p-host-code
                    AND buf_dis-dct-rule.obj-type = p-obj-type
                    and buf_dis-dct-rule.obj-code = p-obj-code
                    and buf_dis-dct-rule.pos-type = 'bo':U
                    and buf_dis-dct-rule.discnt-role = p-discnt-role No-ERROR.
    if available buf_dis-dct-rule
    then do:
      find first buf_dis-rule NO-lock
        where buf_dis-rule.rule-num = buf_dis-dct-rule.rule-num no-error.
      if not avail buf_dis-rule
      then do:
          p-d-pcnt = ?.
          undo, return error
          substitute("Не найдена скидка для типа ДК: тип &1 эмитент &2&3тип скидки &4"
                     , p-type
                     , p-emitent-host-code
                     , chr(10)
                     ,entry (lookup (p-discnt-role, 'calc-d-pcnt,calc-cash-d-pcnt,calc-categ,dis-tot-flag,def-categ,def-pcnt,def-cash-pcnt':u) + 1, ',' + 'Расчет %скидки ДК на товар,Расчет %скидки ДК на итог,Расчет категории ДК,Участие в итогах по ДК,Категория ДК по умолчанию,% скидки ДК на товар по умолч.,% скидки ДК на итог по умолч.':u)
                     ) .
      end.
      assign
      p-d-pcnt = (if p-discnt-role = 'def-categ':U
                  then buf_dis-rule.dis-kat
                  else buf_dis-rule.discnt-value).
      return.
    end.
  end.
end procedure.
procedure wthobjcr :
  define input parameter  v-obj-type  like ub.wth-obj.obj-type  no-undo .
  define input parameter  v-obj-code  like ub.wth-obj.obj-code  no-undo .
  define input parameter  v-wth-code  like ub.wth-obj.wth-code     no-undo .
  define parameter buffer buf_wth-obj for ub.wth-obj .
  define variable vss-description as character no-undo initial "wthobjcr-01: поиск/cоздание записи о МЦ на объекте".
  define buffer buf_wealth for ub.wealth .
  find first buf_wth-obj no-lock
    where buf_wth-obj.obj-type  = v-obj-type
      and buf_wth-obj.obj-code  = v-obj-code
      and buf_wth-obj.wth-code  = v-wth-code
    no-error .
  if not available buf_wth-obj
  then do:
    do transaction
    on error undo, return error return-value
    :
      find first buf_wealth share-lock
        where buf_wealth.wth-code = v-wth-code
        no-error .
      if not available buf_wealth
      then do:
        message
          "МЦ" v-wth-code "не найдена."
          view-as alert-box .
        undo, return error return-value .
      end.
      create buf_wth-obj.
      assign
        buf_wth-obj.obj-type     = v-obj-type
        buf_wth-obj.obj-code     = v-obj-code
        buf_wth-obj.wth-code     = v-wth-code
      .
define variable vss-include-info90 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-obj-type
  ,input  v-obj-code
  ,output buf_wth-obj.host-code
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении кода фирмы для объекта" skip
          "v-obj-type" v-obj-type skip
          "v-obj-code" v-obj-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      define buffer buf_wth-pobj for ub.wth-pobj .
      for each buf_wth-pobj no-lock
        where buf_wth-pobj.obj-type   = v-obj-type
          and buf_wth-pobj.obj-code   = v-obj-code
          and buf_wth-pobj.wth-code    = v-wth-code
      on error undo, return error return-value
      :
        if buf_wth-pobj.incass-bank-pl <> 0
        or buf_wth-pobj.incass-other-pl <> 0
        or buf_wth-pobj.incass-cassa-pl <> 0
        or buf_wth-pobj.incass-pl <> 0
        or buf_wth-pobj.income-cassa-pl <> 0
        or buf_wth-pobj.income-other-pl <> 0
        or buf_wth-pobj.income-pl <> 0
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при создании МЦ на объекте" skip
            "Уже существует МЦ на МХ объекта с ненулевыми суммами" skip
            "Объект"  v-obj-type v-obj-code skip
            "Код МЦ" v-wth-code skip
            "Код МХ" buf_wth-pobj.w-p-code skip
            "Сумма инкассировано в банк" buf_wth-pobj.incass-bank-pl SKIP
            "Сумма возврата по кассе" buf_wth-pobj.incass-cassa-pl SKIP
            "Сумма других расходов" buf_wth-pobj.incass-other-pl SKIP
            "Сумма расходов всего" buf_wth-pobj.incass-pl SKIP
            "Сумма выручки" buf_wth-pobj.income-cassa-pl
            "Сумма других приходов" buf_wth-pobj.income-other-pl
            "Сумма приходов всего" buf_wth-pobj.income-pl
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
    end.
  end.
end procedure.
procedure wthpobjc :
  define input parameter  v-obj-type  like ub.wth-pobj.obj-type  no-undo .
  define input parameter  v-obj-code  like ub.wth-pobj.obj-code  no-undo .
  define input parameter  v-wth-code  like ub.wth-pobj.wth-code  no-undo .
  define input parameter  v-w-p-code  like ub.wth-pobj.wth-code  no-undo .
  define parameter buffer buf_wth-pobj for ub.wth-pobj .
  define variable vss-description as character no-undo initial "wthpobjc-01: поиск/cоздание записи о МЦ на МХ объекта".
  define buffer buf_wealth for ub.wealth .
  define buffer buf_wth-place for ub.wth-place .
  define buffer buf_wth-obj for ub.wth-obj .
  find first buf_wth-pobj no-lock
    where buf_wth-pobj.obj-type  = v-obj-type
      and buf_wth-pobj.obj-code  = v-obj-code
      and buf_wth-pobj.wth-code  = v-wth-code
      and buf_wth-pobj.w-p-code  = v-w-p-code
    no-error .
  if not available buf_wth-pobj
  then do:
    do transaction
    on error undo, return error return-value
    :
      find first buf_wealth share-lock
        where buf_wealth.wth-code = v-wth-code
        no-error .
      if not available buf_wealth
      then do:
        message
          "МЦ" v-wth-code "не найдена."
          view-as alert-box .
        undo, return error return-value .
      end.
      find first buf_wth-place share-lock
        where buf_wth-place.w-p-code = v-w-p-code
          AND buf_wth-place.obj-type = v-obj-type
          AND buf_wth-place.obj-code = v-obj-code
        no-error .
      if not available buf_wth-place
      then do:
        message
          "МХ" v-w-p-code
          "объект" v-obj-type v-obj-code
          "не найдено."
          view-as alert-box .
        undo, return error return-value .
      end.
      create buf_wth-pobj.
      assign
        buf_wth-pobj.obj-type     = v-obj-type
        buf_wth-pobj.obj-code     = v-obj-code
        buf_wth-pobj.wth-code     = v-wth-code
        buf_wth-pobj.w-p-code     = v-w-p-code
      .
define variable vss-include-info91 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-obj-type
  ,input  v-obj-code
  ,output buf_wth-pobj.host-code
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении кода фирмы для объекта" skip
          "v-obj-type" v-obj-type skip
          "v-obj-code" v-obj-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.
end procedure.
procedure wthcheck :
  define input parameter p-obj-type  like ub.wth-obj.obj-type  no-undo .
  define input parameter p-obj-code  like ub.wth-obj.obj-code  no-undo .
  define input parameter p-wth-code  like ub.wth-obj.wth-code  no-undo .
  define input parameter p-mode      as character              no-undo .
  define variable vss-description as character no-undo initial "wthcheck-01: Проверка целостности МЦ" .
  define buffer buf_wealth      for ub.wealth .
  define buffer buf_wth-obj     for ub.wth-obj .
  define buffer buf_wth-pobj    for ub.wth-pobj .
  define buffer buf_temp-pl-wth for temp-pl-wth .
  define variable l-bad-wth as logical  initial true .
  define variable v-message as character no-undo .
  if  p-mode <> ""
  and p-mode <> ?
  and p-mode <> "return"
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестное значение параметра p-mode" skip
      "p-mode" p-mode skip
      view-as alert-box information.
    undo, return error return-value .
  end.
  assign
    v-message = "Объект" + " " + string(p-obj-type) + " " + string(p-obj-code) + chr(10)
              + "МЦ" + " " + string(p-wth-code) + chr(10)
  .
  check_block:
  do
  on error undo check_block, leave
  :
    assign
      l-bad-wth = false
    .
    find first buf_wealth no-lock
      where buf_wealth.wth-code     = p-wth-code
      no-error .
    if not available buf_wealth
    then do:
      assign
        v-message = v-message
                  + "Не найдена запись МЦ" + chr(10)
        l-bad-wth = true
      .
      leave check_block.
    end.
    if buf_wealth.PS begins "%%%"
    then do:
      return .
    end.
    find first buf_wth-obj exclusive-lock
      where buf_wth-obj.obj-type  = p-obj-type
        and buf_wth-obj.obj-code  = p-obj-code
        and buf_wth-obj.wth-code  = p-wth-code
      no-error .
    if not available buf_wth-obj
    then do:
      assign
        v-message = v-message
                  + "Не найдена запись МЦ на объекте" + chr(10)
        l-bad-wth = true
      .
      leave check_block.
    end.
    DEFINE VARIABLE v-incass-bank  like ub.wth-obj.incass-bank  no-undo .
    DEFINE VARIABLE v-incass-other like ub.wth-obj.incass-other no-undo .
    DEFINE VARIABLE v-incass-cassa like ub.wth-obj.incass-cassa no-undo .
    DEFINE VARIABLE v-incass       like ub.wth-obj.incass       no-undo .
    DEFINE VARIABLE v-income-cassa like ub.wth-obj.income-cassa no-undo .
    DEFINE VARIABLE v-income-other like ub.wth-obj.income-other no-undo .
    DEFINE VARIABLE v-income       like ub.wth-obj.income       no-undo .
    assign
    v-incass-bank  = 0
    v-incass-other = 0
    v-incass-cassa = 0
    v-incass       = 0
    v-income-cassa = 0
    v-income-other = 0
    v-income       = 0
    .
    for each buf_wth-pobj share-lock
      where buf_wth-pobj.obj-type  = p-obj-type
        and buf_wth-pobj.obj-code  = p-obj-code
        and buf_wth-pobj.wth-code   = p-wth-code
    on error undo check_block, leave check_block
    :
      assign
      v-incass-bank  = v-incass-bank  + buf_wth-pobj.incass-bank-pl
      v-incass-other = v-incass-other + buf_wth-pobj.incass-other-pl
      v-incass-cassa = v-incass-cassa + buf_wth-pobj.incass-cassa-pl
      v-incass       = v-incass       + buf_wth-pobj.incass-pl
      v-income-cassa = v-income-cassa + buf_wth-pobj.income-cassa-pl
      v-income-other = v-income-other + buf_wth-pobj.income-other-pl
      v-income       = v-income       + buf_wth-pobj.income-pl
      .
    end.
    if
    (v-incass-bank + v-incass-other + v-incass-cassa) <> v-incass OR
    (v-income-cassa + v-income-other) <> v-income OR
    (buf_wth-obj.incass-bank + buf_wth-obj.incass-other + buf_wth-obj.incass-cassa) <> buf_wth-obj.incass OR
    (buf_wth-obj.income-cassa + buf_wth-obj.income-other) <> buf_wth-obj.income
    then do:
      assign
        v-message = v-message
                  + "Суммы по МХ не совпадают с суммами по МЦ на объекте" + chr(10)
                  + "или не корреллируют друг с другом" + chr(10)
                  + "По МЦ на объекте:"          +         chr(10)
                  + "Сумма инкассировано в банк" + chr(32) + string(buf_wth-obj.incass-bank ) + chr(10)
                  + "Сумма возвратов по кассе"   + chr(32) + string(buf_wth-obj.incass-cassa) + chr(10)
                  + "Сумма других расходов"      + chr(32) + string(buf_wth-obj.incass-other) + chr(10)
                  + "Сумма расходов всего"       + chr(32) + string(buf_wth-obj.incass      ) + chr(10)
                  + "Сумма выручки"              + chr(32) + string(buf_wth-obj.income-cassa) + chr(10)
                  + "Сумма других приходов"      + chr(32) + string(buf_wth-obj.income-other) + chr(10)
                  + "Сумма приходов всего"       + chr(32) + string(buf_wth-obj.income      ) + chr(10)
                  + "По МХ:" + chr(10)
                  + "Сумма инкассировано в банк" + chr(32) + string(          v-incass-bank ) + chr(10)
                  + "Сумма возвратов по кассе"   + chr(32) + string(          v-incass-cassa) + chr(10)
                  + "Сумма других расходов"      + chr(32) + string(          v-incass-other) + chr(10)
                  + "Сумма расходов всего"       + chr(32) + string(          v-incass      ) + chr(10)
                  + "Сумма выручки"              + chr(32) + string(          v-income-cassa) + chr(10)
                  + "Сумма других приходов"      + chr(32) + string(          v-income-other) + chr(10)
                  + "Сумма приходов всего"       + chr(32) + string(          v-income      ) + chr(10)
        l-bad-wth = true
      .
      leave check_block.
    end.
  end.
  if l-bad-wth
  then do:
    define variable v-return-value as character no-undo .
    if p-mode = ""
    or p-mode = ?
    then do:
      message
        vss-workfile + " " + vss-revision + " " + vss-description + chr(10)
        v-message + chr(10)
        view-as alert-box .
    end.
    if p-mode = "return"
    then do:
      assign
        v-return-value = v-message
      .
    end.
    undo, return error v-return-value .
  end.
end procedure.
procedure wthobjat :
  define input  parameter p-obj-type         like ub.wth-obj.obj-type  no-undo .
  define input  parameter p-obj-code         like ub.wth-obj.obj-code  no-undo .
  define input  parameter p-wth-code         like ub.wth-obj.wth-code  no-undo .
  define input  parameter p-action           as character no-undo .
  define output parameter p-return-attribute as logical no-undo .
  define variable vss-description as character no-undo initial "wthobjat-01: задает/получает признаки МЦ на объекте".
  define variable ind      as integer no-undo .
  define variable v-action as character no-undo .
  define variable l-find-wth-obj as logical no-undo initial false .
  define buffer buf_wth-obj for ub.wth-obj .
  define variable v-num-entries-p-action as integer no-undo .
  assign
    v-num-entries-p-action = num-entries(p-action)
  .
  do ind = 1 to v-num-entries-p-action
  :
    assign
      v-action = entry(ind, p-action)
    .
    if lookup(v-action, "inv-on=request,exist-wth-obj=request") > 0
    then do:
      find first buf_wth-obj no-lock
        where buf_wth-obj.obj-type  = p-obj-type
          and buf_wth-obj.obj-code  = p-obj-code
          and buf_wth-obj.wth-code  = p-wth-code
        no-error .
    end.
    else do:
      if l-find-wth-obj <> true
      then do:
define variable vss-include-info92 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run wthobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-wth-code
  ,buffer buf_wth-obj
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно найти wth-obj" skip
            "p-obj-type"  p-obj-type  skip
            "p-obj-code"  p-obj-code  skip
            "p-wth-code"  p-wth-code  skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        assign
          l-find-wth-obj = true
        .
      end.
    end.
    case v-action :
      when "exist-wth-obj=request"
      then do:
        assign
          p-return-attribute = (available buf_wth-obj)
        .
      end.
      when "inv-on=true" or
      when "inv-on=yes"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_wth-obj exclusive-lock .
          if buf_wth-obj.inv-on <> true
          then do:
            assign
              buf_wth-obj.inv-on = true
            .
          end.
          else do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при установке признака 'МЦ находится в инвентаризации'."
              "p-obj-type"  p-obj-type  skip
              "p-obj-code"  p-obj-code  skip
              "p-wth-code"  p-wth-code  skip
              "v-action"    v-action    skip
              "p-action"    p-action    skip
              "wth-obj.inv-on" buf_wth-obj.inv-on skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            p-return-attribute = buf_wth-obj.inv-on
          .
        end.
      end.
      when "inv-on=false" or
      when "inv-on=no"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_wth-obj exclusive-lock .
          if buf_wth-obj.inv-on <> false
          then do:
            assign
              buf_wth-obj.inv-on = false
            .
          end.
          else do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при сбрасывании признака 'МЦ находится в инвентаризации'."
              "p-obj-type"  p-obj-type  skip
              "p-obj-code"  p-obj-code  skip
              "p-wth-code"  p-wth-code  skip
              "v-action"    v-action    skip
              "p-action"    p-action    skip
              "wth-obj.inv-on" buf_wth-obj.inv-on skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            p-return-attribute = buf_wth-obj.inv-on
          .
        end.
      end.
      when "inv-on=request"
      then do:
        if available buf_wth-obj
        then do:
          assign
            p-return-attribute = buf_wth-obj.inv-on
          .
        end.
        else do:
          assign
            p-return-attribute = false
          .
        end.
      end.
      when "inv-on=request:exclusive"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_wth-obj exclusive-lock .
          assign
            p-return-attribute = buf_wth-obj.inv-on
          .
        end.
      end.
      when "inv-on=request:share"
      then do:
        do transaction
        on error undo, return error return-value
        :
          find current buf_wth-obj exclusive-lock .
          assign
            p-return-attribute = buf_wth-obj.inv-on
          .
        end.
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестное значение параметра v-action " skip
          "v-action" v-action skip
          "p-action" p-action skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.
end procedure.
procedure wthdat :
  define input parameter  p-wth-doc-doc-type    like ub.wth-doc.doc-type no-undo .
  define input parameter  p-wth-doc-internal    like ub.wth-doc.exter_   no-undo .
  define input parameter  p-wth-doc-status_     like ub.wth-doc.status_  no-undo .
  define input  parameter p-action              as character no-undo .
  define output parameter p-return-attribute    as character no-undo .
  define variable vss-description as character no-undo initial "wthdat-01: Задает/получает различные признаки документа МЦ на объекте".
  define variable ind      as integer no-undo .
  define variable v-action as character no-undo .
  define variable v-num-entries-p-action as integer no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-num-entries-p-action = num-entries(p-action)
    .
    do ind = 1 to v-num-entries-p-action
    :
      assign
        v-action = entry(ind, p-action)
      .
      case v-action :
        when "can-change-status-inv-on=request"
        then do:
          if  p-wth-doc-doc-type = 'инв':U
          then do:
            assign
              p-return-attribute = "true":u
            .
            next .
          end.
          if  p-wth-doc-doc-type = 'при':U
          and p-wth-doc-internal = false
          and p-wth-doc-status_  = 'накл':U
          then do:
            assign
              p-return-attribute = "true":u
            .
            next .
          end.
          assign
            p-return-attribute = "false":u
          .
        end.
        when "can-edit-inv-on=request":u
        then do:
          if  p-wth-doc-doc-type = 'инв':U
          and p-wth-doc-status_  = 'разрешен':U
         then do:
            assign
              p-return-attribute = "true":u
            .
            next .
          end.
          if  p-wth-doc-doc-type = 'при':U
          and p-wth-doc-internal = false
          and p-wth-doc-status_  = 'накл':U
          then do:
            assign
              p-return-attribute = "true":u
            .
            next .
          end.
          assign
            p-return-attribute = "false":u
          .
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестное значение параметра v-action " skip
            "v-action" v-action skip
            "p-action" p-action skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
    end.
  end.
end procedure.
procedure emptyscl :
  define output parameter p-node-code as integer   no-undo .
  define variable vss-description as character no-undo initial "emptyscl-01: Определение корневого признака пустой шкалы".
  define buffer buf_gds-prt for ub.gds-prt .
  do
  on error undo, return error return-value
  :
    find first buf_gds-prt no-lock
      where buf_gds-prt.root = true
        and buf_gds-prt.node-name = '_Пустая шкала':U
      no-error .
    if available buf_gds-prt
    then do:
      assign
        p-node-code = buf_gds-prt.node-code
      .
    end.
    else do:
      undo, return error substitute("&1 не найдена", '_Пустая шкала':U ) .
    end.
  end.
end procedure.
procedure objdbnum :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define output parameter p-db-num   as integer   no-undo .
  define variable vss-description as character no-undo initial "objdbnum-01: Определить базу данных, которой принадлежит объект".
  define buffer buf_clients for ub.clients .
  do
  on error undo, return error return-value
  :
    find first buf_clients no-lock
      where buf_clients.obj-type = p-obj-type
        and buf_clients.obj-code = p-obj-code
      no-error .
    if not available buf_clients
    then do:
      undo, return error substitute( "Ошибка задания входных параметров. Не найден объект &1 &2", p-obj-type, p-obj-code) .
    end.
    assign
      p-db-num = buf_clients.db-num
    .
  end.
end procedure.
procedure grpgdsnm :
  define input  parameter p-node-code     as integer   no-undo .
  define output parameter p-full-grp-name as character no-undo .
  define variable vss-description as character no-undo initial "grpgdsnm-01: Полное имя группы для сортировки и поиска".
  define variable v-upper-code as integer   no-undo .
  define variable v-grp-name   as character no-undo .
  define buffer buf_gds-grp for ub.gds-grp .
  do
  on error undo, return error return-value
  :
    find buf_gds-grp no-lock
      where buf_gds-grp.node-code = p-node-code
      no-error .
    if not available buf_gds-grp
    then do:
      undo, return error substitute("Ошибка задания входных параметров" + chr(10)
                                   + "Не найдена группа &1", p-node-code
                                   ) .
    end.
    assign
      v-grp-name = ''
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error return-value
    :
      assign
        v-grp-name   = buf_gds-grp.node-name + chr(47) + v-grp-name
        v-upper-code = buf_gds-grp.upper-code
      .
      find buf_gds-grp no-lock
        where buf_gds-grp.node-code = v-upper-code
        no-error .
      if not available buf_gds-grp
      then do:
        undo, return error substitute("Не найдена родительская группа для группы &1", v-upper-code
                                     ) .
      end.
    end.
    assign
      p-full-grp-name = v-grp-name
    .
  end.
end procedure.
procedure file-clr :
  define input  parameter p-file-name as character no-undo .
  define variable vss-description as character no-undo initial "file-clr-01: Создать новый файл нулевой длины".
  do
  on error undo, return error return-value
  :
    if p-file-name = ""
    or p-file-name = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не задано имя файла" skip
        "p-file-name" p-file-name skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    output stream librout to value(p-file-name) .
    output stream librout close .
  end.
end procedure.
procedure file-wr :
  define input  parameter p-file-name as character no-undo .
  define input  parameter p-line      as character no-undo .
  define variable vss-description as character no-undo initial "file-wr-01: Записать строку в файл".
  do
  on error undo, return error return-value
  :
    if p-file-name = ""
    or p-file-name = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не задано имя файла" skip
        "p-file-name" p-file-name skip
        "p-line" p-line skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-line = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не задана строка для вывода в файл" skip
        "p-file-name" p-file-name skip
        "p-line" p-line skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    output stream librout to value(p-file-name) append.
    put stream librout unformatted p-line .
    output stream librout close .
  end.
end procedure.
procedure filenmln :
  define input  parameter p-file-name  as character no-undo .
  define input  parameter p-line-count as integer   no-undo .
  define output parameter p-line-exist as logical   no-undo .
  define variable vss-description as character no-undo initial "filenmln-01: Определить наличие определенного количества строк в файле".
  define variable v-str-read as character no-undo .
  define variable v-str-ind  as integer   no-undo init 0 .
  if p-line-count = ?
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "p-line-count" p-line-count skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  do
  on error undo, return error return-value
  :
    assign
      p-line-exist = false
    .
    input stream librout from value(p-file-name) .
    repeat
    :
      import stream librout unformatted v-str-read no-error .
      assign
        v-str-ind = v-str-ind + 1
      .
      if v-str-ind >= p-line-count
      then do:
        assign
          p-line-exist = true
        .
        leave.
      end.
    end.
    input stream librout close .
  end.
end procedure.
procedure rsrvtype :
  define input  parameter p-doc-code  as character no-undo .
  define output parameter p-rsrv-type as character no-undo .
  define variable vss-description as character no-undo initial "rsrvtype-01: Способ резервирования документа в зависимости от типа и статуса".
  define buffer buf_trn-doc for ub.trn-doc .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Документ" p-doc-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    case buf_trn-doc.doc-type:
      when 'при':U
      then do:
        if buf_trn-doc.internal = false
        then do:
          if  buf_trn-doc.status_  = 'накл':U
          and buf_trn-doc.flag_    = false
          then do:
            assign
              p-rsrv-type = 'rsrv-pri-doc':U
            .
            return .
          end.
          if  buf_trn-doc.status_  = 'накл':U
          and buf_trn-doc.flag_    = true
          then do:
            assign
              p-rsrv-type = 'rsrv-pri-fact':U
            .
            return .
          end.
        end.
        if  buf_trn-doc.internal = true
        then do:
          if  buf_trn-doc.status_  = 'накл':U
          and buf_trn-doc.flag_    = false
          then do:
            assign
              p-rsrv-type = 'rsrv-pri-doc':U
            .
            return .
          end.
          if  buf_trn-doc.status_  = 'накл':U
          and buf_trn-doc.flag_    = true
          then do:
            assign
              p-rsrv-type = 'rsrv-fact':U
            .
            return .
          end.
        end.
      end.
      when 'рас':U   or
      when 'спи':U or
      when 'возврат':U
      then do:
        if (buf_trn-doc.status_ = 'накл':U and buf_trn-doc.flag_ = no )
        or (buf_trn-doc.status_ = 'касс':U )
        then do:
          assign
            p-rsrv-type = 'rsrv-doc':U
          .
          return .
        end.
        else do:
          if buf_trn-doc.status_ = 'разрешен':U
          or (buf_trn-doc.status_ = 'накл':U and buf_trn-doc.flag_ = yes and buf_trn-doc.ext-doc-type = 'eo':U)
          then do:
            assign
              p-rsrv-type = 'rsrv-fact':U
            .
            return .
          end.
        end.
      end.
      when 'инв':U
      then do:
        assign
          p-rsrv-type = 'rsrv-doc':U
        .
        return .
      end.
    end case.
    undo, return error substitute("Неизвестный тип документа. Тип документа &1. Статус &2", buf_trn-doc.doc-type, buf_trn-doc.status_) .
  end.
end procedure.
procedure curdbnum :
  define output parameter p-db-num as integer   no-undo .
  define variable vss-description as character no-undo initial "curdbnum-01: Возвращает номер текущей базы данных".
  define buffer buf_sys-ctrl for ub.sys-ctrl .
  do
  on error undo, return error return-value
  :
    find first buf_sys-ctrl no-lock no-error .
    if not available buf_sys-ctrl
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена запись sys-ctrl" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      p-db-num = buf_sys-ctrl.db-num
    .
  end.
end procedure.
procedure usrfulnm :
  define input  parameter p-user-id   as character no-undo .
  define output parameter p-user-name as character no-undo .
  define variable vss-description as character no-undo initial "usrfulnm-01: Псевдоним пользователя".
  define buffer buf_user-account        for ub.user-account .
  define buffer buf_parent_user-account for ub.user-account .
  do
  on error undo, return error return-value
  :
    find first buf_user-account no-lock
      where buf_user-account.user-id = p-user-id
      no-error .
    if not available buf_user-account
    then do:
      assign
        p-user-name = p-user-id
      .
    end.
    else do:
      if buf_user-account.check-parent = true
      then do:
        find first buf_parent_user-account no-lock
          where buf_parent_user-account.user-id = buf_user-account.parent-user-id
          no-error .
        if not available buf_parent_user-account
        then do:
          assign
            p-user-name = p-user-id
          .
        end.
        else do:
          assign
            p-user-name = buf_user-account.nik
          .
        end.
      end.
      else do:
        assign
          p-user-name = buf_user-account.nik
        .
      end.
    end.
  end.
end procedure.
procedure usrfuln2 :
  define input  parameter p-user-id   as character no-undo .
  define input  parameter p-db-num    as integer   no-undo .
  define output parameter p-user-name as character no-undo .
  define variable vss-description as character no-undo initial "usrfulnm-01: Имя пользователя".
  define buffer buf_user-account        for ub.user-account .
  define buffer buf_parent_user-account for ub.user-account .
  define buffer buf_user-account-attr   for ub.user-account-attr .
  do
  on error undo, return error return-value
  :
    find first buf_user-account no-lock
      where buf_user-account.user-id = p-user-id
      no-error .
    if not available buf_user-account
    then do:
      find first buf_user-account
           where buf_user-account.user-id begins SUBSTITUTE("&1-", p-db-num)
             and buf_user-account.parent-user-id   = p-user-id
             and buf_user-account.check-parent     = FALSE
           no-lock
           no-error
           .
            if available buf_user-account
            then do:
               assign
                  p-user-name = substitute('&1 &2 &3':U
                                          ,buf_user-account.last-name
                                          ,buf_user-account.first-name
                                          ,buf_user-account.second-name
                                          )
               .
            end.
            else do:
               assign
                  p-user-name = p-user-id
               .
            end.
    end.
    else do:
      if buf_user-account.check-parent = true
      then do:
        find first buf_parent_user-account no-lock
          where buf_parent_user-account.user-id = buf_user-account.parent-user-id
          no-error .
        if not available buf_parent_user-account
        then do:
          assign
            p-user-name = p-user-id
          .
        end.
        else do:
          assign
            p-user-name = substitute('&1 &2 &3':U
                                    ,buf_parent_user-account.last-name
                                    ,buf_parent_user-account.first-name
                                    ,buf_parent_user-account.second-name
                                    )
          .
        end.
      end.
      else do:
        assign
          p-user-name = substitute('&1 &2 &3':U
                                  ,buf_user-account.last-name
                                  ,buf_user-account.first-name
                                  ,buf_user-account.second-name
                                  )
        .
      end.
    end.
  end.
end procedure.
procedure curdburt :
  define output parameter p-db-num       as integer   no-undo .
  define output parameter p-user-name    as character no-undo .
  define output parameter p-sys-date     as date      no-undo .
  define output parameter p-sys-time     as character no-undo .
  define output parameter p-sys-time-int as integer   no-undo .
  define variable vss-description as character no-undo initial "curdburt-01: Возвращает текущий номер базы данных, пользователя, дату, время и количество секунд".
  do
  on error undo, return error return-value
  :
define variable vss-include-info93 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run getcurus in g#library2
  (output p-db-num
  ,output p-user-name
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении текущего номера базы данных и пользователя" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run cur-time in this-procedure
      (output p-sys-date
      ,output p-sys-time-int
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении текущего номера базы данных" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      p-sys-time = string(p-sys-time-int, 'HH:MM:SS':u)
    .
  end.
end procedure.
procedure proridoc :
  define input  parameter p-in-code        as character no-undo .
  define input  parameter p-gds-code       as integer   no-undo .
  define input  parameter p-part-code      as character no-undo .
  define output parameter p-orig-in-code   as character no-undo .
  define output parameter p-orig-gds-code  as integer   no-undo .
  define output parameter p-orig-part-code as character no-undo .
  define variable vss-description as character no-undo initial "proridoc-01: Возвращает первичный приход партии".
  define buffer buf_parts-root for ub.parts-root .
  do
  on error undo, return error return-value
  :
    define variable v-in-code   as character no-undo .
    define variable v-gds-code  as integer   no-undo .
    define variable v-part-code as character no-undo .
    assign
      v-in-code   = p-in-code
      v-gds-code  = p-gds-code
      v-part-code = p-part-code
    .
    find first buf_parts-root no-lock
      where buf_parts-root.in-code   = v-in-code
        and buf_parts-root.gds-code  = v-gds-code
        and buf_parts-root.part-code = v-part-code
      no-error .
    do while available buf_parts-root
    :
      assign
        v-in-code   = buf_parts-root.orig-in-code
        v-gds-code  = buf_parts-root.orig-gds-code
        v-part-code = buf_parts-root.orig-part-code
      .
      find first buf_parts-root no-lock
        where buf_parts-root.in-code   = v-in-code
          and buf_parts-root.gds-code  = v-gds-code
          and buf_parts-root.part-code = v-part-code
        no-error .
    end.
    assign
      p-orig-in-code   = v-in-code
      p-orig-gds-code  = v-gds-code
      p-orig-part-code = v-part-code
    .
  end.
end procedure.
procedure pargocod :
  define input  parameter p-parts-recid as recid     no-undo .
  define output parameter p-gds-code    as integer   no-undo .
  define variable vss-description as character no-undo initial "pargocod-01: Возвращает код товара для партии".
  define buffer buf_parts for ub.parts .
  define buffer buf_goods for ub.goods .
  do
  on error undo, return error return-value
  :
    find first buf_parts no-lock
      where recid(buf_parts) = p-parts-recid
      no-error .
    if not available buf_parts
    then do:
      undo, return error substitute("Ошибка задания входных параметров. Не найдена партия с кодом &1", p-parts-recid).
    end.
    find first buf_goods no-lock
      where buf_goods.artic     = buf_parts.artic
        and buf_goods.prod-type = buf_parts.prod-type
        and buf_goods.prod-code = buf_parts.prod-code
      no-error .
    if not available buf_goods
    then do:
      undo, return error substitute("Не найден товар. Указатель партии &1. Артикул &2 &3 &4.", p-parts-recid, buf_parts.artic, buf_parts.prod-type, buf_parts.prod-code) .
    end.
    assign
      p-gds-code = buf_goods.gds-code
    .
  end.
end procedure.
procedure doclicod :
  define input  parameter p-doc-line-recid as recid     no-undo .
  define output parameter p-gds-code       as integer   no-undo .
  define variable vss-description as character no-undo initial "doclicod-01: Возвращает код товара для строки документа".
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_goods for ub.goods .
  do
  on error undo, return error return-value
  :
    find first buf_doc-line no-lock
      where recid(buf_doc-line) = p-doc-line-recid
      no-error .
    if not available buf_doc-line
    then do:
      undo, return error substitute("Ошибка задания входных параметров. Не найдена строка документа с указателем &1", p-doc-line-recid) .
    end.
    find first buf_goods no-lock
      where buf_goods.artic     = buf_doc-line.artic
        and buf_goods.prod-type = buf_doc-line.prod-type
        and buf_goods.prod-code = buf_doc-line.prod-code
      no-error .
    if not available buf_goods
    then do:
      undo, return error substitute("Не найден товар. Указатель строки &1. Артикул &2 &3 &4",p-doc-line-recid,buf_doc-line.artic,buf_doc-line.prod-type,buf_doc-line.prod-code).
    end.
    assign
      p-gds-code = buf_goods.gds-code
    .
  end.
end procedure.
procedure tblnmusr :
  define input  parameter p-table-name as character no-undo .
  define output parameter p-user-name  as character no-undo .
  define variable vss-description as character no-undo initial "tblnmusr-01: Возвращает пользовательское имя таблицы".
  do
  on error undo, return error return-value
  :
    case p-table-name
    :
      when 'trn-doc':U
      then do:
        assign
          p-user-name = 'Накладная'
        .
      end.
      when 'price-doc':U
      then do:
        assign
          p-user-name = 'Переоценка'
        .
      end.
      when 'wth-doc':U
      then do:
        assign
          p-user-name = 'Документ МЦ'
        .
      end.
      when 'inkas':U
      then do:
        assign
          p-user-name = 'Продажа'
        .
      end.
      when 'fbr-doc':U
      then do:
        assign
          p-user-name = 'Производство'
        .
      end.
      when 'fbr-pln':U
      then do:
        assign
          p-user-name = 'План-меню'
        .
      end.
      when 'chk-doc':U
      then do:
        assign
          p-user-name = 'Чек'
        .
      end.
      when 'goods':U
      then do:
        assign
          p-user-name = 'Товар'
        .
      end.
      when 'place':U
      then do:
        assign
          p-user-name = 'Складское место'
        .
      end.
      when 'rvs-doc':U
      then do:
        assign
          p-user-name = 'Сверка'
        .
      end.
      when 'icnt-doc':U
      then do:
        assign
          p-user-name = 'Док.сч.ТРК'
        .
      end.
      when 'ord-doc':U
      then do:
        assign
          p-user-name = 'Заказ'
        .
      end.
      when 'ord-doc-rcv':U
      then do:
        assign
          p-user-name = 'Поставка'
        .
      end.
      when 'ord-cons':U
      then do:
        assign
          p-user-name = 'СЗФП'
        .
      end.
      when 'c-usr-hist':U
      then do:
        assign
          p-user-name = 'История пользователя'
        .
      end.
      when 'cash-pay':U
      then do:
        assign
          p-user-name = 'Тип кассовых платежей'
        .
      end.
      when 'pay-type':U
      then do:
        assign
          p-user-name = 'Вид оплаты'
        .
      end.
      when 'cli-grp':U
      then do:
        assign
          p-user-name = 'Группа клиентов'
        .
      end.
      when 'clients':U
      then do:
        assign
          p-user-name = 'Клиенты'
        .
      end.
      when 'config':U
      then do:
        assign
          p-user-name = 'Конфигурация'
        .
      end.
      when 'dis-card':U
      then do:
        assign
          p-user-name = 'Дисконтная карта'
        .
      end.
      when 'dis-card-type':U
      then do:
        assign
          p-user-name = 'Тип дисконтной карты'
        .
      end.
      when 'fin-bank':U
      then do:
        assign
          p-user-name = 'Банк'
        .
      end.
      when 'gds-grp':U
      then do:
        assign
          p-user-name = 'Группа товаров'
        .
      end.
      when 'units':U
      then do:
        assign
          p-user-name = 'Единица измерения'
        .
      end.
      when 'auto-tank':U
      then do:
        assign
          p-user-name = 'Транспорт'
        .
      end.
      when 'sr-izmerenia':U
      then do:
        assign
          p-user-name = 'Средство измерения'
        .
      end.
      when 'action-role':U
      then do:
        assign
          p-user-name = 'Группа прав'
        .
      end.
      when 'action-role-item':U
      then do:
        assign
          p-user-name = 'Группа прав пункты'
        .
      end.
      when 'pl-gds':U
      then do:
        assign
          p-user-name = 'Товар на скл.месте'
        .
      end.
      when 'pl-gds-pump':U
      then do:
        assign
          p-user-name = 'Контейнер через товар'
        .
      end.
      when 'price-doc-forming':U
      then do:
        assign
          p-user-name = 'Документ формир.цены'
        .
      end.
      when 'c-sht-hist':U or when "sht-hist"
      then do:
        assign
          p-user-name = 'История смены'
        .
      end.
      when 'cash-desk':U
      then do:
        assign
          p-user-name = 'Касса'
        .
      end.
      when 'thbj-attr':U
      then do:
        assign
          p-user-name = 'Конфигурационные атрибуты'
        .
      end.
      when 'staff':U
      then do:
        assign
          p-user-name = 'Персонал'
        .
      end.
      when 'pl-level':U
      then do:
        assign
          p-user-name = 'Градуир. таблица'
        .
      end.
      when 'c-plc-hist':U
      THEN do:
          assign
          p-user-name = "Хранения тов. на скл. месте"
          .
      end.
      when 'pl-pump':U
      THEN do:
          assign
          p-user-name = "Склад.место ТРК"
          .
      end.
      when 'pl-pump-nozzle':U
      THEN do:
          assign
          p-user-name = "Соотв. пистолета и ТРК"
          .
      end.
      when 'shift-obj':U
      THEN do:
          assign
          p-user-name = "Смены"
          .
      end.
      when "report"
      THEN do:
          assign
          p-user-name = "Отчеты"
          .
      end.
      when "utl"
      THEN do:
          assign
          p-user-name = "Утилиты"
          .
      end.
      when "printdoc"
      THEN do:
          assign
          p-user-name = "Печать"
          .
      end.
      otherwise do:
        assign
          p-user-name = p-table-name
        .
      end.
    end.
  end.
end procedure.
procedure tblusrnm :
  define input  parameter p-user-name  as character no-undo .
  define output parameter p-table-name as character no-undo .
  define variable vss-description as character no-undo initial "tblusrnm-01: возвращает имя таблицы по пользовательскому имени таблицы".
  do
  on error undo, return error return-value
  :
    case p-user-name
    :
      when 'Накладная'
      then do:
        assign
          p-table-name = 'trn-doc':U
        .
      end.
      when 'Переоценка'
      then do:
        assign
          p-table-name = 'price-doc':U
        .
      end.
      when 'Документ МЦ'
      then do:
        assign
          p-table-name = 'wth-doc':U
        .
      end.
      when 'Продажа'
      then do:
        assign
          p-table-name = 'inkas':U
        .
      end.
      when 'Производство'
      then do:
        assign
          p-table-name = 'fbr-doc':U
        .
      end.
      when 'План-меню'
      then do:
        assign
          p-table-name = 'fbr-pln':U
        .
      end.
      when 'Сверка'
      then do:
        assign
          p-table-name = 'rvs-doc':U
        .
      end.
      when 'Док.сч.ТРК'
      then do:
        assign
          p-table-name = 'icnt-doc':U
        .
      end.
      when 'Заказ'
      then do:
        assign
          p-table-name = 'ord-doc':U
        .
      end.
      when 'Поставка'
      then do:
        assign
          p-table-name = 'ord-doc-rcv':U
        .
      end.
      when 'СЗФП'
      then do:
        assign
          p-table-name = 'ord-cons':U
        .
      end.
      otherwise do:
        assign
          p-table-name = p-user-name
        .
      end.
    end.
  end.
end procedure.
procedure partcond :
  define input  parameter p-ext-doc-type    as character no-undo .
  define input  parameter p-is-hold         as logical   no-undo .
  define input  parameter p-parts-fact-qnty as decimal   no-undo .
  define input  parameter p-create-part     as logical   no-undo .
  define input  parameter p-old-return      as logical   no-undo .
  define output parameter p-rsrv-code       as character no-undo .
  define output parameter p-unrv-code       as character no-undo .
  define output parameter p-need-rsrv       as logical   no-undo .
  define output parameter p-need-unrv       as logical   no-undo .
  define output parameter p-rsrv-sign       as integer   no-undo .
  define output parameter p-unrv-sign       as integer   no-undo .
  define variable vss-description as character no-undo init "partcond-01: определяет каким образом обрабатывать партии документа".
  do
  on error undo, return error return-value
  :
    assign
      p-rsrv-sign = -1
      p-unrv-sign = 1
    .
    case p-ext-doc-type :
      when 'ie':U
      then do:
        assign
          p-rsrv-code = 'free-zone':U
          p-unrv-code = 'out-zone':U
          p-need-rsrv = true
          p-need-unrv = false
        .
      end.
      when 'ee':U
      then do:
        assign
          p-rsrv-code = 'out-zone':U
          p-unrv-code = 'free-zone':U
          p-need-rsrv = true
          p-need-unrv = true
        .
      end.
      when 'ep':U
      then do:
        assign
          p-rsrv-code = 'out-zone':U
          p-unrv-code = 'free-zone':U
          p-need-rsrv = false
          p-need-unrv = true
        .
      end.
      when 'es':U
      then do:
        assign
          p-rsrv-code = 'out-zone':U
          p-unrv-code = 'free-zone':U
          p-need-rsrv = true
          p-need-unrv = true
        .
      end.
      when 're':U
      then do:
        assign
          p-rsrv-code = 'free-zone':U
          p-unrv-code = 'out-zone':U
          p-need-rsrv = true
          p-need-unrv = true
        .
        if ( p-create-part = true
             and
             p-old-return  = true
           )
        or p-is-hold = true
        then do:
          assign
            p-need-unrv = false
          .
        end.
      end.
      when 'rs':U
      then do:
        assign
          p-rsrv-code = 'free-zone':U
          p-unrv-code = 'out-zone':U
          p-need-rsrv = true
          p-need-unrv = true
        .
        if  p-create-part = true
        and p-old-return  = true
        then do:
          assign
            p-need-unrv = false
          .
        end.
      end.
      when 'we':U
      then do:
        assign
          p-rsrv-code = 'out-zone':U
          p-unrv-code = 'free-zone':U
          p-need-rsrv = true
          p-need-unrv = true
        .
      end.
      when 'vt':U              or
      when 'mp':U or
      when 'vp':U         then do:
        if p-parts-fact-qnty >= 0
        then do:
          assign
            p-rsrv-code = 'free-zone':U
            p-unrv-code = 'out-zone':U
            p-need-rsrv = true
            p-need-unrv = true
          .
          if  p-create-part = true
          and p-old-return  = true
          then do:
            assign
              p-need-unrv = false
            .
          end.
        end.
        else do:
          assign
            p-rsrv-sign = 1
            p-unrv-sign = -1
          .
          assign
            p-rsrv-code = 'out-zone':U
            p-unrv-code = 'free-zone':U
            p-need-rsrv = true
            p-need-unrv = true
          .
        end.
      end.
      when 'ap':U or
      when 'pc':U
      then do:
        if p-parts-fact-qnty >= 0
        then do:
          assign
            p-rsrv-code = 'free-zone':U
            p-unrv-code = 'out-zone':U
            p-need-rsrv = true
            p-need-unrv = false
          .
        end.
        else do:
          assign
            p-rsrv-sign = 1
            p-unrv-sign = -1
          .
          assign
            p-rsrv-code = 'out-zone':U
            p-unrv-code = 'free-zone':U
            p-need-rsrv = false
            p-need-unrv = true
          .
        end.
      end.
      when 'iv':U
      then do:
        assign
          p-rsrv-code = 'free-zone':U
          p-unrv-code = 'out-zone':U
          p-need-rsrv = true
          p-need-unrv = false
        .
      end.
      when 'ev':U
      then do:
        assign
          p-rsrv-code = 'out-zone':U
          p-unrv-code = 'free-zone':U
          p-need-rsrv = true
          p-need-unrv = true
        .
      end.
      when 'io':U
      then do:
        assign
          p-rsrv-code = 'free-zone':U
          p-unrv-code = 'out-zone':U
          p-need-rsrv = true
          p-need-unrv = false
        .
      end.
      when 'eo':U
      then do:
        assign
          p-rsrv-code = 'out-zone':U
          p-unrv-code = 'free-zone':U
          p-need-rsrv = true
          p-need-unrv = true
        .
      end.
      when 'rv':U
      then do:
        assign
          p-rsrv-code = 'free-zone':U
          p-unrv-code = 'out-zone':U
          p-need-rsrv = true
          p-need-unrv = true
        .
      end.
      when 'em':U or
      when 'wm':U
      then do:
        assign
          p-rsrv-code = 'out-zone':U
          p-unrv-code = 'free-zone':U
          p-need-rsrv = true
          p-need-unrv = true
        .
      end.
      when 'im':U
      then do:
        assign
          p-rsrv-code = 'free-zone':U
          p-unrv-code = 'out-zone':U
          p-need-rsrv = true
          p-need-unrv = false
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестный тип документа" skip
          "Тип документа" p-ext-doc-type skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .
    if p-rsrv-code = p-unrv-code
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Внутренняя ошибка" skip
        "p-rsrv-code" p-rsrv-code skip
        "p-unrv-code" p-unrv-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure partparm :
  define input  parameter p-parts-recid as recid     no-undo .
  define output parameter p-create-part as logical   no-undo .
  define output parameter p-old-return  as logical   no-undo .
  define output parameter p-create-obj  as logical   no-undo .
  define variable vss-description as character no-undo init "partparm-01: определяет тип партии".
  define buffer buf_parts for ub.parts .
  do
  on error undo, return error return-value
  :
    find first buf_parts no-lock
      where recid(buf_parts) = p-parts-recid
      no-error .
    if not available buf_parts
    then do:
      undo, return error substitute("Не найдена партия с кодом &1", p-parts-recid) .
    end.
    if  buf_parts.supp-type = buf_parts.obj-type
    and buf_parts.supp-code = buf_parts.obj-code
    then do:
      assign
        p-create-obj = true
      .
    end.
    else do:
      assign
        p-create-obj = false
      .
    end.
    assign
      p-old-return = false
    .
    if buf_parts.in-code = buf_parts.out-code
    then do:
      assign
        p-create-part = true
      .
      if p-create-obj = true
      then do:
        assign
          p-old-return = false
        .
      end.
      else do:
        assign
          p-old-return = true
        .
      end.
    end.
    else do:
      assign
        p-create-part = false
      .
    end.
  end.
end procedure.
procedure hold-doc :
  define input  parameter pardoc-code as character no-undo .
  define output parameter paris-hold  as logical   no-undo .
  define buffer buf_trn-doc for ub.trn-doc.
  define variable vss-description as character no-undo init "hold-doc-01: определяет тип документа - холдинговый или нет".
  do
  for buf_trn-doc
  on error undo, return error substitute ("&1 &2", return-value, error-status:get-message(1))
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = pardoc-code
      no-error .
    if not available buf_trn-doc
    then do:
      undo, return error substitute ("Не найден документ с номером &1.", pardoc-code).
    end.
    if  ( buf_trn-doc.ext-doc-type = 'ie':U
          or buf_trn-doc.ext-doc-type = 'ee':U
          or buf_trn-doc.ext-doc-type = 'ep':U
          or buf_trn-doc.ext-doc-type = 're':U
        )
    and ( ( buf_trn-doc.hold-doc-code-child  <> ""
            and buf_trn-doc.hold-doc-code-child  <> "no-hold":u
          )
          or
          ( buf_trn-doc.hold-doc-code-parent <> ""
            and buf_trn-doc.hold-doc-code-parent <> "no-hold":u
          )
        )
    then do:
      assign
        paris-hold = yes
      .
    end.
    else do:
      assign
        paris-hold = no
      .
    end.
  end.
end procedure.
procedure docextnm :
  define input  parameter p-doc-code as character no-undo .
  define output parameter p-ext-name as character no-undo .
  define variable vss-description as character no-undo init "docextnm-01: определяет короткое имя документа для показа в интерфейсах".
  define variable v-is-hold as logical   no-undo .
  define buffer buf_trn-doc for ub.trn-doc .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if available buf_trn-doc
    then do:
define variable vss-include-info94 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  p-doc-code
  ,output v-is-hold
  )  .
      case buf_trn-doc.ext-doc-type
      :
        when 'ie':U
        then do:
          if v-is-hold = false
          then do:
            assign
              p-ext-name = "ПН"
            .
          end.
          else do:
            assign
              p-ext-name = "ПФ"
            .
          end.
        end.
        when 'ee':U
        then do:
          if v-is-hold = false
          then do:
            assign
              p-ext-name = "РН"
            .
          end.
          else do:
            assign
              p-ext-name = "РФ"
            .
          end.
        end.
        when 'ep':U
        then do:
          if v-is-hold = false
          then do:
            assign
              p-ext-name = "РЩ"
            .
          end.
          else do:
            assign
              p-ext-name = "РЖ"
            .
          end.
        end.
        when 'es':U
        then do:
          assign
            p-ext-name = "РК"
          .
        end.
        when 're':U
        then do:
          if v-is-hold = false
          then do:
            assign
              p-ext-name = "ВН"
            .
          end.
          else do:
            assign
              p-ext-name = "ВФ"
            .
          end.
        end.
        when 'rs':U
        then do:
          assign
            p-ext-name = "ВК"
          .
        end.
        when 'we':U
        then do:
          assign
            p-ext-name = "СН"
          .
        end.
        when 'vt':U
        then do:
          assign
            p-ext-name = "ИН"
          .
        end.
        when 'vp':U
        then do:
          assign
            p-ext-name = "ПС"
          .
        end.
        when 'iv':U
        then do:
          assign
            p-ext-name = "ПВ"
          .
        end.
        when 'ev':U
        then do:
          assign
            p-ext-name = "РВ"
          .
        end.
        when 'io':U
        then do:
          assign
            p-ext-name = "ПО"
          .
        end.
        when 'eo':U
        then do:
          assign
            p-ext-name = "РО"
          .
        end.
        when 'rv':U
        then do:
          assign
            p-ext-name = "ВВ"
          .
        end.
        when 'em':U
        then do:
          assign
            p-ext-name = "РП"
          .
        end.
        when 'wm':U
        then do:
          assign
            p-ext-name = "СП"
          .
        end.
        when 'im':U
        then do:
          assign
            p-ext-name = "ПП"
          .
        end.
        when 'ap':U
        then do:
          assign
            p-ext-name = "ИЦ"
          .
        end.
        when 'mp':U
        then do:
          assign
            p-ext-name = "ИМ"
          .
        end.
        when 'pc':U
        then do:
          assign
            p-ext-name = "ИТ"
          .
        end.
        otherwise do:
          assign
            p-ext-name = buf_trn-doc.ext-doc-type
          .
        end.
      end case .
    end.
    else do:
      assign
        p-ext-name = "??"
      .
    end.
  end.
end procedure.
procedure fgdsobjt :
  define input  parameter p-obj-type         like ub.fbr-gds-obj.obj-type  no-undo .
  define input  parameter p-obj-code         like ub.fbr-gds-obj.obj-code  no-undo .
  define input  parameter p-gds-code         like ub.fbr-gds-obj.gds-code  no-undo .
  define input  parameter p-action           as character no-undo .
  define output parameter p-return-attribute as character no-undo .
  define variable vss-description as character no-undo initial "fgdsobjt-01: задает/получает признаки товара на объекте РЕСТОРАН".
  define variable ind      as integer no-undo .
  define variable v-action as character no-undo .
  define variable l-find-fbr-gds-obj as logical no-undo initial false .
  define buffer buf_fbr-gds-obj for ub.fbr-gds-obj .
  define variable v-num-entries-p-action as integer no-undo .
  assign
    v-num-entries-p-action = num-entries(p-action)
  .
  do ind = 1 to v-num-entries-p-action
  :
    assign
      v-action = entry(ind, p-action)
    .
    if lookup(entry(1, v-action, ":":U), "is-menu=request,is-semi-finished=request,is-dish=request,is-modificator=request,is-modificator-null-price=request,exist-fbr-gds-obj=request") > 0
    then do:
      find first buf_fbr-gds-obj no-lock
        where buf_fbr-gds-obj.obj-type  = p-obj-type
          and buf_fbr-gds-obj.obj-code  = p-obj-code
          and buf_fbr-gds-obj.gds-code  = p-gds-code
        no-error .
    end.
    if not available buf_fbr-gds-obj then return string(0).
    if num-entries(v-action, ":":U) > 1
    then do:
      if entry(2, v-action, ":":U) = "exclusive-lock":U
      then do:
        find current buf_fbr-gds-obj exclusive-lock .
      end.
      if entry(2, v-action, ":":U) = "share":U
      then do:
        find current buf_fbr-gds-obj share-lock .
      end.
    end.
    case entry(1, v-action, "=request":U) :
      when "exist-fbr-gds-obj":U
      then do:
        assign
        p-return-attribute = p-return-attribute + (if p-return-attribute = '':U then '':U else chr(44))
                             + if (available buf_fbr-gds-obj) then string(1) else string(0)
        .
      end.
      when "is-menu":U
      then do:
        assign
          p-return-attribute = p-return-attribute + (if p-return-attribute = '':U then '':U else chr(44))
                               + if buf_fbr-gds-obj.is-menu then string(1) else string(0)
        .
      end.
      when "is-semi-finished":U
      then do:
        assign
        p-return-attribute = p-return-attribute + (if p-return-attribute = '':U then '':U else chr(44))
                             + if buf_fbr-gds-obj.is-semi-finished then string(1) else string(0)
        .
      end.
      when "is-dish":U
      then do:
        assign
        p-return-attribute = p-return-attribute + (if p-return-attribute = '':U then '':U else chr(44))
                             + string(if buf_fbr-gds-obj.is-menu then 1 else 0 +
                                    if buf_fbr-gds-obj.is-semi-finished then 2 else 0 )
        .
      end.
      when "is-modificator-null-price":U
      then do:
        assign
        p-return-attribute = p-return-attribute + (if p-return-attribute = '':U then '':U else chr(44))
                             + string(if buf_fbr-gds-obj.is-modificator
                                    and buf_fbr-gds-obj.is-null-price
                                    then 1
                                    else 0)
        .
      end.
      when "is-modificator":U
      then do:
        assign
        p-return-attribute = p-return-attribute + (if p-return-attribute = '':U then '':U else chr(44))
                             + string(if buf_fbr-gds-obj.is-modificator
                                    then 1
                                    else 0)
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестное значение параметра v-action " skip
          "v-action" v-action skip
          "p-action" p-action skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.
end procedure.
procedure cntpurch :
  define input  parameter p-contract-type as character no-undo .
  define output parameter p-purch-code    as integer   no-undo .
  define variable vss-description as character no-undo initial "cntpurch-01: Определить тип приобретения по типу контракта".
  do
  on error undo, return error return-value
  :
    if p-contract-type = ""
    or p-contract-type = ?
    then do:
      undo, return error vss-description + "Не задан тип договора"
        .
    end.
    if lookup(p-contract-type, 'Купли-продажи,Консигнации,Ответственного хранения,Агентский договор,Давальческого сырья,Продажи через ТПСИ,о Дополнительных расходах':U) = 0
    then do:
      undo, return error vss-description + "Неизвестный тип договора" + chr(10)
        + substitute("Тип договора &1", p-contract-type)
        .
    end.
    if lookup(p-contract-type, 'Купли-продажи,Агентский договор,Давальческого сырья,Продажи через ТПСИ':U) > 0
    then do:
      assign
        p-purch-code = 1
      .
    end.
    else do:
      if lookup(p-contract-type, 'Консигнации':U) > 0
      then do:
        assign
          p-purch-code = 2
        .
      end.
      else do:
        if lookup(p-contract-type, 'Ответственного хранения':U) > 0
        then do:
          assign
            p-purch-code = 3
          .
        end.
        else do:
          undo, return error vss-description + "Ошибка при определении типа приобретения на основе типа договора" + chr(10)
            + substitute("Тип договора &1", p-contract-type)
            .
        end.
      end.
    end.
  end.
end procedure.
procedure purchnam :
  define input  parameter p-purch-code as integer   no-undo .
  define output parameter p-purch-name as character no-undo .
  define variable vss-description as character no-undo initial "purchnam-01: Определить название типа приобретения по коду типа приобретения".
  define variable v-purch-code-index as integer   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-purch-code-index = lookup(string(p-purch-code), '1,2,3,4':U )
    .
    if v-purch-code-index = ?
    then do:
      undo, return error vss-description + chr(10)
        + "Тип приобретения имеет неопределённое значение" .
    end.
    if v-purch-code-index > 0
    then do:
      assign
        p-purch-name = entry(v-purch-code-index, 'выкуп,консигнация,ответственное хранение,старая консигнация':U)
      .
    end.
    else do:
      undo, return error vss-description + chr(10)
        + substitute("Неизвестный тип приобретения &1", p-purch-code) .
    end.
  end.
end procedure.
procedure xmlbegin :
  define input  parameter p-file-name    as character no-undo .
  define input  parameter p-option-string as character no-undo .
  define variable vss-description as character no-undo initial "xmlbegin-01: Начать создание xml файла".
  do
  on error undo, return error return-value
  :
    output stream librout to value(p-file-name) .
    put stream librout unformatted
      substitute("<?xml version='1.0' &1?>":u, p-option-string) + chr(10)
      + "<root>":u + chr(10)
      .
    output stream librout close .
  end.
end procedure.
procedure xmlend :
  define input  parameter p-file-name as character no-undo .
  define variable vss-description as character no-undo initial "xmlend-01: Завершить создание xml файла".
  do
  on error undo, return error return-value
  :
    output stream librout to value(p-file-name) append .
    put stream librout unformatted
      "</root>":u + chr(10)
      .
    output stream librout close .
  end.
end procedure.
procedure cutd-obj :
  define input  parameter p-obj-type     as character no-undo .
  define input  parameter p-obj-code     as integer   no-undo .
  define output parameter p-status       as integer   no-undo .
  define output parameter p-cut-date     as date      no-undo .
  define output parameter p-cut-fin-date as date      no-undo .
  do
  on error undo, return error substitute( "&1 (cutd-obj). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  :
    define buffer buf_clients for ub.clients .
    find first buf_clients no-lock
      where buf_clients.obj-type = p-obj-type
        and buf_clients.obj-code = p-obj-code
      no-error .
    if not available buf_clients
    then do:
      undo, return error substitute( "&1 (cutd-obj). Объект &2 &3 не найден!", vss-workfile, p-obj-type, p-obj-code ) .
    end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cutd-db in g#library
  (input  buf_clients.db-num
  ,output p-status
  ,output p-cut-date
  ,output p-cut-fin-date
  ) no-error .
    if error-status :error
    then do:
      undo, return error substitute( "&1 (cutd-obj). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ).
    end.
  end.
  return.
end procedure.
procedure cutd-db :
  define input  parameter p-db-num       as integer   no-undo .
  define output parameter p-status       as integer   no-undo .
  define output parameter p-cut-date     as date      no-undo .
  define output parameter p-cut-fin-date as date      no-undo .
  do
  on error undo, return error substitute( "&1 (cutd-db). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  :
    define variable v-attr-exist as logical   no-undo .
    define variable v-attr-value as character no-undo .
    define variable v-attr-type  as character no-undo .
    define buffer buf_sys-ctrl for ub.sys-ctrl .
    assign
      p-cut-date = ?
      p-status   = ?
    .
    run db-attr-exist ( input p-db-num
                       ,input 'cut-date':U
                       ,output v-attr-exist
                      ) no-error.
    if error-status :error
    then do:
      undo, return error substitute( "&1 (cutd-db). Ошибка при определении наличия атрибута 'дата обрезания складских документов' для БД &2 &3&4&5", vss-workfile, p-db-num, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ).
    end.
    if v-attr-exist = true then do:
      run db-attr-value ( input p-db-num
                         ,input 'cut-date':U
                         ,output v-attr-value
                         ,output v-attr-type
                        ) no-error.
      if error-status :error
      then do:
        undo, return error substitute( "&1 (cutd-db). Ошибка при чтении значения атрибута 'дата обрезания складских документов' для БД &2 &3&4&5", vss-workfile, p-db-num, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ).
      end.
      if v-attr-value = "":U
        or v-attr-value = ?
      then do:
        undo, return error substitute( "&1 (cutd-db). Атрибут 'дата обрезания складских документов' для БД &2 имеет некорректное значение '&3'", vss-workfile, p-db-num, v-attr-value ).
      end.
      else do:
        assign
          p-cut-date = date( v-attr-value )
        .
        run db-attr-exist ( input p-db-num
                           ,input 'unload-after-cut':U
                           ,output v-attr-exist
                          ) no-error.
        if error-status :error
        then do:
          undo, return error substitute( "&1 (cutd-db). Ошибка при определении наличия атрибута 'выгрузка после обрезания' для БД &2 &3&4&5", vss-workfile, p-db-num, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ).
        end.
        run db-attr-value ( input p-db-num
                           ,input 'unload-after-cut':U
                           ,output v-attr-value
                           ,output v-attr-type
                          ) no-error.
        if error-status :error
        then do:
          undo, return error substitute( "&1 (cutd-db). Ошибка при чтении значения атрибута 'выгрузка после обрезани ' для БД &2 &3&4&5", vss-workfile, p-db-num, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ).
        end.
        if v-attr-exist = true
          and v-attr-value = "yes":U
        then do:
          assign
            p-status = 4
          .
        end.
        else do:
          assign
            p-status = 3
          .
        end.
      end.
    end.
    else do:
      find first buf_sys-ctrl no-lock .
      if buf_sys-ctrl.cut-date <> ? then do:
        assign
          p-cut-date = buf_sys-ctrl.cut-date
          p-status   = 2
        .
      end.
      else do:
        assign
          p-cut-date = buf_sys-ctrl.cut-date
          p-status   = 1
        .
      end.
    end.
    run db-attr-exist ( input p-db-num
                      ,input 'cut-fin-date':U
                      ,output v-attr-exist
                      ) no-error.
    if error-status :error
    then do:
      undo, return error substitute( "&1 (cutd-db). Ошибка при определении наличия атрибута 'дата обрезания финансовых документов' для БД &2 &3&4&5", vss-workfile, p-db-num, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ).
    end.
    if v-attr-exist = true then do:
      run db-attr-value ( input p-db-num
                        ,input 'cut-fin-date':U
                        ,output v-attr-value
                        ,output v-attr-type
                        ) no-error.
      if error-status :error
      then do:
        undo, return error substitute( "&1 (cutd-db). Ошибка при чтении значения атрибута 'дата обрезания финансовых документов' для БД &2 &3&4&5", vss-workfile, p-db-num, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ).
      end.
      if v-attr-value = "":U
        or v-attr-value = ?
      then do:
        undo, return error substitute( "&1 (cutd-db). Атрибут 'дата обрезания финансовых документов' для БД &2 имеет некорректное значение '&3'", vss-workfile, p-db-num, v-attr-value ).
      end.
      else do:
        assign
          p-cut-fin-date = date( v-attr-value )
        .
      end.
    end.
    else do:
      assign
        p-cut-fin-date = ?
      .
    end.
  end.
  return.
end procedure.
procedure gdsobjpr :
  do
  on error undo, return error substitute( "&1 (gdsobjpr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  :
  define input  parameter p-obj-type                    like ub.gds-obj.obj-type  no-undo .
  define input  parameter p-obj-code                    like ub.gds-obj.obj-code  no-undo .
  define input  parameter p-artic                       like ub.gds-obj.artic     no-undo .
  define input  parameter p-prod-type                   like ub.gds-obj.prod-type no-undo .
  define input  parameter p-prod-code                   like ub.gds-obj.prod-code no-undo .
  define input  parameter p-gds-code                    like ub.gds-obj.gds-code no-undo .
  define output parameter p-amin                        as logical no-undo .
  define output parameter p-izt                         as character no-undo .
  define output parameter p-gdop-min-stock              as decimal   no-undo .
  define output parameter p-grop-max-stock              as decimal   no-undo .
  define output parameter p-grop-level-always-presence  as decimal   no-undo .
  define output parameter p-grop-min-order              as decimal   no-undo .
define buffer buf_goods for  ub.goods .
define buffer buf_gds-obj-prop for  ub.gds-obj-prop .
if p-gds-code = ? or p-gds-code = 0  then do:
   find first buf_goods no-lock where
        buf_goods.artic      = p-artic     and
        buf_goods.prod-type  = p-prod-type and
        buf_goods.prod-code  = p-prod-code no-error .
        if error-status :error
        then do:
          undo, return error substitute( "Ошибка при определении товара &1 &2 &3 &4",
          p-artic   ,
          p-prod-type,
          p-prod-code ,
          error-status :get-message (1) ).
        end.
   p-gds-code = buf_goods.gds-code.
end.
find first buf_gds-obj-prop no-lock where
           buf_gds-obj-prop.gds-code = p-gds-code and
           buf_gds-obj-prop.obj-type = p-obj-type and
           buf_gds-obj-prop.obj-code = p-obj-code no-error .
           if available buf_gds-obj-prop
           then do:
              assign
                p-amin = buf_gds-obj-prop.gdop-assort-min
                p-izt  = buf_gds-obj-prop.gdop-igt
                p-gdop-min-stock               = buf_gds-obj-prop.gdop-min-stock
                p-grop-max-stock               = buf_gds-obj-prop.grop-max-stock
                p-grop-level-always-presence   = buf_gds-obj-prop.grop-level-always-presence
                p-grop-min-order               = buf_gds-obj-prop.grop-min-order
              .
           end.
           else do:
              assign
                p-amin = false
                p-izt  = 'Пусто':U
                p-gdop-min-stock               = 0
                p-grop-max-stock               = 0
                p-grop-level-always-presence   = 0
                p-grop-min-order               = 0
              .
           end.
end.
end procedure.
procedure glstmain :
define output parameter p-main-price-list as logical   no-undo .
define buffer buf_global-state for ub.global-state  .
  do
  on error undo, return error return-value
  :
 find first  buf_global-state no-lock no-error .
 if not available buf_global-state then create buf_global-state.
    assign
        p-main-price-list  = false
    .
if  logical(buf_global-state.db-num-chg)   = true  and
    buf_global-state.pl-use-grp-buy        = false and
    buf_global-state.pl-use-oborot-buy     = false and
    buf_global-state.pl-use-qnty-group     = false and
    buf_global-state.pl-use-sum-group      = false and
    buf_global-state.pl-use-sys-date-time  = false and
    buf_global-state.pl-use-shift-date-num = false and
    buf_global-state.pl-use-cassa          = false and
    buf_global-state.pl-use-val            = false and
    buf_global-state.pl-use-pay-type       = false and
    buf_global-state.pl-use-child          = false and
    buf_global-state.pl-use-cash-pay       = false
    then do:
      p-main-price-list  = true  .
    end.
  end.
end procedure.
procedure glstall :
define output parameter p-use-grp-buy          as logical   no-undo .
define output parameter p-use-oborot-buy       as logical   no-undo .
define output parameter p-use-qnty-group       as logical   no-undo .
define output parameter p-use-sum-group        as logical   no-undo .
define output parameter p-use-add-code         as logical   no-undo .
define output parameter p-use-sys-date-time    as logical   no-undo .
define output parameter p-use-shift-date-num   as logical   no-undo .
define output parameter p-use-cassa            as logical   no-undo .
define output parameter p-use-val              as logical   no-undo .
define output parameter p-use-pay-type         as logical   no-undo .
define output parameter p-use-cash-pay         as logical   no-undo .
define output parameter p-use-child            as logical   no-undo .
define buffer buf_global-state for ub.global-state  .
  do
  on error undo, return error return-value
  :
 find first  buf_global-state no-lock no-error .
 if error-status :error then do:
   return error "Не заданы Глобальные настройки ценообразования !!!".
 end.
  assign
    p-use-grp-buy          =  buf_global-state.pl-use-grp-buy
    p-use-oborot-buy       =  buf_global-state.pl-use-oborot-buy
    p-use-qnty-group       =  buf_global-state.pl-use-qnty-group
    p-use-sum-group        =  buf_global-state.pl-use-sum-group
    p-use-add-code         =  buf_global-state.pl-use-add-code
    p-use-sys-date-time    =  buf_global-state.pl-use-sys-date-time
    p-use-shift-date-num   =  buf_global-state.pl-use-shift-date-num
    p-use-cassa            =  buf_global-state.pl-use-cassa
    p-use-val              =  buf_global-state.pl-use-val
    p-use-pay-type         =  buf_global-state.pl-use-pay-type
    p-use-cash-pay         =  buf_global-state.pl-use-cash-pay
    p-use-child            =  buf_global-state.pl-use-child
  .
 end.
 end procedure.
procedure proprice :
define input  parameter p-b-code          as integer   no-undo .
define input  parameter p-obj-type        as character no-undo .
define input  parameter p-obj-code        as integer   no-undo .
define output parameter p-price           as decimal   no-undo .
define output parameter p-priceWithVat    as decimal   no-undo .
define output parameter p-vat-pc          as decimal   no-undo .
define output parameter p-part-code as character no-undo .
define output parameter p-in-code   as character no-undo .
define buffer buf_bar-code for ub.bar-code  .
define buffer buf_goods for ub.goods  .
define buffer buf_parts for ub.parts  .
define variable v-artic       as character no-undo .
define variable v-prod-type as character no-undo .
define variable v-prod-code as integer   no-undo .
define variable v-doc-code as character no-undo .
   do
   on error undo, return error return-value
   :
   assign
    p-price = 0
    p-priceWithVat = 0
    p-vat-pc       = 0
   .
 find first buf_bar-code no-lock where
            buf_bar-code.b-code = p-b-code no-error .
    if error-status :error then do:
      return error error-status :get-message(1) .
    end.
define variable vss-include-info95 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run arptpc in g#library
  (input  buf_bar-code.gds-code
  ,output v-artic
  ,output v-prod-type
  ,output v-prod-code
  )  .
    find first ub.gds-obj no-lock where
      ub.gds-obj.gds-code = buf_bar-code.gds-code and
      ub.gds-obj.obj-code = p-obj-code and
      ub.gds-obj.obj-type = p-obj-type
      no-error .
    if available ub.gds-obj then do:
      v-doc-code = ub.gds-obj.in-code .
    end.
    if buf_bar-code.in-code <> "" then do:
       find first buf_parts no-lock where
                  buf_parts.in-code   = buf_bar-code.in-code  and
                  buf_parts.part-code = buf_bar-code.part-code  and
                  buf_parts.out-code  = 'free-zone':U  and
                  buf_parts.status_   = false   and
                  buf_parts.rsrv-free = true    and
                  buf_parts.artic     = v-artic and
                  buf_parts.prod-type = v-prod-type and
                  buf_parts.prod-code = v-prod-code  no-error .
                      if available buf_parts then do:
define variable vss-include-info96 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run partppric in g#library
(  buffer buf_parts
 , output p-price
 , output p-priceWithVat
 , output p-vat-pc
        )  .
                         p-part-code = buf_parts.part-code.
                         p-in-code   = buf_parts.in-code  .
                      end.
                      if not available buf_parts or buf_parts.dop = "" then do:
                      find last buf_parts no-lock where
                            buf_parts.obj-type  = p-obj-type  and
                            buf_parts.obj-code  = p-obj-code  and
                            buf_parts.artic     = v-artic and
                            buf_parts.prod-type = v-prod-type and
                            buf_parts.prod-code = v-prod-code  and
                            buf_parts.out-code  = 'free-zone':U  and
                            buf_parts.status_   = false   and
                            buf_parts.rsrv-free = true    and
                            buf_parts.dop <> "" and
                            buf_parts.dop <> "0;0" and
                            buf_parts.dop <> "0"
                            no-error .
                            if available buf_parts then do:
define variable vss-include-info97 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run partppric in g#library
(  buffer buf_parts
 , output p-price
 , output p-priceWithVat
 , output p-vat-pc
        )  .
                              p-part-code = buf_parts.part-code.
                              p-in-code   = buf_parts.in-code  .
                            end.
                            else do:
                              find last buf_parts no-lock where
                                    buf_parts.obj-type  = p-obj-type  and
                                    buf_parts.obj-code  = p-obj-code  and
                                    buf_parts.artic     = v-artic and
                                    buf_parts.prod-type = v-prod-type and
                                    buf_parts.prod-code = v-prod-code  and
                                    buf_parts.out-code  = 'free-zone':U  and
                                    buf_parts.status_   = false   and
                                    buf_parts.rsrv-free = true
                                    no-error .
                                    if not available buf_parts then do:
                                        find last buf_parts no-lock where
                                                  buf_parts.obj-type  = p-obj-type  and
                                                  buf_parts.obj-code  = p-obj-code  and
                                                  buf_parts.artic     = v-artic and
                                                  buf_parts.prod-type = v-prod-type and
                                                  buf_parts.prod-code = v-prod-code  and
                                                  buf_parts.out-code  = v-doc-code and
                                                  buf_parts.dop <> ""  and
                                                  buf_parts.dop <> "0;0"  and
                                                  buf_parts.dop <> "0"
                                                  no-error .
                                                      if available buf_parts then do:
define variable vss-include-info98 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run partppric in g#library
(  buffer buf_parts
 , output p-price
 , output p-priceWithVat
 , output p-vat-pc
        )  .
                                                          p-part-code = buf_parts.part-code.
                                                          p-in-code   = buf_parts.in-code  .
                                                      end.
                                    end.
                            end.
                      end.
    end.
    else do:
       find last buf_parts no-lock where
                  buf_parts.obj-type  = p-obj-type  and
                  buf_parts.obj-code  = p-obj-code  and
                  buf_parts.artic     = v-artic and
                  buf_parts.prod-type = v-prod-type and
                  buf_parts.prod-code = v-prod-code  and
                  buf_parts.out-code  = 'free-zone':U  and
                  buf_parts.status_   = false   and
                  buf_parts.rsrv-free = true    and
                  buf_parts.dop <> ""  and
                  buf_parts.dop <> "0;0"  and
                  buf_parts.dop <> "0"
                  no-error .
                      if available buf_parts then do:
define variable vss-include-info99 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run partppric in g#library
(  buffer buf_parts
 , output p-price
 , output p-priceWithVat
 , output p-vat-pc
        )  .
                         p-part-code = buf_parts.part-code.
                         p-in-code   = buf_parts.in-code  .
                      end.
                      else do:
                        find last buf_parts no-lock where
                                  buf_parts.obj-type  = p-obj-type  and
                                  buf_parts.obj-code  = p-obj-code  and
                                  buf_parts.artic     = v-artic and
                                  buf_parts.prod-type = v-prod-type and
                                  buf_parts.prod-code = v-prod-code  and
                                  buf_parts.out-code  = v-doc-code and
                                  buf_parts.dop <> ""  and
                                  buf_parts.dop <> "0;0"  and
                                  buf_parts.dop <> "0"
                                  no-error .
                                      if available buf_parts then do:
define variable vss-include-info100 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run partppric in g#library
(  buffer buf_parts
 , output p-price
 , output p-priceWithVat
 , output p-vat-pc
        )  .
                                          p-part-code = buf_parts.part-code.
                                          p-in-code   = buf_parts.in-code  .
                                      end.
                      end.
    end.
   end.
end procedure.
procedure partppric :
define parameter buffer buf_parts for ub.parts .
define output parameter p-price           as decimal   no-undo .
define output parameter p-priceWithVat    as decimal   no-undo .
define output parameter p-vat-pc          as decimal   no-undo .
  do
  on error undo, return error return-value
  :
   p-price        = decimal(entry(1,buf_parts.dop,";")) / buf_parts.cli-base-rate.
   p-priceWithVat = decimal(entry(2,buf_parts.dop,";")) / buf_parts.cli-base-rate no-error .
   if error-status :error then do:
      p-priceWithVat = 0 .
   end.
   if p-priceWithVat = 0 then do:
     p-vat-pc       = 0 .
   end.
   else do:
      p-vat-pc       = 100 * ( p-priceWithVat - p-price ) / p-price .
   end.
  end.
end procedure.
procedure calltree :
define input parameter p-proc-name as character no-undo .
define input parameter p-from-handle as handle no-undo .
define input parameter p-find-up-to-handle as handle no-undo .
define output parameter p-proc-handle as handle no-undo .
define variable v-uh as handle no-undo .
define variable v-uh1 as handle no-undo .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if not valid-handle(p-from-handle) then do:
    undo, return error substitute("Не указан handle procedure, от которой начинается поиск").
  end.
  if p-from-handle:persistent then do:
    if p-proc-name <> "mainhandle_parentproc_indicator" then do:
      message
      vss-workfile vss-revision vss-description skip
      substitute("НЕ разрешено вызывать процедуру из персистентной процедуры (&1)", p-from-handle:name)
      view-as alert-box error .
      undo, return error .
    end.
    v-uh = session:first-procedure no-error .
    do while valid-handle(v-uh):
      v-uh1 = v-uh:instantiating-procedure.
      if valid-handle(v-uh1)
      and v-uh1:type = "PROCEDURE"
      and lookup(p-proc-name, v-uh1:internal-entries) > 0 then do:
        p-proc-handle = v-uh1 .
        leave.
      end.
      v-uh = v-uh:next-sibling no-error .
    end.
  end.
  v-uh = p-from-handle:instantiating-procedure.
  do while valid-handle(v-uh):
    if lookup(p-proc-name, v-uh:internal-entries) > 0 then do:
      p-proc-handle = v-uh .
      leave.
    end.
    if valid-handle(p-find-up-to-handle) and  v-uh = p-find-up-to-handle then do:
      leave.
    end.
    v-uh = v-uh:instantiating-procedure.
  end.
end.
end procedure.
procedure regcode :
do
on error undo, return error return-value
:
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define output parameter p-reg-code  as integer   no-undo .
  define variable vss-description as character no-undo initial "regcode-01: код региона для БД".
  define variable v-db-attr-type  as character no-undo.
  define buffer buf_db   for ub.db .
  case p-obj-type :
    when 'БД':U
    then do:
      find first buf_db no-lock
        where buf_db.db-num = p-obj-code
        no-error .
      if not available buf_db
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найдена БД" skip
          "p-obj-type" p-obj-type skip
          "p-obj-code" p-obj-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      run db-attr-value in this-procedure (buf_db.db-num,
                                           "reg-code",
                                           output p-reg-code,
                                           output v-db-attr-type) no-error.
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Неизвестный тип объекта" skip
        "p-obj-type" p-obj-type skip
        "p-obj-code" p-obj-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
  assign
    l-last-regcode-exist     = true
    v-last-regcode-obj-type  = p-obj-type
    v-last-regcode-obj-code  = p-obj-code
    v-last-regcode-reg-code  = p-reg-code
  .
end.
end procedure.
define variable vss-include-info101 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
Function reverse returns character (str as character).
   define variable rev_incl_s as character init "" no-undo .
   define variable rev_incl_i as integer no-undo .
   define variable rev_incl_l as integer no-undo .
   rev_incl_l = length(str).
   do rev_incl_i = 1 to rev_incl_l:
      rev_incl_s = rev_incl_s + substr(str,rev_incl_l - rev_incl_i + 1,1).
   end.
   return rev_incl_s.
end.
procedure check-enc.
  define input  parameter p-db-num    as integer   no-undo .
  define input  parameter p-db-key    as character no-undo .
  define input  parameter p-code      as character no-undo .
  define input  parameter p-value     as character no-undo .
  define input  parameter p-beg-date  as date      no-undo .
  define input  parameter p-end-date  as date      no-undo .
  define input  parameter p-enc-value as character no-undo .
  define output parameter p-answer    as logical   no-undo .
  define variable tmp         as character no-undo .
  define variable v-enc-value as character no-undo .
  if p-db-num <> 0
    and p-db-key = "":U
  then do:
    assign
      p-answer = true
    .
    return.
  end.
  if p-db-key = "unload-db":U then do:
    assign
      p-answer = true
    .
    return.
  end.
  if p-code = ""  then do:
    assign
      tmp = string( p-db-num ) + reverse (p-db-key).
    .
  end.
  else do:
    assign
      tmp = string( p-db-num )
            + trim( p-db-key )
            + reverse( trim( p-code ) )
            + reverse( trim( p-value ) )
            + reverse( string( p-beg-date, "99.99.9999" ) )
            + reverse( string( p-end-date, "99.99.9999" ) )
    .
  end.
  run pswd-enc in this-procedure
    ( input tmp
     ,output v-enc-value
    ) no-error .
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры pswd-enc" skip
      return-value skip
      error-status :get-message(1) skip
      view-as alert-box error .
    undo, return error .
  end.
  if v-enc-value = p-enc-value then do:
    assign
      p-answer = true
    .
  end.
  else do:
    assign
      p-answer = false
    .
  end.
end.
define variable vss-include-info102 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure pswd-enc :
  define input parameter  pswd     as character no-undo .
  define output parameter enc-pswd as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      enc-pswd = encode(pswd + string(index(pswd, "k")))
    .
  end.
end procedure.
define variable vss-include-info103 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info104 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info104 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info104, p-tbl-name ).
    end.
    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info104, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info104, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
        .
      end.
    end.
    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info104, p-tbl-name ).
    end.
  end.
  return.
end procedure.
procedure gen-where-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character  no-undo.
  define input  parameter p-key-rec    as character  no-undo.
  define input  parameter p-key-handle as handle     no-undo .
  define input  parameter p-db-name    as character  no-undo .
  define input  parameter p-tt-handle  as handle     no-undo .
  define output parameter o-Where      as character  no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable vTable           as character no-undo.
    define variable bh_tbl-key       as handle    no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do:
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info104 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info104, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info104 ).
      end.
    end.
    assign
      vTable = entry( 1 , p-key-rec, chr(3) )
    .
    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info104, vTable, chr(10) ).
    end.
    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info104, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info104, v-inform, vTable ).
    end.
    assign
      o-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    if i-tablekey ne "" and i-tablekey ne ?
    then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tablekey )
      .
      create buffer bh_tbl-key for table v-full-tbl-name .
    end.
    if i-tableSerach ne "" and i-tableSerach ne ?
    then do:
      delete object bh_tbl-name no-error.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.
      define variable VfieldKeyTable as handle no-undo.
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
      if     bh_tbl-key ne ?
      then do:
         VfieldKeyTable = bh_tbl-key:buffer-field( v-field-name ) no-error.
         if VfieldKeyTable eq ?
         then next block_where.
      end.
      if v-full-tbl-name ne "" and v-full-tbl-name ne ?
      then
         o-where = substitute( "&1 &2 &3.&4 =", o-where, v-word-link,v-full-tbl-name, v-field-name ).
      else
         o-where = substitute( "&1 &2 &3 =", o-where, v-word-link, v-field-name ).
      if p-key-handle = ? then do:
        assign
          v-field-val = replace (entry( v-count-fld + 1 , p-key-rec, chr(3) ),chr(2) + chr(9) + chr (2),chr(3))
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          delete object bh_tbl-name.
          if     bh_tbl-key ne ?
          then
             delete object bh_tbl-key.
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info104, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.
      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        o-where = substitute( "&1 &2", o-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    delete object bh_tbl-name.
    if     bh_tbl-key ne ?
    then
       delete object bh_tbl-key.
    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info104, vTable ).
    end.
  end.
end procedure.
procedure gen-hn-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character no-undo.
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  define variable v-full-tbl-name as character no-undo.
  define variable v-where         as character no-undo.
  define variable bh_tbl-name     as handle    no-undo.
  define variable vTable          as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile ):
      run gen-where-keyr-tab(i-tableSerach,
                             i-tablekey,
                             p-key-rec,
                             p-key-handle,
                             p-db-name,
                             p-tt-handle,
                             output v-where).
      if i-tableSerach ne "" and i-tableSerach ne ?
      then do:
         v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach ).
         create buffer bh_tbl-name for table v-full-tbl-name .
      end.
      else do:
         if p-tt-handle = ? then do:
            assign
               vTable = entry( 1 , p-key-rec, chr(3) )
            .
            v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable ).
            create buffer bh_tbl-name for table v-full-tbl-name .
         end.
         else do:
            create buffer bh_tbl-name for table p-tt-handle:table-handle .
         end.
      end.
      if p-tt-handle = ? then do:
         bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
      end.
      else do:
         bh_tbl-name:find-first( v-where ) no-error .
      end.
      o-hn = bh_tbl-name.
   end.
end procedure.
procedure gen-hn-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output o-hn).
end.
procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  define variable vHn as handle no-undo.
    run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output vHn).
    p-tbl-row = if vHn:available then vHn:rowid else ?.
    p-tbl-name =  vHn:table.
    delete object vHn no-error.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info104, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure.
procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info104 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info104 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info104, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info104, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info104, v-tbl-name ).
    end.
  end.
end procedure.
procedure gen-key-field :
  define input  parameter p-table      as character no-undo .
  define output parameter p-field-list as character no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-table = ?
      or p-table = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info104 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info104 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info104, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info104, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      v-delim-key  = "":U
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U ).
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
  end.
end procedure.
procedure rum-runa :
define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-parent-handle as handle no-undo .
define input  parameter p-log-handle  as handle no-undo .
define input  parameter p-process    as character no-undo .
define input  parameter p-oldbh as handle no-undo .
define input  parameter p-newbh as handle no-undo .
define input  parameter p-changes-list as character no-undo .
define input  parameter p-doc-code-file-name as character no-undo .
define variable v-proc-handle as handle no-undo .
define variable v-proc-name as character no-undo .
define variable v-ruleset-id as integer no-undo .
define variable v-ruleset-id-list as character no-undo extent 3.
define variable v-codex-id as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-jj as integer no-undo .
define variable sign as integer no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-codex-id-list as character no-undo .
define variable v-doc-code as character no-undo .
define variable v-doc-type as character no-undo .
define variable v-process-file-name as character no-undo .
define variable v-cont-handle as handle no-undo .
define variable v-prop-code as character no-undo .
define variable v-curr-r-b as character no-undo .
define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_thbj-attr for ub.thbj-attr.
_main:
do
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:
  if p-log-handle = ? then do:
if (valid-handle(g#lib-log) <> true) then do:   run gbl/lib-log.p persistent no-error .   if error-status :error or (valid-handle(g#lib-log) <> true) then do:     message       "Error starting gbl/lib-log.p" skip       g#lib-log skip       g#lib-log :type skip       g#lib-log :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-log_get-log-handle in g#lib-log
  (output  p-log-handle
  )  .
  end.
  assign
  v-ruleset-id-list[2] = ''
  v-doc-code = substitute("&2&1&3&1&4&1&5"
                          , chr(4)
                          ,entry(1, p-doc-code-file-name, chr(4))
                          ,p-oldbh
                          ,p-newbh
                          ,p-changes-list)
  v-process-file-name =  (if num-entries(p-doc-code-file-name, chr(4)) > 1
                          then entry(2, p-doc-code-file-name, chr(4))
                          else '')
  .
  CASE p-process:
    when 'gdsadd':U
    or
    when 'gdsupdate':U
    or
    when 'rengdscode':U
    then do:
      assign
      v-codex-id-list = string(11)
      v-ruleset-id-list[1] = string(5)
      v-prop-code = 'goods':U
      v-curr-r-b = ?
      .
    end.
    when 'addlcode':U
    or
    when 'dellcode':U
    or
    when 'updatelcode':U
    then do:
      assign
      v-codex-id-list = string(11)
      v-ruleset-id-list[1] = string(6)
      v-prop-code = 'goods':U
      v-curr-r-b = ?
      .
    end.
    when 'addprcode':U
    or
    when 'delprcode':U
    or
    when 'updateprcode':U
    then do:
      assign
      v-codex-id-list = string(11)
      v-ruleset-id-list[1] = string(7)
      v-prop-code = 'goods':U
      v-curr-r-b = ?
      .
    end.
    when 'rest-update':U
    then do:
      assign
      v-codex-id-list = string(11)
      v-ruleset-id-list[1] = string(8)
      v-prop-code = 'goods':U
      .
define variable vss-include-info105 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
    end.
    when 'cliadd':U
    or
    when 'cliupdate':U
    then do:
      assign
      v-codex-id-list = string(12)
      v-ruleset-id-list[1] = string(6)
      v-prop-code = 'clients':U
      v-curr-r-b = ?
      .
    end.
    when 'recadd':U
    or
    when 'recupdate':U
    then do:
      assign
      v-codex-id-list = string(20)
      v-ruleset-id-list[1] = string(5)
      v-prop-code = 'thref':U
      v-curr-r-b = ?
      .
    end.
    when 'ref-event':U
    then do:
      assign
      v-codex-id-list = string(20)
      v-ruleset-id-list[1] = string(100)
      v-prop-code = 'thref':U
      v-curr-r-b = ?
      .
    end.
    when 'event_price-doc':U
    then do:
      assign
      v-codex-id-list = string(18)
      v-ruleset-id-list[1] = string(110)
      v-prop-code = 'edoc':U
      .
define variable vss-include-info106 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
    end.
    when 'event_trn-doc':U
    then do:
      assign
      v-codex-id-list = string(18)
      v-ruleset-id-list[1] = string(115)
      v-prop-code = 'edoc':U
      .
define variable vss-include-info107 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
    end.
    when  'event_rcv':U
    then do:
      assign
      v-codex-id-list = string(18)
      v-ruleset-id-list[1] = string(105)
      v-prop-code = 'edoc':U
      .
define variable vss-include-info108 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
    end.
    when  'event_order':U
    then do:
      assign
      v-codex-id-list = string(18)
      v-ruleset-id-list[1] = string(100)
      v-prop-code = 'edoc':U
      .
define variable vss-include-info109 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
    end.
    when  'event_intorder':U
    then do:
      assign
      v-codex-id-list = string(18)
      v-ruleset-id-list[1] = string(125)
      v-prop-code = 'edoc':U
      .
define variable vss-include-info110 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
    end.
    when 'event_inkas':U
    then do:
      assign
      v-codex-id-list = string(18)
      v-ruleset-id-list[1] = string(130)
      v-prop-code = 'edoc':U
      .
define variable vss-include-info111 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
    end.
    when 'event_rvs-doc':U
    then do:
      assign
      v-codex-id-list = string(18)
      v-ruleset-id-list[1] = string(135)
      v-prop-code = 'edoc':U
      .
define variable vss-include-info112 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
    end.
    when 'event_inkas':U
    then do:
      assign
      v-codex-id-list = string(18)
      v-ruleset-id-list[1] = string(130)
      v-prop-code = 'edoc':U
      .
define variable vss-include-info113 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
    end.
    when 'event_shift':U
    then do:
      assign
      v-codex-id-list = string(18)
      v-ruleset-id-list[1] = string(140)
      v-prop-code = 'edoc':U
      .
define variable vss-include-info114 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
    end.
    when 'event_icnt-doc':U
    then do:
      assign
      v-codex-id-list = string(18)
      v-ruleset-id-list[1] = string(145)
      v-prop-code = 'edoc':U
      .
define variable vss-include-info115 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
    end.
    when 'event_fin-doc':U
    then do:
      assign
      v-codex-id-list = string(18)
      v-ruleset-id-list[1] = string(150)
      v-prop-code = 'edoc':U
      .
define variable vss-include-info116 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
    end.
    when 'event_fbr-doc':U
    then do:
      assign
      v-codex-id-list = string(18)
      v-ruleset-id-list[1] = string(155)
      v-prop-code = 'edoc':U
      .
define variable vss-include-info117 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
    end.
    when 'event_utd':U
    then do:
      assign
      v-codex-id-list = string(18)
      v-ruleset-id-list[1] = string(160)
      v-prop-code = 'edoc':U
      .
define variable vss-include-info118 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
    end.
    when 'event_mark':U
    then do:
      assign
      v-codex-id-list = string(18)
      v-ruleset-id-list[1] = string(165)
      v-prop-code = 'edoc':U
      .
define variable vss-include-info119 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
    end.
    when 'event_user-action':U
    then do:
      assign
      v-codex-id-list = string(18)
      v-ruleset-id-list[1] = string(170)
      v-prop-code = 'edoc':U
      .
define variable vss-include-info120 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
    end.
    otherwise do:
      undo _main, return error substitute("&1 &2 &3&4Ошибка входных параметров процедуры rum-run.p&4Невернoе значение p-process = &5"
                                          ,vss-workfile
                                          ,vss-revision
                                          ,vss-description
                                          ,chr(10)
                                          ,p-process
                                           ).
    end.
  END CASE.
  find first buf_thbj-attr no-lock where
            buf_thbj-attr.upper-prop-code = 'rum':U
       and  buf_thbj-attr.prop-code = v-prop-code no-error.
  if not available buf_thbj-attr
  or buf_thbj-attr.property-value-logical = no
  then return ''.
  run gen-key-rec in this-procedure ( input 'thbj-attr':U
                                     ,input (buffer buf_thbj-attr:handle)
                                     ,output v-uniq-key-rec).
  _codex:
  do v-jj = 1 to num-entries(v-codex-id-list):
    if entry(v-jj, v-codex-id-list) = '':U then next _codex.
    v-codex-id = integer(entry(v-jj, v-codex-id-list)).
    do v-ii = 1 to num-entries(v-ruleset-id-list[v-jj]):
        if entry(v-ii, v-ruleset-id-list[v-jj]) = '':U then next.
        v-ruleset-id = integer(entry(v-ii, v-ruleset-id-list[v-jj])).
      _rule-by-call:
      for each buf_rule-by-call no-lock where
                buf_rule-by-call.call_id = v-uniq-key-rec
          and buf_rule-by-call.can-calc = yes
          and buf_rule-by-call.codex_id = v-codex-id
          and buf_rule-by-call.ruleset_id = v-ruleset-id
      by buf_rule-by-call.call_Id
      by buf_rule-by-call.codex_id
      by buf_rule-by-call.ruleset_id
      by buf_rule-by-call.order_id
      on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
      on endkey undo _main, return error substitute( "&1. endkey", vss-workfile ) :
        v-proc-name = "rul/" + string(buf_rule-by-call.rule_id, '999999999') + '.p'.
        run value(v-proc-name)  (
                                                              input parparentproc
                                                            ,input p-parent-handle
                                                            ,input p-log-handle
                                                            ,input v-cont-handle
                                                            ,input v-codex-id
                                                            ,input v-ruleset-id
                                                            ,input buf_rule-by-call.call_id
                                                            ,input buf_rule-by-call.order_id
                                                            ,input buf_rule-by-call.rule_id
                                                            ,input buf_rule-by-call.profile
                                                            ,input buf_rule-by-call.is_dynamic
                                                            ,input v-doc-type
                                                            ,input 0
                                                            ,input ''
                                                            ,input 0
                                                            ,input v-doc-code
                                                            ,input v-process-file-name
                                                            ,input 0
                                                            ,input v-curr-r-b
                                                            ,input ?
                                                            ,input 0
                                                            ) .
      end.
    end.
  end.
end.
end procedure.
