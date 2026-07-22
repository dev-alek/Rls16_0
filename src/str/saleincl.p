block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Закачка чеков в продажу - вызывается через diallog.w

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/21/05
Author: Bakhtadze Natalya
Creation date: 03/21/05

*/


define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle     as handle no-undo .
define input parameter p-parameter      as character        no-undo.
/*p-parameter включает в себ
*/
define variable p-auto         as integer no-undo .
define variable p-inkas-code   like ub.inkas.inkas-code no-undo .
define variable p-filter-on as logical no-undo .
define variable v-curr-r-b  as character no-undo .
define variable is-wth      as logical   no-undo .
define variable cas-shft    as logical no-undo init no.
define variable one-curs    as logical no-undo init no.
define variable cas-curs    as logical no-undo init no.
define variable prcl-spl    as logical no-undo init no.
define variable pay-gds-algo as character no-undo .
/*код дорожного налога*/
define variable rdtaxcd     as INTEGER                  no-undo.
/*код акциза*/
define variable exctaxcd    as INTEGER                  no-undo.
/*фактор дор налога*/
define variable factorrt    as decimal no-undo.
/*код стеклопосуды*/
define variable btltaxcd    as INTEGER                  no-undo.
define variable p-day-only  as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Закачка чеков в продажу".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

{ gbl/cur-time.i }
{ str/get-pr.i def }
{ str/clc-exc.i }
{ cmp/operlist.i }
{ cmp/library.i }
{ str/lib-trn.i }
{ str/trdcalib.i }
{ str/lib-def.i }
{ str/inkas-ps.i }
{ str/saledoc.i }
{ str/tpsidoc.i "SHARED" proc }
{ str/t-gds.i  def inc-sale }
{ str/findtank.i }
{ gbl/clntattr.i }
{ rep/real3tm.i }
{ ref/gds-attr.i }
{ str/placelib.i }

define variable p-ii as integer no-undo .
define variable p-ii-ok as integer no-undo .
define variable p-rid-list as character no-undo . /*список recid chk-doc если по нескольким - здесь пустой */
define variable p-call-handle  as handle no-undo .
define variable p-filter-rus as character no-undo .
define variable p-obj-type  like ub.clients.obj-type no-undo .
define variable p-obj-code  like ub.clients.obj-code no-undo .
define variable cursh       like ub.curr-shop.exch-rate init 0.
define variable cursh-scale like ub.curr-shop.exch-rate.
define variable gds-amount  as integer .
define variable chk-amount  as integer .
define variable line-out    as integer .
define variable line-ret    as integer .
define variable dtl-out     as integer .
define variable dtl-ret     as integer .
define variable nf-gds-amount  as integer .
define variable nf-chk-amount  as integer .
define variable old-doc-date   like ub.inkas.doc-date no-undo .
define variable old-shift-date like ub.inkas.shift-date no-undo .
define variable old-shift-num  like ub.inkas.shift-num  no-undo .
define variable new-doc-date   like ub.inkas.doc-date no-undo .
define variable new-shift-date like ub.inkas.shift-date no-undo .
define variable new-shift-num  like ub.inkas.shift-num  no-undo .
define variable v-no-check     as logical no-undo .
define variable v-dop-where-rus as character no-undo .
define variable log-file-name  as character no-undo .

define buffer ink-doc for ub.inkas.
define buffer trn-doc for ub.trn-doc.
define buffer buf_sysconf for ub.sysconf.
define buffer X_chk-doc for ub.chk-doc.
DEFINE QUERY QUERY-chk-doc FOR X_chk-doc SCROLLING.


define variable v-view-log as logical no-undo .
define variable v-esm as character no-undo .
define variable v-input-error as logical no-undo .
define variable v-db-num  like ub.db.db-num no-undo .
define variable v-filter-name as character no-undo .
define variable v-where-phrase as character no-undo .
define variable v-query-prepare as character no-undo .
define variable glog            as logical no-undo .
define variable v-filter-exist as logical no-undo .


do
on error undo, return error
:


if num-entries(p-parameter, {&delim-par}) <> 15
then do:
  assign
  v-input-error = yes
  v-esm         = substitute("Неверное количество ENTRY в составном параметре - &1, должно быть 15"
                             ,num-entries(p-parameter, {&delim-par})).
  .
