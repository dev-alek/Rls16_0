block-level on error undo, throw.
/*

$Revision: 1f78fe327cdf, 1091, rls $
$Author: ASMorozov $
$Date: Thu Dec 14 02:13:52 2017 +0300 $
$Workfile: ththgdse.p $
$Archive: cmp/ththgdse.p $

Связывание товара вручную

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/16/09
Author: Bakhtadze Natalya
Creation date: 01/16/09

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .


define variable vss-revision    as character no-undo init "$Revision: 1f78fe327cdf, 1091, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:52 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ththgdse.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cmp/ththgdse.p $":U .
define variable vss-description as character no-undo init "Связывание товара вручную".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/thth150.i }
{ cmp/thth14.i }
{ ref/extclass.i }

define variable p-gds-code as integer no-undo .
define variable p-src-gds-code as integer no-undo .
define variable p-from-version as character no-undo .
define variable log-file-name as character no-undo .
define variable v-clients-uniq-key-rec as character no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-rec as recid no-undo .
define variable v-has-ss as logical no-undo .
define variable v-num-src-gds-prt as integer no-undo .
define variable v-src-empty-scale as integer no-undo .
define variable v-num-gds-prt as integer no-undo .
define variable v-empty-scale as integer no-undo .
define variable v-param-type                as character                no-undo.
define variable v-value-character           as character                no-undo.
define variable v-value-date                as date                     no-undo.
define variable v-value-decimal             as decimal                  no-undo.
define variable v-value-integer             as INTEGER                  no-undo.
define variable v-value-logical             AS LOGICAL                  no-undo.
define variable v-tth                       as handle                   no-undo.
define variable dif-pdbc as logical no-undo initial no.
define variable pbc-veto  as logical no-undo.
define variable v-is-new as logical no-undo .
define variable v-b-str as character no-undo .
define variable v-rid as recid no-undo .
define variable v-classif-name as character no-undo .
define variable v-cli-classif-name as character no-undo .


DEFINE BUFFER buf_ext-classif FOR ub.ext-classif.
DEFINE BUFFER buf2_ext-classif FOR ub.ext-classif.
define buffer buf_goods for ub.goods.
define buffer buf_clients for ub.clients.
define buffer clients_ext-classif for ub.ext-classif.
define buffer src_bar-code for src.bar-code.
define buffer src_prod-bc for src.prod-bc.
define buffer src_goods for src.goods.
define buffer src_code-range for src.code-range.
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_bar-code for ub.bar-code.
define buffer src_gds-prt for src.gds-prt.
define buffer buf_gds-prt for ub.gds-prt.


&glob display-message  run write-log-and-file in p-log-handle ( ~
          input 1 ~
        , input log-file-name ~
        , input 1 ~
        , input ~{&my-message~} ~
                                      )

&glob display-count-message  run write-counter in p-log-handle (input ~{&my-count-message~})

&glob hide-count-message  run hide-counter in p-log-handle

log-file-name = substitute("&1.txt", entry(1, entry(num-entries(this-procedure:file-name, {&slash-char}), this-procedure:file-name, {&slash-char}), ".")).

if num-entries(p-parameter, {&delim-par}) <> 3 then do:
  message
  substitute("Неверное количество ENTRY в составном параметре - &1, должно быть 3"
             ,num-entries(p-parameter, {&delim-par}))
  view-as alert-box error .
  return.
end.

assign
p-gds-code = integer(entry(1, p-parameter, {&delim-par}))
p-src-gds-code = integer(entry(2, p-parameter, {&delim-par}))
p-from-version = entry(3, p-parameter, {&delim-par})
.
case p-from-version:
  when {&thth150-from-version} then do:
    assign
    v-classif-name = {&extclass_goods_th-th150}
    v-cli-classif-name = {&extclass_clients_th-th150}
    .
  end.
  when {&thth14-from-version} then do:
    assign
    v-classif-name = {&extclass_goods_th-th14}
    v-cli-classif-name = {&extclass_clients_th-th14}
    .
  end.
end case.

find first src_code-range no-lock where
          src_code-range.range-type = {&loc-ss-code}
          or
          src_code-range.range-type = {&gbl-ss-code} no-error.
if available src_code-range then do:
  v-has-ss = yes.
end.


for each src_gds-prt no-lock:
  v-num-src-gds-prt = v-num-src-gds-prt + 1.
end.
if v-num-src-gds-prt > 1 then do:
  find first src_gds-prt where
            src_gds-prt.node-name = {&empty-scale} .
  assign
  v-src-empty-scale = src_gds-prt.node-code.
end.
for each buf_gds-prt no-lock:
  v-num-gds-prt = v-num-gds-prt + 1.
end.
if v-num-gds-prt > 1 then do:
  find first buf_gds-prt where
            buf_gds-prt.node-name = {&empty-scale} .
  assign
  v-empty-scale = src_gds-prt.node-code.
end.

run adm/shattri.p (
    input "get":U
    ,input  '':U /*p-obj-type*/
    ,input  0 /*p-obj-code*/
    ,input  {&attr-gds-ref}
    ,input  {&attr-gds-ref_dif-pdbc} /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output dif-pdbc
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error.
delete object v-tth.
run adm/shattri.p (
    input "get":U
    ,input  '':U /*p-obj-type*/
    ,input  0 /*p-obj-code*/
    ,input  {&attr-gds-ref}
    ,input  {&attr-gds-ref_pbc-veto} /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output pbc-veto
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error.
delete object v-tth.


find first buf_goods exclusive-lock where
          buf_goods.gds-code = p-gds-code.

find first buf_ext-classif exclusive-lock where
          buf_ext-classif.classif-subject = {&table_goods}
      and buf_ext-classif.classif-name = v-classif-name
      and buf_ext-classif.key#_one = p-src-gds-code.

/*проверим по ед-изм*/
if num-entries(buf_ext-classif.charkey_three, {&delim-par} ) > 1
and buf_goods.unit-base <> entry(2, buf_ext-classif.charkey_three, {&delim-par} )
then do:
    &scop my-message ~
    substitute("Ед.изм &1 товара с кодом &2 в ВАШЕЙ БД  не соответствует ед.изм. &3 товара с кодом &4 в БД &6 &5" + ~
              "Связать НЕВОЗМОЖНО" ~
              ,buf_goods.unit-base  ~
              ,buf_goods.gds-code ~
              ,entry(2, buf_ext-classif.charkey_three, ~{&delim-par~} ) ~
              ,buf_ext-classif.key#_one ~
              ,{&new-line} ~
              , p-from-version)
    {&display-message}.
    return ''.
end. /*if buf_goods.unit-base = src_goods.unit-base then do:*/
find first buf_clients no-lock where
          buf_clients.obj-type = buf_goods.prod-type
      and buf_clients.obj-code = buf_goods.prod-code no-error.
if available buf_clients then do:
  /*при связывании проверяем что производители тоже связаны друг с другом*/
  run gen-key-rec in this-procedure ( input {&table_clients}
                                    ,input (buffer buf_clients:handle)
                                    ,output v-clients-uniq-key-rec).
  find first clients_ext-classif share-lock where
            clients_ext-classif.classif-subject  = {&table_clients}
        and  clients_ext-classif.classif-name  = v-cli-classif-name
        and clients_ext-classif.db-num = -1
        and clients_ext-classif.charkey_one = buf_ext-classif.charkey_two
        and clients_ext-classif.key#_one = buf_ext-classif.key#_two
        and clients_ext-classif.uniq-key-rec = v-clients-uniq-key-rec no-error .
  if not available clients_ext-classif then do:
     &scop my-message   substitute("Производитель  &1&2 товара с кодом &3 в ВАШЕЙ БД  не соответствует производителю &4&5 товара с кодом &6 в БД &8&7" + ~
                "Связать НЕВОЗМОЖНО" ~
                ,buf_goods.prod-type  ~
                ,buf_goods.prod-code   ~
                ,buf_goods.gds-code     ~
                ,buf_ext-classif.charkey_two ~
                ,buf_ext-classif.key#_two ~
                ,buf_ext-classif.key#_one ~
                ,~{&new-line~} ~
                , p-from-version)
    {&display-message}.
    return ''.
  end. /*if available clients_ext-classif then do:*/

end. /*if available buf_clients then do:*/

run gen-key-rec in this-procedure ( input {&table_goods}
                                ,input (buffer buf_goods:handle)
                                ,output v-uniq-key-rec).
find first buf2_ext-classif no-lock where
          buf2_ext-classif.classif-subject = {&table_goods}
      and buf2_ext-classif.classif-name = v-classif-name
      and buf2_ext-classif.uniq-key-rec = v-uniq-key-rec no-error.
if available buf2_ext-classif then do:
  &scop my-message ~
  substitute('Товар с кодом &1 (&2 &3&4 &5) в БД v16.0 &6' ~
                                , buf_goods.gds-code    ~
                                , buf_goods.artic        ~
                                , buf_goods.prod-type     ~
                                , buf_goods.prod-code      ~
                                , buf_goods.gds-name        ~
                                , ~{&new-line~}) + ~
 substitute('уже привязан к товару с кодом &1 (&2 &3&4 &5) в БД &6' ~
                                , buf2_ext-classif.key#_one /*gds-code*/  ~
                                , buf2_ext-classif.charkey_One  /*artic*/   ~
                                , buf2_ext-classif.charkey_two /*prod-type*/ ~
                                , buf2_ext-classif.Key#_two /*prod-code */     ~
                                , buf2_ext-classif.charkey_three /*gds-name*/   ~
                                , p-from-version ~
                                )
  {&display-message}.
  return ''.
end.

find first src_goods share-lock where
         src_goods.gds-code = p-src-gds-code.


if v-num-src-gds-prt > 1
or v-num-gds-prt > 1 then do:
  find first src_gds-prt no-lock WHERE
            src_gds-prt.upper-code = src_goods.prt-root.
  find first buf_gds-prt no-lock WHERE
            buf_gds-prt.upper-code = buf_goods.prt-root.
  if src_gds-prt.node-code <> v-src-empty-scale
  or buf_gds-prt.node-code <> v-empty-scale then do:
    &scop my-message substitute("Один или оба из связываемых товаров являются товарами с непустой шкалой&1Связывание невозможно", ~{&new-line~})
    {&display-message}.
    return ''.
  end.
end.


/*надо проверить что все prod-bc товара в БД p-from-version принадлежат одному товару*/
_prod-bc2:
for each src_bar-code where src_bar-code.gds-code = src_goods.gds-code,
    each src_prod-bc where src_prod-bc.b-code = src_bar-code.b-code:
  if src_bar-code.in-code <> '' then next _prod-bc2.
  if src_bar-code.part-code <> '' then next _prod-bc2.
  if src_prod-bc.bc-on = no then next _prod-bc2.
  if length(src_prod-bc.b-str) < 6 then next _prod-bc2. /*это весовые*/
  if v-has-ss
  and length(src_prod-bc.b-str) < 10
  then do:
    find first src_code-range no-lock where
              src_code-range.range-type = {&loc-ss-code}
          and src_code-range.first-code >= integer(src_prod-bc.b-str)
          and src_code-range.last-code <= integer(src_prod-bc.b-str) no-error.
    if available src_code-range then next _prod-bc2.
    find first src_code-range no-lock where
              src_code-range.range-type = {&gbl-ss-code}
          and src_code-range.first-code >= integer(src_prod-bc.b-str)
          and src_code-range.last-code <= integer(src_prod-bc.b-str) no-error.
    if available src_code-range then next _prod-bc2.
  end.
  find first buf_prod-bc no-lock where
            buf_prod-bc.b-str = src_prod-bc.b-str no-error.
  if available buf_prod-bc then do:
    find first buf_bar-code no-lock where
            buf_bar-code.b-code = buf_prod-bc.b-code no-error.
    if available buf_bar-code then do:
        if buf_bar-code.gds-code <> buf_goods.gds-code then do:
          /*НЕ ВСЕ БАРКОДЫ ПРИНАДЛЕЖАТ В БД v15,1 ОДНОМУ И ТОМУ ЖЕ ТОВАРУ*/
          &scop my-message substitute("Для товара с кодом &1 в БД &5 имеется ДопБК &2, который в БД v16.0 принадлежит другому товару (&4) &3связывание невозможно" ~
                                      , src_goods.gds-code ~
                                      , src_prod-bc.b-str ~
                                      , ~{&new-line~} ~
                                      , buf_bar-code.gds-code ~
                                      , p-from-version ~
                                      )
          {&display-message}.
          return ''.
        end.
    end. /*if available buf_bar-code then do:*/
  end. /*if available buf_prod-bc then do:*/
end. /* for each src_bar-code where src_bar-code.gds-code = src_goods.gds-code,*/



v-rec = recid(buf_ext-classif).
run ref/extclas1.p (
                      input {&update}
                    ,input yes /*p-silent*/
                    ,input-output v-rec
                    ,input {&table_goods} /*p-classif-subject */
                    ,input v-classif-name
                    ,input -1 /*p-db-num*/
                    ,input buf_ext-classif.Key#_One /* gds-code*/
                    ,input buf_ext-classif.Key#_two /*prod-code */
                    ,input 0  /*p-key#_Three*/
                    ,input buf_ext-classif.charkey_One  /*artic*/
                    ,input buf_ext-classif.charkey_two /*prod-type*/
                    ,input buf_ext-classif.charkey_three /*gds-name*/
                    ,input 0 /*p-nonunique*/
                    ,input v-uniq-key-rec /*p-uniq-key-rec*/
                    ) no-error.
if error-status:error then do:
  &scop my-message  substitute('Ошибка при сохранении записи по товару БД &5 &1&2:&3&2&4' ~
                              , buf_ext-classif.key#_One ~
                              ,~{&new-line~} ~
                              , error-status:get-message(1) ~
                              , return-value ~
                              , p-from-version )
  {&dsiplay-message}.
  return  ''.
end.
_prod-bc3:
for each src_bar-code where src_bar-code.gds-code = src_goods.gds-code,
    each src_prod-bc where src_prod-bc.b-code = src_bar-code.b-code:
  if src_bar-code.in-code <> '' then next _prod-bc3.
  if src_bar-code.part-code <> '' then next _prod-bc3.
  if src_prod-bc.bc-on = no then next _prod-bc3.
  if length(src_prod-bc.b-str) < 6 then next _prod-bc3. /*это весовые*/
  if v-has-ss
  and length(src_prod-bc.b-str) < 10
  then do:
    find first src_code-range no-lock where
              src_code-range.range-type = {&loc-ss-code}
          and src_code-range.first-code >= integer(src_prod-bc.b-str)
          and src_code-range.last-code <= integer(src_prod-bc.b-str) no-error.
    if available src_code-range then next _prod-bc3.
    find first src_code-range no-lock where
              src_code-range.range-type = {&gbl-ss-code}
          and src_code-range.first-code >= integer(src_prod-bc.b-str)
          and src_code-range.last-code <= integer(src_prod-bc.b-str) no-error.
    if available src_code-range then next _prod-bc3.
  end.
  find first buf_prod-bc no-lock where
            buf_prod-bc.b-str = src_prod-bc.b-str no-error.
  if not available buf_prod-bc then do:
     /*НЕ БУДЕМ НИЧЕГО САМИ ДЕЛАТЬ НАФИГ!!!*/
    &scop my-message substitute("В БД v16.0 отсутствует ДопБК &1, который в БД &3 принадлежит товару с кодом &2", src_prod-bc.b-str, src_bar-code.gds-code, p-from-version )
    {&display-message}.
    /*найдем в бд v16.0 bar-code */
    /*
    find first buf_gds-prt no-lock WHERE
              buf_gds-prt.upper-code = buf_goods.prt-root.
    run barcodcr in this-procedure (
                                      input  buf_goods.gds-code
                                    ,input buf_gds-prt.node-code
                                    ,input '' /*p-part-code*/
                                    ,input '' /*p-in-code*/
                                    ,input src_bar-code.unit-cli
                                    ,input src_bar-code.cli-base-rate
                                    ,output v-is-new
                                    ,buffer buf_bar-code
                                    ) no-error.
    if error-status:error then do:
        &scop my-message substitute("Ошибка при добавлении собственного баркода для товара с найденным соответствием&1" + ~
                                    "&7&1&8" + ~
                                    "код товара в текущей БД &2, код товара в БД &9 &3,&1" + ~
                                    " ДопБК &4, ед.изм в текущей БД &5, ед изм. в БД &9 &6" ~
                                    , ~{&new-line~} ~
                                    , src_goods.gds-code ~
                                    , buf_goods.gds-code ~
                                    , src_prod-bc.b-str ~
                                    , src_bar-code.cli-base-rate ~
                                    , buf_bar-code.cli-base-rate ~
                                    , error-status:get-message(1)  ~
                                    , return-value ~
                                    , p-from-version ~
                                    )
        {&display-message}.
      next _prod-bc3.
    end.
    if available buf_bar-code then do:
      if buf_bar-code.cli-base-rate <> src_bar-code.cli-base-rate then do:
        &scop my-message substitute("Невозможно добавить отсутствующий в текущей БД ДопБК для товара с найденным соответствием&1" + ~
                                    "Не совпадают коэфф ед.изм." +  ~
                                    "код товара в текущей БД &2, код товара в БД &9 &3,&1" + ~
                                    " ДопБК &4, ед.изм в текущей БД &5, ед изм. в БД &9 &6" + ~
                                    " коэфф. в текущей БД &7 коэфф. в БД &9 &8" ~
                                    , ~{&new-line~} ~
                                    , src_goods.gds-code ~
                                    , buf_goods.gds-code ~
                                    , src_prod-bc.b-str ~
                                    , src_bar-code.unit-cli ~
                                    , buf_bar-code.unit-cli ~
                                    , src_bar-code.cli-base-rate ~
                                    , buf_bar-code.cli-base-rate ~
                                    , p-from-version ~
                                      )
        {&display-message}.
      end. /*if buf_bar-code.cli-base-rate <> src_bar-code.cli-base-rate then do:*/
      else do:
        v-b-str = src_prod-bc.b-str.
        run trg/prod-bc1.p ( input parparentproc
                            ,input yes /*p-silent*/
                            ,input dif-pdbc /* dif-pdbc */
                            ,input ? /*pbc-veto*/
                            ,input no /*send-ref*/
                            ,input ''
                            ,input "" /*p-ean-type*/
                            ,buffer buf_goods
                            ,input buf_bar-code.b-code
                            ,input-output v-b-str /*p-b-str*/
                            ,output v-rid
                            ) no-error.
        if not error-status:error then do:
        end.
        else do:
          &scop my-message substitute("Ошибка при добавлении ДоБК для товара с найденным соответствием&1" + ~
                                      "&7&1&8" + ~
                                      "код товара в текущей БД &2, код товара в БД &9 &3,&1" + ~
                                      " ДопБК &4, ед.изм в текущей БД &5, ед изм. в БД &9 &6" ~
                                      , ~{&new-line~} ~
                                      , src_goods.gds-code ~
                                      , buf_goods.gds-code ~
                                      , src_prod-bc.b-str ~
                                      , src_bar-code.cli-base-rate ~
                                      , buf_bar-code.cli-base-rate ~
                                      , error-status:get-message(1)  ~
                                      , return-value ~
                                      , p-from-version ~
                                      )
          {&display-message}.
        end.
      end. /*else if buf_bar-code.cli-base-rate <> src_bar-code.cli-base-rate then do:*/
    end. /*if available buf_bar-code then do:*/
    */
  end. /*if available buf_prod-bc then do:*/
