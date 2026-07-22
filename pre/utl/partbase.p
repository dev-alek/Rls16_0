block-level on error undo, throw.
define input parameter parparentproc AS  WIDGET-HANDLE       NO-UNDO.
define input parameter p-artic      like ub.parts.artic      no-undo .
define input parameter p-prod-type  like ub.parts.prod-type  no-undo .
define input parameter p-prod-code  like ub.parts.prod-code  no-undo .
define input parameter p-in-code    like ub.parts.in-code    no-undo .
define input parameter p-part-code  like ub.parts.part-code  no-undo .
define input parameter p-price-base like ub.parts.price-base no-undo .
define input parameter p-price-rubl like ub.parts.price-rubl no-undo .
define input parameter p-vat-pc     like ub.parts.vat-pc     no-undo .
define input parameter p-slt-pc     like ub.parts.slt-pc     no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: partbase.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/partbase.p $":U .
define variable vss-description as character no-undo init "Программа изменения учетной цены партии".
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
define temp-table temp-trndocrs-gds-dtl-rsrv no-undo
  field prt-code         like ub.gds-dtl.prt-code
  field rsrv-qnty        like ub.gds-dtl.fact-qnty
  field rsrv-out-qnty    like ub.gds-dtl.fact-qnty
  index xpk is primary unique prt-code
.
define temp-table temp-trndocrs-pl-gds-rsrv no-undo
  field pl-code          like ub.pl-gds.pl-code
  field rsrv-qnty        like ub.pl-gds.free-qnty
  field cli-rsrv-qnty    like ub.pl-gds.cli-free-qnty
  field rsrv-out-qnty    like ub.pl-gds.fact-qnty
  field before-free-qnty like ub.pl-gds.fact-qnty
  field before-out-qnty  like ub.pl-gds.fact-qnty
  field after-free-qnty  like ub.pl-gds.fact-qnty
  field after-out-qnty   like ub.pl-gds.fact-qnty
  field fact-qnty        like ub.pl-gds.fact-qnty
  field cli-qnty         like ub.pl-gds.cli-qnty
  field cli-fact-qnty    like ub.pl-gds.cli-fact-qnty
  index xpk is primary unique pl-code
.
procedure trndocrs-gds-dtl-clear :
  define buffer buf_temp-trndocrs-gds-dtl-rsrv for temp-trndocrs-gds-dtl-rsrv .
  do
  on error undo, return error return-value
  :
    for each buf_temp-trndocrs-gds-dtl-rsrv
    on error undo, return error return-value
    :
      delete buf_temp-trndocrs-gds-dtl-rsrv .
    end.
  end.
end procedure.
procedure trndocrs-pl-gds-clear :
  define buffer buf_temp-trndocrs-pl-gds-rsrv  for temp-trndocrs-pl-gds-rsrv .
  do
  on error undo, return error return-value
  :
    for each buf_temp-trndocrs-pl-gds-rsrv
    on error undo, return error return-value
    :
      delete buf_temp-trndocrs-pl-gds-rsrv .
    end.
  end.
end procedure.
procedure trndocrs-clear :
  define buffer buf_temp-trndocrs-gds-dtl-rsrv for temp-trndocrs-gds-dtl-rsrv .
  define buffer buf_temp-trndocrs-pl-gds-rsrv  for temp-trndocrs-pl-gds-rsrv .
  do
  on error undo, return error return-value
  :
    for each buf_temp-trndocrs-gds-dtl-rsrv
    on error undo, return error return-value
    :
      delete buf_temp-trndocrs-gds-dtl-rsrv .
    end.
    for each buf_temp-trndocrs-pl-gds-rsrv
    on error undo, return error return-value
    :
      delete buf_temp-trndocrs-pl-gds-rsrv .
    end.
  end.