end.
else do:
  assign
  p-auto              = integer(entry(1, p-parameter, {&delim-par}))
  p-inkas-code        = entry(2, p-parameter, {&delim-par})
  p-filter-on         = logical(entry(3, p-parameter, {&delim-par}))
  v-curr-r-b          = entry(4, p-parameter, {&delim-par})
  is-wth              = logical(entry(5, p-parameter, {&delim-par}))
  cas-shft            = logical(entry(6, p-parameter, {&delim-par}))
  one-curs            = logical(entry(7, p-parameter, {&delim-par}))
  cas-curs            = logical(entry(8, p-parameter, {&delim-par}))
  prcl-spl            = logical(entry(9, p-parameter, {&delim-par}))
  pay-gds-algo        = entry(10, p-parameter, {&delim-par})
  rdtaxcd             = integer(entry(12, p-parameter, {&delim-par}))
  exctaxcd            = integer(entry(12, p-parameter, {&delim-par}))
  factorrt            = decimal(entry(13, p-parameter, {&delim-par}))
  btltaxcd            = integer(entry(14, p-parameter, {&delim-par}))
  p-day-only          = logical(entry(15, p-parameter, {&delim-par}))
  no-error
  .
  if error-status:error then do:
    assign
    v-esm = error-status:get-message(1)
    v-input-error = yes
    .
  end.
end.

if p-auto = 0 then do:
  log-file-name = 'saleincl.log' .
end.
else do:
  log-file-name = 'ext-sale.log'.
end.

&glob display-message  run write-log-and-file in p-log-handle ( ~
          input 1 ~
        , input log-file-name ~
        , input 1 ~
        , input ~{&my-message~} ~
                                      )

&glob display-message-laud  run write-log-and-file in p-log-handle ( ~
          input 1 ~
        , input log-file-name ~
        , input 1 ~
        , input ~{&my-message~} ~
                                      )

&glob display-count-message  run write-counter in p-log-handle (input ~{&my-count-message~})

&glob hide-count-message  run hide-counter in p-log-handle


&glob view-log   if p-auto = 0 then do: ~
                   ~{ str/cdviewlg.i   ~
                    "substitute('!!!В процессе закачки чеков в продажу произошли ошибки!!!')"  ~
                    "'saleincl.log'" ~}   ~
                    return "error":U. ~
                 end

{ str/inc-salr.i }

if v-input-error = yes then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , {&new-line}
                         , v-esm
                         , return-value
                         )).
  assign
  v-view-log = yes.
  {&view-log}.
end.

assign
p-call-handle = this-procedure .

find first ink-doc exclusive-lock where
            ink-doc.inkas-code = p-inkas-code no-error no-wait.
if NOT available ink-doc
and not locked ink-doc
then do:
  return error substitute("Не найден отчет о продаже №&1", p-inkas-code).
end.
if locked ink-doc then do:
  if p-auto < 2 then
  return error substitute("Отчет о продаже №&1 занят", p-inkas-code).
  else do:
    return "":U.
  end.
end.
FIND FIRST trn-doc WHERE trn-doc.doc-code = ink-doc.inkas-code exclusive.
assign
p-obj-type = ink-doc.obj-type
p-obj-code = ink-doc.obj-code
.

if (p-auto < 2
and not (ink-doc.status_ = {&g___new}
          or
          ink-doc.status_ = {&doc-froze} ))
then do:
  return error substitute("Отчет о продаже №&1 имеет статус &2", ink-doc.inkas-code, ink-doc.status_).
end.
if p-auto >= 2
and ink-doc.status_ <> {&g___new}
and trn-doc.flag_ <> no
then do:
  return "":U.
end.
{ gbl/objdbnum.i {&shop}  ink-doc.obj-code v-db-num }
if v-db-num <> g#db-num then do:
  return error substitute("Отчет о продаже №&1 относится к магазину БД &2, текущая БД &3"
                          , ink-doc.inkas-code
                          , v-db-num
                          , g#db-num
                          ).
end.
find first buf_sysconf where
          buf_sysconf.host-code = ink-doc.host-code no-lock.
if not available buf_sysconf then do:
  return error substitute("Не найдена запись о фирме &1", ink-doc.host-code).
end.

run get-inkas-ps in this-procedure (
                                    buffer ink-doc
                                  , output chk-amount
                                  , output gds-amount
                                  , output line-out
                                  , output dtl-out
                                  , output line-ret
                                  , output dtl-ret
                                  , output nf-chk-amount
                                  , output nf-gds-amount
                                  , output v-dop-where-rus
                                  ).

  assign
  ink-doc.PS = set-inkas-ps-simple (
                          input chk-amount
                        , input gds-amount
                        , input line-out
                        , input dtl-out
                        , input line-ret
                        , input dtl-ret
                        , input nf-chk-amount
                        , input nf-gds-amount
                        )
  .


