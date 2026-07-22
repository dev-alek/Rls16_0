block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Импорт спецификации

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/14/10
Author: Bakhtadze Natalya
Creation date: 07/14/10

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-cont-handle  as handle no-undo .
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-call-id as character no-undo .
define input parameter p-order-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-is-dynamic as logical no-undo .
define input parameter p-doc-type as character no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-doc-code as character no-undo .
define input parameter p-process-file-name as character no-undo .
define input parameter p-save       as integer no-undo .
define input parameter v-curr-r-b   as character no-undo .
define input parameter p-cmd-proc-handle as handle no-undo .
define input parameter p-cmd-code  as integer no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Импорт спецификации".
{ cmp/vssrevis.i }


{ cmp/trg-def.i }
{ cmp/library.i }
{ str/libbcrcn.i }
{ gbl/key-rec.i }
{ rul/ruleset_.i }
{ str/cntspcie.i }
{ str/specattr.i } /*write-bonus*/
{ ref/spegrpmt.i } /*recalc-gds-SpecGr*/
{ str/contrcth.i }

define variable file-name as character no-undo .
define variable p-delimiter as character no-undo.
define variable p-start-row as integer no-undo.

define variable log-file-name                as character      no-undo init "process-edoc.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-rid                        as recid          no-undo .


define stream InStream.
{ gbl/dyneximp.i Instream }
define stream logstream .
define variable ss as char format "X(3000)".
/*для раскладки строчки*/
define variable my-mess as char.
/*вспомогат*/
define variable num-rec as integer.
define variable num-rec-ok as integer.
define variable num-rec-process as integer.
define variable num-rec-process-ok as integer.
define variable v-return-value as character no-undo .
define variable v-db-num like ub.db.db-num no-undo .
define variable varscales-pref as character no-undo .
define variable varpgscales-pref as character no-undo .
define variable varscales-pref-type as character no-undo.
define variable v-ask as logical no-undo .
define variable v-write-hist as logical no-undo .
define variable v-order as character no-undo .
define variable v-bar-code as integer no-undo .
define variable v-error as logical no-undo .
define variable v-create as logical no-undo .

define variable glog as logical no-undo .
define variable v-mess as character no-undo .
define variable v-cntspcie as handle no-undo .
define variable v-current-host-code as integer no-undo .
define variable v-contract-code as integer no-undo .
define variable parresult   as character                no-undo .
define variable partype-bc  as character                no-undo .
define variable parweight   as decimal                  no-undo .
define variable v-fin-vat-pc as decimal no-undo .
define variable v-create-ext-artic as logical no-undo .
define variable v-contract-cli-type as character no-undo .
define variable v-contract-cli-code as integer no-undo .
DEFINE VARIABLE i AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE cTmpBK AS CHARACTER NO-UNDO INITIAL "".
/*  */
define buffer buf_prod-bc  for ub.prod-bc.
define buffer buf_bar-code  for ub.bar-code.
define buffer buf_place for ub.place.
define buffer buf_goods for ub.goods.
define buffer buf_contract for ub.contract.
define buffer buf_contract-specif for ub.contract-specif.
define buffer buf_ext-artic for ub.ext-artic.
define buffer tmpl_cntspcie for cntspcie.
define shared temp-table tt0-rule-call-param no-undo like ub.rule-call-param.
define buffer buf_rule-call-param for tt0-rule-call-param.

&scop display-message ~
      run write-log-and-file in p-log-handle ( ~
            input 1 ~
          , input log-file-name ~
          , input 1 ~
          , input ~{&my-message~})



&scop view-log   ~{ str/cdviewlg.i   ~
                    "'!!!При импорте информации произошли ошибки!!!'" ~
                    "'process-edoc.txt'" ~}   ~
                    return


run load-ruleset-context in this-procedure ( input p-ruleset-id) no-error.
if error-status:error then do:
  &scop my-message substitute("Ошибка при подготовке к импорту данных в спецификацию:&1&2&1&3" ~
                           , ~{&new-line~} ~
                           , error-status:get-message(1)  ~
                           , return-value )
  {&display-message}.
  v-view-log = yes.
  {&view-log}.
