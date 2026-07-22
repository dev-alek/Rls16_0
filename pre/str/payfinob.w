DEFINE TEMP-TABLE tt-fin-doc NO-UNDO LIKE ub.fin-doc.
DEFINE TEMP-TABLE tt0-fin-doc-attr NO-UNDO LIKE ub.fin-doc-attr.
DEFINE TEMP-TABLE tt0-fin-doc-tax NO-UNDO LIKE ub.fin-doc-tax
       INDEX pi1 vat-pc slt-pc with-vat with-slt
       .
DEFINE TEMP-TABLE tt0-payment NO-UNDO LIKE ub.payment.
  DEFINE temp-table temp-fin-ob no-undo
    field   ri             as  recid
    field   ind            as integer
    field   del            as logical
    INDEX pi  IS PRIMARY   ind
    INDEX pi1  ri
    INDEX pi2  del
  .
  define input  parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input  parameter p-host-code    as integer   no-undo .
  define input  parameter table for temp-fin-ob.
  define output parameter p-ri as recid no-undo .
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Автомат. оплата фин. обязательств" .
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
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
  define variable g-log as logical   no-undo .
  define variable is-expense  as logical   no-undo .
  define buffer buf_contract for ub.contract .
  define buffer b1_fin-schet for ub.fin-schet .
  define buffer b2_fin-schet for ub.fin-schet .
  define variable curr-rc as character no-undo .
  define variable v-curr-r-b as integer   no-undo .
  define variable num-fo as integer initial 0  no-undo .
  define variable sss as character no-undo .
DEFINE BUTTON B-calc
     LABEL "Расчет сумм и курсов"
     SIZE 22 BY 1.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-tax
     LABEL "&Налоги"
     SIZE 10 BY 1.
DEFINE VARIABLE naznach-plat AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 51.5 BY 5.5 NO-UNDO.
DEFINE VARIABLE curr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY .67 NO-UNDO.
DEFINE VARIABLE FILL-code AS CHARACTER FORMAT "X(16)":U
     LABEL "Номер"
     VIEW-AS FILL-IN
     SIZE 17.5 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-sum AS DECIMAL FORMAT ">,>>>,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "Сумма"
     VIEW-AS FILL-IN
     SIZE 24.5 BY 1 NO-UNDO.
DEFINE VARIABLE b-nal AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "б/н", 1,
"нал.", 2,
"АПЗ", 3
     SIZE 18 BY 1 NO-UNDO.
DEFINE VARIABLE b-val AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "abbr_rub_firstshift.", 1,
"Б.вал.", 2,
"Вал.дог.", 3
     SIZE 11 BY 2.5 NO-UNDO.
DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 25.5 BY 1.5.
DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 51.5 BY 3.75.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-tax AT ROW 1 COL 33
     b-help AT ROW 1 COL 43
     FILL-code AT ROW 2.25 COL 7 COLON-ALIGNED
     b-nal AT ROW 2.25 COL 34.5 NO-LABEL
     FILL-sum AT ROW 4 COL 26 COLON-ALIGNED
     b-val AT ROW 4.58 COL 3.13 NO-LABEL
     B-calc AT ROW 5.25 COL 30
     naznach-plat AT ROW 9.5 COL 1.5 NO-LABEL
     curr AT ROW 3.75 COL 10 COLON-ALIGNED NO-LABEL
     RECT-7 AT ROW 2 COL 27.5
     RECT-8 AT ROW 3.5 COL 1.5
     "Основание платежа" VIEW-AS TEXT
          SIZE 19.38 BY 1 AT ROW 8.25 COL 2
          FGCOLOR 4
     "Тип:" VIEW-AS TEXT
          SIZE 5 BY .83 AT ROW 2.25 COL 28.5
          FGCOLOR 4
     "Валюта:" VIEW-AS TEXT
          SIZE 9 BY .83 AT ROW 3.67 COL 3
          FGCOLOR 4
     SPACE(41.49) SKIP(10.57)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Новый платеж"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       FILL-sum:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-calc IN FRAME Dialog-Frame
DO:
  define variable old-sum as decimal   no-undo .
  assign old-sum = tt-fin-doc.sum-doc .
  run ref/findclci.w (
   INPUT          parParentProc
  ,input          "":U
  ,INPUT          tt-fin-doc.doc-date
  ,INPUT          tt-fin-doc.curr-code
  ,INPUT          v-curr-r-b
  ,INPUT          tt-fin-doc.contract-curr
  ,INPUT-OUTPUT   tt-fin-doc.sum-doc
  ,INPUT-OUTPUT   tt-fin-doc.exch-rate
  ,INPUT-OUTPUT   tt-fin-doc.exch-scale
  ,INPUT-OUTPUT   tt-fin-doc.sum-rubl
  ,INPUT-OUTPUT   tt-fin-doc.sum-base
  ,INPUT-OUTPUT   tt-fin-doc.base-rate
  ,INPUT-OUTPUT   tt-fin-doc.base-scale
  ,INPUT-OUTPUT   tt-fin-doc.sum-contr
  ,INPUT-OUTPUT   tt-fin-doc.contract-rate
  ,INPUT-OUTPUT   tt-fin-doc.contract-scale ) no-error.
  if error-status:error then return no-apply.
  assign FILL-sum = tt-fin-doc.sum-doc .
  DISPLAY FILL-sum WITH FRAME Dialog-Frame.
  if tt-fin-doc.sum-doc <> tt-fin-doc.sum-doc then run CorrectNalog in this-procedure .
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
  assign naznach-plat FILL-code .
  run CreateDoc no-error.
  if error-status:error then return no-apply.
END.
ON VALUE-CHANGED OF b-nal IN FRAME Dialog-Frame
DO:
 if b-nal:screen-value = "1" then do:
   if not available b1_fin-schet or not available b2_fin-schet then do:
      message  "Не найден счет плательщика или получателя."   view-as alert-box.
      assign b-nal:screen-value = string(b-nal) .
      return .
    end.
  end.
  assign b-nal .
  if b-nal = 1 then do:
    DISABLE b-val WITH FRAME Dialog-Frame .
    case b2_fin-schet.curr-code :
      when 0 then assign tt-fin-doc.sum-doc = tt-fin-doc.sum-rubl .
      when v-curr-r-b then assign tt-fin-doc.sum-doc = tt-fin-doc.sum-base .
      when buf_contract.curr-code then assign tt-fin-doc.sum-doc = tt-fin-doc.sum-contr .
      otherwise do:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  b2_fin-schet.curr-code
  ,input  today
  ,output tt-fin-doc.exch-rate
  ,output tt-fin-doc.exch-scale
  ,output curr-rc
  )  .
        assign tt-fin-doc.sum-doc = tt-fin-doc.sum-rubl * tt-fin-doc.exch-scale / tt-fin-doc.exch-rate  .
        assign  FILL-sum = tt-fin-doc.sum-doc .
      end.
    end.
    assign
      curr = curr-rc
      tt-fin-doc.curr-code = b1_fin-schet.curr-code
    .
    assign naznach-plat .
    define variable si as character no-undo .
    si = entry(2,naznach-plat,'@') no-error .
    if si = "" then assign
      tt-fin-doc.naznach-plat = tt-fin-doc.naznach-plat + "@" + tt-fin-doc.including
      naznach-plat = tt-fin-doc.naznach-plat
    .
    DISPLAY curr FILL-sum naznach-plat WITH FRAME Dialog-Frame.
  end.
  else do:
    ENABLE  b-val WITH FRAME Dialog-Frame .
    apply "VALUE-CHANGED"  to b-val in frame Dialog-Frame.
  end.
END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
  message "Вы действительно хотите отменить создание платежа?" view-as alert-box QUESTION BUTTONS YES-NO UPDATE g-log .
  if g-log = no then return no-apply.
