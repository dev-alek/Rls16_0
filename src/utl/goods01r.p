block-level on error undo, throw.
/*

$Revision: 151fe727385f, 696, rls $
$Author: EShklyar $
$Date: Wed Jul 06 18:00:55 2016 +0300 $
$Workfile: goods01r.p $
$Archive: utl/goods01r.p $

Изменение товаров по списку

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/21/05
Author: Bakhtadze Natalya
Creation date: 03/21/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

/*
p-parameter включает
*/

define variable p-curr-obj-type like ub.clients.obj-type no-undo.
define variable p-curr-obj-code like ub.clients.obj-code no-undo.
define variable p-gds-name      like ub.goods.gds-name         no-undo.
define variable p-engl-name     like ub.goods.engl-name         no-undo.
define variable p-label-name    like ub.goods.label-name         no-undo.
define variable p-chk-name      like ub.goods.chk-name         no-undo.
define variable p-alpha1        like ub.goods.alpha1         no-undo.
define variable p-unit-cli      like ub.goods.unit-cli       no-undo.
define variable p-max-rate      like ub.goods.max-rate       no-undo.
define variable p-min-rate      like ub.goods.min-rate       no-undo.
define variable p-cli-base-rate like ub.goods.cli-base-rate       no-undo.
define variable p-qnty-cart     like ub.goods.qnty-cart      no-undo.
define variable p-ms-base       like ub.goods.ms-base        no-undo.
define variable p-wt-base       like ub.goods.wt-base      no-undo.
define variable p-ms-cart       like ub.goods.ms-cart        no-undo.
define variable p-wt-cart       like ub.goods.wt-cart      no-undo.
define variable p-calc-method   like ub.goods.calc-method  no-undo.
define variable p-increase-pc   like ub.goods.increase-pc  no-undo.
define variable p-negative-rest like ub.goods.negative-rest no-undo.
define variable p-okdp          like ub.goods.okdp          no-undo.
define variable p-destin        like ub.goods.destin        no-undo.
define variable p-attrib        like ub.goods.attrib        no-undo.
define variable p-user-rule     like ub.goods.user-rule     no-undo.
define variable p-sert          like ub.goods.sert          no-undo.
define variable p-struct        like ub.goods.struct        no-undo.
define variable p-deadline      like ub.goods.deadline      no-undo.
define variable p-cond-keep-code like ub.goods.cond-keep-code no-undo.
define variable p-sort          like ub.goods.sort          no-undo.
define variable p-proof         like ub.goods.proof         no-undo.
define variable p-normal-wastage  like ub.goods.normal-wastage  no-undo.
define variable p-normal-waste  like ub.goods.normal-waste  no-undo.
define variable p-tnved         like ub.goods.tnved         no-undo.
define variable p-nationality   like ub.goods.nationality   no-undo.
define variable p-unit-cst      like ub.goods.unit-cst      no-undo.
define variable p-cst-base-rate like ub.goods.cst-base-rate no-undo.
define variable p-fbr-grp-code  like ub.goods.fbr-grp-code  no-undo .
define variable p-ps            like ub.goods.ps            no-undo .
define variable p-date          as date                     no-undo .
define variable p-stts          as logical no-undo .
DEFINE VARIABLE var-fact-order like ub.tax-rate-value.fact-order no-undo .


define variable vss-revision    as character no-undo init "$Revision: 151fe727385f, 696, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Wed Jul 06 18:00:55 2016 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: goods01r.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/goods01r.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/library.i  }
{ cmp/gds-list.i gds-list def "shared" }
{ str/tt-tax.i "shared" tt-tax full }
{ trg/factord.i  }
{ gbl/cur-time.i }
{ ref/grplib.i }

/*вспомогат*/
define variable dops as character no-undo format "X(250)".
define variable dopst as character no-undo format "X(1)".
define variable is-jwlr as logical no-undo.
define variable is-bttl as logical no-undo.
define variable is-ptrl as logical no-undo.
define variable custvalue      as char no-undo.
define variable custtype       as char no-undo.
define variable v-gds-rec as recid no-undo.
define variable v-nbc like ub.bar-code.b-code no-undo .
define variable v-dop as character no-undo .
define variable v-main-error as logical no-undo .
define variable vnum1 as integer no-undo .
define variable vnum2 as integer no-undo .
define variable v-call-point as character no-undo .
define variable i-line as integer no-undo .
/*место выхова программы*/
define variable v-call-params as character no-undo .
define variable text-string as character no-undo .
define variable i-artic like ub.goods.artic no-undo .
define variable i-struct like ub.goods.struct no-undo .
define variable i-prod-code like ub.goods.prod-code no-undo .
define variable i-tnved like ub.goods.tnved no-undo .
define variable i-alpha1 like ub.goods.alpha1 no-undo .
define variable v-stts as integer no-undo .

