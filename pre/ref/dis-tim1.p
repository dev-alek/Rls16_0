block-level on error undo, throw.
define input parameter  p-time-rule-num     like ub.dis-time-rule.time-rule-num          no-undo .
define input parameter  p-rl-root           like ub.dis-time-rule.rl-root           no-undo .
define input parameter  p-templ-rl-root     like ub.dis-time-rule.templ-rl-root     no-undo .
define input parameter  p-des               like ub.dis-time-rule.des               no-undo .
define input parameter  p-date-from         like ub.dis-time-rule.date-from no-undo .
define input parameter  p-date-to           like ub.dis-time-rule.date-to no-undo .
define input parameter  p-time-from         like ub.dis-time-rule.time-from no-undo .
define input parameter  p-time-to           like ub.dis-time-rule.time-to no-undo .
define input parameter  p-month-day         like ub.dis-time-rule.month-day no-undo .
define input parameter  p-week-day-0        like ub.dis-time-rule.week-day-0 no-undo .
define input parameter  p-week-day-1        like ub.dis-time-rule.week-day-1 no-undo .
define input parameter  p-week-day-2        like ub.dis-time-rule.week-day-2 no-undo .
define input parameter  p-week-day-3        like ub.dis-time-rule.week-day-3 no-undo .
define input parameter  p-week-day-4        like ub.dis-time-rule.week-day-4 no-undo .
define input parameter  p-week-day-5        like ub.dis-time-rule.week-day-5 no-undo .
define input parameter  p-week-day-6        like ub.dis-time-rule.week-day-6 no-undo .
define input parameter  p-week-day-7        like ub.dis-time-rule.week-day-7 no-undo .
define input parameter  p-upper-time-rule-num    like ub.dis-time-rule.upper-time-rule-num    no-undo .
define input parameter  p-value-type        like ub.dis-time-rule.value-type        no-undo .
define temp-table tt0-term_dis-time-rule no-undo like ub.dis-time-rule.
DEFINE INPUT PARAMETER TABLE FOR tt0-term_dis-time-rule.
define input-output parameter p-recid as recid no-undo.
define input parameter p-mode                         as character no-undo .
define input parameter p-silent                       as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dis-tim1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dis-tim1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в расписаниях".
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
def var vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure dtr-code :
  do
  on error undo, return error
  :
    define input  parameter  p-templ-rl-root     like ub.dis-time-rule.templ-rl-root     no-undo .
    define output parameter  p-des               like ub.dis-time-rule.des               no-undo .
    define output parameter  p-upper-time-rule-num    like ub.dis-time-rule.upper-time-rule-num    no-undo .
    define output parameter  p-value-type        like ub.dis-time-rule.value-type        no-undo .
    define output parameter  p-level-1 as character no-undo .
    define output parameter  p-level-2 as character no-undo .
    define output parameter  p-output-display as logical   no-undo .
    define output parameter  p-tree           as char  no-undo .
    define output parameter  p-other          as character no-undo .
    define variable v-templ-rl-root like ub.dis-time-rule.templ-rl-root no-undo .
    define buffer buf_dis-time-rule for ub.dis-time-rule .
    define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
    if p-templ-rl-root < 50000 then
    v-templ-rl-root = (p-templ-rl-root + 50000).
    else v-templ-rl-root = p-templ-rl-root.
    find first buf_dis-time-rule no-lock where
              buf_dis-time-rule.time-rule-num = v-templ-rl-root no-error .
    if not available buf_dis-time-rule then do:
      undo, return error substitute("неизвестный тип расписания &1", p-templ-rl-root) .
    end.
    find first buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.templ-rl-root = 0
        and buf_dis-cfg-rule.time-templ-rl-root = p-templ-rl-root
        and buf_dis-cfg-rule.pos-type = '':U
        and buf_dis-cfg-rule.table-name = '':U
        and buf_dis-cfg-rule.discnt-role = '':U
        and buf_dis-cfg-rule.self-nonunique = '':U
            no-error.
    if not available buf_Dis-cfg-rule then do:
        undo, return error substitute("неизвестный тип расписания &1", p-templ-rl-root ).
    end.
    assign
    p-des = buf_dis-time-rule.des
    p-upper-time-rule-num = (buf_dis-time-rule.upper-time-rule-num - 50000)
    p-value-type = buf_dis-time-rule.value-type
    p-level-1 = entry(1, buf_dis-cfg-rule.other-inf, ";":U)
    p-level-2 = (if num-entries(buf_dis-cfg-rule.other-inf, ";":U) > 1
                 then entry(2, buf_dis-cfg-rule.other-inf, ";":U)
                 else '')
    p-output-display = (buf_dis-time-rule.sts = integer('0':U))
    p-tree = buf_dis-time-rule.uniq-field
    p-other = buf_dis-time-rule.other-inf
    .
  end.
end procedure.
def var vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure dr-code :
  do
  on error undo, return error
  :
    define input  parameter  p-templ-rl-root     like ub.dis-rule.templ-rl-root     no-undo .
    define output parameter  p-des               like ub.dis-rule.des               no-undo .
    define output parameter  p-discnt-type       like ub.dis-rule.discnt-type       no-undo .
    define output parameter  p-subject-type      like ub.dis-rule.subject-type      no-undo .
    define output parameter  p-value-type        like ub.dis-rule.value-type        no-undo .
    define output parameter  p-level-1           as character no-undo .
    define output parameter  p-level-2           as character no-undo .
    define output parameter  p-global             as integer no-undo .
    define output parameter  p-host               as integer no-undo .
    define output parameter  p-object             as integer no-undo .
    define output parameter  p-output-display as logical   no-undo .
    define output parameter  p-tree           as char  no-undo .
    define output parameter  p-other          as character no-undo .
    define variable v-other as character no-undo .
    define buffer buf_dis-rule for ub.dis-rule .
    define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
    find first buf_dis-rule no-lock where
              buf_dis-rule.rule-num = p-templ-rl-root no-error.
    find first buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.templ-rl-root = buf_dis-rule.templ-rl-root
        and buf_dis-cfg-rule.pos-type = '':U
        and buf_dis-cfg-rule.table-name = '':U
        and buf_dis-cfg-rule.discnt-role = '':U
        and buf_dis-cfg-rule.self-nonunique = '':U
            no-error.
    if not available buf_Dis-cfg-rule then do:
        undo, return error substitute("неизвестный шаблон скидки &1", p-templ-rl-root ).
    end.
    assign
    p-des = buf_dis-rule.des
    p-discnt-type = buf_dis-rule.discnt-type
    p-subject-type = buf_dis-rule.subject-type
    p-value-type = buf_dis-rule.value-type
    p-global = (if available buf_dis-cfg-rule
                then buf_dis-cfg-rule.has-global
                else 0)
    p-host = (if available buf_dis-cfg-rule
              then buf_dis-cfg-rule.has-host
              else 0)
    p-object = (if available buf_dis-cfg-rule
              then buf_dis-cfg-rule.has-obj
              else 0)
    p-output-display = (buf_dis-rule.sts = integer('0':U))
    p-tree = buf_Dis-rule.uniq-field
    p-other = buf_dis-rule.other-inf
    p-level-1 = entry(1, buf_dis-cfg-rule.other-inf, ";":U)
    p-level-2 = (if num-entries(buf_dis-cfg-rule.other-inf, ";":U) > 1
                 then entry(2, buf_dis-cfg-rule.other-inf, ";":U)
                 else '')
    .
  end.