END.
ON CHOOSE OF B-tax IN FRAME Dialog-Frame
DO:
  run ref/fndocti.w (
                  INPUT parParentProc
                  ,input p-host-code
                  ,input 'ДОБАВЛЕНИЕ':U
                  ,input tt-fin-doc.host-code
                  ,input tt-fin-doc.fin-doc-code
                  ,input tt-fin-doc.fin-doc-type
                  ,input tt-fin-doc.fin-ext-doc-type
                  ,input tt-fin-doc.trn-doc-code
                  ,input tt-fin-doc.contract-code
                  ,input tt-fin-doc.sum-doc
                  ,input tt-fin-doc.curr-code
                  ,input tt-fin-doc.base-rate
                  ,input tt-fin-doc.base-scale
                  ,input tt-fin-doc.exch-rate
                  ,input tt-fin-doc.exch-scale
                  ,input tt-fin-doc.obj-type
                  ,input tt-fin-doc.obj-code
                  ,input-output table tt0-fin-doc-tax
                  ,input 0
                  ).
  assign naznach-plat .
  if num-entries(naznach-plat, "@":U) > 1 then do:
    assign sss = ""  .
    run StrTax (input-output sss) .
    assign  entry(2, naznach-plat, "@":U) = sss.
    DISPLAY naznach-plat WITH FRAME Dialog-Frame.
  end.
END.
ON VALUE-CHANGED OF b-val IN FRAME Dialog-Frame
DO:
  assign b-val .
  case b-val :
    when 1 then do:
      find first ub.currency no-lock where ub.currency.curr-code = 0 .
      assign
        FILL-sum = tt-fin-doc.sum-rubl
        tt-fin-doc.curr-code = 0
      .
    end.
    when 2 then do:
      find first ub.currency no-lock where ub.currency.curr-code = v-curr-r-b .
      assign
        FILL-sum = tt-fin-doc.sum-base
        tt-fin-doc.curr-code = v-curr-r-b
      .
    end.
    when 3 then do:
      find first ub.currency no-lock where ub.currency.curr-code = buf_contract.curr-code .
      assign
        FILL-sum = tt-fin-doc.sum-contr
        tt-fin-doc.curr-code = buf_contract.curr-code
      .
    end.
  end.
  assign curr = ub.currency.curr-abbr .
  DISPLAY curr WITH FRAME Dialog-Frame.
END.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  p-host-code
  ,output v-curr-r-b
  )  .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON ANY-PRINTABLE OF naznach-plat IN FRAME Dialog-Frame
DO:
  RUN proc-uho-check IN THIS-PROCEDURE(1) NO-ERROR.
  IF ERROR-STATUS :ERROR THEN DO: RETURN NO-APPLY. END.
END.
ON BACKSPACE OF naznach-plat IN FRAME Dialog-Frame
DO:
define variable v-offset as integer no-undo .
  RUN proc-uho-check IN THIS-PROCEDURE(1) NO-ERROR.
  IF ERROR-STATUS :ERROR THEN DO: RETURN NO-APPLY. END.
  if naznach-plat :CURSOR-OFFSET > 1 then do :
    assign
    v-offset = naznach-plat:CURSOR-OFFSET
    naznach-plat:screen-value = substring(naznach-plat:screen-value, 1, naznach-plat:CURSOR-OFFSET - 2) +
                      substring(naznach-plat:screen-value, naznach-plat:CURSOR-OFFSET , length(naznach-plat:screen-value)  -  naznach-plat:CURSOR-OFFSET + 1)
    naznach-plat:CURSOR-OFFSET = v-offset - 1
    .
  end.
END.
ON DELETE-CHARACTER OF naznach-plat IN FRAME Dialog-Frame
DO:
define variable v-offset as integer no-undo .
  if naznach-plat:selection-start = ? then do:
    RUN proc-uho-check IN THIS-PROCEDURE(0) NO-ERROR.
    IF ERROR-STATUS :ERROR THEN DO: RETURN NO-APPLY. END.
    assign
    v-offset = naznach-plat:CURSOR-OFFSET
    naznach-plat:screen-value = substring(naznach-plat:screen-value, 1, naznach-plat:CURSOR-OFFSET - 1) +
                      substring(naznach-plat:screen-value, naznach-plat:CURSOR-OFFSET + 1, length(naznach-plat:screen-value)  -  naznach-plat:CURSOR-OFFSET + 1)
    naznach-plat:CURSOR-OFFSET = v-offset
    .
  end.
  else do:
    IF  index(naznach-plat:SCREEN-VALUE IN FRAME Dialog-Frame, "@") > 0 then do:
      IF naznach-plat:Selection-start >= index(naznach-plat:SCREEN-VALUE, "@") + 1 THEN   do:
        RETURN no-apply.
      end.
    END.
    naznach-plat:edit-clear().
  end.
END.
ON CTRL-X OF naznach-plat IN FRAME Dialog-Frame
DO:
  IF  index(naznach-plat:SCREEN-VALUE IN FRAME Dialog-Frame, "@") > 0 then do:
    IF naznach-plat:Selection-start >= index(naznach-plat:SCREEN-VALUE, "@") + 1 THEN   do:
      RETURN no-apply.
    end.
  END.
  naznach-plat:edit-cut().
END.
ON CTRL-V OF naznach-plat IN FRAME Dialog-Frame
DO:
  IF  index(naznach-plat:SCREEN-VALUE IN FRAME Dialog-Frame, "@") > 0 then do:
    IF naznach-plat:Selection-start >= index(naznach-plat:SCREEN-VALUE, "@") + 1 THEN   do:
      RETURN no-apply.
    end.
  END.
  naznach-plat:edit-paste().
END.
      procedure proc-uho-check :
DEFINE INPUT PARAMETER p-offset AS INTEGER NO-UNDO.
  do
  on error undo, return error
  :
    IF  index(naznach-plat:SCREEN-VALUE IN FRAME Dialog-Frame, "@") > 0 then do:
      IF (naznach-plat:CURSOR-OFFSET >= index(naznach-plat:SCREEN-VALUE, "@") + 1
      AND p-offset = 0)
      OR (naznach-plat:CURSOR-OFFSET > index(naznach-plat:SCREEN-VALUE, "@") + 1
      AND p-offset = 1)  THEN   do:
        RETURN ERROR.
      end.
    END.
  end.