end procedure.
procedure trndocrs-pl-gds-accum :
  define input parameter p-pl-code       like ub.pl-gds.pl-code       no-undo .
  define input parameter p-rsrv-qnty     like ub.pl-gds.free-qnty     no-undo .
  define input parameter p-cli-rsrv-qnty like ub.pl-gds.cli-free-qnty no-undo .
  define input parameter p-fact-qnty     like ub.pl-gds.fact-qnty     no-undo .
  define input parameter p-cli-fact-qnty like ub.pl-gds.cli-fact-qnty no-undo .
  define buffer buf_temp-trndocrs-pl-gds-rsrv  for temp-trndocrs-pl-gds-rsrv .
  do
  on error undo, return error return-value
  :
    find first buf_temp-trndocrs-pl-gds-rsrv
      where buf_temp-trndocrs-pl-gds-rsrv.pl-code = p-pl-code
      no-error .
    if not available buf_temp-trndocrs-pl-gds-rsrv then do:
      create buf_temp-trndocrs-pl-gds-rsrv .
      assign
        buf_temp-trndocrs-pl-gds-rsrv.pl-code = p-pl-code
      .
    end.
    assign
      buf_temp-trndocrs-pl-gds-rsrv.rsrv-qnty     = buf_temp-trndocrs-pl-gds-rsrv.rsrv-qnty     + p-rsrv-qnty
      buf_temp-trndocrs-pl-gds-rsrv.cli-rsrv-qnty = buf_temp-trndocrs-pl-gds-rsrv.cli-rsrv-qnty + p-cli-rsrv-qnty
      buf_temp-trndocrs-pl-gds-rsrv.fact-qnty     = buf_temp-trndocrs-pl-gds-rsrv.fact-qnty     + p-fact-qnty
      buf_temp-trndocrs-pl-gds-rsrv.cli-fact-qnty = buf_temp-trndocrs-pl-gds-rsrv.cli-fact-qnty + p-cli-fact-qnty
    .
  end.
end procedure.
procedure trndocrs-gds-dtl-accum :
  define input parameter p-prt-code   like ub.gds-dtl.prt-code   no-undo .
  define input parameter p-rsrv-qnty like ub.gds-dtl.fact-qnty no-undo .
  define buffer buf_temp-trndocrs-gds-dtl-rsrv  for temp-trndocrs-gds-dtl-rsrv .
  do
  on error undo, return error return-value
  :
    find first buf_temp-trndocrs-gds-dtl-rsrv
      where buf_temp-trndocrs-gds-dtl-rsrv.prt-code = p-prt-code
      no-error .
    if not available buf_temp-trndocrs-gds-dtl-rsrv then do:
      create buf_temp-trndocrs-gds-dtl-rsrv .
      assign
        buf_temp-trndocrs-gds-dtl-rsrv.prt-code = p-prt-code
      .
    end.
    assign
      buf_temp-trndocrs-gds-dtl-rsrv.rsrv-qnty = buf_temp-trndocrs-gds-dtl-rsrv.rsrv-qnty
                                             + p-rsrv-qnty
    .
  end.