assign
old-doc-date   =  ink-doc.doc-date
old-shift-date =  ink-doc.shift-date
old-shift-num  =  ink-doc.shift-num
new-doc-date   =  ink-doc.doc-date
new-shift-date =  ink-doc.shift-date
new-shift-num  =  ink-doc.shift-num
ink-doc.is-auto-get = (p-auto >= 2)
.

if p-filter-on
or (p-auto >= 2 and (ink-doc.sale-filter <> '':U
                     and ink-doc.sale-filter <> ?)
    )
then do:
  /*получим значение фильтра и в Myenable покажем его*/
  assign
  v-filter-name = ink-doc.sale-filter-name
  v-where-phrase = ink-doc.sale-filter
  p-filter-rus = ink-doc.sale-filter-rus
  .
end.
if one-curs then do:
  assign
  cursh = trn-doc.exch-rate
  cursh-scale = trn-doc.exch-scale
  .
end.

&scop my-message substitute("Обработка продажи &1............"                          ~
                            , p-inkas-code)

{&display-message}.


if cas-shft then do:
&scop my-message substitute("Закачиваются чеки с датой продажи(учета) &1 по смене &2"                          ~
                            , string(old-shift-date, "99/99/9999")                                             ~
                            , old-shift-num)
{&display-message}.
end.
else do:
  if p-day-only then do:
    &scop my-message substitute("Закачиваются чеки с датой продажи(учета) &1"                          ~
                                , string(old-shift-date, "99/99/9999"))
    {&display-message}.
  end.
  else do:
    if p-filter-on then do:
      &scop my-message substitute("Закачиваются чеки с любой датой продажи(учета)"                          ~
                                  )
      {&display-message}.
    end.
    else do:
      &scop my-message substitute("Закачиваются чеки с датой продажи(учета) <= &1"                          ~
                                  , string(old-shift-date, "99/99/9999"))
      {&display-message}.
    end.
  end.
end.
if p-filter-on then do:
  &scop my-message substitute("Закачиваются ТОЛЬКО чеки удовлятворяющие фильтру:&1&2"                          ~
                              , ~{&new-line~}                                                                  ~
                              , p-filter-rus)
  {&display-message}.
end.

ASSIGN
v-query-prepare = substitute("for each X_chk-doc no-lock where ":U +
                          "X_chk-doc.obj-type = '&1'":U +
                          " AND X_chk-doc.obj-code = &2":U +
                          " AND X_chk-doc.out-code = ? ", ink-doc.obj-type, ink-doc.obj-code).
if cas-shft then do:
  ASSIGN
  v-query-prepare = v-query-prepare +
                  substitute(" AND X_chk-doc.shift-date = &1 AND X_chk-doc.shift-num = &2"
                            , string(ink-doc.shift-date, "99/99/9999")
                            , ink-doc.shift-num).
  /* пропускаем, если не та дата */
end. /*cas-shft*/
else do:
    if p-day-only then do:
        ASSIGN
        v-query-prepare = v-query-prepare +
                        substitute(" AND X_chk-doc.shift-date = &1", string(ink-doc.shift-date, "99/99/9999")).
                        .
      /* пропускаем, если не та дата */
    end.
    else do:
        ASSIGN
        v-query-prepare = v-query-prepare +
                        substitute(" AND X_chk-doc.shift-date <= &1", string(ink-doc.shift-date, "99/99/9999")).
      /* пропускаем, если не та дата */
    end.
end. /*not cas-shft*/
assign
glog =
QUERY query-chk-doc:QUERY-PREPARE(v-query-prepare + v-where-phrase) No-error.
IF not glog THEN DO:
&scop my-message substitute("Ошибка - неверно выбран или построен ФИЛЬТР:&1&2&1 &3"  ~
                          , ~{&new-line~}                                          ~
                          , (v-query-prepare + v-where-phrase)                     ~
                          , error-status:get-message(1))
{&display-message-laud}.
  UNDO, RETURN ERROR.
END.

assign
glog = QUERY query-chk-doc:query-OPEN() NO-ERROR.
IF not glog THEN DO:
&scop my-message substitute("Ошибка - неверно выбран или построен ФИЛЬТР:&1&2&1 &3"   ~
                          , ~{&new-line~}                                           ~
                          , (v-query-prepare + v-where-phrase)                      ~
                          , error-status:get-message(1))
{&display-message-laud}.
  UNDO, RETURN ERROR.
