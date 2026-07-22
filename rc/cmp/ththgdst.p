block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ththgdst.p $
$Archive: cmp/ththgdst.p $

Получение данных по товарам из системы TH старой версии во временную таблицу

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/18/08
Author: Bakhtadze Natalya
Creation date: 12/18/08

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ththgdst.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cmp/ththgdst.p $":U .
define variable vss-description as character no-undo init "Получение данных по товарам из системы TH старой версии во временную таблицу".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ ref/extclass.i }
{ gbl/key-rec.i }
{ gbl/cur-time.i }
{ trg/factord.i }
{ cmp/thth150.i }
{ cmp/thth14.i }


define variable p-copy-option as character no-undo .
define variable p-gds-code as integer no-undo .
define variable p-rid-list as character no-undo .
define variable p-from-version as character no-undo .
define variable v-src-full-name as character no-undo .
define variable v-upper-code as integer no-undo .
define variable v-level as integer no-undo .
define variable v-counter as integer no-undo .
define variable v-rec as recid no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-ii as integer no-undo .
define variable v-ii-ok as integer no-undo .
define variable v-has-ss as logical no-undo .
define variable log-file-name as character no-undo .
define variable v-b-code as integer no-undo .
define variable v-classif-name as character no-undo .
define buffer src_code-range for src.code-range.
define buffer src_tax-rate for src.tax-rate.

{ cmp/ththgdst.i " shared "}

DEFINE BUFFER buf_ext-classif FOR ub.ext-classif.

&glob display-message  run write-log-and-file in p-log-handle ( ~
          input 1 ~
        , input log-file-name ~
        , input 1 ~
        , input ~{&my-message~} ~
                                      )

&glob display-count-message  run write-counter in p-log-handle (input ~{&my-count-message~})

&glob hide-count-message  run hide-counter in p-log-handle

log-file-name = substitute("&1.txt", entry(1, entry(num-entries(this-procedure:file-name, {&slash-char}), this-procedure:file-name, {&slash-char}), ".")).

if num-entries(p-parameter, {&delim-par}) <> 4 then do:
  message
  substitute("Неверное количество ENTRY в составном параметре - &1, должно быть 4"
             ,num-entries(p-parameter, {&delim-par}))
  view-as alert-box error .
  return.
end.
assign
p-copy-option = entry(1, p-parameter, {&delim-par} )
p-gds-code = integer(entry(2, p-parameter, {&delim-par} ))
p-rid-list =  entry(3, p-parameter, {&delim-par} )
p-from-version = entry(4, p-parameter, {&delim-par})
.

case p-from-version:
  when {&thth150-from-version} then do:
    assign
    v-classif-name = {&extclass_goods_th-th150}
    .
  end.
  when {&thth14-from-version} then do:
    assign
    v-classif-name = {&extclass_goods_th-th14}
    .
  end.
end case.


&scop my-message substitute("Копирование данных по товарам из БД &1 во временную таблицу...", p-from-version)
{&display-message}.

for each goods-01:
  delete goods-01.
end.
for each bar-code-01:
  delete bar-code-01.
end.
for each prod-bc-01:
  delete prod-bc-01.
end.
for each temp-tax-rate:
  delete temp-tax-rate.
end.
define variable v-tax-rate-value as decimal no-undo .
/*заполним налоги*/
for each src_tax-rate no-lock where
        src_tax-rate.tax-code = integer({&vat-tax-code})
     or src_tax-rate.tax-code = integer({&slt-tax-code})
        :
  v-ii = v-ii - 1.
  run pftaxval in this-procedure ( input ?
                                  ,input src_tax-rate.tax-code
                                  ,input src_tax-rate.rate-code
                                  ,input ? /*par-date*/
                                  ,input 0 /*p-host-code*/
                                  ,input '' /*p-obj-type*/
                                  ,input 0 /*p-obj-code*/
                                  ,output v-tax-rate-value) no-error.
  if not error-status:error then do:
    create temp-tax-rate.
    assign
    temp-tax-rate.tax-code = src_tax-rate.tax-code
    temp-tax-rate.rate-code = v-ii - 1
    temp-tax-rate.src-rate-code = src_tax-rate.rate-code
    temp-tax-rate.tax-rate-value = v-tax-rate-value
    .
    release temp-tax-rate.
  end.
