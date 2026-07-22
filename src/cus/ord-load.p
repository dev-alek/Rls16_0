block-level on error undo, throw.
/*

$Revision: bbf1530230d5, 2753, rls $
$Author: EShklyar $
$Date: Сб фев 20 15:59:21 2021 +0300 $
$Workfile: ord-load.p $
$Archive: cus/ord-load.p $

Загрузка заказа из Excel

Автор: Комаров Иван Сергеевич
Дата создания: 07/23/10
Author: Ivan Komarov
Creation date: 07/23/10

Автор1: Чернова Светлана Александровна
Дата создания1: 08/21/01

*/

define input parameter parParentProc  as widget-handle no-undo .
define input parameter p-type-ord     as character     no-undo .

define variable vss-revision    as character no-undo init "$Revision: bbf1530230d5, 2753, rls $":u .
define variable vss-author      as character no-undo init "$Author: EShklyar $":u .
define variable vss-date        as character no-undo init "$Date: Сб фев 20 15:59:21 2021 +0300 $":u .
define variable vss-Workfile    as character no-undo init "$Workfile: ord-load.p $":u .
define variable vss-archive     as character no-undo init "$Archive: cus/ord-load.p $":u .
define variable vss-description as character no-undo init "Загрузка заказа из Excel".
{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/r-page1.i  new }
{ cmp/library.i      }
{ cus/df-zakaz.i new }
{ gbl/waitfram.i noprocess }
{ cmp/showinf.i      }
{ gbl/getcntxt.i def }
{ cus/ord-code.i def }
{ cus/z-qnty.i   def }
{ gbl/usr-flt.i      }
{ cus/ord-outp.i def }

define variable g#host-name  as character no-undo .
define variable g#host-code  as integer   no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .
define variable g#log        as logical   no-undo .
define variable g#report-num as integer   no-undo .
define variable g#out-pay    as integer   no-undo .
define variable g#db-remote  as logical   no-undo .
define variable v-obj-type   as character no-undo .
define variable v-obj-code   as integer   no-undo .
/* Нужные колонки для засоски*/
define variable col-gds-code     as integer   no-undo .
define variable col-typecode-obj as integer   no-undo .
define variable col-zakz-qnty    as integer   no-undo .
define variable col-price        as integer   no-undo .
define variable col-cli-type     as integer   no-undo .
define variable col-cli-code     as integer   no-undo .
define variable col-cli-art      as integer   no-undo .
define variable col-choice       as integer   no-undo .

define temp-table tmp#objqnty no-undo
field gds-code as integer
field obj      as character
field qnty     as decimal
field cli-type as character
field cli-code as character
index pi gds-code cli-type cli-code
.
define temp-table tt-table no-undo
    FIELD id AS INTEGER
    FIELD new-id AS INTEGER
    INDEX p1 IS PRIMARY id
    .

function new-n returns integer
    ( input num as integer ) :
    find first tt-table where
              tt-table.id = num no-error .
    if error-status :error then return num.
    else return tt-table.new-id .
end function.

{ gbl/getcntxt.i get }
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
  g#db-remote   = (v-cntxt-db-num <> 0)
.
{ gbl/hostname.i
  store-type
  store-code
  g#host-code
  g#host-name
  }
