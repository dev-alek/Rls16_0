block-level on error undo, throw.
define input parameter  p-rule-num          like ub.dis-rule.rule-num          no-undo .
define input parameter  p-pos-type          as character no-undo .
define input parameter  p-rl-root           like ub.dis-rule.rl-root           no-undo .
define input parameter  p-templ-rl-root     like ub.dis-rule.templ-rl-root     no-undo .
define input parameter  p-des               like ub.dis-rule.des               no-undo .
define input parameter  p-dis-kat           like ub.dis-rule.dis-kat           no-undo .
define input parameter  p-discnt-type       like ub.dis-rule.discnt-type       no-undo .
define input parameter  p-doc-qnty          like ub.dis-rule.doc-qnty          no-undo .
define input parameter  p-tot-sum           like ub.dis-rule.tot-sum           no-undo .
define input parameter  p-charkey_one       like ub.dis-rule.charkey_one       no-undo .
define input parameter  p-charkey_two       like ub.dis-rule.charkey_two       no-undo .
define input parameter  p-charkey_three     like ub.dis-rule.charkey_three     no-undo .
define input parameter  p-deckey_one        like ub.dis-rule.deckey_one       no-undo .
define input parameter  p-deckey_two        like ub.dis-rule.deckey_two       no-undo .
define input parameter  p-deckey_three      like ub.dis-rule.deckey_three     no-undo .
define input parameter  p-key#_one          like ub.dis-rule.key#_one          no-undo .
define input parameter  p-key#_two          like ub.dis-rule.key#_two          no-undo .
define input parameter  p-key#_three        like ub.dis-rule.key#_three        no-undo .
define input parameter  p-subject-type      like ub.dis-rule.subject-type      no-undo .
define input parameter  p-time-templ-rl-root like ub.dis-rule.time-templ-rl-root  no-undo .
define input parameter  p-time-rule-num     like ub.dis-rule.time-rule-num     no-undo .
define input parameter  p-upper-rule-num    like ub.dis-rule.upper-rule-num    no-undo .
define input parameter  p-value-type        like ub.dis-rule.value-type        no-undo .
define input parameter  p-host-code         like ub.dis-rule.host-code         no-undo .
DEFINE INPUT PARAMETER  p-obj-type          LIKE ub.dis-rule.obj-type          NO-UNDO.
DEFINE INPUT PARAMETER  p-obj-code          LIKE ub.dis-rule.obj-code          NO-UNDO.
DEFINE INPUT PARAMETER  p-discnt-value      LIKE ub.dis-rule.discnt-value      NO-UNDO.
define temp-table tt0-term_dis-rule no-undo like ub.dis-rule.
DEFINE INPUT PARAMETER TABLE FOR tt0-term_dis-rule.
define input-output parameter p-recid as recid no-undo.
define input parameter p-mode                         as character no-undo .
define input parameter p-silent                       as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dis-rul1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dis-rul1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в правилах скидок".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info5 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info5, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info5, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info5, v-inform, p-tbl-name ).
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
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info5, p-tbl-name ).
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
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info5 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info5, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info5 ).
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
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info5, vTable, chr(10) ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info5, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info5, v-inform, vTable ).
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
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info5, p-key-handle:name, v-field-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info5, vTable ).
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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info5, p-tbl-name, p-key-rec ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info5 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info5 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info5, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info5, v-inform, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info5, v-tbl-name ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info5 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info5 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info5, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info5, v-inform, v-tbl-name ).
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
define variable v-db-num like ub.db.db-num no-undo .
define variable v-hostcode like ub.sysconf.host-code no-undo .
define variable  v-new-rule-num      like ub.dis-rule.rule-num          no-undo .
define variable  v-rule-num          like ub.dis-rule.rule-num          no-undo .
define variable  v-des               like ub.dis-rule.des               no-undo .
define variable  v-level-1           as character no-undo .
define variable  v-level-2           as character no-undo .
define variable  v-discnt-type       like ub.dis-rule.discnt-type       no-undo .
define variable  v-subject-type      like ub.dis-rule.subject-type      no-undo .
define variable  v-value-type        like ub.dis-rule.value-type        no-undo .
define variable  v-term-value-type   like ub.dis-rule.value-type        no-undo .
define variable  v-global            as integer no-undo .
define variable  v-host              as integer no-undo .
define variable  v-object            as integer no-undo .
define variable  v-output-display    as logical   no-undo .
define variable  v-tree              as character no-undo .
define variable  v-other             as character no-undo .
define variable  v-dub               as logical no-undo .
define variable  v-region            as character no-undo .
define variable  v-entry             as character no-undo .
define variable ii as integer no-undo .
define variable iib as integer no-undo extent 14.
define variable jj as integer no-undo .
define variable v-curr-field as character no-undo .
define variable v-tree-field as logical no-undo extent 14.
define variable v-num-rec as integer no-undo extent 14.
define variable v-num-rec-sign as character no-undo extent 14.
define variable v-uniq-field as logical no-undo extent 14.
define variable v-down-limit as character no-undo extent 14.
define variable v-up-limit as character no-undo extent 14.
define variable v-dv-up-limit as character no-undo .
define variable v-dv-down-limit as character no-undo .
define variable v-des-len-up-limit as character no-undo .
define variable v-dis-gds-rule as integer no-undo init ?.
define variable v-dis-thbj-rule as integer no-undo init ?.
define variable v-dis-dc-rule as integer no-undo init ?.
define variable v-dis-dct-rule as integer no-undo init ?.
define variable v-dis-cp-rule as integer no-undo init ?.
define variable v-dis-gds-rule-log as logical no-undo.
define variable v-dis-thbj-rule-log as logical no-undo.
define variable v-dis-dc-rule-log as logical no-undo.
define variable v-dis-dct-rule-log as logical no-undo.
define variable v-dis-cp-rule-log as logical no-undo.
define variable v-gds-grp-log as logical   no-undo .
define variable v-dis-some-rule-log as logical   no-undo .
define variable v-field-label as character no-undo .
define variable v-found as logical no-undo .
define variable v-sts-mode as logical no-undo .
define variable v-ret-mess as character no-undo .
define variable v-dop as character no-undo .
define variable v-value-option-list as character no-undo .
define variable v-run-cn as logical no-undo .
define variable v-discnt-role as character no-undo .
define variable v-nonunique as character no-undo .
define variable v-nonunique2 as character no-undo .
define variable v-term-time-templ-rl-root as integer no-undo .
define buffer buf_temp-drt-prop for temp-drt-prop.
define buffer buf_sysconf  for ub.sysconf.
DEFINE BUFFER buf_clients-obj FOR ub.clients.
define buffer buf_db for ub.db .
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
define buffer buf_dis-gds-rule for ub.dis-gds-rule.
define buffer buf_dis-thbj-rule for ub.dis-thbj-rule.
define buffer buf_dis-dc-rule for ub.dis-dc-rule.
define buffer buf_dis-dct-rule for ub.dis-dct-rule.
define buffer buf_dis-cp-rule for ub.dis-cp-rule.
define buffer buf_dis-time-rule for ub.dis-time-rule.
define buffer buf_dis-rule for ub.dis-rule.
define buffer dub_dis-rule for ub.dis-rule.
define buffer term_dis-rule for ub.dis-rule.
define buffer dub_tt-dis-rule  for tt0-term_dis-rule.
define temp-table temp-dis-rule no-undo like ub.dis-rule.
define buffer check_dis-rule for temp-dis-rule.
define buffer buf_price-list-type for ub.price-list-type.
if p-mode <> 'ДОБАВЛЕНИЕ':U
AND p-mode <> 'ИЗМЕНЕНИЕ':U
AND p-mode <> ('ИЗМЕНЕНИЕ':U + chr(4) + 'sts':U)
then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр p-mode" p-mode
  view-as alert-box error .
  undo, return error '':u.
end.
if p-mode = ('ИЗМЕНЕНИЕ':U + chr(4) + 'sts':U) then do:
  assign
  v-sts-mode = yes
  p-mode = 'ИЗМЕНЕНИЕ':U
  .
end.
if p-host-code <> 0 then do:
  find first buf_sysconf no-lock where
            buf_sysconf.host-code = p-host-code no-error .
  if not available buf_sysconf then do:
    run err-mess in this-procedure ( substitute("Не найдена фирма с кодом &1", string(p-host-code)), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "host-code":U).
  end.
end.
if p-obj-type <> "":U
or p-obj-code <> 0 then do:
  find first buf_clients-obj no-lock where
            buf_clients-obj.obj-type = p-obj-type
        AND buf_clients-obj.obj-code = p-obj-code no-error .
  if not available buf_clients-obj
  or (p-obj-type <> 'маг':U and p-obj-type <> 'скл':U)
  then do:
    run err-mess in this-procedure ( substitute("Не найден объект &1&2", p-obj-type, p-obj-code), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "obj-code":U).
  end.
  if buf_clients-obj.host-code <> p-host-code then do:
    run err-mess in this-procedure ( substitute("Объект &1&2 принадлежит фирме &3, а правило скидки принадлежит фирме &4"
                  , p-obj-type, p-obj-code, buf_clients-obj.host-code , p-host-code), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "obj-code":U).
  end.