end procedure.
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
procedure disrules-get-interface-form :
define input parameter p-templ-rl-root like ub.dis-rule.templ-rl-root no-undo .
define output parameter p-form-name as character no-undo .
define buffer buf_temp-drt-prop for temp-drt-prop.
define buffer buf_drt-prop for ub.drt-prop.
find first buf_temp-drt-prop where
          buf_temp-drt-prop.templ-rl-root = p-templ-rl-root
      and buf_temp-drt-prop.upper-prop-code = "InputForm"
      and buf_temp-drt-prop.prop-code = "FormName" no-error.
if not available buf_temp-drt-prop then do:
  find first buf_drt-prop where
            buf_drt-prop.templ-rl-root = p-templ-rl-root
        and buf_drt-prop.upper-prop-code = "InputForm"
        and buf_drt-prop.prop-code = "FormName" no-error.
  if available buf_drt-prop then do:
    p-form-name = buf_drt-prop.property-value.
  end.
  else do:
    p-form-name = "ref/dis-ruli.w".
  end.
end.
else do:
  p-form-name = buf_temp-drt-prop.property-value.
end.
end procedure.
~
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    define variable v-mes2 as character no-undo .
    define variable v-param-type2 as character no-undo .
    define variable v-value-character2 as INTEGER no-undo .
    define variable v-value-date2 as date no-undo .
    define variable v-value-decimal2 as decimal no-undo .
    define variable v-value-integer2 AS integer no-undo .
    define variable v-value-logical2 AS LOGICAL no-undo .
    define variable v-tth2 as handle no-undo .
    run adm/shattri.p (
        input "get":U
        ,input  'БД':U
        ,input  p-db-num
        ,input  'code-range':U
        ,input  cfg-param-code
        ,output v-value-character2
        ,output v-value-date2
        ,output v-value-decimal2
        ,output v-value-integer2
        ,output v-value-logical2
        ,output v-param-type2
        ,INPUT-OUTPUT table-handle v-tth2
        ) no-error .
    if error-status :error then do:
      delete object v-tth2.
      v-mes2 = substitute("Ошибка при получении размера диапазона собственных глобальных кодов&2&1&2&3"
                         , error-status:get-message(1)
                         , chr(10)
                         , return-value ).
      undo, return error v-mes2.
    end.
    delete object v-tth2.
    if v-cre-cdrg = TRUE then do:
      create buf_code-range .
      assign
        buf_code-range.db-num     = p-db-num
        buf_code-range.range-type = type-code
        buf_code-range.stts       = "f"
        buf_code-range.first-code = last_code-range.last-code + 1
        buf_code-range.last-code  = last_code-range.last-code + integer(v-value-integer2)
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer locK-batchprocess3 for ub.batchprocess.
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
    ,buffer lock-batchprocess3
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION gtregion RETURNS CHARACTER
  ( input parhost-code as integer
  , input parobj-type as character
  , input parobj-code as integer
  , input p-tab as logical
  ) :
  def var par-region as character no-undo.
  if parhost-code = 0 and
       parobj-type = "":U and
       parobj-code = 0 then do:
       par-region = "Глобально".
       return par-region.
    end.
    if parobj-type = "" and
       parobj-code = 0 then do:
       par-region = if p-tab then fill(chr(32), 2) else "":U +
                    "Фирма" + chr(32) + string(parhost-code).
       return par-region.
    end.
    par-region = if p-tab then fill(chr(32), 4) else "":U +
                 parobj-type + chr(32) + string(parobj-code).
    return par-region.
END FUNCTION.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-waitfram-action01         as character   no-undo .
define variable v-waitfram-action02         as character   no-undo .
define variable v-waitfram-action03         as character   no-undo .
define variable mWaitFramTextBeg            as character   no-undo.
define variable mWaitFramTextEnd            as character   no-undo.
define variable mWaitFramView               as logical     no-undo.
define variable mWaitProcEvent              as logical     no-undo init yes.
define variable mWaitFramInterval           as integer     no-undo init 1 .
define variable mWaitFramStop               as logical     no-undo.
define variable mWaitFramStopUser           as logical     no-undo.
define variable mWaitFramStopTimeOut        as logical     no-undo.
define variable mWaitFramStartProc          as datetime-tz no-undo.
define variable mWaitFramTimeOut            as decimal     no-undo init ?.
define button B-WaitFramStop auto-end-key
     label "Стоп"
     size 10 by 1 tooltip "Остоновить процесс".
define button B-viewProcInfo
     label "Информация"
     size 15 by 1 tooltip "Информация о процесс".
define frame waitfram
  v-waitfram-action01 format "x(72)" no-label skip
  v-waitfram-action02 format "x(72)" no-label skip
  v-waitfram-action03 format "x(72)" no-label skip
  B-viewProcInfo
  B-WaitFramStop at row 4 col 30
  with view-as dialog-box side-labels three-d cancel-button B-WaitFramStop
  .
define new global shared variable mBatchMode as logical no-undo init ?.
define variable mFramBachModHandle as handle no-undo.
mFramBachModHandle = frame waitfram:handle.
define variable mFameOldVis as logical no-undo.
define variable mVisCUrentVin as logical no-undo.
if session:batch-mode
then
   mBatchMode = yes.
if mBatchMode = ? then do:
  mVisCUrentVin = current-window:visible.
  mFameOldVis = mFramBachModHandle:visible.
  mFramBachModHandle:visible  = yes.
  mBatchMode = mFramBachModHandle:visible ne yes.
  mFramBachModHandle:visible = mFameOldVis.
  current-window:visible = mVisCUrentVin.
end.
 if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramBachModHandle:visible), "frameRepError").
  end.
on choose of B-WaitFramStop in frame waitfram
do:
  mWaitFramStop = yes.
  mWaitFramStopUser = yes.
end.
function waitfram-check-timeout returns logical():
   define variable vtime as int64 no-undo.
   if mWaitFramStopTimeOut
   then
      return yes.
   vtime = ( now - mWaitFramStartProc ) / 1000 .
   if     mWaitFramTimeOut ne ?
      and mWaitFramTimeOut ne 0
      and mWaitFramTimeOut lt vtime
   then do:
      mWaitFramStopTimeOut = yes.
   end.
   return mWaitFramStopTimeOut.
end.
procedure waitfram-hide :
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    pause 0 before-hide .
    if not mBatchMode then
      hide frame waitfram .
  if     not mWaitFramView
     and mWaitProcEvent
  then
    process events .
  end.
