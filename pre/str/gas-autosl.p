block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo.
define input parameter p-log-handle as handle no-undo.
define input parameter log-file-name as character no-undo.
define input parameter p-auto as integer no-undo.
define input parameter p-inkas-code as character no-undo.
define input parameter v-curr-r-b as character no-undo.
define input parameter p-cli-type as character no-undo.
define input parameter p-cli-code as integer no-undo.
define output parameter p-doc-code as character no-undo.
define output parameter p-root-node as character no-undo.
define parameter buffer buf-sale_trn-doc for ub.trn-doc.
define parameter buffer buf-sale_doc-line for ub.doc-line.
define parameter buffer buf-new_trn-doc for ub.trn-doc.
define variable vss-revision as character no-undo init "$Revision: a1ec81b583b9, 1957, rls $":U .
define variable vss-author as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date as character no-undo init "$Date: 2019/07/26 08:40:52 $":U .
define variable vss-workfile as character no-undo init "$Workfile: gas-autosl.p $":U .
define variable vss-archive as character no-undo init "$Archive: str/gas-autosl.p $":U .
define variable vss-description as character no-undo init "Создание приходного документа техпролива по документу продажи газа (ТГУ)".
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure doc-code:
define input  parameter parmode          as   character           no-undo.
define input  parameter parobj-type      like ub.clients.obj-type no-undo.
define input  parameter parobj-code      like ub.clients.obj-code no-undo.
define input  parameter parroot-doc-code like ub.trn-doc.doc-code no-undo.
define output parameter pardoc-code      like ub.trn-doc.doc-code no-undo.
define buffer buf_sys-ctrl for ub.sys-ctrl  .
define variable vardb-remote     as   logical             no-undo.
define variable vartemp-doc-code like ub.trn-doc.doc-code no-undo.
define variable v-delimiter as character no-undo .
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
:
find first buf_sys-ctrl no-lock .
vardb-remote = buf_sys-ctrl.db-num <> 0 .
  CASE parmode:
    when "main":u then do:
      if vardb-remote then do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (parobj-code, ">>>>9")) + substring (parobj-type, (if g#language = "RUS" then 1 else 2), 1).
      end.
      else do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-".
      end.
    end.
    when "trio" then do:
      assign
        pardoc-code = replace (parroot-doc-code, "=", "*").
    end.
    otherwise do:
      assign
      v-delimiter = entry(lookup(entry(1, parmode), "main,chip,pair,flora,trio-m,quadro,stock-up,stock-down,stock-fix," +                          "main_s,chip_s,pair_s,trio-m_s,quadro_s,stock-up_s,stock-down_s,stock-fix_s":U), ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)))
      no-error
      .
      if error-status:error  then do:
        undo, return error substitute("Ошибка при генерации номера документа&1Неверное значение параметра parmode &2"
                                      ,chr(10)
                                      ,parmode
                                      ).
      end.
      if num-entries(parmode) = 1
      and parmode <> "chip":U
      and parmode <> "chip_s":U
      then do:
        assign
        pardoc-code = replace (parroot-doc-code, "-", v-delimiter).
      end.
      else if (lookup("chip":U, parmode) > 0
               or
               lookup("chip_s":U, parmode) > 0) then do:
        assign
          vartemp-doc-code = parroot-doc-code.
        do while true:
          if index (vartemp-doc-code , ".") = 0 then
            vartemp-doc-code  = replace (vartemp-doc-code , v-delimiter, v-delimiter + "1.").
          else
            vartemp-doc-code  =
            substring (vartemp-doc-code , 1, index (vartemp-doc-code, v-delimiter)) +
            string (integer (substring (vartemp-doc-code, index (vartemp-doc-code, v-delimiter) + 1, index (vartemp-doc-code, ".") - index (vartemp-doc-code, v-delimiter) - 1)) + 1) +
            substring (vartemp-doc-code, index (vartemp-doc-code, ".")).
          if not can-find (ub.trn-doc where ub.trn-doc.doc-code = vartemp-doc-code no-lock) then leave.
        end.
        assign
          pardoc-code = vartemp-doc-code.
      end.
    end.
  end CASE.
  if pardoc-code = '':U
  or (parroot-doc-code <> '':U
  and pardoc-code = parroot-doc-code) then do:
    undo, return error substitute("Ошибка при генерации номера документа&1"
                                  ,chr(10)).
  end.
end.
end. // procedure/method
function get-doc-code-int64 returns int64
  ( input p-doc-code as character ) :
  define variable v-ind              as integer   no-undo .
  define variable v-num-entries      as integer   no-undo .
  define variable v-doc-code-int64   as int64     no-undo .
  define variable v-canonic-doc-code as character no-undo .
  assign
    v-num-entries      = num-entries( ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) )
    v-canonic-doc-code = p-doc-code
  .
  do v-ind = 1 to v-num-entries
  :
    assign
      v-canonic-doc-code = entry(1, v-canonic-doc-code, entry( v-ind, ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) ) )
    .
  end.
  assign
    v-doc-code-int64 = int64(v-canonic-doc-code) no-error
  .
  return v-doc-code-int64 .