end. /* for each src_bar-code where src_bar-code.gds-code = src_goods.gds-code,*/


procedure barcodcr :

  define input  parameter p-gds-code      like ub.bar-code.gds-code      no-undo .
  define input  parameter p-node-code     like ub.bar-code.node-code     no-undo .
  define input  parameter p-part-code     like ub.bar-code.part-code     no-undo .
  define input  parameter p-in-code       like ub.bar-code.in-code       no-undo .
  define input  parameter p-unit-cli      like ub.bar-code.unit-cli      no-undo .
  define input  parameter p-cli-base-rate like ub.bar-code.cli-base-rate no-undo .
  define output parameter p-is-new        as logical                     no-undo .
  define parameter buffer buf_bar-code for ub.bar-code .

  define variable vss-description as character no-undo initial "barcodcr-03: поиск/создание бар-кода" .

  define variable v-new-b-code like ub.bar-code.b-code no-undo .
  define variable v-unit-base  like ub.goods.unit-base no-undo .

  do
  on error undo, return error return-value
  :
    assign
      p-is-new = false
    .

    find first buf_bar-code no-lock
      where buf_bar-code.gds-code  = p-gds-code
        and buf_bar-code.node-code = p-node-code
        and buf_bar-code.part-code = p-part-code
        and buf_bar-code.in-code   = p-in-code
        and buf_bar-code.unit-cli  = p-unit-cli
      no-error .
    if not available buf_bar-code
    then do
    transaction
    on error undo, return error return-value
    :
      run gen-b-code in this-procedure
        ( input {&gbl-bc-code},
          output v-new-b-code
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при получении номера бар-кода" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
       run unitbase in this-procedure ( input p-gds-code, output v-unit-base) no-error.
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка определения базовой единицы измерения товара" skip
          "Код товара" p-gds-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      if p-unit-cli = v-unit-base
      then do:
        assign
          p-cli-base-rate = 1
        .
      end.

      if p-cli-base-rate = ?
      or p-cli-base-rate = 0
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Не задана коэффициент преобразования из одной единицы измерения в другую" skip
          "Код товара" p-gds-code skip
          "p-unit-cli" p-unit-cli skip
          "v-unit-base" v-unit-base skip
          "p-cli-base-rate" p-cli-base-rate skip
          view-as alert-box error .
        undo, return error return-value .
      end.


      assign
        p-is-new = true
      .

      create buf_bar-code .
      assign
        buf_bar-code.b-code        = v-new-b-code
        buf_bar-code.gds-code      = p-gds-code
        buf_bar-code.node-code     = p-node-code
        buf_bar-code.part-code     = p-part-code
        buf_bar-code.in-code       = p-in-code
        buf_bar-code.unit-cli      = p-unit-cli
        buf_bar-code.cli-base-rate = p-cli-base-rate
      .
    end. /*if not available buf_bar-code*/
    else do:
      if buf_bar-code.stts_ = integer({&hn-delete})
      or buf_bar-code.stts_ = integer({&hn-switch-off})
      then do:
        undo, return error substitute("баркод &1 для товара &2 помечен к удалению или логически удален", buf_bar-code.b-code, p-gds-code).
      end.
    end.

  end.

end procedure. /* barcodcr */

procedure unitbase :

  define input  parameter p-gds-code  like ub.goods.gds-code  no-undo .
  define output parameter p-unit-base like ub.goods.unit-base no-undo .

  define variable vss-description as character no-undo initial "unitbase-01: определение базовой единицы измерения товара".

  define buffer buf_goods for ub.goods .

  do
  on error undo, return error return-value
  :
    find first buf_goods no-lock
      where buf_goods.gds-code = p-gds-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error return-value . /* --->>>--- */
    end.

    assign
      p-unit-base = buf_goods.unit-base
    .
  end.

end procedure. /* unitbase */


&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile: ththgdse.p $ $Revision: 1f78fe327cdf, 1091, rls $".

&if defined (include_key-rec) = 0 &then
&glob include_key-rec yes

procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info{&vssseq} ).
    end.

    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info{&vssseq}, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info{&vssseq}, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info{&vssseq}, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + {&delim-key} + substitute("&1", fh:buffer-value())
        .
      end.
    end.

    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info{&vssseq}, p-tbl-name ).
    end.

  end.
  return.