end procedure.
procedure waitfram-show :
  define input  parameter p-message as character no-undo .
  define variable v-left-margin as integer   no-undo .
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    if length(p-message) <= 70 then do:
      assign
        v-left-margin = integer((70 - length(p-message)) / 2)
      .
      assign
        v-left-margin = max(0, v-left-margin - (v-left-margin mod 5))
      .
      assign
        v-waitfram-action01 = " "
        v-waitfram-action02 = " "
                                 + fill(" ", v-left-margin)
                                 + p-message
        v-waitfram-action03 = " "
      .
    end.
    else do:
      define variable vRindex1 as integer no-undo.
      define variable vRindex2 as integer no-undo.
      vRindex1 = r-index(p-message," ",70).
      if vRindex1 = 0
      then
         vRindex1 = 70.
      if length(p-message)  <= vRindex1 + 70 then do:
        assign
          v-waitfram-action01 = " "
          v-waitfram-action02 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action03 = " " + substring(p-message,  vRindex1 + 1, 70      )
        .
      end.
      else do:
        vRindex2 = r-index(p-message," ",vRindex1 + 70).
        if vRindex2 <= vRindex1
        then
           vRindex2 = vRindex1 + 70.
        assign
          v-waitfram-action01 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action02 = " " + substring(p-message,  vRindex1 + 1, vRindex2 - vRindex1 )
          v-waitfram-action03 = " " + substring(p-message,  vRindex2 + 1, 70)
        .
      end.
    end.
    B-viewProcInfo:visible   in frame waitfram = no.
    B-viewProcInfo:sensitive in frame waitfram = no.
    B-WaitFramStop:visible   in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    B-WaitFramStop:sensitive in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    if  (   mWaitFramView
       or  mWaitProcEvent)
       and not mBatchMode
    then
       display
          v-waitfram-action01 skip
          v-waitfram-action02 skip
          v-waitfram-action03 skip
       with frame waitfram .
    if     mWaitFramView
       then do:
          if     mWaitFramInterval ne ?
             and not mBatchMode
          then
             wait-for go of frame waitfram pause mWaitFramInterval.
       end.
       else
          if     mWaitProcEvent
             and not mBatchMode
          then
             process events .
  end.
end procedure.
   procedure waitfram-show-this:
      define input  parameter iInterval as int64 no-undo.
      define variable vtime as int64 no-undo.
      vtime = ( now - mWaitFramStartProc  ) / 1000 .
      mWaitFramInterval = iInterval.
      run waitfram-show (substitute("&1&2 &3&4" ,
                                    mWaitFramTextBeg ,
                                    if vtime eq ? then "" else substitute (" Прошло: &1 сек" , string( vtime)),
                                    if mWaitFramTimeOut ne 0 and mWaitFramTimeOut ne ? then " из " + string(mWaitFramTimeOut) + " сек. " else "",
                                    mWaitFramTextEnd
                                   )
                        ).
   end.
   procedure WaitFramRunPause:
      define input  parameter iInterval as dec no-undo.
      define variable vStart  as datetime-tz no-undo.
      define variable vend    as datetime-tz no-undo.
      define variable vint as int64 no-undo.
      define variable vOk as logical no-undo.
      vStart = now.
      vend   = vStart.
      publish "WaitFramPause" (iInterval,output vOk).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and (   vint > 0
              or (    not vOk
                  and iInterval eq ?
                  )
              )
      then
         run waitfram-show-this (iInterval).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and vint > 0
      then do:
         run gbl/pause.p (vint * 1000).
      end.
      if iInterval ne ?
      then
         publish "WaitFramStop".
      waitfram-check-timeout().
   end.
   procedure WaitFramWaitFor:
      define input  parameter iInterval as dec no-undo.
      assign
         mWaitFramStartProc   = now
         mWaitFramStopUser    = no
         mWaitFramStopTimeOut = no
      .
      block-wait:
      do while not mWaitFramStop:
         run WaitFramRunPause (iInterval).
         if  waitfram-check-timeout()
         then do:
            leave block-wait.
         end.
      end.
      run waitfram-hide.
   end.
procedure waitfram-join :
  define input  parameter p-line-1  as character no-undo .
  define input  parameter p-line-2  as character no-undo .
  define input  parameter p-line-3  as character no-undo .
  define output parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-message = substring(p-line-1 + fill(' ', 70), 1, 70)
                + substring(p-line-2 + fill(' ', 70), 1, 70)
                + substring(p-line-3 + fill(' ', 70), 1, 70)
    .
  end.
end procedure.
function waitfram-join-function returns character
  (input p-line-1 as character
  ,input p-line-2 as character
  ,input p-line-3 as character
  ).
  define variable v-message as character no-undo .
  run waitfram-join in this-procedure
    (input  p-line-1
    ,input  p-line-2
    ,input  p-line-3
    ,output v-message
    ) .
  return v-message .
