block-level on error undo, throw.
define input parameter parrvs-code like ub.rvs-doc.rvs-code no-undo.
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: clcavrgs.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: utl/clcavrgs.p $":U .
define variable vss-description as character no-undo initial "Утилита по пересчету веса по средней плотности".
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
procedure clcavrgd:
define input parameter parrvs-code like ub.rvs-doc.rvs-code no-undo.
define buffer bf_rvs-doc    for ub.rvs-doc.
define buffer bf_rvs-line   for ub.rvs-line.
define buffer bf_goods      for ub.goods.
define buffer prev_rvs-line for ub.rvs-line.
define buffer prev_rvs-doc  for ub.rvs-doc.
define variable varsystem-cli-avrg-qnty like ub.rvs-line.system-cli-avrg-qnty no-undo.
define variable vardensity like ub.rvs-line.density no-undo.
find first bf_rvs-doc where bf_rvs-doc.rvs-code = parrvs-code no-error.
if not available bf_rvs-doc then return error "Неверный номер документа сверки(clcavrgd)".
for each bf_rvs-line where bf_rvs-line.rvs-code = bf_rvs-doc.rvs-code exclusive,
    first bf_goods where bf_goods.gds-code = bf_rvs-line.gds-code break by bf_rvs-line.gds-code on error undo, return error return-value :
    if first-of(bf_rvs-line.gds-code) then do:
       run str/avrgdens.p (input  bf_rvs-doc.obj-type,
                       input  bf_rvs-doc.obj-code,
                       input  bf_rvs-doc.shift-date,
                       input  bf_rvs-doc.shift-num,
                       input  bf_rvs-line.gds-code,
                       input  bf_rvs-doc.rvs-code,
                       input  no,
                       output vardensity) no-error.
       if error-status:error or
          vardensity = ?     then do:
          undo, return error.
       end.
    end.
    if bf_rvs-line.rvs-prev-code <> ? then do:
       find first prev_rvs-line where prev_rvs-line.rvs-code = bf_rvs-line.rvs-prev-code and
                                      prev_rvs-line.obj-type = bf_rvs-line.obj-type      and
                                      prev_rvs-line.obj-code = bf_rvs-line.obj-code      and
                                      prev_rvs-line.pl-code  = bf_rvs-line.pl-code       and
                                      prev_rvs-line.gds-code = bf_rvs-line.gds-code      no-lock no-error.
       if not available prev_rvs-line then do:
          undo, return error SUBSTITUTE
          ("Не найдена строка документа сверки с № &1 на которую имеет ссылку строка по складскому месту &2 товару &3 &4 &5 &6 .",
           bf_rvs-line.rvs-prev-code,
           bf_rvs-line.pl-code,
           bf_goods.artic,
           bf_goods.prod-type,
           bf_goods.prod-code,
           bf_goods.gds-name).
       end.
       find first prev_rvs-doc where prev_rvs-doc.rvs-code = prev_rvs-line.rvs-code No-LOCK No-ERROR.
       if not available prev_rvs-doc then do:
          undo, return error SUBSTITUTE
          ("Не найден документ сверки с № &1 на который имеет ссылку строка по складскому месту &2 товару &3 &4 &5 &6 .",
           bf_rvs-line.rvs-prev-code,
           bf_rvs-line.pl-code,
           bf_goods.artic,
           bf_goods.prod-type,
           bf_goods.prod-code,
           bf_goods.gds-name).
       end.
    end.
    else do:
       if bf_rvs-doc.rvs-type = 'смена':U then
          undo, return error SUBSTITUTE
         ("По складскому месту &1 товару &2 &3 &4 &5 нет ссылки на предыдущую сверку.",
          bf_rvs-line.pl-code,
          bf_goods.artic,
          bf_goods.prod-type,
          bf_goods.prod-code,
          bf_goods.gds-name).
   end.
   run calc_avrg_stock (input  bf_rvs-doc.shift-date,
                        input  bf_rvs-doc.shift-num,
                        input  bf_rvs-doc.obj-type,
                        input  bf_rvs-doc.obj-code,
                        input  bf_rvs-line.pl-code,
                        input  bf_rvs-line.gds-code,
                        input  vardensity,
                        output varsystem-cli-avrg-qnty) no-error.
   if error-status:error then do:
      undo, return error substitute ("Ошибка при расчета остатка по средней плотности &1.",return-value) .
   end.
   ASSIGN bf_rvs-line.system-cli-avrg-qnty =
          (if available prev_rvs-line then prev_rvs-line.system-cli-avrg-qnty else 0) + varsystem-cli-avrg-qnty.
   if bf_rvs-line.system-cli-avrg-qnty = ? then return error SUBSTITUTE
   ("Невозможно рассчитать вес по средней плотности для резервуара &1 товара &2 &3 &4 &5 .",
   bf_rvs-line.pl-code,
   bf_goods.artic,
   bf_rvs-line.obj-type,
   bf_rvs-line.obj-code,
   bf_goods.gds-name).