define stream inp.

define buffer buf_goods for ub.goods.
define buffer buf_gds-prt for ub.gds-prt.
define buffer buf_gds-obj for ub.gds-obj.
define buffer buf_units for ub.units.
define buffer cli-units for ub.units.
define buffer buf_tt-tax for tt-tax.


/*имя log-file */
define variable log-file-name                as character      no-undo init "gdsuform.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-val as character no-undo .
define variable v-do-str  as character no-undo .
define variable v-do      as logical no-undo extent 37.
define variable v-ii      as integer no-undo .
define variable num-rec   as integer no-undo .
define variable num-rec-ok as integer no-undo .
define variable glog as logical no-undo .
define variable lns-cnt as integer no-undo .
define variable line-rec as recid no-undo .
define variable v-update-mode as character no-undo .
define variable v-file-name as character no-undo .
define variable v-encoding as character no-undo .
define variable v-found   as logical no-undo .



define variable v-host-code like ub.sysconf.host-code no-undo .

&scop       gds-name         1
&scop       engl-name        2
&scop       label-name       3
&scop       chk-name         4
&scop       alpha1           5
&scop       unit-cli         6
&scop       max-rate         7
&scop       min-rate         8
&scop       cli-base-rate    9
&scop       qnty-cart       10
&scop       ms-base         11
&scop       wt-base         12
&scop       ms-cart         13
&scop       wt-cart         14
&scop       calc-method     15
&scop       increase-pc     16
&scop       negative-rest   17
&scop       okdp            18
&scop       destin          19
&scop       attrib          20
&scop       user-rule       21
&scop       sert            22
&scop       struct          23
&scop       deadline        24
&scop       cond-keep-code  25
&scop       sort            26
&scop       proof           27
&scop       normal-wastage  28
&scop       normal-waste    29
&scop       tnved           30
&scop       nationality     31
&scop       unit-cst        32
&scop       cst-base-rate   33
&scop       fbr-grp-code    34
&scop       ps              35
&scop       stts            36
&scop       tax             37






&scop view-log   ~{ str/cdviewlg.i   ~
                    "'!!!При изменении товаров произошли ошибки!!!'" ~
                    "'gdsuform.txt'" ~}   ~
                    return


if num-entries(p-parameter, {&delim-nws}) <> 4 then do:
 run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , {&new-line}
                         , error-status:get-message(1)
                         , return-value
                         )).
  assign
  v-view-log = yes.
  {&view-log}.
end.
assign
v-call-point = entry(1, p-parameter, {&delim-nws})
v-call-params = entry(2, p-parameter, {&delim-nws})
v-val = entry(3, p-parameter, {&delim-nws})
v-do-str = entry(4, p-parameter, {&delim-nws})
.
log-file-name = v-call-point + ".txt".

if lookup(v-call-point, "gdsuform,struct,tnved,alpha1") = 0 then do:
 run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2неверный режим пакетного изменения товара &3"
                         , p-parameter
                         , {&new-line}
                         , v-call-point
                         )).
  assign
  v-view-log = yes.
  {&view-log}.


end.
assign
vnum1 = num-entries(v-val, {&delim-par})
vnum2 = num-entries(v-do-str, {&delim-par})
.

if vnum1 <> 40
or vnum2 <> 37
then do:
 run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2неверное количество элементов списка (&3) &4"
                         , p-parameter
                         , {&new-line}
                         , (if vnum1 <> 40 then vnum1 else vnum2)
                         , (if vnum1 <> 40 then "значений параметров" else "изменяемых полей")
                         , return-value
                         )).
  assign
  v-view-log = yes.
  {&view-log}.