run get-report-num in parParentProc ( output g#report-num ).
define buffer buf_sysconf for ub.sysconf  .
  find first buf_sysconf no-lock where buf_sysconf.host-code = g#host-code .
  g#out-pay = buf_sysconf.out-pay.


if not (
  p-type-ord = {&O-P} or
  p-type-ord = {&O-O} or
  p-type-ord = {&F-P} or
  p-type-ord = {&O-F} ) then do:
  message "Неопределен тип заказа. Загрузка невозможна." view-as alert-box information .
   return .
end.


&scop if-not-true ~
 if not g#log then return no-apply.

&scop Excel-visable ~
  assign ~
    chExcelApplication:interactive = true ~
    chExcelApplication:screenupdating = true ~
    chExcelApplication:visible = true .

&scop Excel-invisable ~
  assign ~
    chExcelApplication:interactive = false  ~
    chExcelApplication:ScreenUpdating = false  ~
    chExcelApplication:visible = false  .

&glob rezalt "Результат"

define buffer    for-cli for ub.clients.
define variable  ff as character no-undo .
define variable  var-name-Sheet as character no-undo .

define temp-table tmp#p-zakaz no-undo
field gds-code  like  ub.goods.gds-code
field cli-type  like  ub.cli-gds.cli-type
field cli-code  like  ub.cli-gds.cli-code
field cli-art   as character
field price-cli like  ub.cli-gds.price-cli
field qnty      like  ub.cli-gds.in-qnty
index pi   cli-type cli-code gds-code.

define variable  var-l-pay-day as integer no-undo .
define variable  l-date    as date no-undo .
define variable  l-date-1  as date no-undo .
define variable  l-date-2  as date no-undo .
define variable   v-base-rate as decimal   no-undo .
define variable   v-base-scale as decimal   no-undo .

{ gbl/baserate.i
  g#host-code
  to-day
  v-base-rate
  v-base-scale
  }

  run init-p .

  message  "Импорт из Excel данных по заказу ." skip
           "При импорте используется работа с com объектом Excel, поэтому не прерывайте работу Excel и не нарушайте уже законнекченную связь!"
           skip "Продолжать ?"
           view-as alert-box question buttons yes-no update g#log.
           {&if-not-true}
   chWorkBook = chExcelApplication:activeWorkBook no-error.
   g#log = false .
   define variable okpressed as logical initial true no-undo.
   system-dialog get-file ff
  title      "Выберите файл ..."
  filters    "Excel (*.xls)"   "*.xls"
              use-filename
              must-exist
              update okpressed.

    if okpressed = true then do:
       run ex-file in this-procedure  (ff, false) .
    end.
    else return no-apply .

   chWorkBook   = chExcelApplication:activeWorkBook no-error.
   chWorkSheet  = chExcelApplication:Sheets:item(1):select  no-error.
   chWorkSheet  = chExcelApplication:Sheets:item(1) no-error.
   g#log = false .

   message "Предварительно посмотреть файл " chWorkBook:fullname " ? "
             view-as alert-box question buttons yes-no update g#log.
    if g#log =  true then  do:
        {&Excel-visable}
    end.

   assign
     g#log = true
     .

    var-name-Sheet = chExcelApplication:Sheets:item(1):name no-error.

    if   var-name-Sheet = {&rezalt} then do:
       message "Начинаем импорт  " skip
              "файл:  " chWorkBook:fullname  skip
              "закладка: "  var-name-Sheet  skip
              "Продолжить ? "
              view-as alert-box question buttons yes-no update g#log.
       if g#log = true then
          run export-proc in this-procedure (1).
    end.
    else do:
      message "Начинаем импорт  " skip
              "Файл сделан не в системе 'ЗАКАЗЫ' !!! " skip
              "файл:  " chWorkBook:fullname  skip
              "Продолжить ? "
             view-as alert-box question buttons ok-cancel update g#log.
      if g#log = true then
         run export-proc in this-procedure (1).
    end.

release object chworksheet no-error.
release object chworkbook no-error.
chexcelapplication :quit() no-error .
if error-status :error then message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value skip
  "123"
  view-as alert-box error
.
release object chexcelapplication  no-error.





procedure ex-file :
define input parameter ff as character no-undo .
define input parameter ex as logical no-undo .

  if ex = false then do:
    create "Excel.Application" chExcelApplication no-error.
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        undo, return error .
    end.    
    if ff = ""  then do:
      chWorkBook   = chExcelApplication:WorkBooks:add( ).
    end.
    else do:
      chWorkBook   = chExcelApplication:WorkBooks:open( ff ).
    end.
  end.

  {&Excel-invisable}
  chWorkSheet  = chExcelApplication:Sheets:item (1).
end procedure.


procedure export-proc :
define input parameter numberSheet as integer no-undo .
define variable  v#doc-code   as   character no-undo .
define variable  v#doc-code1  as   character no-undo .
define variable  v#gds-code   like ub.goods.gds-code  no-undo .
define variable  kol-z        as   integer   no-undo init 0.
define variable  k            as   integer   no-undo init 0.
define variable  ik           as   integer   no-undo init 1 .
define variable  ord-qnty     as   decimal   no-undo init 0.
define variable  ord-sum-cli  as   decimal   no-undo init 0 .
define variable  v-zakaz-qnty like ub.cli-gds.in-qnty no-undo init ? .
define variable v-temp-1 as character no-undo .
define variable v-temp-2 as character no-undo .
define variable v-temp-3 as character no-undo .
define variable v-temp-obj as character no-undo .
define variable  v-ok         as   logical   no-undo .
define variable  v-mess       as   character no-undo .
define variable  v-erase      as   logical   no-undo .
define variable  v-stop       as   integer   no-undo init 0. /*страховка от левого файла*/

{ cmp/df-sub.i pr }
 l-date-1   = date   (chWorkSheet:range ("G3"):value) no-error .
 l-date-2   = date   (chWorkSheet:range ("I3"):value) no-error .
 l-date     = date   (chWorkSheet:range ("D3"):value) no-error .
 var-l-pay-day  = integer(l-date-2 - l-date-2 + 1 )  .



define variable ii as int init 4 no-undo.


run waitfram-show in this-procedure ("Ждите...").

mm:
 repeat  /* on endkey undo, retry  */ :
/* закачка во временную таблицу из ексел*/
    ii = ii  + 1.
        if numberSheet = 1 then do:
            v-temp-1 = chWorkSheet:range("A" + string(ii)):value  no-error .
            if ( v-temp-1 = "END FILE":U  ) then leave mm.
            /*счетчик пустых кол-ва строк подряд*/
            v-stop = ( if v-temp-1 = "" or v-temp-1 = ? then v-stop + 1 else 0 ) .
            /*это файл не нашего формата - не заканчивается на END FILE, больше 100 пустых строк подряд*/
            if v-stop > 100 then do:
                message "Файл не соответствует заданному формату." view-as alert-box error .
                return error .
            end.
            v-temp-2 = chWorkSheet:range (col-name[col-gds-code] + string(ii)):value no-error .
            if not( v-temp-2 = "" or v-temp-2 = ?) then
                assign
                  v#gds-code  = chWorkSheet:range (col-name[col-gds-code] + string(ii)):value
                  no-error .

            v-temp-obj = chWorkSheet:range (col-name[col-typecode-obj] + string(ii)):value no-error .
            if  v-temp-obj <> "" and v-temp-obj <> ?  then do:
               create tmp#objqnty.
               assign
                 tmp#objqnty.gds-code = v#gds-code
                 tmp#objqnty.obj      = v-temp-obj
                 tmp#objqnty.cli-type = ''
                 tmp#objqnty.cli-code = ''
                 .
                 tmp#objqnty.qnty = chWorkSheet:range (col-name[col-zakz-qnty] + string(ii)):value no-error .
                 if tmp#objqnty.qnty = ? then tmp#objqnty.qnty = 0 .

                assign
                  v-obj-type = entry(1,tmp#objqnty.obj ,' ')
                  v-obj-code = integer(entry(2,tmp#objqnty.obj ,' '))
                .
                { gbl/goassizt.i
                  p-type-ord
                  v#gds-code
                  v-obj-type
                  v-obj-code
                  false
                  v-ok
                  v-mess
                  no-error
                }
                if not v-ok then do:
                  run creat-tt (tmp#objqnty.gds-code , v-mess ) .
                  v-erase = true.
                  delete tmp#objqnty .
                  next.
                end.
            end.

            assign
              v-temp-3 = chWorkSheet:range (col-name[col-choice] + string(ii)):value
              v-zakaz-qnty = absolute(decimal(chWorkSheet:range (col-name[col-zakz-qnty] + string(ii)):value))
            no-error.
            if v-temp-3  = "*" and v-zakaz-qnty <> 0 and v-zakaz-qnty <> ? then do : /* Проверим можно ли закачивать этого контрагента и количество*/
                  create tmp#p-zakaz .
                  assign
                    tmp#p-zakaz.gds-code  = v#gds-code
                    tmp#p-zakaz.cli-type  =                  chWorkSheet:range (col-name[col-cli-type] + string(ii)):value
                    tmp#p-zakaz.cli-code  =                  chWorkSheet:range (col-name[col-cli-code] + string(ii)):value
                    tmp#p-zakaz.cli-art   =                  chWorkSheet:range (col-name[col-cli-art] + string(ii)):value
                    tmp#p-zakaz.price-cli = absolute(decimal(chWorkSheet:range (col-name[col-price] + string(ii)):value))
                    tmp#p-zakaz.qnty      = absolute(decimal(chWorkSheet:range (col-name[col-zakz-qnty] + string(ii)):value))
                    no-error.
                    if tmp#p-zakaz.cli-art = ? then do:
                       assign tmp#p-zakaz.cli-art = "" .
                    end.
                    for each tmp#objqnty where
                             tmp#objqnty.gds-code = v#gds-code and
                             tmp#objqnty.cli-type = '' and
                             tmp#objqnty.cli-code = ''
                             :
                        assign
                          tmp#objqnty.cli-type = tmp#p-zakaz.cli-type
                          tmp#objqnty.cli-code = string(tmp#p-zakaz.cli-code)
                        .
                    end.

                    If p-type-ord = {&o-f}  then do:
                       assign
                        tmp#p-zakaz.cli-code = g#host-code
                        tmp#p-zakaz.cli-type = {&cmp}
                       .
                    end.
            end. /**/

        end. /* numbershit = 1 */
 end.  /* repeat */
if v-erase = true then do:
      run view-exept-gds (substitute("Есть товары, не добавленные в заказ !&1Просмотреть список ?", {&new-line})) . .
end.

RELEASE OBJECT chWorksheet NO-ERROR.
RELEASE OBJECT chWorkbook NO-ERROR.
chExcelApplication :QUIT() no-error .
if error-status :error then message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value skip
  "2222"
  view-as alert-box error
.
RELEASE OBJECT  chExcelApplication  NO-ERROR.
/*-------------------------------------------------*/

define buffer buf_cli-gds  for ub.cli-gds  .
define buffer buf_clients  for ub.clients  .
define buffer buf_doc-line for ub.doc-line  .
define buffer bf-units-cli for ub.units.

define variable v-pcvat as decimal   no-undo .
define variable v-e-m as character no-undo .
define variable v-spis as character no-undo .

  for each  tmp#p-zakaz no-lock
      break by tmp#p-zakaz.cli-type
            by tmp#p-zakaz.cli-code
            by tmp#p-zakaz.gds-code :

      /* закачка в ord-doc ord-line */
      v-spis = "" .
      if first-of(tmp#p-zakaz.cli-code) then do :

      define variable v-i-doc as character no-undo .
      { cus/ord-code.i
          'main'
          v-cntxt-db-num
          v-cntxt-obj-type
          v-cntxt-obj-code
          v-i-doc
          v#doc-code
          }

          assign
            ord-qnty = 0
            ord-sum-cli = 0
            k = 0
            .
          if ik = 1  then assign
                           v#doc-code1 = v#doc-code
                           ik = 0
                           .
      end.


           find first ub.goods where ub.goods.gds-code = tmp#p-zakaz.gds-code no-lock no-error.
           find first ub.gds-obj no-lock where
                      ub.gds-obj.obj-type = store-type and
                      ub.gds-obj.obj-code = store-code and
                      ub.gds-obj.gds-code = tmp#p-zakaz.gds-code
                      no-error.
           v-e-m = ''.
           if available ub.goods then do :
                assign
                  k = k + 1
                .
                  for each tmp#objqnty where
                           tmp#objqnty.gds-code = tmp#p-zakaz.gds-code and
                           tmp#objqnty.cli-type = tmp#p-zakaz.cli-type and
                           tmp#objqnty.cli-code = string(tmp#p-zakaz.cli-code)
                           :
                            assign
                              v-obj-type = entry(1,tmp#objqnty.obj ,' ')
                              v-obj-code = integer(entry(2,tmp#objqnty.obj ,' '))
                              v-e-m = 'Импорт с объектами'
                            .
                            if lookup( tmp#objqnty.obj + ',' , v-spis ) = 0 then
                               v-spis = trim( v-spis ) + tmp#objqnty.obj + ','.
                            run create-obj-temp (
                                v#doc-code           ,
                                tmp#objqnty.gds-code ,
                                v-obj-type ,
                                v-obj-code ,
                                decimal(tmp#objqnty.qnty)
                                ) .
                end.

                find first bf-units-cli where bf-units-cli.unit-name = ub.goods.unit-cli no-lock no-error.

                create shar_ord-line no-error.
                assign
                  shar_ord-line.doc-code    = v#doc-code
                  shar_ord-line.prod-type   = ub.goods.prod-type
                  shar_ord-line.prod-code   = ub.goods.prod-code
                  shar_ord-line.artic       = ub.goods.artic
                  shar_ord-line.gds-code    = ub.goods.gds-code
                  shar_ord-line.cli-art     = tmp#p-zakaz.cli-art
                  shar_ord-line.qnty        = tmp#p-zakaz.qnty
                  shar_ord-line.order-qnty  = tmp#p-zakaz.qnty
                  shar_ord-line.initial-qnty = tmp#p-zakaz.qnty
                  shar_ord-line.cli-qnty    = ( if lookup({&pieces}, bf-units-cli.type) > 0
                    and  trunc (tmp#p-zakaz.qnty / ub.goods.cli-base-rate, 0) <> tmp#p-zakaz.qnty / ub.goods.cli-base-rate
                    then trunc (tmp#p-zakaz.qnty / ub.goods.cli-base-rate, 0)
                    else tmp#p-zakaz.qnty / ub.goods.cli-base-rate )
                  shar_ord-line.price-cli   = tmp#p-zakaz.price-cli * ub.goods.cli-base-rate
                  shar_ord-line.sum-cli     = shar_ord-line.price-cli * shar_ord-line.cli-qnty
                  shar_ord-line.price-rubl  = tmp#p-zakaz.price-cli
                  shar_ord-line.price-base  = ( tmp#p-zakaz.price-cli ) / v-base-rate * v-base-scale
                  shar_ord-line.sum-rubl    = shar_ord-line.price-rubl * shar_ord-line.qnty
                  shar_ord-line.sum-base    = shar_ord-line.price-base * shar_ord-line.qnty
                  shar_ord-line.unit-cli    = ub.goods.unit-cli
                  shar_ord-line.line-num    = k
                  .
                assign
                  ord-qnty    = ord-qnty + tmp#p-zakaz.qnty
                  ord-sum-cli = ord-sum-cli + ( shar_ord-line.cli-qnty * shar_ord-line.price-cli )
                  v-pcvat = 0
                  .
                    for each buf_cli-gds no-lock  where
                             buf_cli-gds.artic         = ub.goods.artic      and
                             buf_cli-gds.prod-code     = ub.goods.prod-code  and
                             buf_cli-gds.prod-type     = ub.goods.prod-type  and
                             buf_cli-gds.host-code     = g#host-code   ,
                      first buf_clients no-lock where
                            buf_clients.obj-type = buf_cli-gds.cli-type and
                            buf_clients.obj-code = buf_cli-gds.cli-code  ,
                      first buf_doc-line no-lock where
                            buf_doc-line.doc-code   = buf_cli-gds.in-code and
                            buf_doc-line.artic      = buf_cli-gds.artic and
                            buf_doc-line.prod-type  = buf_cli-gds.prod-type and
                            buf_doc-line.prod-code  = buf_cli-gds.prod-code
                            :
                         v-pcvat = buf_doc-line.vat-pc.
                    end.

                   assign
                     shar_ord-line.vat-pc  = v-pcvat
                   .
           end.

    if last-of(tmp#p-zakaz.cli-code) then do:
          find first for-cli no-lock where
                     for-cli.obj-type = tmp#p-zakaz.cli-type and
                     for-cli.obj-code = tmp#p-zakaz.cli-code
                     no-error.
              if not available for-cli then do:
                 message "В таблице для импорта не верно задано значение Поставщика "
                  tmp#p-zakaz.cli-type
                  tmp#p-zakaz.cli-code
                  view-as alert-box error .
                next.
              end.

          run waitfram-show in this-procedure ("Создается заказ № " + string(v#doc-code) + " для " + for-cli.obj-name ).
          kol-z = kol-z + 1.
          if v-e-m <> "" then do:
              v-e-m = trim(v-e-m) + ' :&' + trim (v-spis) .
          end.

          create shar_ord-doc.
          assign
              shar_ord-doc.doc-code     = v#doc-code
              shar_ord-doc.doc-date     = to-day
              shar_ord-doc.cli-code     = for-cli.obj-code
              shar_ord-doc.cli-name     = for-cli.obj-name
              shar_ord-doc.cli-type     = for-cli.obj-type
              shar_ord-doc.creid        = v-cntxt-userid
              shar_ord-doc.agnt         = ?
              shar_ord-doc.boss         = ?
              shar_ord-doc.fact-date    = ?
              shar_ord-doc.pay-code     = g#out-pay
              shar_ord-doc.ship-date    = l-date
              shar_ord-doc.sum-service  = 0
              shar_ord-doc.sum-ship     = 0
              shar_ord-doc.flag_        = false
              shar_ord-doc.status_      = {&g___new}
              shar_ord-doc.wrkr         = ?
              shar_ord-doc.host-code    = g#host-code
              shar_ord-doc.doc-type     = p-type-ord
              shar_ord-doc.tot-lines    = k
              shar_ord-doc.order-type   = 0
              shar_ord-doc.cycle-day    = 0
              shar_ord-doc.start-date   = l-date-1
              shar_ord-doc.end-date     = l-date-2
              shar_ord-doc.date-sale-1  = l-date-1
              shar_ord-doc.date-sale-2  = l-date-2
              shar_ord-doc.pay-day      = var-l-pay-day
              shar_ord-doc.obj-code     = store-code
              shar_ord-doc.obj-type     = store-type
              shar_ord-doc.slt-type     = {&without-slt}
              shar_ord-doc.vat-type     = {&inc-vat}
              shar_ord-doc.exch-code    = 0
              shar_ord-doc.exch-date    = to-day
              shar_ord-doc.e-method     = v-e-m
              .
            find ub.currency where ub.currency.curr-code = 0 no-lock no-error.
            find last ub.curr-accnt where ub.curr-accnt.curr-code = ub.currency.curr-code  use-index pi no-lock no-error.
              if available ub.curr-accnt then
                 assign
                    shar_ord-doc.exch-rate  = ub.curr-accnt.exch-rate
                    shar_ord-doc.exch-scale = ub.curr-accnt.exch-scale
                 .
                    { gbl/baserate.i
                      g#host-code
                      to-day
                      shar_ord-doc.base-rate
                      shar_ord-doc.base-scale
                      }
    end.
  end. /* for each */
  run waitfram-hide in this-procedure .
  if kol-z > 0 then
      message   "Импорт завершен !" skip
                "Сформировано " kol-z " заказов с № " v#doc-code1 " по № " v#doc-code
                view-as alert-box information title "Внимание !"
                .
  else
      message   "Импорт завершен !" skip
                "Сформировано " kol-z " заказов "
                view-as alert-box information title "Внимание !"
                .

end procedure.

procedure init-p :

do
on error undo, return error return-value
:
run uf-get in this-procedure (
     input  {&uf-seqeallo}
    ,input  'adm'
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
)  no-error.
define variable iv as integer   no-undo .
define variable i-kol as integer   no-undo .
define variable st as character no-undo .
    if v-uf-List_ <> "" then do:
    i-kol = num-entries (v-uf-List_, {&delim-par}) .
        repeat Iv = 1 to i-kol :
          st = entry(Iv,v-uf-List_, {&delim-par}).
          create tt-table.
          assign
            tt-table.id = integer(entry(1, st))
            tt-table.new-id = integer(entry(2, st))
          .
        end.
    end.
    else do:
        repeat Iv = 1 to 33 :
          create tt-table.
          assign
            tt-table.id = iv
            tt-table.new-id = iv
          .
        end.
    end.
/* Нужные колонки для засоски*/
assign
 col-gds-code     = new-n (1)
 col-typecode-obj = new-n (22)
 col-zakz-qnty    = new-n (25)
 col-price        = new-n (27)
 col-cli-type     = new-n (28)
 col-cli-code     = new-n (29)
 col-cli-art      = new-n (30)
 col-choice       = new-n (31)
.
end.
end procedure. /* init-p */