end procedure.
procedure trndocrs-pl-gds-request :
  define input parameter p-doc-code               like ub.doc-line.doc-code  no-undo .
  define input parameter p-doc-type               like ub.trn-doc.doc-type   no-undo .
  define input parameter p-obj-type               like ub.doc-line.obj-type  no-undo .
  define input parameter p-obj-code               like ub.doc-line.obj-code  no-undo .
  define input parameter p-artic                  like ub.doc-line.artic     no-undo .
  define input parameter p-prod-type              like ub.doc-line.prod-type no-undo .
  define input parameter p-prod-code              like ub.doc-line.prod-code no-undo .
  define input parameter p-field-accum            as character no-undo .
  define variable vss-description as character no-undo init "trndocrs-pl-gds-request: Сбор информации о партиях на складских местах".
  define buffer buf_temp-trndocrs-pl-gds-rsrv for temp-trndocrs-pl-gds-rsrv .
  do
  on error undo, return error return-value
  :
    if lookup(p-field-accum, "before,after":u ) = 0 then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info0 skip
        "Ошибка задания входных параметров параметров" skip
        "Неизвестное значение параметра" skip
        "p-field-accum" p-field-accum skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    case p-field-accum :
      when "before":u then do:
        for each buf_temp-trndocrs-pl-gds-rsrv
        on error undo, return error return-value
        :
          assign
            buf_temp-trndocrs-pl-gds-rsrv.before-free-qnty = 0
            buf_temp-trndocrs-pl-gds-rsrv.before-out-qnty  = 0
          .
        end.
      end.
      when "after":u then do:
        for each buf_temp-trndocrs-pl-gds-rsrv
        on error undo, return error return-value
        :
          assign
            buf_temp-trndocrs-pl-gds-rsrv.after-free-qnty  = 0
            buf_temp-trndocrs-pl-gds-rsrv.after-out-qnty   = 0
          .
        end.
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info0 skip
          "Ошибка задания входных параметров параметров" skip
          "Неизвестное значение параметра" skip
          "p-field-accum" p-field-accum skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
    define buffer buf_parts for ub.parts.
    for each buf_parts no-lock
      where buf_parts.out-code  = p-doc-code
        and buf_parts.obj-type  = p-obj-type
        and buf_parts.obj-code  = p-obj-code
        and buf_parts.artic     = p-artic
        and buf_parts.prod-type = p-prod-type
        and buf_parts.prod-code = p-prod-code
    on error undo, return error return-value
    :
      find first buf_temp-trndocrs-pl-gds-rsrv
        where buf_temp-trndocrs-pl-gds-rsrv.pl-code = buf_parts.pl-code
        no-error .
      if not available buf_temp-trndocrs-pl-gds-rsrv then do:
        create buf_temp-trndocrs-pl-gds-rsrv .
        assign
          buf_temp-trndocrs-pl-gds-rsrv.pl-code = buf_parts.pl-code
        .
      end.
      if can-do('при,рас,спи':U, p-doc-type)
      or (p-doc-type = 'инв':U
          and buf_parts.fact-qnty < 0)
      then do:
        case p-field-accum :
          when "before":u then do:
            assign
              buf_temp-trndocrs-pl-gds-rsrv.before-free-qnty
                = buf_temp-trndocrs-pl-gds-rsrv.before-free-qnty
                + abs(buf_parts.fact-qnty)
            .
          end.
          when "after":u then do:
            assign
              buf_temp-trndocrs-pl-gds-rsrv.after-free-qnty
                = buf_temp-trndocrs-pl-gds-rsrv.after-free-qnty
                + abs(buf_parts.fact-qnty)
            .
          end.
          otherwise do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info0 skip
              "Ошибка задания входных параметров параметров" skip
              "Неизвестное значение параметра" skip
              "p-field-accum" p-field-accum skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end.
      end.
      else do:
        case p-field-accum :
          when "before":u then do:
            assign
              buf_temp-trndocrs-pl-gds-rsrv.before-out-qnty
                = buf_temp-trndocrs-pl-gds-rsrv.before-out-qnty
                + abs(buf_parts.fact-qnty)
            .
          end.
          when "after":u then do:
            assign
              buf_temp-trndocrs-pl-gds-rsrv.after-out-qnty
                = buf_temp-trndocrs-pl-gds-rsrv.after-out-qnty
                + abs(buf_parts.fact-qnty)
            .
          end.
          otherwise do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info0 skip
              "Ошибка задания входных параметров параметров" skip
              "Неизвестное значение параметра" skip
              "p-field-accum" p-field-accum skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure trndocrs-pl-gds-calc-rsrv :
  define variable vss-description as character no-undo init "trndocrs-pl-gds-calc-rsrv: Сбор информации о партиях на складских местах".
  define buffer buf_temp-trndocrs-pl-gds-rsrv for temp-trndocrs-pl-gds-rsrv .
  do
  on error undo, return error return-value
  :
    for each buf_temp-trndocrs-pl-gds-rsrv
    on error undo, return error return-value
    :
      assign
        buf_temp-trndocrs-pl-gds-rsrv.rsrv-qnty
          = buf_temp-trndocrs-pl-gds-rsrv.after-free-qnty
          - buf_temp-trndocrs-pl-gds-rsrv.before-free-qnty
        buf_temp-trndocrs-pl-gds-rsrv.rsrv-out-qnty
          = buf_temp-trndocrs-pl-gds-rsrv.after-out-qnty
          - buf_temp-trndocrs-pl-gds-rsrv.before-out-qnty
      .
    end.
  end.