end.
end procedure.
procedure calc_avrg_stock:
define input  parameter parshift-date            like ub.rvs-doc.shift-date           no-undo.
define input  parameter parshift-num             like ub.rvs-doc.shift-num            no-undo.
define input  parameter parobj-type              like ub.rvs-doc.obj-type             no-undo.
define input  parameter parobj-code              like ub.rvs-doc.obj-code             no-undo.
define input  parameter parpl-code               like ub.rvs-line.pl-code             no-undo.
define input  parameter pargds-code              like ub.rvs-line.gds-code            no-undo.
define input  parameter pardensity               like ub.rvs-line.density             no-undo.
define output parameter parsystem-cli-avrg-qnty  like ub.rvs-doc.system-cli-avrg-qnty no-undo.
define buffer bf_trn-doc  for ub.trn-doc.
define buffer bf_doc-line for ub.doc-line.
define buffer bf_doc-pl   for ub.doc-pl.
define buffer bf_goods    for ub.goods.
find first bf_goods where bf_goods.gds-code = pargds-code no-lock.
for each bf_trn-doc where bf_trn-doc.obj-type   = parobj-type   and
                          bf_trn-doc.obj-code   = parobj-code   and
                          bf_trn-doc.shift-date = parshift-date and
                          bf_trn-doc.shift-num  = parshift-num  and
                          bf_trn-doc.status_    = 'факт':U       no-lock,
    first bf_doc-line where bf_doc-line.doc-code  = bf_trn-doc.doc-code and
                            bf_doc-line.artic     = bf_goods.artic      and
                            bf_doc-line.prod-type = bf_goods.prod-type  and
                            bf_doc-line.prod-code = bf_goods.prod-code  no-lock,
          first bf_doc-pl where bf_doc-pl.out-code = bf_trn-doc.doc-code and
                                bf_doc-pl.gds-code = pargds-code         and
                                bf_doc-pl.obj-type = parobj-type         and
                                bf_doc-pl.obj-code = parobj-code         and
                                bf_doc-pl.pl-code  = parpl-code:
    if lookup (bf_trn-doc.ext-doc-type, 'ie,re,iv,rv,im,io':U) > 0 then do:
       if bf_trn-doc.ext-doc-type = 'ie':U then do:
          assign parsystem-cli-avrg-qnty = parsystem-cli-avrg-qnty + bf_doc-line.fact-density * bf_doc-pl.fact-qnty.
       end.
       else
          assign parsystem-cli-avrg-qnty = parsystem-cli-avrg-qnty + pardensity * bf_doc-pl.fact-qnty.
    end.
    else do:
       if lookup (bf_trn-doc.ext-doc-type, 'ee,ep,es,rs,we,vt,vp,ap,mp,pc,ev,em,wm,eo':U) > 0 then do:
          if lookup (bf_trn-doc.ext-doc-type, 'vt,vp,rs':U) > 0 then do:
             assign parsystem-cli-avrg-qnty = parsystem-cli-avrg-qnty + pardensity * bf_doc-pl.fact-qnty.
          end.
          else do:
             assign parsystem-cli-avrg-qnty = parsystem-cli-avrg-qnty - pardensity * bf_doc-pl.fact-qnty.
          end.
       end.
       else return error SUBSTITUTE
       ("Документ &1. Расширенный тип документа &2. Невозможно определить, реализация или поступление.",
       bf_trn-doc.doc-code,
       bf_trn-doc.ext-doc-type).
    end.
end.
end procedure.
do
on error undo, return error return-value
:
  define buffer bf_rvs-doc  for ub.rvs-doc.
  define buffer bf_rvs-line for ub.rvs-line.
  find first bf_rvs-doc
    where bf_rvs-doc.rvs-code = parrvs-code no-error
    .
  if not available bf_rvs-doc
  then do:
    message
      "Ошибка входных параметров" skip
      view-as alert-box error .
    return error.
  end.
  run clcavrgd
    (input bf_rvs-doc.rvs-code
    ) no-error .
  if error-status :error then do:
    return error .
  end.
end.