end.
do v-ii = 1 to 37:
  assign
  v-do[v-ii] = logical(entry(v-ii, v-do-str, {&delim-par}))
  no-error
  .
  if error-status:error then do:
    run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("1Ошибка входных параметров &1:&2&3&4"
                            , p-parameter
                            , {&new-line}
                            , error-status:get-message(1)
                            , return-value
                            )).
      assign
      v-view-log = yes.
      {&view-log}.
  end.
end.
assign
p-curr-obj-type = entry(1, v-val, {&delim-par})
p-curr-obj-code = integer(entry(2, v-val, {&delim-par}))
var-fact-order  = decimal(entry(3, v-val, {&delim-par}))
p-gds-name      = entry(4, v-val, {&delim-par})
p-engl-name     = entry(5, v-val, {&delim-par})
p-label-name    = entry(6, v-val, {&delim-par})
p-chk-name      = entry(7, v-val, {&delim-par})
p-alpha1        = entry(8, v-val, {&delim-par})
p-unit-cli      = entry(9, v-val, {&delim-par})
p-max-rate      = decimal(entry(10, v-val, {&delim-par}))
p-min-rate      = decimal(entry(11, v-val, {&delim-par}))
p-cli-base-rate = decimal(entry(12, v-val, {&delim-par}))
p-qnty-cart     = decimal(entry(13, v-val, {&delim-par}))
p-ms-base       = decimal(entry(14, v-val, {&delim-par}))
p-wt-base       = decimal(entry(15, v-val, {&delim-par}))
p-ms-cart       = decimal(entry(16, v-val, {&delim-par}))
p-wt-cart       = decimal(entry(17, v-val, {&delim-par}))
p-calc-method   = entry(18, v-val, {&delim-par})
p-increase-pc   = decimal(entry(19, v-val, {&delim-par}))
p-negative-rest = if v-do[{&negative-rest}] then logical(entry(20, v-val, {&delim-par})) else no
p-okdp          = entry(21, v-val, {&delim-par})
p-destin        = entry(22, v-val, {&delim-par})
p-attrib        = entry(23, v-val, {&delim-par})
p-user-rule     = entry(24, v-val, {&delim-par})
p-sert          = entry(25, v-val, {&delim-par})
p-struct        = entry(26, v-val, {&delim-par})
p-deadline      = integer(entry(27, v-val, {&delim-par}))
p-cond-keep-code = integer(entry(28, v-val, {&delim-par}))
p-sort          = entry(29, v-val, {&delim-par})
p-proof          = decimal(entry(30, v-val, {&delim-par}))
p-normal-wastage = decimal(entry(31, v-val, {&delim-par}))
p-normal-waste   = decimal(entry(32, v-val, {&delim-par}))
p-tnved          = entry(33, v-val, {&delim-par})
p-nationality    = entry(34, v-val, {&delim-par})
p-unit-cst       = entry(35, v-val, {&delim-par})
p-cst-base-rate  = decimal(entry(36, v-val, {&delim-par}))
p-fbr-grp-code   = integer(entry(37, v-val, {&delim-par}))
p-ps             = entry(38, v-val, {&delim-par})
v-dop            = entry(39, v-val, {&delim-par})
p-date           =  if v-do[{&tax}]
                    then date(integer(substring(v-dop, 4, 2)),
                                        integer(substring(v-dop, 1, 2)),
                                        integer(substring(v-dop, 7, 4))
                                        )
                   else ?
p-stts           = if v-do[{&stts}] then logical(entry(40, v-val, {&delim-par})) else no
.
if error-status:error then do:
 run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , {&new-line}
                         , error-status:get-message(1)
                         , return-value
                         )).
  assign
  v-view-log = yes.
  {&view-log}.
end.


if not (p-curr-obj-type = {&shop}
or p-curr-obj-type = {&stock})
or not
 can-find (first ub.clients no-lock where
                      ub.clients.obj-type = p-curr-obj-type
                 AND  ub.clients.obj-code = p-curr-obj-code )
                 then do:
 run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров p-curr-obj-type &1 p-curr-obj-code &2&3"
                         , p-curr-obj-type
                         , p-curr-obj-code
                         , {&new-line}
                         )).
  assign
  v-view-log = yes.
  {&view-log}.

end.

{ gbl/hostcode.i p-curr-obj-type p-curr-obj-code v-host-code }

