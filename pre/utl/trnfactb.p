block-level on error undo, throw.
DEFINE TEMP-TABLE x_parts LIKE ub.parts.
define input  parameter ParParentProc as handle no-undo .
define input  parameter p-doc-code as character no-undo .
define input  parameter table for x_parts.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: 2014/01/27 14:27:46 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: trnfactb.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/trnfactb.p $":U .
define variable vss-description as character no-undo init "Корректировка партий внешнего прихода закрытого на факт".
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
procedure partrqst :
  define input  parameter p-doc-code                   like ub.doc-line.doc-code  no-undo .
  define input  parameter p-obj-type                   like ub.doc-line.obj-type  no-undo .
  define input  parameter p-obj-code                   like ub.doc-line.obj-code  no-undo .
  define input  parameter p-artic                      like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type                  like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code                  like ub.doc-line.prod-code no-undo .
  define output parameter p-total-parts-qnty           like ub.parts.qnty         no-undo .
  define output parameter p-total-parts-fact-qnty      like ub.parts.fact-qnty    no-undo .
  define output parameter p-total-parts-cli-qnty       like ub.parts.cli-qnty     no-undo .
  define output parameter p-total-parts-fact-cli-qnty  like ub.parts.cli-qnty     no-undo .
  define output parameter p-total-parts-price-cli      as decimal                 no-undo .
  define output parameter p-total-parts-price-base     as decimal                 no-undo .
  define output parameter p-total-parts-price-rubl     as decimal                 no-undo .
  define output parameter p-total-parts-transport-base as decimal                 no-undo .
  define output parameter p-total-parts-transport-rubl as decimal                 no-undo .
  define output parameter p-total-parts-other-base     as decimal                 no-undo .
  define output parameter p-total-parts-other-rubl     as decimal                 no-undo .
  define variable vss-description as character no-undo init "partrqst: Суммарная информация по всем зарезервированным партиям строки документа".
  do
  on error undo, return error return-value
  :
    assign
      p-total-parts-qnty           = 0
      p-total-parts-fact-qnty      = 0
      p-total-parts-cli-qnty       = 0
      p-total-parts-fact-cli-qnty  = 0
      p-total-parts-price-cli      = 0
      p-total-parts-price-base     = 0
      p-total-parts-price-rubl     = 0
      p-total-parts-transport-base = 0
      p-total-parts-transport-rubl = 0
      p-total-parts-other-base     = 0
      p-total-parts-other-rubl     = 0
    .
    define buffer buf_parts for ub.parts .
    for each buf_parts no-lock
      where buf_parts.out-code  = p-doc-code
        and buf_parts.obj-type  = p-obj-type
        and buf_parts.obj-code  = p-obj-code
        and buf_parts.artic     = p-artic
        and buf_parts.prod-type = p-prod-type
        and buf_parts.prod-code = p-prod-code
    on error undo, return error return-value
    :
      define variable v-parts-fact-multiplier as decimal   no-undo .
      assign
        v-parts-fact-multiplier = 1
      .
      if buf_parts.qnty <> 0 then do:
        assign
          v-parts-fact-multiplier = buf_parts.fact-qnty / buf_parts.qnty
        .
      end.
      assign
        p-total-parts-qnty            = p-total-parts-qnty       + buf_parts.qnty
        p-total-parts-fact-qnty       = p-total-parts-fact-qnty  + buf_parts.fact-qnty
        p-total-parts-cli-qnty        = p-total-parts-cli-qnty   + buf_parts.cli-qnty
        p-total-parts-fact-cli-qnty   = p-total-parts-fact-cli-qnty
                                      + buf_parts.cli-qnty * v-parts-fact-multiplier
        p-total-parts-price-cli       = p-total-parts-price-cli  + buf_parts.cli-qnty  * buf_parts.price-cli
        p-total-parts-price-base      = p-total-parts-price-base + buf_parts.fact-qnty * buf_parts.price-base
        p-total-parts-price-rubl      = p-total-parts-price-rubl + buf_parts.fact-qnty * buf_parts.price-rubl
        p-total-parts-transport-base  = p-total-parts-transport-base
                                      + buf_parts.fact-qnty
                                        * (if   buf_parts.transport-base <> ?
                                          then buf_parts.transport-base
                                          else 0
                                          )
        p-total-parts-transport-rubl  = p-total-parts-transport-rubl
                                      + buf_parts.fact-qnty
                                        * (if   buf_parts.transport-rubl <> ?
                                          then buf_parts.transport-rubl
                                          else 0
                                          )
        p-total-parts-other-base      = p-total-parts-other-base
                                      + buf_parts.fact-qnty
                                        * (if   buf_parts.other-base <> ?
                                          then buf_parts.other-base
                                          else 0
                                          )
        p-total-parts-other-rubl      = p-total-parts-other-rubl
                                      + buf_parts.fact-qnty
                                        * (if   buf_parts.other-rubl <> ?
                                          then buf_parts.other-rubl
                                          else 0
                                          )
      .
    end.
  end.
