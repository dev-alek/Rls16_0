DEFINE TEMP-TABLE prod-cds NO-UNDO LIKE ub.prod-bc
       field cli-base-rate like ub.bar-code.cli-base-rate
       field unit-cli like ub.bar-code.unit-cli
       field in-code like ub.bar-code.in-code
       field part-code like ub.bar-code.part-code
       field price-sale like ub.price-list.price-sale
       field d-pcnt like ub.price-list.d-pcnt
       field dtl-name as char
       field rid as recid
       field doc-num like ub.price-doc.doc-num
       field is-global as logical
       field is-prod-bc as logical
       index pi is unique primary
       b-code b-str cr-db-num
       .
DEFINE INPUT  PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input  parameter p-obj-type like ub.clients.obj-type no-undo .
define input  parameter p-obj-code like ub.clients.obj-code no-undo .
define input  parameter mode     as char             no-undo.
define input  parameter g-code  like ub.goods.gds-code  no-undo.
define input  parameter base-bc like ub.bar-code.b-code no-undo.
define output parameter p-rec-list as char             no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список дополнительных кодов".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION MakeShbl RETURNS CHARACTER(input par-int1 as integer, input par-int2 as integer):
DEFINE VARIABLE ii as integer no-undo init 1.
DEFINE VARIABLE var-char1 as character no-undo .
DEFINE VARIABLE var-char2 as character no-undo .
DEFINE VARIABLE par-shbl as character no-undo .
assign
var-char1 = string(par-int1)
var-char2 = string(par-int2)
.
if length(var-char1) <> length(var-char2) then return error.
do while ii <= length(var-char1):
  if substring(var-char1, ii, 1) = substring(var-char2, ii, 1) then do:
    par-shbl = par-shbl + substring(var-char1, ii, 1).
  end.
  else do:
    par-shbl = par-shbl + fill("?", length(var-char1) - length(par-shbl)).
    return par-shbl.
  end.
  ii = ii + 1.
end.
END FUNCTION.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define buffer base-bar-code for ub.bar-code.
define variable mark as character  no-undo.
define variable rid  as recid no-undo.
define variable v-show-db-num as logical no-undo .
FUNCTION get-mark RETURNS CHARACTER
  (local-rid as recid)  FORWARD.
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON b-print
     LABEL "Пе&чать"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE QUERY br-cds FOR
      prod-cds SCROLLING.
DEFINE QUERY d-prod-cds FOR
      prod-cds SCROLLING.
DEFINE BROWSE br-cds
  QUERY br-cds DISPLAY
      get-mark (prod-cds.rid) @ mark format "x(1)"  column-label "*"
      prod-cds.bc-on                   format "+/"  column-label "+"
      prod-cds.b-str                                column-label "Доп. код"
      prod-cds.is-global               FORMAT "+/-" column-label "Глоб"
      prod-cds.cr-db-num             FORMAT ">>>>9" column-label "Создан(БД)"
      prod-cds.b-code                               column-label "Соб. код"
      prod-cds.cli-base-rate                        column-label "Коэф"
      prod-cds.d-pcnt                               column-label "Скидка"
      prod-cds.price-sale                           column-label "Цена"
      prod-cds.unit-cli                             column-label "Изм"
      prod-cds.dtl-name              format "x(20)" column-label "Привязка"
      prod-cds.doc-num                              column-label "Переоценка"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.3 BY 14.13.
DEFINE FRAME d-prod-cds
     br-cds AT ROW 2.37 COL 1.1
     b-print AT ROW 1 COL 92
     b-quit AT ROW 1 COL 1
     b-sel AT ROW 1 COL 11
     b-mark AT ROW 1 COL 21
     b-add AT ROW 1 COL 24
     b-help AT ROW 1 COL 95
     prod-cds.b-str AT ROW 16.77 COL 1.1 NO-LABEL FORMAT "X(256)"
          VIEW-AS FILL-IN
          SIZE 98.3 BY 1
          FGCOLOR 4
     SPACE(0.09) SKIP(0.22)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список дополнительных кодов"
         DEFAULT-BUTTON b-quit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME d-prod-cds:SCROLLABLE       = FALSE
       FRAME d-prod-cds:HIDDEN           = TRUE.
ASSIGN
       br-cds:NUM-LOCKED-COLUMNS IN FRAME d-prod-cds     = 3.
ON END-ERROR OF FRAME d-prod-cds
OR ENDKEY OF FRAME d-prod-cds DO:
   run gbl/markqwa.p (
                           input b-mark:sensitive
                          , input p-rec-list) no-error.
    if error-status:error then return no-apply.