{ gbl/conf-rd.i
"'is-jwlr'"
"''"
"''"
0
"''"
"''"
"''"
no
dops
dopst
no-error
}
assign
is-jwlr = (dops = "yes":U) no-error
.

{ gbl/conf-rd.i
"'is-bttl'"
"''"
"''"
0
"''"
"''"
"''"
no
dops
dopst
no-error
}
assign
is-bttl = (dops = "yes":U) no-error
.
{ gbl/conf-rd.i
"'is-ptrl'"
"''"
"''"
0
"''"
"''"
"''"
no
dops
dopst
no-error
}
assign
is-ptrl = (dops = "yes":U) no-error
.
{ gbl/conf-rd.i
 "'is-custm'"
 "''"
 "''"
 0
 "''"
 "''"
 "''"
 no
 custvalue
 custtype
 no-error
 }

run write-log  in p-log-handle(
                                 input 0
                               , "&DLine").
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Пакетное изменение товаров")).

CASE v-call-point :
  when "struct":U then do:
    /*сначала закачем файл и изменения внесем в gds-list!!!*/
    if num-entries(v-call-params, {&delim-par}) <> 3 then do:
      run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Ошибка входных параметров режима изменения состава сырья&1" +
                                "неверное количество элементов списка &2 (ожидалось 3)"
                              , {&new-line}
                              , num-entries(v-call-params, {&delim-par})
                              )).
        assign
        v-view-log = yes.
        {&view-log}.
    end.
    assign
    v-update-mode = entry(1, v-call-params, {&delim-par})
    v-file-name  = entry(2, v-call-params, {&delim-par})
    v-encoding   = entry(3, v-call-params, {&delim-par})
    .
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "Предварительный просмотр файла импорта ...")
                          ).
    run show-counter in p-log-handle .
    input stream inp FROM value (v-File-Name) convert source v-encoding.
    _struct:
    REPEAT :
      IMPORT stream inp UNFORMATTED text-string NO-ERROR.
      if num-entries(text-string, ";") < 2 then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Неверный формат строки (строка файла &1).&2Пропускаем"
                                            ,i-line
                                            ,{&new-line})
                              ).
        assign
        v-view-log = yes.
        next _struct.
      end.
      assign
      i-artic = entry (1, text-string, ";")
      i-struct = entry (2, text-string, ";")
      .
      if num-entries (text-string, ";") > 2 then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Артикул &1 - неправильный, может быть,&3в артикуле встречаются ';' (строка файла &2).&3Пропускаем"
                                            ,i-artic
                                            ,i-line
                                            ,{&new-line})
                              ).
        assign
        v-view-log = yes.
        next _struct.
      end.
      v-found = no.
      for each buf_goods WHERE buf_goods.artic = i-artic:
        if buf_goods.struct <> "":U and v-update-mode = {&add-def} then next.
        { cmp/gds-list.i gds-list assign " " buf_goods }
        assign
        gds-list.struct = i-struct.
        v-found = yes.
      end.
      if not v-found then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Товар с артикулом &1 в БД отсутствует&2Пропускаем"
                                            ,i-artic
                                            ,{&new-line})
                              ).
      end.
      num-rec = num-rec + 1.
      run write-counter in p-log-handle (substitute("Считано из файла &1 записей"
                                              , num-rec
                                              )) no-error.
      run get-stop-state in p-log-handle (
          output v-stop
      ).
    end. /*repeat*/
    run hide-counter in p-log-handle .
    INPUT stream inp CLOSE.
  end. /* when struct*/
  when "tnved":U then do:
    /*сначала закачем файл и изменения внесем в gds-list!!!*/
    if num-entries(v-call-params, {&delim-par}) <> 3 then do:
      run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Ошибка входных параметров режима изменения кодов ТНВЭД&1" +
                                "неверное количество элементов списка &2 (ожидалось 3)"
                              , {&new-line}
                              , num-entries(v-call-params, {&delim-par})
                              )).
        assign
        v-view-log = yes.
        {&view-log}.
    end.
    assign
    v-update-mode = entry(1, v-call-params, {&delim-par})
    v-file-name  = entry(2, v-call-params, {&delim-par})
    v-encoding   = entry(3, v-call-params, {&delim-par})
    .
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "Предварительный просмотр файла импорта ...")
                          ).
    run show-counter in p-log-handle .
    input stream inp FROM value (v-File-Name) convert source v-encoding.
    _tnved:
    REPEAT :
      IMPORT stream inp UNFORMATTED text-string NO-ERROR.
      if num-entries(text-string, ";") < 3 then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Неверный формат строки (строка файла &1).&2Пропускаем"
                                            ,i-line
                                            ,{&new-line})
                              ).
        assign
        v-view-log = yes.
        next _tnved.
      end.
      i-line = i-line + 1.
      i-prod-code = 0.
      assign
      i-artic = entry (1, text-string, ";")
      i-prod-code = integer(entry(2, text-string, ";"))
      i-tnved = entry (3, text-string, ";")
      no-error
      .
      if num-entries (text-string, ";") > 3 then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Артикул &1 - неправильный, может быть,&3в артикуле встречаются ';' (строка файла &2).&3Пропускаем"
                                            ,i-artic
                                            ,i-line
                                            ,{&new-line})
                              ).
        assign
        v-view-log = yes.
        next _tnved.
      end.
      if length(i-tnved) <> 10 then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Код ТНВЭД &1 - должен быть 10 символов (строка файла # &2)&3Пропускаем"
                                            ,i-tnved
                                            ,i-line
                                            ,{&new-line})
                              ).
        assign
        v-view-log = yes.
        next _tnved.
      end.
      v-found = no.
      for each buf_goods WHERE
             buf_goods.artic = i-artic
          and buf_goods.prod-type = {&cmp}
          and buf_goods.prod-code = i-prod-code:
        if buf_goods.tnved <> "":U and v-update-mode = {&add-def} then next.
        { cmp/gds-list.i gds-list assign " " buf_goods }
        assign
        gds-list.tnved = i-tnved
        v-found = yes.
      end.
      if not v-found then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Товар с артикулом &1 (производитель &2&3 в БД отсутствует&4Пропускаем"
                                            ,i-artic
                                            ,{&cmp}
                                            ,i-prod-code
                                            ,{&new-line})
                              ).
      end.
      num-rec = num-rec + 1.
      run write-counter in p-log-handle (substitute("Считано из файла &1 записей"
                                              , num-rec
                                              )) no-error.
      run get-stop-state in p-log-handle (
          output v-stop
      ).
    end. /*repeat*/
    run hide-counter in p-log-handle .
    INPUT stream inp CLOSE.
  end. /*when tnved*/
  when "alpha1":U then do:
    /*сначала закачем файл и изменения внесем в gds-list!!!*/
    if num-entries(v-call-params, {&delim-par}) <> 3 then do:
      run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Ошибка входных параметров режима изменения страны происхождения товара&1" +
                                "неверное количество элементов списка &2 (ожидалось 3)"
                              , {&new-line}
                              , num-entries(v-call-params, {&delim-par})
                              )).
        assign
        v-view-log = yes.
        {&view-log}.
    end.
    /*сначала закачем файл и изменения внесем в gds-list!!!*/
    if num-entries(v-call-params, {&delim-par}) <> 3 then do:
      run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Ошибка входных параметров режима изменения страны происхождения товара&1" +
                                "неверное количество элементов списка &2 (ожидалось 3)"
                              , {&new-line}
                              , num-entries(v-call-params, {&delim-par})
                              )).
        assign
        v-view-log = yes.
        {&view-log}.
    end.
    assign
    v-update-mode = entry(1, v-call-params, {&delim-par})
    v-file-name  = entry(2, v-call-params, {&delim-par})
    v-encoding   = entry(3, v-call-params, {&delim-par})
    .
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "Предварительный просмотр файла импорта ...")
                          ).
    run show-counter in p-log-handle .
    input stream inp FROM value (v-File-Name) convert source v-encoding.
    _alpha1:
    REPEAT :
      IMPORT stream inp UNFORMATTED text-string NO-ERROR.
      if num-entries(text-string, ";") < 3 then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Неверный формат строки (строка файла &1).&2Пропускаем"
                                            ,i-line
                                            ,{&new-line})
                              ).
        assign
        v-view-log = yes.
        next _alpha1.
      end.
      i-prod-code = 0.
      assign
      i-artic = entry (1, text-string, ";")
      i-prod-code = integer(entry(2, text-string, ";"))
      i-alpha1 = entry (3, text-string, ";")
      no-error
      .
      if num-entries (text-string, ";") > 3 then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Артикул &1 - неправильный, может быть,&3в артикуле встречаются ';' (строка файла &2).&3Пропускаем"
                                            ,i-artic
                                            ,i-line
                                            ,{&new-line})
                              ).
        assign
        v-view-log = yes.
        next _alpha1.
      end.
      if not can-find(first ub.country no-lock where ub.country.alpha1 = i-alpha1) then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Код страны &1 отсутствует в справочнике стран (строка файла # &2)&3Пропускаем"
                                            ,i-alpha1
                                            ,i-line
                                            ,{&new-line})
                              ).
        assign
        v-view-log = yes.
        next _alpha1.
      end.
      v-found = no.
      for each buf_goods WHERE
             buf_goods.artic = i-artic
          and buf_goods.prod-type = {&cmp}
          and buf_goods.prod-code = i-prod-code:
        if (buf_goods.alpha1 <> "":U
           and buf_goods.alpha1 <> "XX":U )
        and v-update-mode = {&add-def} then next.
        { cmp/gds-list.i gds-list assign " " buf_goods }
        assign
        gds-list.alpha1 = i-alpha1
        v-found = yes.
      end.
      if not v-found then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Товар с артикулом &1 (производитель &2&3 в БД отсутствует&4Пропускаем"
                                            ,i-artic
                                            ,{&cmp}
                                            ,i-prod-code
                                            ,{&new-line})
                              ).
      end.
      num-rec = num-rec + 1.
      run write-counter in p-log-handle (substitute("Считано из файла &1 записей"
                                              , num-rec
                                              )) no-error.
      run get-stop-state in p-log-handle (
          output v-stop
      ).
    end. /*repeat*/
    run hide-counter in p-log-handle .
    INPUT stream inp CLOSE.
  end. /*when alpha1*/