end procedure.
procedure trndocrs-need-rsrv :
  define input  parameter p-doc-type     like ub.trn-doc.doc-type no-undo .
  define input  parameter p-artic        like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type    like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code    like ub.doc-line.prod-code no-undo .
  define output parameter p-need-rsrv    as logical   no-undo .
  define buffer buf_goods   for ub.goods .
  do
  on error undo, return error return-value
  :
    find first buf_goods no-lock
      where buf_goods.artic     = p-artic
        and buf_goods.prod-type = p-prod-type
        and buf_goods.prod-code = p-prod-code
      .
    if buf_goods.gds-type = 'т':U
    and ( p-doc-type = 'рас':U
          or p-doc-type = 'спи':U
        )
    then do:
      assign
        p-need-rsrv = true
      .
    end.
    else do:
      assign
        p-need-rsrv = false
      .
    end.
  end.
end procedure.
procedure trndocrs-need-create-doc-pl :
  define input  parameter p-extended-doc-type  as character no-undo .
  define input  parameter p-news               as logical   no-undo .
  define input  parameter p-sale-auto          as logical   no-undo .
  define output parameter p-need-create-doc-pl as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if  not p-news
    and p-extended-doc-type <> 'ie':U
    and p-extended-doc-type <> 'es':U
    and p-extended-doc-type <> 'rs':U
    and not p-sale-auto
    then do:
      assign
        p-need-create-doc-pl = true
      .
    end.
    else do:
      assign
        p-need-create-doc-pl = false
      .
    end.
  end.
end procedure.
procedure trndocrs-validate :
  define input parameter p-place-rsrv as logical no-undo .
  define input parameter p-chg-qnty   as decimal no-undo .
  define buffer buf_temp-trndocrs-gds-dtl-rsrv for temp-trndocrs-gds-dtl-rsrv .
  define buffer buf_temp-trndocrs-pl-gds-rsrv  for temp-trndocrs-pl-gds-rsrv .
  define variable v-total-gds-dtl-rsrv-qnty as decimal no-undo .
  define variable v-total-pl-gds-rsrv-qnty as decimal no-undo .
  assign
    v-total-gds-dtl-rsrv-qnty = 0
    v-total-pl-gds-rsrv-qnty  = 0
  .
  do
  on error undo, return error return-value
  :
    for each buf_temp-trndocrs-gds-dtl-rsrv
    on error undo, return error return-value
    :
      assign
        v-total-gds-dtl-rsrv-qnty = v-total-gds-dtl-rsrv-qnty
                                  + buf_temp-trndocrs-gds-dtl-rsrv.rsrv-qnty
      .
    end.
    for each buf_temp-trndocrs-pl-gds-rsrv
    on error undo, return error return-value
    :
      assign
        v-total-pl-gds-rsrv-qnty = v-total-pl-gds-rsrv-qnty
                                 + buf_temp-trndocrs-pl-gds-rsrv.rsrv-qnty
      .
    end.
    if round(v-total-gds-dtl-rsrv-qnty, 0) <> round(p-chg-qnty, 0) then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info0 skip
        "Ошибка при резервировании свободных количеств" skip
        "Запрошено резервирование:" skip
        "По товару" p-chg-qnty skip
        "По признакам" v-total-gds-dtl-rsrv-qnty skip
        "По складским местам" v-total-pl-gds-rsrv-qnty skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-place-rsrv then do:
      if round(v-total-pl-gds-rsrv-qnty, 0) <> round(p-chg-qnty, 0) then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info0 skip
          "Ошибка при резервировании свободных количеств" skip
          "Запрошено резервирование:" skip
          "По товару" p-chg-qnty skip
          "По признакам" v-total-gds-dtl-rsrv-qnty skip
          "По складским местам" v-total-pl-gds-rsrv-qnty skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.