end.
if p-ruleset-id = {&edoc-proc_18_text-import_specif_224} then do:
  define variable v-end-new-line as logical no-undo .
  run gbl/filnline.p ( input file-name
                      ,output v-end-new-line) no-error.
  if error-status:error
  or not v-end-new-line then do:
    &scop my-message substitute("Ошибка при проверке наличия пустой строки в конце файла импорта&1&2" ~
                          , ~{&new-line~} ~
                          , return-value)
    {&display-message}.
    assign
    v-view-log = yes.
    {&view-log}.
  end.
end.

v-cntspcie = buffer cntspcie:handle.
create cntspcie.
v-cntspcie:buffer-field("has-line-num"):buffer-value = yes.
  for each buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-fields"
and buf_rule-call-param.p-index > 0
by buf_rule-call-param.p-index
:
  v-order = v-order + (if v-order = '' then '' else {&comma-char}) + entry(2, buf_rule-call-param.param-value-character, ".").
  v-cntspcie:buffer-field( substitute("has-&1", entry(2, buf_rule-call-param.param-value-character, "."))):buffer-value = yes.
end.
v-cntspcie:buffer-release().
run write-log  in p-log-handle (
                                 input 0
                               , "&DLine").
  &scop my-message substitute("Чтение данных из файла &1", file-name)
  {&display-message}.
if p-ruleset-id = {&edoc-proc_18_text-import_specif_224} then do:
  if p-delimiter = {&space-char} then do:
    /*файл имеет тип progress dump - строки окавычены*/
    input stream Instream from value(file-name).
    run dyneximp_dump-import in this-procedure (
                                                 input v-cntspcie
                                                ,input v-order
                                                ,input '' /*p-except-field-list */
                                                ,input "line-num"
                                                ,input this-procedure:handle
                                                ,input "cb_err"
                                                ,output num-rec
                                                ,output num-rec-ok
                                                ) no-error.
   if error-status:error then do:
    input stream InStream close.
    &scop my-message substitute("Ошибка при чтении данных из файла &1:&2&3&2&4" ~
                              , file-name ~
                              , ~{&new-line~} ~
                              , error-status:get-message(1)  ~
                              , return-value ~
                              )
    {&display-message}.
    v-error = yes.
    {&view-log}.
   end.
   input stream InStream close.
  end.
  else do:
    input stream Instream from value(file-name).
  /*файл имеет тип unformatted - строки не окавычены - в строках НЕ МОЖЕТ СОДЕРЖАТЬСЯ РАЗДЕЛИТЕЛЬ*/
    _stroka:
    REPEAT ON ERROR UNDO _stroka, leave _stroka:
      ss = ''.
      import stream INstream
      UNFORMATTED
      ss
      .
      if ss = '' then leave  _stroka.
      v-cntspcie:buffer-create().
      v-cntspcie::line-num = num-rec + 1.
      num-rec = num-rec + 1.
      glog = dyneximp_import( input v-cntspcie
                            ,input p-delimiter
                            ,input ss
                            ,input v-order
                            ,input ""
                            ,output v-mess
                            ) no-error.
      if not glog then do:
        &scop my-message substitute("Строчка &1 не разобрана!&2&3" ~
                              ,num-rec ~
                              ,~{&new-line~} ~
                              ,v-mess)
        {&display-message}.
        v-view-log = yes.
        next _stroka.
      end.
      num-rec-ok = num-rec-ok + 1.
      run show-counter in p-log-handle .
      run write-counter in p-log-handle (substitute("Прочитано &1 из них успешно &2"
                                                  , num-rec
                                                  , num-rec-ok
                                                  )) no-error.
      run get-stop-state in p-log-handle (
          output v-stop
      ).
      if v-stop then do:
        leave _stroka.
      end.
    END. /*REPEAT*/
    input stream InStream close.
  end. /*else if p-delimiter = {&space-char} then do:*/