end procedure. /* gen-key-rec */

procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo . /* буфер записи которую будем искать. если ищем по key-rec то ? */
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo . /* буфер таблицы - если надо найти во временной таблице. если ищем в БД то ? */
  define input  parameter p-stts-lock  as integer   no-undo . /* этот параметр игнорируется для временных таблиц */
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-where          as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do: /* если ищем по буферу */
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info{&vssseq} ).
      end.
      if num-entries( p-key-rec, {&delim-key} ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info{&vssseq}, p-key-rec ).
      end.
    end.
    else do: /* если ищем по ключу */
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info{&vssseq} ).
      end.
    end.

    assign
      p-tbl-name = entry( 1 , p-key-rec, {&delim-key} )
    .

    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info{&vssseq}, p-tbl-name, {&new-line} ).
    end.

    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, p-tbl-name )
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info{&vssseq}, p-tbl-name ).
    end.

    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info{&vssseq}, v-inform, p-tbl-name ).
    end.
    assign
      v-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, {&delim-key} ) - 1
      v-count-fld = 0
    .
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

      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
        assign
          v-where = substitute( "&1 &2 &3 =", v-where, v-word-link, v-field-name )
        .
/*      if p-tt-handle = ? then do:*/
/*        assign*/
/*          v-where = substitute( "&1 &2 &3.&4 =", v-where, v-word-link, v-full-tbl-name, v-field-name )*/
/*        .*/
/*      end.*/
/*      else do:*/
/*        assign*/
/*          v-where = substitute( "&1 &2 &3 =", v-where, v-word-link, v-field-name )*/
/*        .*/
/*      end.*/
      if p-key-handle = ? then do:
        assign
          v-field-val = entry( v-count-fld + 1 , p-key-rec, {&delim-key} )
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info{&vssseq}, p-key-handle:name, v-field-name ).
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
        v-where = substitute( "&1 &2", v-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.

    end.

    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info{&vssseq}, p-tbl-name ).
    end.
    if p-tt-handle = ? then do:
      bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
    end.
    else do:
      bh_tbl-name:find-first( v-where ) no-error .
    end.

    if bh_tbl-name:available then do:
      assign
        p-tbl-row = bh_tbl-name:rowid
      .
    end.
    else do:
      assign
        p-tbl-row = ?
      .
    end.

    delete object bh_tbl-name.

  end.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info{&vssseq}, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.