end. // function/method
define variable vss-include-info3 as character format "x(65)":U no-undo initial "@(#)$Workfile$ $Revision$".
procedure partscr :
  define input  parameter parparentproc      as widget-handle no-undo.
  define input  parameter p-db-num           as integer   no-undo .
  define input  parameter p-user-id          as character no-undo .
  define input  parameter p-supp-type        as character no-undo .
  define input  parameter p-supp-code        as integer   no-undo .
  define input  parameter p-part-code        as character no-undo .
  define input  parameter p-cst-code         as character no-undo .
  define input  parameter p-ps               as character no-undo .
  define input  parameter p-dop              as character no-undo .
  define input  parameter p-part-reserv-base as decimal   no-undo .
  define input  parameter p-part-reserv-rubl as decimal   no-undo .
  define input  parameter p-vat-type         as character no-undo .
  define input  parameter p-vat-pc           as decimal   no-undo .
  define input  parameter p-slt-type         as character no-undo .
  define input  parameter p-slt-pc           as decimal   no-undo .
  define input  parameter p-change-qnty      as decimal   no-undo .
  define input  parameter p-action           as character no-undo .
  define input  parameter p-cli-qnty         as decimal   no-undo .
  define input  parameter p-last-date        as date      no-undo .
  define input  parameter p-hold-date        as date      no-undo .
  define input  parameter p-pl-code          as integer   no-undo .
  define parameter buffer buf_doc-line       for ub.doc-line .
  define parameter buffer buf_parts          for ub.parts .
  define variable vss-description as character no-undo initial "$Workfile$ $Revision$ Процедура создания партии".
  define variable v-price-cli                like ub.doc-line.price-rubl no-undo.
  define variable v-price-cli-unit-base      like ub.doc-line.price-rubl no-undo.
  define variable v-price-road-tax           like ub.doc-line.price-rubl no-undo.
  define variable v-price-other-exp          like ub.doc-line.price-rubl no-undo.
  define variable v-price-transport-exp      like ub.doc-line.price-rubl no-undo.
  define variable v-price-without-abs        like ub.doc-line.price-rubl no-undo.
  define variable v-price-slt                like ub.doc-line.price-rubl no-undo.
  define variable v-price-no-slt             like ub.doc-line.price-rubl no-undo.
  define variable v-price-vat                like ub.doc-line.price-rubl no-undo.
  define variable v-price-no-vat-slt         like ub.doc-line.price-rubl no-undo.
  define variable v-price-rubl               like ub.doc-line.price-rubl no-undo.
  define variable v-price-road-tax-rubl      like ub.doc-line.price-rubl no-undo.
  define variable v-price-other-exp-rubl     like ub.doc-line.price-rubl no-undo.
  define variable v-price-transport-exp-rubl like ub.doc-line.price-rubl no-undo.
  define variable v-price-without-abs-rubl   like ub.doc-line.price-rubl no-undo.
  define variable v-price-slt-rubl           like ub.doc-line.price-rubl no-undo.
  define variable v-price-no-slt-rubl        like ub.doc-line.price-rubl no-undo.
  define variable v-price-vat-rubl           like ub.doc-line.price-rubl no-undo.
  define variable v-price-no-vat-slt-rubl    like ub.doc-line.price-rubl no-undo.
  define variable v-price-base               like ub.doc-line.price-base no-undo.
  define variable v-price-road-tax-base      like ub.doc-line.price-base no-undo.
  define variable v-price-other-exp-base     like ub.doc-line.price-base no-undo.
  define variable v-price-transport-exp-base like ub.doc-line.price-base no-undo.
  define variable v-price-without-abs-base   like ub.doc-line.price-base no-undo.
  define variable v-price-slt-base           like ub.doc-line.price-base no-undo.
  define variable v-price-no-slt-base        like ub.doc-line.price-base no-undo.
  define variable v-price-vat-base           like ub.doc-line.price-base no-undo.
  define variable v-price-no-vat-slt-base    like ub.doc-line.price-base no-undo.
  define variable l-fact-qnty              as logical   no-undo .
  define variable v-action                 as character no-undo .
  define variable l-need-create-old-return as logical   no-undo init false .
  define variable l-create-old-return      as logical   no-undo init false .
  define variable v-izlcstpr        as character no-undo .
  define variable l-goods-serial           as logical   no-undo .
  define variable l-goods-twounit          as logical   no-undo .
  define variable l-reserv-pl-code         as logical   no-undo .
  define variable l-goods-bottle           as logical   no-undo .
  define buffer buf_trn-doc  for ub.trn-doc .
  define buffer buf_goods    for ub.goods .
  define variable v-prompt-price       as character no-undo .
  define variable v-check-right        as logical   no-undo .
  define variable v-ind                as integer   no-undo .
  define variable v-num-entries-action as integer   no-undo .
  define variable v-option             as character no-undo .
  define variable v-type as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-check-right = true
    .
    if not available buf_doc-line
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не задана строка документа" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-supp-type = ?
    or p-supp-type = ''
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-supp-type имеет неопределенное значение" skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-supp-code = ?
    or p-supp-code = 0
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-supp-code имеет неопределенное значение" skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-part-code = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-part-code имеет неопределенное значение" skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-cst-code = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-cst-code имеет неопределенное значение" skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-ps = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-ps имеет неопределенное значение" skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-part-reserv-base = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-part-reserv-base имеет неопределенное значение" skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-part-reserv-base < 0
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-part-reserv-base имеет отрицательное значение" skip
        "p-part-reserv-base" p-part-reserv-base skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-part-reserv-rubl = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-part-reserv-rubl имеет неопределенное значение" skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-part-reserv-rubl < 0
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-part-reserv-rubl имеет отрицательное значение" skip
        "p-part-reserv-rubl" p-part-reserv-rubl skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-change-qnty = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-change-qnty имеет неопределенное значение" skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-pl-code = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-pl-code имеет неопределенное значение" skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      v-num-entries-action = num-entries(p-action, chr(44))
    .
    do v-ind = 1 to v-num-entries-action
    :
      assign
        v-option = entry(v-ind, p-action, chr(44))
      .
      if num-entries(v-option, '=':u) <> 2
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Количество входений в опцию отлично от двух"
          "p-action" p-action skip
          "v-option" v-option skip
          view-as alert-box error .
        undo, return error .
      end.
      case entry(1, v-option, '=':u)
      :
        when 'prompt':u
        then do:
          assign
            v-prompt-price = v-option
          .
        end.
        when 'check-right':u
        then do:
          assign
            v-check-right = logical(entry(2, v-option, '=':u))
          .
        end.
        when 'izlcstpr':u
        then do :
            assign
                v-izlcstpr = v-option
            .
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка задания входных параметров" skip
            "Неизвестная опция"
            "p-action" p-action skip
            "v-option" v-option skip
            view-as alert-box error .
          undo, return error .
        end.
      end case .
    end.
    if lookup(v-prompt-price, 'prompt=enable,prompt=disable-reject,prompt=disable-create':u ) > 0
    then do:
    end.
    else do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "v-prompt-price" v-prompt-price skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = buf_doc-line.doc-code
      .
define variable v-negparts as character no-undo .
define variable v-negmanuf as character no-undo .
define variable v-prcshrs0 as character no-undo .
define variable v-prcshrs1 as character no-undo .
define variable v-prdocrs0 as character no-undo .
define variable v-prdocrs1 as character no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input buf_doc-line.obj-type
  ,input buf_doc-line.obj-code
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
  if thbjattr_thbj-attr.prop-code = 'negparts'  then  v-negparts  = thbjattr_thbj-attr.property-value-character.
  if thbjattr_thbj-attr.prop-code = 'negmanuf'  then  v-negmanuf  = thbjattr_thbj-attr.property-value-character.
  if thbjattr_thbj-attr.prop-code = 'prcshrs0'  then  v-prcshrs0  = thbjattr_thbj-attr.property-value-character.
  if thbjattr_thbj-attr.prop-code = 'prcshrs1'  then  v-prcshrs1  = thbjattr_thbj-attr.property-value-character.
  if thbjattr_thbj-attr.prop-code = 'prdocrs0'  then  v-prdocrs0  = thbjattr_thbj-attr.property-value-character.
  if thbjattr_thbj-attr.prop-code = 'prdocrs1'  then  v-prdocrs1  = thbjattr_thbj-attr.property-value-character.