end. /*if p-ruleset-id = {&edoc-proc_18_text-import_specif_224} then do:*/
if p-ruleset-id = {&edoc-proc_18_excel-import_specif_226} then do:
  run dyneximp_import-excel in this-procedure (
                                              input file-name
                                             ,input p-start-row /*p-start-row */
                                             ,input v-cntspcie /*p-bh*/
                                             ,input v-order
                                             ,input '' /* p-except-field-list */
                                             ,input "line-num"
                                             ,input this-procedure:handle
                                             ,input "cb_err"
                                             ,output num-rec
                                             ,output num-rec-ok
                                             ) no-error.
   if error-status:error then do:
    &scop my-message substitute("Ошибка при чтении данных из файла &1:&2&3&2&4" ~
                              , file-name ~
                              , ~{&new-line~} ~
                              , error-status:get-message(1)  ~
                              , return-value ~
                              )
    {&display-message}.
    v-error = yes.
    {&view-log}.
   end.
end. /*if p-ruleset-id = {&edoc-proc_18_excel-import_specif_226} then do:*/
if v-stop then do:
  &scop my-mess substitute("Чтение данных для импорта  в спецификацию прервано пользователем")
  {&display-message}.
  v-view-log = yes.
  {&view-log}.
end.
&scop my-message substitute("Прочитано записей &1 из них успешно  &2", num-rec, num-rec-ok)
{&display-message}.