END.
ON WINDOW-CLOSE OF FRAME d-prod-cds
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-add IN FRAME d-prod-cds
DO:
define variable sc-code like ub.bar-code.b-code no-undo .
DEFINE VARIABLE case-num as integer no-undo .
DEFINE VARIABLE vattr-codes as character no-undo .
DEFINE VARIABLE vattr-labels as character no-undo .
DEFINE VARIABLE voutput as character no-undo .
DEFINE VARIABLE is-ean as logical no-undo init yes.
DEFINE VARIABLE v-on as logical no-undo .
DEFINE VARIABLE v-b-str like ub.prod-bc.b-str no-undo .
define variable glog as logical no-undo .
define variable glog2 as logical no-undo .
define variable glog3 as logical no-undo .
define variable v-main-b-code as integer   no-undo .
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable unq-artc as logical no-undo .
define variable v-prt-rec as recid no-undo .
define variable v-cdrg-type as character no-undo .
define variable v-rid as recid no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
define buffer buf_code-range for ub.code-range.
define buffer goods_units for ub.units.
define buffer buf_goods for ub.goods.
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
find first buf_goods no-lock
     where buf_goods.gds-code = g-code no-error.
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_alt-barcode_preparation':U
    ,input  'object':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  buf_goods.grp-code
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
if not glog then return no-apply.
find first ub.units no-lock where
            ub.units.unit-name = base-bar-code.unit-cli No-ERROR.
if not avail ub.units then return no-apply.
find first goods_units no-lock where
            goods_units.unit-name = ub.goods.unit-base No-ERROR.
if not avail goods_units then return no-apply.
if lookup('вес':U, units.type) > 0 then do:
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_alt-barcode_gbl-sc-code':U
    ,input  'object':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  buf_goods.grp-code
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
  if not glog then case-num = 2.
  else do:
    run gbl/d-askw.w
    (input "Создание дополнительного кода"
    ,input "Вы действительно хотите создать дополнительный код?" + chr(10)
      + "(для весового товара здесь можно ввести только ГЛОБАЛЬНЫЙ ВЕСОВОЙ КОД)" + chr(10)
    ,input "|^"
    ,input "Глоб.вес. код|Отказ"
    ,input "Весовой код, который будет передан по СПН во все БД - ИХ КОЛИЧЕСТВО ОГРАНИЧЕНО|"
        + "Отказ от выполнения операции"
    ,input 1
    ,input 2
    ,output case-num
    ).
    if case-num = 2 then return no-apply.
    if case-num = 1 then do:
      v-cdrg-type = 'scgb':U.
      v-rid = ?.
      run trg/prod-bc1.p ( input parparentproc
                          ,input no
                          ,input ?
                          ,input ?
                          ,input no
                          ,input 'scgb':U
                          ,input ""
                          ,buffer goods
                          ,input base-bc
                          ,input-output v-b-str
                          ,output v-rid
                          ) no-error.
      if error-status :error
      or v-rid = ?
      then do:
        undo, return no-apply.
      end.
      else do:
        run UI-on.
        apply "entry" to br-cds in frame d-prod-cds.
        apply "value-changed" to br-cds.
        return no-apply.
      end.
    end.
  end.
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  goods.gds-code
  ,input  ?
  ,output v-main-b-code
  )  .
if lookup('шту':U, goods_units.type) > 0
and units.type = 'шту':U
and base-bc = v-main-b-code
then do:
  find first buf_code-range no-lock where
            buf_code-range.range-type = 'pglc':U
        and buf_code-range.db-num = 0  no-error.
  if available buf_code-range then do:
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_alt-barcode_loc-pg-code':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  buf_goods.grp-code
    ,input  0
    ,input  true
    ,output glog3
    )  .