end procedure.
procedure trndocrs :
  define input parameter p-doc-code   like ub.doc-line.doc-code  no-undo .
  define input parameter p-obj-type   like ub.doc-line.obj-type  no-undo .
  define input parameter p-obj-code   like ub.doc-line.obj-code  no-undo .
  define input parameter p-artic      like ub.doc-line.artic     no-undo .
  define input parameter p-prod-type  like ub.doc-line.prod-type no-undo .
  define input parameter p-prod-code  like ub.doc-line.prod-code no-undo .
  define input parameter p-chg-qnty   as decimal no-undo .
  define buffer buf_db         for ub.db .
  define buffer buf_gds-obj    for ub.gds-obj .
  define buffer buf_prt-obj    for ub.prt-obj .
  define buffer buf_gds-prt    for ub.gds-prt .
  define buffer buf_goods      for ub.goods .
  define buffer buf_pl-gds     for ub.pl-gds .
  define buffer buf_temp-trndocrs-pl-gds-rsrv  for temp-trndocrs-pl-gds-rsrv .
  define buffer buf_temp-trndocrs-gds-dtl-rsrv for temp-trndocrs-gds-dtl-rsrv .
  define variable v-node-code   like ub.gds-prt.node-code no-undo .
  define variable v-curr-db-num like ub.db.db-num         no-undo .
  define variable v-cmd         as   character            no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info0 skip
        "Ошибка при поиске товара на объекте" skip
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
    find current buf_gds-obj exclusive-lock .
    run trndocrs-validate in this-procedure
      (input buf_gds-obj.place-rsrv
      ,input p-chg-qnty
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info0 skip
        "Противоречивые данные для резервирования" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      buf_gds-obj.free-qnty   = buf_gds-obj.free-qnty - p-chg-qnty
      buf_gds-obj.on-line-rest = buf_gds-obj.free-qnty
    .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input  'rest-update':U
  ,input ?
  ,input  buffer buf_gds-obj:handle
  ,input 'fact-qnty,free-qnty'
  ,input ''
  ) no-error .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-curr-db-num
  )  .
    find first buf_db no-lock
      where buf_db.db-num = v-curr-db-num
      .
    if buf_db.db-num <> 0
      and buf_db.on-line-rest = true
    then do:
      assign
        v-cmd = "command":U + chr(1)
                + "create":U + chr(1)
                + "on-line-rest":U + chr(1)
                + substitute( "&1", buf_gds-obj.obj-type ) + chr(1)
                + substitute( "&1", buf_gds-obj.obj-code ) + chr(1)
                + substitute( "&1", buf_gds-obj.artic ) + chr(1)
                + substitute( "&1", buf_gds-obj.prod-type ) + chr(1)
                + substitute( "&1", buf_gds-obj.prod-code ) + chr(1)
                + substitute( "&1", buf_gds-obj.free-qnty ) + chr(1)
      .
      run nws/cr-route.p
        ( input 'send-cmd':U
          ,input v-cmd
          ,input ?
          ,input "0":U
        ).
    end.
    if buf_gds-obj.place-rsrv = true then do:
      for each buf_temp-trndocrs-pl-gds-rsrv
      on error undo, return error return-value
      :
        find first buf_goods no-lock
          where buf_goods.artic     = p-artic
            and buf_goods.prod-type = p-prod-type
            and buf_goods.prod-code = p-prod-code
          no-error .
        if not available buf_goods then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info0 skip
            "Не найдена товар" skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        find first buf_pl-gds exclusive-lock
          where buf_pl-gds.obj-type = p-obj-type
            and buf_pl-gds.obj-code = p-obj-code
            and buf_pl-gds.gds-code = buf_goods.gds-code
            and buf_pl-gds.pl-code  = buf_temp-trndocrs-pl-gds-rsrv.pl-code
          no-error .
        if not available buf_pl-gds then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info0 skip
            "Не найдена привязка товара к складскому месту" skip
            "Код товара" buf_temp-trndocrs-pl-gds-rsrv.pl-code skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        assign
          buf_pl-gds.free-qnty     = buf_pl-gds.free-qnty     - buf_temp-trndocrs-pl-gds-rsrv.rsrv-qnty
          buf_pl-gds.cli-free-qnty = buf_pl-gds.cli-free-qnty - buf_temp-trndocrs-pl-gds-rsrv.cli-rsrv-qnty
        .
        if buf_pl-gds.free-qnty = buf_pl-gds.fact-qnty
          and absolute( buf_pl-gds.cli-free-qnty - buf_pl-gds.cli-fact-qnty ) <= 0.01
        then do:
          assign
            buf_pl-gds.cli-free-qnty = buf_pl-gds.cli-fact-qnty
          .
        end.
      end.
    end.
    for each buf_temp-trndocrs-gds-dtl-rsrv
    on error undo, return error return-value
    :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run termnode in g#library
  (input  buf_temp-trndocrs-gds-dtl-rsrv.prt-code
  ,output v-node-code
  ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info0 skip
          "Ошибка при определении первого терминального признака" skip
          "prt-code" buf_temp-trndocrs-gds-dtl-rsrv.prt-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find first buf_gds-prt no-lock
        where buf_gds-prt.node-code = v-node-code
        .
      do while available buf_gds-prt
      on error undo, return error return-value
      :
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  buf_gds-prt.node-code
  ,buffer buf_prt-obj
  )  .
        find current buf_prt-obj exclusive-lock .
        assign
          buf_prt-obj.free-qnty = buf_prt-obj.free-qnty - buf_temp-trndocrs-gds-dtl-rsrv.rsrv-qnty
        .
        assign
          v-node-code = buf_gds-prt.upper-code
        .
        find first buf_gds-prt no-lock
          where buf_gds-prt.node-code = v-node-code
          no-error .
      end.
    end.
  end.