if not v-error then do:
  /*начинаем проверку и сохранение в БД*/
  &scop my-message substitute("Проверка и сохранение в БД ...")
  {&display-message}.
  find first tmpl_cntspcie where tmpl_cntspcie.line-num = 0.
  _save:
  for each cntspcie
    where cntspcie.line-num > 0
  on error  undo _save, retry
  on stop   undo _save, retry
  on endkey undo _save, retry
  :
    if retry then do:
      v-mess = substitute("&1 (строка &2)", v-mess, cntspcie.line-num).
      &scop my-message v-mess
      {&display-message}.
      v-view-log = yes.
      next _save.
    end.
    num-rec-process = num-rec-process + 1.
    if tmpl_cntspcie.has-artic then do:
      v-create-ext-artic = no.
      if cntspcie.artic = ''
      or cntspcie.artic = ?
      then do:
        v-mess =  substitute("Не задан артикул").
        undo _save, retry _save.
      end.
      if tmpl_cntspcie.has-prod-type then do:
        if cntspcie.prod-type = ''
        or cntspcie.prod-type = ?
        then do:
          v-mess =  substitute("Не задан тип производителя").
          undo _save, retry _save.
        end.
      end.
      if tmpl_cntspcie.has-prod-code then do:
        if cntspcie.prod-code = 0
        or cntspcie.prod-code = ?
        then do:
          v-mess =  substitute("Не задан код производителя").
          undo _save, retry _save.
        end.
      end.
      find buf_goods no-lock where
                buf_goods.artic = cntspcie.artic
            and ((not tmpl_cntspcie.has-prod-type and true)
                  or
                  buf_goods.prod-type = cntspcie.prod-type)
            and ((not tmpl_cntspcie.has-prod-code and true)
                  or
                  buf_goods.prod-code = cntspcie.prod-code)
      no-error.
      if not available buf_goods then do:
        if ambiguous buf_goods then do:
          v-mess =  substitute("Заданный артикул (&1) не уникален в системе - необходимо указать производителя"
                              , cntspcie.artic).
          undo _save, retry _save.
        end.
        else do:
          v-mess =  substitute("Не найден товар с артикулом &1 и производителем &2&3"
                                , cntspcie.artic
                                , cntspcie.prod-type
                                , cntspcie.prod-code
                              ).
          undo _save, retry _save.
        end.
      end.
      /*на всякий случай найдем баркод*/
      { gbl/gdsbcode.i buf_goods.gds-code ? v-bar-code }
      find first buf_bar-code no-lock where
                buf_bar-code.b-code = v-bar-code no-error.

    end.
    if tmpl_cntspcie.has-b-str then do:
      if cntspcie.b-str <> ?
       and cntspcie.b-str <> '' then
       do i = 1 TO NUM-ENTRIES(cntspcie.b-str):
          ASSIGN
             cTmpBK = ENTRY(i, cntspcie.b-str).
       /* #2095 Так как, в cntspcie.b-str может лежать список
          дополнительных бар кодов, - проверяем каждый из них   */
         { str/bc-rcnz.i
         parparentproc
           cTmpBK
         ?
         "''"
         ?
         no
         no
         varscales-pref
         varpgscales-pref
         parresult
         partype-bc
         parweight
         buf_bar-code
         buf_prod-bc
         buf_place
         no-error }
         /*  */
         if not available buf_bar-code then do:
             v-mess =  substitute("Не найден бар-код &1", cTmpBK).
            undo _save, retry _save.
         end.
       end.
    end.
    /*  */
    if tmpl_cntspcie.has-price-cli
    and (cntspcie.price-cli < 0
    or cntspcie.price-cli = ?) then do:
      v-mess =  substitute("Неверное значение цены поставщика (&1)", cntspcie.price-cli).
      undo _save, retry _save.
    end.
    if tmpl_cntspcie.has-prc
    and (cntspcie.prc < 0
        or
        cntspcie.prc = ?
        ) then do:
      v-mess =  substitute("Неверное значение отклонения в большую сторону (&1)", cntspcie.prc).
      undo _save, retry _save.
    end.
    if tmpl_cntspcie.has-vat-pc
    and (cntspcie.vat-pc < 0
        or
        cntspcie.vat-pc > 99
        or
        cntspcie.vat-pc = ?
        )
    then do:
      v-mess =  substitute("Неверное значение НДС (&1)", cntspcie.vat-pc).
      undo _save, retry _save.
    end.
    if tmpl_cntspcie.has-vat-type
    and (cntspcie.vat-type = ''
    or  lookup(cntspcie.vat-type, {&inc-vat} + {&comma-char} + {&no-vat} + {&comma-char} + {&without-vat}) = 0
    or cntspcie.vat-type = ?) then do:
      v-mess =  substitute("Неверное значение типа НДС (&1)", cntspcie.vat-type).
      undo _save, retry _save.
    end.
    if tmpl_cntspcie.has-bonus
  and (cntspcie.bonus < 0
        or
        cntspcie.bonus = ?
        or
        cntspcie.bonus > 100
        )
    then do:
      v-mess =  substitute("Неверное значение бонуса (&1)", cntspcie.bonus).
      undo _save, retry _save.
    end.
    if tmpl_cntspcie.has-ext-artic
    then do:
      /*пока внешний артикул ПРОСТО ЛЕЖИТ В ФАЙЛЕ ИМПОРТА - НО НЕ ИМПОРТИРУЕТСЯ!!! - Щелчков*/
      /*отсутствие внешнего артикула не должно вызывать ни ошибки ни предупреждения*/
      /*
      if cntspcie.ext-artic <> ''
      and cntspcie.ext-artic <> ? then do:
        find first buf_ext-artic no-lock where
                  buf_ext-artic.cli-type = v-contract-cli-type
              and buf_ext-artic.cli-code = v-contract-cli-code
              and buf_ext-artic.gds-code = buf_goods.gds-code no-error.
        if available buf_ext-artic
        and buf_ext-artic.ext-artic <> cntspcie.ext-artic then do:
          v-mess =  substitute("Значение внешнего артикула в строке импорта (&1) не совпадает с уже имеющимся в БД для данного поставщика", cntspcie.ext-artic).
          undo _save, retry _save.
        end.
        v-create-ext-artic = no.
      end.
      */
    end.
    if tmpl_cntspcie.has-prc-min
    and (cntspcie.prc-min < 0
        or
        cntspcie.prc-min = ?
        ) then do:
      v-mess =  substitute("Неверное значение отклонения в меньшую сторону (&1)", cntspcie.prc-min).
      undo _save, retry _save.
    end.
    v-create = no.
    do transaction :
      find first buf_contract-specif exclusive-lock
        where buf_contract-specif.host-code    = v-current-host-code
          and buf_contract-specif.contract-num = v-contract-code
          and buf_contract-specif.gds-code     = buf_bar-code.gds-code
      no-error .
      if not available  buf_contract-specif then do:
        find buf_goods no-lock where
            buf_goods.gds-code = buf_bar-code.gds-code no-error .
        if not available buf_goods then do:
          v-mess = substitute("В БД не найден товар для товара с кодом &1", buf_bar-code.gds-code).
          undo _save, retry _save.
        end.
        run  SpecGr-gds-code-yes in this-procedure (
                                                      input  buf_goods.gds-code
                                                      ,input  buf_goods.grp-code
                                                      ,input  v-contract-code
                                                      ,input  v-current-host-code
                                                      ,output v-ask        ) no-error .
        if error-status :error
        or v-ask = false  then do:
          v-mess =  substitute("Нельзя добавлять товар &1 &2 в Спецификацию из-за ограничения по ассортименту в группе"
                                      ,buf_goods.gds-code
                                      ,buf_goods.gds-name
                                      ).
          undo _save, retry _save.
        end.
        create buf_contract-specif .
        assign
        buf_contract-specif.host-code     = v-current-host-code
        buf_contract-specif.contract-num  = v-contract-code
        buf_contract-specif.gds-code      = buf_bar-code.gds-code
        buf_contract-specif.gds-name      = buf_goods.gds-name
        buf_contract-specif.artic         = buf_goods.artic
        buf_contract-specif.prod-type     = buf_goods.prod-type
        buf_contract-specif.prod-code     = buf_goods.prod-code
        buf_contract-specif.cli-base-rate = buf_bar-code.cli-base-rate
        buf_contract-specif.unit-cli      = buf_bar-code.unit-cli
        buf_contract-specif.unit-base     = buf_goods.unit-base
        buf_contract-specif.db-num        = g#db-num
        buf_contract-specif.vat-pc        = v-fin-VAT-pc
        buf_contract-specif.vat-type      = {&inc-VAT}
        .
        v-create = yes.
      end.
      /*  */
      assign
      buf_contract-specif.price-cli     = (if tmpl_cntspcie.has-price-cli
                                            then cntspcie.price-cli
                                            else buf_contract-specif.price-cli)
      buf_contract-specif.prc           = (if tmpl_cntspcie.has-prc
                                            then cntspcie.prc
                                            else buf_contract-specif.prc)
      buf_contract-specif.qnty          = (if tmpl_cntspcie.has-qnty
                                            then cntspcie.qnty
                                            else buf_contract-specif.qnty)
      buf_contract-specif.sum-cli       = buf_contract-specif.price-cli * buf_contract-specif.qnty
      /* Поскольку в спецификации поле количество qnty (DECIMAL), по умолчанию установлено в ?,
         то если в этом поле после загрузки из файла образовался 0 - меняем 0 на ?
      */
      buf_contract-specif.qnty = (if buf_contract-specif.qnty = 0 THEN ? ELSE buf_contract-specif.qnty)
      /*  */
      buf_contract-specif.VAT-type      = (if tmpl_cntspcie.has-vat-type
                                            then cntspcie.VAT-type
                                            else buf_contract-specif.VAT-type)
      buf_contract-specif.VAT-pc        = (if tmpl_cntspcie.has-vat-pc
                                            then cntspcie.VAT-pc
                                            else buf_contract-specif.VAT-pc)
      .
      if tmpl_cntspcie.has-bonus then do:
        run write-bonus in this-procedure ( input v-contract-code
                                            , input v-current-host-code
                                            , input buf_contract-specif.gds-code
                                            , input cntspcie.bonus
                                            ) no-error .
        if error-status:error then do:
          v-mess = substitute("Ошибка при записи бонусов после добавления/изменения спецификации&1&2&1&3"
                              , {&new-line}
                              , error-status:get-message(1)
                              , return-value ).
          undo _save, retry _save.
        end.
      end.
      if tmpl_cntspcie.has-prc-min then do:
        run write-prc-min in this-procedure ( input v-contract-code
                                            , input v-current-host-code
                                            , input buf_contract-specif.gds-code
                                            , input cntspcie.prc-min
                                            ) no-error .
        if error-status:error then do:
          v-mess = substitute("Ошибка при записи отклонения в меньшую сторону после добавления/изменения спецификации&1&2&1&3"
                              , {&new-line}
                              , error-status:get-message(1)
                              , return-value ).
          undo _save, retry _save.
        end.
      end.
      if v-create then do:
      run recalc-gds-SpecGr in this-procedure  (
            /* пересчет после удаления или внесения товара в Спецификацию */
              input  '+'
            ,input  buf_goods.grp-code
            ,input  v-contract-code
            ,input  v-current-host-code
            )
      no-error .
      if error-status:error then do:
        v-mess = substitute("Ошибка при пересчете после добавления/изменения спецификации&1&2&1&3"
                            , {&new-line}
                            , error-status:get-message(1)
                            , return-value ).
        undo _save, retry _save.
      end.
      end.
      num-rec-process-ok = num-rec-process-ok + 1.
      assign
      v-write-hist = yes.
    end. /*    do transaction :*/
  END. /*REPEAT :*/
  &scop my-message substitute("Из ранее прочитанных записей просмотрено &1, успешно импортировано &2", num-rec-process, num-rec-process-ok)
  {&display-message}.
  if v-write-hist then do:
    run contrcth_write-hist in this-procedure ( input v-current-host-code
                                              ,input v-contract-code) no-error.
  end.