end.
if g#db-num <> 0
and (p-host-code = 0
or   p-obj-type = "":U
or   p-obj-code = 0)
then do:
  run err-mess in this-procedure ( substitute("Нельзя изменять/добавлять глобальную запись ПРАВИЛА СКИДКИ или запись по фирме в УБД:&1" +
                           "номер текущей БД &2"
                           , chr(10)
                           , g#db-num), output v-ret-mess).
  undo, return error (if p-silent then v-ret-mess else "host-code":U).
end.
run dr-code  in this-procedure (
     input  p-templ-rl-root
    ,output v-des
    ,output v-discnt-type
    ,output v-subject-type
    ,output v-value-type
    ,output v-level-1
    ,output v-level-2
    ,output v-global
    ,output v-host
    ,output v-object
    ,output v-output-display
    ,output v-tree
    ,output v-other
                               ) no-error .
if error-status:error then do:
    run err-mess in this-procedure ( substitute("Неверный номер шаблона для скидки: &1&2&3&2&4"
                               , p-templ-rl-root
                               , chr(10)
                               , error-status:get-message(1)
                               ,return-value), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "rule-num":U).
end.
run disrules-fill-properties in this-procedure ( input p-templ-rl-root).
for each buf_dis-cfg-rule no-lock where
        buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root
    and buf_dis-cfg-rule.table-name > '':U
        :
  if buf_dis-cfg-rule.table-name = 'dis-gds-rule':U then do:
    v-dis-gds-rule-log = yes.
  end.
  if buf_dis-cfg-rule.table-name = 'dis-thbj-rule':U then do:
    v-dis-thbj-rule-log = yes.
  end.
  if buf_dis-cfg-rule.table-name = 'dis-dc-rule':U then do:
    v-dis-dc-rule-log = yes.
  end.
  if buf_dis-cfg-rule.table-name = 'dis-dct-rule':U then do:
    v-dis-dct-rule-log = yes.
  end.
  if buf_dis-cfg-rule.table-name = 'dis-cp-rule':U then do:
    v-dis-cp-rule-log = yes.
  end.
  if buf_dis-cfg-rule.table-name = 'dis-grp-rule':U
  and buf_dis-cfg-rule.self-nonunique = 'gds-grp':U
  then do:
    v-gds-grp-log = yes.
  end.
  if buf_dis-cfg-rule.table-name = 'dis-some-rule':U
  then do:
    v-dis-some-rule-log = yes.
  end.
end.
do jj = 1 to num-entries("dis-kat,doc-qnty,tot-sum,time-rule-num,discnt-value,charkey_one,charkey_two,charkey_three,deckey_one,deckey_two,deckey_three,key#_one,key#_two,key#_three"):
  assign
  v-curr-field = entry(jj, "dis-kat,doc-qnty,tot-sum,time-rule-num,discnt-value,charkey_one,charkey_two,charkey_three,deckey_one,deckey_two,deckey_three,key#_one,key#_two,key#_three")
  .
  find first buf_temp-drt-prop where
            buf_temp-drt-prop.upper-prop-code = '':U
        and buf_temp-drt-prop.prop-code = v-curr-field + "=uniq"
        and logical(buf_temp-drt-prop.property-value) = yes
          no-error .
  if available buf_temp-drt-prop then do:
    assign
    v-uniq-field[jj] = yes
    .
  end.
end.
if p-pos-type = "" then do:
  define variable dflt-cd as character no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type6 as character no-undo .
define variable v-value-date6 as date no-undo .
define variable v-value-decimal6 as decimal no-undo .
define variable v-value-integer6 as INTEGER no-undo .
define variable v-value-logical6 AS LOGICAL no-undo .
define variable v-tth6 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output p-pos-type
    ,output v-value-date6
    ,output v-value-decimal6
    ,output v-value-integer6
    ,output v-value-logical6
    ,output v-param-type6
    ,INPUT-OUTPUT table-handle v-tth6
    )  .
delete object v-tth6 no-error.
end.
for each buf_temp-drt-prop where
        buf_temp-drt-prop.templ-rl-root = p-templ-rl-root
    and buf_temp-drt-prop.upper-prop-code = p-pos-type:
  case buf_temp-drt-prop.prop-code:
    when "discnt-value<=" then do:
      v-dv-up-limit = buf_temp-drt-prop.property-value.
    end.
    when "discnt-value>=" then do:
      v-dv-down-limit = buf_temp-drt-prop.property-value.
    end.
    when "discnt-value=" then do:
      v-dv-up-limit = buf_temp-drt-prop.property-value.
      v-dv-down-limit = buf_temp-drt-prop.property-value.
    end.
    when "des-len<=" then do:
      v-des-len-up-limit = buf_temp-drt-prop.property-value.
    end.
    when "discnt-value=radio" then do:
      v-dop = buf_temp-drt-prop.property-value.
      do ii = 1 to num-entries(v-dop):
        if ii modulo 2 = 0 then
        assign
        v-value-option-list = v-value-option-list + chr(44) + entry(ii, v-dop)
        .
      end.
      v-value-option-list = trim(v-value-option-list).
    end.
    otherwise do:
      do jj = 1 to num-entries("dis-kat,doc-qnty,tot-sum,time-rule-num,discnt-value,charkey_one,charkey_two,charkey_three,deckey_one,deckey_two,deckey_three,key#_one,key#_two,key#_three"):
        assign
        v-curr-field = entry(jj, "dis-kat,doc-qnty,tot-sum,time-rule-num,discnt-value,charkey_one,charkey_two,charkey_three,deckey_one,deckey_two,deckey_three,key#_one,key#_two,key#_three")
        .
        if buf_temp-drt-prop.prop-code = v-curr-field + "=uniq" then do:
          assign
          v-uniq-field[jj] = yes
          .
        end.
        if buf_temp-drt-prop.prop-code =  (v-curr-field + ">=":U) then do:
          assign
          v-down-limit[jj] = buf_temp-drt-prop.property-value
          .
        end.
        if buf_temp-drt-prop.prop-code = (v-curr-field + "<=":U) then do:
          assign
          v-up-limit[jj] = buf_temp-drt-prop.property-value
          .
        end.
      end.
    end.
  end case.
end.
if p-obj-code > 0 then do:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-db-num
  )  .
  if (v-db-num <> g#db-num and g#db-num > 0) then do:
    run err-mess in this-procedure ( substitute("Нельзя изменять/добавлять запись ПРАВИЛА СКИДКИ на объекте в чужой УБД:&1" +
                            "номер текущей БД &2, номер БД для &3&34 &5"
                            , chr(10)
                            , g#db-num
                            , p-obj-type
                            , p-obj-code
                            , v-db-num
                            ), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "obj-code":U).
  end.
  if (p-mode = 'ИЗМЕНЕНИЕ':U and v-db-num <> g#db-num and g#db-num > 0) then do:
    run err-mess in this-procedure ( substitute("Нельзя изменять запись ПРАВИЛА СКИДКИ на объекте в чужой БД:&1" +
                            "номер текущей БД &2, номер БД для &3&4: &5"
                            , chr(10)
                            , g#db-num
                            , p-obj-type
                            , p-obj-code
                            , v-db-num
                            ), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "obj-code":U).
  end.
end.
if p-mode = 'ИЗМЕНЕНИЕ':U then do:
  run waitfram-show in this-procedure ( "Ждите .. Проводится проверка возможности изменения правила" ).
  if v-dis-thbj-rule-log then do:
    _dis-thbj-rule:
    for each buf_dis-thbj-rule no-lock where
          buf_dis-thbj-rule.rule-num = p-rule-num:
      assign
      v-found = yes
      .
      leave _dis-thbj-rule.
    end.
    define variable v-can as logical   no-undo .
    if v-found
    then do:
      find first buf_temp-drt-prop no-lock where
      buf_temp-drt-prop.templ-rl-root = p-templ-rl-root
      and buf_temp-drt-prop.upper-prop-code = "can-update"
      and buf_temp-drt-prop.prop-code = "can" no-error.
      if available buf_temp-drt-prop
      and integer(buf_temp-drt-prop.property-value) > 0 then do:
        if integer(buf_temp-drt-prop.property-value) >= 2 then do:
          v-found = no.
        end.
        if integer(buf_temp-drt-prop.property-value) < 2 then do:
          find first buf_temp-drt-prop no-lock where
          buf_temp-drt-prop.templ-rl-root = p-templ-rl-root
          and buf_temp-drt-prop.upper-prop-code = "can-update"
          and buf_temp-drt-prop.prop-code = "can-message" no-error.
          if available buf_temp-drt-prop then do:
            message
            buf_temp-drt-prop.property-value
            view-as alert-box question buttons yes-no update v-can.
            if v-can then do:
              v-found = no.
            end.
          end.
        end.
      end.
    end.
    if v-found then do:
      run waitfram-hide in this-procedure .
      run err-mess in this-procedure ( substitute("Нельзя изменять/добавлять запись ПРАВИЛА СКИДКИ&1" +
                              "с ней связана ОБЩАЯ СКИДКА  НА ОБЪЕКТЕ: &2&3"
                              , chr(10)
                              , buf_dis-thbj-rule.obj-type
                              , buf_dis-thbj-rule.obj-code
                              )
                              , output v-ret-mess).
      undo, return error (if p-silent then v-ret-mess else "":U).
    end.
  end.
  if v-dis-dct-rule-log then do:
    _dis-dct-rule:
    for each buf_dis-dct-rule no-lock where
          buf_dis-dct-rule.rule-num = p-rule-num:
      assign
      v-found = yes
      .
      leave _dis-dct-rule.
    end.
    if v-found then do:
      run waitfram-hide in this-procedure .
      run err-mess in this-procedure ( substitute("Нельзя изменять/добавлять запись ПРАВИЛА СКИДКИ&1" +
                              "с ней связана СКИДКА по типу ДК: тип ДК &2 эмитент &3 тип скидки &4 фирма &5 объект &6&7"
                              , chr(10)
                              , buf_dis-dct-rule.type
                              , buf_dis-dct-rule.emitent-host-code
                              , entry (lookup (buf_dis-dct-rule.discnt-role, 'calc-d-pcnt,calc-cash-d-pcnt,calc-categ,dis-tot-flag,def-categ,def-pcnt,def-cash-pcnt':u) + 1, ',' + 'Расчет %скидки ДК на товар,Расчет %скидки ДК на итог,Расчет категории ДК,Участие в итогах по ДК,Категория ДК по умолчанию,% скидки ДК на товар по умолч.,% скидки ДК на итог по умолч.':u)
                              , buf_dis-dct-rule.host-code
                              , buf_dis-dct-rule.obj-type
                              , buf_dis-dct-rule.obj-code
                              )
                              , output v-ret-mess).
      undo, return error (if p-silent then v-ret-mess else "":U).
    end.
  end.
  if v-dis-cp-rule-log then do:
    _dis-cp-rule:
    for each buf_dis-cp-rule no-lock where
          buf_dis-cp-rule.rule-num = p-rule-num:
      assign
      v-found = yes
      .
      leave _dis-cp-rule.
    end.
    if v-found then do:
      run waitfram-hide in this-procedure .
      run err-mess in this-procedure ( substitute("Нельзя изменять/добавлять запись ПРАВИЛА СКИДКИ&1" +
                              "с ней связана СКИДКА ТИПА КАССОВОГО ПЛАТЕЖА: ПЛАТЕЖ &2 ВАЛЮТА &3 тип скидки &4 фирма &5 объект &6&7"
                              , chr(10)
                              , buf_dis-cp-rule.cdpay-code
                              , buf_dis-cp-rule.curr-code
                              , entry (lookup (buf_dis-cp-rule.discnt-role, 'simple-pay,qnty-pay':u) + 1, ',' + 'Скидка при оплате,Скидка на количество при оплате':u)
                              , buf_dis-cp-rule.host-code
                              , buf_dis-cp-rule.obj-type
                              , buf_dis-cp-rule.obj-code
                              )
                              , output v-ret-mess).
      undo, return error (if p-silent then v-ret-mess else "":U).
    end.
  end.
  run waitfram-hide in this-procedure .
end.
  if entry (lookup (string(p-discnt-type), '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,23,17,18,19,20,21,22,998,999,1001':U), '?,Клиент,Стандарт,Временная,Количество,Сумма,Персонал,Промо,Уценка,Счастл.час,Комплект,Сезонная,Катег,Ручная,Карта-маска,Округл. в пользу.клиента,Катег с исп шаблона,Оплата топливным купоном (Ашан),Абсолютная,Группа,Платеж,ЛНР,Округление,Оплата,Доп.условие,Другое,Погрешность':U) = "":U then do:
    run err-mess in this-procedure ( substitute("Неверный тип скидки: &1", p-discnt-type), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "discnt-type":U).
  end.
  if entry (lookup (string(p-subject-type), '0,1,2,3,4,5,7,8':U), 'Неизв,Товар,Подитог,Итог,Чек,Оплата,Товар_б/итог.скидки,Группа':U) = "":U then do:
    run err-mess in this-procedure ( substitute("Неверный тип объекта приложения скидки: &1", p-subject-type), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "subject-type":U).
  end.
  if entry (lookup (string(p-value-type), '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14':U), '?,%,Абс,ФЦ,опция,Бонус,Категория,Флаг,Правило,%-Абс-ФЦ,Сумма,ТПЛ-%,ТПЛ-ФЦ,ТПЛ-абс,Подарок':U) = "":U then do:
    run err-mess in this-procedure ( substitute("Неверный тип значения скидки: &1", p-value-type), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "value-type":U).
  end.
  find first buf_dis-rule no-lock where
          buf_dis-rule.rule-num = p-upper-rule-num no-error .
  if not available buf_dis-rule then do:
    run err-mess in this-procedure ( substitute("Неверный номер шаблона правила-скидки: &1", p-upper-rule-num), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "upper-rule-num":U).
  end.
  find first buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root
        and buf_dis-cfg-rule.time-templ-rl-root = p-time-templ-rl-root no-error.
  if not available buf_dis-cfg-rule then do:
    run err-mess in this-procedure ( substitute("Неверный тип шаблона расписания &1 для ПРАВИЛА СКИДКИ", p-time-templ-rl-root), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "":U).
  end.
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    find first buf_dis-cfg-rule no-lock where
            buF_dis-cfg-rule.templ-rl-root = p-templ-rl-root
          and buF_dis-cfg-rule.pos-type = p-pos-type
          no-error .
    if not available buf_Dis-cfg-rule
    or p-pos-type = '':U
    then do:
      run err-mess in this-procedure ( substitute("Неприменимо правило скидки такого типа &1 для типа касс &2"
                                                  , v-des
                                                  , p-pos-type), output v-ret-mess).
      undo, return error (if p-silent then v-ret-mess else "":U).
    end.
  end.
  if p-time-rule-num <> 0 then do:
    find first buf_dis-time-rule no-lock where
            buf_dis-time-rule.time-rule-num = p-time-rule-num no-error .
    if not available buf_dis-time-rule then do:
      run err-mess in this-procedure ( substitute("Неверный номер расписания для скидки: &1", p-time-rule-num), output v-ret-mess).
      undo, return error (if p-silent then v-ret-mess else "time-rule-num":U).
    end.
  end.
  else do:
    v-found = no.
    for each buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root
         and (if p-pos-type = ? then yes else buF_dis-cfg-rule.pos-type = p-pos-type):
       if buf_dis-cfg-rule.time-templ-rl-root <= 0 then do:
         v-found = yes.
       end.
    end.
    if not v-found
    and lookup("time-rule-num", v-level-1) > 0
    then do:
      run err-mess in this-procedure ( substitute("Не задано расписание для скидки"), output v-ret-mess).
      undo, return error (if p-silent then v-ret-mess else "time-rule-num":U).
    end.
  end.
  if p-rule-num <=  99999 then do:
      run err-mess in this-procedure ( substitute("Неверный номер правила для скидки: &1, значения меньшие &2 зарезервированы", p-rule-num, 99999), output v-ret-mess).
      undo, return error (if p-silent then v-ret-mess else "rule-num":U).
  end.
  assign
  v-rule-num = p-upper-rule-num
  .
if (lookup("time-rule-num", v-level-1) = 0
    and
    lookup("time-rule-num", v-level-2) = 0
    and
    0 <> p-time-rule-num) then do:
  p-time-rule-num = 0.
end.
if lookup("dis-kat", v-level-1) = 0
    and
    lookup("dis-kat", v-level-2) = 0 then do:
  p-dis-kat = -1.
end.
if lookup("doc-qnty", v-level-1) = 0
    and
    lookup("doc-qnty", v-level-2) = 0 then do:
  p-doc-qnty = -1.
end.
if lookup("tot-sum", v-level-1) = 0
    and
    lookup("tot-sum", v-level-2) = 0 then do:
  p-tot-sum = -1.
end.
if lookup("key#_one", v-level-1) = 0
    and
    lookup("key#_one", v-level-2) = 0 then do:
  p-key#_one = ?.
end.
if lookup("key#_two", v-level-1) = 0
    and
    lookup("key#_two", v-level-2) = 0 then do:
  p-key#_two = ?.
end.
if lookup("key#_three", v-level-1) = 0
    and
    lookup("key#_three", v-level-2) = 0 then do:
  p-key#_three = ?.
end.
if lookup("deckey_one", v-level-1) = 0
    and
    lookup("deckey_one", v-level-2) = 0 then do:
  p-deckey_one = ?.
end.
if lookup("deckey_two", v-level-1) = 0
    and
    lookup("deckey_two", v-level-2) = 0 then do:
  p-deckey_two = ?.
end.
if lookup("deckey_three", v-level-1) = 0
    and
    lookup("deckey_three", v-level-2) = 0 then do:
  p-deckey_three = ?.
end.
if lookup("charkey_one", v-level-1) = 0
    and
    lookup("charkey_one", v-level-2) = 0 then do:
  p-charkey_one = '':U.
end.
if lookup("charkey_two", v-level-1) = 0
    and
    lookup("charkey_two", v-level-2) = 0 then do:
  p-charkey_two = '':U.
end.
if lookup("charkey_three", v-level-1) = 0
    and
    lookup("charkey_three", v-level-2) = 0 then do:
  p-charkey_three = '':U.
end.
if (v-discnt-type <> p-discnt-type)
or v-subject-type <> p-subject-type
or (v-value-type <> p-value-type )
or (v-global = 0 and p-host-code = 0)
or (v-host  = 0 and p-host-code <> 0 and p-obj-code = 0)
or (v-object = 0 and p-obj-code <> 0)
then do:
    run err-mess in this-procedure ( substitute("Несоответствуют друг другу параметры шаблона &1 и задаваемые параметры правила скидки"
                                    , p-templ-rl-root), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "templ-rl-root":U).
end.
if v-output-display = no then do:
  run err-mess in this-procedure ( substitute("Нельзя добавить правило скидки по неиспользуемому шаблону: &1", p-templ-rl-root), output v-ret-mess).
  undo, return error (if p-silent then v-ret-mess else "templ-rl-root":U).
end.
if v-value-type = integer('1':U) then do:
  if p-discnt-value > 0
  and p-discnt-value > 100 then do:
    run err-mess in this-procedure ( substitute("Значение процентной скидки не может быть больше 100%: &1", p-discnt-value), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "rule-num":U).
  end.
end.
if v-value-type = integer('3':U) then do:
  if p-discnt-value < 0
  then do:
    run err-mess in this-procedure ( substitute("Значение ФЦ не может быть < 0: &1", p-discnt-value), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "rule-num":U).
  end.
end.
if v-value-type = integer('11':U)
or v-value-type = integer('13':U)
or v-value-type = integer('12':U) then do:
  find first buf_price-list-type no-lock where
            buf_price-list-type.plt-id = integer(entry(1, p-charkey_one, "-"))
        and buf_price-list-type.plt-db-num = integer(entry(2, p-charkey_one, "-")) no-error.
  if not available buf_price-list-type
  or buf_price-list-type.stts <> integer('0':U) then do:
    run err-mess in this-procedure ( substitute("ТПЛ &1 (БД &2) не существует или удален"
                                              ,entry(1, p-charkey_one, "-")
                                              ,entry(2, p-charkey_one, "-")
                                              ), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "charkey_one":U).
  end.
end.
if v-value-type = integer('4':U) then do:
  if lookup(string(p-discnt-value), v-value-option-list) = 0 then do:
    run err-mess in this-procedure ( substitute("Значение может принимать только значения &1", v-value-option-list), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "discnt-value":U).
  end.
end.
create check_dis-rule.
assign
check_dis-rule.dis-kat = p-dis-kat
check_dis-rule.doc-qnty = p-doc-qnty
check_dis-rule.tot-sum = p-tot-sum
check_dis-rule.discnt-value = p-discnt-value
check_dis-rule.charkey_one = p-charkey_one
check_dis-rule.charkey_two = p-charkey_two
check_dis-rule.charkey_three = p-charkey_three
check_dis-rule.deckey_one = p-deckey_one
check_dis-rule.deckey_two = p-deckey_two
check_dis-rule.deckey_three = p-deckey_three
check_dis-rule.key#_one = p-key#_one
check_dis-rule.key#_two = p-key#_two
check_dis-rule.key#_three = p-key#_three
.
do jj = 1 to num-entries("dis-kat,doc-qnty,tot-sum,time-rule-num,discnt-value,charkey_one,charkey_two,charkey_three,deckey_one,deckey_two,deckey_three,key#_one,key#_two,key#_three"):
  assign
  v-curr-field = entry(jj, "dis-kat,doc-qnty,tot-sum,time-rule-num,discnt-value,charkey_one,charkey_two,charkey_three,deckey_one,deckey_two,deckey_three,key#_one,key#_two,key#_three")
  .
  if v-down-limit[jj] <> "":u then do:
    if decimal(buffer check_dis-rule:buffer-field(v-curr-field):buffer-value)  < decimal(v-down-limit[jj]) then do:
      run disrules-override-labels-2 in this-procedure ( input p-templ-rl-root
                                                       , input v-curr-field
                                                       , output v-field-label).
      run err-mess in this-procedure ( substitute("Значение &1 не может быть меньше &2"
                                                , v-field-label
                                                , v-down-limit[jj]), output v-ret-mess).
      undo, return error (if p-silent then v-ret-mess else "":U ).
    end.
    v-down-limit[jj] = "":u.
  end.
  if v-up-limit[jj] <> "":u then do:
    if decimal(buffer check_dis-rule:buffer-field(v-curr-field):buffer-value)  > decimal(v-up-limit[jj]) then do:
      run disrules-override-labels-2 in this-procedure ( input p-templ-rl-root
                                                       , input v-curr-field
                                                       , output v-field-label).
      run err-mess in this-procedure ( substitute("Значение &1 не может быть больше &2"
                  , v-field-label
                  , v-up-limit[jj]), output v-ret-mess).
      undo, return error (if p-silent then v-ret-mess else "":U) .
    end.
    v-up-limit[jj] = "":u.
  end.
end.
if v-dis-thbj-rule-log then do:
  for each buf_dis-cfg-rule no-lock where
          buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root
      and buf_dis-cfg-rule.pos-type = p-pos-type
      and buf_dis-cfg-rule.table-name = 'dis-thbj-rule':U
  :
    if  buf_Dis-cfg-rule.link-prop = integer('0':U) then do:
      assign
      v-discnt-role = buf_dis-cfg-rule.discnt-role.
      do jj = 1 to num-entries(buf_dis-cfg-rule.nonunique):
        assign
        v-curr-field = entry(jj, buf_dis-cfg-rule.nonunique)
        .
        assign
        v-nonunique = v-nonunique + (if v-nonunique = '':u then '':U else chr(4)) +
                      string(buffer check_dis-rule:buffer-field(v-curr-field):buffer-value).
      end.
      find first buf_dis-thbj-rule no-lock where
            buF_dis-thbj-rule.host-code = p-host-code
        and buF_dis-thbj-rule.obj-type = p-obj-type
        and buF_dis-thbj-rule.obj-code = p-obj-code
        and buF_dis-thbj-rule.pos-type = p-pos-type
        and buF_dis-thbj-rule.discnt-role = v-discnt-role
        and buf_dis-thbj-rule.nonunique = v-nonunique no-error .
      if available buf_dis-thbj-rule
      and buf_dis-thbj-rule.rule-num <> p-rule-num
      then  do:
        run err-mess in this-procedure (
        substitute("Уже есть правило скидки &1 с той же областью действия &2:&3" +
                  "(правило &4 с типом &5)&3" +
                  "для такой скидки можно определить только одно такое правило "
                   , v-des
                   , v-region
                   ,chr(10)
                   ,buf_dis-thbj-rule.rule-num
                   ,buf_Dis-thbj-rule.templ-rl-root
                   )
                 , output v-ret-mess).
        undo, return error (if p-silent then v-ret-mess else "":U).
      end.
    end.
  end.
end.
assign
v-region = gtregion(p-host-code, p-obj-type, p-obj-code, no)
.
_dub:
for each dub_dis-rule no-lock where
        dub_dis-rule.upper-rule-num = p-upper-rule-num
    AND dub_dis-rule.host-code      = p-host-code
    AND dub_dis-rule.obj-type       = p-obj-type
    AND dub_dis-rule.obj-code       = p-obj-code
    and dub_dis-rule.sts            = integer('0':U)
    :
  if p-mode = 'ИЗМЕНЕНИЕ':U
  and  dub_dis-rule.rule-num = p-rule-num then next.
  do jj = 1 to num-entries("dis-kat,doc-qnty,tot-sum,time-rule-num,discnt-value,charkey_one,charkey_two,charkey_three,deckey_one,deckey_two,deckey_three,key#_one,key#_two,key#_three"):
    assign
    v-curr-field = entry(jj, "dis-kat,doc-qnty,tot-sum,time-rule-num,discnt-value,charkey_one,charkey_two,charkey_three,deckey_one,deckey_two,deckey_three,key#_one,key#_two,key#_three")
    .
    if v-uniq-field[jj] then do:
      if buffer dub_dis-rule:buffer-field(v-curr-field):buffer-value = buffer check_dis-rule:buffer-field(v-curr-field):buffer-value then do:
        assign
        v-dub = yes
        .
        run disrules-override-labels-2 in this-procedure ( input p-templ-rl-root
                                                        , input v-curr-field
                                                        , output v-field-label).
        run err-mess in this-procedure ( substitute("Уже есть правило скидки с той же областью действия &3"
                                                    , v-field-label
                                                    , string(buffer check_dis-rule:buffer-field(v-curr-field):buffer-value)
                                                    , v-region)
                                                    , output v-ret-mess).
        LEAVE _dub.
      end.
    end.
  end.
end.
if v-dub then do:
  undo, return error (if p-silent then v-ret-mess else "rule-num":U).
end.
if v-tree = '':U then do:
  if v-dv-up-limit <> '':U
  and p-discnt-value > decimal(v-dv-up-limit) then do:
      run err-mess in this-procedure ( substitute("Значение скидки не может быть больше &1"
                                                  , v-dv-up-limit)
                                      , output v-ret-mess).
      undo, return error (if p-silent then v-ret-mess else "":U) .
  end.
  if v-dv-down-limit <> '':U
  and p-discnt-value > decimal(v-dv-up-limit) then do:
      run err-mess in this-procedure ( substitute("Значение скидки не может быть меньше &1"
                                                  , v-dv-down-limit)
                                      , output v-ret-mess).
      undo, return error (if p-silent then v-ret-mess else "":U) .
  end.
end.
if v-des-len-up-limit <> '':U
and length(p-des) > integer(v-des-len-up-limit) then do:
  run err-mess in this-procedure ( substitute("Описание скидки не может быть длиннее &1 знаков"
                                              , v-des-len-up-limit)
                                  , output v-ret-mess).
  undo, return error (if p-silent then v-ret-mess else "":U) .
end.
if v-tree <> "":U then do:
  do ii = 1 to num-entries(v-tree):
    assign
    v-entry = entry(ii, v-tree)
    .
    do jj = 1 to num-entries("dis-kat,doc-qnty,tot-sum,time-rule-num,discnt-value,charkey_one,charkey_two,charkey_three,deckey_one,deckey_two,deckey_three,key#_one,key#_two,key#_three"):
      assign
      v-curr-field = entry(jj, "dis-kat,doc-qnty,tot-sum,time-rule-num,discnt-value,charkey_one,charkey_two,charkey_three,deckey_one,deckey_two,deckey_three,key#_one,key#_two,key#_three")
      .
      if v-entry = v-curr-field then do:
        assign
        v-tree-field[jj] = yes
        .
        for each buf_temp-drt-prop where
                buf_temp-drt-prop.templ-rl-root = p-templ-rl-root
            and buf_temp-drt-prop.upper-prop-code = p-pos-type
            and buf_temp-drt-prop.prop-code begins v-curr-field:
          if buf_temp-drt-prop.prop-code =  (v-curr-field + "-num-rec==":U) then do:
            assign
            v-num-rec[jj] = integer(buf_temp-drt-prop.property-value)
            v-num-rec-sign[jj] = "==":U
            .
          end.
          if buf_temp-drt-prop.prop-code =  (v-curr-field + "-num-rec<=":U) then do:
            assign
            v-num-rec[jj] = integer(buf_temp-drt-prop.property-value)
            v-num-rec-sign[jj] = "<=":U
            .
          end.
          if buf_temp-drt-prop.prop-code =  (v-curr-field + "-num-rec>=":U) then do:
            assign
            v-num-rec[jj] = integer(buf_temp-drt-prop.property-value)
            v-num-rec-sign[jj] = ">=":U
            .
          end.
          if buf_temp-drt-prop.prop-code = (v-curr-field + ">=":U) then do:
            assign
            v-down-limit[jj] = buf_temp-drt-prop.property-value
            .
          end.
          if buf_temp-drt-prop.prop-code =  (v-curr-field + "<=":U) then do:
            assign
            v-up-limit[jj] = buf_temp-drt-prop.property-value
            .
          end.
        end.
      end.
    end.
  end.
define variable v-entry-entry as character no-undo .
define variable v-entry-record as character no-undo .
define variable v-entry-name as character no-undo .
define variable v-name-name as character no-undo .
define variable v-entry-list as character no-undo .
define variable nn as integer no-undo .
 _dub:
  for each tt0-term_dis-rule no-lock where
          tt0-term_dis-rule.upper-rule-num = (if p-mode = 'ДОБАВЛЕНИЕ':U then p-templ-rl-root else p-rule-num):
    v-entry-record = '':U.
    v-entry-name = '':U.
    do nn = 1 to num-entries(v-tree):
      assign
      v-entry-entry = string(buffer tt0-term_dis-rule:buffer-field(entry(nn, v-tree)):buffer-value)
      .
      run disrules-override-labels-2 in this-procedure ( input p-templ-rl-root
                                                       , input entry(nn, v-tree)
                                                       , output v-field-label).
      v-name-name = substitute("&1 = &2", v-field-label, buffer tt0-term_dis-rule:buffer-field(entry(nn, v-tree)):buffer-value).
      assign
      v-entry-record = v-entry-record +
                (if v-entry-record = '':U then "" else chr(4)) + v-entry-entry
      v-entry-name = v-entry-name +
                (if v-entry-name = '':U then "" else chr(4)) + v-name-name
                .
    end.
    if lookup(v-entry-record, v-entry-list, chr(3)) > 0 then do:
      assign
      v-dub = yes
      .
      run err-mess in this-procedure (  substitute("Более одного подправила: &1", v-entry-name)
                                      , output v-ret-mess).
      undo, return error (if p-silent then v-ret-mess else "":U) .
    end.
    v-entry-list = v-entry-list + (if v-entry-list = '':U then "" else chr(3)) + v-entry-record.
  end.
  for each tt0-term_dis-rule no-lock where
          tt0-term_dis-rule.upper-rule-num = (if p-mode = 'ДОБАВЛЕНИЕ':U then p-templ-rl-root else p-rule-num):
    if tt0-term_dis-rule.value-type = integer('1':U) then do:
      if tt0-term_dis-rule.discnt-value > 0
      and tt0-term_dis-rule.discnt-value > 100 then do:
        run err-mess in this-procedure ( substitute("Значение процентной скидки не может быть больше 100%: &1", tt0-term_dis-rule.discnt-value), output v-ret-mess).
        undo, return error (if p-silent then v-ret-mess else "rule-num":U).
      end.
    end.
    if tt0-term_dis-rule.value-type = integer('3':U) then do:
      if tt0-term_dis-rule.discnt-value < 0
      then do:
        run err-mess in this-procedure ( substitute("Значение ФЦ не может быть < 0: &1", tt0-term_dis-rule.discnt-value), output v-ret-mess).
        undo, return error (if p-silent then v-ret-mess else "rule-num":U).
      end.
      if tt0-term_dis-rule.value-type = integer('11':U)
      or tt0-term_dis-rule.value-type = integer('13':U)
      or tt0-term_dis-rule.value-type = integer('12':U) then do:
        find first buf_price-list-type no-lock where
                  buf_price-list-type.plt-id = integer(entry(1, tt0-term_dis-rule.charkey_one, "-"))
              and buf_price-list-type.plt-db-num = integer(entry(2, tt0-term_dis-rule.charkey_one, "-")) no-error.
        if not available buf_price-list-type
        or buf_price-list-type.stts <> integer('0':U) then do:
          run err-mess in this-procedure ( substitute("ТПЛ &1 (БД &2) не существует или удален"
                                                    ,entry(1, tt0-term_dis-rule.charkey_one, "-")
                                                    ,entry(2, tt0-term_dis-rule.charkey_one, "-")
                                                    ), output v-ret-mess).
          undo, return error (if p-silent then v-ret-mess else "":U).
        end.
      end.
    end.
    if tt0-term_dis-rule.value-type = integer('4':U) then do:
      if lookup(string(tt0-term_dis-rule.discnt-value), v-value-option-list) = 0 then do:
        run err-mess in this-procedure ( substitute("Значение может принимать только значения &1", v-value-option-list), output v-ret-mess).
        undo, return error (if p-silent then v-ret-mess else "discnt-value":U).
      end.
    end.
    for each buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root
        and buf_dis-cfg-rule.table-name > '':U
    on error undo, return error error-status:get-message(1) :
      if buf_dis-cfg-rule.projection = '':U then next.
      v-entry-name = '':U  .
       run check-projection in this-procedure ( buffer tt0-term_dis-rule
                                               ,input buf_Dis-cfg-rule.table-name
                                               ,input buf_dis-cfg-rule.projection
                                               ,output v-entry-name
                                               ) no-error.
       if error-status:error then do:
          run err-mess in this-procedure (  substitute("Неверные сслылки в правиле: &1", v-entry-name)
                                          , output v-ret-mess).
          undo, return error (if p-silent then v-ret-mess else "":U) .
       end.
    end.
    if v-dv-up-limit <> '':U
    and tt0-term_dis-rule.discnt-value > decimal(v-dv-up-limit) then do:
        run err-mess in this-procedure ( substitute("Значение скидки не может быть больше &1"
                                                   , v-dv-up-limit)
                                        , output v-ret-mess).
        undo, return error (if p-silent then v-ret-mess else "":U) .
    end.
    if v-dv-down-limit <> '':U
    and tt0-term_dis-rule.discnt-value > decimal(v-dv-up-limit) then do:
        run err-mess in this-procedure ( substitute("Значение скидки не может быть меньше &1"
                                                    , v-dv-down-limit)
                                       , output v-ret-mess).
        undo, return error (if p-silent then v-ret-mess else "":U) .
    end.
    _JJ:
    do jj = 1 to num-entries("dis-kat,doc-qnty,tot-sum,time-rule-num,discnt-value,charkey_one,charkey_two,charkey_three,deckey_one,deckey_two,deckey_three,key#_one,key#_two,key#_three"):
      assign
      v-curr-field = entry(jj, "dis-kat,doc-qnty,tot-sum,time-rule-num,discnt-value,charkey_one,charkey_two,charkey_three,deckey_one,deckey_two,deckey_three,key#_one,key#_two,key#_three")
      .
      if v-tree-field[jj]  = no
      and not can-find(first temp-drt-prop no-lock where
                            temp-drt-prop.templ-rl-root = p-templ-rl-root
                        and temp-drt-prop.upper-prop-code = "Level2_UsingFields":U
                        and temp-drt-prop.prop-code = v-curr-field) then do:
        next _jj.
      end.
      run disrules-override-labels-2 in this-procedure ( input p-templ-rl-root
                                                      , input v-curr-field
                                                      , output v-field-label).
      if v-down-limit[jj] <> "":u then do:
        if decimal(buffer tt0-term_dis-rule:buffer-field(v-curr-field):buffer-value)  < decimal(v-down-limit[jj]) then do:
          run err-mess(substitute("Значение &1 не может быть меньше &2"
                                  , v-field-label
                                  , v-down-limit[jj])
                                  , output v-ret-mess).
          undo, return error (if p-silent then v-ret-mess else "":U) .
        end.
      end.
      if v-up-limit[jj] <> "":u then do:
        if decimal(buffer tt0-term_dis-rule:buffer-field(v-curr-field):buffer-value)  > decimal(v-up-limit[jj]) then do:
          run err-mess in this-procedure ( substitute("Значение &1 не может быть больше &2"
                                                    , v-field-label
                                                    , v-up-limit[jj])
                                          , output v-ret-mess).
          undo, return error (if p-silent then v-ret-mess else "":U) .
        end.
      end.
    end.
    assign
    iib[1] = 0
    iib[2] = 0
    iib[3] = 0
    iib[4] = 0
    iib[5] = 0
    iib[6] = 0
    iib[7] = 0
    iib[8] = 0
    iib[9] = 0
    iib[10] = 0
    iib[11] = 0
    iib[12] = 0
    iib[13] = 0
    iib[14] = 0
    .
    _dub-tt:
    for each dub_tt-dis-rule no-lock where
            dub_tt-dis-rule.upper-rule-num = tt0-term_dis-rule.upper-rule-num
    break
    by dub_tt-dis-rule.rule-num:
      _JJ:
      do jj = 1 to num-entries("dis-kat,doc-qnty,tot-sum,time-rule-num,discnt-value,charkey_one,charkey_two,charkey_three,deckey_one,deckey_two,deckey_three,key#_one,key#_two,key#_three"):
        assign
        v-curr-field = entry(jj, "dis-kat,doc-qnty,tot-sum,time-rule-num,discnt-value,charkey_one,charkey_two,charkey_three,deckey_one,deckey_two,deckey_three,key#_one,key#_two,key#_three")
        .
        if v-tree-field[jj]  = no
        and not can-find(first temp-drt-prop no-lock where
                            temp-drt-prop.templ-rl-root = p-templ-rl-root
                        and temp-drt-prop.upper-prop-code = "Level2_UsingFields":U
                        and temp-drt-prop.prop-code = v-curr-field) then do:
          next _jj.
        end.
        run disrules-override-labels-2 in this-procedure ( input p-templ-rl-root
                                                        ,input v-curr-field
                                                        ,output v-field-label).
        assign
        iib[jj] = iib[jj] + 1
        .
        if v-num-rec[jj] > 0 then do:
          CASE v-num-rec-sign[jj]:
            when "<=":U then do:
              if iib[jj] > v-num-rec[jj] then do:
                assign
                v-dub = yes
                .
                run err-mess in this-procedure ( input substitute("Количество правил детализированных &2 не может быть больше &1"
                                              , v-num-rec[jj]
                                              , v-field-label)
                                              , output v-ret-mess).
                undo, return error (if p-silent then v-ret-mess else "":U).
              end.
            end.
            when ">=":U then do:
              if last(dub_tt-dis-rule.rule-num) and
              iib[jj] < v-num-rec[jj] then do:
                assign
                v-dub = yes
                .
                run err-mess in this-procedure ( input substitute("Количество правил детализированных &2 не может быть меньше &1"
                                                            ,v-num-rec[jj]
                                                            ,v-field-label)
                                                            ,output v-ret-mess).
                undo, return error (if p-silent then v-ret-mess else "":U).
              end.
            end.
            when "==":U then do:
              if last(dub_tt-dis-rule.rule-num) and
              iib[jj] <> v-num-rec[jj] then do:
                assign
                v-dub = yes
                .
                run err-mess in this-procedure ( input substitute("Количество правил детализированных &2 должно быть равно &1"
                                                            , v-num-rec[jj]
                                                            , v-field-label)
                                                            , output v-ret-mess).
                undo, return error (if p-silent then v-ret-mess else "":U).
              end.
            end.
          END CASE.
        end.
      end.
    end.
  end.
  if v-dub then do:
    undo, return error "rule-num":U.
  end.
end.
_MAIN:
DO ON ERROR UNDO, RETURN ERROR
ON STOP UNDO, RETURN ERROR:
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    run gen-b-code in this-procedure ( input 'drgb':U, output v-new-rule-num) no-error .
    if error-status:error then do:
      run err-mess in this-procedure ( substitute("Ошибка при попытке создания номера правила скидки: &1", return-value ), output v-ret-mess).
      undo _main, return error (if p-silent then v-ret-mess else '':U).
    end.
    create ub.dis-rule.
    assign
    ub.dis-rule.rule-num = v-new-rule-num
    p-recid = recid(ub.dis-rule)
    .
  end.
  else do:
    FIND FIRST ub.dis-rule where
              recid(ub.dis-rule) = p-recid No-ERROR.
    if not available ub.dis-rule then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись ПРАВИЛО СКИДКИ - p-recid" string(p-recid)
      view-as alert-box error .
      undo, return error '':u.
    end.
    if ub.dis-rule.sts = integer('99':U) then do:
      message
      "Правило находится в статусе" entry (lookup (STRING(ub.dis-rule.sts), '0,1,2,99,98':U), 'исп,не-исп,детализ,удаление,запр.удал':U)  skip
      "ИЗМЕНЕНИЕ ЗАПРЕЩЕНО" skip
      view-as alert-box ERROR.
      undo, return error '':U.
    end.
    if ub.dis-rule.rule-num <> p-rule-num
    or ub.dis-rule.host-code <> p-host-code
    or ub.dis-rule.obj-type <> p-obj-type
    or ub.dis-rule.obj-code <> p-obj-code
    or ub.dis-rule.time-templ-rl-root <> p-time-templ-rl-root
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Для уже имеющейся записи нельзя изменить"
      "номер правила и/или привязку к объекту и фирме" skip
      "и тип привязанного расписания"
      view-as alert-box ERROR.
      undo, return error '':U.
    end.
  end.
  if v-sts-mode then do:
    v-rule-num = p-rule-num.
  end.
  else do:
  assign
  ub.dis-rule.des               = p-des
  ub.dis-rule.dis-kat           = p-dis-kat
  ub.dis-rule.discnt-type       = p-discnt-type
  ub.dis-rule.doc-qnty          = p-doc-qnty
  ub.dis-rule.tot-sum           = p-tot-sum
  ub.dis-rule.sts               = (if p-mode = 'ДОБАВЛЕНИЕ':U then integer('0':U) else ub.dis-rule.sts)
  ub.dis-rule.subject-type      = p-subject-type
  ub.dis-rule.time-rule-num     = p-time-rule-num
  ub.dis-rule.time-templ-rl-root = (if available buf_dis-time-rule
                                    then buf_dis-time-rule.templ-rl-root
                                    else 0)
  ub.dis-rule.upper-rule-num    = p-upper-rule-num
  ub.dis-rule.value-type        = p-value-type
  ub.dis-rule.discnt-value      = p-discnt-value
  ub.dis-rule.host-code         = p-host-code
  ub.dis-rule.obj-type          = p-obj-type
  ub.dis-rule.obj-code          = p-obj-code
  ub.dis-rule.root              = yes
  ub.dis-rule.lvl-num           = 1
  ub.dis-rule.is-term           = (v-tree = "":U)
  ub.dis-rule.uniq-field        = v-tree
  ub.dis-rule.other-inf         = v-other
  ub.dis-rule.rl-root           = ub.dis-rule.rule-num
  ub.dis-rule.templ-rl-root     = p-upper-rule-num
  ub.dis-rule.key#_one          = p-key#_one
  ub.dis-rule.key#_two          = p-key#_two
  ub.dis-rule.key#_three        = p-key#_three
  ub.dis-rule.charkey_one       = p-charkey_one
  ub.dis-rule.charkey_two       = p-charkey_two
  ub.dis-rule.charkey_three     = p-charkey_three
  ub.dis-rule.deckey_one        = p-deckey_one
  ub.dis-rule.deckey_two        = p-deckey_two
  ub.dis-rule.deckey_three      = p-deckey_three
  v-rule-num                    = ub.dis-rule.rule-num
  .
  release ub.dis-rule no-error.
  if error-status:error then do:
     run err-mess in this-procedure ( substitute("Ошибка при сохранении записи ПРАВИЛО СКИДКИ с номером &1: &2: &3"
                            , v-rule-num
                            , ERROR-STATUS:GET-message(1)
                            , return-value
                            ), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "":U).
 end.
 end.
 if (p-mode = 'ДОБАВЛЕНИЕ':U
 or v-sts-mode = yes)
 and can-find(first ub.dis-cfg-rule no-lock where
                    ub.dis-cfg-rule.templ-rl-root = p-templ-rl-root
                and ub.dis-cfg-rule.table-name = 'dis-thbj-rule':U)
 then do:
   v-nonunique = '':U.
   for each buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.templ-rl-root  = p-templ-rl-root
        and buf_dis-cfg-rule.table-name = 'dis-thbj-rule':U
        and buf_dis-cfg-rule.pos-type = p-pos-type
        and ((p-time-templ-rl-root = 0 and lookup("time-rule-num", v-level-2) > 0)
            or buf_Dis-cfg-rule.time-templ-rl-root = p-time-templ-rl-root
            )
   on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
   on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
   on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
   :
    if buf_dis-cfg-rule.link-prop = integer('0':U) then do:
      do jj = 1 to num-entries(buf_dis-cfg-rule.nonunique):
        assign
        v-curr-field = entry(jj, buf_dis-cfg-rule.nonunique)
        .
        assign
        v-nonunique = (if v-nonunique = '':u then '':U else chr(4)) +
                    string(buffer check_dis-rule:buffer-field(v-curr-field):buffer-value).
      end.
      create buf_dis-thbj-rule.
      assign
      buf_dis-thbj-rule.host-code = p-host-code
      buf_dis-thbj-rule.obj-type = p-obj-type
      buf_dis-thbj-rule.obj-code = p-obj-code
      buf_dis-thbj-rule.pos-type = p-pos-type
      buf_dis-thbj-rule.discnt-role = buf_Dis-cfg-rule.discnt-role
      buf_dis-thbj-rule.templ-rl-root = p-templ-rl-root
      buf_dis-thbj-rule.nonunique = v-nonunique
      buf_dis-thbj-rule.rule-num = v-rule-num
      buf_dis-thbj-rule.rl-root = v-rule-num
      buf_Dis-thbj-rule.time-templ-rl-root = p-time-templ-rl-root
      .
      define buffer buf2_dis-cfg-rule for ub.dis-cfg-rule.
      define buffer buf2_dis-rule for ub.dis-rule.
      v-nonunique2 = '':U.
      for each buf2_dis-cfg-rule no-lock where
              buf2_dis-cfg-rule.table-name = 'dis-thbj-rule':U
          and buf2_dis-cfg-rule.pos-type = p-pos-type
          and buf2_dis-cfg-rule.link-prop = integer('3':U)
          and buf2_dis-cfg-rule.discnt-role = buf_dis-cfg-rule.discnt-role,
      first buf2_dis-rule no-lock where
                  buf2_dis-rule.rule-num = p-key#_one
             and buf2_dis-rule.templ-rl-root = buf2_dis-cfg-rule.templ-rl-root
             and (buf2_dis-rule.time-templ-rl-root = buf2_dis-cfg-rule.time-templ-rl-root
                  or
                  buf2_dis-rule.time-templ-rl-root = 0 and buf2_dis-rule.is-term = no
                 )
      on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
      on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
      :
        if not (buf2_dis-rule.obj-type = p-obj-type
                and
                buf2_dis-rule.obj-code = p-obj-code) then do:
          run err-mess in this-procedure ( substitute("Правило скидки &1, которое является значением правила изменяемого/сохраняемого правила скидки &2&7" +
                                                      "должно быть привязано к &3&4, а не к &5&6"
                                                      , buf2_dis-rule.rule-num
                                                      , v-rule-num
                                                      , (if p-obj-type = "" then "Глобально" else p-obj-type)
                                                      , p-obj-code
                                                      , (if buf2_dis-rule.obj-type = ""  then "Глобально" else buf2_dis-rule.obj-type)
                                                      , buf2_dis-rule.obj-code
                                                      ), output v-ret-mess).
          undo, return error (if p-silent then v-ret-mess else "":U).
        end.
        do jj = 1 to num-entries(buf2_dis-cfg-rule.nonunique):
          assign
          v-curr-field = entry(jj, buf2_dis-cfg-rule.nonunique)
          .
          assign
          v-nonunique2 = (if v-nonunique2 = '':u then '':U else chr(4)) +
                      string(buffer buf2_dis-rule:buffer-field(v-curr-field):buffer-value).
        end.
        create buf_dis-thbj-rule.
        assign
        buf_dis-thbj-rule.host-code = p-host-code
        buf_dis-thbj-rule.obj-type = p-obj-type
        buf_dis-thbj-rule.obj-code = p-obj-code
        buf_dis-thbj-rule.pos-type = p-pos-type
        buf_dis-thbj-rule.discnt-role = buf2_Dis-cfg-rule.discnt-role
        buf_dis-thbj-rule.templ-rl-root = buf2_dis-cfg-rule.templ-rl-root
        buf_dis-thbj-rule.nonunique = v-nonunique2
        buf_dis-thbj-rule.rule-num = buf2_dis-rule.rule-num
        buf_dis-thbj-rule.rl-root = buf2_dis-rule.rl-root
        buf_Dis-thbj-rule.time-templ-rl-root = buf2_dis-rule.time-templ-rl-root
        .
      end.
      leave.
     end.
   end.
 end.
 if v-sts-mode then return.
 if p-mode <> 'ДОБАВЛЕНИЕ':U then do:
  for each term_dis-rule where
          term_dis-rule.upper-rule-num = v-rule-num
   on error undo _main, return error error-status:get-message(1) :
    find first tt0-term_dis-rule no-lock where
                tt0-term_dis-rule.upper-rule-num = v-rule-num
            AND tt0-term_dis-rule.rule-num = term_dis-rule.rule-num no-error .
    if not available tt0-term_dis-rule then do:
      for each buf_dis-cfg-rule no-lock where
            buf_Dis-cfg-rule.templ-rl-root = p-templ-rl-root
        and buf_Dis-cfg-rule.pos-type = p-pos-type
        and buf_Dis-cfg-rule.time-templ-rl-root = term_dis-rule.time-templ-rl-root
        on error undo _main, return error error-status:get-message(1) :
        if buf_dis-cfg-rule.link-prop <> integer('0':U)
        and buf_dis-cfg-rule.link-prop <> integer('3':U)
        then do:
          run delete-from-projection in this-procedure ( input term_dis-rule.rule-num
                                                        ,buffer buf_dis-cfg-rule
                                                        ).
        end.
      end.
      v-run-cn = yes.
      delete term_dis-rule no-error .
      if error-status:error then do:
        run err-mess in this-procedure ( substitute("Ошибка при попытке удаления правила скидки: &1 (детализация к правилу &2): &3 ", tt0-term_dis-rule.rule-num, v-rule-num, return-value ), output v-ret-mess).
        undo _main, return error (if p-silent then v-ret-mess else '':U).
      end.
    end.
  end.
 end.
 for each tt0-term_dis-rule
 on error undo _main, return error error-status:get-message(1)
 :
    find first term_dis-rule where
                term_dis-rule.upper-rule-num = v-rule-num
            AND term_dis-rule.rule-num       = tt0-term_dis-rule.rule-num
            no-error .
    if not available term_dis-rule then do:
      v-run-cn = yes.
      run gen-b-code in this-procedure ( input 'drgb':U, output v-new-rule-num) no-error .
      if error-status:error then do:
      end.
      create term_dis-rule.
      assign
      term_dis-rule.upper-rule-num = v-rule-num
      term_dis-rule.rule-num       = v-new-rule-num
      term_dis-rule.rl-root        = v-rule-num
      .
    end.
    buffer-copy tt0-term_dis-rule except rule-num upper-rule-num root is-term lvl-num uniq-field rl-root
    doc-qnty tot-sum dis-kat time-rule-num
    charkey_one
    charkey_two
    charkey_three
    deckey_one
    deckey_two
    deckey_three
    key#_one
    key#_two
    key#_three
    to term_dis-rule
    assign
    term_dis-rule.doc-qnty = (if lookup("doc-qnty", v-level-2) = 0
                              then (if lookup("doc-qnty", v-level-1) = 0
                                    then -1
                                    else p-doc-qnty)
                              else tt0-term_dis-rule.doc-qnty)
    term_dis-rule.tot-sum = (if lookup("tot-sum", v-level-2) = 0
                             then (if lookup("tot-sum", v-level-1) = 0
                                   then -1
                                   else p-tot-sum)
                             else tt0-term_dis-rule.tot-sum)
    term_dis-rule.dis-kat = (if lookup("dis-kat", v-level-2) = 0
                             then (if lookup("dis-kat", v-level-1) = 0
                                   then p-dis-kat
                                   else -1)
                             else tt0-term_dis-rule.dis-kat)
    term_dis-rule.charkey_one = (if lookup("charkey_one", v-level-2) = 0
                                 then (if lookup("charkey_one", v-level-1) = 0
                                       then ?
                                       else p-charkey_one)
                                 else tt0-term_dis-rule.charkey_one)
    term_dis-rule.charkey_two = (if lookup("charkey_two", v-level-2) = 0
                                 then (if lookup("charkey_two", v-level-1) = 0
                                      then ?
                                      else p-charkey_two)
                                 else tt0-term_dis-rule.charkey_two)
    term_dis-rule.charkey_three = (if lookup("charkey_three", v-level-2) = 0
                                   then (if lookup("charkey_three", v-level-1) = 0
                                         then ?
                                         else p-charkey_three)
                                   else tt0-term_dis-rule.charkey_three)
    term_dis-rule.deckey_one = (if lookup("deckey_one", v-level-2) = 0
                                 then (if lookup("deckey_one", v-level-1) = 0
                                       then ?
                                       else p-deckey_one)
                                 else tt0-term_dis-rule.deckey_one)
    term_dis-rule.deckey_two = (if lookup("deckey_two", v-level-2) = 0
                                 then (if lookup("deckey_two", v-level-1) = 0
                                       then ?
                                       else p-deckey_two)
                                 else tt0-term_dis-rule.deckey_two)
    term_dis-rule.deckey_three = (if lookup("deckey_three", v-level-2) = 0
                                   then (if lookup("deckey_three", v-level-1) = 0
                                         then ?
                                         else p-deckey_three)
                                   else tt0-term_dis-rule.deckey_three)
    term_dis-rule.key#_one = (if lookup("key#_one", v-level-2) = 0
                              then (if lookup("key#_one", v-level-1) = 0
                                    then ?
                                    else p-key#_one)
                              else tt0-term_dis-rule.key#_one)
    term_dis-rule.key#_two = (if lookup("key#_two", v-level-2) = 0
                              then (if lookup("key#_two", v-level-1) = 0
                                    then ?
                                    else p-key#_two)
                              else tt0-term_dis-rule.key#_two)
    term_dis-rule.key#_three = (if lookup("key#_three", v-level-2) = 0
                                then (if lookup("key#_three", v-level-1) = 0
                                      then ?
                                      else p-key#_three)
                                else tt0-term_dis-rule.key#_three)
    term_dis-rule.time-rule-num = (if lookup("time-rule-num", v-level-2) = 0
                                   then (if lookup("time-rule-num", v-level-1) = 0
                                         then -1
                                         else p-time-rule-num)
                                   else tt0-term_dis-rule.time-rule-num)
    term_dis-rule.time-templ-rl-root = (if lookup("time-rule-num", v-level-2) = 0
                                        then (if lookup("time-rule-num", v-level-1) = 0
                                              then 0
                                              else p-time-templ-rl-root)
                                        else tt0-term_dis-rule.time-templ-rl-root)
    v-term-time-templ-rl-root       = term_dis-rule.time-templ-rl-root
    term_dis-rule.root              = no
    term_dis-rule.lvl-num           = 2
    term_dis-rule.is-term           = yes
    term_dis-rule.uniq-field        = v-tree
    term_dis-rule.other-inf         = v-other
    .
    release term_dis-rule no-error .
    if error-status:error then do:
      run err-mess in this-procedure ( substitute("Ошибка при попытке сохранения правила скидки: &1 (детализация к правилу &2): &3 ", v-new-rule-num, v-rule-num, return-value ), output v-ret-mess).
      undo _main, return error (if p-silent then v-ret-mess else '':U).
    end.
    v-run-cn = yes.
    for each buf_dis-cfg-rule no-lock where
           buf_Dis-cfg-rule.templ-rl-root = p-templ-rl-root
      and buf_Dis-cfg-rule.pos-type = p-pos-type
      and buf_Dis-cfg-rule.time-templ-rl-root = v-term-time-templ-rl-root
      on error undo _main, return error error-status:get-message(1) :
       if buf_dis-cfg-rule.link-prop <> integer('0':U)
       and buf_dis-cfg-rule.link-prop <> integer('3':U)
       and p-mode = 'ДОБАВЛЕНИЕ':U
       then do:
         run create-from-projection in this-procedure ( input v-new-rule-num
                                                       ,buffer buf_dis-cfg-rule
                                                       ).
       end.
    end.
  end.
  if v-run-cn then do:
    find first ub.dis-rule no-lock where
              ub.dis-rule.rule-num = v-rule-num .
    run str/callnews.p
        (input 'dis-rule':U
        ,input (buffer ub.dis-rule:handle)
        ).
  end.
end.
PROCEDURE err-mess:
  DEFINE INPUT PARAMETER p-mess as character No-UNDO.
  define output parameter p-ret-mess as character no-undo .
  CASE p-silent:
    when yes then do:
      p-ret-mess =
      substitute("ПРАВИЛО СКИДКИ &1: &2&3"
                , (if p-mode = 'ИЗМЕНЕНИЕ':U then string(p-rule-num) else p-des)
                , chr(10)
                , p-mess).
    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.
procedure check-projection :
define parameter buffer buf_tt0-term_dis-rule for tt0-term_dis-rule.
define input parameter p-table-name as character no-undo .
define input parameter p-projection as character no-undo .
define output parameter p-reason as character no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-ii as integer no-undo .
do
on error undo, return error
:
   v-uniq-key-rec = p-table-name.
   do v-ii = 1 to num-entries(p-projection):
     assign
     v-uniq-key-rec = v-uniq-key-rec + chr(3) +
                      string(buffer buf_tt0-term_dis-rule:buffer-field(entry(2, entry(v-ii, p-projection), "=":U)):buffer-value)
     .
   end.
   run gen-row-keyr in this-procedure (
                                         input  v-uniq-key-rec
                                        ,input  ?
                                        ,input  "Ub"
                                        ,input  ?
                                        ,input  no-lock
                                        ,output v-tbl-row
                                        ,output v-tbl-name   ) no-error.
   if not error-status:error then do:
     return '':U.
   end.
   assign
   p-reason = substitute("&1", entry (lookup (p-table-name, 'dis-gds-rule,dis-cp-rule,dis-dc-rule,dis-dct-rule,dis-thbj-rule,dis-grp-rule,dis-some-rule':u) + 1, ',' + 'Скидка Товара на объ.,Скидки на платеж,Скидки для ДК,Скидки на типы ДК,Общие скидки,Скидки по группе,Привязка прв скид':u))
   .
end.
end procedure.
procedure disrules-override-labels-2 :
define input parameter p-templ-rl-root like ub.dis-rule.templ-rl-root no-undo .
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
      when "dis-kat" then do:
        p-label = "Категория".
      end.
      when "tot-sum" then do:
        p-label = "Сумма".
      end.
      when "doc-qnty" then do:
        p-label = "Кол-во".
      end.
      when "time-rule-num" then do:
        p-label = "Расписание".
      end.
      when "value-type" then do:
        p-label = "Тип".
      end.
    end case.
  end.
  end.
end procedure.
procedure create-from-projection :
define input  parameter p-link-rule-num as integer   no-undo .
define parameter buffer buf_Dis-cfg-rule for ub.dis-cfg-rule.
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_dis-cp-rule for ub.dis-cp-rule.
define buffer buf_dis-grp-rule for ub.dis-grp-rule.
define variable buf_h as handle no-undo .
define variable v-ii as integer   no-undo .
define variable v-dop as character no-undo .
define variable glog as logical   no-undo .
do
on error undo, return error return-value
:
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = p-link-rule-num.
  create buffer buf_h for table buf_dis-cfg-rule.table-name.
  assign
  glog = buf_h:buffer-copy(buffer buf_dis-rule:handle) no-error.
  if not glog then do:
    delete widget buf_h.
    undo, return error substitute("Ошибка копирования при связи правила с &1&2&3"
                                  ,buf_dis-cfg-rule.table-name
                                  , chr(10)
                                  , error-status:get-message(1)).
  end.
  assign
  buf_h:buffer-field("pos-type"):buffer-value = buffer buf_dis-cfg-rule:buffer-field("pos-type"):buffer-value
  .
  if buf_dis-cfg-rule.self-nonunique <>'':U then do:
    assign
    buf_h:buffer-field("classif-type"):buffer-value = buffer buf_dis-cfg-rule:buffer-field("self-nonunique"):buffer-value
    .
  end.
  if buf_dis-cfg-rule.nonunique <> '':U then do:
    assign
    buf_h:buffer-field("nonunique"):buffer-value = string(buffer buf_Dis-rule:handle:buffer-field(buf_dis-cfg-rule.nonunique):buffer-value)
    .
  end.
  assign
  buf_h:buffer-field("discnt-role"):buffer-value = buffer buf_Dis-cfg-rule:handle:buffer-field("discnt-role"):buffer-value
  .
  do v-ii = 1 to num-entries(buf_dis-cfg-rule.projection):
     v-dop = entry(v-ii, buf_dis-cfg-rule.projection).
     assign
     buf_h:buffer-field(entry(1, v-dop, "=":U)):buffer-value = buffer buf_dis-rule:buffer-field(entry(2, v-dop, "=":U)):buffer-value
     no-error
     .
     if error-status :error then do:
        delete widget buf_h.
        undo, return error substitute("Ошибка копирования при связи правила с &1&2&3"
                                      ,buf_dis-cfg-rule.table-name
                                      , chr(10)
                                      , error-status:get-message(1)).
     end.
  end.
  assign
  glog = buf_h:buffer-release no-error .
  if not glog then do:
    delete widget buf_h.
    undo, return error substitute("Ошибка сохранения связи правила с &1&2&3"
                                  ,buf_dis-cfg-rule.table-name
                                  ,chr(10)
                                  ,error-status:get-message(1)).
  end.
  delete widget buf_h.
end.
end procedure.
procedure delete-from-projection :
define input  parameter p-link-rule-num as integer   no-undo .
define parameter buffer buf_Dis-cfg-rule for ub.dis-cfg-rule.
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_dis-cp-rule for ub.dis-cp-rule.
define buffer buf_dis-grp-rule for ub.dis-grp-rule.
define variable buf_h as handle no-undo .
define variable buf_h2 as handle no-undo .
define variable t_h as handle no-undo .
define variable v-ii as integer   no-undo .
define variable v-dop as character no-undo .
define variable glog as logical   no-undo .
define variable v-keys as character no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
do
on error undo, return error return-value
:
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = p-link-rule-num.
  create temp-table t_h.
assign
t_h:undo = no
glog = false
.
  assign
  glog = t_h:create-like(buf_dis-cfg-rule.table-name ) no-error
  .
  if glog <> true then do:
    delete object t_h.
    undo, return error substitute("Ошибка создания врем.таблицы при удалении связи правила с &1&2&3"
                                  ,buf_dis-cfg-rule.table-name
                                  , chr(10)
                                  , error-status:get-message(1)).
  end.
  glog = no.
  assign
  glog = t_h:temp-table-prepare( substitute("temp_&1", buf_dis-cfg-rule.table-name )) no-error
  .
  if glog <> true then do:
    delete object t_h.
    undo, return error substitute("Ошибка создания врем.таблицы при удалении связи правила с &1&2&3"
                                  ,buf_dis-cfg-rule.table-name
                                  , chr(10)
                                  , error-status:get-message(1)).
  end.
  assign
  buf_h = t_h:default-buffer-handle
  .
  assign
  glog = buf_h:buffer-copy(buffer buf_dis-rule:handle) no-error.
  if not glog then do:
    delete widget t_h.
    undo, return error substitute("Ошибка копирования при удалении связи правила с &1&2&3"
                                  ,buf_dis-cfg-rule.table-name
                                  , chr(10)
                                  , error-status:get-message(1)).
  end.
  assign
  buf_h:buffer-field("pos-type"):buffer-value = buffer buf_dis-cfg-rule:buffer-field("pos-type"):buffer-value
  .
  if buf_dis-cfg-rule.self-nonunique <>'':U then do:
    assign
    buf_h:buffer-field("classif-type"):buffer-value = buffer buf_dis-cfg-rule:buffer-field("self-nonunique"):buffer-value
    .
  end.
  if buf_dis-cfg-rule.nonunique <> '':U then do:
    assign
    buf_h:buffer-field("nonunique"):buffer-value = string(buffer buf_Dis-rule:handle:buffer-field(buf_dis-cfg-rule.nonunique):buffer-value)
    .
  end.
  assign
  buf_h:buffer-field("discnt-role"):buffer-value = buffer buf_Dis-cfg-rule:handle:buffer-field("discnt-role"):buffer-value
  .
  do v-ii = 1 to num-entries(buf_dis-cfg-rule.projection):
     v-dop = entry(v-ii, buf_dis-cfg-rule.projection).
     assign
     buf_h:buffer-field(entry(1, v-dop, "=":U)):buffer-value = buffer buf_dis-rule:buffer-field(entry(2, v-dop, "=":U)):buffer-value
     no-error
     .
     if error-status :error then do:
        delete widget t_h.
        undo, return error substitute("Ошибка копирования при связи правила с &1&2&3"
                                      ,buf_dis-cfg-rule.table-name
                                      , chr(10)
                                      , error-status:get-message(1)).
     end.
  end.
  v-keys = buf_h:keys.
  v-uniq-key-rec = buf_dis-cfg-rule.table-name .
  do v-ii = 1 to num-entries(v-keys):
    v-uniq-key-rec = v-uniq-key-rec + chr(3) + string(buf_h:buffer-field(entry(v-ii, v-keys)):buffer-value).
  end.
  v-uniq-key-rec = trim(v-uniq-key-rec, chr(3)).
  run gen-row-keyr in this-procedure (
   input  v-uniq-key-rec
  ,input ?
  ,input "ub"
  ,input ?
  ,input exclusive-lock
  ,output v-tbl-row
  ,output v-tbl-name).
  create buffer buf_h2 for table buf_dis-cfg-rule.table-name.
  glog = buf_h2:find-by-rowid( v-tbl-row).
  assign
  glog = buf_h2:buffer-delete no-error .
  if not glog then do:
    delete widget t_h.
    undo, return error substitute("Ошибка удаления связи правила с &1&2&3"
                                  ,buf_dis-cfg-rule.table-name
                                  ,chr(10)
                                  ,error-status:get-message(1)).
  end.
  delete widget t_h.
  delete widget buf_h2.
end.
end procedure.