end procedure.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gdsobjcl :
  define input parameter p-gds-obj-recid    as recid no-undo .
  define input parameter p-update-fact-qnty as logical   no-undo .
  define variable vss-description as character no-undo init "$Workfile$ gdsobjcl: расчет записи товар на объекте ".
  define buffer buf_parts for ub.parts .
  define variable v-total-avrg-base as decimal no-undo .
  define variable v-total-avrg-rubl as decimal no-undo .
  define variable v-total-avrg-qnty as decimal no-undo .
  define variable v-parts-avrg-qnty as decimal no-undo .
  define variable v-total-fact-base as decimal no-undo .
  define variable v-total-fact-rubl as decimal no-undo .
  define variable v-total-fact-qnty as decimal no-undo .
  define variable v-parts-fact-qnty as decimal   no-undo .
  define buffer buf_gds-obj for ub.gds-obj .
  define buffer buf_prt-obj for ub.prt-obj .
  define buffer buf_gds-prt for ub.gds-prt .
  do
  on error undo, return error return-value
  :
    find first buf_gds-obj exclusive-lock
      where recid(buf_gds-obj) = p-gds-obj-recid
      no-error .
    if not available buf_gds-obj
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найдена запись товар на объекте" skip
        "Код записи (recid)" p-gds-obj-recid skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      v-total-avrg-base = 0
      v-total-avrg-rubl = 0
      v-total-avrg-qnty = 0
      v-total-fact-base = 0
      v-total-fact-rubl = 0
      v-total-fact-qnty = 0
    .
    for each buf_parts no-lock
      where buf_parts.obj-type  = buf_gds-obj.obj-type
        and buf_parts.obj-code  = buf_gds-obj.obj-code
        and buf_parts.artic     = buf_gds-obj.artic
        and buf_parts.prod-type = buf_gds-obj.prod-type
        and buf_parts.prod-code = buf_gds-obj.prod-code
        and buf_parts.status_   = no
        and buf_parts.rsrv-free = yes
        and buf_parts.in-code   <> buf_parts.out-code
        and buf_parts.doc-type  <> 'акт':U
    on error undo, return error return-value
    :
      assign
        v-parts-avrg-qnty = 0
        v-parts-fact-qnty = 0
      .
      if buf_parts.out-code = 'free-zone':U
      then do:
        if buf_parts.fact-qnty > 0
        then do:
          assign
            v-parts-avrg-qnty = buf_parts.qnty
          .
        end.
        assign
          v-parts-fact-qnty = buf_parts.qnty
        .
      end.
      else do:
        assign
          v-parts-avrg-qnty = abs(buf_parts.qnty)
          v-parts-fact-qnty = abs(buf_parts.qnty)
        .
      end.
      assign
        v-total-avrg-base = v-total-avrg-base
                          + (buf_parts.price-base * v-parts-avrg-qnty)
        v-total-avrg-rubl = v-total-avrg-rubl
                          + (buf_parts.price-rubl * v-parts-avrg-qnty)
        v-total-avrg-qnty = v-total-avrg-qnty
                          + v-parts-avrg-qnty
        v-total-fact-base = v-total-fact-base
                          + (buf_parts.price-base * v-parts-fact-qnty)
        v-total-fact-rubl = v-total-fact-rubl
                          + (buf_parts.price-rubl * v-parts-fact-qnty)
        v-total-fact-qnty = v-total-fact-qnty
                          + v-parts-fact-qnty
      .
    end.
    if v-total-avrg-qnty < 0
    or v-total-avrg-qnty = ?
    then do:
      undo, return error
        vss-description + chr(10)
        + "Количество положительных партий в свободной зоне не может быть отрицательным или неопределенным" + chr(10)
        + "v-total-avrg-qnty " + (if v-total-avrg-qnty <> ? then string(v-total-avrg-qnty) else "?")
        .
    end.
    if v-total-fact-base = ?
    or v-total-fact-rubl = ?
    then do:
      undo, return error
        vss-description + chr(10)
        + "Сумма учетных цен по товару на объекте не может иметь неопределенное значение" + chr(10)
        + "v-total-fact-base " + (if v-total-fact-base <> ? then string(v-total-fact-base) else "?") + chr(10)
        + "v-total-fact-rubl " + (if v-total-fact-rubl <> ? then string(v-total-fact-rubl) else "?") + chr(10)
        .
    end.
    assign
      buf_gds-obj.avrg-qnty = v-total-avrg-qnty
      buf_gds-obj.fact-base = v-total-fact-base
      buf_gds-obj.fact-rubl = v-total-fact-rubl
    .
    if p-update-fact-qnty
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров"
        "В данной версии обновление фактического количества не реализовано" skip
        "p-update-fact-qnty" p-update-fact-qnty skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if buf_gds-obj.fact-qnty <> v-total-fact-qnty
    then do:
      undo, return error
        vss-description + chr(10)
        + "Не совпадает общее количество по партиям и фактическое количество по товару на объекте" + chr(10)
        + "buf_gds-obj.fact-qnty " + (if buf_gds-obj.fact-qnty <> ? then string(buf_gds-obj.fact-qnty) else "?") + chr(10)
        + "v-total-fact-qnty "     + (if v-total-fact-qnty     <> ? then string(v-total-fact-qnty)     else "?") + chr(10)
        .
    end.
    if v-total-avrg-qnty > 0
    then do:
      assign
        buf_gds-obj.avrg-base = v-total-avrg-base / v-total-avrg-qnty
        buf_gds-obj.avrg-rubl = v-total-avrg-rubl / v-total-avrg-qnty
      .
    end.
    else do:
      if  buf_gds-obj.last-base > 0
      and buf_gds-obj.last-rubl > 0
      then do:
        assign
          buf_gds-obj.avrg-base = buf_gds-obj.last-base
          buf_gds-obj.avrg-rubl = buf_gds-obj.last-rubl
        .
      end.
    end.
    define variable v-total-sale-fact-qnty as decimal   no-undo .
    define variable v-total-fact-sale      as decimal   no-undo .
    assign
      v-total-sale-fact-qnty = 0
      v-total-fact-sale      = 0
    .
    for each buf_prt-obj
      where buf_prt-obj.obj-type  = buf_gds-obj.obj-type
        and buf_prt-obj.obj-code  = buf_gds-obj.obj-code
        and buf_prt-obj.artic     = buf_gds-obj.artic
        and buf_prt-obj.prod-type = buf_gds-obj.prod-type
        and buf_prt-obj.prod-code = buf_gds-obj.prod-code
        and buf_prt-obj.is-term   = true
    on error undo, return error return-value
    :
      assign
        v-total-sale-fact-qnty  = v-total-sale-fact-qnty
                                + buf_prt-obj.fact-qnty
        v-total-fact-sale       = v-total-fact-sale
                                + buf_prt-obj.fact-qnty * buf_prt-obj.price-sale
      .
    end.
    if v-total-fact-sale = ?
    then do:
      undo, return error
        vss-description + chr(10)
        + "Сумма продажных цен по товару на объекте не может иметь неопределенное значение" + chr(10)
        + "v-total-fact-sale " + (if v-total-fact-sale <> ? then string(v-total-fact-sale) else "?") + chr(10)
        .
    end.
    if buf_gds-obj.fact-qnty <> v-total-sale-fact-qnty
    then do:
      undo, return error
        vss-description + chr(10)
        + "Не совпадает общее количество по признакам и фактическое количество по товару на объекте" + chr(10)
        + "buf_gds-obj.fact-qnty "  + (if buf_gds-obj.fact-qnty <> ?  then string(buf_gds-obj.fact-qnty)  else "?") + chr(10)
        + "v-total-sale-fact-qnty " + (if v-total-sale-fact-qnty <> ? then string(v-total-sale-fact-qnty) else "?") + chr(10)
        .
    end.
    assign
      buf_gds-obj.fact-sale = v-total-fact-sale
    .
  end.