end function .
define variable v-db-num like ub.db.db-num no-undo .
define variable v-dr-code as character no-undo .
define variable  v-new-time-rule-num      like ub.dis-time-rule.time-rule-num          no-undo .
define variable  v-time-rule-num          like ub.dis-time-rule.time-rule-num          no-undo .
define variable  v-des               like ub.dis-time-rule.des               no-undo .
define variable  v-upper-time-rule-num    like ub.dis-time-rule.upper-time-rule-num    no-undo .
define variable  v-value-type        like ub.dis-time-rule.value-type        no-undo .
define variable  vt-level-1 as character no-undo .
define variable  vt-level-2 as character no-undo .
define variable  v-output-display    as logical   no-undo .
define variable  v-tree              as character no-undo .
define variable  v-other             as character no-undo .
define variable  v-dub               as logical no-undo .
define variable  v-entry             as character no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
define variable v-curr-field as character no-undo .
define variable v-curr-field1 as character no-undo .
define variable v-curr-field2 as character no-undo .
define variable v-tree-field as logical no-undo extent 18.
define variable v-num-rec as integer no-undo extent 18.
define variable v-num-rec-sign as character no-undo extent 18.
define variable v-uniq-field as logical no-undo extent 18.
define variable v-gds-obj-attr as character no-undo .
define variable v-found as logical no-undo .
define variable v-str as character no-undo .
define variable v-changes as logical no-undo .
define variable v-run-cn as logical no-undo .
define variable v-field-label as character no-undo .
define buffer buf_temp-drt-prop for ub.drt-prop.
define buffer buf_sysconf  for ub.sysconf.
DEFINE BUFFER buf_clients-obj FOR ub.clients.
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
define buffer buf_db for ub.db .
define buffer buf_dis-time-rule for ub.dis-time-rule.
define buffer buf_dis-rule for ub.dis-rule.
define buffer dub_dis-time-rule for ub.dis-time-rule.
define buffer term_dis-time-rule for ub.dis-time-rule.
define buffer dub_tt-dis-time-rule  for tt0-term_dis-time-rule.
define temp-table temp-dis-time-rule no-undo like ub.dis-time-rule.
define buffer check_dis-time-rule for temp-dis-time-rule.
FUNCTION get-week-day-num RETURNS integer (buffer buf_tt-dis-time-rule for tt0-term_dis-time-rule, input p-mode as character):
define variable v-correct as integer no-undo .
assign
v-correct = (if buf_tt-dis-time-rule.week-day-0 <> ? and p-mode = "week-day-a"
            then (if buf_tt-dis-time-rule.week-day-0
                  then (if p-mode = "week-day-c"
                        then 128
                        else 0)
                  else 1
                  )
            else 0)     +
            (if buf_tt-dis-time-rule.week-day-1 <> ?
            then (if buf_tt-dis-time-rule.week-day-1
                  then 1
                  else 0)
            else 0)     +
            (if buf_tt-dis-time-rule.week-day-2 <> ?
            then (if buf_tt-dis-time-rule.week-day-2
                  then (if p-mode = "week-day-c"
                        then  2
                        else 0)
                  else 0
                 )
            else 0)     +
            (if buf_tt-dis-time-rule.week-day-3 <> ?
            then (if buf_tt-dis-time-rule.week-day-3
                  then (if p-mode = "week-day-c"
                        then  4
                        else 0)
                  else 0
                  )
            else 0)     +
            (if buf_tt-dis-time-rule.week-day-4 <> ?
            then (if buf_tt-dis-time-rule.week-day-4
                  then (if p-mode = "week-day-c"
                        then  8
                        else 0)
                  else 0
                  )
            else 0)     +
            (if buf_tt-dis-time-rule.week-day-5 <> ?
            then (if buf_tt-dis-time-rule.week-day-5
                  then (if p-mode = "week-day-c"
                        then  16
                        else 0)
                  else 0
                  )
            else 0)     +
            (if buf_tt-dis-time-rule.week-day-6 <> ?
            then (if buf_tt-dis-time-rule.week-day-6
                  then (if p-mode = "week-day-c"
                        then  32
                        else 0)
                  else 0
                  )
            else 0)     +
            (if buf_tt-dis-time-rule.week-day-7 <> ?
            then (if buf_tt-dis-time-rule.week-day-7
                  then (if p-mode = "week-day-c"
                        then  64
                        else 0)
                  else 0
                  )
            else 0)
.
if v-correct <> 1 then return ?.
if buf_tt-dis-time-rule.week-day-0 <> ?
and p-mode = "week-day-a" then return 0.
if buf_tt-dis-time-rule.week-day-1 <> ?
then return 1.
if buf_tt-dis-time-rule.week-day-2 <> ?
then return 2.
if buf_tt-dis-time-rule.week-day-3 <> ?
then return 3.
if buf_tt-dis-time-rule.week-day-4 <> ?
then return 4.
if buf_tt-dis-time-rule.week-day-5 <> ?
then return 5.
if buf_tt-dis-time-rule.week-day-6 <> ?
then return 6.
if buf_tt-dis-time-rule.week-day-7 <> ?
then return 7.
END.
if p-mode <> 'ДОБАВЛЕНИЕ':U
AND p-mode <> 'ИЗМЕНЕНИЕ':U then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр p-mode" p-mode
  view-as alert-box error .
  undo, return error '':u.
end.
run dtr-code  in this-procedure (
     input  p-templ-rl-root
    ,output v-des
    ,output v-upper-time-rule-num
    ,output v-value-type
    ,output vt-level-1
    ,output vt-level-2
    ,output v-output-display
    ,output v-tree
    ,output v-other
                               ) no-error .
if error-status:error then do:
    run err-mess in this-procedure (substitute("Неверный номер шаблона для расписания: &1, &2", p-templ-rl-root, return-value)).
    undo, return error "time-rule-num":U.
end.
run disrules-fill-properties in this-procedure ( input p-templ-rl-root).
do jj = 1 to num-entries("time-from,time-to,date-from,date-to,week-day-0,week-day-1,week-day-2,week-day-3,week-day-4,week-day-5,"  +                     "week-day-6,week-day-7,month-day,week-day-a,week-day-b,week-day-c,time-period,date-period"):
  assign
  v-curr-field = entry(jj, "time-from,time-to,date-from,date-to,week-day-0,week-day-1,week-day-2,week-day-3,week-day-4,week-day-5,"  +                     "week-day-6,week-day-7,month-day,week-day-a,week-day-b,week-day-c,time-period,date-period")
  .
  find first buf_temp-drt-prop where
      buf_temp-drt-prop.templ-rl-root = p-templ-rl-root
  and buf_temp-drt-prop.upper-prop-code = "":U
  and buf_temp-drt-prop.prop-code = v-curr-field + "=uniq" no-error .
  if available buf_temp-drt-prop then do:
    assign
    v-uniq-field[jj] = yes
    .
  end.
end.
if p-mode = 'ИЗМЕНЕНИЕ':U
then do:
  find first buf_db no-lock where
            buf_db.db-num > 0 no-error.
  if available buf_db then do:
    run check-changes(
                         input p-time-rule-num
                        ,output v-changes) no-error .
    if error-status:error
    or v-changes then do:
      run err-mess  in this-procedure (substitute("Т.к. в Системе имеются Удаленные БД,то можно менять только описания РАСПИСАНИЯ")).
      undo, return error "":U.
    end.
  end.
  run waitfram-show in this-procedure ("Ждите .. Проводится проверка возможности изменения правила" ).
    _dis-rule:
  for each buf_dis-rule no-lock where
          buf_dis-rule.time-rule-num = p-time-rule-num:
    assign
    v-found = (yes AND v-changes)
    .
    leave _dis-rule.
  end.
end.
if v-found then do:
  run waitfram-hide in this-procedure .
  run err-mess in this-procedure (substitute("Нельзя изменять запись РАСПИСАНИЯ: &1 ~
                          с ней связано ПРАВИЛО СКИДОК №&2 &3"
                          , chr(10)
                          , buf_dis-rule.rule-num
                          , buf_dis-rule.des
                          )).
  undo, return error "":U.
end.
run waitfram-hide in this-procedure .
DO ii = 1 TO NUM-ENTRIES(p-value-type):
   ASSIGN
   v-str =  entry (lookup (ENTRY(ii, p-value-type), '0,1,2,4,8,16':U), '?,Период времени,Период дат,День недели,Дата,День месяца':U) NO-ERROR.
   if error-status:error then do:
    run err-mess in this-procedure (substitute("Неверный тип расписания: &1", p-value-type)).
    undo, return error "value-type":U.
   end.
END.
find first buf_dis-time-rule no-lock where
        buf_dis-time-rule.time-rule-num = p-upper-time-rule-num no-error .
if not available buf_dis-time-rule then do:
  run err-mess in this-procedure (substitute("Неверный номер корневого расписания: &1", p-upper-time-rule-num)).
  undo, return error "upper-time-rule-num":U.
