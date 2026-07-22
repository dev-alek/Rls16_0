block-level on error undo, throw.
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Резервирования товара по партиям":U .
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
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
        vss-include-info1 skip
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
          vss-include-info1 skip
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
              vss-include-info1 skip
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
              vss-include-info1 skip
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
        vss-include-info1 skip
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
          vss-include-info1 skip
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
        vss-include-info1 skip
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
        vss-include-info1 skip
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
            vss-include-info1 skip
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
            vss-include-info1 skip
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
          vss-include-info1 skip
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-calc as handle no-undo .
define input parameter parparentproc AS WIDGET-HANDLE NO-UNDO.
define parameter buffer buf_doc-line        for ub.doc-line.
define input parameter  v-chg-free-qnty as decimal no-undo .
define input parameter  v-chg-out-qnty  as decimal no-undo .
define input parameter table for temp-trndocrs-gds-dtl-rsrv .
define input parameter table for temp-trndocrs-pl-gds-rsrv .
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
    assign
      p-vss-parameters = substitute('&1|&2',v-chg-free-qnty,v-chg-out-qnty)
    .
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
define variable v-root-node             like ub.gds-dtl.prt-code no-undo .
define variable l-cr-root-gds-dtl       as   logical             no-undo .
define variable l-need-update-inventory as   logical             no-undo .
define variable l-goods-twounit         as   logical             no-undo .
main-block:
do
on error undo main-block, return error
:
  define variable v-check-qnty like ub.doc-line.doc-qnty no-undo .
  assign
    v-check-qnty = v-chg-free-qnty
  .
  if v-check-qnty <> v-chg-free-qnty then do:
    message
      vss-workfile vss-revision vss-description skip
      "Запрошено резервирование дробного количества" skip
      "Запрошено резервирование v-chg-free-qnty" v-chg-free-qnty skip
      "После округления это составит" v-check-qnty skip
      view-as alert-box .
    undo, return error .
  end.
  assign
    v-check-qnty = v-chg-out-qnty
  .
  if v-check-qnty <> v-chg-out-qnty then do:
    message
      vss-workfile vss-revision vss-description skip
      "Запрошено резервирование дробного количества" skip
      "Запрошено резервирование v-chg-out-qnty" v-chg-out-qnty skip
      "После округления это составит" v-check-qnty skip
      view-as alert-box .
    undo, return error .
  end.
  find first ub.goods no-lock
    where ub.goods.artic     = buf_doc-line.artic
      and ub.goods.prod-type = buf_doc-line.prod-type
      and ub.goods.prod-code = buf_doc-line.prod-code
    .
  find first ub.trn-doc no-lock
    where ub.trn-doc.doc-code = buf_doc-line.doc-code
    .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  ub.goods.artic
  ,input  ub.goods.prod-type
  ,input  ub.goods.prod-code
  ,output v-root-node
  ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении корневого признака шкалы" skip
      "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  ub.trn-doc.obj-type
  ,input  ub.trn-doc.obj-code
  ,input  ub.goods.artic
  ,input  ub.goods.prod-type
  ,input  ub.goods.prod-code
  ,input  'cr-root-gds-dtl=request':u
  ,output l-cr-root-gds-dtl
  ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении признака товара на объекте" skip
      "Объект" ub.trn-doc.obj-type ub.trn-doc.obj-code skip
      "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
      "Запрашиваемый атрибут" 'cr-root-gds-dtl=request':u skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.
  if ub.trn-doc.status_ = 'запрос':U then do:
    if v-chg-free-qnty <> 0
    or v-chg-out-qnty <> 0
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Резервирование товара недопустимо для документов в статусе" 'запрос':U skip
        view-as alert-box error .
      undo, return error .
    end.
    else do:
      return .
    end.
  end.
    define variable v-total-parts-qnty           like ub.parts.qnty      no-undo .   define variable v-total-parts-fact-qnty      like ub.parts.fact-qnty no-undo .   define variable v-total-parts-cli-qnty       like ub.parts.cli-qnty  no-undo .   define variable v-total-parts-fact-cli-qnty  like ub.parts.cli-qnty  no-undo .   define variable v-total-parts-price-cli      as decimal no-undo .   define variable v-total-parts-price-base     as decimal no-undo .   define variable v-total-parts-price-rubl     as decimal no-undo .   define variable v-total-parts-transport-base as decimal no-undo .   define variable v-total-parts-transport-rubl as decimal no-undo .   define variable v-total-parts-other-base     as decimal no-undo .   define variable v-total-parts-other-rubl     as decimal no-undo .
  run partrqst in this-procedure
    (input  buf_doc-line.doc-code
    ,input  buf_doc-line.obj-type
    ,input  buf_doc-line.obj-code
    ,input  buf_doc-line.artic
    ,input  buf_doc-line.prod-type
    ,input  buf_doc-line.prod-code
        ,output v-total-parts-qnty   ,output v-total-parts-fact-qnty   ,output v-total-parts-cli-qnty   ,output v-total-parts-fact-cli-qnty   ,output v-total-parts-price-cli   ,output v-total-parts-price-base   ,output v-total-parts-price-rubl   ,output v-total-parts-transport-base   ,output v-total-parts-transport-rubl   ,output v-total-parts-other-base   ,output v-total-parts-other-rubl
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при выполнении процедуры partrqst" skip
      "buf_doc-line.doc-code"  buf_doc-line.doc-code  skip
      "buf_doc-line.obj-type"  buf_doc-line.obj-type  skip
      "buf_doc-line.obj-code"  buf_doc-line.obj-code  skip
      "buf_doc-line.artic"     buf_doc-line.artic     skip
      "buf_doc-line.prod-type" buf_doc-line.prod-type skip
      "buf_doc-line.prod-code" buf_doc-line.prod-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.
  assign
    l-need-update-inventory = (buf_doc-line.fact-qnty <> v-total-parts-fact-qnty)
  .
  if  (trn-doc.ext-doc-type = 'es':U
      or ub.trn-doc.ext-doc-type = 'rs':U
      )
  and (v-chg-free-qnty <> 0
       or v-chg-out-qnty <> 0
      )
  then do:
    message
      "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
      "Документ" ub.trn-doc.doc-code skip
      "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
      "Было запрошено изменение общего количества, зарезервированного по партиям." skip
      "Зарезервированное из свободной зоны должно измениться на" v-chg-free-qnty skip
      "Зарезервированное из расходной зоны должно измениться на " v-chg-out-qnty skip
      "Для документа продажи через кассу и документа возврата через кассу" skip
      "общее количество зарезервированного товара следует менять из документа продажи" skip
      view-as alert-box information .
    undo, return error .
  end.
  if not l-cr-root-gds-dtl
  and (v-chg-free-qnty <> 0
      or v-chg-out-qnty <> 0
      )
  then do:
    if  ub.trn-doc.doc-type = 'инв':U
    and l-need-update-inventory = false
    then do:
    end.
    else do:
      message
        "На объекте" buf_doc-line.obj-type buf_doc-line.obj-code "включены признаки" skip
        "Товар с артикулом" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        "имеет шкалу с признаками." skip
        "Было запрошено изменение общего количества, зарезервированного по партиям." skip
        "Зарезервированное из свободной зоны должно измениться на" v-chg-free-qnty skip
        "Зарезервированное из расходной зоны должно измениться на " v-chg-out-qnty skip
        "Общее количество зарезервированного товара необходимо изменять через редактирование шкалы." skip
        view-as alert-box information .
      undo, return error .
    end.
  end.
  if l-cr-root-gds-dtl then do:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsdtlcr in g#library
  (input  v-root-node
  ,buffer buf_doc-line
  ,buffer ub.gds-dtl
  ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ощибка при создании корневого признака" skip
        "Документ" buf_doc-line.doc-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box information .
      undo, return error .
    end.
    if not available ub.gds-dtl then do:
      message
        vss-workfile vss-revision vss-description skip
        "В документе отсутствует корневой признак" skip
        "Документ" buf_doc-line.doc-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box information .
      undo, return error .
    end.
  end.
  if l-cr-root-gds-dtl then do:
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,input  'twounit=request':u
  ,output l-goods-twounit
  ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        'twounit=request':u skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if  ub.trn-doc.doc-type = 'при':U
    and ub.trn-doc.internal = no
    then do:
      if ub.trn-doc.flag_ = no then do:
        if buf_doc-line.cli-qnty <> v-total-parts-cli-qnty and
           abs( buf_doc-line.cli-qnty - v-total-parts-cli-qnty ) > 0.001
        then do:
          assign
            buf_doc-line.cli-qnty  = v-total-parts-cli-qnty
          .
        end.
        if l-goods-twounit = true then do:
          if buf_doc-line.cli-qnty <> 0 then do:
            assign
              buf_doc-line.cli-base-rate = buf_doc-line.doc-qnty / buf_doc-line.cli-qnty
            .
          end.
        end.
      end.
      assign
        buf_doc-line.doc-qnty  = v-total-parts-qnty
        buf_doc-line.fact-qnty = v-total-parts-fact-qnty
        ub.gds-dtl.doc-qnty   = buf_doc-line.doc-qnty
        ub.gds-dtl.fact-qnty  = buf_doc-line.fact-qnty
      .
if (valid-handle(g#lib-calc) <> true) then do:   run str/lib-calc.p persistent no-error .   if error-status :error or (valid-handle(g#lib-calc) <> true) then do:     message       "Error starting lib-calc.p" skip       g#lib-calc skip       g#lib-calc :type skip       g#lib-calc :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-calc_lnfactqt in g#lib-calc
(
 input parparentproc
,input recid(buf_doc-line)
,input no
,input ub.trn-doc.status_
,input ub.trn-doc.flag_       )
no-error.
      if error-status:error then do:
        undo, return error substitute("Ошибка при изменении &1 фактического количества по товару: &2 &3 &4 ",
                                return-value,
                                buf_doc-line.artic,
                                buf_doc-line.prod-type,
                                buf_doc-line.prod-code).
      end.
    end.
    if not ((trn-doc.doc-type = 'при':U and internal = no)
            or (trn-doc.doc-type = 'инв':U)
            )
    then do:
      if ub.trn-doc.status_ = 'разрешен':U
      or (trn-doc.doc-type = 'при':U and internal = yes)
      then do:
        assign
          buf_doc-line.fact-qnty = v-total-parts-fact-qnty
          ub.gds-dtl.fact-qnty  = buf_doc-line.fact-qnty
        .
      end.
      else do:
        if ub.trn-doc.status_ <> 'касс':U then do:
          assign
            buf_doc-line.fact-qnty  = v-total-parts-fact-qnty
            ub.gds-dtl.fact-qnty   = buf_doc-line.fact-qnty
          .
        end.
        assign
          buf_doc-line.doc-qnty = v-total-parts-qnty
          ub.gds-dtl.doc-qnty      = buf_doc-line.doc-qnty
        .
        if l-goods-twounit = true then do:
          assign
            buf_doc-line.cli-qnty      = v-total-parts-cli-qnty
          .
          if buf_doc-line.cli-qnty <> 0 then do:
            assign
              buf_doc-line.cli-base-rate = buf_doc-line.doc-qnty / buf_doc-line.cli-qnty
            .
          end.
        end.
      end.
    end.
    if ub.trn-doc.doc-type = 'инв':U
    and l-need-update-inventory
    then do:
      assign
        buf_doc-line.doc-qnty  = buf_doc-line.doc-qnty - buf_doc-line.fact-qnty + v-total-parts-fact-qnty
        buf_doc-line.fact-qnty = v-total-parts-fact-qnty
        ub.gds-dtl.doc-qnty       = buf_doc-line.fact-qnty
        ub.gds-dtl.fact-qnty      = buf_doc-line.doc-qnty
      .
      if l-goods-twounit = true then do:
        assign
          buf_doc-line.cli-qnty      = v-total-parts-cli-qnty
        .
        if buf_doc-line.cli-qnty <> 0 then do:
          assign
            buf_doc-line.cli-base-rate = buf_doc-line.fact-qnty / buf_doc-line.cli-qnty
          .
        end.
      end.
    end.
  end.
  if  ub.trn-doc.doc-type = 'при':U
  and ub.trn-doc.internal = no
  then do:
    if v-total-parts-cli-qnty <> 0 then do:
      assign
        buf_doc-line.price-cli = v-total-parts-price-cli / v-total-parts-cli-qnty
      .
    end.
  end.
  if v-total-parts-fact-qnty <> 0 then do:
    assign
      buf_doc-line.price-base     = v-total-parts-price-base     / v-total-parts-fact-qnty
      buf_doc-line.price-rubl     = v-total-parts-price-rubl     / v-total-parts-fact-qnty
      buf_doc-line.transport-base = v-total-parts-transport-base / v-total-parts-fact-qnty
      buf_doc-line.transport-rubl = v-total-parts-transport-rubl / v-total-parts-fact-qnty
      buf_doc-line.other-base     = v-total-parts-other-base     / v-total-parts-fact-qnty
      buf_doc-line.other-rubl     = v-total-parts-other-rubl     / v-total-parts-fact-qnty
    .
  end.
  if l-cr-root-gds-dtl then do:
    if can-do ('рас,спи':U,trn-doc.doc-type)
    and ub.goods.gds-type      = 'т':U
    and ((trn-doc.status_   = 'накл':U
          and ub.trn-doc.flag_  = no
          )
          or ub.trn-doc.status_ = 'касс':U
        )
    then do:
      define variable v-new-free-qnty as decimal no-undo .
      define variable v-old-free-qnty as decimal no-undo .
      run trg/free-prt.p
        (input  buf_doc-line.obj-type
        ,input  buf_doc-line.obj-code
        ,input  buf_doc-line.artic
        ,input  buf_doc-line.prod-type
        ,input  buf_doc-line.prod-code
        ,input  v-root-node
        ,output v-old-free-qnty
        ) .
      define variable l-need-create-doc-pl as logical no-undo .
      run trndocrs-need-create-doc-pl
        (input  ub.trn-doc.ext-doc-type
        ,input  false
        ,input  no
        ,output l-need-create-doc-pl
        ) .
      if not l-need-create-doc-pl then do:
        for each temp-trndocrs-pl-gds-rsrv
          where temp-trndocrs-pl-gds-rsrv.rsrv-qnty    <> 0
            or temp-trndocrs-pl-gds-rsrv.rsrv-out-qnty <> 0
        on error undo, return error
        :
          message
            "Товар учитывается по складским местам" skip
            "Было запрошено изменение количества, зарезервированного по складскому месту." skip
            "Общее количество необходимо изменять через редактирование документа." skip
            "Зарезервированное из свободной зоны должно измениться на" temp-trndocrs-pl-gds-rsrv.rsrv-qnty skip
            "Зарезервированное из расходной зоны должно измениться на" temp-trndocrs-pl-gds-rsrv.rsrv-out-qnty skip
            "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
            "Артикулом" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
            "Складское место" temp-trndocrs-pl-gds-rsrv.pl-code skip
            view-as alert-box information .
          undo, return error .
        end.
      end.
      run trndocrs-gds-dtl-clear in this-procedure  .
      run trndocrs-gds-dtl-accum in this-procedure
        (input ub.gds-dtl.prt-code
        ,input v-chg-free-qnty
        ) .
      run trndocrs in this-procedure
        (input buf_doc-line.doc-code
        ,input buf_doc-line.obj-type
        ,input buf_doc-line.obj-code
        ,input buf_doc-line.artic
        ,input buf_doc-line.prod-type
        ,input buf_doc-line.prod-code
        ,input v-chg-free-qnty
        ) .
      run trg/free-prt.p
        (input  buf_doc-line.obj-type
        ,input  buf_doc-line.obj-code
        ,input  buf_doc-line.artic
        ,input  buf_doc-line.prod-type
        ,input  buf_doc-line.prod-code
        ,input  v-root-node
        ,output v-new-free-qnty
        ) .
      if  ub.goods.negative-rest = false
      and v-new-free-qnty < 0 then do:
        message
          "Отрицательные остатки недопустимы" skip
          "Объект"  buf_doc-line.obj-type buf_doc-line.obj-code skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          "Было свободно" v-old-free-qnty  skip
          "Стало свободно" v-new-free-qnty skip
          view-as alert-box.
        undo, return error .
      end.
    end.
    run str/chk-prt.p
      (input recid(buf_doc-line)
      ,input false
      ,buffer ub.trn-doc
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при установке флага разнесения по строке" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscheck in g#library
  (input buf_doc-line.obj-type
  ,input buf_doc-line.obj-code
  ,input buf_doc-line.artic
  ,input buf_doc-line.prod-type
  ,input buf_doc-line.prod-code
  ,input v-root-node
  ,input ''
  ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке целостности товара" skip
      "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
      "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
      "Проверка целостности товара до резервирования" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box .
    undo, return error .
  end.
end.