end case.
num-rec = 0.



if v-do[{&unit-cli}] then do:
  FIND FIRST cli-units No-LOCK WHERE
           cli-units.unit-name = p-unit-cli No-ERROR.
end.
_gds-list:
  FOR EACH gds-list NO-LOCK,
      FIRST buf_goods exclusive-lock WHERE
            buf_goods.prod-type = gds-list.prod-type AND
            buf_goods.prod-code = gds-list.prod-code AND
            buf_goods.artic = gds-list.artic,
      FIRST buf_gds-prt no-lock where
            buf_gds-prt.upper-code = buf_goods.prt-root
            on error undo, next:
    num-rec = num-rec + 1.
    FIND FIRST buf_units No-LOCK WHERE
    buf_units.unit-name = buf_goods.unit-base No-ERROR.
    if v-do[{&unit-cli}] then do:
        if NOT can-do(buf_units.type, {&petrolium}) = can-do(cli-units.type, {&petrolium})
        then next.
    end.
    if buf_goods.unit-base = p-unit-cli
    and p-cli-base-rate <> 1
    and v-do[{&cli-base-rate}] then next.
    assign
    error-status:error = no
    v-main-error = no
    v-gds-rec  = recid(ub.goods)
    .
    IF v-do[{&tax}] then do:
       /*заполним tt-tax*/
      for each buf_tt-tax:
        FIND LAST ub.tax-rate-gds No-LOCK WHERE
                  ub.tax-rate-gds.gds-code = buf_goods.gds-code AND
                  ub.tax-rate-gds.tax-code = buf_tt-tax.tax-code AND
                  ub.tax-rate-gds.host-code = 0 AND
                  ub.tax-rate-gds.obj-type = "":U AND
                  ub.tax-rate-gds.obj-code = 0 AND
                  ub.tax-rate-gds.fact-order <= var-fact-order NO-ERROR.
        assign
        buf_tt-tax.fact-date = p-date
        buf_tt-tax.fact-order = var-fact-order
        buf_tt-tax.tax-rate-gds-rc = (if available ub.tax-rate-gds then recid(ub.tax-rate-gds) else ?)
        .
      end.
    end.
    if buf_goods.gds-type = {&gds-office} then dO:
      FIND FIRST buf_gds-obj no-lock where
                buf_gds-obj.gds-code = buf_goods.gds-code
            AND buf_gds-obj.obj-type = p-curr-obj-type
            AND buf_gds-obj.obj-code = p-curr-obj-code no-error .
    end.
    CASE v-call-point:
      when "struct":U then do:
        assign
        p-struct = gds-list.struct.
      end.
      when "tnved":U then do:
        assign
        p-tnved = gds-list.tnved.
      end.
      when "alpha1":U then do:
        assign
        p-alpha1 = gds-list.alpha1.
      end.
    END CASE.

     run ref/goods01.p (
    input parparentproc
  , input {&update}
  , input no /*par-copymode */
  , input 0 /*par-alt-bc-mode as integer нужно ли вводить ДОП БК вместе с товаром*/
  , input no /*par-manual as logical мз карточки товара - yes*/
  , input yes /*par-silence as logical  ругаемся вслух или ?*/
  , input no /* import */
  , input no /*par-file as logical идет импоррт из файла - из карточки товара*/
  , input no /*par-single-record as logical надо сохранить только одну запись - потом выход в справ*/
  , input v-host-code /*par-host-code like ub.sysconf.host-code */
  , input p-curr-obj-type /*par-obj-type like ub.clients.obj-type */
  , input p-curr-obj-code /*par-obj-code like ub.clients.obj-code */
  , input (buf_goods.gds-type = {&gds-goods}) /*товар - yes услуга no*/
  , input ? /*par-copy-rec as recid recid записи с которой копируем*/
  , input buf_goods.gds-code
  , input buf_goods.artic
  , input buf_goods.prod-type
  , input buf_goods.prod-code
  , input buf_gds-prt.node-code
  , input buf_goods.grp-code
  , input (if v-do[{&gds-name}] then p-gds-name else  buf_goods.gds-name)
  , input "":U /*par-saved-name like ub.buf_goods.gds-name no-undo */
  , input (if v-do[{&engl-name}] then p-engl-name else  buf_goods.engl-name)
  , input (if v-do[{&label-name}] then p-label-name else  buf_goods.label-name)
  , input (if v-do[{&chk-name}] then p-chk-name else  buf_goods.chk-name)
  , input (if v-do[{&alpha1}] then p-alpha1 else  buf_goods.alpha1)
  , input buf_goods.unit-base
  , input (if v-do[{&unit-cli}] then p-unit-cli else  buf_goods.unit-cli)
  , input (IF v-do[{&max-rate}] AND LOOKUP({&twounit}, buf_units.type) > 0
          then p-max-rate
          else buf_goods.max-rate)
  , input (IF v-do[{&min-rate}] AND LOOKUP({&twounit}, buf_units.type) > 0
          then p-min-rate
          else buf_goods.min-rate)
  , input (IF v-do[{&cli-base-rate}] then p-cli-base-rate else buf_goods.cli-base-rate)
  , input (IF v-do[{&qnty-cart}] then p-qnty-cart else buf_goods.qnty-cart)
  /* todo base!!!!*/
  , input (IF v-do[{&ms-base}]  then p-ms-base else buf_goods.ms-base)
  , input (IF v-do[{&wt-base}]  then p-wt-base else buf_goods.wt-base)
  /**/
  , input (IF v-do[{&ms-cart}] then p-ms-cart else buf_goods.ms-cart)
  , input (IF v-do[{&wt-cart}] then p-wt-cart else buf_goods.wt-cart)
  , input (IF v-do[{&calc-method}] then p-calc-method else buf_goods.calc-method)
  , input (IF v-do[{&increase-pc}] then p-increase-pc else buf_goods.increase-pc)
  , input (IF v-do[{&negative-rest}] then p-negative-rest else buf_goods.negative-rest)
  , input (if buf_goods.gds-type = {&gds-office} and available buf_gds-obj
           then buf_gds-obj.price-base
           else 0)
  , input (if buf_goods.gds-type = {&gds-office} and available buf_gds-obj
           then  buf_gds-obj.price-rubl
           else 0)
  , input (IF v-do[{&okdp}] then p-okdp else buf_goods.okdp)
  , input (IF v-do[{&destin}] then p-destin else buf_goods.destin)
  , input (IF v-do[{&attrib}] then p-attrib else buf_goods.attrib)
  , input (IF v-do[{&user-rule}] then p-user-rule else buf_goods.user-rule)
  , input (IF v-do[{&sert}]  then p-sert else buf_goods.sert)
  , input (IF v-do[{&struct}] then p-struct else buf_goods.struct)
  , input (IF v-do[{&deadline}] then p-deadline else buf_goods.deadline)
  , input (IF v-do[{&cond-keep-code}] then p-cond-keep-code else buf_goods.cond-keep-code)
  , input (IF v-do[{&sort}] then p-sort else buf_goods.sort)
  , input (IF v-do[{&proof}] then p-proof else buf_goods.proof)
  , input (IF v-do[{&normal-wastage}] then p-normal-wastage else buf_goods.normal-wastage)
  , input (IF v-do[{&normal-waste}] then p-normal-waste else buf_goods.normal-waste)
  , input (IF v-do[{&tnved}]  then p-tnved else buf_goods.tnved)
  , input (IF v-do[{&nationality}] then p-nationality else buf_goods.nationality)
  , input (IF v-do[{&unit-cst}] then p-unit-cst else buf_goods.unit-cst)
  , input (IF v-do[{&cst-base-rate}] then p-cst-base-rate else buf_goods.cst-base-rate)
  , input (if v-do[{&fbr-grp-code}] then p-fbr-grp-code else buf_goods.fbr-grp-code)
  , input (IF v-do[{&ps}] then p-PS else buf_goods.PS)
    , input no /*unq-artc*/
  , input is-jwlr
  , input is-bttl
  , input is-ptrl
  , input custvalue
  , input no /*par-dif-nam1 нам неважно*/
  , input no /*par-dif-nam2 нам неважно */
  , input no /*par-ArtDis нам неважно */
  , input 0 /*par-BarDis нам неважно */
  , input-output v-gds-rec
  , output v-nbc
                    ) no-error .
  if error-status:error then do:
    assign
    v-main-error = yes.
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Ошибка изменения записи товара с кодом &1:&2&3 &4"
                          , gds-list.gds-code
                          , {&new-line}
                          , error-status:get-message(1)
                          , return-value
                          ) ).
    assign
    v-view-log = yes.
  end.
  if not v-main-error then do:
   IF v-do[{&stts}] then do:
      v-stts = (if p-stts then 1 else 0).
      run ref/goods02.p (
                       input recid(buf_goods)
                      ,input yes /*p-silent*/
                      ,input-output v-stts) no-error.
      if error-status:error then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Ошибка изменения статуса товара с кодом &1:&2&3 &4"
                              , gds-list.gds-code
                              , {&new-line}
                              , error-status:get-message(1)
                              , return-value
                              ) ).
        assign
        v-view-log = yes.
      end.
    end.
  end.
  IF v-main-error then do:
    message
    substitute("Не удалось изменить товар с кодом &1&2" +
               "&3 &4&5 - &6&2" +
               "Продолжить изменение товаров по списку?"
              ,buf_goods.gds-code
              , {&new-line}
              ,buf_goods.artic
              ,buf_goods.prod-type
              ,buf_goods.prod-code)
   view-as alert-box ERROR buttons YES-NO update glog.
   if not glog then do:
     IF num-rec > num-rec-ok then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Из выбранных &1 товаров удалось отредактировать &2"
                              , num-rec
                              , num-rec-ok
                              ) ).
        return.
     end.
   end.
  end.
  else num-rec-ok = num-rec-ok + 1.
  run show-counter in p-log-handle .
  run write-counter in p-log-handle (substitute("Обработано &1 из них успешно &2"
                                              , num-rec
                                              , num-rec-ok
                                              )) no-error.
  run get-stop-state in p-log-handle (
      output v-stop
  ).
  if v-stop then do:
    leave _gds-list.
  end.
end.
IF num-rec > num-rec-ok then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("&3&4Из выбранных &1 товаров удалось отредактировать &2&4Информация находится в файле &5.txt"
                        , num-rec
                        , num-rec-ok
                        , (if v-stop then "Процесс прерван пользователем" else "":U)
                        , {&new-line}
                        , v-call-point
                        ) ).
end.
else do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("&1&2Пакетное изменение по списку товаров прошло"
                            , (if v-stop then "Процесс прерван пользователем" else "":U)
                            , {&new-line}
                              ) ).

end.