end.
if p-time-rule-num <=  99999 then do:
    run err-mess in this-procedure (substitute("Неверный номер расписания: &1, значения меньшие &2 зарезервированы", p-time-rule-num, 99999)).
    undo, return error "time-rule-num":U.
end.
assign
v-time-rule-num = p-upper-time-rule-num
.
if lookup("time-from", vt-level-1) = 0
and lookup("time-from", vt-level-2) = 0  then do:
  p-time-from = -1.
end.
if lookup("time-to", vt-level-1) = 0
and lookup("time-to", vt-level-2) = 0  then do:
  p-time-to = -1.
end.
if lookup("date-from", vt-level-1) = 0
and lookup("date-from", vt-level-2) = 0  then do:
  p-date-from = 12/31/1989.
end.
if lookup("date-to", vt-level-1) = 0
and lookup("date-to", vt-level-2) = 0  then do:
  p-date-to = 12/31/1989.
end.
if lookup("week-day-0", vt-level-1) = 0
and lookup("week-day-0", vt-level-2) = 0  then do:
  p-week-day-0 = ?.
end.
if lookup("week-day-1", vt-level-1) = 0
and lookup("week-day-1", vt-level-2) = 0  then do:
  p-week-day-1 = ?.
end.
if lookup("week-day-2", vt-level-1) = 0
and lookup("week-day-2", vt-level-2) = 0  then do:
  p-week-day-2 = ?.
end.
if lookup("week-day-3", vt-level-1) = 0
and lookup("week-day-3", vt-level-2) = 0  then do:
  p-week-day-3 = ?.
end.
if lookup("week-day-4", vt-level-1) = 0
and lookup("week-day-4", vt-level-2) = 0  then do:
  p-week-day-4 = ?.
end.
if lookup("week-day-5", vt-level-1) = 0
and lookup("week-day-5", vt-level-2) = 0  then do:
  p-week-day-5 = ?.
end.
if lookup("week-day-6", vt-level-1) = 0
and lookup("week-day-6", vt-level-2) = 0  then do:
  p-week-day-6 = ?.
end.
if lookup("week-day-7", vt-level-1) = 0
and lookup("week-day-7", vt-level-2) = 0  then do:
  p-week-day-7 = ?.
end.
if lookup("month-day", vt-level-1) = 0
and lookup("month-day", vt-level-2) = 0  then do:
  p-month-day = -1.
end.
if (v-value-type <> p-value-type )
then do:
    run err-mess in this-procedure (substitute("Неверный номер шаблона для расписания: &1, несоответствуют друг друг параметры шаблона и параметры правила скидки", p-templ-rl-root, return-value)).
    undo, return error "templ-rl-root":U.
end.
if v-output-display = no then do:
  run err-mess in this-procedure (substitute("Нельзя добавить расписание по неиспользуемому шаблону: &1", p-templ-rl-root)).
  undo, return error "templ-rl-root":U.
end.
if p-month-day <> -1
and (p-month-day > 31 or p-month-day < -1 ) then do:
  run err-mess in this-procedure (substitute("Значение номера дня месяца не может быть больше 31: &1", p-month-day)).
  undo, return error "month-day":U.
end.
if p-time-from <>  -1 then do:
  assign
  v-str = string(p-time-from, "hh:mm") no-error .
  if error-status:error then do:
     run err-mess in this-procedure (substitute("Значение начала периода времени неверное: &1", p-time-from)).
     undo, return error "time-from":U.
  end.
end.
if p-time-to <>  -1 then do:
  assign
  v-str = string(p-time-to, "hh:mm") no-error .
  if error-status:error then do:
     run err-mess in this-procedure (substitute("Значение конца периода времени неверное: &1", p-time-to)).
     undo, return error "time-to":U.
  end.
  if p-time-from > p-time-to
  then do:
    run err-mess in this-procedure (substitute("Значение конца периода времени &1 не может быть меньше значения начала периода времени &2"
                                    , string(p-time-to, "HH:mm")
                                    , string(p-time-from, "HH:MM"))).
    undo, return error "time-from":U.
  end.
end.
if p-date-from < 12/31/1989
or p-date-from = ?
then do:
  if error-status:error then do:
     run err-mess in this-procedure (substitute("Значение начала периода дат неверное: &1", string(p-date-from, "99/99/9999"))).
     undo, return error "date-from":U.
  end.
end.
if p-date-to < 12/31/1989
or p-date-to = ?
then do:
  if error-status:error then do:
     run err-mess in this-procedure (substitute("Значение конца периода дат неверное: &1", string(p-date-to, "99/99/9999"))).
     undo, return error "date-to":U.
  end.
end.
if p-date-to < p-date-from
and lookup("date-from", vt-level-1) > 0
and lookup("date-to", vt-level-1) > 0
then do:
  run err-mess in this-procedure ( substitute("Значение конца периода дат &1 не может быть меньше значения начала периода дат &2"
                                  , string(p-date-to, "99/99/9999")
                                  , string(p-date-from, "99/99/9999"))).
  undo, return error "date-from":U.
end.
if p-mode = 'ДОБАВЛЕНИЕ':U then do:
  if can-find(first temp-drt-prop where
                   temp-drt-prop.templ-rl-root = p-templ-rl-root
              and  temp-drt-prop.upper-prop-code = '':U
              and temp-drt-prop.prop-code = "uniq"
              and logical(temp-drt-prop.property-value) = yes)
                     then do:
    find first dub_dis-time-rule no-lock where
          dub_dis-time-rule.upper-time-rule-num = p-upper-time-rule-num no-error .
    if available dub_dis-time-rule then do:
      assign
      v-dub = yes
      .
      run err-mess in this-procedure (substitute("Уже есть расписание такого типа &1: для данного типа можно определить только одно такое расписание ", v-des)).
    end.
  end.
  create check_dis-time-rule.
  assign
  check_dis-time-rule.date-from = p-date-from
  check_dis-time-rule.date-to = p-date-to
  check_dis-time-rule.time-from = p-time-from
  check_dis-time-rule.time-to = p-time-to
  check_dis-time-rule.week-day-0 = p-week-day-0
  check_dis-time-rule.week-day-1 = p-week-day-1
  check_dis-time-rule.week-day-2 = p-week-day-2
  check_dis-time-rule.week-day-3 = p-week-day-3
  check_dis-time-rule.week-day-4 = p-week-day-4
  check_dis-time-rule.week-day-5 = p-week-day-5
  check_dis-time-rule.week-day-6 = p-week-day-6
  check_dis-time-rule.week-day-7 = p-week-day-7
  check_dis-time-rule.month-day = p-month-day
  .
  _dub:
  for each dub_dis-time-rule no-lock where
          dub_dis-time-rule.upper-time-rule-num = p-upper-time-rule-num:
    do jj = 1 to num-entries("time-from,time-to,date-from,date-to,week-day-0,week-day-1,week-day-2,week-day-3,week-day-4,week-day-5,"  +                     "week-day-6,week-day-7,month-day,week-day-a,week-day-b,week-day-c,time-period,date-period"):
      assign
      v-curr-field = entry(jj, "time-from,time-to,date-from,date-to,week-day-0,week-day-1,week-day-2,week-day-3,week-day-4,week-day-5,"  +                     "week-day-6,week-day-7,month-day,week-day-a,week-day-b,week-day-c,time-period,date-period")
      .
      if lookup(v-curr-field, vt-level-1) > 0
      and v-uniq-field[jj] then do:
        if buffer dub_dis-time-rule:buffer-field(v-curr-field) = buffer check_dis-time-rule:buffer-field(v-curr-field)  then do:                ~
          assign
          v-dub = yes
          .
          run distruls-override-labels-2 in this-procedure ( input p-templ-rl-root
                                                          , input v-curr-field
                                                          , output v-field-label).
          LEAVE _dub.                                                                                ~
        end.                                                                                         ~
      end.
    end.
  end.
  if v-dub then do:
    undo, return error "rule-num":U.
  end.
