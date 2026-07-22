block-level on error undo, throw.
define input  parameter p-mode as character no-undo .
define input  parameter p-silent as logical   no-undo .
define input  parameter p-b-code as integer   no-undo .
define input  parameter p-gds-code as integer   no-undo .
define input  parameter p-node-code as integer   no-undo .
define input  parameter p-part-code as character no-undo .
define input  parameter p-in-code as character no-undo .
define input  parameter p-unit-cli as character no-undo .
define input  parameter p-cli-base-rate as decimal no-undo .
define output parameter p-rid as recid no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: barcode1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/barcode1.p $":U .
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$".
procedure chk-b-code:
define input parameter p-silence as logical no-undo .
define input param b-c like ub.bar-code.b-code no-undo.
define output param p-log as log no-undo.
  define variable l-code as integer no-undo.
  define variable v-mes as character no-undo .
  define variable v-param-type0 as character no-undo .
  define variable v-value-character0 as INTEGER no-undo .
  define variable v-value-date0 as date no-undo .
  define variable v-value-decimal0 as decimal no-undo .
  define variable v-value-integer0 AS integer no-undo .
  define variable v-value-logical0 AS LOGICAL no-undo .
  define variable v-tth0 as handle no-undo .
  define buffer buf_sys-ctrl for ub.sys-ctrl.
  define buffer b-c-r for ub.code-range.
  define buffer buf_code-range for ub.code-range .
  do
  on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-workfile )
  on endkey undo , return error substitute( "&1. endkey", vss-workfile )
  :
    find first buf_sys-ctrl no-lock.
    p-log = no.
    run adm/shattri.p (
        input "get":U
        ,input  'БД':U
        ,input  buf_sys-ctrl.db-num
        ,input  'code-range':U
        ,input  'cdrgbcgb':U
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
      v-mes = substitute("Ошибка при получении размера диапазона собственных глобальных кодов&2&1&2&3"
                         , error-status:get-message(1)
                         , chr(10)
                         , return-value ).
      if not p-silence then
      message
      v-mes
      view-as alert-box error.
      p-log = no.
      undo, return error v-mes.
    end.
    delete object v-tth0.
    find first buf_code-range
      where buf_code-range.range-type = 'bcgb':U
        and buf_code-range.last-code >= b-c
        and buf_code-range.db-num = g#db-num
    use-index last-codei
  no-lock no-error .
    if available buf_code-range and buf_code-range.first-code <= b-c then do:
      case buf_code-range.stts:
      when "a" then do:
          if buf_code-range.db-num <> buf_sys-ctrl.db-num then do:
          assign
          v-mes = substitute("Нельзя использовать активный диапазон чужой БД для генерации бар-кодов в БД").
          if not p-silence then
          message v-mes
          view-as alert-box error.
          p-log = no.
          undo, return error v-mes.
        end.
        p-log = yes.
      end.
      when "f" then do:
          if buf_code-range.db-num = -1
          or buf_code-range.db-num <> buf_sys-ctrl.db-num
          then do:
          assign
            v-mes = substitute("Нельзя использовать свободный диапазон БД для генерации бар-кодов:&1" +
                               "текущая БД &2, диапазон (&3 - &4) для БД &5&1"
                               ,chr(10)
                               ,buf_sys-ctrl.db-num
                               ,buf_code-range.first-code
                               ,buf_code-range.last-code
                               ,buf_code-range.db-num
                               ).
          if not p-silence then
          message v-mes
          view-as alert-box error.
          p-log = no.
          undo, return error v-mes .
        end.
          find b-c-r where recid(b-c-r) = recid(buf_code-range) exclusive no-error.
        if (not available b-c-r) or (b-c-r.db-num <> buf_sys-ctrl.db-num) then do:
          p-log = no.
          undo, return error.
        end.
        assign
          b-c-r.stts = "u"
            b-c-r.db-num = buf_sys-ctrl.db-num
          p-log = yes.
      end.
      when "u" then do:
          if (buf_code-range.db-num > 0 and buf_sys-ctrl.db-num = 0) or
             (buf_sys-ctrl.db-num <> 0 and buf_code-range.db-num <> buf_sys-ctrl.db-num)  then do:
          assign
          v-mes = substitute("Нельзя использовать использованный чужой диапазон БД для генерации бар-кодов в БД").
          if not p-silence then
          message v-mes
          view-as alert-box error.
          p-log = no.
          undo, return error v-mes.
        end.
        assign
          p-log = yes.
      end.
    end case.
  end.
    else do:
      if buf_sys-ctrl.db-num <> 0 then do:
      assign
      v-mes = substitute("Нельзя создавать диапазоны в УБД ").
      if not p-silence then
      message v-mes
      view-as alert-box error.
      undo, return error v-mes.
    end.
    find first buf_code-range
      where buf_code-range.range-type = 'bcgb':U
        and buf_code-range.last-code >= b-c
        and buf_code-range.first-code <= b-c
    no-lock no-error .
    if available buf_code-range
    and buf_code-range.db-num <> g#db-num then do:
      assign
      v-mes = substitute("Диапазон для кода &1 (&2-&3) принадлежит БД &4"
                          , b-c
                          , buf_code-range.first-code
                          , buf_code-range.last-code
                          , buf_code-range.db-num
                  ).
      if not p-silence then
      message v-mes
      view-as alert-box error.
      undo, return error v-mes.
    end.
      _l-code:
      do while true :
        run new-bcod-gen-code-range in this-procedure ( input g#db-num
                                                       ,input 'bcgb':U).
        find first buf_code-range where
          buf_code-range.range-type = 'bcgb':U
            and buf_code-range.db-num = g#db-num
            and buf_code-range.last-code >= b-c
            and buf_code-range.first-code <= b-c  no-lock no-error .
        if available buf_code-range then do:
          find b-c-r where recid(b-c-r) = recid(buf_code-range) exclusive .
          b-c-r.stts = 'u':U.
          p-log = yes.
          leave _l-code.
        end.
    end.
  end.
end.
end procedure.
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
define buffer buf_units for ub.units.
define buffer base_units for ub.units.
define buffer buf_goods for ub.goods.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_gds-prt for ub.gds-prt.
define variable v-err-mess as character no-undo .
define variable v-is-new as logical no-undo .
define variable v-import as logical   no-undo .
define variable glog as logical   no-undo .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if num-entries(p-mode) > 1 then do:
    assign
    v-import = (entry(2, p-mode) = 'ДОБАВЛЕНИЕ-ИМПОРТ':U).
    p-mode = entry(1, p-mode).
  end.
  if not ( p-mode = 'ДОБАВЛЕНИЕ':U or p-mode = 'ИЗМЕНЕНИЕ':U) then do:
    message vss-workfile vss-revision vss-description skip
            "Неверный параметр p-mode - " p-mode
    view-as alert-box error .
    return error '':u.
  end.
  find first buf_goods no-lock where
            buf_goods.gds-code = p-gds-code no-error .
  if not available buf_goods then do:
    v-err-mess = substitute("Не найден товар с кодом &1", p-gds-code).
    run err-mess in this-procedure ( input-output v-err-mess).
    undo, return error (if p-silent then v-err-mess else 'unit-cli').
  end.
  if p-unit-cli = ""
  then do:
    v-err-mess = "Не задана единица измерения.".
    run err-mess in this-procedure ( input-output v-err-mess).
    undo, return error (if p-silent then v-err-mess else 'unit-cli').
  end.
  find first buf_gds-prt no-lock where
            buf_gds-prt.node-code = p-node-code no-error.
  if not available buf_gds-prt then do:
    v-err-mess = substitute("Неверный код признака &1.", p-node-code).
    run err-mess in this-procedure ( input-output v-err-mess).
    undo, return error (if p-silent then v-err-mess else 'node-code').
  end.
  find buf_units where
      buf_units.unit-name = p-unit-cli no-lock no-error.
  find base_units where base_units.unit-name = buf_goods.unit-base no-lock.
  if not available buf_units
  then do:
    v-err-mess = substitute("Единица измерения &1 отсутствует в справочнике.", p-unit-cli).
    run err-mess in this-procedure ( input-output v-err-mess).
    undo, return error (if p-silent then v-err-mess else 'unit-cli').
  end.
  if  lookup( 'сте':U, base_units.type ) > 0
  and buf_goods.unit-base <> buf_units.unit-name
  then do:
    v-err-mess =  substitute("Нельзя создать код для неосновной единицы измерения&1"  +
                            "к товару, у которого основная единица измерения типа &2"
                            , chr(10)
                            , 'сте':U).
    run err-mess in this-procedure ( input-output v-err-mess).
    undo, return error (if p-silent then v-err-mess else 'unit-cli').
  end.
  if  lookup ('топ':U, base_units.type) > 0
  and lookup ('дро':U, base_units.type) > 0
  and buf_goods.gds-type = 'т':U
  then do:
    v-err-mess =  "Товар топливный: добавление собственных кодов запрещено.".
    run err-mess in this-procedure ( input-output v-err-mess).
    undo, return error (if p-silent then v-err-mess else '').
  end.
  if  lookup ('топ':U, buf_units.type) > 0
  and lookup ('дро':U, buf_units.type) > 0
  then do:
    v-err-mess =  "Топливная единица измерения не может быть указана в бар-коде.".
    run err-mess in this-procedure ( input-output v-err-mess).
    undo, return error (if p-silent then v-err-mess else 'unit-cli').
  end.
  if lookup ('вес':U, buf_units.type) > 0
  then do:
    v-err-mess = "Весовая единица измерения не может быть указана в бар-коде.".
    run err-mess in this-procedure ( input-output v-err-mess).
    undo, return error (if p-silent then v-err-mess else 'unit-cli').
  end.
  if lookup ('сер':U, buf_units.type) > 0
  then do:
    v-err-mess = "Серийная единица измерения не может быть указана в бар-коде.".
    run err-mess in this-procedure ( input-output v-err-mess).
    undo, return error (if p-silent then v-err-mess else 'unit-cli').
  end.
  if  p-unit-cli <> buf_goods.unit-base
  and lookup ('сер':U, base_units.type) > 0
  then do:
    v-err-mess = "Товар серийный: Единица измерения должна совпадать с базовой.".
    run err-mess in this-procedure ( input-output v-err-mess).
    undo, return error (if p-silent then v-err-mess else 'unit-cli').
  end.
  if  lookup ('шту':U, base_units.type) > 0
  and p-cli-base-rate <>  truncate (p-cli-base-rate, 0)
  then do:
    v-err-mess = "Товар штучный: коэффициент должен быть целым числом.".
    run err-mess in this-procedure ( input-output v-err-mess).
    undo, return error (if p-silent then v-err-mess else 'cli-base-rate').
  end.
  if p-cli-base-rate <= 0
  or p-cli-base-rate = ?
  then do:
    v-err-mess =  "Коэффициент должен быть больше 0.".
    run err-mess in this-procedure ( input-output v-err-mess).
    undo, return error (if p-silent then v-err-mess else 'cli-base-rate').
  end.
  if  p-unit-cli <> buf_goods.unit-base
  and p-cli-base-rate = 1
  and not p-silent
  then do:
    message
    "Единица измерения не совпадает с основной - а коэффициент 1. Это странно. Вы не ошиблись?"
      view-as alert-box question.
  end.
  b-c:
  do transaction
  on error undo, return error return-value
  :
    if p-mode = 'ДОБАВЛЕНИЕ':U
    then do:
        if can-find (ub.bar-code where
                    ub.bar-code.gds-code  = buf_goods.gds-code
                and ub.bar-code.in-code   = p-in-code
                and ub.bar-code.part-code = p-part-code
                and ub.bar-code.node-code = p-node-code
                and ub.bar-code.unit-cli  = p-unit-cli)
        then do:
          v-err-mess = substitute( "Бар-код для единицы измерения &1 уже существует."
                                  ,p-unit-cli ).
          run err-mess in this-procedure ( input-output v-err-mess).
          undo, return error (if p-silent then v-err-mess else 'cli-base-rate').
        end.
      if v-import = yes then do:
        glog = no.
        run  chk-b-code in THIS-PROCEDURE (
                                             input p-silent
                                            ,input p-b-code
                                            ,output glog
                                          ) no-error.
        if error-status:error then do:
          v-err-mess = return-value .
          run err-mess in this-procedure ( input-output v-err-mess).
          undo, return error (if p-silent then v-err-mess else '').
        end.
        create buf_bar-code.
        assign
        buf_bar-code.gds-code  = p-gds-code
        buf_bar-code.b-code    = p-b-code
        buf_bar-code.node-code = p-node-code
        buf_bar-code.part-code = p-part-code
        buf_bar-code.in-code   = p-in-code
        buf_bar-code.unit-cli  = p-unit-cli
        buf_bar-code.cli-base-rate  = p-cli-base-rate
        p-rid = recid(buf_bar-code)
        .
      end.
    end.
    if v-import = no then do:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run barcodcr in g#library
  (input  buf_goods.gds-code
  ,input  p-node-code
  ,input  p-part-code
  ,input  p-in-code
  ,input  p-unit-cli
  ,input  p-cli-base-rate
  ,output v-is-new
  ,buffer buf_bar-code
  ) no-error .
      if error-status :error
      then do:
        v-err-mess = substitute("Ошибка: &1&2&3", error-status:get-message(1) , chr(10), return-value ).
        run err-mess in this-procedure ( input-output v-err-mess).
        undo, return error (if p-silent then v-err-mess else 'cli-base-rate').
      end.
      p-rid = recid(buf_bar-code).
    end.
    if p-mode = 'ИЗМЕНЕНИЕ':U
    then do:
      if v-import = yes then do:
        find first buf_bar-code exclusive-lock where
                  buf_bar-code.b-code = p-b-code .
        if buf_bar-code.gds-code <> p-gds-code then do:
          v-err-mess = substitute("Изменяемый бар-код существует, но относится к другому товару ( с кодом &1)", buf_bar-code.gds-code).
          run err-mess in this-procedure ( input-output v-err-mess).
          undo, return error (if p-silent then v-err-mess else '').
        end.
        if buf_bar-code.node-code <> p-node-code then do:
          v-err-mess = substitute("Изменяемый бар-код существует, но относится к другому признаку ( с кодом &1)", buf_bar-code.node-code).
          run err-mess in this-procedure ( input-output v-err-mess).
          undo, return error (if p-silent then v-err-mess else '').
        end.
        if buf_bar-code.part-code <> p-part-code then do:
          v-err-mess = substitute("Изменяемый бар-код существует, но относится к другому коду партии (&1)", buf_bar-code.part-code).
          run err-mess in this-procedure ( input-output v-err-mess).
          undo, return error (if p-silent then v-err-mess else '').
        end.
        if buf_bar-code.in-code <> p-in-code then do:
          v-err-mess = substitute("Изменяемый бар-код существует, но относится к другой ПН (&1)", buf_bar-code.in-code).
          run err-mess in this-procedure ( input-output v-err-mess).
          undo, return error (if p-silent then v-err-mess else '').
        end.
        if buf_bar-code.unit-cli <> p-unit-cli then do:
          v-err-mess = substitute("Изменяемый бар-код существует, но относится к другой ед.изм. (&1)", buf_bar-code.unit-cli).
          run err-mess in this-procedure ( input-output v-err-mess).
          undo, return error (if p-silent then v-err-mess else '').
        end.
        if buf_bar-code.stts_ = integer('79':U) then do:
          buf_bar-code.stts_ = 0.
        end.
      end.
      if v-import = no then do:
        buf_bar-code.cli-base-rate = p-cli-base-rate.
      end.
    end.
  end.
end.
PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Создание бар-кода &2 для товара с кодом &1:&3&4"
                         , p-gds-code
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