end procedure.
  find first ub.sysconf no-lock where ub.sysconf.host-code = p-host-code .
  find first ub.firm no-lock where ub.firm.firm-code = p-host-code .
  run StartProc in this-procedure .
  assign
    tt-fin-doc.prn-doc-code = string(tt-fin-doc.fin-doc-code)
    FILL-sum     = tt-fin-doc.sum-doc
    naznach-plat = tt-fin-doc.naznach-plat
    FILL-code    = tt-fin-doc.prn-doc-code
  .
  case buf_contract.pay-nal :
    when no  then assign b-nal = 1 .
    when yes then assign b-nal = 2 .
    when ?   then assign b-nal = 3 .
  end.
  case tt-fin-doc.contract-curr :
    when 0          then             assign b-val = 1 .
    when v-curr-r-b then             assign b-val = 2 .
    when buf_contract.curr-code then assign b-val = 3 .
    otherwise                        assign b-val = 1 .
  end.
  assign
  b-val:radio-buttons in frame Dialog-Frame =
  "Руб." + chr(44) + "1" + chr(44) +
  "Б.вал." + chr(44) + "2" + chr(44) +
  "Вал.дог." + chr(44) + "3"
  .
  RUN enable_UI.
  apply "VALUE-CHANGED"  to b-nal in frame Dialog-Frame.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE CorrectNalog :
  do
  on error undo, return error return-value
  :
    for each tt0-fin-doc-tax : delete tt0-fin-doc-tax . end.
    create tt0-fin-doc-tax .
    assign
      tt0-fin-doc-tax.fin-doc-code       = tt-fin-doc.fin-doc-code
      tt0-fin-doc-tax.host-code          = p-host-code
      tt0-fin-doc-tax.line-num           = 1
      tt0-fin-doc-tax.VAT-pc             = buf_contract.fin-VAT-pc
      tt0-fin-doc-tax.sum-line-doc       =  tt-fin-doc.sum-doc
      tt0-fin-doc-tax.sum-vat-line-doc   =  tt-fin-doc.sum-doc * buf_contract.fin-VAT-pc / (100 + buf_contract.fin-VAT-pc)
      tt0-fin-doc-tax.sum-line-rubl      =  tt-fin-doc.sum-rubl
      tt0-fin-doc-tax.sum-vat-line-rubl  =  tt-fin-doc.sum-rubl * buf_contract.fin-VAT-pc / (100 + buf_contract.fin-VAT-pc)
      tt0-fin-doc-tax.sum-line-base      =  tt-fin-doc.sum-base
      tt0-fin-doc-tax.sum-vat-line-base  =  tt-fin-doc.sum-base * buf_contract.fin-VAT-pc / (100 + buf_contract.fin-VAT-pc)
      tt0-fin-doc-tax.sum-line-contr     =  tt-fin-doc.sum-contr
      tt0-fin-doc-tax.sum-vat-line-contr =  tt-fin-doc.sum-contr * buf_contract.fin-VAT-pc / (100 + buf_contract.fin-VAT-pc)
    .
  end.
END PROCEDURE.
PROCEDURE CreateDoc :
  do on error undo, return error return-value :
    assign
      tt-fin-doc.naznach-plat = naznach-plat
      tt-fin-doc.prn-doc-code = FILL-code
    .
    if b-nal > 1 then do:
      case b-val:
        when 1 then assign tt-fin-doc.curr-code = 0 .
        when 2 then assign tt-fin-doc.curr-code = v-curr-r-b .
        when 3 then assign tt-fin-doc.curr-code = buf_contract.curr-code .
      end.
      assign
        tt-fin-doc.receiver-code-schet = 0
        tt-fin-doc.receiver-bank-name  = ""
        tt-fin-doc.receiver-c-schet    = ""
        tt-fin-doc.receiver-r-schet    = ""
        tt-fin-doc.payer-code-schet = 0
        tt-fin-doc.payer-bank-name  = ""
        tt-fin-doc.payer-c-schet    = ""
        tt-fin-doc.payer-r-schet    = ""
      .
    end.
    else do:
      if not available b1_fin-schet or not available b2_fin-schet then do:
        message  "Не найден счет плательщика или получателя."   view-as alert-box.
        return error .
      end.
      assign tt-fin-doc.curr-code    = b1_fin-schet.curr-code .
    end.
   if is-expense then
     assign
       tt-fin-doc.payer-sign1        = ub.firm.director
       tt-fin-doc.payer-sign2        = ub.sysconf.snr-accnt
       tt-fin-doc.payer-sign3        = ub.sysconf.cashier
     .
   else
     assign
       tt-fin-doc.receiver-sign1        = ub.firm.director
       tt-fin-doc.receiver-sign2        = ub.sysconf.snr-accnt
       tt-fin-doc.receiver-sign3        = ub.sysconf.cashier
     .
    case b-nal :
      when 1 then do:
        if b1_fin-schet.curr-code <> b2_fin-schet.curr-code then do:
          message "Валюта счета плательщика отличается от валюты счета получателя." view-as alert-box.
          return error .
        end.
        if buf_contract.doc-type = 'при':U then do:
          if is-expense then do:
            assign
            tt-fin-doc.fin-doc-type = 'рпп':U
            tt-fin-doc.fin-ext-doc-type = 'рпп':U
            .
          end.
          else do:
            assign
            tt-fin-doc.fin-doc-type = 'ппп':U
            tt-fin-doc.fin-ext-doc-type = 'ппп':U
            .
          end.
        end.
        else do:
          if is-expense then do:
            assign
            tt-fin-doc.fin-doc-type = 'ппп':U
            tt-fin-doc.fin-ext-doc-type = 'ппп':U
            .
          end.
          else do:
            assign
            tt-fin-doc.fin-doc-type = 'рпп':U
            tt-fin-doc.fin-ext-doc-type = 'рпп':U
            .
          end.
        end.
      end.
      when 2 then do:
        run StrTax (input-output tt-fin-doc.including) .
        if buf_contract.doc-type = 'при':U then do:
          if is-expense then do:
            assign
            tt-fin-doc.fin-doc-type = 'рко':U
            tt-fin-doc.fin-ext-doc-type = 'рко':U
            .
        end.
        else do:
            assign
            tt-fin-doc.fin-doc-type = 'пко':U
            tt-fin-doc.fin-ext-doc-type = 'пко':U
            .
          end.
        end.
        else do:
          if is-expense then do:
            assign
            tt-fin-doc.fin-doc-type = 'пко':U
            tt-fin-doc.fin-ext-doc-type = 'пко':U
            .
          end.
          else do:
            assign
            tt-fin-doc.fin-doc-type = 'рко':U
            tt-fin-doc.fin-ext-doc-type = 'рко':U
            .
          end.
        end.
      end.
      when 3 then do:
        if buf_contract.doc-type = 'при':U then do:
          if is-expense then do:
            assign
            tt-fin-doc.fin-doc-type = 'апр':U
            tt-fin-doc.fin-ext-doc-type = 'апр':U
            .
          end.
          else do:
            assign
            tt-fin-doc.fin-doc-type = 'апп':U
            tt-fin-doc.fin-ext-doc-type = 'апп':U
            .
          end.
        end.
        else do:
          if is-expense then do:
            assign
            tt-fin-doc.fin-doc-type = 'апп':U
            tt-fin-doc.fin-ext-doc-type = 'апп':U
            .
        end.
        else do:
            assign
            tt-fin-doc.fin-doc-type = 'апр':U
            tt-fin-doc.fin-ext-doc-type = 'апр':U
            .
          end.
        end.
      end.
    end.
    define variable p-doc-rec as recid no-undo.
    run UchetCode in this-procedure .
    run RoundTax in this-procedure .
    tt-fin-doc.doc-author = "fin-ob".
    run ref/findoc0.p (
        input-output p-doc-rec
       ,input 'ДОБАВЛЕНИЕ':U
       ,input no
       ,input tt-fin-doc.host-code            ,input tt-fin-doc.fin-doc-code         ,input tt-fin-doc.an-uchet-code        ,input tt-fin-doc.an-uchet-value       ,input tt-fin-doc.base-rate            ,input tt-fin-doc.base-scale           ,input tt-fin-doc.cel-nazn-code        ,input tt-fin-doc.cel-nazn-value       ,input tt-fin-doc.contract-code        ,input tt-fin-doc.contract-curr        ,input tt-fin-doc.contract-rate        ,input tt-fin-doc.contract-scale       ,input tt-fin-doc.cor-acc              ,input tt-fin-doc.cor-acc-value        ,input tt-fin-doc.cor-acc1             ,input tt-fin-doc.cor-acc1-value       ,input tt-fin-doc.curr-code            ,input tt-fin-doc.doc-date             ,input tt-fin-doc.shift-date           ,input tt-fin-doc.shift-num            ,input tt-fin-doc.shift-name           ,input tt-fin-doc.enclosure            ,input tt-fin-doc.exch-rate            ,input tt-fin-doc.exch-scale           ,input tt-fin-doc.f104                 ,input tt-fin-doc.f105                 ,input tt-fin-doc.f106                 ,input tt-fin-doc.f107                 ,input tt-fin-doc.f108                 ,input tt-fin-doc.f109                 ,input tt-fin-doc.f110                 ,input tt-fin-doc.f22                  ,input tt-fin-doc.f23                  ,input tt-fin-doc.fact-date            ,input tt-fin-doc.fin-doc-type         ,input tt-fin-doc.fin-ext-doc-type     ,input tt-fin-doc.in-doc-code          ,input tt-fin-doc.in-host-code         ,input tt-fin-doc.including            ,input tt-fin-doc.nazn-pl              ,input tt-fin-doc.naznach-plat         ,input tt-fin-doc.ocher-pl             ,input tt-fin-doc.out-doc-code         ,input tt-fin-doc.out-host-code        ,input tt-fin-doc.pay-date             ,input tt-fin-doc.payer-bank-name      ,input tt-fin-doc.payer-bank-city      ,input tt-fin-doc.payer-bik            ,input tt-fin-doc.payer-c-schet        ,input tt-fin-doc.payer-code           ,input tt-fin-doc.payer-code-schet     ,input tt-fin-doc.payer-dop1           ,input tt-fin-doc.payer-dop2           ,input tt-fin-doc.payer-inn            ,input tt-fin-doc.payer-kpp            ,input tt-fin-doc.payer-name           ,input tt-fin-doc.payer-okpo           ,input tt-fin-doc.payer-passport      ,input tt-fin-doc.payer-r-schet        ,input tt-fin-doc.payer-type           ,input tt-fin-doc.perm-date            ,input tt-fin-doc.prn-doc-code         ,input tt-fin-doc.PS                   ,input tt-fin-doc.receiver-bank-name   ,input tt-fin-doc.receiver-bank-city   ,input tt-fin-doc.receiver-bik         ,input tt-fin-doc.receiver-c-schet     ,input tt-fin-doc.receiver-code        ,input tt-fin-doc.receiver-code-schet  ,input tt-fin-doc.receiver-dop1        ,input tt-fin-doc.receiver-dop2        ,input tt-fin-doc.receiver-inn         ,input tt-fin-doc.receiver-kpp         ,input tt-fin-doc.receiver-name        ,input tt-fin-doc.receiver-okpo        ,input tt-fin-doc.receiver-passport    ,input tt-fin-doc.receiver-r-schet     ,input tt-fin-doc.receiver-type        ,input tt-fin-doc.srok-pl              ,input tt-fin-doc.stat-pl              ,input tt-fin-doc.str-podr-code        ,input tt-fin-doc.str-podr-type        ,input tt-fin-doc.str-podr-name        ,input tt-fin-doc.sum-base             ,input tt-fin-doc.sum-doc              ,input tt-fin-doc.sum-rubl             ,input tt-fin-doc.sum-contr            ,input tt-fin-doc.trn-doc-code         ,input tt-fin-doc.vid-opl              ,input tt-fin-doc.vid-plat
       ,input tt-fin-doc.con-sum-rubl         ,input tt-fin-doc.con-sum-base         ,input tt-fin-doc.con-sum-doc          ,input tt-fin-doc.con-sum-contr        ,input tt-fin-doc.con-stat             ,input tt-fin-doc.payer-sign1                ,input tt-fin-doc.payer-sign2                ,input tt-fin-doc.payer-sign3                ,input tt-fin-doc.payer-sign4                ,input tt-fin-doc.receiver-sign1                ,input tt-fin-doc.receiver-sign2                ,input tt-fin-doc.receiver-sign3                ,input tt-fin-doc.receiver-sign4                ,input tt-fin-doc.obj-type                   ,input tt-fin-doc.obj-code                   ,input tt-fin-doc.doc-author                 ,input tt-fin-doc.fact-author                ,input tt-fin-doc.CashBookId
       ,input table tt0-fin-doc-tax
       ,input table tt0-fin-doc-attr
       ,input no
       ,input table tt0-payment
     ) no-error .
    if error-status:error then do:
      undo, return error.
    end.
    assign p-ri = p-doc-rec .
  end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY FILL-code b-nal FILL-sum b-val naznach-plat curr
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit B-tax b-help FILL-code b-nal FILL-sum b-val B-calc
         naznach-plat curr RECT-7 RECT-8
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE RoundTax :
  do
  on error undo, return error return-value
  :
    for each tt0-fin-doc-tax :
      assign
        tt0-fin-doc-tax.sum-line-doc       =  ROUND( tt0-fin-doc-tax.sum-line-doc      , 2)
        tt0-fin-doc-tax.sum-vat-line-doc   =  ROUND( tt0-fin-doc-tax.sum-vat-line-doc  , 2)
        tt0-fin-doc-tax.sum-line-rubl      =  ROUND( tt0-fin-doc-tax.sum-line-rubl     , 2)
        tt0-fin-doc-tax.sum-vat-line-rubl  =  ROUND( tt0-fin-doc-tax.sum-vat-line-rubl , 2)
        tt0-fin-doc-tax.sum-line-base      =  ROUND( tt0-fin-doc-tax.sum-line-base     , 2)
        tt0-fin-doc-tax.sum-vat-line-base  =  ROUND( tt0-fin-doc-tax.sum-vat-line-base , 2)
      .
    end.
  end.