end.
if v-tree <> "":U then do:
  for each buf_dis-cfg-rule no-lock where
          buf_dis-cfg-rule.time-templ-rl-root = p-templ-rl-root:
    do ii = 1 to num-entries(v-tree):
      assign
      v-entry = entry(ii, v-tree)
      .
      do jj = 1 to num-entries("time-from,time-to,date-from,date-to,week-day-0,week-day-1,week-day-2,week-day-3,week-day-4,week-day-5,"  +                     "week-day-6,week-day-7,month-day,week-day-a,week-day-b,week-day-c,time-period,date-period"):
        assign
        v-curr-field = entry(jj, "time-from,time-to,date-from,date-to,week-day-0,week-day-1,week-day-2,week-day-3,week-day-4,week-day-5,"  +                     "week-day-6,week-day-7,month-day,week-day-a,week-day-b,week-day-c,time-period,date-period")
        .
        if v-entry = v-curr-field then do:
          assign
          v-tree-field[jj] = yes
          .
          for each buf_temp-drt-prop where
                  buf_temp-drt-prop.templ-rl-root = p-templ-rl-root
              and buf_temp-drt-prop.upper-prop-code = buf_Dis-cfg-rule.pos-type
              and buf_temp-drt-prop.prop-code begins v-curr-field:
            if buf_temp-drt-prop.prop-code =  (v-curr-field + "-num-rec==":U) then do:
              assign
              v-num-rec[jj] = integer(buf_temp-drt-prop.property-value)
              v-num-rec-sign[jj] = "=":U
              .
            end.
            if buf_temp-drt-prop.prop-code =  (v-curr-field + "-num-rec<=":U) then do:
              assign
              v-num-rec[jj] = integer(buf_temp-drt-prop.property-value)
              v-num-rec-sign[jj] = "<":U
              .
            end.
            if buf_temp-drt-prop.prop-code =  (v-curr-field + "-num-rec>=":U) then do:
              assign
              v-num-rec[jj] = integer(buf_temp-drt-prop.property-value)
              v-num-rec-sign[jj] = ">":U
              .
            end.
          end.
        end.
      end.
    end.
  end.
  for each tt0-term_dis-time-rule no-lock where
          tt0-term_dis-time-rule.upper-time-rule-num = (if p-mode = 'ДОБАВЛЕНИЕ':U then 0 else p-time-rule-num):
    if tt0-term_dis-time-rule.month-day <> -1
    and (tt0-term_dis-time-rule.month-day > 31 or tt0-term_dis-time-rule.month-day < -1 ) then do:
      run err-mess in this-procedure (substitute("Значение номера дня месяца не может быть больше 31: &1", tt0-term_dis-time-rule.month-day)).
      undo, return error "month-day":U.
    end.
    if tt0-term_dis-time-rule.time-from <>  -1 then do:
      assign
      v-str = string(tt0-term_dis-time-rule.time-from, "hh:mm") no-error .
      if error-status:error then do:
        run err-mess in this-procedure (substitute("Значение начала периода времени неверное: &1"
                                                  , tt0-term_dis-time-rule.time-from)).
        undo, return error "time-from":U.
      end.
    end.
    if tt0-term_dis-time-rule.time-to <>  -1 then do:
      assign
      v-str = string(tt0-term_dis-time-rule.time-to, "hh:mm") no-error .
      if error-status:error then do:
        run err-mess in this-procedure (substitute("Значение конца периода времени неверное: &1", tt0-term_dis-time-rule.time-to)).
        undo, return error "time-to":U.
      end.
      if tt0-term_dis-time-rule.time-from > tt0-term_dis-time-rule.time-to
      and (not (tt0-term_dis-time-rule.date-from <> 12/31/1989
          and tt0-term_dis-time-rule.date-to <> 12/31/1989 )
          OR
          tt0-term_dis-time-rule.date-from = tt0-term_dis-time-rule.date-to)
      then do:
        run err-mess in this-procedure (substitute("Значение конца периода времени &1 не может быть меньше значения начала периода времени &2"
                                                  , string(tt0-term_dis-time-rule.time-to, "HH:mm")
                                                  , string(tt0-term_dis-time-rule.time-from, "HH:MM"))).
        undo, return error "time-from":U.
      end.
    end.
    if tt0-term_dis-time-rule.date-from < 12/31/1989 then do:
      if error-status:error then do:
        run err-mess in this-procedure (substitute("Значение начала периода дат неверное: &1", string(tt0-term_dis-time-rule.date-from, "99/99/9999"))).
        undo, return error "date-from":U.
      end.
    end.
    if tt0-term_dis-time-rule.date-to < 12/31/1989 then do:
      if error-status:error then do:
        run err-mess in this-procedure (substitute("Значение конца периода дат неверное: &1", string(tt0-term_dis-time-rule.date-to, "99/99/9999"))).
        undo, return error "date-to":U.
      end.
    end.
    if tt0-term_dis-time-rule.date-to <> 12/31/1989
    and tt0-term_dis-time-rule.date-to < tt0-term_dis-time-rule.date-from then do:
      run err-mess in this-procedure (substitute("Значение конца периода дат &1 не может быть меньше значения начала периода дат &2"
                                                , string(tt0-term_dis-time-rule.date-to, "99/99/9999")
                                                , string(tt0-term_dis-time-rule.date-from, "99/99/9999"))).
      undo, return error "date-from":U.
    end.
    _dub-tt:
    for each dub_tt-dis-time-rule no-lock where
            dub_tt-dis-time-rule.upper-time-rule-num = tt0-term_dis-time-rule.upper-time-rule-num:
      assign                                                                                         ~
      ii = 0.                                                                                        ~
      do jj = 1 to num-entries("time-from,time-to,date-from,date-to,week-day-0,week-day-1,week-day-2,week-day-3,week-day-4,week-day-5,"  +                     "week-day-6,week-day-7,month-day,week-day-a,week-day-b,week-day-c,time-period,date-period"):
        assign
        v-curr-field = entry(jj, "time-from,time-to,date-from,date-to,week-day-0,week-day-1,week-day-2,week-day-3,week-day-4,week-day-5,"  +                     "week-day-6,week-day-7,month-day,week-day-a,week-day-b,week-day-c,time-period,date-period")
        .
        if lookup(v-curr-field, vt-level-2) > 0 then do:
          assign
          ii = ii + 1
          .
          if v-uniq-field[jj] then do:
            if buffer dub_tt-dis-time-rule:buffer-field(v-curr-field):buffer-value =  buffer tt0-term_dis-time-rule:buffer-field(v-curr-field):buffer-value
            and recid(dub_tt-dis-time-rule) <> recid(tt0-term_dis-time-rule) then do:
              assign
              v-dub = yes.
              run distruls-override-labels-2 in this-procedure ( input p-templ-rl-root
                                                              , input v-curr-field
                                                              , output v-field-label).
              run err-mess in this-procedure (substitute("Не могут быть два детализированных правила скидки &1 &2"
                                                  , v-field-label
                                                  , string(buffer tt0-term_dis-time-rule:buffer-field(v-curr-field):buffer-value))).
              LEAVE _dub-tt.
            end.
          end.
          if v-num-rec[jj] > 0 then do:
            CASE v-num-rec-sign[jj]:
              when "<=":U then do:
                if ii >= v-num-rec[jj] then do:
                  assign
                  v-dub = yes
                  .
                  run distruls-override-labels-2 in this-procedure ( input p-templ-rl-root
                                                                  , input v-curr-field
                                                                  , output v-field-label).
                  run err-mess in this-procedure (substitute("Не могут быть больше &1 правила скидки, детализированных по &2"
                                                  , v-num-rec[jj]
                                                  , v-field-label)).
                  LEAVE _dub-tt.
                end.
              end.
            END CASE.
          end.
        end.
      end.
    end.
  end.
  if v-dub then do:
    undo, return error "time-rule-num":U.
  end.