end.
    if p-cst-code = ?
    then do:
      assign
        p-cst-code = (if buf_trn-doc.cst-code <> ?
                      then buf_trn-doc.cst-code
                      else "")
      .
    end.
    find first buf_goods no-lock
      where buf_goods.artic     = buf_doc-line.artic
        and buf_goods.prod-type = buf_doc-line.prod-type
        and buf_goods.prod-code = buf_doc-line.prod-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка поиска товара" skip
        "Товар" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
        'serial=request':u skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,input  'twounit=request':u
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
      undo, return error .
    end.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,input  'bottle=request':u
  ,output l-goods-bottle
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
        'bottle=request':u skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if  buf_trn-doc.doc-type = 'при':U
    and buf_trn-doc.internal = false
    then do:
      if buf_trn-doc.flag_ = no
      then do:
        assign
          l-fact-qnty = false
        .
      end.
      else do:
        assign
          l-fact-qnty = true
        .
      end.
    end.
    else do:
      define variable conf-par as character no-undo .
      define variable par-type as character no-undo .
      define variable lok      as logical no-undo .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  buf_doc-line.obj-type
  ,input  buf_doc-line.obj-code
  ,input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,input  'place-rsrv=request'
  ,output l-reserv-pl-code
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении атрибута товара на объекте" skip
          "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          "place-rsrv=request" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      if l-reserv-pl-code
      then do:
        return
          "Товар на объекте резервируется по складским местам" + chr(10)
          + "Создание партий запрещено " + chr(10)
          + "Объект " + string(buf_doc-line.obj-type)
              + " " + string(buf_doc-line.obj-code) + chr(10)
          + "Артикул " + string(buf_doc-line.artic)
              + " " + string(buf_doc-line.prod-type)
              + " " + string(buf_doc-line.prod-code) + chr(10)
          .
      end.
      if buf_trn-doc.ext-doc-type = 'im':U
      then do:
      end.
      else do:
        conf-par  =  v-negparts .
        if buf_trn-doc.ext-doc-type = 're':U
        or buf_trn-doc.ext-doc-type = 'rs':U
        or buf_trn-doc.ext-doc-type = 'vt':U
        or buf_trn-doc.ext-doc-type = 'vp':U
        then do:
          if conf-par = "disable"
          or buf_goods.negative-rest = false
          then do:
            if v-prompt-price = 'prompt=enable':u and v-izlcstpr <> 'izlcstpr=enable':u
            then do:
              assign
                l-need-create-old-return = true
              .
            end.
          end.
        end.
        else do:
          if conf-par = "disable"
          then do:
            return
              "Порождение отрицательных партий для объекта "
              + string(buf_doc-line.obj-type) + " " + string(buf_doc-line.obj-code)
              + " запрещено (negparts)"
              .
          end.
          if buf_goods.negative-rest = false
          then do:
            return
              "Для товара " + string(buf_doc-line.artic)
              + " " + string(buf_doc-line.prod-type)
              + " " + string(buf_doc-line.prod-code)
              + " запрещены отрицательные остатки"
              .
          end.
        end.
      end.
      if buf_trn-doc.ext-doc-type = 'ep':U
      then do:
        return
          "Недопустимо создавать порожденные партии для данного типа документа"
          .
      end.
      if buf_trn-doc.ext-doc-type = 'em':U
      or buf_trn-doc.ext-doc-type = 'wm':U
      then do:
        conf-par = v-negmanuf.
        if conf-par = "disable"
        then do:
          return
            "Для документа производства порождение отрицательных партий для объекта "
            + string(buf_doc-line.obj-type) + " " + string(buf_doc-line.obj-code)
            + " запрещено (negmanuf)"
            .
        end.
      end.
      define variable v-reason as character no-undo .
      run partscr_check-valid-supp in this-procedure
        (input  p-supp-type
        ,input  p-supp-code
        ,input
        ( if buf_trn-doc.doc-type = 'при':U then buf_trn-doc.cli-type else buf_trn-doc.obj-type )
        ,input
        ( if buf_trn-doc.doc-type = 'при':U then buf_trn-doc.cli-code else buf_trn-doc.obj-code )
        ,input  buf_trn-doc.ext-doc-type
        ,output l-create-old-return
        ,output v-reason
        ).
      if v-reason <> ""
      then do:
        return
          v-reason
          .
      end.
      if l-goods-serial = true
      then do:
        if not(buf_trn-doc.doc-type = 'при':U
              and buf_trn-doc.internal = false
              and v-prompt-price = 'prompt=disable-create':u
              )
        then do:
          return
            "Порождение партий серийного товара допустимо только во внешнем приходе в интерфейсе партий."
            .
        end.
      end.
      if l-goods-twounit = true
      then do:
        if l-create-old-return
        then do:
          if l-create-old-return
          then do:
            assign
              p-cli-qnty = 1
            .
          end.
        end.
        else do:
          return
            "Для товара с двумя единицами измерения допустимо создание партий во внешнем приходе или партий старого возврата"
            .
        end.
      end.
      if buf_trn-doc.doc-type = 'инв':U
      then do:
        assign
          l-fact-qnty = false
        .
      end.
      else do:
        if buf_trn-doc.doc-type = 'при':U
        and buf_trn-doc.internal = true
        and buf_trn-doc.discnt-type = 'прво':U
        then do:
          assign
            l-fact-qnty = false
          .
        end.
        else do:
          if buf_trn-doc.status_ = 'разрешен':U
          or (buf_trn-doc.doc-type = 'при':U
              and buf_trn-doc.internal = true
            )
          then do:
            assign
              l-fact-qnty = true
            .
          end.
          else do:
            assign
              l-fact-qnty = false
            .
          end.
        end.
      end.
    end.
    find buf_parts
      where buf_parts.obj-type  = buf_doc-line.obj-type
        and buf_parts.obj-code  = buf_doc-line.obj-code
        and buf_parts.artic     = buf_doc-line.artic
        and buf_parts.prod-type = buf_doc-line.prod-type
        and buf_parts.prod-code = buf_doc-line.prod-code
        and buf_parts.in-code   = buf_doc-line.doc-code
        and buf_parts.out-code  = buf_doc-line.doc-code
        and buf_parts.part-code = p-part-code
      no-error.
    if not available buf_parts
    then do:
      assign
        v-action = ""
      .
      if  ( buf_trn-doc.doc-type = 'при':U
            and buf_trn-doc.internal = false
          )
      or  ( buf_trn-doc.doc-type = 'при':U
            and buf_trn-doc.internal = true
            and buf_trn-doc.discnt-type = 'прво':U
          )
      then do:
        assign
          v-action = "exit":u
        .
      end.
      else do:
        if v-check-right = true
        then do:
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  p-db-num
    ,input  p-user-id
    ,input  0
    ,input  'actn_parts_createneg':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_doc-line.obj-type
    ,input  buf_doc-line.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output lok
    )  .