END PROCEDURE.
PROCEDURE StartProc :
  do
  on error undo, return error return-value
  :
    define variable line as integer   no-undo .
    define buffer b_fin-ob for ub.fin-ob .
    define variable num-cont as integer  no-undo .
    define variable pay-type as character no-undo .
    define variable rec-type as character no-undo .
    define variable obj-type as character no-undo .
    define variable pay-code as integer no-undo .
    define variable rec-code as integer no-undo .
    define variable obj-code as integer no-undo .
    define variable is-full-sum as logical   no-undo .
    define variable p-koef-rubl as decimal   no-undo .
    define variable p-koef-base as decimal   no-undo .
    define variable p-koef-cont as decimal   no-undo .
    define variable p-koef-doc  as decimal   no-undo .
    define variable v-fd-code as integer no-undo .
    assign
      num-cont = - 1
      line = 1
      is-full-sum = yes .
    .
    for each temp-fin-ob :
      find first b_fin-ob no-lock where recid(b_fin-ob) = temp-fin-ob.ri .
      if b_fin-ob.con-stat = 2 then do:
        message
          "Фин. обязательство № " b_fin-ob.prn-doc-code " (дата платежа " b_fin-ob.pay-date ") уже полностью связано с платежем!"
        view-as alert-box.
        return error .
      end.
      if b_fin-ob.contract-code < 1 then do:
        message "Автоматическая оплата фин. обязательств без договора невозможна! Фин. обязательство № " b_fin-ob.prn-doc-code " (дата платежа " b_fin-ob.pay-date "). " view-as alert-box.
        return error .
      end.
      assign num-fo = num-fo + 1 .
      if num-cont = - 1 then do:
        find first buf_contract no-lock where buf_contract.host-code = p-host-code and buf_contract.contract-code = b_fin-ob.contract-code no-error .
        assign
          num-cont = b_fin-ob.contract-code
          pay-type = b_fin-ob.payer-type
          pay-code = b_fin-ob.payer-code
          rec-type = b_fin-ob.receiver-type
          rec-code = b_fin-ob.receiver-code
          obj-type = b_fin-ob.obj-type
          obj-code = b_fin-ob.obj-code
        .
        run gen-b-code in this-procedure ( input 'fdgb':U
                                        , output v-fd-code) no-error .
        if error-status:error then do:
          define variable v-mess as character no-undo .
          v-mess = substitute("Ошибка при генерации внутреннего номера фин. док-та:&1&2&1&3"
                                      , chr(10)
                                      , error-status:get-message(1)
                                      , return-value ).
          message
          v-mess
          view-as alert-box error .
          undo, return error .
        end.
        create tt-fin-doc .
        assign
          tt-fin-doc.host-code       = p-host-code
          tt-fin-doc.fin-doc-code    = v-fd-code
          tt-fin-doc.contract-code   = b_fin-ob.contract-code
          tt-fin-doc.contract-curr   = b_fin-ob.contract-curr
          tt-fin-doc.curr-code       = b_fin-ob.curr-code
          tt-fin-doc.doc-date        = today
          tt-fin-doc.prn-doc-code    = ""
          tt-fin-doc.PS              = ""
          tt-fin-doc.ocher-pl        = "6"
          tt-fin-doc.stat-pl         = ""
          tt-fin-doc.naznach-plat    = "Оплата по договору № " + buf_contract.contract-prn-code + " от " + string( buf_contract.contract-date,"99/99/9999")
          tt-fin-doc.payer-name      = b_fin-ob.payer-name
          tt-fin-doc.payer-code      = b_fin-ob.payer-code
          tt-fin-doc.payer-type      = b_fin-ob.payer-type
          tt-fin-doc.receiver-code   = b_fin-ob.receiver-code
          tt-fin-doc.receiver-name   = b_fin-ob.receiver-name
          tt-fin-doc.receiver-type   = b_fin-ob.receiver-type
          tt-fin-doc.sum-base        = b_fin-ob.sum-base     - b_fin-ob.con-sum-base
          tt-fin-doc.sum-rubl        = b_fin-ob.sum-rubl     - b_fin-ob.con-sum-rubl
          tt-fin-doc.sum-contr       = b_fin-ob.sum-contract - b_fin-ob.con-sum-contr
          tt-fin-doc.sum-doc         = b_fin-ob.sum-doc      - b_fin-ob.con-sum-doc
          tt-fin-doc.base-scale      = b_fin-ob.base-scale
          tt-fin-doc.contract-scale  = b_fin-ob.contract-scale
          tt-fin-doc.exch-scale      = b_fin-ob.exch-scale
          p-koef-rubl                = ( b_fin-ob.sum-rubl     - b_fin-ob.con-sum-rubl ) / b_fin-ob.sum-rubl
          p-koef-base                = ( b_fin-ob.sum-rubl     - b_fin-ob.con-sum-base ) / b_fin-ob.sum-rubl
          p-koef-cont                = ( b_fin-ob.sum-contract - b_fin-ob.con-sum-contr) / b_fin-ob.sum-contract
          p-koef-doc                 = ( b_fin-ob.sum-doc      - b_fin-ob.con-sum-doc  ) / b_fin-ob.sum-doc
        .
        run CheckCli no-error .
        if error-status:error then do:
          message "Несоответствие плательщика или получателя договору!" view-as alert-box.
          return error .
        end.
        run FindBank .
      end.
      else do:
        if num-cont <> b_fin-ob.contract-code then do:
          message "Фин. обязательство № " b_fin-ob.prn-doc-code " (дата платежа " b_fin-ob.pay-date ") относится к другому договору, чем предыдущие док-ты!"
          view-as alert-box.
          return error .
        end.
        if pay-type <> b_fin-ob.payer-type or pay-code <> b_fin-ob.payer-code then do:
          message "Плательщик в фин. обяз. № " b_fin-ob.prn-doc-code " (дата платежа " b_fin-ob.pay-date ") иной, чем в предыдущих док-тах! Продолжить? (В платеж будет прописан плательщик 1-го фин.обяз.)"
          view-as alert-box QUESTION BUTTONS YES-NO UPDATE g-log .
          if g-log = no then return error.
        end.
        if rec-type <> b_fin-ob.receiver-type or rec-code <> b_fin-ob.receiver-code then do:
          message "Получатель в фин. обяз. № " b_fin-ob.prn-doc-code " (дата платежа " b_fin-ob.pay-date ") иной, чем в предыдущих док-тах! Продолжить? (В платеж будет прописан получатель 1-го фин.обяз.)"
          view-as alert-box QUESTION BUTTONS YES-NO UPDATE g-log .
          if g-log = no then return error.
        end.
        if obj-code <> 0 then do:
          if obj-type <> b_fin-ob.obj-type or obj-code <> b_fin-ob.obj-code then assign obj-code = 0 .
        end.
        assign
          tt-fin-doc.sum-base  = tt-fin-doc.sum-base  + b_fin-ob.sum-base     - b_fin-ob.con-sum-base
          tt-fin-doc.sum-rubl  = tt-fin-doc.sum-rubl  + b_fin-ob.sum-rubl     - b_fin-ob.con-sum-rubl
          tt-fin-doc.sum-contr = tt-fin-doc.sum-contr + b_fin-ob.sum-contract - b_fin-ob.con-sum-contr
          tt-fin-doc.sum-doc   = tt-fin-doc.sum-doc   + b_fin-ob.sum-doc      - b_fin-ob.con-sum-doc
          p-koef-rubl          = ( b_fin-ob.sum-rubl     - b_fin-ob.con-sum-rubl ) / b_fin-ob.sum-rubl
          p-koef-base          = ( b_fin-ob.sum-rubl     - b_fin-ob.con-sum-base ) / b_fin-ob.sum-rubl
          p-koef-cont          = ( b_fin-ob.sum-contract - b_fin-ob.con-sum-contr) / b_fin-ob.sum-contract
          p-koef-doc           = ( b_fin-ob.sum-doc      - b_fin-ob.con-sum-doc  ) / b_fin-ob.sum-doc
        .
      end.
      for each ub.fin-ob-tax no-lock where ub.fin-ob-tax.host-code = p-host-code and ub.fin-ob-tax.doc-code = b_fin-ob.doc-code :
        find first tt0-fin-doc-tax
          where tt0-fin-doc-tax.vat-pc   = ub.fin-ob-tax.vat-pc
            and tt0-fin-doc-tax.slt-pc   = ub.fin-ob-tax.slt-pc
            and tt0-fin-doc-tax.with-vat = ub.fin-ob-tax.with-vat
            and tt0-fin-doc-tax.with-slt = ub.fin-ob-tax.with-slt
        no-error .
        if not available tt0-fin-doc-tax then do:
          create tt0-fin-doc-tax .
          BUFFER-COPY ub.fin-ob-tax TO tt0-fin-doc-tax .
          assign
            tt0-fin-doc-tax.fin-doc-code = tt-fin-doc.fin-doc-code
            tt0-fin-doc-tax.host-code    = p-host-code
            tt0-fin-doc-tax.line-num     = line
            line = line + 1
            tt0-fin-doc-tax.sum-line-doc       = tt0-fin-doc-tax.sum-line-doc       * p-koef-doc
            tt0-fin-doc-tax.sum-vat-line-doc   = tt0-fin-doc-tax.sum-vat-line-doc   * p-koef-doc
            tt0-fin-doc-tax.sum-slt-line-doc   = tt0-fin-doc-tax.sum-slt-line-doc   * p-koef-doc
            tt0-fin-doc-tax.sum-line-rubl      = tt0-fin-doc-tax.sum-line-rubl      * p-koef-rubl
            tt0-fin-doc-tax.sum-vat-line-rubl  = tt0-fin-doc-tax.sum-vat-line-rubl  * p-koef-rubl
            tt0-fin-doc-tax.sum-slt-line-rubl  = tt0-fin-doc-tax.sum-slt-line-rubl  * p-koef-rubl
            tt0-fin-doc-tax.sum-line-base      = tt0-fin-doc-tax.sum-line-base      * p-koef-base
            tt0-fin-doc-tax.sum-vat-line-base  = tt0-fin-doc-tax.sum-vat-line-base  * p-koef-base
            tt0-fin-doc-tax.sum-slt-line-base  = tt0-fin-doc-tax.sum-slt-line-base  * p-koef-base
            tt0-fin-doc-tax.sum-line-contr     = tt0-fin-doc-tax.sum-line-contr     * p-koef-cont
            tt0-fin-doc-tax.sum-vat-line-contr = tt0-fin-doc-tax.sum-vat-line-contr * p-koef-cont
            tt0-fin-doc-tax.sum-slt-line-contr = tt0-fin-doc-tax.sum-slt-line-contr * p-koef-cont
          .
        end.
        else do:
          assign
            tt0-fin-doc-tax.sum-line-doc       = tt0-fin-doc-tax.sum-line-doc       + ub.fin-ob-tax.sum-line-doc       * p-koef-doc
            tt0-fin-doc-tax.sum-vat-line-doc   = tt0-fin-doc-tax.sum-vat-line-doc   + ub.fin-ob-tax.sum-vat-line-doc   * p-koef-doc
            tt0-fin-doc-tax.sum-slt-line-doc   = tt0-fin-doc-tax.sum-slt-line-doc   + ub.fin-ob-tax.sum-slt-line-doc   * p-koef-doc
            tt0-fin-doc-tax.sum-line-rubl      = tt0-fin-doc-tax.sum-line-rubl      + ub.fin-ob-tax.sum-line-rubl      * p-koef-rubl
            tt0-fin-doc-tax.sum-vat-line-rubl  = tt0-fin-doc-tax.sum-vat-line-rubl  + ub.fin-ob-tax.sum-vat-line-rubl  * p-koef-rubl
            tt0-fin-doc-tax.sum-slt-line-rubl  = tt0-fin-doc-tax.sum-slt-line-rubl  + ub.fin-ob-tax.sum-slt-line-rubl  * p-koef-rubl
            tt0-fin-doc-tax.sum-line-base      = tt0-fin-doc-tax.sum-line-base      + ub.fin-ob-tax.sum-line-base      * p-koef-base
            tt0-fin-doc-tax.sum-vat-line-base  = tt0-fin-doc-tax.sum-vat-line-base  + ub.fin-ob-tax.sum-vat-line-base  * p-koef-base
            tt0-fin-doc-tax.sum-slt-line-base  = tt0-fin-doc-tax.sum-slt-line-base  + ub.fin-ob-tax.sum-slt-line-base  * p-koef-base
            tt0-fin-doc-tax.sum-line-contr     = tt0-fin-doc-tax.sum-line-contr     + ub.fin-ob-tax.sum-line-contr     * p-koef-cont
            tt0-fin-doc-tax.sum-vat-line-contr = tt0-fin-doc-tax.sum-vat-line-contr + ub.fin-ob-tax.sum-vat-line-contr * p-koef-cont
            tt0-fin-doc-tax.sum-slt-line-contr = tt0-fin-doc-tax.sum-slt-line-contr + ub.fin-ob-tax.sum-slt-line-contr * p-koef-cont
          .
        end.
      end.
    end.
    if obj-code <> 0 then do:
      assign
        tt-fin-doc.obj-type = obj-type
        tt-fin-doc.obj-code = obj-code
      .
    end.
    else do:
      if ub.sysconf.fin-calc = 1 then do:
        message
          substitute ("По фирме &1 ведется раздельный учет по объектам с поставщиками. Нельзя создать платеж по ФО с разных объектов.",sysconf.host-code)
        view-as alert-box.
        return error .
      end.
    end.
    assign
      tt-fin-doc.base-rate       = if tt-fin-doc.sum-base  <> 0 then tt-fin-doc.sum-rubl * tt-fin-doc.base-scale / tt-fin-doc.sum-base      else 0
      tt-fin-doc.contract-rate   = if tt-fin-doc.sum-contr <> 0 then tt-fin-doc.sum-rubl * tt-fin-doc.contract-scale / tt-fin-doc.sum-contr else 0
      tt-fin-doc.exch-rate       = if tt-fin-doc.sum-doc   <> 0 then tt-fin-doc.sum-rubl * tt-fin-doc.exch-scale / tt-fin-doc.sum-doc       else 0
    .
    if not available b1_fin-schet or not available b2_fin-schet then do:
      if buf_contract.pay-nal = no then do:
        message  "Не найден счет плательщика или получателя."   view-as alert-box.
        return error .
      end.
    end.
    else do:
      find first ub.currency no-lock where ub.currency.curr-code = b2_fin-schet.curr-code .
      assign  curr-rc = ub.currency.curr-abbr  .
      if buf_contract.pay-nal = no then do:
        assign
          curr = ub.currency.curr-abbr
          tt-fin-doc.curr-code = b2_fin-schet.curr-code
        .
        case b2_fin-schet.curr-code :
          when 0 then do:
            assign tt-fin-doc.sum-doc = tt-fin-doc.sum-rubl .
            for each tt0-fin-doc-tax no-lock :
              assign
                tt0-fin-doc-tax.sum-line-doc       = tt0-fin-doc-tax.sum-line-rubl
                tt0-fin-doc-tax.sum-vat-line-doc   = tt0-fin-doc-tax.sum-vat-line-rubl
                tt0-fin-doc-tax.sum-slt-line-doc   = tt0-fin-doc-tax.sum-slt-line-rubl
              .
            end.
          end.
          when v-curr-r-b then do:
            assign tt-fin-doc.sum-doc = tt-fin-doc.sum-base .
            for each tt0-fin-doc-tax no-lock :
              assign
                tt0-fin-doc-tax.sum-line-doc       = tt0-fin-doc-tax.sum-line-base
                tt0-fin-doc-tax.sum-vat-line-doc   = tt0-fin-doc-tax.sum-vat-line-base
                tt0-fin-doc-tax.sum-slt-line-doc   = tt0-fin-doc-tax.sum-slt-line-base
              .
            end.
          end.
          when buf_contract.curr-code then do:
            assign tt-fin-doc.sum-doc = tt-fin-doc.sum-contr .
            for each tt0-fin-doc-tax no-lock :
              assign
                tt0-fin-doc-tax.sum-line-doc       = tt0-fin-doc-tax.sum-line-contr
                tt0-fin-doc-tax.sum-vat-line-doc   = tt0-fin-doc-tax.sum-vat-line-contr
                tt0-fin-doc-tax.sum-slt-line-doc   = tt0-fin-doc-tax.sum-slt-line-contr
              .
            end.
          end.
          otherwise do:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  b2_fin-schet.curr-code
  ,input  today
  ,output tt-fin-doc.exch-rate
  ,output tt-fin-doc.exch-scale
  ,output curr-rc
  )  .
            assign
              is-full-sum = no
              tt-fin-doc.sum-doc = tt-fin-doc.sum-rubl * tt-fin-doc.exch-scale / tt-fin-doc.exch-rate
            .
          end.
        end.
      end.
    end.
    assign is-expense = yes .
    if tt-fin-doc.sum-rubl < 0 then do:
      assign is-expense = no .
      run InvertCli .
    end.
    for each tt0-fin-doc-tax :   if tt0-fin-doc-tax.sum-line-doc < 0 then assign is-full-sum = no .   end.
    if is-full-sum = no then do:
      run CorrectNalog in this-procedure .
    end.
    run RoundTax in this-procedure .
    if buf_contract.pay-nal = no then do:
      run StrTax (input-output sss) .
      assign tt-fin-doc.naznach-plat = tt-fin-doc.naznach-plat + "@" + sss .
    end.
    else if buf_contract.pay-nal = yes then do:
      run StrTax (input-output tt-fin-doc.including) .
    end.
  end.