end procedure .
procedure gdsobjcl-calc-goods :
  define input parameter p-artic     like ub.goods.artic     no-undo .
  define input parameter p-prod-type like ub.goods.prod-type no-undo .
  define input parameter p-prod-code like ub.goods.prod-code no-undo .
  define variable vss-description as character no-undo init "$Workfile$ gdsobjcl-calc-goods".
  do
  on error undo, return error return-value
  :
    define buffer buf_gds-obj for ub.gds-obj .
    define buffer buf_prt-obj for ub.prt-obj .
    do
    on error undo, return error return-value
    :
      for each buf_prt-obj
        where buf_prt-obj.artic     = p-artic
          and buf_prt-obj.prod-type = p-prod-type
          and buf_prt-obj.prod-code = p-prod-code
      on error undo, return error return-value
      :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtobjup in g#library
  (buffer buf_prt-obj
  ) no-error .
        if error-status :error
        then do:
          undo, return error
            "объект "  + string(buf_prt-obj.obj-type) + " " + string(buf_prt-obj.obj-code) + chr(10)
            + "артикул " + string(buf_prt-obj.artic) + " " + string(buf_prt-obj.prod-type) + " " + string(buf_prt-obj.prod-code) + chr(10)
            + "признак " + string(buf_prt-obj.prt-code) + chr(10)
            + return-value .
        end.
      end.
      for each buf_gds-obj
        where buf_gds-obj.artic     = p-artic
          and buf_gds-obj.prod-type = p-prod-type
          and buf_gds-obj.prod-code = p-prod-code
      on error undo, return error return-value
      :
        run gdsobjcl in this-procedure
          (input recid(buf_gds-obj)
          ,input false
          ) no-error .
        if error-status :error
        then do:
          undo, return error
            "объект " + string(buf_gds-obj.obj-type) + " " + string(buf_gds-obj.obj-code) + chr(10)
            + return-value .
        end.
      end.
    end.
  end.