end.
          if lok <> true
          then do:
            return "Отсутствуют права на создание порожденных партий" .
          end.
        end.
        if l-need-create-old-return
        or l-create-old-return
        then do:
        end.
        else do:
          define variable v-parameter-name as character no-undo .
          define variable v-document-name  as character no-undo .
          if p-part-reserv-base = 0
          or p-part-reserv-rubl = 0
          then do:
            run trg/partplas.p
              (input  buf_doc-line.obj-type
              ,input  buf_doc-line.obj-code
              ,input  buf_goods.gds-code
              ,input  buf_trn-doc.base-rate
              ,input  buf_trn-doc.base-scale
              ,output p-part-reserv-base
              ,output p-part-reserv-rubl
              ) .
          end.
          if buf_trn-doc.discnt-type = 'касс':U
          then do:
            assign
              v-action         = "exit":u
              v-document-name  = "продажи"
            .
            if  p-part-reserv-base = 0
            and p-part-reserv-rubl = 0
            then do:
              assign
                v-parameter-name = 'prcshrs0':U
                conf-par  = v-prcshrs0
              .
            end.
            else do:
              assign
                v-parameter-name = 'prcshrs1':U
                conf-par  = v-prcshrs1
              .
            end.
          end.
          else do:
            assign
              v-action         = ""
              v-document-name  = "документа"
            .
            if  p-part-reserv-base = 0
            and p-part-reserv-rubl = 0
            then do:
              assign
                v-parameter-name = 'prdocrs0':U
                conf-par  = v-prdocrs0
              .
            end.
            else do:
              assign
                v-parameter-name = 'prdocrs1':U
                conf-par  = v-prdocrs1
              .
            end.
          end.
          if conf-par = ""
          or conf-par = ?
          then do:
            assign
              conf-par = "disable"
            .
          end.
          case conf-par :
            when "disable"
            then do:
              return
                "Для " + v-document-name + " " + buf_doc-line.doc-code + " порождение отрицательных партий для объекта "
                + string(buf_doc-line.obj-type) + " " + string(buf_doc-line.obj-code)
                + " c учетной ценой "
                + ( if p-part-reserv-base <> 0 then "не равной 0" else "равной 0")
                + " запрещено." + chr(10)
                + "Параметр " + v-parameter-name + "=" + conf-par + "."
                .
            end.
            when "enable"
            then do:
              assign
                v-action = "exit":u
              .
            end.
            when "prompt"
            then do:
              if v-prompt-price = 'prompt=disable-reject':u
              then do:
                return
                  "Требуется ручное редактирование партий" + chr(10)
                  + "В данном режиме резервирования ручное редактирование невозможно" + chr(10)
                  + "Параметр " + v-parameter-name + "=" + conf-par + "." + chr(10)
                  .
              end.
              assign
                v-action = ""
              .
            end.
            when "manual"
            then do:
              if v-prompt-price = 'prompt=disable-reject':u
              then do:
                return
                  "Требуется ручное редактирование партий" + chr(10)
                  + "В данном режиме резервирования ручное редактирование невозможно" + chr(10)
                  + "Параметр " + v-parameter-name + "=" + conf-par + "." + chr(10)
                  .
              end.
              assign
                v-action = "chg":u
              .
            end.
            otherwise do:
              message
                vss-workfile vss-revision vss-description skip
                "Неизвестное значение параметра" v-parameter-name skip
                "conf-par" conf-par skip
                view-as alert-box error .
              return
                "Неизвестное значение параметра " + v-parameter-name
                + " conf-par = " + conf-par
                .
            end.
          end.
        end.
      end.
      if l-need-create-old-return
      then do:
        assign
          v-action = "chg":u
        .
      end.
      if v-prompt-price = 'prompt=disable-create':u
      then do:
        assign
          v-action = "exit":u
        .
      end.
      if v-action = ""
      then do:
        assign
          v-action = "exit":u
        .
        run trg/in-price.w
          (input parparentproc
          ,input-output p-part-reserv-base
          ,input-output p-part-reserv-rubl
          ,output v-action
          ,input  buf_doc-line.obj-type
          ,input  buf_doc-line.obj-code
          ,input  buf_doc-line.artic
          ,input  buf_doc-line.prod-type
          ,input  buf_doc-line.prod-code
          ,input  p-supp-type
          ,input  p-supp-code
          ,input  buf_trn-doc.base-rate
          ,input  buf_trn-doc.base-scale
          ,input  p-change-qnty
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при запросе учетной цены" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          return error .
        end.
      end.
      case v-action :
        when "chg":u
        then do:
          run str/partsedt.p
            (input parparentproc
            ,buffer buf_doc-line
            ,input  true
            ,input  false
            ,input  p-change-qnty
            ) no-error .
          if error-status :error
          then do:
            if error-status :get-message(1) <> ""
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при редактировании партий" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
            end.
            undo, return error .
          end.
        end.
        when "exit":u
        then do:
          define variable v-doc-num    like ub.price-list.doc-num    no-undo .
          define variable v-price-sale like ub.price-list.price-sale no-undo .
          define variable v-road-tax   like ub.price-list.road-tax   no-undo .
          define variable v-excise     like ub.price-list.excise     no-undo .
          if  buf_trn-doc.doc-type = 'при':U
          and buf_trn-doc.internal = false
          then do:
          end.
          else do:
            if l-goods-bottle
            then do:
              define variable v-gds-code    like ub.goods.gds-code  no-undo .
              define variable v-root-b-code like ub.bar-code.b-code no-undo .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,output v-gds-code
  )  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  v-gds-code
  ,input  ?
  ,output v-root-b-code
  )  .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf_doc-line.obj-type
  ,input  buf_doc-line.obj-code
  ,input  v-root-b-code
  ,input  v-root-b-code
  ,input  0
  ,output v-doc-num
  ,output v-price-sale
  ,output v-road-tax
  ,output v-excise
  ) no-error .
              if v-price-sale = ?
              then do:
                return
                  "Для товара " + string(buf_doc-line.artic)
                  + " " + string(buf_doc-line.prod-type)
                  + " " + string(buf_doc-line.prod-code)
                  + " типа стеклопосуда не задана продажная цена"
                  .
              end.
            end.
            else do:
              assign
                v-road-tax = 0
                v-excise   = 0
              .
            end.
          end.
          define variable v-curr-r-b as character no-undo .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
          if p-dop = "" or p-dop = ? then do:
             if buf_trn-doc.ext-doc-type = 'ie':U then do:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,output v-gds-code
  )  .
                define variable  v-dop1 as character no-undo .
                define variable  v-dop2 as character no-undo .
                run lineattr-value in this-procedure (
                    input   buf_trn-doc.doc-code  ,
                    input   v-gds-code  ,
                    input   'price-prod':U ,
                    output  v-dop1      ,
                    output  v-type )
                    no-error .
                run lineattr-value in this-procedure (
                    input   buf_trn-doc.doc-code  ,
                    input   v-gds-code  ,
                    input   'price-prodvat':U ,
                    output  v-dop2   ,
                    output  v-type )
                    no-error .
                    p-dop = substitute("&1;&2" , v-dop1, v-dop2) .
             end.
             if p-dop = ? then p-dop = "" .
          end.
          create buf_parts .
          assign
            buf_parts.obj-type       = buf_doc-line.obj-type
            buf_parts.obj-code       = buf_doc-line.obj-code
            buf_parts.artic          = buf_doc-line.artic
            buf_parts.prod-type      = buf_doc-line.prod-type
            buf_parts.prod-code      = buf_doc-line.prod-code
            buf_parts.in-code        = buf_doc-line.doc-code
            buf_parts.out-code       = buf_doc-line.doc-code
            buf_parts.part-code      = p-part-code
            buf_parts.cst-code       = p-cst-code
            buf_parts.pl-code        = p-pl-code
            buf_parts.ps             = p-ps
            buf_parts.dop            = p-dop
            buf_parts.doc-type       = buf_trn-doc.doc-type
            buf_parts.status_        = no
            buf_parts.qnty           = 0
            buf_parts.fact-qnty      = 0
            buf_parts.cli-qnty       = 0
            buf_parts.real-qnty      = 0
            buf_parts.transport-base = 0
            buf_parts.transport-rubl = 0
            buf_parts.other-base     = 0
            buf_parts.other-rubl     = 0
            buf_parts.supp-type      = p-supp-type
            buf_parts.supp-code      = p-supp-code
            buf_parts.host-code      = buf_trn-doc.host-code
            buf_parts.last-date      = p-last-date
            buf_parts.hold-date      = p-hold-date
            buf_parts.vat-type       = p-vat-type
            buf_parts.vat-pc         = p-vat-pc
            buf_parts.slt-type       = p-slt-type
            buf_parts.slt-pc         = p-slt-pc
            buf_parts.contract-code  = buf_trn-doc.contract-code
          .
          if buf_trn-doc.ext-doc-type = 'ie':U
          or buf_trn-doc.ext-doc-type = 'im':U
          then do:
            if buf_trn-doc.ext-doc-type = 'ie':U
            then do:
              assign
                buf_parts.is-supp       = yes
              .
            end.
            else do:
              assign
                buf_parts.is-supp       = no
              .
            end.
            assign
              buf_parts.rsrv-free     = ?
              buf_parts.pay-code      = buf_trn-doc.pay-code
              buf_parts.purch-code    = buf_trn-doc.purch-code
              buf_parts.exch-code     = buf_trn-doc.exch-code
              buf_parts.cli-base-rate = buf_doc-line.cli-base-rate
              buf_parts.price-cli     = buf_doc-line.price-cli
              buf_parts.price-base    = buf_doc-line.price-base
              buf_parts.price-rubl    = buf_doc-line.price-rubl
            .
            if v-curr-r-b = 'base':U
            then do:
              assign
                buf_parts.road-tax-base = buf_doc-line.road-tax
              .
              assign
                buf_parts.road-tax-rubl = buf_parts.road-tax-base
                                        * buf_trn-doc.base-rate
                                        / buf_trn-doc.base-scale
              .
            end.
            else do:
              assign
                buf_parts.road-tax-rubl = buf_doc-line.road-tax
              .
              assign
                buf_parts.road-tax-base = buf_parts.road-tax-rubl
                                        / buf_trn-doc.base-rate
                                        * buf_trn-doc.base-scale
              .
            end.
            if  l-goods-twounit = false
            and buf_trn-doc.ext-doc-type = 'ie':U
            then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_in-vat in g#lib-trn
  (
   input   buf_trn-doc.doc-code
  ,input   buf_trn-doc.base-rate
  ,input   buf_trn-doc.base-scale
  ,input   buf_trn-doc.exch-rate
  ,input   buf_trn-doc.exch-scale
  ,input   buf_trn-doc.vat-type
  ,input   buf_trn-doc.slt-type
  ,input   buf_parts.artic
  ,input   buf_parts.prod-type
  ,input   buf_parts.prod-code
  ,input   buf_parts.price-cli
  ,input   buf_parts.cli-base-rate
  ,input   buf_parts.price-rubl
  ,input   buf_parts.vat-pc
  ,input   buf_parts.slt-pc
  ,input   buf_doc-line.road-tax
  ,input   buf_parts.transport-rubl
  ,input   buf_parts.other-rubl
  ,output  v-price-cli
  ,output  v-price-cli-unit-base
  ,output  v-price-road-tax
  ,output  v-price-other-exp
  ,output  v-price-transport-exp
  ,output  v-price-without-abs
  ,output  v-price-slt
  ,output  v-price-no-slt
  ,output  v-price-vat
  ,output  v-price-no-vat-slt
  ,output  v-price-rubl
  ,output  v-price-road-tax-rubl
  ,output  v-price-other-exp-rubl
  ,output  v-price-transport-exp-rubl
  ,output  v-price-without-abs-rubl
  ,output  v-price-slt-rubl
  ,output  v-price-no-slt-rubl
  ,output  v-price-vat-rubl
  ,output  v-price-no-vat-slt-rubl
  ,output  v-price-base
  ,output  v-price-road-tax-base
  ,output  v-price-other-exp-base
  ,output  v-price-transport-exp-base
  ,output  v-price-without-abs-base
  ,output  v-price-slt-base
  ,output  v-price-no-slt-base
  ,output  v-price-vat-base
  ,output  v-price-no-vat-slt-base
  ) no-error.
              if error-status :error
              then do:
                return error "Ошибка при пересчете линии документа".
              end.
              assign
                buf_parts.price-cli  = v-price-cli
                buf_parts.price-rubl = v-price-rubl
                buf_parts.price-base = v-price-base
              .
            end.
          end.
          else do:
            define variable v-curr-r-b-code as integer no-undo .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run r-b-curr in g#library
  (input  buf_trn-doc.host-code
  ,output v-curr-r-b-code
  ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры basecode.i" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            assign
              buf_parts.rsrv-free     = (if can-do('рас,спи':U, buf_trn-doc.doc-type)
                                          or (can-do('инв':U, buf_trn-doc.doc-type)
                                              and (buf_parts.qnty + p-change-qnty) < 0
                                              )
                                        then yes
                                        else no
                                      )
              buf_parts.is-supp       = ( if l-create-old-return then yes else no )
              buf_parts.pay-code      = buf_trn-doc.pay-code
              buf_parts.purch-code    = integer('1':U)
              buf_parts.price-base    = p-part-reserv-base
              buf_parts.price-rubl    = p-part-reserv-rubl
              buf_parts.road-tax-base = 0
              buf_parts.road-tax-rubl = 0
              buf_parts.cli-base-rate = buf_doc-line.cli-base-rate
              buf_parts.exch-code     = 0
              buf_parts.price-cli     = buf_parts.price-rubl
            .
          end.
          validate buf_parts .
        end.
        when "quit":u
        then do:
        end.
      end case .
    end.
    if available buf_parts
    then do:
      if l-fact-qnty
      then do:
        assign
          buf_parts.fact-qnty = buf_parts.fact-qnty + p-change-qnty
        .
      end.
      else do:
        assign
          buf_parts.qnty      = buf_parts.qnty + p-change-qnty
          buf_parts.fact-qnty = buf_parts.qnty
        .
        if buf_trn-doc.doc-type = 'инв':U
        then do:
          assign
            buf_parts.rsrv-free     = ( if buf_parts.qnty < 0
                                        then true
                                        else false
                                      )
          .
        end.
      end.
      if l-goods-twounit = true
      then do:
        if p-cli-qnty <> 0
        then do:
          assign
            buf_parts.cli-qnty = p-cli-qnty
          .
          assign
            buf_parts.cli-base-rate = buf_parts.qnty / buf_parts.cli-qnty
          .
        end.
      end.
      else do:
        if buf_parts.cli-base-rate <> 0
        then do:
          assign
            buf_parts.cli-qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
          .
        end.
        else do:
          assign
            buf_parts.cli-qnty = 0
          .
        end.
        if abs(buf_parts.cli-qnty - p-cli-qnty) < 0.0011
        then do :
          assign
            buf_parts.cli-qnty = p-cli-qnty
          .
        end .
      end.
      if l-goods-twounit = false
      then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run qntycalc in g#library
  (input  'cli-qnty'
  ,input  buf_parts.cli-base-rate
  ,input  buf_parts.cli-qnty
  ,input  buf_parts.qnty
  ,output buf_parts.cli-qnty
  ,output buf_parts.qnty
  ) no-error .
        if error-status :error
        then do:
          message
            "Невозможно пересчитать количество по ТТН" skip
            "Документ" buf_parts.out-code skip
            'Артикул':U buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
            "Партия" + string(buf_parts.part-code) skip
            return-value skip
            view-as alert-box .
          undo, return error .
        end.
      end.
      if l-goods-serial
      then do:
        if  buf_parts.qnty <> 0
        and buf_parts.qnty <> 1
        then do:
          message
            "Товар серийный." skip
            "Невозможно порождение партии с количеством, отличным от 1."
            view-as alert-box .
          undo, return error .
        end.
      end.
    end.
    return .
  end.
end procedure.
procedure partscr_check-valid-supp :
  define input parameter  p-supp-type         like ub.parts.supp-type no-undo .
  define input parameter  p-supp-code         like ub.parts.supp-code no-undo .
  define input parameter  p-trn-doc-supp-type like ub.parts.supp-type no-undo .
  define input parameter  p-trn-doc-supp-code like ub.parts.supp-code no-undo .
  define input parameter  p-extended-doc-type as character no-undo .
  define output parameter p-old-return        as logical no-undo .
  define output parameter p-reason            as character no-undo .
  assign
    p-old-return = false
    p-reason     = ""
  .
  if p-supp-type <> p-trn-doc-supp-type
  or p-supp-code <> p-trn-doc-supp-code
  then do:
    if p-extended-doc-type = 're':U
    or p-extended-doc-type = 'rs':U
    or p-extended-doc-type = 'vt':U
    or p-extended-doc-type = 'vp':U
    then do:
      if p-supp-type = 'чел':U
      or p-supp-type = 'орг':U
      then do:
        assign
          p-old-return = true
        .
      end.
      else do:
        assign
          p-reason = "Поставщиком партии старого возврата может быть только человек или организация"
        .
        return .
      end.
    end.
    else do:
      assign
        p-reason = "Поставщиком порожденной партии может быть только объект документа"
      .
      return .
    end.
  end.
  return .
end procedure.
procedure partscr_get-default-values :
  define parameter buffer buf_doc-line for ub.doc-line .
  define output parameter p-vat-type   as character no-undo .
  define output parameter p-vat-pc     as decimal   no-undo .
  define output parameter p-slt-type   as character no-undo .
  define output parameter p-slt-pc     as decimal   no-undo .
  define buffer buf_trn-doc for ub.trn-doc .
  define buffer buf_goods for ub.goods .
  define variable v-vat-pc as decimal   no-undo .
  define variable v-host-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if not available buf_doc-line
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не задана строка документа" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = buf_doc-line.doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден документ" skip
        "Код документа" buf_doc-line.doc-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    find first buf_goods no-lock
      where buf_goods.artic     = buf_doc-line.artic
        and buf_goods.prod-type = buf_doc-line.prod-type
        and buf_goods.prod-code = buf_doc-line.prod-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка поиска товара" skip
        "Товар" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if buf_trn-doc.ext-doc-type = 'ie':U
    or buf_trn-doc.ext-doc-type = 'im':U
    then do:
      assign
        p-vat-type = buf_trn-doc.vat-type
        p-vat-pc   = buf_doc-line.vat-pc
        p-slt-type = buf_trn-doc.slt-type
        p-slt-pc   = buf_doc-line.slt-pc
      .
    end.
    else do:
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_doc-line.obj-type
  ,input  buf_doc-line.obj-code
  ,output v-host-code
  )  .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-host-code
  ,input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,output v-vat-pc
  ) no-error .
      assign
        p-vat-type = 'в т. ч.':U
        p-vat-pc   = v-vat-pc
        p-slt-type = 'без':U
        p-slt-pc   = 0
      .
    end.
  end.
