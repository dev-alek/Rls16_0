block-level on error undo, throw.
define input parameter parparentproc AS WIDGET-HANDLE NO-UNDO.
define input parameter par-mode as character no-undo .
define input parameter par-copymode as logical no-undo .
define input parameter par-alt-bc-mode as integer no-undo .
define input parameter par-manual as logical no-undo .
define input parameter par-silence as logical no-undo .
define input parameter par-import as logical no-undo .
define input parameter par-file as logical no-undo .
define input parameter par-single-record as logical no-undo .
define input parameter par-host-code like ub.sysconf.host-code no-undo .
define input parameter par-obj-type like ub.clients.obj-type no-undo .
define input parameter par-obj-code like ub.clients.obj-code no-undo .
define input parameter is-goods as logical no-undo .
define input parameter par-copy-rec as recid no-undo.
define input parameter par-gds-code  like ub.goods.gds-code no-undo .
define input parameter par-artic like ub.goods.artic no-undo .
define input parameter par-prod-type like ub.goods.prod-type no-undo .
define input parameter par-prod-code like ub.goods.prod-code no-undo .
define input parameter par-node-code like ub.gds-prt.node-code no-undo .
define input parameter par-grp-code like ub.gds-grp.node-code no-undo .
define input parameter par-gds-name like ub.goods.gds-name no-undo .
define input parameter par-saved-name like ub.goods.gds-name no-undo .
define input parameter par-engl-name like ub.goods.engl-name no-undo .
define input parameter par-label-name like ub.goods.label-name no-undo .
define input parameter par-chk-name like ub.goods.chk-name no-undo .
define input parameter par-alpha1 like ub.goods.alpha1 no-undo .
define input parameter par-unit-base like ub.goods.unit-base no-undo .
define input parameter par-unit-cli like ub.goods.unit-cli no-undo .
define input parameter par-max-rate like ub.goods.max-rate no-undo .
define input parameter par-min-rate like ub.goods.min-rate no-undo .
define input parameter par-cli-base-rate like ub.goods.cli-base-rate no-undo .
define input parameter par-qnty-cart like ub.goods.qnty-cart no-undo .
define input parameter par-ms-base like ub.goods.ms-base no-undo .
define input parameter par-wt-base like ub.goods.wt-base no-undo .
define input parameter par-ms-cart like ub.goods.ms-cart no-undo .
define input parameter par-wt-cart like ub.goods.wt-cart no-undo .
define input parameter par-calc-method like ub.goods.calc-method no-undo .
define input parameter par-increase-pc like ub.goods.increase-pc no-undo .
define input parameter par-NegRest as logical no-undo .
define input parameter par-obj-price-base like ub.gds-obj.price-base no-undo .
define input parameter par-obj-price-rubl like ub.gds-obj.price-rubl no-undo .
define input parameter par-okdp like ub.goods.okdp no-undo .
define input parameter par-destin like ub.goods.destin no-undo .
define input parameter par-attrib like ub.goods.attrib  no-undo .
define input parameter par-user-rule like ub.goods.user-rule no-undo .
define input parameter par-sert like ub.goods.sert no-undo .
define input parameter par-struct like ub.goods.struct no-undo .
define input parameter par-deadline like ub.goods.deadline no-undo .
define input parameter par-cond-keep-code like ub.goods.cond-keep-code no-undo .
define input parameter par-sort like ub.goods.sort no-undo .
define input parameter par-proof like ub.goods.proof no-undo .
define input parameter par-normal-wastage like ub.goods.normal-wastage no-undo .
define input parameter par-normal-waste like ub.goods.normal-waste no-undo .
define input parameter par-tnved like ub.goods.tnved no-undo .
define input parameter par-nationality like ub.goods.nationality no-undo .
define input parameter par-unit-cst like ub.goods.unit-cst no-undo .
define input parameter par-cst-base-rate like ub.goods.cst-base-rate no-undo .
define input parameter par-fbr-grp-code like ub.goods.fbr-grp-code no-undo .
define input parameter par-PS like ub.goods.ps no-undo .
define input parameter par-unq-artc as logical no-undo .
define input parameter par-is-jwlr   as logical no-undo .
define input parameter par-is-bttl  as logical no-undo .
define input parameter par-is-ptrl  as logical no-undo .
define input parameter par-custvalue as character no-undo .
define input parameter par-dif-nam1 as logical no-undo .
define input parameter par-dif-nam2 as logical no-undo .
define input parameter par-ArtDis as logical no-undo .
define input parameter par-BarDis as integer no-undo .
define input-output parameter par-rec as recid no-undo .
define output parameter par-nbc like ub.bar-code.b-code no-undo .
define variable vss-revision    as character no-undo init "$Revision: f5e72f13272f, 2363, rls $":U .
define variable vss-author      as character no-undo init "$Author: druban $":U .
define variable vss-date        as character no-undo init "$Date: 2020/06/10 18:13:42 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: goods01.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/goods01.p $":U .
define variable vss-description as character no-undo init "Проверка и создание goods".
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
DEFINE  SHARED TEMP-TABLE TT-tnved NO-UNDO
FIELD tnved  AS CHAR FORMAT "X(10)"  LABEL 'Код ТНВЭД':U
FIELD f-name AS CHAR FORMAT "X(255)" LABEL 'Полное наименование':U
INDEX tnved IS UNIQUE PRIMARY  tnved.
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$".
procedure chk-b-code:
define input parameter p-silence as logical no-undo .
define input param b-c like ub.bar-code.b-code no-undo.
define output param p-log as log no-undo.
  define variable l-code as integer no-undo.
  define variable v-mes as character no-undo .
  define variable v-param-type3 as character no-undo .
  define variable v-value-character3 as INTEGER no-undo .
  define variable v-value-date3 as date no-undo .
  define variable v-value-decimal3 as decimal no-undo .
  define variable v-value-integer3 AS integer no-undo .
  define variable v-value-logical3 AS LOGICAL no-undo .
  define variable v-tth3 as handle no-undo .
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
        ,output v-value-character3
        ,output v-value-date3
        ,output v-value-decimal3
        ,output v-value-integer3
        ,output v-value-logical3
        ,output v-param-type3
        ,INPUT-OUTPUT table-handle v-tth3
        ) no-error .
    if error-status :error then do:
      delete object v-tth3.
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
    delete object v-tth3.
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
function cross-list returns logical (
  input parfirst-stream  as character,
  input parsecond-stream as character,
  input pardelim         as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  define variable vari            as integer no-undo .
  define variable varresult-cross as logical no-undo .
  assign
    varresult-cross = no
  .
  def var v-num-parfirst-stream as integer no-undo .
  assign
    v-num-parfirst-stream = num-entries(parfirst-stream, pardelim)
  .
  do vari = 1 to v-num-parfirst-stream
  :
    if lookup(entry(vari, parfirst-stream, pardelim)
             ,parsecond-stream
             ,pardelim
             ) > 0 then do:
      assign
        varresult-cross = yes
      .
      leave.
    end.
  end.
  return varresult-cross .
end function.
  define SHARED temp-table  tt-tax no-undo
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
define variable vss-include-info4 as character format "X(65)" no-undo
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-nws as handle no-undo .
procedure clientsh_write-clients-proc  :
define parameter buffer buf_clients for ub.clients .
define input parameter p-source-type like ub.c-cli-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-cli-hist.source-ref no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-cli-hist for ub.c-cli-hist.
define buffer buf_c-clients for ub.c-clients.
  do
  on error undo, return error
  :
    if not available buf_clients then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не определен контрагент" skip
        view-as alert-box error .
      undo, return error .
    end.
    if g#news then do:
      define variable v-send as integer no-undo .
      define variable v-subject as character no-undo .
      case buf_clients.obj-type:
        when 'орг':U then v-subject =  'firm':U.
        when 'чел':U then v-subject =  'person':U.
        when 'маг':U then v-subject =  'shop':U.
        when 'скл':U then v-subject =  'store':U.
      end case.
      v-send = integer('0':U).
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option in g#lib-nws
  (input  g#db-num
  ,input  v-subject
  ,input  0
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  0
  ,input  0
  ,input  0
  ,input  'nws-to-hist'
  ,output v-send
  ) no-error .
      if v-send < 0 then return.
    end.
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-clients.
    buffer-copy buf_clients to buf_c-clients
    assign
    buf_c-clients.obj-code           = buf_clients.obj-code
    buf_c-clients.obj-type           = buf_clients.obj-type
    buf_c-clients.chip-num           = next-value (s-cli-chip, ub)
    buf_c-clients.corr-time          = v-time
    buf_c-clients.corr-user-db-num   = g#db-num
    buf_c-clients.corr-user-name     = (if g#news
                                        then (chr(4) +  'СПН':U)
                                        else (if g#esys
                                              then (chr(4) +  'ВС':U)
                                              else g#userid)
                                        )
    buf_c-clients.corr-date          = v-date
    .
    create buf_c-cli-hist.
    buffer-copy buf_c-clients to buf_c-cli-hist
    assign
    buf_c-cli-hist.action =  integer('2':U)
    buf_c-cli-hist.subject = 'clients':U
    buf_c-cli-hist.host-code = (if buf_clients.obj-type = 'орг':U
                                and
                                can-find(first ub.sysconf no-lock where
                                                  ub.sysconf.host-code = buf_clients.obj-code)
                                then buf_clients.obj-code
                                else 0)
    buf_c-cli-hist.is-news = g#news
    buf_c-cli-hist.source-type = p-source-type
    buf_c-cli-hist.source-ref = p-source-ref
    .
  end.
end procedure.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure bar-codh_write-bar-code-proc  :
define parameter buffer buf_bar-code for ub.bar-code .
define input parameter p-action as integer no-undo .
define input parameter p-source-type like ub.c-gds-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-gds-hist.source-ref no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-gds-hist for ub.c-gds-hist.
define buffer buf_c-bar-code for ub.c-bar-code.
  do
  on error undo, return error
  :
    if not available buf_bar-code then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не определен БАР-КОД" skip
        view-as alert-box error .
      undo, return error .
    end.
    if g#news then do:
      define variable v-send as integer no-undo .
      v-send = integer('0':U).
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option in g#lib-nws
  (input  g#db-num
  ,input  'bar-code':U
  ,input  0
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  0
  ,input  0
  ,input  0
  ,input  'nws-to-hist'
  ,output v-send
  ) no-error .
      if v-send < 0 then return.
    end.
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-bar-code.
    if p-action = integer('1':U) then do:
      assign
      buf_c-bar-code.b-code             = buf_bar-code.b-code
      buf_c-bar-code.gds-code           = buf_bar-code.gds-code
      buf_c-bar-code.chip-num           = next-value (s-gds-chip, ub)
      buf_c-bar-code.corr-time          = v-time
      buf_c-bar-code.corr-user-db-num   = g#db-num
      buf_c-bar-code.corr-user-name     = (if g#news
                                          then (chr(4) +  'СПН':U)
                                          else (if g#esys
                                                then (chr(4) +  'ВС':U)
                                                else g#userid)
                                          )
      buf_c-bar-code.corr-date          = v-date
     .
    end.
    else do:
      buffer-copy buf_bar-code to buf_c-bar-code
      assign
      buf_c-bar-code.gds-code           = buf_bar-code.gds-code
      buf_c-bar-code.chip-num           = next-value (s-gds-chip, ub)
      buf_c-bar-code.corr-time          = v-time
      buf_c-bar-code.corr-user-db-num   = g#db-num
      buf_c-bar-code.corr-user-name     = (if g#news
                                          then (chr(4) +  'СПН':U)
                                          else (if g#esys
                                                then (chr(4) +  'ВС':U)
                                                else g#userid)
                                          )
      buf_c-bar-code.corr-date          = v-date
      .
    end.
    create buf_c-gds-hist.
    buffer-copy buf_c-bar-code to buf_c-gds-hist
    assign
    buf_c-gds-hist.gds-code           = buf_c-bar-code.gds-code
    buf_c-gds-hist.action = integer(p-action)
    buf_c-gds-hist.subject = 'bar-code':U
    buf_c-gds-hist.is-news = g#news
    buf_c-gds-hist.source-type = (if g#news then 'db':U
                                  else (if g#esys
                                        then 'esys':U
                                        else "":U
                                        )
                                 )
    buf_c-gds-hist.source-ref = (if g#news
                                 then string(g#news-source-db)
                                  else (if g#esys
                                        then string(g#esys-source-esys)
                                        else "":U
                                        )
                                 )
    .
  end.
end procedure.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
DEFINE VARIABLE prev-value-base     as decimal no-undo .
DEFINE VARIABLE prev-value-rubl     as decimal no-undo .
DEFINE VARIABLE art-dec             as decimal no-undo .
DEFINE VARIABLE prod-bc-added       as logical no-undo init yes.
DEFINE VARIABLE is-twounit          as logical no-undo .
DEFINE VARIABLE loc#log             as logical no-undo .
DEFINE VARIABLE conf-par            as character no-undo .
DEFINE VARIABLE par-type            as character no-undo .
DEFINE VARIABLE choice              as integer no-undo .
DEFINE VARIABLE var-AvtArt like ub.bar-code.b-code no-undo .
DEFINE VARIABLE main-code  like ub.bar-code.gds-code no-undo .
DEFINE VARIABLE vattaxcd as integer no-undo.
DEFINE VARIABLE slttaxcd as integer no-undo.
define variable v-grp-name like ub.goods.grp-name no-undo .
define variable v-artic like ub.goods.artic no-undo .
define variable v-gds-code like ub.goods.gds-code no-undo .
define variable v-gds-rec as recid no-undo .
define buffer buf_goods for ub.goods .
define buffer buf_clients for ub.clients .
define buffer buf_gds-prt for ub.gds-prt .
define buffer buf_gds-grp for ub.gds-grp .
define buffer for-goods for ub.goods .
define buffer base_units for ub.units .
define buffer cli_units for ub.units .
define buffer grp-buf for ub.gds-grp .
define buffer similar_goods for ub.goods .
define buffer cli-buf for ub.clients .
define buffer buf_prod-bc for ub.prod-bc .
define buffer buf_fbr-gds-grp for ub.fbr-gds-grp.
define buffer buf_country for ub.country.
define buffer buf_BatchProcess for ub.BatchProcess .
_main:
do
on error undo, return error return-value
:
  assign
  vattaxcd = integer('1':U)
  slttaxcd = integer('2':U)
  .
  if par-mode = 'АВТОИЗМЕНЕНИЕ':U
  then do on error undo, return error :
     par-mode = 'ИЗМЕНЕНИЕ':U.
     find first buf_goods no-lock where
               recid(buf_goods) = par-rec no-error .
     if not available buf_goods then do:
        find first buf_goods no-lock where
                 buf_goods.gds-code = par-gds-code.
     end.
     if available buf_goods
     then do:
        assign
           par-tnved      = buf_goods.tnved when par-tnved eq ?
           par-gds-name   = buf_goods.gds-name  when par-gds-name eq ?
           par-grp-code   = buf_goods.grp-code when par-grp-code eq ?
           par-prod-type   = buf_goods.prod-type     when par-prod-type eq ?
           par-prod-code   = buf_goods.prod-code     when par-prod-code eq ?
           is-goods = buf_goods.gds-type eq 'т':U when is-goods eq ?
           par-engl-name = buf_goods.engl-name     when par-engl-name eq ?
           par-label-name = buf_goods.label-name   when par-label-name eq ?
           par-chk-name = buf_goods.chk-name   when par-chk-name eq ?
           par-fbr-grp-code = buf_goods.fbr-grp-code  when par-fbr-grp-code eq ?
           par-unit-base = buf_goods.unit-base     when par-unit-base eq ?
           par-unit-cli = buf_goods.unit-cli      when par-unit-cli eq ?
           par-min-rate = buf_goods.min-rate when par-min-rate eq ?
           par-max-rate = buf_goods.max-rate when par-max-rate eq ?
           par-cli-base-rate = buf_goods.cli-base-rate when par-cli-base-rate eq ?
           par-calc-method = buf_goods.calc-method  when par-calc-method eq ?
           par-nationality = buf_goods.nationality   when par-nationality eq ?
           par-unit-cst = buf_goods.unit-cst     when par-unit-cst eq ?
           par-alpha1 = buf_goods.alpha1  when par-alpha1 eq ?
           par-okdp = buf_goods.okdp       when par-okdp eq ?
           par-increase-pc = buf_goods.increase-pc   when par-increase-pc eq ?
           par-qnty-cart =  buf_goods.qnty-cart     when par-qnty-cart  eq ?
           par-ms-base  = buf_goods.ms-base when  par-ms-base eq ?
           par-wt-base =  buf_goods.wt-base when par-wt-base eq ?
           par-ms-cart = buf_goods.ms-cart when par-ms-cart eq ?
           par-wt-cart = buf_goods.wt-cart when par-wt-cart eq ?
           par-PS = buf_goods.PS      when par-PS  eq ?
           par-NegRest = buf_goods.negative-rest when par-NegRest eq ?
           par-destin = buf_goods.destin        when par-destin  eq ?
           par-attrib = buf_goods.attrib        when par-attrib eq ?
           par-user-rule = buf_goods.user-rule    when par-user-rule eq ?
           par-sert = buf_goods.sert          when par-sert eq ?
           par-struct = buf_goods.struct        when par-struct eq ?
           par-deadline = buf_goods.deadline     when par-deadline eq ?
           par-cond-keep-code = buf_goods.cond-keep-code when par-cond-keep-code eq ?
           par-sort  = buf_goods.sort          when par-sort eq ?
           par-proof = buf_goods.proof         when par-proof eq ?
           par-normal-wastage = buf_goods.normal-wastage when par-normal-wastage eq ?
           par-normal-waste = buf_goods.normal-waste when par-normal-waste eq ?
        .
     end.
  end.
  if par-gds-name = "" then do:
    run do-message in this-procedure(
                                      par-silence
                                    ,"Название не может быть пустым !"
                                    ,"error":U
                                    ) no-error .
    if error-status :error then do:
        undo _main, return error return-value.
    end.
  end.
  if
  index(par-gds-name, chr(10)) > 0
  or
  index(par-gds-name, chr(13)) > 0
  or
  index(par-engl-name, chr(10)) > 0
  or
  index(par-engl-name, chr(13)) > 0
  or
  index(par-label-name, chr(10)) > 0
  or
  index(par-label-name, chr(13)) > 0
  or
  index(par-chk-name, chr(10)) > 0
  or
  index(par-chk-name, chr(13)) > 0
  then do:
    run do-message in this-procedure(
                                      par-silence
                                    ,"Поля Названий не могут содержать символы перевода строки и возврата каретки!"
                                    ,"error":U
                                    ) no-error .
    if error-status :error then do:
        undo _main, return error return-value.
    end.
  end.
  find first buf_gds-prt share-lock where
            buf_gds-prt.node-code = par-node-code no-error .
  if not available buf_gds-prt then do:
    run do-message in this-procedure(
                                      par-silence
                                    ,"Шкала выбрана неправильно !"
                                    ,"error":U
                                    ) no-error .
    if error-status:error then do:
        undo _main, return error return-value.
    end.
  end.
  find first buf_gds-grp share-lock where
              buf_gds-grp.node-code = par-grp-code no-error .
  if NOT available buf_gds-grp then do:
    run do-message in this-procedure(
                                      par-silence
                                    ,"Не выбрана группа ( по классификатору товаров ) !"
                                    ,"error":U
                                    ) no-error .
    if error-status:error then do:
        undo _main, return error return-value.
    end.
  end.
  if can-find( first grp-buf where grp-buf.upper-code = buf_gds-grp.node-code ) then do:
    run do-message in this-procedure(
                                      par-silence
                                    ,("Выбранная Вами группа" + chr(10) +
                                      "делится на более детальные группы :"  + chr(10) +
                                      "в такую группу нельзя добавлять товар !"
                                      )
                                    ,"error":U
                                    ) no-error .
    if error-status:error then do:
        undo _main, return error return-value.
    end.
  end.
  if par-fbr-grp-code <> ? then do:
    find first buf_fbr-gds-grp no-lock where
                buf_fbr-gds-grp.node-code = par-fbr-grp-code
         AND    buf_fbr-gds-grp.obj-type = "":U
         and    buf_fbr-gds-grp.obj-code = 0
         no-error .
    if NOT available buf_fbr-gds-grp then do:
      run do-message in this-procedure(
                                        par-silence
                                      ,"Неверно выбрана группа блюд( по рубрикатору блюд ) !"
                                      ,"error":U
                                      ) no-error .
      if error-status:error then do:
          undo _main, return error return-value.
      end.
    end.
    if can-find( first buf_fbr-gds-grp where buf_fbr-gds-grp.upper-code = par-fbr-grp-code ) then do:
      run do-message in this-procedure(
                                        par-silence
                                      ,("Выбранная Вами группа блюд" + chr(10) +
                                        "делится на более детальные группы :"  + chr(10) +
                                        "в такую группу нельзя добавлять товар !"
                                        )
                                      ,"error":U
                                      ) no-error .
      if error-status:error then do:
          undo _main, return error return-value.
      end.
    end.
  end.
  if NOT can-find( ub.units where ub.units.unit-name = par-unit-base ) then do:
    run do-message in this-procedure(
                                      par-silence
                                    ,"Не выбрана учетная единица измерения !"
                                    ,"error":U
                                    ) no-error .
    if error-status:error then do:
      undo _main, return error return-value.
    end.
  end.
  if NOT can-find( ub.units where ub.units.unit-name =  par-unit-cli ) then do:
    run do-message in this-procedure(
                                      par-silence
                                    ,"Не выбрана единица измерения поставщика !"
                                    ,"error":U
                                    ) no-error .
    if error-status:error then do:
      undo _main, return error return-value.
    end.
  end.
  FIND FIRST base_units WHERE
            base_units.unit-name = par-unit-base
  NO-LOCK NO-ERROR .
  if ( available base_units ) then do:
    if  can-do( base_units.type, 'топ':U) then do:
define variable vss-include-info13 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  ibs.th.gbl.gbl-var:g#db-num
    ,input  ibs.th.gbl.gbl-var:g#userid
    ,input  0
    ,input  'actn_reference-petrolium_update':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output loc#log
    )  .
end.
      if not loc#log then undo _main, return error "Отсутствуют права на работу с топливным товаром".
      if not par-is-ptrl then do:
        run do-message in this-procedure(
                                            par-silence
                                          ,"В системе запрещена работа с топливным товаром"
                                          ,"error":U
                                          ) no-error .
        if error-status:error then do:
          undo _main, return error return-value.
        end.
      end.
    end.
    if par-unq-artc AND can-do(base_units.type, 'вес':U) then do:
      run do-message in this-procedure(
                                          par-silence
                                        ,("В Вашей конфигурации диапазон весовых кодов" + chr(10) +
                                          "уже используется несовместимым образом," + chr(10) +
                                          "поэтому ввод весовых товаров ЗАПРЕЩЕН!")
                                        ,"error":U
                                        ) no-error .
      if error-status:error then do:
        undo _main, return error return-value.
      end.
    end.
    if can-do( base_units.type, 'сер':U) AND ( par-unit-cli <> par-unit-base ) then do:
      run do-message in this-procedure(
                                          par-silence
                                        ,("Для товаров с серийными номерами" + chr(10) +
                                          "учетная единица измерения"  + chr(10) +
                                          "и единица измерения  поставщика"  +  chr(10) +
                                          "должны быть ОДИНАКОВЫ !")
                                        ,"error":U
                                        ) no-error .
      if error-status:error then do:
        undo _main, return error return-value.
      end.
    end.
    assign
    is-twounit = (lookup('2ед':U, base_units.type) > 0)
    .
  end.
  FIND FIRST cli_units No-LOCK WHERE
            cli_units.unit-name = par-unit-cli No-ERROR.
  if NOT can-do(base_units.type, 'топ':U) = can-do(cli_units.type, 'топ':U) THEN DO:
    run do-message in this-procedure(
                                        par-silence
                                      ,("Для товара eдиница измерения поставщика и основная единица измерения" + chr(10) +
                                        "могут быть либо обе топливные либо обе нетопливные!")
                                      ,"error":U
                                      ) no-error .
    if error-status:error then do:
      undo _main, return error return-value.
    end.
  END.
  if  LOOKUP('топ':U, base_units.type) > 0  AND (LOOKUP('дро':U, cli_units.type ) = 0 ) then do:
    run do-message in this-procedure(
                                        par-silence
                                      ,("Для товаров типа топливо  единица измерения поставщика может быть только типа " + chr(10) +
                                        'топ':U + chr(44) + 'дро':U + "!")
                                      ,"error":U
                                      ) no-error .
    if error-status:error then do:
      undo _main, return error return-value.
    end.
  end.
  if  LOOKUP('2ед':U, base_units.type) > 0  then do:
    if not par-is-jwlr then do:
      run do-message in this-procedure(
                                          par-silence
                                        ,"В системе запрещена работа с товаром с двумя единицами измерения"
                                        ,"error":U
                                        ) no-error .
      if error-status:error then do:
        undo _main, return error return-value.
      end.
    end.
    IF (LOOKUP('шту':U, cli_units.type ) = 0 ) then do:
      run do-message in this-procedure(
                                          par-silence
                                        ,( "Для товаров, у которых тип основной единицы измерения - " + '2ед':U + chr(10) +
                                          " единица измерения поставщика может быть только типа " + 'шту':U + "!"
                                        )
                                        ,"error":U
                                        ) no-error .
      if error-status:error then do:
        undo _main, return error ("unit-cli":U + chr(4) + return-value).
      end.
    END.
    if par-max-rate <= par-min-rate AND
      (par-max-rate <> 0 AND
      par-min-rate <> 0)
    then do:
      run do-message in this-procedure(
                                        par-silence
                                        ,("Для товаров, у которых тип основной единицы измерения - " + '2ед':U + chr(10) +
                                        "max кол-во дробного в штуке должно быть больше min кол-ва дробного в штуке !")
                                        ,"error":U
                                        ) no-error .
      if error-status:error then do:
        undo _main, return error return-value.
      end.
    end.
    IF (par-max-rate) >= 2 * (par-min-rate) AND
      (par-max-rate <> 0 AND
        par-min-rate <> 0)
    then do:
      run do-message in this-procedure(
                                        par-silence
                                        ,("Для товаров, у которых тип основной единицы измерения - " + '2ед':U + chr(10) +
                                          "max кол-во дробного в штуке не может быть больше чем в 2 раза min кол-ва дробного в штуке!")
                                        ,"error":U
                                        ) no-error .
      if error-status:error then do:
        undo _main, return error return-value.
      end.
    end.
  end.
  if  LOOKUP('сте':U, base_units.type) > 0  then do:
    if not par-is-bttl then do:
      run do-message in this-procedure(
                                        par-silence
                                        ,"В системе запрещена работа с товаром с раздельным учетом стеклотары"
                                        ,"error":U
                                        ) no-error .
      if error-status:error then do:
        undo _main, return error return-value.
      end.
    end.
    IF (LOOKUP('сте':U, cli_units.type ) = 0 ) then do:
      run do-message in this-procedure(
                                        par-silence
                                        ,("Для товаров, у которых тип основной единицы измерения - " +  'сте':U + chr(10) +
                                        " единица измерения поставщика может быть только типа " + 'сте':U + "!")
                                        ,"error":U
                                        ) no-error .
      if error-status:error then do:
        undo _main, return error ("unit-cli":U + chr(4) + return-value).
      end.
    END.
  end.
  IF (LOOKUP('сте':U, base_units.type ) = 0 ) AND (LOOKUP('сте':U, cli_units.type ) > 0 )  then do:
    run do-message in this-procedure(
                                        par-silence
                                        ,("Для товаров, у которых тип основной единицы измерения -  не " + 'сте':U + chr(10) +
                                          " единица измерения поставщика не может быть типа " + 'сте':U + "!")
                                        ,"error":U
                                        ) no-error .
    if error-status:error then do:
      undo _main, return error ("unit-cli":U + chr(4) + return-value) .
    end.
  end.
  if par-cli-base-rate = 0 then do:
    run do-message in this-procedure(
                                        par-silence
                                        ,"Коэффициент пересчета единиц измерения не может быть нулевым !"
                                        ,"error":U
                                        ) no-error .
    if error-status:error then do:
      undo _main, return error return-value.
    end.
  end.
  if
  par-calc-method = ?
  or
  lookup(par-calc-method, 'Учетная':U + chr(44) +                               'Группа':U + chr(44) +                               'Учет-объект':U + chr(44) +                               'Учет-резерв':U + chr(44) +                               'Накладная':U + chr(44) +                               'Накл-безНДС':U + chr(44) +                               'Учет+накл':U + chr(44) +                               'Уч+накл-НДС':U + chr(44) +                               'Учет-безНДС':U + chr(44) +                               'НсП':U + chr(44) +                               'НсП+накл':U + chr(44) +                               'Производит':U + chr(44) +                               'Произв-НДС':U + chr(44) +                               'ПорогПр-НДС':U + chr(44) +                               'ПорогПр+НДС':U + chr(44) +                               'Спецификация':U + chr(44) +                               'Не-считать':U) = 0 then do:
    run do-message in this-procedure(
                                        par-silence
                                        ,("Неверное значение способа расчета цены" +
                                        (if par-calc-method = ?
                                        then chr(63)
                                        else par-calc-method) + chr(10) +
                                          "требуется указать одно из " + chr(10) +
                                          'Учетная':U + chr(44) +                               'Группа':U + chr(44) +                               'Учет-объект':U + chr(44) +                               'Учет-резерв':U + chr(44) +                               'Накладная':U + chr(44) +                               'Накл-безНДС':U + chr(44) +                               'Учет+накл':U + chr(44) +                               'Уч+накл-НДС':U + chr(44) +                               'Учет-безНДС':U + chr(44) +                               'НсП':U + chr(44) +                               'НсП+накл':U + chr(44) +                               'Производит':U + chr(44) +                               'Произв-НДС':U + chr(44) +                               'ПорогПр-НДС':U + chr(44) +                               'ПорогПр+НДС':U + chr(44) +                               'Спецификация':U + chr(44) +                               'Не-считать':U)
                                        ,"error":U
                                        ) no-error .
    if error-status:error then do:
      undo _main, return error return-value.
    end.
  end.
 if (par-file = yes and par-tnved <> "":U)
  or par-custvalue = "yes" then do:
    IF LENGTH(TRIM(par-tnved)) <> 10 THEN DO:
      run do-message in this-procedure(
                                          par-silence
                                          ,"Код ТНВЭД должен быть 10 символов."
                                          ,"error":U
                                          ) no-error .
      if error-status:error then do:
        undo _main, return error return-value.
      end.
    end.
  END.
  IF par-custvalue = "yes" THEN DO:
    if not CAN-FIND(FIRST TT-tnved WHERE
                          TT-tnved.tnved = par-tnved no-lock) then do:
      run do-message in this-procedure(
                                          par-silence
                                          ,"В дополнительной информации по товару обязательно следует указать код ТНВЭД из справочника."
                                          ,"error":U
                                          ) no-error .
      if error-status:error then do:
        undo _main, return error return-value.
      end.
    END.
    IF par-nationality <> "российский" and
      par-nationality <> "иностранный" then do:
      run do-message in this-procedure(
                                          par-silence
                                          ,"Не определен статус товара - российский или иностранный."
                                          ,"error":U
                                          ) no-error .
      if error-status:error then do:
        undo _main, return error return-value.
      end.
    END.
    if NOT can-find(ub.units where
                    ub.units.unit-name = par-unit-cst no-lock) then do:
      run do-message in this-procedure(
                                          par-silence
                                          ,"Не задана таможенная единица"
                                          ,"error":U
                                          ) no-error .
      if error-status:error then do:
        undo _main, return error return-value.
      end.
    end.
    if par-unit-cst =  par-unit-base then do:
      if par-cst-base-rate = 0 then par-cst-base-rate = 1.
      if par-cst-base-rate <> 1 then do:
        loc#log = no.
        run do-message in this-procedure(
                                            par-silence
                                            ,"Таможенная единица равна базовой. Установить коэффициент в 1 ?"
                                            ,"question":U
                                            ) no-error .
        if loc#log then par-cst-base-rate = 1.
        else undo _main, return error.
      end.
    end.
    if par-cst-base-rate = 0 then do:
      run do-message in this-procedure(
                                          par-silence
                                          ,"Не задан коэффициент пересчета таможенной единицы."
                                          ,"error":U
                                          ) no-error .
      if error-status:error then do:
        undo _main, return error return-value.
      end.
    end.
  END.
  find first buf_clients no-lock where
            buf_clients.obj-type = par-prod-type AND
            buf_clients.obj-code = par-prod-code no-error .
  if NOT available buf_clients then do:
    run do-message in this-procedure(
                                        par-silence
                                        ,"Не выбран или неизвестен производитель !"
                                        ,"error":U
                                        ) no-error .
    if error-status:error then do:
      undo _main, return error return-value.
    end.
  end.
  find first buf_country no-lock where
            buf_country.alpha1 = par-alpha1 no-error .
  if not available buf_country then do:
    run do-message in this-procedure(
                                        par-silence
                                        ,"Не выбрана или неизвестна страна !"
                                        ,"error":U
                                        ) no-error .
    if error-status:error then do:
      undo _main, return error return-value.
    end.
  end.
  if par-mode = 'ДОБАВЛЕНИЕ':U then do:
    if par-copymode then do:
      find first for-goods no-LOCK WHERE
                recid(for-goods) = par-copy-rec no-error .
      if not avail for-goods then do:
        run do-message in this-procedure(
                                            par-silence
                                            ,"Не найден товар, с которого производится копирование"
                                            ,"error":U
                                            ) no-error .
        if error-status:error then do:
          undo _main, return error return-value.
        end.
      end.
    end.
    if buf_clients.obj-type = 'маг':U
    or buf_clients.obj-type = 'скл':U
    then do:
      run do-message in this-procedure(
                                          par-silence
                                          ,"Склад/магазин не может быть производителем !"
                                          ,"error":U
                                          ) no-error .
      if error-status:error then do:
        undo _main, return error return-value.
      end.
    end.
    if cross-list( 'сер,вес,топ,2ед,сте':U, base_units.type, chr(44) ) AND
      buf_gds-prt.node-name <> '_Пустая шкала':U then do:
      run do-message in this-procedure(
                                          par-silence
                                          ,("У товаров с серийными номерами, весовых товаров, " + chr(10) +
                                          "топлива, товаров, учитываемых по двум ед. изм."  + chr(10) +
                                          " и товаров с учетом стеклотары" + chr(10) +
                                          "может быть определена"  + chr(10) +
                                          'только <ПУСТАЯ> шкала признаков.')
                                          ,"error":U
                                          ) no-error .
      if error-status:error then do:
        undo _main, return error return-value.
      end.
    end.
    if NOT is-goods AND NOT par-file AND
      ( par-obj-price-base = 0 OR
        par-obj-price-rubl = 0 ) then do:
      run do-message in this-procedure(
                                          par-silence
                                          ,"Учетная цена не может быть нулевой !"
                                          ,"error":U
                                          ) no-error .
      if error-status:error then do:
        undo _main, return error return-value.
      end.
    end.
    IF trim(par-artic) <> par-artic then do:
      run do-message in this-procedure(
                                          par-silence
                                          ,"Артикул товара содержит пробелы слева или справа или другие запрещенные символы"
                                          ,"error":U
                                          ) no-error .
      if error-status:error then do:
        undo _main, return error return-value.
      end.
    end.
    if length(par-artic) > 20 then do:
      run do-message in this-procedure(
                                          par-silence
                                          , substitute("Длина артикула товара &1 = &2 больше допаустимой длины (&3)"
                                                       ,par-artic
                                                       ,length(par-artic)
                                                       ,20)
                                          ,"error":U
                                          ) no-error .
      if error-status:error then do:
        undo _main, return error return-value.
      end.
    end.
    IF par-dif-nam1 AND par-gds-name = par-saved-name then do:
      if par-ArtDis then do:
        if par-copymode and
        (for-goods.prod-type = buf_clients.obj-type AND
        for-goods.prod-code = buf_clients.obj-code) then do:
          run do-message in this-procedure(
                                              par-silence
                                              ,"Копирумый товар имеет то же название и производителя, что и его аналог!"
                                              ,"error":U
                                              ) no-error .
        end.
        else do:
          run do-message in this-procedure(
                                              par-silence
                                              ,"Вы только что ввели товар с таким названием !"
                                              ,"error":U
                                              ) no-error .
        end.
        if error-status:error then do:
          undo _main, return error return-value.
        end.
      end.
      else do:
        run do-message in this-procedure(
                                            par-silence
                                            ,("Вы уверены, что хотите добавить добавить еще один товар с названием" + chr(10) +
                                              par-saved-name)
                                            ,"question":U
                                            ) no-error .
        if not loc#log then undo _main, return error.
      end.
    end.
    if par-ArtDis then do:
      run gen-b-code IN THIS-PROCEDURE (
                                        input 'bcgb':U
                                        ,output par-nbc
                                      ) no-error.
      if error-status:error then undo _main, return error "Ошибка при создании кода из диапазона собственных кодов" .
    end.
    assign
    var-AvtArt = par-nbc
    .
    find first similar_goods no-lock where similar_goods.artic = (IF par-ArtDis then string(par-nbc) else par-artic)
                        and similar_goods.prod-type = buf_clients.obj-type
                        and similar_goods.prod-code = buf_clients.obj-code no-error .
    if available similar_goods then do:
      run do-message in this-procedure(
                                          par-silence
                                          ,substitute("Товар с артикулом &1 и производителем &2&3 уже есть в справочнике !"
                                                     ,similar_goods.artic
                                                     ,similar_goods.prod-type
                                                     ,similar_goods.prod-code)
                                          ,"error":U
                                          ) no-error .
      if error-status:error then do:
        undo _main, return error ("artic|prod-type|prod-code":U + chr(4) + return-value).
      end.
    end.
  find first buf_BatchProcess exclusive-lock
    where buf_BatchProcess.bp_type   = 'rnar':U
      and buf_BatchProcess.bp_status = 'N':U
      and  buf_BatchProcess.key#_one  = par-prod-code
      and buf_BatchProcess.charkey_one = par-artic
      and buf_BatchProcess.charkey_two = par-prod-type
  no-error .
    if available buf_BatchProcess then do:
      run do-message in this-procedure(
                                        par-silence
                                       ,substitute("Товар с артикулом &1 и производителем &2 &3 создать нельзя (ren-art) !"
                                                   ,par-artic
                                                   ,par-prod-type
                                                   ,par-prod-code)
                                       ,"error":U
                                      ) no-error .
      if error-status:error then do:
          undo _main, return error return-value.
      end.
    end.
    if par-import <> yes
    then do:
        FIND first similar_goods WHERE
                similar_goods.artic = par-artic NO-LOCK no-error.
        if available similar_goods then do:
        if par-unq-artc then do:
            run do-message in this-procedure(
                                                par-silence
                                                ,"Товар с таким артикулом уже есть в справочнике !"
                                                ,"error":U
                                                ) no-error .
            if error-status:error then do:
            undo _main, return error ("artic|unq-artc":U + chr(4) + return-value).
            end.
        end.
        FIND FIRST cli-buf WHERE
                    cli-buf.obj-type = similar_goods.prod-type AND
                    cli-buf.obj-code = similar_goods.prod-code NO-LOCK.
        loc#log = no.
        if not par-manual then do:
            run do-message in this-procedure(
                                                par-silence
                                                ,(substitute("Вы добавляете товар с артикулом &1 для производителя &2&3: &4"
                                                            ,par-artic
                                                            ,par-prod-type
                                                            ,par-prod-code
                                                            ,par-gds-name
                                                            )
                                                + chr(10) + chr(10) +
                                                substitute("Товар с таким артикулом уже есть в справочнике для производителя &1&2: &3"
                                                            , cli-buf.obj-type
                                                            , cli-buf.obj-code
                                                            , similar_goods.gds-name
                                                            )
                                                + chr(10) + chr(10) +
                                                "Вы уверены, что Вы добавляете ДРУГОЙ, а не тот же самый товар ?")
                                                ,"question":U
                                                ) no-error .
            if NOT loc#log then do:
            undo _main, return error (if par-silence
                                      then  substitute("Товар с таким артикулом уже есть в справочнике для производителя &1&2: &3"
                                                            , cli-buf.obj-type
                                                            , cli-buf.obj-code
                                                            , similar_goods.gds-name
                                                            )
                                      else "artic":U).
            end.
        end.
        else do:
            run gbl/d-askw.w (input "Внимание  !!",
                        input (substitute("Вы добавляете товар с артикулом &1 для производителя &2&3: &4"
                                        ,par-artic
                                        ,par-prod-type
                                        ,par-prod-code
                                        ,par-gds-name
                                        )
                            + chr(10) + chr(10) +
                            substitute("Товар с таким артикулом уже есть в справочнике для производителя &1&2: &3"
                                        , cli-buf.obj-type
                                        , cli-buf.obj-code
                                        , similar_goods.gds-name
                                        )
                            ),
                        input "|",
                        input "Все равно добавить" +
                               (if par-file  then "|Перейти к СЛЕДУЮЩЕМУ|ВЫЙТИ из режима ИМПОРТА" else "|Отказ"),
                        input (if par-file  then "||" else "|"),
                        input 1,
                        input (if par-file  then 3 else 2),
                        output choice).
            CASE choice:
            when 1 then do:
            end.
            when 2 then do:
                undo _main, return error "artic|next":U.
            end.
            when 3 then do:
                undo _main, return error "artic|quit":U.
            end.
            end CASE.
        end.
        end.
    end.
    if ( NOT par-ArtDis ) AND ( par-artic = "":U ) then do:
      run do-message in this-procedure(
                                          par-silence
                                          ,"Артикул не может быть пустым !"
                                          ,"error":U
                                          ) no-error .
      if error-status:error then do:
        undo _main, return error return-value.
      end.
    end.
    if (not par-ArtDIs AND par-unq-artc) OR (par-BarDis = 1) then do:
      art-dec = decimal (par-artic) no-error.
      if art-dec = 0 or art-dec = ? or
        art-dec <> trunc(art-dec, 0) OR
        ((par-BarDIs = 1 ) AND (length (par-artic) < 6  OR
          length (par-artic) > 7) AND
          (avail base_units AND lookup('топ':U, base_units.type) = 0)
        ) then do:
        run do-message in this-procedure(
                                          par-silence
                                         ,substitute("Неверный и/или нецифровой артикул &1 при создании товара с кодом=артикулу&2" +
                                                      "Артикул не может=0, а артикул не может =?, артикул не может быть < 100000&3" +
                                                      "Артикул не может быть> 9999999"
                                                      , par-artic
                                                      , chr(10)
                                                      , chr(10)
                                                      )
                                          ,"error":U
                                          ) no-error .
        if error-status:error then do:
          undo _main, return error return-value.
        end.
      end.
    end.
    if par-bardis = 2 then do:
    end.
  end.
  if par-mode = 'ДОБАВЛЕНИЕ':U then do:
    do on error undo, return error :
      RUN grplib-get-full-name in this-procedure (input buf_gds-grp.node-code, output v-grp-name).
      if (par-BarDIs > 0 )then do:
        loc#log = no.
        run  chk-b-code in THIS-PROCEDURE (
                                             par-silence
                                            ,(if par-bardis = 1
                                             then integer(par-artic)
                                             else par-gds-code)
                                            ,output loc#log
                                          ) no-error.
        if error-status:error then do:
          run do-message in this-procedure(
                                            par-silence
                                            ,(if par-bardis = 1
                                              then substitute("Некорректный артикул товара &1 при создании товара с кодом=артикулу - невозможно сгенерить код &1&2&3"
                                                             , par-artic
                                                             ,chr(10)
                                                             , return-value
                                                             )
                                              else substitute("Некорректный код товара &1 при создании товара с кодом, определенным пользователем - невозможно сгенерить код &1:&2&3"
                                                            , par-gds-code
                                                            , chr(10)
                                                            , return-value
                                                            )
                                             )
                                            ,"error":U
                                            ) no-error .
          if error-status:error then do:
            undo _main, return error return-value.
          end.
        end.
        IF can-FIND(FIRST ub.bar-code No-LOCK WHERE
                          ub.bar-code.b-code = (if par-bardis = 1 then integer(par-artic) else par-gds-code)) OR
          NOT loc#log
        then do:
          run do-message in this-procedure(
                                            par-silence
                                            ,(if par-bardis = 1
                                              then substitute("Неверный артикул товара &1 при создании товара с кодом=артикулу - уже есть товар с кодом &1 или невозможно сгенерить код &1", par-artic)
                                              else substitute("Неверный код товара &1 при создании товара с кодом, определенным пользователем - уже есть товар с кодом &1 или невозможно сгенерить код &1", par-gds-code)
                                             )
                                            ,"error":U
                                            ) no-error .
          if error-status:error then do:
            undo _main, return error return-value.
          end.
        end.
      end.
      CREATE buf_goods.
      assign
      buf_goods.gds-type = if is-goods then 'т':U else 'у':U
      buf_goods.artic = ( if par-ArtDis
                          then string( var-AvtArt )
                          else par-artic )
      v-artic                 = buf_goods.artic
      buf_goods.okdp          = par-okdp
      buf_goods.prod-type     = buf_clients.obj-type
      buf_goods.prod-code     = buf_clients.obj-code
      buf_goods.grp-code      = buf_gds-grp.node-code
      buf_goods.gds-name      = par-gds-name
      buf_goods.engl-name     = par-engl-name
      buf_goods.prt-root      = buf_gds-prt.upper-code
      buf_goods.unit-base     = par-unit-base
      buf_goods.unit-cli      = par-unit-cli
      buf_goods.cli-base-rate = par-cli-base-rate
      buf_goods.calc-method   = par-calc-method
      buf_goods.increase-pc   = (if par-calc-method = 'Группа':U then 0 else par-increase-pc)
      buf_goods.qnty-cart     = par-qnty-cart
      buf_goods.ms-base       = par-ms-base
      buf_goods.wt-base       = par-wt-base
      buf_goods.ms-cart       = par-ms-cart
      buf_goods.wt-cart       = par-wt-cart
      buf_goods.PS            = par-PS
      buf_goods.PS = REPLACE(buf_goods.PS, chr(10), " ")
      buf_goods.grp-name      = ""
      buf_goods.cost-calc = 'FIFO':U
      buf_goods.negative-rest = par-NegRest
      buf_goods.label-name = if par-label-name = ""
                            then buf_goods.gds-name
                            else par-label-name
      buf_goods.chk-name = if par-chk-name = ""
                          then replace(replace(buf_goods.gds-name, chr(39), ""), '"', "")
                          else par-chk-name
      buf_goods.alpha1 = par-alpha1
      buf_goods.min-rate = if LOOKUP('2ед':U, base_units.type) > 0
                          then par-min-rate
                          else 0
      buf_goods.max-rate = if LOOKUP('2ед':U, base_units.type) > 0
                          then par-max-rate
                          else 0
      buf_goods.grp-name = v-grp-name
      buf_goods.destin        = par-destin
      buf_goods.attrib        = par-attrib
      buf_goods.user-rule     = par-user-rule
      buf_goods.sert          = par-sert
      buf_goods.struct        = par-struct
      buf_goods.deadline      = par-deadline
      buf_goods.cond-keep-code = par-cond-keep-code
      buf_goods.sort          = par-sort
      buf_goods.proof          = par-proof
      buf_goods.normal-wastage = par-normal-wastage
      buf_goods.normal-waste = par-normal-waste
      buf_goods.unit-cst      = if par-custvalue = "yes"
                                then par-unit-cst else "":U
      buf_goods.tnved         = if par-custvalue = "yes" or
                                (par-file = yes and par-tnved <> "":U)
                                then par-tnved
                                else "":U
      buf_goods.cst-base-rate = if par-custvalue = "yes"
                                then par-cst-base-rate
                                else 0
      buf_goods.nationality   = if par-custvalue = "yes"
                                then par-nationality
                                else "":U
      buf_goods.fbr-grp-code  = par-fbr-grp-code
      v-gds-rec = recid (buf_goods)
      par-rec = recid (buf_goods)
      v-gds-code = buf_goods.gds-code
      .
      if not buf_clients.is-prod then do:
        FIND current buf_clients SHARE-LOCK NO-ERROR .
        if available buf_clients
        and  not buf_clients.is-prod then do:
          run clientsh_write-clients-proc in this-procedure  (
                                                       buffer buf_clients
                                                      ,input "":U
                                                      ,input "":U
                                                      ) .
          assign
          buf_clients.is-prod = yes.
        end.
        FIND current buf_clients No-LOCK NO-ERROR .
      end.
      RUN cre-bc in this-procedure (
                                    input buf_gds-prt.node-code
                                    ,input par-nbc
                                    ,input par-ArtDIs
                                    ,input var-AvtArt
                                    ,input par-BarDis
                                    ,output main-code
                                    ) no-error.
      if error-status:error then do:
        run do-message in this-procedure(
                                            par-silence
                                            ,"Ошибка при создании главного кода товара: " + return-value
                                            ,"error":U
                                            ) no-error .
        if error-status:error then do:
          undo _main, return error return-value.
        end.
      end.
      par-gds-code = v-gds-code.
      if not is-goods and not par-file then do:
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscr in g#library
  (input  par-obj-type
  ,input  par-obj-code
  ,input  v-artic
  ,input  buf_clients.obj-type
  ,input  buf_clients.obj-code
  ,input  buf_gds-prt.node-code
  ,buffer ub.gds-obj
  ,buffer ub.prt-obj
  )  .
        if avail gds-obj then do:
          assign
          gds-obj.price-base = par-obj-price-base
          gds-obj.price-rubl = par-obj-price-rubl
          .
          run str/callnews.p
            ( input "gds-obj"
              ,input (buffer gds-obj:handle)
            ).
        end.
      end.
      if par-alt-bc-mode > 0 then do:
        if par-alt-bc-mode = 1 then do:
          run ref/alt-bc.w (
                        input parparentproc
                        ,input par-obj-type
                        ,input par-obj-code
                        ,input main-code
                        ).
        end.
        if par-dif-nam2 or par-alt-bc-mode = 2 then do:
          REPEAT while prod-bc-added:
            run dif-nam2-proc in this-procedure(
                                                 input par-dif-nam2
                                                ,input par-gds-name
                                                ,input base_units.type
                                                ,input main-code
                                                ) no-error .
            if error-status:error then do:
              run gbl/d-askw.w (input "Рекомендация",
                          input ("В соответствии с настройками системы" + chr(10) +
                                  "необходимо ввести доп.бар-код" + chr(10) +
                                  "( уже был сохранен товар с таким же названием)!"),
                          input "|",
                          input "Ввести Доп.БК|Продолжить без Доп.БК",
                          input "|",
                          input 1,
                          input 2,
                          output choice).
              if choice = 1 then do:
                assign
                prod-bc-added = yes
                .
              end.
              else do:
                prod-bc-added = no.
              end.
              if prod-bc-added then do:
                run ref/alt-bc.w (
                              input parparentproc
                              ,input par-obj-type
                              ,input par-obj-code
                              ,input main-code
                            ).
                prod-bc-added = no.
              end.
            end.
            else  do:
              assign
              prod-bc-added = no.
            end.
          END.
        end.
      end.
      if par-unq-artc and NOT can-do( base_units.type, 'вес':U ) then do:
        define variable v-b-str as character no-undo .
        define variable v-pbc-rid as recid no-undo .
        assign
          v-b-str = v-artic
          v-pbc-rid = ?
        .
        find first buf_goods exclusive-lock where
                  recid(buf_goods) = par-rec no-error .
        run trg/prod-bc1.p (
                            input  parparentproc
                            ,input par-silence
                            ,input no
                            ,input no
                            ,input no
                            ,input 'unq-artc'
                            ,input ""
                            ,buffer buf_goods
                            ,input main-code
                            ,input-output v-b-str
                            ,output v-pbc-rid
                            ) no-error.
        if error-status :error
        or v-pbc-rid = ? then do:
          run do-message in this-procedure(
                                           input par-silence
                                          ,input return-value
                                          ,input "error":U
                                          ) no-error .
          if error-status:error then do:
            undo _main, return error return-value.
          end.
        end.
      end.
    end.
  end.
  if par-mode = 'ИЗМЕНЕНИЕ':U then do:
    do on error undo, return error :
      find first buf_goods exclusive-lock where
                recid(buf_goods) = par-rec no-error .
      if not available buf_goods then do:
        find first buf_goods exclusive-lock where
                 buf_goods.gds-code = par-gds-code.
      end.
      assign
      par-nbc = buf_goods.gds-code
      .
      if buf_goods.gds-type = 'у':U and not par-file then do:
        if not par-file then do :
          if ( par-obj-price-base <> 0 ) AND
            ( par-obj-price-rubl <> 0 ) AND
            ( par-obj-price-base <> ? ) AND
            ( par-obj-price-rubl <> ? ) then .
          else do:
            run do-message in this-procedure(
                                                par-silence
                                                ,"Учетная цена не может быть нулевой !"
                                                ,"error":U
                                                ) no-error .
            if error-status:error then do:
              undo _main, return error return-value.
            end.
          end.
        end.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscr in g#library
  (input  par-obj-type
  ,input  par-obj-code
  ,input  buf_goods.artic
  ,input  buf_clients.obj-type
  ,input  buf_clients.obj-code
  ,input  buf_gds-prt.node-code
  ,buffer ub.gds-obj
  ,buffer ub.prt-obj
  )  .
        if not is-goods then do:
          assign
          prev-value-base = gds-obj.price-base
          prev-value-rubl = gds-obj.price-rubl
          .
        end.
        IF
        ( par-obj-price-base <> prev-value-base OR
        par-obj-price-rubl <> prev-value-rubl ) then do:
          if avail gds-obj then do:
            FIND Current gds-obj exclusive-lock No-WAIT NO-ERROR.
            if not avail gds-obj then undo _main, return error.
            assign
            gds-obj.price-base = par-obj-price-base
            gds-obj.price-rubl = par-obj-price-rubl
            .
            run str/callnews.p
              ( input "gds-obj"
               ,input (buffer gds-obj:handle)
              ).
          end.
          else undo _main, return error.
        end.
      end.
      assign
      buf_goods.grp-code    = buf_gds-grp.node-code
      buf_goods.okdp        = par-okdp
      buf_goods.gds-name    = par-gds-name
      buf_goods.engl-name   = par-engl-name
      buf_goods.label-name   = par-label-name
      buf_goods.chk-name   = par-chk-name
      buf_goods.alpha1   = par-alpha1
      buf_goods.prt-root    = buf_gds-prt.upper-code
      buf_goods.unit-cli    = par-unit-cli
      buf_goods.cli-base-rate = par-cli-base-rate
      buf_goods.calc-method  = par-calc-method
      buf_goods.increase-pc   = (if par-calc-method = 'Группа':U then 0 else par-increase-pc)
      buf_goods.qnty-cart = par-qnty-cart
      buf_goods.ms-base = par-ms-base
      buf_goods.wt-base = par-wt-base
      buf_goods.ms-cart = par-ms-cart
      buf_goods.wt-cart = par-wt-cart
      buf_goods.PS      = par-PS
      buf_goods.PS = REPLACE(buf_goods.PS, chr(10), " ")
      buf_goods.grp-name = ""
      buf_goods.negative-rest = par-NegRest
      buf_goods.min-rate = if is-twounit
                            then par-min-rate
                            else buf_goods.min-rate
      buf_goods.max-rate = if is-twounit
                            then par-max-rate
                            else buf_goods.max-rate
      buf_goods.destin        = par-destin
      buf_goods.attrib        = par-attrib
      buf_goods.user-rule     = par-user-rule
      buf_goods.sert          = par-sert
      buf_goods.struct        = par-struct
      buf_goods.deadline      = par-deadline
      buf_goods.cond-keep-code = par-cond-keep-code
      buf_goods.sort          = par-sort
      buf_goods.proof         = par-proof
      buf_goods.normal-wastage = par-normal-wastage
      buf_goods.normal-waste = par-normal-waste
      buf_goods.unit-cst      = par-unit-cst
      buf_goods.tnved         = par-tnved
      buf_goods.cst-base-rate = par-cst-base-rate
      buf_goods.nationality   = par-nationality
      buf_goods.fbr-grp-code  = par-fbr-grp-code
      v-gds-rec = recid (buf_goods)
      .
      RUN grplib-get-full-name in this-procedure (input buf_gds-grp.node-code, output buf_goods.grp-name).
      run ref/dtaxgdsu.p (
                     input (if par-single-record then yes else no)
                    ,input par-host-code
                    ,input par-obj-type
                    ,input par-obj-code
                    ,input v-gds-rec
                    ,input (if par-copymode then for-goods.gds-code else 0)
                    ) no-error.
      if error-status:error then do:
        run do-message in this-procedure(
                                            par-silence
                                            , substitute("Ошибка при создании/сохранении налогов!&1&2&1&3"
                                             , chr(10)
                                             , return-value
                                             , error-status:get-message(1))
                                            ,"error":U
                                            ) no-error .
        if error-status:error then do:
          undo _main, return error return-value.
        end.
      end.
    end.
  end.
end.
PROCEDURE cre-bc :
define input parameter par-c like ub.gds-prt.node-code no-undo.
define input parameter par-nbc like ub.bar-code.gds-code no-undo .
define input parameter par-ArtDis as logical no-undo .
define input parameter par-ArtAvt like ub.bar-code.b-code no-undo .
define input parameter par-BarDis as integer no-undo .
define output parameter par-main-code like ub.bar-code.gds-code no-undo .
DEFINE VARIABLE var-bc-code as integer no-undo .
define variable v-gds-code like ub.goods.gds-code no-undo .
define variable v-unit-base like ub.goods.unit-base no-undo .
define variable v-goods-recid as recid no-undo .
define buffer buf_bar-code for ub.bar-code.
_bc:
do transaction on error undo, return error :
  IF NOT par-ArtDis and par-Bardis = 0 then do:
    run gen-b-code IN THIS-PROCEDURE (
                                       input 'bcgb':U
                                      ,output var-bc-code
                                      ) no-error.
    if error-status:error then do:
      undo _bc, return error return-value .
    end.
  end.
  else do:
    assign
    var-bc-code = (if par-BarDIs = 1
                   then integer(buf_goods.artic)
                   else (if par-bardis = 2
                         then integer(par-gds-code)
                         else par-nbc)
                  )
    .
  end.
  assign
  par-nbc = var-bc-code
  .
  assign
  buf_goods.gds-code  = if par-ArtDis
                        then par-ArtAvt
                        else var-bc-code
  v-gds-code          = buf_goods.gds-code
  v-unit-base         = buf_goods.unit-base
  .
  create buf_bar-code.
  assign
  buf_bar-code.b-code        = var-bc-code
  buf_bar-code.node-code     = par-c
  buf_bar-code.gds-code      = v-gds-code
  buf_bar-code.in-code       = "":U
  buf_bar-code.part-code     = "":U
  buf_bar-code.unit-cli      = v-unit-base
  buf_bar-code.cli-base-rate = 1
  par-main-code = var-bc-code
  buf_bar-code.stts          = integer('99':U)
  .
  release buf_bar-code no-error .
  if error-status:error then do:
    undo _bc, return error vss-workfile + "Ошибка при создании бар-кода." + chr(10) + return-value + chr(10) + trim(error-status :get-message(1)).
  end.
  assign
  v-goods-recid = recid(buf_goods).
  release buf_goods no-error .
  if error-status:error then do:
    undo _bc, return error vss-workfile + "Ошибка при создании товара." + chr(10) + return-value + chr(10) + trim(error-status :get-message(1)).
  end.
  find first buf_bar-code where buf_bar-code.b-code = var-bc-code.
  assign
  buf_bar-code.stts = 0
  .
  run ref/dtaxgdsu.p (
                  if par-single-record then yes else no
                ,par-host-code
                ,par-obj-type
                ,par-obj-code
                ,v-goods-recid
                ,(if par-copymode then for-goods.gds-code else 0)
                ) no-error.
  if error-status:error then do:
      undo _bc, return error vss-workfile + "Ошибка при создании налогов." + chr(10) + return-value + chr(10) + trim(error-status :get-message(1)).
  end.
  find first buf_bar-code no-lock where
            buf_bar-code.b-code = var-bc-code .
  run bar-codh_write-bar-code-proc in this-procedure (
                                                        buffer buf_bar-code
                                                      , integer('1':U)
                                                      , "":U
                                                      , "":U
                                                      ) .
end.
END PROCEDURE.
procedure do-message :
define input parameter par-silence as logical no-undo .
define input parameter par-mess as character no-undo .
define input parameter par-title-type as character no-undo .
  do
  on error undo, return error
  :
    if not par-silence then do:
      CASE par-title-type:
        when "error":U then do:
          message
          par-mess
          view-as alert-box error.
          undo, return error par-mess.
        end.
        when "warning":U then do:
          message
          par-mess
          view-as alert-box warning.
        end.
        when "question":U then do:
          message
          par-mess
          view-as alert-box question buttons YES-NO update loc#log.
        end.
      end CASE.
    end.
    else do:
      CASE par-title-type:
        when "error":U then do:
          undo, return error par-mess.
        end.
        when "warning":U then do:
        end.
        when "question":U then do:
          loc#log = no.
        end.
      end CASE.
    end.
  end.
end procedure.
PROCEDURE dif-nam2-proc:
define input parameter par-dif-nam2 as logical no-undo .
define input parameter par-gds-name like ub.goods.gds-name no-undo .
define input parameter par-units-type like ub.units.type no-undo .
define input parameter par-gds-code like ub.goods.gds-code no-undo .
  do
  on error undo, return error
  :
    if par-dif-nam2 and par-saved-name = par-gds-name
        and NOT can-do( par-units-type, 'вес':U) AND
        not can-find(first ub.prod-bc where ub.prod-bc.b-code = par-gds-code)
        then return error.
  end.
END PROCEDURE.