end procedure.
    define buffer   in-vatp-trn-doc  for ub.trn-doc .
    define buffer   in-vatp-parts    for ub.parts   .
    define buffer   in-vatp-doc      for ub.trn-doc .
    define buffer   in-vatp-goods    for ub.goods   .
    define buffer   in-vatp-sysconf  for ub.sysconf .
    define buffer   in-vatp_doc-attr for ub.doc-attr.
    define variable in-vatp-have-vat-slt       as   logical initial yes    no-undo.
    define variable vat-pc-loc                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprb                  as   character              no-undo.
    define variable slt-pc-loc                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rate              as   decimal                no-undo.
    define variable price-rubl-with-tax-loc    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loc    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loc     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loc like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loc like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loc  like ub.doc-line.price-base no-undo.
    define variable vat-base-loc               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loc               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loc           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loc         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loc         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loc          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loc             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loc             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loc              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loc          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envd             as   character              no-undo.
    define variable varinvatp-type             as   character              no-undo.
define variable v-total-parts-qnty           like ub.parts.qnty      no-undo .   define variable v-total-parts-fact-qnty      like ub.parts.fact-qnty no-undo .   define variable v-total-parts-cli-qnty       like ub.parts.cli-qnty  no-undo .   define variable v-total-parts-fact-cli-qnty  like ub.parts.cli-qnty  no-undo .   define variable v-total-parts-price-cli      as decimal no-undo .   define variable v-total-parts-price-base     as decimal no-undo .   define variable v-total-parts-price-rubl     as decimal no-undo .   define variable v-total-parts-transport-base as decimal no-undo .   define variable v-total-parts-transport-rubl as decimal no-undo .   define variable v-total-parts-other-base     as decimal no-undo .   define variable v-total-parts-other-rubl     as decimal no-undo .
define buffer buf_trn-doc    for ub.trn-doc  .
define buffer oth_trn-doc    for ub.trn-doc  .
define buffer buf_doc-line   for ub.doc-line .
define buffer buf_parts      for ub.parts    .
define buffer all_parts      for ub.parts    .
define buffer free_parts     for ub.parts    .
define buffer buf_parts-attr for ub.parts-attr  .
define buffer buf_goods      for ub.goods   .
define variable v-doc-line-VAT-pc   as decimal   no-undo .
define variable v-rash-cli          as decimal   no-undo .
define variable v-rash-qnty         as decimal   no-undo .
define variable v-delta-qnty        as decimal   no-undo .
define variable v-delta-cli-qnty    as decimal   no-undo .
define variable v-root-node         like ub.gds-prt.node-code no-undo .
find first buf_trn-doc exclusive-lock where
           buf_trn-doc.doc-code = p-doc-code
           no-error .