end procedure.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table gds-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define variable v-vat-type as character no-undo.
define variable v-vat-pc as decimal no-undo.
define variable v-slt-type as character no-undo.
define variable v-slt-pc as decimal no-undo.
define variable v-doc-pl-rowid as rowid no-undo.
define variable varchg-inv as logical no-undo.
define variable v-cntxt-rsrv-time as integer no-undo.
define variable v-cntxt-load-time as integer no-undo.
define variable v-cntxt-holidays as character no-undo.
define variable v-wrkr    as integer no-undo .
define variable v-agnt    as integer no-undo .
define variable v-boss    as integer no-undo .
define buffer buf_clients for ub.clients.
define buffer buf-spis_trn-doc for ub.trn-doc.
define buffer buf-spis_doc-line for ub.doc-line.
define buffer buf-new_doc-line for ub.doc-line.
define buffer buf_parts for ub.parts.
define buffer buf_goods for ub.goods.
define buffer buf_pl-gds for ub.pl-gds.
define buffer buf-new_doc-pl for ub.doc-pl.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_sale-gds-dtl for ub.gds-dtl.
define buffer buf_spis-gds-dtl for ub.gds-dtl.
define buffer buf-new_sale-gds-dtl for ub.gds-dtl.
run doc-code in this-procedure (input "chip",
                                input buf-sale_trn-doc.obj-type,
                                input buf-sale_trn-doc.obj-code,
                                input buf-sale_trn-doc.doc-code,
                                output p-doc-code) no-error.
find first buf_clients where buf_clients.obj-type = p-cli-type
                         and buf_clients.obj-code = p-cli-code no-lock.
find first buf_sale-gds-dtl where buf_sale-gds-dtl.doc-code = buf-sale_doc-line.doc-code
                              and buf_sale-gds-dtl.artic = buf-sale_doc-line.artic
                              and buf_sale-gds-dtl.prod-code = buf-sale_doc-line.prod-code
                              and buf_sale-gds-dtl.prod-type = buf-sale_doc-line.prod-type no-lock.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crtrndoc in g#lib-trn