end.
  end.
  if glog3 then do:
    for each thbjattr_thbj-attr:
      delete thbjattr_thbj-attr.
    end.
    run adm/shattri.p (
          input "get":U
        ,input  '':U
        ,input  0
        ,input  'gds-ref':U
        ,input  "":U
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
    IF error-status:error then do:
      delete object v-tth.
      message
      substitute("Ошибка при получении опций работы со справочником товаров:&1&2 &3"
                , chr(10)
                , error-status:get-message(1)
                , return-value )
      view-as alert-box error .
      undo, return no-apply .
    end.
    for each thbjattr_thbj-attr  where
            thbjattr_thbj-attr.obj-type = '':U
        and thbjattr_thbj-attr.obj-code = 0
        and thbjattr_thbj-attr.upper-prop-code = 'gds-ref':U
    :
      case thbjattr_thbj-attr.prop-code:
        when 'unq-artc':U then do :
          unq-artc = thbjattr_thbj-attr.property-value-logical.
        end.
      end case.
    end.
    if unq-artc then do:
      message
      substitute("В Вашей конфигурации диапазон штучных кодов для весов&1" +
                  "уже используется несовместимым образом,&1"  +
                  "поэтому ввод таких кодов ЗАПРЕЩЕН!"
                  , chr(10))
      view-as alert-box error .
      undo, return no-apply.
    end.
    run gbl/d-askw.w
    (input "Создание дополнительного кода"
    ,input substitute("Вы действительно хотите создать дополнительный код?&1" +
                      "(для штучного товара здесь можно ввести обычный Доп. БК&1" +
                      "или ЛОКАЛЬНЫЙ ШТУЧНЫЙ КОД ДЛЯ ВЕСОВ)", chr(10))
    ,input "|^"
    ,input substitute("Обычный Доп.БК|Лок.штучный|Отказ"
                      )
    ,input ("Обычный Доп.БК производителя товара|"
        +  "Локальный Код, по которому для товара будет печататься на весах этикетка с указанием количества - ИХ КОЛИЧЕСТВО ОГРАНИЧЕНО|"
        + "Отказ от выполнения операции")
    ,input 1
    ,input 3
    ,output case-num
    ).
    if case-num = 3 then return no-apply.
    if case-num = 2 then do:
      v-rid = ?.
      run trg/prod-bc1.p ( input parparentproc
                          ,input no
                          ,input ?
                          ,input ?
                          ,input no
                          ,input 'pglc':U
                          ,input ""
                          ,buffer goods
                          ,input base-bc
                          ,input-output v-b-str
                          ,output v-rid
                          ) no-error.
      if error-status :error
      or v-rid = ?
      then do:
        undo, return no-apply.
      end.
      else do:
        run UI-on.
        apply "entry" to br-cds in frame d-prod-cds.
        apply "value-changed" to br-cds.
        return no-apply.
      end.
    end.
  end.
end.
if lookup('вес':U, goods_units.type) > 0 and units.type = 'дро':U then do:
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_alt-barcode_loc-ss-code':U
    ,input  'object':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  buf_goods.grp-code
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_alt-barcode_gbl-ss-code':U
    ,input  'object':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  buf_goods.grp-code
    ,input  0
    ,input  true
    ,output glog2
    )  .
end.
  if not glog and not glog2 then case-num = 3.
  else do:
    run gbl/d-askw.w
    (input "Создание дополнительного кода"
    ,input "Вы действительно хотите создать дополнительный код?" + chr(10)
      + "(для весового товара здесь можно ввести только ЛОКАЛЬНЫЙ ИЛИ ГЛОБАЛЬНЫЙ КОД ВЗВЕШИВАЕМОГО ТОВАРА)" + chr(10)
    ,input "|^"
    ,input substitute("Лок.взвеш.код&1|Глоб.взвеш.код&2|Отказ"
                      , (if glog then "" else "^disable")
                      , (if glog2 then "" else "^disable"))
    ,input ("Локальный Код, по которому товар будет взвешиваться на сканер-весах кассы - ИХ КОЛИЧЕСТВО ОГРАНИЧЕНО|"
        +  "Глобальный Код, по которому товар будет взвешиваться на сканер-весах кассы - ИХ КОЛИЧЕСТВО ОГРАНИЧЕНО|"
        + "Отказ от выполнения операции")
    ,input 1
    ,input 3
    ,output case-num
    ).
  end.
  if case-num = 3 then return no-apply.
  if case-num = 1
  or case-num = 2
  then do:
    if case-num = 1 then v-cdrg-type = 'sslc':U.
    if case-num = 2 then v-cdrg-type = 'ssgb':U.
    FOR EACH ub.code-range No-LOCK WHERE
        ub.code-range.range-type = (if case-num = 1 then 'sslc':U else 'ssgb':U)
        and ub.code-range.db-num = (if case-num = 1 then 0 else v-cntxt-db-num)
    :
      assign
      vattr-labels = vattr-labels +
                     (if vattr-labels = "":U
                      then "":U
                      else chr(44)) +
                      string(ub.code-range.first-code, "999999999") + "-":U + string(ub.code-range.last-code, "999999999") +
                      fill(chr(32), 5) + "----->":U +
                      fill(chr(32), 5) +
                      MakeShbl(ub.code-range.first-code , ub.code-range.last-code)
      vattr-codes =  vattr-codes +
                     (if vattr-codes = "":U
                      then "":U
                      else chr(44)) +
                      chr(32) +
                      MakeShbl(ub.code-range.first-code , ub.code-range.last-code)
      .
    end.
    run gbl/d-list.w (
                  INPUT "b-sel":U
                  ,INPUT (if case-num = 1
                          then "Диапазоны и шаблоны локальных взвешиваемых кодов"
                          else "Диапазоны и шаблоны глобальных взвешиваемых кодов")
                  ,INPUT vattr-codes
                  ,INPUT vattr-labels
                  ,INPUT chr(44)
                  ,INPUT "":U
                  ,output voutput).
    IF voutput = "":u THEN RETURN NO-APPLY.
    is-ean = no.
  end.