if available buf_trn-doc then
    run str/trn-hist.p
        ( buffer buf_trn-doc ,
          input  buf_trn-doc.obj-type ,
          input  buf_trn-doc.obj-code ,
          input  "Корр. закрытого на ФАКТ"
        ) .
do :
for each x_parts break by x_parts.prod-type
                       by x_parts.prod-code
                       by x_parts.artic
                       :
  find first buf_goods no-lock where
             buf_goods.artic      = x_parts.artic     and
             buf_goods.prod-type  = x_parts.prod-type and
             buf_goods.prod-code  = x_parts.prod-code no-error .
    find first free_parts exclusive-lock where
               free_parts.obj-type   = x_parts.obj-type  and
               free_parts.obj-code   = x_parts.obj-code  and
               free_parts.out-code   = 'free-zone':U      and
               free_parts.part-code  = x_parts.part-code and
               free_parts.in-code    = x_parts.in-code   and
               free_parts.artic      = x_parts.artic     and
               free_parts.prod-type  = x_parts.prod-type and
               free_parts.prod-code  = x_parts.prod-code
               no-error .
       if available free_parts then do:
         run calc-rash-part in this-procedure (
            input  x_parts.artic    ,
            input  x_parts.prod-type,
            input  x_parts.prod-code,
            input  x_parts.obj-type ,
            input  x_parts.obj-code ,
            input  x_parts.in-code  ,
            input  x_parts.part-code  ,
            output v-rash-cli ,
            output v-rash-qnty
            ) .
         assign
           free_parts.cli-qnty   = x_parts.cli-qnty  - v-rash-cli
           free_parts.qnty       = x_parts.qnty      - v-rash-qnty
           free_parts.fact-qnty  = x_parts.fact-qnty - v-rash-qnty
         .
       end.
       else do:
       end.
    find first buf_parts exclusive-lock where
               buf_parts.obj-type   = x_parts.obj-type  and
               buf_parts.obj-code   = x_parts.obj-code  and
               buf_parts.out-code   = x_parts.out-code  and
               buf_parts.part-code  = x_parts.part-code and
               buf_parts.in-code    = x_parts.in-code   and
               buf_parts.artic      = x_parts.artic     and
               buf_parts.prod-type  = x_parts.prod-type and
               buf_parts.prod-code  = x_parts.prod-code
               no-error .
    If available buf_parts then  do:
       buffer-copy x_parts to buf_parts .
    end.
    for each  buf_parts-attr exclusive-lock where
              buf_parts-attr.gds-code   = buf_goods.gds-code and
              buf_parts-attr.in-code    = x_parts.in-code and
              buf_parts-attr.part-code  = x_parts.part-code :
        assign
          buf_parts-attr.alc-bottling-date       = x_parts.alc-bottling-date
          buf_parts-attr.alc-certif-path         = x_parts.alc-certif-path
          buf_parts-attr.alc-quality-certif-path = x_parts.alc-quality-certif-path
          buf_parts-attr.alc-ref-ab-path         = x_parts.alc-ref-ab-path
          buf_parts-attr.cli-qnty                = x_parts.cli-qnty
          buf_parts-attr.cst-code                = x_parts.cst-code
          buf_parts-attr.doc-qnty                = x_parts.qnty
          buf_parts-attr.fact-qnty               = x_parts.fact-qnty
          buf_parts-attr.last-date               = x_parts.last-date
          buf_parts-attr.mark-code               = x_parts.mark-code
          buf_parts-attr.mark-db-num             = x_parts.mark-db-num
          buf_parts-attr.price-base              = x_parts.price-base
          buf_parts-attr.price-cli               = x_parts.price-cli
          buf_parts-attr.price-rubl              = x_parts.price-rubl
          buf_parts-attr.road-tax-base           = x_parts.road-tax-base
          buf_parts-attr.road-tax-rubl           = x_parts.road-tax-rubl
          buf_parts-attr.transport-base          = x_parts.transport-base
          buf_parts-attr.transport-rubl          = x_parts.transport-rubl
          buf_parts-attr.vat-pc                  = x_parts.vat-pc
          .
          v-doc-line-VAT-pc =  x_parts.vat-pc .