END PROCEDURE.
define variable vss-include-info9 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
PROCEDURE StrTax :
  do
  on error undo, return error return-value
  :
    define input-output parameter str as character no-undo .
    assign str = " В т.ч.: "  .
    for each tt0-fin-doc-tax :
      if tt0-fin-doc-tax.with-vat = no then next.
      if str <> " В т.ч.: " then str = str + "," .
      if tt-fin-doc.curr-code = 0 then
        assign str = str + string(tt0-fin-doc-tax.vat-pc,">>9.9") + "% НДС - " + string(tt0-fin-doc-tax.sum-vat-line-doc) + " руб. (от суммы " + string(tt0-fin-doc-tax.sum-line-doc) + ") " .
      else
        assign str = str + string(tt0-fin-doc-tax.vat-pc,">>9.9") + "% НДС - " + string(tt0-fin-doc-tax.sum-vat-line-doc) + " (от суммы " + string(tt0-fin-doc-tax.sum-line-doc) + ") " .
    end.
    if str = " В т.ч.: " then assign str = "" .
  end.
END PROCEDURE.
PROCEDURE InvertCli :
  do
  on error undo, return error return-value
  :
      define variable payer-bank-name    like ub.fin-doc.payer-bank-name  .
      define variable payer-bank-city    like ub.fin-doc.payer-bank-city  .
      define variable payer-bik          like ub.fin-doc.payer-bik        .
      define variable payer-c-schet      like ub.fin-doc.payer-c-schet    .
      define variable payer-code         like ub.fin-doc.payer-code       .
      define variable payer-code-schet   like ub.fin-doc.payer-code-schet .
      define variable payer-inn          like ub.fin-doc.payer-inn        .
      define variable payer-kpp          like ub.fin-doc.payer-kpp        .
      define variable payer-name         like ub.fin-doc.payer-name       .
      define variable payer-okpo         like ub.fin-doc.payer-okpo       .
      define variable payer-passport     like ub.fin-doc.payer-passport   .
      define variable payer-r-schet      like ub.fin-doc.payer-r-schet    .
      define variable payer-type         like ub.fin-doc.payer-type       .
      assign
        tt-fin-doc.sum-rubl  = - tt-fin-doc.sum-rubl
        tt-fin-doc.sum-base  = - tt-fin-doc.sum-base
        tt-fin-doc.sum-doc   = - tt-fin-doc.sum-doc
        tt-fin-doc.sum-contr = - tt-fin-doc.sum-contr
        payer-bank-name      = tt-fin-doc.payer-bank-name
        payer-bank-city      = tt-fin-doc.payer-bank-city
        payer-bik            = tt-fin-doc.payer-bik
        payer-c-schet        = tt-fin-doc.payer-c-schet
        payer-code           = tt-fin-doc.payer-code
        payer-code-schet     = tt-fin-doc.payer-code-schet
        payer-inn            = tt-fin-doc.payer-inn
        payer-kpp            = tt-fin-doc.payer-kpp
        payer-name           = tt-fin-doc.payer-name
        payer-okpo           = tt-fin-doc.payer-okpo
        payer-passport       = tt-fin-doc.payer-passport
        payer-r-schet        = tt-fin-doc.payer-r-schet
        payer-type           = tt-fin-doc.payer-type
        tt-fin-doc.payer-bank-name    = tt-fin-doc.receiver-bank-name
        tt-fin-doc.payer-bank-city    = tt-fin-doc.receiver-bank-city
        tt-fin-doc.payer-bik          = tt-fin-doc.receiver-bik
        tt-fin-doc.payer-c-schet      = tt-fin-doc.receiver-c-schet
        tt-fin-doc.payer-code         = tt-fin-doc.receiver-code
        tt-fin-doc.payer-code-schet   = tt-fin-doc.receiver-code-schet
        tt-fin-doc.payer-inn          = tt-fin-doc.receiver-inn
        tt-fin-doc.payer-kpp          = tt-fin-doc.receiver-kpp
        tt-fin-doc.payer-name         = tt-fin-doc.receiver-name
        tt-fin-doc.payer-okpo         = tt-fin-doc.receiver-okpo
        tt-fin-doc.payer-passport     = tt-fin-doc.receiver-passport
        tt-fin-doc.payer-r-schet      = tt-fin-doc.receiver-r-schet
        tt-fin-doc.payer-type         = tt-fin-doc.receiver-type
        tt-fin-doc.receiver-bank-name =  payer-bank-name
        tt-fin-doc.receiver-bank-city =  payer-bank-city
        tt-fin-doc.receiver-bik       =  payer-bik
        tt-fin-doc.receiver-c-schet   =  payer-c-schet
        tt-fin-doc.receiver-code      =  payer-code
        tt-fin-doc.receiver-code-schet = payer-code-schet
        tt-fin-doc.receiver-inn       =  payer-inn
        tt-fin-doc.receiver-kpp       =  payer-kpp
        tt-fin-doc.receiver-name      =  payer-name
        tt-fin-doc.receiver-okpo      =  payer-okpo
        tt-fin-doc.receiver-passport  =  payer-passport
        tt-fin-doc.receiver-r-schet   =  payer-r-schet
        tt-fin-doc.receiver-type      =  payer-type
      .
      for each  tt0-fin-doc-tax no-lock :
        assign
          tt0-fin-doc-tax.sum-line-doc       = - tt0-fin-doc-tax.sum-line-doc
          tt0-fin-doc-tax.sum-vat-line-doc   = - tt0-fin-doc-tax.sum-vat-line-doc
          tt0-fin-doc-tax.sum-slt-line-doc   = - tt0-fin-doc-tax.sum-slt-line-doc
          tt0-fin-doc-tax.sum-line-rubl      = - tt0-fin-doc-tax.sum-line-rubl
          tt0-fin-doc-tax.sum-vat-line-rubl  = - tt0-fin-doc-tax.sum-vat-line-rubl
          tt0-fin-doc-tax.sum-slt-line-rubl  = - tt0-fin-doc-tax.sum-slt-line-rubl
          tt0-fin-doc-tax.sum-line-base      = - tt0-fin-doc-tax.sum-line-base
          tt0-fin-doc-tax.sum-vat-line-base  = - tt0-fin-doc-tax.sum-vat-line-base
          tt0-fin-doc-tax.sum-slt-line-base  = - tt0-fin-doc-tax.sum-slt-line-base
          tt0-fin-doc-tax.sum-line-contr     = - tt0-fin-doc-tax.sum-line-contr
          tt0-fin-doc-tax.sum-vat-line-contr = - tt0-fin-doc-tax.sum-vat-line-contr
          tt0-fin-doc-tax.sum-slt-line-contr = - tt0-fin-doc-tax.sum-slt-line-contr
        .
      end.
  end.