end procedure. /* gen-row-keyr */

procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info{&vssseq} ).
    end.

    assign
      v-tbl-name      = entry( 1 , p-key-rec, {&delim-key} )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name .

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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info{&vssseq}, v-tbl-name ).
    end.

    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info{&vssseq}, v-inform, v-tbl-name ).
    end.

    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, {&delim-key} ) - 1
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
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, {&delim-key} )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = {&delim-key}
        .
      end.
    end.

    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info{&vssseq}, v-tbl-name ).
    end.

    delete object bh_tbl-name.

  end.

  return.

end procedure. /* gen-key-fv */

&endif

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile: ththgdse.p $ $Revision: 1f78fe327cdf, 1091, rls $".

procedure gen-b-code :

  define input  parameter type-code like ub.code-range.range-type no-undo . /* тип кода, значение которого хотим получить */
  define output parameter p-b-code  like ub.bar-code.b-code       no-undo . /* выходное значение бар-кода                 */

  do
  on error  undo, return error substitute( "&1 (gen-b-code). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (gen-b-code). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-b-code). endkey", vss-workfile )
  :
    define buffer buf_thbj-attr     for ub.thbj-attr .
    define buffer buf_sys-ctrl   for ub.sys-ctrl .
    define buffer buf_code-range for ub.code-range .

    define variable l-code         as   integer              no-undo .
    define variable v-db-num       like ub.db.db-num         no-undo .
    define variable cfg-param-code like ub.thbj-attr.prop-code no-undo .

    if type-code = {&loc-ss-code}
    or type-code = {&gbl-ss-code}
    then do:
      /* диапазон локальных взвешиваемых кодов */
      message
        "Нельзя генерировать локальный или глобальный взвешиваемый код." skip
        "Обратитесь к администратору системы."
        view-as alert-box error .
      undo, return error (if type-code = {&loc-ss-code} then "loc-ss-code":U else "gbl-ss-code" ) .
    end.

    run trg/getpcode.p ( input  type-code
                   ,output cfg-param-code
                  ).
    run get-next-seq( input  type-code,
                      output l-code
                    ).

    find first buf_sys-ctrl no-lock.
    if type-code = {&loc-sc-code}
    or type-code = {&loc-pg-code}
    then do:
      /* диапазон локальных весовых кодов всегда привязан к ГБД */
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
      /* значение внутри активного диапазона - выставляем его по sequence */
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
      /* завхватываем thbj-attr */
      /* чтобы никто другой не мог одновременно менять диапазон */
      do transaction
      on error undo, return error
      :
        find first buf_thbj-attr exclusive-lock
          where buf_thbj-attr.upper-prop-code = {&attr-code-range}
            and buf_thbj-attr.prop-code = cfg-param-code
            and buf_thbj-attr.obj-type   = {&db}
            and buf_thbj-attr.obj-code   = v-db-num
          no-error .
        if not available buf_thbj-attr then do:
          find first buf_thbj-attr exclusive-lock
            where buf_thbj-attr.upper-prop-code = {&attr-code-range}
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
            /* если пользователь отказался подождать, */
            /* то ему не дадим менять диапазон и бар-код не дадим ! */
            undo, return error "config":U .
          end. /*if not available buf_thbj-attr then do:*/
        end. /*if not available buf_thbj-attr then do:*/

        run get-next-seq( input type-code,
                          output l-code
                        ).
        /* если диапазон сменился другим пользователем */
        /* то надо перечитать значение sequence, */
        /* если не сменился, то требуется смена диапазона и смена sequence */
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
            /* диапазон никто не сменил */
            /* sequence за пределами диапазона */
            /* помечаем его как использованный */
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

          /* создаем новый диапазон и присваиваем новое значение seq */
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
  on error  undo, return error substitute( "&1 (get-next-seq). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (get-next-seq). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (get-next-seq). endkey", vss-workfile )
  :
    case type-code:
      when {&gbl-bc-code} then do:
        assign
          next-seq = next-value(s-bcgb-code, {&db-name_schema})
        .
      end.
      when {&gbl-sc-code} then do:
        assign
          next-seq = next-value(s-scgb-code, {&db-name_schema})
        .
      end.
      when {&loc-sc-code} then do:
        assign
          next-seq = next-value(s-sclc-code, {&db-name_schema})
        .
      end.
      when {&loc-pg-code} then do:
        assign
          next-seq = next-value(s-pglc-code, {&db-name_schema})
        .
      end.
      when {&gbl-dc-code} then do:
        assign
          next-seq = next-value(s-dcgb-code, {&db-name_schema})
        .
      end.
      when {&gbl-ct-code} then do:
        assign
          next-seq = next-value(s-ctgb-code, {&db-name_schema})
        .
      end.
      when {&gbl-dr-code} then do:
        assign
          next-seq = next-value(s-drgb-code, {&db-name_schema})
        .
      end.
      when {&gbl-fm-code} then do:
        assign
          next-seq = next-value(s-fmgb-code, {&db-name_schema})
        .
      end.
      when {&gbl-pn-code} then do:
        assign
          next-seq = next-value(s-pngb-code, {&db-name_schema})
        .
      end.
      when {&gbl-ca-code} then do:
        assign
          next-seq = next-value(s-cagb-code, {&db-name_schema})
        .
      end.
      when {&gbl-fd-code} then do:
        assign
          next-seq = next-value(s-fin-doc, {&db-name_schema})
        .
      end.
    end case.
  end.
end procedure. /* get-next-seq */