(input ?
,input ?
,input buf-sale_trn-doc.base-rate
,input buf-sale_trn-doc.base-scale
,input buf_clients.obj-code
,input buf_clients.obj-type
,input buf_clients.obj-name
,input buf-sale_trn-doc.cr-db-num
,input g#userid
,input ''
,input p-doc-code
,input buf-sale_trn-doc.doc-date
,input 'при':U
,input buf-sale_trn-doc.flag
,input buf-sale_trn-doc.host-code
,input false
,input buf-sale_trn-doc.obj-code
,input buf-sale_trn-doc.obj-type
,input false
,input buf-sale_trn-doc.pay-code
,input 'ПН для продажи природного газа'
,input false
,input 'без':U
,input 'накл':U
,input 'в т. ч.':U
,input 'ie':U
,input 1
) no-error
.
find first buf-new_trn-doc where buf-new_trn-doc.doc-code = p-doc-code exclusive-lock.
assign
buf-new_trn-doc.out-code = buf-sale_trn-doc.doc-code
buf-new_trn-doc.fact-date  = buf-sale_trn-doc.fact-date
buf-new_trn-doc.shift-date = buf-sale_trn-doc.shift-date
buf-new_trn-doc.shift-num  = buf-sale_trn-doc.shift-num
buf-new_trn-doc.shift-name = buf-sale_trn-doc.shift-name
buf-new_trn-doc.base-rate = buf-sale_trn-doc.base-rate
buf-new_trn-doc.base-scale = buf-sale_trn-doc.base-scale
buf-new_trn-doc.exch-scale = buf-sale_trn-doc.exch-scale
buf-new_trn-doc.exch-rate = buf-sale_trn-doc.exch-rate
buf-new_trn-doc.pay-code = buf-sale_trn-doc.pay-code
buf-new_trn-doc.tot-lines = 1
buf-new_trn-doc.tot-doc = buf_sale-gds-dtl.price-base * buf_sale-gds-dtl.fact-qnty
buf-new_trn-doc.tot-fact = buf_sale-gds-dtl.price-base * buf_sale-gds-dtl.fact-qnty
buf-new_trn-doc.tot-rubl = buf_sale-gds-dtl.price-base * buf_sale-gds-dtl.fact-qnty
buf-new_trn-doc.tot-sale = buf_sale-gds-dtl.price-base * buf_sale-gds-dtl.fact-qnty
buf-new_trn-doc.tot-cli = buf_sale-gds-dtl.price-base * buf_sale-gds-dtl.fact-qnty
buf-new_trn-doc.tot-calc = buf_sale-gds-dtl.price-base * buf_sale-gds-dtl.fact-qnty.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crdoclin in g#lib-trn
(input buf-new_trn-doc.doc-code
,input buf-sale_doc-line.artic
,input buf-sale_doc-line.prod-type
,input buf-sale_doc-line.prod-code
,input buf-new_trn-doc.obj-type
,input buf-new_trn-doc.obj-code
,input ''
,input buf-new_trn-doc.ext-doc-type
,input buf-sale_doc-line.prt-root
,input buf-sale_doc-line.vat-pc
,input buf-sale_doc-line.slt-pc
,input buf-sale_doc-line.cons-vat-pc
) no-error
.
find first buf-new_doc-line where buf-new_doc-line.doc-code = buf-new_trn-doc.doc-code  exclusive-lock.
find first buf_goods where buf_goods.artic = buf-new_doc-line.artic
                       and buf_goods.prod-type = buf-new_doc-line.prod-type
                       and buf_goods.prod-code = buf-new_doc-line.prod-code no-lock.
find first buf_pl-gds where buf_pl-gds.obj-type = buf-new_trn-doc.obj-type
                        and buf_pl-gds.obj-code = buf-new_trn-doc.obj-code
                        and buf_pl-gds.gds-code = buf_goods.gds-code
                        and buf_pl-gds.status_ = 'тек':U no-lock.
assign
buf-new_doc-line.fact-density = buf-sale_doc-line.fact-density
buf-new_doc-line.cli-qnty = buf-sale_doc-line.fact-qnty * buf-sale_doc-line.fact-density
buf-new_doc-line.fact-qnty = buf-sale_doc-line.fact-qnty
buf-new_doc-line.doc-qnty = buf-sale_doc-line.fact-qnty
buf-new_doc-line.price-rubl = buf_sale-gds-dtl.price-rubl
buf-new_doc-line.price-base = buf_sale-gds-dtl.price-base
buf-new_doc-line.price-cli = buf_sale-gds-dtl.price-base / buf-sale_doc-line.fact-density
buf-new_doc-line.unit-cli = buf_goods.unit-cli
buf-new_doc-line.cli-base-rate = 1 / buf-sale_doc-line.fact-density
buf-new_doc-line.doc-density = buf-sale_doc-line.doc-density.
for each buf-spis_trn-doc no-lock where buf-spis_trn-doc.out-code = buf-sale_trn-doc.doc-code
                                    and buf-spis_trn-doc.ext-doc-type = 'we':U :
  find first buf-spis_doc-line exclusive-lock where buf-spis_doc-line.doc-code = buf-spis_trn-doc.doc-code
                                         and buf-spis_doc-line.artic = buf-sale_doc-line.artic
                                         and buf-spis_doc-line.prod-type = buf-sale_doc-line.prod-type
                                         and buf-spis_doc-line.prod-code = buf-sale_doc-line.prod-code
                                         and rowid(buf-spis_doc-line) <> rowid(buf-sale_doc-line)
                                         no-error .
  if available buf-spis_doc-line
  then do :
    assign
      buf-new_doc-line.cli-qnty = buf-new_doc-line.cli-qnty + buf-spis_doc-line.fact-qnty * buf-spis_doc-line.fact-density
      buf-new_doc-line.fact-qnty = buf-new_doc-line.fact-qnty + buf-spis_doc-line.fact-qnty
      buf-new_doc-line.doc-qnty = buf-new_doc-line.doc-qnty + buf-spis_doc-line.fact-qnty
    .
    assign
      buf-new_trn-doc.tot-cli = buf-new_trn-doc.tot-cli + buf_sale-gds-dtl.price-base * buf-spis_doc-line.fact-qnty
    .
  end.
end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crdocpl in g#lib-trn
(input  buf-new_trn-doc.doc-code
,input  buf_goods.gds-code
,input  buf_pl-gds.pl-code
,input  buf-new_trn-doc.obj-type
,input  buf-new_trn-doc.obj-code
,output v-doc-pl-rowid
) no-error
.
find first buf-new_doc-pl where rowid(buf-new_doc-pl) = v-doc-pl-rowid exclusive-lock.
assign
buf-new_doc-pl.doc-qnty = buf-new_doc-line.doc-qnty
buf-new_doc-pl.fact-qnty = buf-new_doc-line.fact-qnty
buf-new_doc-pl.cli-qnty = buf-new_doc-line.cli-qnty
buf-new_doc-pl.cli-doc-qnty = buf-new_doc-line.cli-qnty
buf-new_doc-pl.cli-fact-qnty = buf-new_doc-line.cli-qnty
buf-new_doc-pl.out-code = buf-new_doc-line.doc-code.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  buf-new_doc-line.artic
  ,input  buf-new_doc-line.prod-type
  ,input  buf-new_doc-line.prod-code
  ,output p-root-node
  )  .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crgdsdtl in g#lib-trn
  ( input buf-new_trn-doc.obj-code
   ,input buf-new_trn-doc.obj-type
   ,input buf-new_trn-doc.doc-code
   ,input buf-new_doc-line.artic
   ,input buf-new_doc-line.prod-code
   ,input buf-new_doc-line.prod-type
   ,input p-root-node
   ,input false
  )  .
find first buf-new_sale-gds-dtl where buf-new_sale-gds-dtl.doc-code = p-doc-code exclusive-lock.
assign
buf-new_sale-gds-dtl.price-base = buf-new_doc-line.price-base
buf-new_sale-gds-dtl.price-rubl = buf-new_doc-line.price-rubl
buf-new_sale-gds-dtl.doc-qnty = buf-new_doc-line.doc-qnty
buf-new_sale-gds-dtl.fact-qnty = buf-new_doc-line.fact-qnty.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION set-sale-doc-PS returns character( buffer buf_sale-doc for ub.sale-doc):
define variable v-ps as character no-undo .
if available buf_sale-doc then
assign
v-PS = substitute('&1&2 &1&3&1Кол-во_чеков &4&1строк_чеков &5&1товаров &6&1признаков &7&1'
                    , chr(4)
                    , (if buf_sale-doc.chr-office = 'у':U then "УСЛУГИ." else "ТОВАРЫ." )
                    , entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )
                    , buf_sale-doc.chk-amount
                    , buf_sale-doc.gds-amount
                    , buf_sale-doc.tot-lines
                    , buf_sale-doc.tot-dtl
                    ).