end.
case mode:
  when "code-all"
  then do:
    run ref/pbc-form.w
      (input parparentproc
      ,input base-bc
      ,input trim(voutput)
      ,input is-ean
      ,input v-cdrg-type
      ,input-output rid
      ).
  end.
  when "scl-gds-all"
  then do:
    define variable v-sel-node-code as integer   no-undo .
    run str/prt-ref.w
      (input parparentproc
      ,input  goods.gds-code
      ,input  'ПРОСМОТР':U
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  ""
      ,input  ""
      ,output v-sel-node-code
      ) .
  end.
  when "par-gds-all"
  then do:
    define variable v-chk-act-host-code as integer   no-undo .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-chk-act-host-code
  )  .
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_archive_cost':U
    ,input  'object':U
    ,input  v-chk-act-host-code
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
    if NOT glog then
      return no-apply .
    run str/parts-l.w
      (
       input parparentproc
      ,input p-obj-type
      ,input p-obj-code
      ,input goods.gds-code
      ,input ""
      ,input 'ПРОСМОТР':U
      ,input 'остатки':U
      ,input 'текущий':U
      ,input 'справочник':U
      ,output v-prt-rec
      ) .
  end.
  otherwise do:
    message
      "Для данного режима добавление не работает."
      view-as alert-box.
    return no-apply.
  end.
end case.
run UI-on.
END.
ON CHOOSE OF b-mark IN FRAME d-prod-cds
DO:
if not available prod-cds then  return no-apply.
define variable v-num-entry as integer no-undo .
if prod-cds.is-prod-bc = no
and prod-cds.cr-db-num <> v-cntxt-db-num
and not(prod-cds.is-global)
then do:
  message
  "Нельзя выбрать неглобальный ДопБК другой БД!"
  view-as alert-box error .
  return no-apply.
end.
if prod-cds.rid = ? then do:
  message
  "Нельзя выбрать ДопБК другой БД!"
  view-as alert-box error .
  return no-apply.
end.
assign
v-num-entry = lookup(string( prod-cds.rid ), p-rec-list ).
if v-num-entry > 0 then do:
  assign
    entry(v-num-entry, p-rec-list) = "":U
    p-rec-list = replace( p-rec-list, chr(44) + chr(44), chr(44)) .
    p-rec-list = trim(p-rec-list, chr(44)).
end.
else do:
  assign
    p-rec-list = p-rec-list + ( if p-rec-list = "":U then "":U else chr(44) ) + string( prod-cds.rid ) .
end.
br-cds :refresh ().
if last-event :function <> "mouse-select-dblclick" then
  br-cds :select-next-row ().
apply "entry" to br-cds in frame d-prod-cds.
END.
ON CHOOSE OF b-print IN FRAME d-prod-cds
DO:
  if available (prod-cds) then do:
   run print-label in this-procedure(prod-cds.rid) no-error.
   if error-status:error then do:
    return no-apply.
   end.
   end.
END.
ON CHOOSE OF b-quit IN FRAME d-prod-cds
DO:
  p-rec-list= ''.
END.
ON CHOOSE OF b-sel IN FRAME d-prod-cds
DO:
if p-rec-list = "" and
   available prod-cds then
  p-rec-list = string (prod-cds.rid).
END.
ON MOUSE-SELECT-DBLCLICK OF br-cds IN FRAME d-prod-cds
DO:
apply "choose" to b-mark in frame d-prod-cds.
END.
ON RETURN OF br-cds IN FRAME d-prod-cds
DO:
apply "choose" to b-mark in frame d-prod-cds.
END.
ON VALUE-CHANGED OF br-cds IN FRAME d-prod-cds
DO:
if available prod-cds then
  disp prod-cds.b-str with frame d-prod-cds.
END.
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame d-prod-cds anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame d-prod-cds. END.
  return no-apply.
end.
define variable vss-include-info13 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame d-prod-cds anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame d-prod-cds. END.
  return no-apply.