END PROCEDURE.
PROCEDURE CheckCli :
  do
  on error undo, return error return-value
  :
    if tt-fin-doc.payer-code = p-host-code and tt-fin-doc.payer-type = 'орг':U then do:
      assign
        tt-fin-doc.payer-bik        = buf_contract.own-bik
        tt-fin-doc.payer-code-schet = buf_contract.own-code-schet
        tt-fin-doc.payer-inn        = buf_contract.own-inn
        tt-fin-doc.payer-kpp        = buf_contract.own-kpp
      .
      if tt-fin-doc.receiver-code = buf_contract.cli-code and tt-fin-doc.receiver-type = buf_contract.cli-type then do:
        assign
          tt-fin-doc.receiver-bik        = buf_contract.cli-bik
          tt-fin-doc.receiver-code-schet = buf_contract.cli-code-schet
          tt-fin-doc.receiver-inn        = buf_contract.cli-inn
          tt-fin-doc.receiver-kpp        = buf_contract.cli-kpp
        .
      end.
      else do:
        if tt-fin-doc.receiver-code = buf_contract.posr-code and tt-fin-doc.receiver-type = buf_contract.posr-type then do:
          assign
            tt-fin-doc.receiver-bik        = buf_contract.posr-bik
            tt-fin-doc.receiver-code-schet = buf_contract.posr-code-schet
            tt-fin-doc.receiver-inn        = buf_contract.posr-inn
            tt-fin-doc.receiver-kpp        = buf_contract.posr-kpp
          .
        end.
        else do:
          assign
            tt-fin-doc.receiver-bik        = buf_contract.agnt-bik
            tt-fin-doc.receiver-code-schet = buf_contract.agnt-code-schet
            tt-fin-doc.receiver-inn        = buf_contract.agnt-inn
            tt-fin-doc.receiver-kpp        = buf_contract.agnt-kpp
          .
        end.
      end.
    end.
    else do:
      if tt-fin-doc.receiver-code = p-host-code and tt-fin-doc.receiver-type = 'орг':U then do:
        assign
          tt-fin-doc.receiver-bik        = buf_contract.own-bik
          tt-fin-doc.receiver-code-schet = buf_contract.own-code-schet
          tt-fin-doc.receiver-inn        = buf_contract.own-inn
          tt-fin-doc.receiver-kpp        = buf_contract.own-kpp
        .
        if tt-fin-doc.payer-code = buf_contract.cli-code and tt-fin-doc.payer-type = buf_contract.cli-type then do:
          assign
            tt-fin-doc.payer-bik        = buf_contract.cli-bik
            tt-fin-doc.payer-code-schet = buf_contract.cli-code-schet
            tt-fin-doc.payer-inn        = buf_contract.cli-inn
            tt-fin-doc.payer-kpp        = buf_contract.cli-kpp
          .
        end.
        else do:
          if tt-fin-doc.payer-code = buf_contract.posr-code and tt-fin-doc.payer-type = buf_contract.posr-type then do:
            assign
              tt-fin-doc.payer-bik        = buf_contract.posr-bik
              tt-fin-doc.payer-code-schet = buf_contract.posr-code-schet
              tt-fin-doc.payer-inn        = buf_contract.posr-inn
              tt-fin-doc.payer-kpp        = buf_contract.posr-kpp
            .
          end.
          else do:
            assign
              tt-fin-doc.payer-bik        = buf_contract.agnt-bik
              tt-fin-doc.payer-code-schet = buf_contract.agnt-code-schet
              tt-fin-doc.payer-inn        = buf_contract.agnt-inn
              tt-fin-doc.payer-kpp        = buf_contract.agnt-kpp
            .
          end.
        end.
      end.
      else return error .
    end.
  end.