else  do:
assign
v-PS = substitute('&1&2 &1&3&1Кол-во_чеков &4&1строк_чеков &5&1товаров &6&1признаков &7&1'
                    , chr(4)
                    , '':U
                    , entry (lookup ('es':U, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )
                    , 0
                    , 0
                    , 0
                    , 0
                    ).
end.
return v-ps.
END FUNCTION.
FUNCTION get-sale-doc-kind returns character (
                                             input p-doc-kind as character
                                           , input p-ext-doc-type as character
                                           , output p-order as integer
                                           , output p-msign as integer
                                           , output p-main as logical
                                           , output p-in-inkas as logical
                                           , output p-dir_ as integer
                                           ):
define variable v-doc-kind as character no-undo.
define variable v-type as character no-undo .
define variable v-value as character no-undo .
CASE p-doc-kind:
  when 'es':U then do:
    assign
    p-order = 100
    p-msign = 1
    p-main = yes
    p-in-inkas = yes
    p-dir_ = 1
    .
    return p-ext-doc-type.
  end.
  when  'rs':U then do:
    assign
    p-order = 200
    p-msign = - 1
    p-main = no
    p-in-inkas = yes
    p-dir_ = - 1
    .
    return p-ext-doc-type.
  end.
  when 'rwo':U then do:
    assign
    p-msign = - 1
    p-main = no
    p-in-inkas = no
    p-order = 300
    p-dir_ = 1
    .
    return 'rwo':U.
  end.
  when 'trf':U then do:
    assign
    p-msign = 1
    p-main = no
    p-in-inkas = no
    p-order = 400
    p-dir_ = 1
    .
    return 'trf':U.
  end.
  when 'swo':U then do:
   assign
   p-msign = 1
   p-main = no
   p-in-inkas = no
   p-order =  500
   p-dir_ = 1
   .
   return 'swo':U.
 end.
 when 'vir':U then do:
   assign
   p-msign = 1
   p-main = no
   p-in-inkas = no
   p-order = 600
   p-dir_ = 1
   .
   return 'vir':U.
 end.
 when 'itr':U then do:
   assign
   p-msign = 1
   p-main = no
   p-in-inkas = no
   p-order = -1
   p-dir_ = -1
   .
  return 'itr':U.
 end.
 when 'ngs':U then do:
   assign
   p-msign = 1
   p-main = no
   p-in-inkas = no
   p-order = 700
   p-dir_ = 1
   .
   return 'ngs':U.
 end.
 when 'rgs':U then do:
   assign
   p-msign = -1
   p-main = no
   p-in-inkas = no
   p-order = 701
   p-dir_ = -1
   .
   return 'rgs':U.
 end.
 otherwise do:
    assign
    p-msign = 1
    p-main = no
    p-in-inkas = no
    p-order = -1.
    return p-ext-doc-type.
  end.
END CASE.
END FUNCTION.
procedure saledoc-create :
define input parameter p-inkas-code like ub.inkas.inkas-code no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-obj-code  like ub.clients.obj-code no-undo .
define input parameter p-doc-kind as character no-undo .
define input parameter p-office as character no-undo .
define input parameter p-tpsidoc as logical no-undo .
define input parameter p-alias-type-price as character no-undo .
define input parameter p-price-obj-type as character no-undo .
define input parameter p-price-obj-code as integer no-undo .
define parameter buffer buf_trn-doc for ub.trn-doc.
define variable v-order as integer no-undo.
define variable v-main as logical no-undo .
define variable v-in-inkas as logical no-undo .
define variable v-msign as integer no-undo .
define variable v-dir_ as integer no-undo .
define variable v-trn-doc-code as character no-undo .
define buffer buf_sale-doc for ub.sale-doc.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
   if available buf_trn-doc then do:
     v-trn-doc-code = buf_trn-doc.doc-code.
   end.
   find first buf_sale-doc where
            buf_sale-doc.inkas-code = p-inkas-code
        and buf_sale-doc.doc-kind = p-doc-kind
        and buf_sale-doc.chr-office = p-office
        and (v-trn-doc-code = '' or buf_sale-doc.doc-code = v-trn-doc-code)
        no-error .
   if not available buf_sale-doc  then do:
      create buf_sale-doc.
      assign
      buf_sale-doc.inkas-code = p-inkas-code
      buf_sale-doc.storage =  'trn-doc':U
      buf_sale-doc.host-code = p-host-code
      buf_sale-doc.obj-type = p-obj-type
      buf_sale-doc.obj-code = p-obj-code
      buf_sale-doc.doc-kind  = p-doc-kind
      buf_sale-doc.order = lookup(p-doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U) * 100 + (if p-office = 'у':U then 5 else 0)
      buf_sale-doc.chr-office = p-office
      buf_sale-doc.doc-code = v-trn-doc-code
      .
   end.
   if available buf_trn-doc then
   buffer-copy buf_trn-doc
   to buf_sale-doc
   .
  assign
  buf_sale-doc.doc-kind = get-sale-doc-kind (
                                             input p-doc-kind
                                            ,input buf_sale-doc.ext-doc-type
                                            ,output v-order
                                            ,output v-msign
                                            ,output v-main
                                            ,output v-in-inkas
                                            ,output v-dir_).
  assign
  buf_sale-doc.order = v-order + (if p-office = 'у':U then 5 else 0)
  buf_sale-doc.main-doc = v-main
  buf_sale-doc.in-inkas = v-in-inkas
  buf_sale-doc.msign = v-msign
  buf_sale-doc.dir = v-dir_
  buf_sale-doc.fbrsale = lookup(buf_sale-doc.doc-kind, 'es,swo':U) > 0
  buf_sale-doc.main-receipt-type = integer(entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U) + 1, '0,1,6,96,17,69,17,17':U))
  buf_sale-doc.poss-wro-codes = '':U
  buf_sale-doc.chr-office = p-office
  buf_sale-doc.tpsidoc = p-tpsidoc
  buf_sale-doc.alias-type-price = p-alias-type-price
  buf_sale-doc.price-obj-type = (if p-tpsidoc
                                 then p-price-obj-type
                                 else '':U)
  buf_sale-doc.price-obj-code = (if p-tpsidoc
                                 then p-price-obj-code
                                 else 0)
  .
  assign
  buf_sale-doc.poss-wro-codes = (if (v-order > 0 and buf_sale-doc.doc-kind <> 'vir':U) then entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U) + 1, '0,2,-2,-6;-3;-9;-4,17,1;3':U) else '':U)
  no-error.