assign
  price-rubl-with-tax-loc = x_parts.price-rubl
  price-base-with-tax-loc = x_parts.price-base
.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if x_parts.out-code = 'free-zone':U     or
     x_parts.out-code = 'out-zone':U   or
     x_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = x_parts.out-code
        and in-vatp_doc-attr.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attr then do:
      assign
        in-vatp-have-vat-slt = yes.
    end.
    else do:
         in-vatp-have-vat-slt = no.
    end.
  end.
  assign
   price-cli-with-tax-loc = x_parts.price-cli
   cli-base-rate          = x_parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if x_parts.road-tax-base  = ? then 0 else x_parts.road-tax-base)
           road-tax-rubl-loc  = (if x_parts.road-tax-rubl  = ? then 0 else x_parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if x_parts.transport-base = ? then 0 else x_parts.transport-base)
          transport-rubl-loc = (if x_parts.transport-rubl = ? then 0 else x_parts.transport-rubl)
          other-base-loc     = (if x_parts.other-base     = ? then 0 else x_parts.other-base)
          other-rubl-loc     = (if x_parts.other-rubl     = ? then 0 else x_parts.other-rubl)
          vat-pc-loc         = (if x_parts.vat-pc         = ? then 0 else x_parts.vat-pc)
          slt-pc-loc         = (if x_parts.slt-pc         = ? then 0 else x_parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (x_parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if x_parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if x_parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / x_parts.price-cli .
  assign
    slt-cli-loc        = slt-rubl-loc       / exch-rate-cli-loc
    vat-cli-loc        = vat-rubl-loc       / exch-rate-cli-loc
    road-tax-cli-loc   = road-tax-rubl-loc  / exch-rate-cli-loc
    transport-cli-loc  = 0
    other-cli-loc      = 0
  .
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
          assign
            buf_parts-attr.vat-base     = vat-base-loc
            buf_parts-attr.vat-rubl     = vat-rubl-loc
            buf_parts-attr.slt-base     = slt-base-loc
            buf_parts-attr.slt-rubl     = slt-rubl-loc
            buf_parts-attr.discnt-base  = 0
            buf_parts-attr.discnt-rubl  = 0
          .
    end.
    for each all_parts exclusive-lock where
             all_parts.artic     = x_parts.artic      and
             all_parts.prod-type = x_parts.prod-type  and
             all_parts.prod-code = x_parts.prod-code  and
             all_parts.in-code   = p-doc-code and
             all_parts.out-code  <> x_parts.out-code
             :
     assign
        all_parts.price-cli  = x_parts.price-cli
        all_parts.price-base = x_parts.price-base
        all_parts.price-rubl = x_parts.price-rubl
        all_parts.vat-pc     = x_parts.vat-pc
        all_parts.cst-code   = x_parts.cst-code
        all_parts.last-date  = x_parts.last-date
     .
    end.
    if last-of(x_parts.artic) then do:
        find first buf_doc-line exclusive-lock where
                   buf_doc-line.doc-code  = p-doc-code and
                   buf_doc-line.artic     = x_parts.artic     and
                   buf_doc-line.prod-type = x_parts.prod-type and
                   buf_doc-line.prod-code = x_parts.prod-code
                   no-error .
        if available buf_doc-line then do:
        run partrqst in this-procedure
          (input  buf_doc-line.doc-code
          ,input  buf_doc-line.obj-type
          ,input  buf_doc-line.obj-code
          ,input  buf_doc-line.artic
          ,input  buf_doc-line.prod-type
          ,input  buf_doc-line.prod-code
                    ,output v-total-parts-qnty   ,output v-total-parts-fact-qnty   ,output v-total-parts-cli-qnty   ,output v-total-parts-fact-cli-qnty   ,output v-total-parts-price-cli   ,output v-total-parts-price-base   ,output v-total-parts-price-rubl   ,output v-total-parts-transport-base   ,output v-total-parts-transport-rubl   ,output v-total-parts-other-base   ,output v-total-parts-other-rubl
          ).
        assign
          buf_doc-line.price-cli  = v-total-parts-price-cli / v-total-parts-cli-qnty
          buf_doc-line.doc-qnty   = v-total-parts-qnty
          buf_doc-line.fact-qnty  = v-total-parts-fact-qnty
          buf_doc-line.cli-qnty   = v-total-parts-cli-qnty
          buf_doc-line.price-base = v-total-parts-price-base   / v-total-parts-fact-qnty
          buf_doc-line.price-rubl = v-total-parts-price-rubl   / v-total-parts-fact-qnty
          buf_doc-line.transport-base  = v-total-parts-transport-base / v-total-parts-fact-qnty
          buf_doc-line.transport-rubl  = v-total-parts-transport-rubl / v-total-parts-fact-qnty
          buf_doc-line.other-base      = v-total-parts-other-base     / v-total-parts-fact-qnty
          buf_doc-line.other-rubl      = v-total-parts-other-rubl     / v-total-parts-fact-qnty
          buf_doc-line.vat-pc          = vat-pc-loc
        .
         find first ub.gds-obj exclusive-lock where
                    ub.gds-obj.gds-code = buf_goods.gds-code and
                    ub.gds-obj.obj-code = buf_doc-line.obj-code and
                    ub.gds-obj.obj-type = buf_doc-line.obj-type no-error .
        if available ub.gds-obj then do :
          run utl/par2gds.p (
              input ub.gds-obj.artic,
              input ub.gds-obj.prod-type,
              input ub.gds-obj.prod-code,
              input ub.gds-obj.obj-type,
              input ub.gds-obj.obj-code
              ) .
            run gdsobjcl in this-procedure (recid(ub.gds-obj), false ).
        end.
       end.
    end.
    find first oth_trn-doc no-lock where
               oth_trn-doc.doc-code = buf_parts.out-code no-error .
    if available oth_trn-doc and oth_trn-doc.status_ = 'факт':U then do:
        run str/calc-hd.p (input oth_trn-doc.doc-code) .
        run str/vtrecalc.p ( input parparentproc , input recid (oth_trn-doc)).
         find first ub.gds-obj exclusive-lock where
                    ub.gds-obj.gds-code = buf_goods.gds-code and
                    ub.gds-obj.obj-code = oth_trn-doc.obj-code and
                    ub.gds-obj.obj-type = oth_trn-doc.obj-type no-error .
        if available ub.gds-obj then run gdsobjcl in this-procedure (recid(ub.gds-obj), false ).
        run trg/markdoc.p
          ( input oth_trn-doc.doc-code
           ,input 'doc-change':u
          ) .
        find current oth_trn-doc exclusive-lock .
                     oth_trn-doc.bge-date = ? .
    end.
end.
if available buf_trn-doc then do:
    run str/calc-hd.p  ( input buf_trn-doc.doc-code ) .
    run str/vtrecalc.p ( input parparentproc , input recid (buf_trn-doc) ).
    run trg/markdoc.p
      ( input buf_trn-doc.doc-code
      , input 'doc-change':u
      ) .
    find current buf_trn-doc exclusive-lock .
                 buf_trn-doc.bge-date = ? .
end.
define variable v-remote-db-list as character no-undo .
define buffer buf_db for ub.db  .
  v-remote-db-list = "":U .
  for each buf_db where buf_db.db-num > 0 no-lock :
    assign
      v-remote-db-list = (if v-remote-db-list <> "":U then v-remote-db-list + chr(1)
                                                      else ""
                          ) + string(buf_db.db-num)
    .
  end.
 if ( g#db-num > 0 and g#news = false ) or g#db-num = 0 then do:
        run trg/cmd-corr.p
          ( input p-doc-code ,
            input table x_parts ,
            input 'cmd-parts-fact-corr':U ,
            input ( if g#db-num = 0 then v-remote-db-list else "0" )
            ) .
 end.
end.
procedure calc-rash-part :
define input  parameter p-artic       as character no-undo .
define input  parameter p-prod-type   as character no-undo .
define input  parameter p-prod-code   as integer   no-undo .
define input  parameter p-obj-type    as character no-undo .
define input  parameter p-obj-code    as integer   no-undo .
define input  parameter p-in-code     as character no-undo .
define input  parameter p-part-code   as character no-undo .
define output parameter p-rash-cli    as decimal   no-undo .
define output parameter p-rash-qnty   as decimal   no-undo .
define buffer r_parts   for ub.parts  .
define buffer rez_parts for ub.parts  .
  do
  on error undo, return error return-value
  :
  p-rash-cli  = 0 .
  p-rash-qnty = 0 .
  for each r_parts no-lock where
           r_parts.artic      =  p-artic and
           r_parts.prod-type  =  p-prod-type and
           r_parts.prod-code  =  p-prod-code and
           r_parts.obj-type   =  p-obj-type  and
           r_parts.obj-code   =  p-obj-code  and
           r_parts.part-code  =  p-part-code  and
           r_parts.out-code   = 'out-zone':U and
           r_parts.rsrv-free  = no :
      assign
        p-rash-cli  = p-rash-cli  + r_parts.cli-qnty
        p-rash-qnty = p-rash-qnty + r_parts.fact-qnty
      .
  end.
  for each rez_parts no-lock where
          rez_parts.artic       =  p-artic      and
          rez_parts.prod-type   =  p-prod-type  and
          rez_parts.prod-code   =  p-prod-code  and
          rez_parts.part-code   =  p-part-code  and
          rez_parts.in-code     =  p-in-code    and
          rez_parts.out-code    <> p-in-code    and
          rez_parts.out-code    <> 'free-zone':U and
          rez_parts.status_     =  false        and
          rez_parts.rsrv-free   =  true
          :
          assign
              p-rash-cli  = p-rash-cli  + rez_parts.cli-qnty
              p-rash-qnty = p-rash-qnty + rez_parts.fact-qnty
            .
    end.
 end.
end procedure.