END PROCEDURE.
PROCEDURE UchetCode :
  do
  on error undo, return error return-value
  :
    case tt-fin-doc.fin-doc-type :
      when 'пко':U then do:
        assign
          tt-fin-doc.cor-acc       = buf_contract.cor-acc-in-cash
          tt-fin-doc.cor-acc1      = buf_contract.cor-acc1-in-cash
          tt-fin-doc.cel-nazn-code = buf_contract.cel-nazn-code-in-cash
          tt-fin-doc.an-uchet-code = buf_contract.an-uchet-code-in-cash
        .
      end.
      when 'рко':U then do:
        assign
          tt-fin-doc.cor-acc       = buf_contract.cor-acc-out-cash
          tt-fin-doc.cor-acc1      = buf_contract.cor-acc1-out-cash
          tt-fin-doc.cel-nazn-code = buf_contract.cel-nazn-code-out-cash
          tt-fin-doc.an-uchet-code = buf_contract.an-uchet-code-out-cash
        .
      end.
      when 'ппп':U then do:
        assign
          tt-fin-doc.cor-acc       = buf_contract.cor-acc-in
          tt-fin-doc.cel-nazn-code = buf_contract.cel-nazn-code-in
          tt-fin-doc.an-uchet-code = buf_contract.an-uchet-code-in
        .
      end.
      when 'рпп':U then do:
        assign
          tt-fin-doc.cor-acc       = buf_contract.cor-acc-out
          tt-fin-doc.cel-nazn-code = buf_contract.cel-nazn-code-out
          tt-fin-doc.an-uchet-code = buf_contract.an-uchet-code-out
        .
      end.
      when 'апп':U then do:
        assign
          tt-fin-doc.cor-acc       = buf_contract.cor-acc-in-payoff
          tt-fin-doc.cor-acc1      = buf_contract.cor-acc1-in-payoff
          tt-fin-doc.cel-nazn-code = buf_contract.cel-nazn-code-in-payoff
          tt-fin-doc.an-uchet-code = buf_contract.an-uchet-code-in-payoff
        .
      end.
      when 'апр':U then do:
        assign
          tt-fin-doc.cor-acc       = buf_contract.cor-acc-out-payoff
          tt-fin-doc.cor-acc1      = buf_contract.cor-acc1-out-payoff
          tt-fin-doc.cel-nazn-code = buf_contract.cel-nazn-code-out-payoff
          tt-fin-doc.an-uchet-code = buf_contract.an-uchet-code-out-payoff
        .
      end.
    end.
    find first ub.fin-code-cel-nazn no-lock where ub.fin-code-cel-nazn.host-code = p-host-code and ub.fin-code-cel-nazn.fin-code = tt-fin-doc.cel-nazn-code no-error .
    if available ub.fin-code-cel-nazn then assign tt-fin-doc.cel-nazn-value = ub.fin-code-cel-nazn.code-value .
    find first ub.fin-code-an-uchet no-lock where ub.fin-code-an-uchet.host-code = p-host-code and ub.fin-code-an-uchet.fin-code = tt-fin-doc.an-uchet-code no-error .
    if available ub.fin-code-an-uchet then assign tt-fin-doc.an-uchet-value = ub.fin-code-an-uchet.code-value .
    find first ub.fin-code-cor-acc no-lock where ub.fin-code-cor-acc.host-code = p-host-code and ub.fin-code-cor-acc.fin-code = tt-fin-doc.cor-acc no-error .
    if available ub.fin-code-cor-acc then assign tt-fin-doc.cor-acc-value = ub.fin-code-cor-acc.code-value .
    find first ub.fin-code-cor-acc no-lock where ub.fin-code-cor-acc.host-code = p-host-code and ub.fin-code-cor-acc.fin-code = tt-fin-doc.cor-acc1 no-error .
    if available ub.fin-code-cor-acc then assign tt-fin-doc.cor-acc1-value = ub.fin-code-cor-acc.code-value .
  end.