end.
END.
procedure fbr-saledoc-create :
define input parameter p-inkas-code as character no-undo .
define variable v-pri-prvo-doc-qnty like ub.trn-doc.doc-qnty no-undo .
define variable v-pri-prvo-fact-qnty like ub.trn-doc.doc-qnty no-undo .
define variable v-pri-prvo-tot-lines like ub.trn-doc.tot-lines no-undo .
define buffer buf_fbr-doc for ub.fbr-doc.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_sale-doc for ub.sale-doc.
define buffer buf2_sale-doc for ub.sale-doc.
define buffer buf2_trn-doc for ub.trn-doc.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_chk-doc for ub.chk-doc.
do
on error undo, return error
:
  for each buf_fbr-doc no-lock where
        buf_fbr-doc.out-code = p-inkas-code:
    for each buf_trn-doc no-lock where
          buf_trn-doc.out-code = buf_fbr-doc.doc-code
    by buf_trn-doc.fact-order
    on error undo, return error:
      if buf_trn-doc.ext-doc-type = 'em':U
      or buf_trn-doc.ext-doc-type = 'im':U
      or buf_trn-doc.ext-doc-type = 'wm':U
      or buf_trn-doc.ext-doc-type = 'ev':U
      or buf_trn-doc.ext-doc-type = 'iv':U
      then do:
        find first buf_sale-doc where
                buf_sale-doc.inkas-code = p-inkas-code
            and buf_sale-doc.doc-code = buf_trn-doc.doc-code
            AND buf_sale-doc.storage  = 'trn-doc':U
                no-error .
        if not available buf_sale-doc then do:
        create buf_sale-doc.                                                                                             buffer-copy buf_trn-doc                                                                                             to buf_sale-doc.                                                                                                assign                                                                                                                  buf_sale-doc.storage  =  'trn-doc':U                                                                          buf_sale-doc.doc-kind = buf_trn-doc.ext-doc-type                                                                buf_sale-doc.order =  - 1                                                                                          buf_sale-doc.main-doc = no                                                                                             buf_sale-doc.in-inkas = no                                                                                         buf_sale-doc.fbrsale = yes                                                                                         buf_sale-doc.msign = 1                                                                                             buf_sale-doc.filled   = buf_sale-doc.fact-qnty <> 0 or buf_sale-doc.tot-lines <> 0                       buf_sale-doc.doc-qnty = (if buf_sale-doc.ext-doc-type = 'pc':U                                                           then ?                                                                                                                  else buf_sale-doc.doc-qnty)                                                          buf_sale-doc.fact-qnty = (if buf_sale-doc.ext-doc-type = 'pc':U                                                          then ?                                                                                                                  else buf_sale-doc.fact-qnty)                                                        buf_sale-doc.inkas-code = p-inkas-code.
        end.
        if buf_trn-doc.ext-doc-type = 'im':U then do:
          assign
          v-pri-prvo-doc-qnty = buf_trn-doc.doc-qnty
          v-pri-prvo-fact-qnty = buf_trn-doc.fact-qnty
          v-pri-prvo-tot-lines = buf_trn-doc.tot-lines
          .
        end.
        for each buf2_trn-doc no-lock where
                buf2_trn-doc.out-code = buf_sale-doc.doc-code:
          find first buf2_sale-doc where
                  buf2_sale-doc.inkas-code = p-inkas-code
              and buf2_sale-doc.doc-code = buf2_trn-doc.doc-code
              AND buf2_sale-doc.storage = 'trn-doc':U no-error .
          if not available buf2_sale-doc then do:
            create buf2_sale-doc.                                                                                             buffer-copy buf2_trn-doc                                                                                             to buf2_sale-doc.                                                                                                assign                                                                                                                  buf2_sale-doc.storage  =  'trn-doc':U                                                                          buf2_sale-doc.doc-kind = buf2_trn-doc.ext-doc-type                                                                buf2_sale-doc.order =  - 1                                                                                          buf2_sale-doc.main-doc = no                                                                                             buf2_sale-doc.in-inkas = no                                                                                         buf2_sale-doc.fbrsale = yes                                                                                         buf2_sale-doc.msign = 1                                                                                             buf2_sale-doc.filled   = buf2_sale-doc.fact-qnty <> 0 or buf2_sale-doc.tot-lines <> 0                       buf2_sale-doc.doc-qnty = (if buf2_sale-doc.ext-doc-type = 'pc':U                                                           then ?                                                                                                                  else buf2_sale-doc.doc-qnty)                                                          buf2_sale-doc.fact-qnty = (if buf2_sale-doc.ext-doc-type = 'pc':U                                                          then ?                                                                                                                  else buf2_sale-doc.fact-qnty)                                                        buf2_sale-doc.inkas-code = p-inkas-code.
          end.
        end.
      end.
    end.
    find first buf_sale-doc where
              buf_sale-doc.inkas-code = p-inkas-code
          AND buf_sale-doc.storage = 'fbr-doc':U
          AND buf_sale-doc.doc-code = buf_fbr-doc.doc-code no-error .
    if not available buf_sale-doc then do:
      create buf_sale-doc.
      assign
      buf_sale-doc.storage       =  'fbr-doc':U
      buf_sale-doc.doc-type      = 'производство':U
      buf_sale-doc.doc-code      = buf_fbr-doc.doc-code
      buf_sale-doc.ext-doc-type  = 'производство':U
      buf_sale-doc.doc-kind      = 'производство':U
      buf_sale-doc.obj-type      = buf_fbr-doc.obj-type
      buf_sale-doc.obj-code      = buf_fbr-doc.obj-code
      buf_sale-doc.cli-type      = buf_fbr-doc.obj-type
      buf_sale-doc.cli-code      = buf_fbr-doc.obj-code
      buf_sale-doc.doc-qnty      = v-pri-prvo-doc-qnty
      buf_sale-doc.fact-qnty     = v-pri-prvo-fact-qnty
      buf_sale-doc.tot-lines     = v-pri-prvo-tot-lines
      buf_sale-doc.tot-dtl       = v-pri-prvo-tot-lines
      buf_sale-doc.fbrsale       = yes
      buf_sale-doc.inkas-code    = p-inkas-code
      .
    end.
  end.
end.
end procedure.
run saledoc-create in this-procedure (
    input p-inkas-code,
    input buf-sale_trn-doc.host-code,
    input buf-sale_trn-doc.obj-type,
    input buf-sale_trn-doc.obj-code,
    input 'ngs':U,
    input 'т':U,
    input no,
    input '':U,
    input '':U,
    input 0,
    buffer buf-new_trn-doc) no-error.
find first buf_sysconf where buf_sysconf.host-code = buf-new_trn-doc.host-code no-lock.
assign
v-cntxt-rsrv-time = buf_sysconf.rsrv-time
v-cntxt-load-time = buf_sysconf.load-time
v-cntxt-holidays = buf_sysconf.holidays.
run partscr_get-default-values in this-procedure (buffer buf-new_doc-line,
                                                  output v-vat-type,
                                                  output v-vat-pc,
                                                  output v-slt-type,
                                                  output v-slt-pc).
run partscr in this-procedure
      (input  parparentproc,
       input  buf-new_trn-doc.cr-db-num,
       input  g#userid,
       input
        ( if buf-new_trn-doc.doc-type = 'при':U then buf-new_trn-doc.cli-type else buf-new_trn-doc.obj-type )
 ,
       input
        ( if buf-new_trn-doc.doc-type = 'при':U then buf-new_trn-doc.cli-code else buf-new_trn-doc.obj-code )
 ,
       input  '':U,
       input  '':U,
       input  '':U,
       input  '':U,
       input  buf-new_doc-line.price-base,
       input  buf-new_doc-line.price-rubl,
       input  v-vat-type,
       input  v-vat-pc,
       input  v-slt-type,
       input  v-slt-pc,
       input  buf-new_doc-line.fact-qnty,
       input  "prompt=disable-create",
       input  buf-new_doc-line.cli-qnty,
       input  ?,
       input  ?,
       input  buf_pl-gds.pl-code,
       buffer buf-new_doc-line,
       buffer buf_parts) no-error.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_calc-in in g#lib-trn
( input parparentproc  ,
  input recid(buf-new_trn-doc)  ,
  input this-procedure   )
no-error.
buf-new_trn-doc.tot-calc = buf-new_trn-doc.tot-cli .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input buf-new_trn-doc.doc-code ,
                       input 'is-auto-trn':U ,
                       input yes ) no-error .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input buf-new_trn-doc.doc-code ,
                       input 'is-fuel':U ,
                       input yes ) no-error .
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input buf-new_trn-doc.obj-type
  ,input buf-new_trn-doc.obj-code
  ,input 'autosale':U
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
  if thbjattr_thbj-attr.prop-code = 'wrkr':U then assign v-wrkr = thbjattr_thbj-attr.property-value-integer .
  if thbjattr_thbj-attr.prop-code = 'agnt':U then assign v-agnt = thbjattr_thbj-attr.property-value-integer .
  if thbjattr_thbj-attr.prop-code = 'boss':U then assign v-boss = thbjattr_thbj-attr.property-value-integer .
end.
assign
  buf-new_trn-doc.wrkr  = v-wrkr
  buf-new_trn-doc.agnt  = v-agnt
  buf-new_trn-doc.boss  = v-boss
.
run str/trn-stat.p (
    input parparentproc,
    input this-procedure,
    input '<закрытие документа на факт>':U ,
    input buf-new_trn-doc.doc-code,
    input false,
    input g#db-num,
    input false,
    input v-cntxt-rsrv-time,
    input v-cntxt-load-time,
    input v-cntxt-holidays,
    input false,
    output varchg-inv,
    output table gds-list) no-error.
if error-status:error then  message error-status:get-message(1) skip return-value view-as alert-box warning.