end.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-prod-cds:PARENT eq ?
THEN FRAME d-prod-cds:PARENT = ACTIVE-WINDOW.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-prod-cds
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
on choose of b-help in frame d-prod-cds
do:
  apply "help":u to frame d-prod-cds .
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
                v-frame-width = frame d-prod-cds:width - 0.3
                fh            = frame d-prod-cds:first-child
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
    if frame d-prod-cds :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame d-prod-cds :height-chars)
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
    if frame d-prod-cds :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame d-prod-cds :height-chars)
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
            frame d-prod-cds :height = v-frame-height
          .
          if frame d-prod-cds :scrollable = true
          then do:
            assign
              frame d-prod-cds :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-prod-cds :scrollable = true
          then do:
            assign
              frame d-prod-cds :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame d-prod-cds :height = v-frame-height
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
      v-frame-height = frame d-prod-cds :height
      v-frame-virtual-height = frame d-prod-cds :virtual-height
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
      v-field-group-handle = frame d-prod-cds :first-child
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
    do with frame d-prod-cds
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame d-prod-cds :scrollable = true
      then do:
        assign
          frame d-prod-cds :virtual-height = frame d-prod-cds :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame d-prod-cds :height = frame d-prod-cds :height + p-change-value
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
        frame d-prod-cds :height = frame d-prod-cds :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame d-prod-cds :scrollable = true
      then do:
        assign
          frame d-prod-cds :virtual-height = frame d-prod-cds :virtual-height + p-change-value
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
          ,input  string(frame d-prod-cds :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame d-prod-cds :height)
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
    if frame d-prod-cds :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame d-prod-cds :width
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
    if frame d-prod-cds :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame d-prod-cds :width
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
            frame d-prod-cds :width = v-frame-width
          .
          if frame d-prod-cds :scrollable = true
          then do:
            assign
              frame d-prod-cds :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-prod-cds :scrollable = true
          then do:
            assign
              frame d-prod-cds :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame d-prod-cds :width = v-frame-width
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
      v-frame-width = frame d-prod-cds :width
      v-frame-virtual-width = frame d-prod-cds :virtual-width
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
      v-field-group-handle = frame d-prod-cds :first-child
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
    do with frame d-prod-cds
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame d-prod-cds :scrollable = true
      then do:
        assign
          frame d-prod-cds :virtual-width = frame d-prod-cds :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame d-prod-cds :width = v-frame-width + p-change-value
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
        frame d-prod-cds :width = frame d-prod-cds :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame d-prod-cds :scrollable = true
      then do:
        assign
          frame d-prod-cds :virtual-width = frame d-prod-cds :virtual-width + p-change-value
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
          ,input  string(frame d-prod-cds :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame d-prod-cds :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame d-prod-cds
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame d-prod-cds :height - v-diasize-resize-button :height
                  - 1
                  - (frame d-prod-cds :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame d-prod-cds :width - v-diasize-resize-button :width
                  - 1
                  - (frame d-prod-cds :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame d-prod-cds
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
      v-row-delta = v-new-row - frame d-prod-cds :height
      v-col-delta = v-new-col - frame d-prod-cds :width
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
            - frame d-prod-cds :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame d-prod-cds :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame d-prod-cds :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame d-prod-cds :height-chars
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
      v-diasize-current-frame-width  = frame d-prod-cds :width
      v-diasize-current-frame-height = frame d-prod-cds :height
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
    do with frame d-prod-cds
    :
      assign
        v-diasize-orig-frame-height = frame d-prod-cds :height
        v-diasize-orig-frame-width  = frame d-prod-cds :width
        v-diasize-browse-handle     = browse br-cds :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame d-prod-cds :first-child
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-cds as INT EXTENT 10 no-undo.
DEF VAR varmvibr-cds       as INT no-undo.
DEF VAR varmvjbr-cds       as INT no-undo.
DEF VAR varmvkbr-cds       as INT no-undo.
DEF VAR varmvlbr-cds       as INT no-undo.
DEF VAR move-elementbr-cds as INT no-undo.
def var jjbr-cds           as int no-undo.
do varmvibr-cds = 1 to EXTENT(cur-clmn-numbr-cds):
  ASSIGN cur-clmn-numbr-cds[varmvibr-cds] = varmvibr-cds.
END.
RUN start-mv-clmnbr-cds.
PROCEDURE start-mv-clmnbr-cds:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-cds do:
  RUN re-move-clmnbr-cds ( 4, 10).
END.
ON ctrl-cursor-left OF BROWSE br-cds do:
  RUN re-move-clmnbr-cds (10, 4).
END.
PROCEDURE re-move-clmnbr-cds:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-cds = 1 TO EXTENT(cur-clmn-numbr-cds):
    if cur-clmn-numbr-cds[varmvibr-cds] = source-column THEN cur-clmn-numbr-cds[varmvibr-cds] = -1.
  END.
  if br-cds:MOVE-COLUMN(source-column, target-column) IN FRAME d-prod-cds then.
  if source-column > target-column THEN
  DO varmvjbr-cds = source-column - 1 to target-column BY -1:
    DO varmvibr-cds = 1 TO EXTENT(cur-clmn-numbr-cds):
        if cur-clmn-numbr-cds[varmvibr-cds] = varmvjbr-cds THEN DO:
          cur-clmn-numbr-cds[varmvibr-cds] = cur-clmn-numbr-cds[varmvibr-cds] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-cds = source-column + 1 to target-column:
    DO varmvibr-cds = 1 TO EXTENT(cur-clmn-numbr-cds):
      if cur-clmn-numbr-cds[varmvibr-cds] = varmvjbr-cds THEN DO:
        cur-clmn-numbr-cds[varmvibr-cds] = cur-clmn-numbr-cds[varmvibr-cds] - 1.
      END.
    END.
  END.
  DO varmvibr-cds = 1 TO EXTENT(cur-clmn-numbr-cds):
    if cur-clmn-numbr-cds[varmvibr-cds] = -1 THEN cur-clmn-numbr-cds[varmvibr-cds] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-cds:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 4 then do:
    return .
  end.
  DO varmvibr-cds = 1 TO EXTENT(cur-clmn-numbr-cds):
    if cur-clmn-numbr-cds[varmvibr-cds] = cur-clmn-loc THEN move-elementbr-cds = varmvibr-cds.
  END.
  RUN re-move-clmnbr-cds (cur-clmn-loc, 4).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-cds:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-cds = 4 to EXTENT(cur-clmn-numbr-cds):
    RUN re-move-clmnbr-cds (cur-clmn-numbr-cds[varmvlbr-cds], varmvlbr-cds).
  END.
  RUN start-mv-clmnbr-cds.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  find ub.goods no-lock where
       ub.goods.gds-code = g-code.
  find first ub.gds-prt no-lock where
             ub.gds-prt.upper-code = ub.goods.prt-root.
  find base-bar-code no-lock where
       base-bar-code.b-code  = base-bc.
  if base-bar-code.gds-code <> ub.goods.gds-code then do:
    message
      "Ошибка параметров prod-cds.w"
      view-as alert-box.
    return error.
  end.
  RUN UI-on.
  WAIT-FOR GO OF FRAME d-prod-cds.
END.
RUN disable_UI.
PROCEDURE cre-prod :
define input parameter bc like ub.bar-code.b-code.
define buffer buf-bar-code for ub.bar-code.
define buffer buf-prod-bc  for ub.prod-bc.
define buffer buf_prod-bc-db  for ub.prod-bc-db.
define buffer buf-gds-prt  for ub.gds-prt.
define buffer buf_Units    for ub.units.
define variable local-dtl-name as character                     no-undo.
define variable pr-rec         as recid                    no-undo.
define variable pr-c-b-r       like ub.bar-code.cli-base-rate no-undo.
define variable v-is-scales-code as logical no-undo .
find buf-bar-code no-lock where
     buf-bar-code.b-code = bc.
find buf-gds-prt no-lock where
     buf-gds-prt.node-code = buf-bar-code.node-code.
if not buf-gds-prt.root and
   not buf-gds-prt.is-term then
  return.
if buf-gds-prt.upper-code = ub.goods.prt-root then
  if buf-bar-code.in-code = "" then
    local-dtl-name = "".
  else
    if buf-bar-code.part-code = "" then
      local-dtl-name = buf-bar-code.in-code.
    else
      local-dtl-name = buf-bar-code.in-code + " (" + buf-bar-code.part-code + ")".
else
  local-dtl-name = buf-gds-prt.f-name.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodepls in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  buf-bar-code.b-code
  ,input  0
  ,input  0
  ,output pr-rec
  ,output pr-c-b-r
  )  .
if v-cntxt-db-num-obj <> v-cntxt-db-num then do:
  find first buf_units no-lock where
            buf_units.unit-name = buf-bar-code.unit-cli .
  if lookup('вес':U, buf_units.type) > 0 then do:
    v-is-scales-code = yes.
  end.
end.
find  ub.price-list no-lock where
      recid (ub.price-list) = pr-rec no-error.
   v-show-db-num = no.
  _buf-prod-bc:
  for each buf-prod-bc no-lock where
          buf-prod-bc.b-code = bc
  :
    create prod-cds.
    buffer-copy buf-prod-bc to prod-cds
      assign
        prod-cds.cli-base-rate = buf-bar-code.cli-base-rate
        prod-cds.unit-cli      = buf-bar-code.unit-cli
        prod-cds.in-code       = buf-bar-code.in-code
        prod-cds.part-code     = buf-bar-code.part-code
        prod-cds.rid           = recid (buf-prod-bc)
        prod-cds.dtl-name      = local-dtl-name
    prod-cds.is-prod-bc    = yes
        .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbctv in g#library
  (input prod-cds.b-str
  ,input  prod-cds.unit-cli
  ,input  goods.unit-base
  ,input  'global=request'
  ,output prod-cds.is-global
  ) no-error .
      if error-status:error then do:
        prod-cds.is-global = ?.
      end.
    if available price-list and
      price-list.b-code = buf-bar-code.b-code then
      assign
        prod-cds.price-sale = price-list.price-sale
        prod-cds.d-pcnt     = price-list.d-pcnt
        prod-cds.doc-num    = price-list.doc-num
        .
    else
      if available price-list then
        assign
          prod-cds.price-sale = price-list.price-sale * buf-bar-code.cli-base-rate
          prod-cds.d-pcnt     = 0
          prod-cds.doc-num    = "-"
          .
      else
        assign
          prod-cds.price-sale = ?
          prod-cds.d-pcnt     = ?
          prod-cds.doc-num    = ?
          .
  end.
if v-cntxt-db-num-obj = v-cntxt-db-num
or v-is-scales-code = no
then do:
end.
else do:
   v-show-db-num = yes.
  _buf-prod-bc:
  for each buf_prod-bc-db no-lock where
          buf_prod-bc-db.b-code = bc
  :
    find first prod-cds no-lock where
              prod-cds.b-code = bc
          and prod-cds.b-str  = buf_prod-bc-db.b-str
          and prod-cds.cr-db-num = buf_prod-bc-db.db-num no-error.
    if not available prod-cds then do:
    create prod-cds.
    buffer-copy buf_prod-bc-db to prod-cds
      assign
        prod-cds.cli-base-rate = buf-bar-code.cli-base-rate
        prod-cds.unit-cli      = buf-bar-code.unit-cli
        prod-cds.in-code       = buf-bar-code.in-code
        prod-cds.part-code     = buf-bar-code.part-code
        prod-cds.dtl-name      = local-dtl-name
    prod-cds.cr-db-num     = buf_prod-bc-db.db-num
        .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbctv in g#library
  (input prod-cds.b-str
  ,input  prod-cds.unit-cli
  ,input  goods.unit-base
  ,input  'global=request'
  ,output prod-cds.is-global
  ) no-error .
    if error-status:error then do:
      prod-cds.is-global = ?.
    end.
    if v-is-scales-code
    and (prod-cds.is-global
    or prod-cds.is-global = ?
    or prod-cds.cr-db-num = v-cntxt-db-num
    )
    then do:
      define buffer buf_prod-bc for ub.prod-bc.
      find first buf_prod-bc no-lock where
                buf_prod-bc.b-str = prod-cds.b-str
            and buf_prod-bc.b-code = prod-cds.b-code no-error.
      if available buf_prod-bc then do:
        prod-cds.rid           = recid (buf_prod-bc).
      end.
    end.
    if available price-list and
      price-list.b-code = buf-bar-code.b-code then
      assign
        prod-cds.price-sale = price-list.price-sale
        prod-cds.d-pcnt     = price-list.d-pcnt
        prod-cds.doc-num    = price-list.doc-num
        .
    else
      if available price-list then
        assign
          prod-cds.price-sale = price-list.price-sale * buf-bar-code.cli-base-rate
          prod-cds.d-pcnt     = 0
          prod-cds.doc-num    = "-"
          .
      else
        assign
          prod-cds.price-sale = ?
          prod-cds.d-pcnt     = ?
            prod-cds.doc-num    = ?.
    end.
  end.
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME d-prod-cds.
END PROCEDURE.
PROCEDURE enable_UI :
  IF AVAILABLE prod-cds THEN
    DISPLAY prod-cds.b-str
      WITH FRAME d-prod-cds.
  ENABLE br-cds b-print b-quit b-sel b-mark b-add b-help
      WITH FRAME d-prod-cds.
  VIEW FRAME d-prod-cds.
  OPEN QUERY br-cds FOR EACH prod-cds NO-LOCK.
END PROCEDURE.
PROCEDURE print-label :
define input parameter p-rid as recid no-undo.
define variable loc#log as logical no-undo.
define buffer buf_prod-bc for ub.prod-bc .
find first buf_prod-bc no-lock where
            recid(buf_prod-bc) = p-rid no-error.
if not available buf_prod-bc then return error.
if buf_prod-bc.bc-on = no then do:
    message
    "Данный ДопБК выключен" skip
    "Вы действительно хотите напечать этикетку на него?"
    view-as alert-box QUestion buttons YEs-No update loc#log.
    if not loc#log then return error.
end.
    run rep/tick-pbc.p (      input parparentproc
                        ,input p-obj-type
                        ,input p-obj-code
                        ,input recid(buf_prod-bc)
                        ,input buf_prod-bc.b-code
                        ) no-error.
    if error-status:error then return error.
END PROCEDURE.
PROCEDURE UI-on :
ENABLE b-quit b-sel b-mark b-help br-cds b-print WITH FRAME d-prod-cds.
VIEW FRAME d-prod-cds.
for each prod-cds
:
  delete prod-cds.
end.
case mode:
  when "all-no-part" then do:
    frame d-prod-cds :title = "Все ДопБК на все имеющиеся основные и неосновные бар-коды:   " +
                                 "Основной код: " + string (base-bc, ">>>>>>>>9")
                                 .
    for each ub.bar-code no-lock where
             ub.bar-code.gds-code  = base-bar-code.gds-code:
      if ub.bar-code.in-code   = base-bar-code.in-code and
      ub.bar-code.part-code = base-bar-code.part-code then do:
        run cre-prod (ub.bar-code.b-code).
      end.
    end.
  end.
  when "code-all" then do:
    if base-bar-code.unit-cli = ub.goods.unit-cli then do:
      frame d-prod-cds :title = "Все дополнительные коды:   Основной код: " + string (base-bc, "999999999") +
                                  "   Товар: " + ub.goods.artic + "  " + ub.goods.gds-name
                                  .
      for each ub.bar-code no-lock where
              ub.bar-code.gds-code  = base-bar-code.gds-code and
              ub.bar-code.node-code = base-bar-code.node-code and
              ub.bar-code.in-code   = base-bar-code.in-code and
              ub.bar-code.part-code = base-bar-code.part-code
      :
        run cre-prod (ub.bar-code.b-code).
      end.
    end.
    else do:
      frame d-prod-cds :title = "Все дополнительные коды:   Неосновной код: " + string (base-bc, "999999999") +
                                  "   Товар: " + goods.artic + "  " + goods.gds-name
                                  .
      run cre-prod (base-bar-code.b-code).
    end.
    ENABLE b-add WITH FRAME d-prod-cds.
  end.
  when "scl-gds-all" then do:
    frame d-prod-cds :title = "Все дополнительные коды по признакам:   " +
                                 "Товар: " + ub.goods.artic + "  " + ub.goods.gds-name
                                 .
    for each ub.bar-code no-lock where
             ub.bar-code.gds-code  = base-bar-code.gds-code and
             ub.bar-code.in-code   = ""
    :
      run cre-prod (ub.bar-code.b-code).
    end.
    ENABLE b-add WITH FRAME d-prod-cds.
  end.
  when "par-gds-all" then do:
    frame d-prod-cds :title = "Все дополнительные коды по партиям:   " +
                                 "Товар: " + ub.goods.artic + "  " + ub.goods.gds-name
                                 .
    for each ub.bar-code no-lock where
             ub.bar-code.gds-code  = base-bar-code.gds-code and
             ub.bar-code.in-code  <> ""
    :
      run cre-prod (ub.bar-code.b-code).
    end.
    ENABLE b-add WITH FRAME d-prod-cds.
  end.
  when "gds-all" then do:
    frame d-prod-cds :title = "Все дополнительные коды по товару:   " +
                                 "Товар: " + ub.goods.artic + "  " + ub.goods.gds-name
                                 .
    for each ub.bar-code no-lock where
             ub.bar-code.gds-code  = base-bar-code.gds-code
    :
      run cre-prod (ub.bar-code.b-code).
    end.
  end.
  when "code-current" then do:
    frame d-prod-cds :title = "Все дополнительные коды по товару:   Код: " + string (base-bc, "999999999") +
                                 "  Товар: " + ub.goods.artic + "  " + ub.goods.gds-name
                                 .
    run cre-prod (base-bar-code.b-code).
  end.
  when "code-current-other-db-scale" then do:
    frame d-prod-cds :title = "Все дополнительные коды по товару:   Код: " + string (base-bc, "999999999") +
                                 "  Товар: " + ub.goods.artic + "  " + ub.goods.gds-name
                                 .
    run cre-prod (base-bar-code.b-code).
  end.
end case.
frame d-prod-cds :title = frame d-prod-cds :title +
                             "      Текущий объект: " + string (p-obj-type, "x(3)") +
                             " " + string (p-obj-code, ">>>>9").
open query br-cds
  for each prod-cds no-lock.
apply "value-changed" to br-cds in frame d-prod-cds.
END PROCEDURE.
FUNCTION get-mark RETURNS CHARACTER
  (local-rid as recid) :
if local-rid = ? then return "".
if lookup (string (local-rid), p-rec-list) > 0 then
  return "*".
else
  return "".
END FUNCTION.