end procedure.
main-block :
do transaction
on error undo, return error
:
  output to partbase.txt append .
  export
    p-artic
    p-prod-type
    p-prod-code
    p-in-code
    p-part-code
    p-price-base
    p-price-rubl
    .
  output close .
  run trg/nu_trnhd.p
    (input p-in-code
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при выполнении процедуры nu_trnhd.p" skip
      view-as alert-box .
    undo main-block, return error .
  end.
  for each ub.parts exclusive-lock
    where ub.parts.artic     = p-artic
      and ub.parts.prod-type = p-prod-type
      and ub.parts.prod-code = p-prod-code
      and ub.parts.in-code   = p-in-code
      and ub.parts.part-code = p-part-code
  on error undo, return error return-value
  :
    output to partbase.fix append .
    export parts .
    output close .
    assign
      ub.parts.price-base = p-price-base
      ub.parts.price-rubl = p-price-rubl
    .
    if ub.parts.vat-type = 'в т. ч.':U or
       ub.parts.vat-type = 'нет':U  then do:
       assign
         ub.parts.vat-pc = p-vat-pc.
    end.
    if ub.parts.slt-type = 'в т. ч.':U or
       ub.parts.slt-type = 'нет':U  then do:
       assign
         ub.parts.slt-pc = p-slt-pc.
    end.
    if  ub.parts.out-code <> 'free-zone':U
    and ub.parts.out-code <> 'out-zone':U
    then do:
      find first ub.doc-line exclusive-lock
        where ub.doc-line.doc-code  = ub.parts.out-code
          and ub.doc-line.artic     = ub.parts.artic
          and ub.doc-line.prod-type = ub.parts.prod-type
          and ub.doc-line.prod-code = ub.parts.prod-code
        no-error.
      if available ub.doc-line then do:
        run trg/rsrv-gds.p
          (input parparentproc
          ,buffer ub.doc-line
          ,input  0
          ,input  0
          ,input table temp-trndocrs-gds-dtl-rsrv
          ,input table temp-trndocrs-pl-gds-rsrv
          ).
        run trg/nu_trnhd.p
          (input ub.parts.out-code
          ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при выполнении процедуры nu_trnhd.p" skip
            "p-doc-code" ub.parts.out-code skip
            view-as alert-box .
          undo main-block, return error .
        end.
      end.
      else do:
        find first ub.price-list where ub.price-list.doc-num = ub.parts.out-code exclusive-lock .
        run trg/nu_prc.p
        (input ub.price-list.doc-num
        ,input 'price-doc':U
        ,input ub.price-list.obj-type
        ,input ub.price-list.obj-code
        ) no-error .
      end.
    end.
  end.
end.