end. /*for each src_tax-rate no-lock where*/
v-ii = 0.
find first src_code-range no-lock where
          src_code-range.range-type = {&loc-ss-code}
          or
          src_code-range.range-type = {&gbl-ss-code} no-error.
if available src_code-range then do:
  v-has-ss = yes.
end.

case p-copy-option:
  when 'one' then do:
    find first buf_ext-classif share-lock where
          buf_ext-classif.classif-subject = {&table_goods}
      and buf_ext-classif.classif-name = v-classif-name
      and buf_ext-classif.db-num = - 1
      and buf_ext-classif.key#_one = p-gds-code no-error.
    if not available buf_ext-classif then do:
      &scop my-message substitute("Не удалось определить текущую запись соответствия (товар с кодом &1 в БД &2)", p-gds-code, p-from-version)
      {&display-message}.
      return.
    end.
    if buf_ext-classif.uniq-key-rec <> '' then do:
      &scop my-message substitute("УЖЕ ЕСТЬ соответствие для товара с кодом &1 в БД &2 в текщуей БД - импортировать невозможно", p-gds-code, p-from-version)
      {&display-message}.
      return.
    end.
    run fill-container in this-procedure ( input buf_ext-classif.key#_one) no-error.
    if error-status:error then do:
      &scop my-message substitute("!!!Ошибка при копировании данных по товару с кодом &1 из БД &5 во временную таблицу&2&3&2&4" ~
                                      , buf_ext-classif.key#_one ~
                                      , ~{&new-line~} ~
                                      , error-status:get-message(1) ~
                                      , return-value   ~
                                      , p-from-version ~
                                      )
      {&display-message}.
    end.
  end. /*when 'one'*/
  when 'list' then do:
    _ii:
    do v-ii = 1 to num-entries(p-rid-list):
      if v-ii modulo 10 = 0 then do:
        &scop my-count-message substitute("Копирование данных по товарам из БД &3 во временную таблицу ... записей &1 удачно &2", v-ii, v-ii-ok, p-from-version)
        {&display-count-message}.
      end.
      find first buf_ext-classif share-lock where
               recid(buf_ext-classif) = integer(entry(v-ii, p-rid-list)) no-error.
      if not available buf_ext-classif then do:
        &scop my-message substitute("Не удалось определить текущую запись соответствия (recid &1)", integer(entry(v-ii, p-rid-list)))
        {&display-message}.
        next _ii.
      end.
      if buf_ext-classif.uniq-key-rec <> '' then do:
        &scop my-message substitute("УЖЕ ЕСТЬ соответствие для товара с кодом &1 в БД &2 в текущей БД - импортировать невозможно", buf_ext-classif.key#_one, p-from-version)
        {&display-message}.
        next _ii.
      end.
      run fill-container in this-procedure ( input buf_ext-classif.key#_one) no-error.
      if error-status:error then do:
        &scop my-message substitute("!!!Ошибка при копировании данных по товару с кодом &1 из БД &5 во временную таблицу&2&3&2&4" ~
                                        , buf_ext-classif.key#_one ~
                                        , ~{&new-line~} ~
                                        , error-status:get-message(1) ~
                                        , return-value  ~
                                        , p-from-version ~
                                        )
        {&display-message}.
      end.
      else do:
        v-ii-ok = v-ii-ok + 1.
      end.
    end.
  end. /*when 'list'*/
  when 'all' then do:
    for each buf_ext-classif share-lock where
            buf_ext-classif.classif-subject = {&table_goods}
        and buf_ext-classif.classif-name = v-classif-name
        and buf_ext-classif.db-num = - 1
        and buf_ext-classif.uniq-key-rec = ''
    on error  undo , next
    on stop  undo , next
    on endkey undo , next
    :
      v-ii = v-ii + 1.
      if v-ii modulo 10 = 0 then do:
        &scop my-count-message substitute("Копирование данных по товарам из БД &3 во временную таблицу ... записей &1 удачно &2", v-ii, v-ii-ok, p-from-version)
        {&display-count-message}.
      end.
      run fill-container in this-procedure ( input buf_ext-classif.key#_one) no-error.
      if error-status:error then do:
        &scop my-message substitute("!!!Ошибка при копировании данных по товару с кодом &1 из БД &5 во временную таблицу&2&3&2&4" ~
                                        , buf_ext-classif.key#_one ~
                                        , ~{&new-line~} ~
                                        , error-status:get-message(1) ~
                                        , return-value  ~
                                        , p-from-version ~
                                        )
        {&display-message}.
      end.
      else do:
        v-ii-ok = v-ii-ok + 1.
      end.
    end.
  end. /*when 'all'*/
end case.
{&hide-count-message}.

procedure fill-container :
define input parameter p-src-gds-code as integer no-undo .

define buffer src_goods for src.goods.
define buffer src_bar-code for src.bar-code.
define buffer src_prod-bc for src.prod-bc.
define buffer buf_src_tax-rate-gds for src.tax-rate-gds.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  find first src_goods share-lock  where
            src_goods.gds-code = p-src-gds-code no-error.
  if not available src_goods then do:
    undo, return error substitute("В БД &2 не найден товар с кодом &1", p-src-gds-code, p-from-version).
  end.
  if src_goods.stts <> integer({&current-status-int}) then do:
    return.
  end.
  find first goods-01 where
            goods-01.src-gds-code = src_goods.gds-code no-error.
  if available goods-01 then return.
  create goods-01.
  buffer-copy src_goods
  except gds-code grp-code artic prod-type prod-code
  to goods-01
  assign
  goods-01.src-gds-code = src_goods.gds-code
  goods-01.src-grp-code = src_goods.grp-code
  goods-01.src-artic = src_goods.artic
  goods-01.src-prod-type = src_goods.prod-type
  goods-01.src-prod-code = src_goods.prod-code
  .
  DEFINE VARIABLE v-today as date no-undo .
  DEFINE VARIABLE v-time as integer no-undo .
  define variable v-fact-order as decimal no-undo .
  run cur-time in this-procedure ( output v-today, output v-time).
    run factord-end-day in this-procedure
      (input  v-today
      ,output v-fact-order
      ).

    find last buf_src_tax-rate-gds no-lock
      where buf_src_tax-rate-gds.gds-code   = src_goods.gds-code
        and buf_src_tax-rate-gds.tax-code   = integer({&vat-tax-code})
        and buf_src_tax-rate-gds.host-code  = 0
        and buf_src_tax-rate-gds.obj-type   = ""
        and buf_src_tax-rate-gds.obj-code   = 0
        and buf_src_tax-rate-gds.fact-order <= v-fact-order
      no-error .

   if available buf_src_tax-rate-gds then do:
     assign
     goods-01.vat-pc-code = buf_src_tax-rate-gds.rate-code
     goods-01.slt-pc-code = 1
     .
   end.



   v-b-code = 0.
  _prod-bc:
  for each src_bar-code where
          src_bar-code.gds-code = src_goods.gds-code,
      each src_prod-bc where
      src_prod-bc.b-code = src_bar-code.b-code:
    if src_bar-code.in-code <> '' then next _prod-bc.
    if src_bar-code.part-code <> '' then next _prod-bc.
    if src_prod-bc.bc-on = no then next _prod-bc.
    if length(src_prod-bc.b-str) < 6 then next _prod-bc. /*это весовые*/
    if v-has-ss
    and length(src_prod-bc.b-str) < 10
    then do:
      find first src_code-range no-lock where
                src_code-range.range-type = {&loc-ss-code}
            and src_code-range.first-code >= integer(src_prod-bc.b-str)
            and src_code-range.last-code <= integer(src_prod-bc.b-str) no-error.
      if available src_code-range then next _prod-bc.
      find first src_code-range no-lock where
                src_code-range.range-type = {&gbl-ss-code}
            and src_code-range.first-code >= integer(src_prod-bc.b-str)
            and src_code-range.last-code <= integer(src_prod-bc.b-str) no-error.
      if available src_code-range then next _prod-bc.
    end.
    if v-b-code <> src_bar-code.b-code then do:
      create
      bar-code-01.
      buffer-copy src_bar-code except
      gds-code b-code to bar-code-01
      assign
      bar-code-01.src-gds-code = src_bar-code.gds-code
      bar-code-01.src-b-code = src_bar-code.b-code
      .
      release bar-code-01.
    end.
    create prod-bc-01.
    buffer-copy src_prod-bc except b-code to prod-bc-01
    assign
    prod-bc-01.src-b-code = src_prod-bc.b-code
    .
    release prod-bc-01.
    v-b-code = src_bar-code.b-code.
  end. /*for each src_bar-code where*/
  release goods-01.
end.

end procedure. /* fill-container */



procedure pftaxval :

  define input  parameter par-rc       as recid     no-undo .
  define input  parameter partax-code  like ub.tax.tax-code no-undo .
  define input  parameter parrate-code like ub.tax-rate.rate-code no-undo .
  /*if par-date = ? то для сейчас*/
  define input  parameter par-date     as date      no-undo .
  define input  parameter parhost-code like ub.sysconf.host-code no-undo .
  define input  parameter parobj-type  like ub.clients.obj-type no-undo .
  define input  parameter parobj-code  like ub.clients.obj-code no-undo .
  define output parameter partax-value as decimal no-undo initial ?.

  define variable vss-description as character no-undo initial "pftaxval: Значение по ставке налога в заданный момент  времени для заданного объекта и фирмы".

  define variable v-fact-order as decimal no-undo .
  define buffer buf_tax-rate for src.tax-rate.
  define buffer buf_tax-rate-value for src.tax-rate-value.

  do
  on error undo, return error return-value
  :

    if par-date = ?
    then do:
      assign
        par-date = today
      .
    end.

    run factord-end-day in this-procedure
      (input  par-date
      ,output v-fact-order
      ).

    if partax-code  = 0
    or parrate-code = 0
    then do:
      find first buf_tax-rate no-lock
        where recid(buf_tax-rate) = par-rc
        no-error .
      if not available buf_tax-rate
      then do:
        assign
          partax-value = ?
        .
        undo, return error
        "Не найдена ставка налога "
        + "recid " + string(par-rc)
        .
      end.
      assign
      partax-code = buf_tax-rate.tax-code
      parrate-code = buf_tax-rate.rate-code
      .
      if buf_tax-rate.status_ = {&deleted-status}
      then do:
        partax-value = ?.
        undo, return error
        "Ставка налога недействительна "
        + "налог: " + string(buf_tax-rate.tax-code) + " ставка: " + string(buf_tax-rate.rate-code) .

      end.
    END.
    FIND LAST buf_tax-rate-value NO-LOCK WHERE
                buf_tax-rate-value.tax-code  = partax-code  AND
                buf_tax-rate-value.rate-code = parrate-code AND
                buf_tax-rate-value.host-code = parhost-code AND
                buf_tax-rate-value.obj-type = parobj-type AND
                buf_tax-rate-value.obj-code = parobj-code AND
                buf_tax-rate-value.fact-order <= v-fact-order AND
                buf_tax-rate-value.status_ = {&current-status}
                NO-ERROR.

    if avail buf_tax-rate-value
    then do:
      partax-value = buf_tax-rate-value.rate-value.
      return.
    end.

    FIND LAST buf_tax-rate-value NO-LOCK WHERE
                buf_tax-rate-value.tax-code  = partax-code  AND
                buf_tax-rate-value.rate-code = parrate-code AND
                buf_tax-rate-value.host-code = parhost-code AND
                buf_tax-rate-value.obj-type = "" AND
                buf_tax-rate-value.obj-code = 0 AND
                buf_tax-rate-value.fact-order <= v-fact-order AND
                buf_tax-rate-value.status_ = {&current-status}
                NO-ERROR.

    if avail buf_tax-rate-value
    then do:
      partax-value = buf_tax-rate-value.rate-value.
      return.
    end.


    FIND LAST buf_tax-rate-value NO-LOCK WHERE
                buf_tax-rate-value.tax-code  = partax-code  AND
                buf_tax-rate-value.rate-code = parrate-code AND
                buf_tax-rate-value.host-code = 0 AND
                buf_tax-rate-value.obj-type = "" AND
                buf_tax-rate-value.obj-code = 0 AND
                buf_tax-rate-value.fact-order <= v-fact-order AND
                buf_tax-rate-value.status_ = {&current-status}
                NO-ERROR.

    if avail buf_tax-rate-value
    then do:
      partax-value = buf_tax-rate-value.rate-value.
      return.
    end.

  end.

end procedure. /* pftaxval */