end.
_MAIN:
DO ON ERROR UNDO, RETURN ERROR
ON STOP UNDO, RETURN ERROR:
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    run gen-b-code in this-procedure ( input 'drgb':U, output v-new-time-rule-num) no-error .
    if error-status:error then do:
      run err-mess in this-procedure (substitute("Ошибка при попытке создания номера расписания: &1", return-value )).
      undo _main, return error .
    end.
    create ub.dis-time-rule.
    assign
    ub.dis-time-rule.time-rule-num = v-new-time-rule-num
    p-recid = recid(ub.dis-time-rule)
    .
  end.
  else do:
    FIND FIRST ub.dis-time-rule where
              recid(ub.dis-time-rule) = p-recid No-ERROR.
    if not available ub.dis-time-rule then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись РАСПИСАНИЕ - p-recid" string(p-recid)
      view-as alert-box error .
      undo, return error '':u.
    end.
  end.
  assign
  ub.dis-time-rule.des               = p-des
  ub.dis-time-rule.sts               = (if p-mode = 'ДОБАВЛЕНИЕ':U then integer('0':U) else ub.dis-time-rule.sts)
  ub.dis-time-rule.upper-time-rule-num    = p-upper-time-rule-num
  ub.dis-time-rule.value-type        = p-value-type
  ub.dis-time-rule.date-from         = p-date-from
  ub.dis-time-rule.date-to           = p-date-to
  ub.dis-time-rule.time-from         = p-time-from
  ub.dis-time-rule.time-to           = p-time-to
  ub.dis-time-rule.month-day         = p-month-day
  ub.dis-time-rule.week-day-0        = p-week-day-0
  ub.dis-time-rule.week-day-1        = p-week-day-1
  ub.dis-time-rule.week-day-2        = p-week-day-2
  ub.dis-time-rule.week-day-3        = p-week-day-3
  ub.dis-time-rule.week-day-4        = p-week-day-4
  ub.dis-time-rule.week-day-5        = p-week-day-5
  ub.dis-time-rule.week-day-6        = p-week-day-6
  ub.dis-time-rule.week-day-7        = p-week-day-7
  ub.dis-time-rule.root              = yes
  ub.dis-time-rule.lvl-num           = 1
  ub.dis-time-rule.is-term           = (v-tree = "":U)
  ub.dis-time-rule.uniq-field        = v-tree
  ub.dis-time-rule.other-inf         = v-other
  ub.dis-time-rule.rl-root           = ub.dis-time-rule.time-rule-num
  ub.dis-time-rule.templ-rl-root     = p-upper-time-rule-num
  v-time-rule-num                    = ub.dis-time-rule.time-rule-num
  .
  release ub.dis-time-rule no-error.
  if error-status:error then do:
     run err-mess in this-procedure (substitute("Ошибка при сохранении записи РАСПИСАНИЕ с номером &1: &2: &3"
                            , v-time-rule-num
                            , ERROR-STATUS:GET-message(1)
                            , return-value
                            )).
    undo, return error "":U.
 end.
 if p-mode <> 'ДОБАВЛЕНИЕ':U then do:
  for each term_dis-time-rule where
          term_dis-time-rule.upper-time-rule-num = v-time-rule-num:
    find first tt0-term_dis-time-rule no-lock where
                tt0-term_dis-time-rule.upper-time-rule-num = v-time-rule-num
            AND tt0-term_dis-time-rule.time-rule-num = term_dis-time-rule.time-rule-num no-error .
    if not available tt0-term_dis-time-rule then do:
      delete term_dis-time-rule no-error .
      if error-status:error then do:
        run err-mess in this-procedure (substitute("Ошибка при попытке удаления расписания: &1 (детализация к расписанию &2): &3 ", tt0-term_dis-time-rule.time-rule-num, v-time-rule-num, return-value )).
        undo _main, return error .
      end.
    end.
  end.
 end.
 for each tt0-term_dis-time-rule :
    find first term_dis-time-rule where
                term_dis-time-rule.upper-time-rule-num = v-time-rule-num
            AND term_dis-time-rule.time-rule-num       = tt0-term_dis-time-rule.time-rule-num
            no-error .
    if not available term_dis-time-rule then do:
      run gen-b-code in this-procedure ( input 'drgb':U, output v-new-time-rule-num) no-error .
      if error-status:error then do:
      end.
      create term_dis-time-rule.
      assign
      term_dis-time-rule.upper-time-rule-num = v-time-rule-num
      term_dis-time-rule.time-rule-num       = v-new-time-rule-num
      term_dis-time-rule.rl-root        = v-time-rule-num
      .
      v-run-cn = yes.
    end.
    buffer-copy tt0-term_dis-time-rule except time-rule-num upper-time-rule-num root is-term lvl-num uniq-field
    time-from time-to date-from date-to month-day
    week-day-0 week-day-1 week-day-2 week-day-3 week-day-4 week-day-5 week-day-6 week-day-7
    to term_dis-time-rule
    assign
    term_dis-time-rule.time-from = (if lookup("time-from", vt-level-2) = 0
                                    then -1
                                    else tt0-term_dis-time-rule.time-from)
    term_dis-time-rule.time-to = (if lookup("time-to", vt-level-2) = 0
                                  then -1
                                  else tt0-term_dis-time-rule.time-to)
    term_dis-time-rule.date-from = (if lookup("date-from", vt-level-2) = 0
                                    then 12/31/1989
                                    else tt0-term_dis-time-rule.date-from)
    term_dis-time-rule.date-to = (if lookup("date-to", vt-level-2) = 0
                                   then 12/31/1989
                                   else tt0-term_dis-time-rule.date-to)
    term_dis-time-rule.week-day-0 = (if lookup("week-day-0", vt-level-2) = 0
                                     then ?
                                     else tt0-term_dis-time-rule.week-day-0)
    term_dis-time-rule.week-day-1 = (if lookup("week-day-1", vt-level-2) = 0
                                     then ?
                                     else tt0-term_dis-time-rule.week-day-1)
    term_dis-time-rule.week-day-2 = (if lookup("week-day-2", vt-level-2) = 0
                                     then ?
                                     else tt0-term_dis-time-rule.week-day-2)
    term_dis-time-rule.week-day-3 = (if lookup("week-day-3", vt-level-2) = 0
                                     then ?
                                     else tt0-term_dis-time-rule.week-day-3)
    term_dis-time-rule.week-day-4 = (if lookup("week-day-4", vt-level-2) = 0
                                     then ?
                                     else tt0-term_dis-time-rule.week-day-4)
    term_dis-time-rule.week-day-5 = (if lookup("week-day-5", vt-level-2) = 0
                                     then ?
                                     else tt0-term_dis-time-rule.week-day-5)
    term_dis-time-rule.week-day-6 = (if lookup("week-day-6", vt-level-2) = 0
                                     then ?
                                     else tt0-term_dis-time-rule.week-day-6)
    term_dis-time-rule.week-day-7 = (if lookup("week-day-7", vt-level-2) = 0
                                     then ?
                                     else tt0-term_dis-time-rule.week-day-7)
    term_dis-time-rule.month-day = (if lookup("month-day", vt-level-2) = 0
                                    then -1
                                    else tt0-term_dis-time-rule.month-day)
    term_dis-time-rule.root              = no
    term_dis-time-rule.lvl-num           = 2
    term_dis-time-rule.is-term           = yes
    term_dis-time-rule.uniq-field        = v-tree
    term_dis-time-rule.other-inf         = v-other
    .
    release term_dis-time-rule no-error .
    if error-status:error then do:
      run err-mess in this-procedure (substitute("Ошибка при попытке сохранения расписания: &1 (детализация к правилу &2): &3 ", v-new-time-rule-num, v-time-rule-num, return-value )).
      undo _main, return error .
    end.
  end.
 if v-run-cn then do:
    find first ub.dis-time-rule no-lock where
              ub.dis-time-rule.time-rule-num = v-time-rule-num .
    run str/callnews.p
        (input 'dis-time-rule':U
        ,input (buffer ub.dis-time-rule:handle)
        ).
  end.