END PROCEDURE.
PROCEDURE FindBank :
  do
  on error undo, return error return-value
  :
  find first b1_fin-schet no-lock where b1_fin-schet.host-code = p-host-code and b1_fin-schet.code-schet = tt-fin-doc.receiver-code-schet no-error .
  find first ub.fin-bank no-lock where ub.fin-bank.host-code = p-host-code and ub.fin-bank.code-bank = b1_fin-schet.code-bank no-error .
  if available b1_fin-schet then
  assign
    tt-fin-doc.receiver-bank-name  = ub.fin-bank.bank-name
    tt-fin-doc.receiver-bank-city  = ub.fin-bank.bank-city
    tt-fin-doc.receiver-c-schet    = b1_fin-schet.c-schet
    tt-fin-doc.receiver-r-schet    = b1_fin-schet.r-schet
  .
  find first b2_fin-schet no-lock where b2_fin-schet.host-code = p-host-code and b2_fin-schet.code-schet = tt-fin-doc.payer-code-schet no-error .
  find first ub.fin-bank no-lock where ub.fin-bank.host-code = p-host-code and ub.fin-bank.code-bank = b2_fin-schet.code-bank no-error .
  if available b2_fin-schet then
  assign
    tt-fin-doc.payer-bank-name  = ub.fin-bank.bank-name
    tt-fin-doc.payer-bank-city  = ub.fin-bank.bank-city
    tt-fin-doc.payer-c-schet    = b2_fin-schet.c-schet
    tt-fin-doc.payer-r-schet    = b2_fin-schet.r-schet
  .
  end.
END PROCEDURE.