END.
ASSIGN
glog = QUERY query-chk-doc:GET-FIRST(no-lock) NO-ERROR.
IF not glog THEN DO:
&scop my-message substitute("Нет чеков, удовлетворяющих условиям закачки в продажу &1"  ~
                          , p-inkas-code)
{&display-message-laud}.
  assign
  v-no-check = yes
  .
END.
ASSIGN
glog = QUERY query-chk-doc:GET-FIRST(exclusive-LOCK, no-wait) NO-ERROR.
do while locked (X_chk-doc ) and available X_chk-doc:
    p-ii = p-ii + 1.
    glog = QUERY query-chk-doc:GET-NEXT(exclusive-LOCK, no-wait) NO-ERROR.
end.


if not v-no-check then do:
if one-curs then do:
  &scop my-message substitute("Закачиваются ТОЛЬКО чеки с курсом баз.вал. = &1"                          ~
                              , string(trn-doc.exch-rate / trn-doc.exch-scale, ">>,>>9.9999"))

  {&display-message}.
end.
end.




end. /*doe*/

if not v-no-check then do:
  run proc-main in this-procedure ( input trn-doc.status_) no-error .
  if error-status:error then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Ошибка при закачке чеков в продажу &1 &2&3:&4&5 &6"
                          , p-inkas-code
                          , (if p-obj-type <> "":U then p-obj-type else "":U)
                          , (if p-obj-code <> 0 then string(p-obj-code) else "":U)
                          , {&new-line}
                          , error-status:get-message(1)
                          , return-value
                          )).
    assign
    v-view-log = yes.
    {&view-log}.
  end.
  else do:
  &scop my-message substitute("Просмотрено &1 чеков, успешно закачано в продажу &2", p-ii, p-ii-ok)
  {&display-message}.
  end.
end. /*if not v-no-check*/

/*если по расписанию и надо перейти к следующей стадии то установим флаг на накладной равен yes*/
if p-auto = 3 then do:
  run str/salestat.p (
                     input parparentproc
                    ,input p-inkas-code
                    ,input {&close-doc}
                    ,input {&g___new}
                    ,input yes
                    ,input yes ) no-error .
  if not error-status:error then do:
&scop my-message substitute("Продажа &1 помечена как готовая к резервированию", p-inkas-code)
{&display-message}.
  end.
  else do:
&scop my-message substitute("!!!Ошибка при переводе статуса продажи:&1&2 &3"  ~
                , ~{&new-line~}                                               ~
                , error-status:get-message(1)                                 ~
                , return-value )
    {&display-message}.
  end.
end.


procedure display-chk :
DEFINE INPUT PARAMETER p-chk-amount AS INTEGER NO-UNDO.
define input parameter p-nf-chk-amount as integer no-undo .

  do
  on error undo, return error
  :

&scop my-count-message substitute("Чеков &1 (&7) Строк &2 Расход: товаров &3 признаков &4 Возврат: товаров &5 признаков &6"  ~
                                  , p-chk-amount                                                                             ~
                                  , gds-amount                                                                              ~
                                  , line-out                                                                                ~
                                  , dtl-out                                                                                 ~
                                  , line-ret                                                                                ~
                                  , dtl-ret                                                                                 ~
                                  , p-nf-chk-amount)

{&display-count-message}.


  end.

end procedure. /* display-chk */


PROCEDURE display-ink-doc :
define input parameter p-gds-amount  as integer no-undo .
define input parameter p-nf-gds-amount  as integer no-undo .
define input parameter p-line-out    as integer no-undo .
define input parameter p-line-ret    as integer no-undo .
define input parameter p-dtl-out     as integer no-undo .
define input parameter p-dtl-ret     as integer no-undo .

&scop my-count-message substitute("Чеков &1 Строк &2 (&7) Расход: товаров &3 признаков &4 Возврат: товаров &5 признаков &6"  ~
                                  , chk-amount                                                                                ~
                                  , p-gds-amount                                                                              ~
                                  , p-line-out                                                                                ~
                                  , p-dtl-out                                                                                 ~
                                  , p-line-ret                                                                                ~
                                  , p-dtl-ret                                                                                 ~
                                  , p-nf-gds-amount)

{&display-count-message}.

END PROCEDURE. /* display-ink-doc */