end.
PROCEDURE err-mess:
  DEFINE INPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      p-mess = substitute("ПРАВИЛО СКИДКИ &1: ", (if p-mode = 'ИЗМЕНЕНИЕ':U then string(p-time-rule-num) else p-des) ) + chr(10) + p-mess.
    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.
procedure check-changes :
define input parameter p-time-rule-num like ub.dis-time-rule.time-rule-num no-undo .
define output parameter p-changes as logical no-undo .
define buffer buf_dis-time-rule for ub.dis-time-rule.
  do
  on error undo, return error
  :
    find first buf_dis-time-rule where buf_dis-time-rule.time-rule-num = p-time-rule-num.
    assign
    p-changes = (buf_dis-time-rule.value-type        <> p-value-type)
                or
                (buf_dis-time-rule.date-from         <> p-date-from )
                or
                (buf_dis-time-rule.date-to           <> p-date-to   )
                or
                (buf_dis-time-rule.time-from         <> p-time-from )
                or
                (buf_dis-time-rule.time-to           <> p-time-to   )
                or
                (buf_dis-time-rule.month-day         <> p-month-day )
                or
                (buf_dis-time-rule.week-day-0        <> p-week-day-0)
                or
                (buf_dis-time-rule.week-day-1        <> p-week-day-1)
                or
                (buf_dis-time-rule.week-day-2        <> p-week-day-2)
                or
                (buf_dis-time-rule.week-day-3        <> p-week-day-3)
                or
                (buf_dis-time-rule.week-day-4        <> p-week-day-4)
                or
                (buf_dis-time-rule.week-day-5        <> p-week-day-5)
                or
                (buf_dis-time-rule.week-day-6        <> p-week-day-6)
                or
                (buf_dis-time-rule.week-day-7        <> p-week-day-7)
  .
  end.
end procedure.
procedure distruls-override-labels-2 :
define input parameter p-templ-rl-root like ub.dis-time-rule.templ-rl-root no-undo .
define input parameter p-field-name as character no-undo .
define output parameter p-label as character no-undo .
define buffer buf_temp-drt-prop for temp-drt-prop.
do
on error undo, return error
:
  for each buf_temp-drt-prop no-lock where
                  buf_temp-drt-prop.templ-rl-root = p-templ-rl-root
              and buf_temp-drt-prop.prop-code = "Label":U
              aND buf_temp-drt-prop.UPPER-prop-code = p-field-name
              :
    assign
    p-label = buf_temp-drt-prop.property-value
    .
    leave.
  end.
  if p-label = '':U then do:
    case p-field-name:
      when "date-from" then do:
        p-label = "Дата с".
      end.
      when "date-to" then do:
        p-label = "Дата по".
      end.
      when "time-from" then do:
        p-label = "Время с".
      end.
      when "time-to" then do:
        p-label = "Время по".
      end.
      when "week-day-0" then do:
        p-label = "Все дни недели".
      end.
      when "week-day-1" then do:
        p-label = "Понедельник".
      end.
      when "week-day-2" then do:
        p-label = "Вторник".
      end.
      when "week-day-3" then do:
        p-label = "Среда".
      end.
      when "week-day-4" then do:
        p-label = "Четверг".
      end.
      when "week-day-5" then do:
        p-label = "Пятница".
      end.
      when "week-day-6" then do:
        p-label = "Суббота".
      end.
      when "week-day-7" then do:
        p-label = "Восресенье".
      end.
      when "month-day" then do:
        p-label = "День месяца".
      end.
      when "time-period" then do:
        p-label = "Период времени суток".
      end.
      when "date-period" then do:
        p-label = "Период дат".
      end.
    end case.
  end.
  end.
end procedure.