end. /*if not v-error then do:*/
{&view-log}.


procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define buffer buf_rule-call-param for tt0-rule-call-param.
define buffer buf_contract for ub.contract.

do
on error undo, return error
:
/*---------------------------&start-process-rule-call-param&-------------------------------*/

  find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-delimiter"
 no-error.
if available buf_rule-call-param then do:
assign p-delimiter = buf_rule-call-param.param-value-character.
end.

  find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-start-row"
 no-error.
if available buf_rule-call-param then do:
assign p-start-row = buf_rule-call-param.param-value-integer.
end.



/*---------------------------&end-process-rule-call-param&-------------------------------*/
    case p-ruleset-id:
      when {&edoc-proc_18_text-import_specif_224}
      or
      when {&edoc-proc_18_excel-import_specif_226}
      then do:
        assign
        v-current-host-code = p-host-code
        v-contract-code = integer(p-doc-code)
        file-name  = p-process-file-name
        .
        find first buf_contract exclusive-lock where
                  buf_contract.host-code = v-current-host-code
              and buf_contract.contract-code = v-contract-code no-error.
        if not available  buf_contract then do:
           undo, return error substitute("Не найден договор № &1 (по фирме &2)", v-contract-code, v-current-host-code).
        end.
        assign
        v-contract-cli-type = buf_contract.cli-type
        v-contract-cli-code = buf_contract.cli-code
        .
      end.
      otherwise do:

      end.
    end case.
    assign
    file-name            = p-process-file-name
    .

    /*
    FIND FIRST ub.db WHERE ub.db.db-num = g#db-num NO-LOCK .
    if g#db-num = 0 then do:
      &scop my-message substitute("Импорт клиентов возможен только в ГБД", ~{&new-line~})
      {&display-message}.
      assign
      v-view-log = yes.
      {&view-log}.
    end.
    */
    define variable v-full-path        as character no-undo .
    define variable v-path             as character no-undo .
    define variable v-file-name        as character no-undo .
    define variable v-file-name-no-ext as character no-undo .
    define variable v-file-name-ext    as character no-undo .

    run gbl/filename.p (
                    input  file-name
                    ,output v-full-path
                    ,output v-path
                    ,output v-file-name
                    ,output v-file-name-no-ext
                    ,output v-file-name-ext
                    ) no-error .

    if error-status:error
    or v-full-path = ?
    or v-full-path = '':U
    then do:
      &scop my-message substitute("Не найден файл &1 для импорта спецификаций", file-name)
      {&display-message}.
      assign
      v-view-log = yes.
      {&view-log}.
    end.
    assign
    file-name = v-full-path.
    { str/sclspref.i varscales-pref varpgscales-pref }
  end. /*doe*/

end procedure. /* load-ruleset-context */

procedure cb_err :
define input parameter p-err-mess as character no-undo .

do
on error undo, return error
:
  &scop my-message p-err-mess
  {&display-message}.
  v-view-log = yes.
end.

end procedure. /* cb_err */