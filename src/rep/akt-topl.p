/*

$Revision: 31d98d0f4d05, 3249, rls $
$Author: SSlivenko $
$Date: 2023/03/29 08:47:58 $
$Workfile: akt-topl.p $
$Archive: rep/akt-topl.p $

Акт несоответствия по топливной накладной

Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/30/09
Author: Dmitry Ukhanov
Creation date: 01/30/09

Автор1: Демин Алексей Сергеевич
Дата создания1: 09/15/05

*/

using ibs.th.str.*.
block-level on error undo, throw.
define input parameter p-mainmenu-handle as widget-handle no-undo.
define input parameter rec_id            as recid         no-undo.
define input parameter parprint-water    as logical       no-undo.

define variable vss-revision    as character no-undo initial "$Revision: 31d98d0f4d05, 3249, rls $":U .
define variable vss-author      as character no-undo initial "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo initial "$Date: 2023/03/29 08:47:58 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: akt-topl.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/akt-topl.p $":U .
define variable vss-description as character no-undo initial "Акт несоответствия по топливной накладной":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ cmp/r-pril.i   }
{ rep/p-fmt.i    }
{ str/trdcalib.i }

do
on error undo, return error return-value
:
&scop left-margin 15
&scop right-margin 130
&scop max-width 114
&scop max-width-p-x2 95
&scop tab-stop1 54
&scop max-width-from-tab1 76
&scop tab-stop2 70
&scop max-width-from-tab2 60
&scop tab-stop3 90
&scop tab-stop4 110

/* ----S----- Таблица -------------------------------- */
&GLOB P-S 16
&GLOB P-X 115        /* длина линии */
&GLOB P-X0 112       /* длина внутренней линии = длина линии - 2 */
&GLOB P-X0-P-X2 93       /* длина внутренней линии = длина линии - 2 */
&GLOB P-X1 68        /* длина внутренней линии от начала 2-й колонки до начала 6-й */
&GLOB P-X2 18        /* длина внутренней линии от начала 6-й колонки до конца */
&GLOB P-E     {&P-S} + 113
&GLOB P-C2-S  {&P-S} + 25
&GLOB P-C3-S  {&P-S} + 40
&GLOB P-C4-S  {&P-S} + 50
&GLOB P-C5-S  {&P-S} + 74
&GLOB P-C6-S  {&P-S} + 94
/* ----E----- Таблица -------------------------------- */



&scop extend-temp-string ~
  assign temp-position = center-field( {&left-margin}, {&right-margin}, length(temp-string) )~
         temp-string   = fill(" ", temp-position) + temp-string.


/* ----S----- Блок описания переменных --------------- */
define buffer buf_trn-doc         for ub.trn-doc.
define buffer buf_doc-line        for ub.doc-line.
define buffer buf_goods           for ub.goods.
define buffer buf_clients         for ub.clients.
define buffer buf_clients_ship    for ub.clients.
define buffer buf_doc-line-attr   for ub.doc-line-attr.
define buffer buf_doc-attr        for ub.doc-attr.
define buffer buf_rvs-doc_before  for ub.rvs-doc.
define buffer buf_rvs-doc_after   for ub.rvs-doc.
define buffer buf_rvs-line_before for ub.rvs-line.
define buffer buf_rvs-line_after  for ub.rvs-line.

define stream out-stream .

define variable v-operator    as char             no-undo.
define variable temp-string   as char             no-undo.
define variable temp-position as int              no-undo.
define variable single-line   as char             no-undo.
define variable v-is-petrol   as logical init no  no-undo.
define variable v-is-pieces   as logical init no  no-undo.
define variable v-have-petrol as logical init no  no-undo.

define variable v-have-rvs-before as logical init no  no-undo.
define variable v-have-rvs-after  as logical init no  no-undo.
define variable before_real-time  as integer          no-undo.
define variable after_real-time   as integer          no-undo.
define variable doc-line_1st-run  as logical          no-undo .

define variable v-ship-org          like doc-line-attr.attr-value no-undo.
define variable v-autoent-obj-code  like doc-line-attr.attr-value no-undo.
define variable v-autoent-obj-type  like doc-line-attr.attr-value no-undo.
define variable v-dids              like doc-line-attr.attr-value no-undo.
define variable v-nids              like doc-line-attr.attr-value no-undo.
define variable v-attr-type         as character                  no-undo.
define variable v-car-num           like doc-line-attr.attr-value no-undo.
define variable v-car-vol           like doc-line-attr.attr-value no-undo.
define variable v-item-pour         like doc-line-attr.attr-value no-undo.
define variable v-tank-density      like doc-line-attr.attr-value no-undo.
define variable v-tank-temp         like doc-line-attr.attr-value no-undo.
define variable v-tank-vol          like doc-line-attr.attr-value no-undo.
define variable v-tank-water        like doc-line-attr.attr-value no-undo.
define variable v-tank-weight       like doc-line-attr.attr-value no-undo.
define variable v-time-pour         like doc-line-attr.attr-value no-undo.
define variable v-time-income       like doc-line-attr.attr-value no-undo.
define variable v-time-start        like doc-line-attr.attr-value no-undo.
define variable v-time-end          like doc-line-attr.attr-value no-undo.
define variable v-type-inp-vat      like doc-line-attr.attr-value no-undo.
define variable v-fio               like doc-line-attr.attr-value no-undo.
define variable v-delta-mass        as decimal                    no-undo.
define variable v-mass-pogresh      as decimal                    no-undo.
define variable v-delta-res as decimal                    no-undo.

define variable v-tank-vol-dec      like ub.rvs-line.state-measure-qnty     no-undo.
define variable v-tank-temp-dec     like ub.rvs-line.state-temperature      no-undo.
define variable v-tank-density-dec  like ub.rvs-line.state-density          no-undo.
define variable v-tank-weight-dec   like ub.rvs-line.state-measure-cli-qnty no-undo.
define variable v-tank-water-dec    like ub.rvs-line.state-measure-qnty     no-undo.
define variable v-nedost            as   logical                         no-undo.

define variable before_qnty         like ub.rvs-line.state-measure-qnty     no-undo.
define variable before_temperature  like ub.rvs-line.state-temperature      no-undo.
define variable before_density      like ub.rvs-line.state-density          no-undo.
define variable before_cli-qnty     like ub.rvs-line.state-measure-cli-qnty no-undo.
define variable after_qnty          like ub.rvs-line.state-measure-qnty     no-undo.
define variable after_temperature   like ub.rvs-line.state-temperature      no-undo.
define variable after_density       like ub.rvs-line.state-density          no-undo.
define variable after_cli-qnty      like ub.rvs-line.state-measure-cli-qnty no-undo.
define variable v-water-qnty        as decimal no-undo .

define variable v-InfoSectionsTotal as class InfoSectionsTotal no-undo .

/* ----E----- Блок описания переменных --------------- */

define variable varstfactpl     as character no-undo .
define variable varstfactpltype as character no-undo .
define variable pogresh         as decimal   no-undo initial 0 .

define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.

run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).
assign
    single-line = fill("-", {&max-width})
.
{ gbl/conf-rd.i "'stfactpl'" "''" "''" 0 "''" "''" "''" no varstfactpl varstfactpltype no-error }
assign
  varstfactpl = replace( varstfactpl,  "read-only;", "":U )
  varstfactpl = replace( varstfactpl, ";read-only",  "":U )
  varstfactpl = replace( varstfactpl,  "read-only",  "":U )
  varstfactpl = replace( varstfactpl,  "inv-set;", "":U )
  varstfactpl = replace( varstfactpl, ";inv-set",  "":U )
  varstfactpl = replace( varstfactpl,  "inv-set",  "":U )
.
if num-entries( varstfactpl, ";" ) > 1
then do:
  assign
    varstfactpl = entry( 1, varstfactpl, ";" )
  .
end.
assign
  varstfactpl = replace( varstfactpl, ";",           "":U )
.
assign
  pogresh     = ( if num-entries( varstfactpl, '=' ) = 2 then decimal( entry( 2, varstfactpl, '=' ) ) * 0.01 else 0 )
  varstfactpl = entry( 1, varstfactpl, "=" )
.

{ gbl/working.i }
{ cmp/open-out.i stream out-stream " " {&CS_PS} }

find first buf_trn-doc no-lock      /* Нашли trn-doc */
     where recid( buf_trn-doc ) = rec_id
.

find first buf_clients no-lock      /* Оператор - по коду из trn-doc */
    where buf_clients.obj-type = {&prs}
      and buf_clients.obj-code = buf_trn-doc.wrkr
no-error.
if available buf_clients
then do:
    assign
        v-operator = buf_clients.obj-name
    .
end.
else do:
    assign
        v-operator = ""
    .
end.

find first buf_clients no-lock      /* Поставщик - по trn-doc */
    where buf_clients.obj-type = buf_trn-doc.obj-type
      and buf_clients.obj-code = buf_trn-doc.obj-code
.
{ str/tdat-val.i
    buf_trn-doc.doc-code
    {&trdcattr-dids}
    v-dids
    v-attr-type
}
{ str/tdat-val.i
    buf_trn-doc.doc-code
    {&trdcattr-nids}
    v-nids
    v-attr-type
}
/* ---S----- Для каждой линии документа печатаем отдельный лист ---- */
print-doc-line:
for each buf_doc-line no-lock
     where buf_doc-line.doc-code = buf_trn-doc.doc-code
:
    assign
      doc-line_1st-run = yes
    .
    { rep/akt-topl.i init-attr }
    find first buf_goods no-lock
        where buf_goods.artic      = buf_doc-line.artic
          and buf_goods.prod-type  = buf_doc-line.prod-type
          and buf_goods.prod-code  = buf_doc-line.prod-code
    .
    { str/is-petrl.i
        buf_goods.artic
        buf_goods.prod-type
        buf_goods.prod-code
        v-is-petrol
        v-is-pieces
    }
    if v-is-petrol <> yes
    then do:
        next print-doc-line.
    end.
    assign                /* Если сюда дошли, значит хоть один топливный товар есть */
        v-have-petrol = yes
    .

    v-InfoSectionsTotal = new InfoSectionsTotal().
    v-InfoSectionsTotal:Initialization(buf_trn-doc.doc-code, buf_goods.gds-code).
    v-InfoSectionsTotal:GetDBAllAttr().
    for each buf_doc-line-attr no-lock
       where buf_doc-line-attr.doc-code = buf_trn-doc.doc-code
         and buf_doc-line-attr.gds-code = buf_goods.gds-code
    :
        case buf_doc-line-attr.attr-code:
          { rep/akt-topl.i when car-vol          }
          { rep/akt-topl.i when tank-density     }
          { rep/akt-topl.i when tank-temp        }
          { rep/akt-topl.i when tank-vol         }
          { rep/akt-topl.i when tank-water       }
          { rep/akt-topl.i when tank-weight      }
          { rep/akt-topl.i when time-start       }
          { rep/akt-topl.i when time-end         }
          { rep/akt-topl.i when time-pour        }
          { rep/akt-topl.i when type-inp-vat     }
        end case.
    end.

    for each buf_doc-attr no-lock where
             buf_doc-attr.doc-code = buf_trn-doc.doc-code:
      case buf_doc-attr.attr-code :
        { rep/akt-topl.i when-doc-attr trdcattr-autoent }
        { rep/akt-topl.i when-doc-attr trdcattr-car-num }
        { rep/akt-topl.i when-doc-attr trdcattr-time-income }
        { rep/akt-topl.i when-doc-attr trdcattr-ptb-item-pour }
        { rep/akt-topl.i when-doc-attr trdcattr-fio-driver }
      end case. /* buf_doc-attr.attr-code */
    end. /* for each buf_doc-attr */

    /* ---S---- Переводим табличные значения в Decimal -------- */
          { rep/akt-topl.i dec tank-vol      }
          { rep/akt-topl.i dec tank-temp     }
          { rep/akt-topl.i dec tank-density  }
          { rep/akt-topl.i dec tank-weight   }
          { rep/akt-topl.i dec tank-water    }
    /* ---E---- Переводим табличные значения в Decimal -------- */

    v-car-vol = string (v-InfoSectionsTotal:CarVolTotal).
    v-tank-vol-dec = v-InfoSectionsTotal:TankVolTotal.
    v-tank-density-dec = v-InfoSectionsTotal:TankWeightTotal / v-InfoSectionsTotal:TankVolTotal.
    v-tank-weight-dec = v-InfoSectionsTotal:TankWeightTotal.
    v-tank-water-dec = v-InfoSectionsTotal:TankWaterVolTotal.
    v-time-start =  string ( v-InfoSectionsTotal:StartRealTime ).
    v-time-end =  string ( v-InfoSectionsTotal:EndRealTime ).
    
    find first buf_clients_ship no-lock
        where buf_clients_ship.obj-type = v-autoent-obj-type
          and buf_clients_ship.obj-code = integer(v-autoent-obj-code)
    no-error.

    if available buf_clients_ship
    then assign
        v-ship-org = buf_clients_ship.obj-name
    .
    else assign
        v-ship-org = ""
    .
    { rep/akt-topl.i real-time before }
    { rep/akt-topl.i real-time after  }

/* ----S----------------- Печать: Шапка документа ------------------------ */

    put stream out-stream
        skip
        space ({&left-margin})  '"УТВЕРЖДАЮ"'           format "X(11)"
        '"УТВЕРЖДАЮ"'           format "X(11)"  at right-field( {&right-margin}, 11 )
        skip
        space ({&left-margin})  "____________________"  format "X(20)"
        "____________________"  format "X(20)"  at right-field( {&right-margin}, 20 )
        skip
        space ({&left-margin})  "____________________"  format "X(20)"
        "____________________"  format "X(20)"  at right-field( {&right-margin}, 20 )
        skip
        "А К Т"            format "X(5)"    at center-field( {&left-margin}, {&right-margin}, 5 )
        skip
        "Об отличии количества нефтепродукта по ТТН"
                          format "X(42)"   at center-field( {&left-margin}, {&right-margin}, 42 )
    .

    assign
      temp-string   = "от количества по измерениям при приеме на " + trim(buf_clients.obj-name)
    .
    {&extend-temp-string}

    put stream out-stream
        skip
        temp-string format "X({&right-margin})"
    .

/*    if buf_trn-doc.flag_ then  /* накладная закрыта по факту - выводим дату fact-date */ */
/*    do: */
      if buf_trn-doc.fact-date <> ?
      then do:
          assign
            temp-string = '" '  + string(day(buf_trn-doc.fact-date))
                          + ' " ' + entry(month(buf_trn-doc.fact-date), {&month-list-for-date})
                          + " " + string(year(buf_trn-doc.fact-date), "9999") + " г."
          .
          {&extend-temp-string}
      end.
      else assign
          temp-string = ""
      .
/*    end. */
/*    else do: */
/*      temp-string = fill(" ", 45 + {&left-margin}) + "Приходная накладная не закрыта". */
/*    end. */

    put stream out-stream
            skip
            temp-string format "X({&right-margin})"
            skip (2)
            space ({&left-margin}) "ТТН N "
            string(buf_trn-doc.doc-code) + " от " + string(buf_trn-doc.doc-date)
                                        format "X({&max-width-from-tab1})"     at {&tab-stop1}
    .

    put stream out-stream
        skip
        space ({&left-margin}) "Основание: накладная поставщика"
        string( "N " + v-nids + " от " + v-dids )
                                        format "X({&max-width-from-tab1})"     at {&tab-stop1}
        skip
        space ({&left-margin}) "Автопредприятие "
        v-ship-org                      format "X({&max-width-from-tab1})"     at {&tab-stop1}
        skip
        space ({&left-margin}) "Гос.N автоцистерны "
        v-car-num                       format "X({&max-width-from-tab1})"     at {&tab-stop1}
        skip
        space ({&left-margin}) "Объем по паспорту в литрах "
        v-car-vol                       format "X({&max-width-from-tab1})"     at {&tab-stop1}
        skip
        space ({&left-margin}) "Поставщик "
        buf_trn-doc.cli-name            format "X({&max-width-from-tab1})"     at {&tab-stop1}
        skip
        space ({&left-margin}) "Пункт налива "
        v-item-pour                     format "X({&max-width-from-tab1})"     at {&tab-stop1}
        skip
        space ({&left-margin}) "Время налива "
        v-time-pour                     format "X({&max-width-from-tab1})"     at {&tab-stop1}
        skip
        space ({&left-margin}) "Время прибытия на АЗС "
        v-time-income                   format "X({&max-width-from-tab1})"     at {&tab-stop1}
        skip
        space ({&left-margin}) "Время налива:"
                                "начало "
                                + (if before_real-time <> ?
                                 then string(before_real-time, "hh:mm")
                                 else "     "
                                   )
                                + " (чч:мм) окончание "
                                + (if after_real-time <> ?
                                 then string(after_real-time, "hh:mm")
                                 else "     "
                                   )
                                + "(чч:мм)"
                                        format "X({&max-width-from-tab1})"     at {&tab-stop1}
        skip
        space ({&left-margin}) "Ф.И.О. экспедитора "
        v-fio format "X({&max-width-from-tab1})"     at {&tab-stop1}
        skip
        space ({&left-margin}) "При приеме машина проверена на наличие пломб. Пломбы сорваны"
        skip
        space ({&left-margin}) fill("_", ( {&right-margin} - {&left-margin} ) )  format "X({&max-width})"
        skip
        space ({&left-margin}) fill ("_", ( {&right-margin} - {&left-margin} ) ) format "X({&max-width})"
        skip
        space ({&left-margin}) "Уровень н/продукта перед сливом автоцистерны _________________________ в сантиметрах"
        skip
        space ({&left-margin}) "калибровочной планки.                         (выше, ниже, по планку)"
        skip
        space ({&left-margin}) "Нефтепродукт "
        buf_goods.gds-name              format "X({&max-width-from-tab1})"     at {&tab-stop1}
    .
    /* ----E----- Шапка документа ------------------------ */

    /* ----S----- Шапка таблицы -------------------------- */
    if parprint-water = yes then do:
      put stream out-stream
        skip
          single-line        format "X({&max-width})"        at {&P-S}
        skip
          ":"         format "X(1)"           at {&P-S}
          ":"         format "X(1)"           at {&P-C2-S}
          "Нефтепродукт"  format "X(12)" at center-field( {&P-C2-S}, {&P-C6-S}, 12)
          ":"         format "X(1)"           at {&P-C6-S}
          "Вода " format "X(5)" at center-field( {&P-C6-S}, {&P-E}, 4)
          ":"         format "X(1)"           at {&P-E}
        skip
          ":"         format "X(1)"           at {&P-S}
          ":"         format "X(1)"           at {&P-C2-S}
          single-line        format "X({&P-X1})"
          ":"         format "X(1)"           at {&P-C6-S}
          single-line        format "X({&P-X2})"
          ":"         format "X(1)"           at {&P-E}
        skip
          ":"         format "X(1)"           at {&P-S}
          ":"         format "X(1)"           at {&P-C2-S}
          "Объем,"    format "X(6)"           at center-field( {&P-C2-S}, {&P-C3-S}, 6)
          ":"         format "X(1)"           at {&P-C3-S}
          "t,"        format "X(2)"          at center-field( {&P-C3-S}, {&P-C4-S}, 2)
          ":"         format "X(1)"           at {&P-C4-S}
          "Плотность," format "X(10)"          at center-field( {&P-C4-S}, {&P-C5-S}, 10)
          ":"         format "X(1)"           at {&P-C5-S}
          "Масса,"    format "X(6)"           at center-field( {&P-C5-S}, {&P-C6-S}, 6)
          ":"         format "X(1)"           at {&P-C6-S}
          "Объем воды," format "X(11)"        at center-field( {&P-C6-S}, {&P-E}, 11)
          ":"         format "X(1)"           at {&P-E}
        skip
          ":"         format "X(1)"           at {&P-S}
          ":"         format "X(1)"           at {&P-C2-S}
          "л"         format "X(1)"           at center-field( {&P-C2-S}, {&P-C3-S}, 1)
          ":"         format "X(1)"           at {&P-C3-S}
          "град.C"    format "X(6)"           at center-field( {&P-C3-S}, {&P-C4-S}, 6)
          ":"         format "X(1)"           at {&P-C4-S}
          "г/см.куб"  format "X(8)"           at center-field( {&P-C4-S}, {&P-C5-S}, 8)
          ":"         format "X(1)"           at {&P-C5-S}
          "кг"        format "X(2)"           at center-field( {&P-C5-S}, {&P-C6-S}, 2)
          ":"         format "X(1)"           at {&P-C6-S}
          "л"         format "X(1)"           at center-field( {&P-C6-S}, {&P-E}, 1)
          ":"         format "X(1)"           at {&P-E}
        skip
          ":"         format "X(1)"           at {&P-S}
          single-line format "X({&P-X0})"
          ":"         format "X(1)"
      .
      /* ----E----- Шапка таблицы -------------------------- */

      /* ----S----- Таблица -------------------------------- */
      put stream out-stream
        skip
          ":"         format "X(1)"           at {&P-S}
          "По ТТН"    format "X(6)"           at {&P-S} + 2
          ":"         format "X(1)"           at {&P-C2-S}
          buf_doc-line.doc-qnty          format "zz,zz9.999"    at right-field( {&P-C3-S} - 2, 10)
          ":"         format "X(1)"           at {&P-C3-S} .
      if v-InfoSectionsTotal:GetInfoSectionProp(1):TTNTemp <> ? then do:
          put stream out-stream
          v-InfoSectionsTotal:GetInfoSectionProp(1):TTNTemp       format "->>9.99"           at right-field( {&P-C4-S} - 1, 7)
          ":"         format "X(1)"           at {&P-C4-S} .
      end.
      else do:
          put stream out-stream
          buf_doc-line.temperature       format "->>9.99"           at right-field( {&P-C4-S} - 1, 7) 
          ":"         format "X(1)"           at {&P-C4-S} .
       end.
      put stream out-stream
          buf_doc-line.doc-density       format "9.9999999999"            at right-field( {&P-C5-S} - 2, 12)
          ":"         format "X(1)"           at {&P-C5-S}
          buf_doc-line.doc-qnty * buf_doc-line.doc-density
                                         format "zzz,zzz,zz9.999"  at right-field( {&P-C6-S} - 2, 15)
          ":"         format "X(1)"           at {&P-C6-S}
          ":"         format "X(1)"           at {&P-E}
        skip
          ":"         format "X(1)"           at {&P-S}
          single-line format "X({&P-X0})"
          ":"         format "X(1)"
        skip
          ":"         format "X(1)"           at {&P-S}
          single-line format "X({&P-X0})"
          ":"         format "X(1)"
        skip
          ":"         format "X(1)"           at {&P-S}
          "По замеру в"    format "X(11)"     at {&P-S} + 2
          ":"         format "X(1)"           at {&P-C2-S}
          ":"         format "X(1)"           at {&P-C3-S}
          ":"         format "X(1)"           at {&P-C4-S}
          ":"         format "X(1)"           at {&P-C5-S}
          ":"         format "X(1)"           at {&P-C6-S}
          ":"         format "X(1)"           at {&P-E}
        skip
          ":"         format "X(1)"           at {&P-S}
          "автоцистерне"    format "X(12)"    at {&P-S} + 2
          ":"         format "X(1)"           at {&P-C2-S}
      .
      if v-InfoSectionsTotal:TankVolTotal <> ?
      then put stream out-stream
          v-InfoSectionsTotal:TankVolTotal
                                      format "zz,zz9.999"    at right-field( {&P-C3-S} - 2, 10)
      .
      put stream out-stream
          ":"         format "X(1)"           at {&P-C3-S}
      .
      if v-InfoSectionsTotal:GetInfoSectionProp(1):TankTemp <> ?
      then put stream out-stream
          v-InfoSectionsTotal:GetInfoSectionProp(1):TankTemp
                                      format "->>9.99"           at right-field( {&P-C4-S} - 1, 7)
      .
      put stream out-stream
          ":"         format "X(1)"           at {&P-C4-S}
      .
      if v-tank-density-dec <> ? then
      put stream out-stream
          v-tank-density-dec
                                      format "9.9999999999"            at right-field( {&P-C5-S} - 2, 12)
      .
      put stream out-stream
          ":"         format "X(1)"           at {&P-C5-S}
      .
      if v-InfoSectionsTotal:TankWeightTotal <> ?
      then put stream out-stream
          v-InfoSectionsTotal:TankWeightTotal
                                      format "zzz,zzz,zz9.999"  at right-field( {&P-C6-S} - 2, 15)
      .
      put stream out-stream
          ":"         format "X(1)"           at {&P-C6-S}
      .
      if v-InfoSectionsTotal:TankWaterVolTotal <> ? then do:
        put stream out-stream v-InfoSectionsTotal:TankWaterVolTotal format "zzz,zzz,zz9.999"  at right-field( {&P-E} - 2, 15).
      end.
      put stream out-stream
          ":"         format "X(1)"           at {&P-E}
          skip
          ":"         format "X(1)"           at {&P-S}
          single-line format "X({&P-X0})"
          ":"         format "X(1)"
      skip.
    end.
    else do:
      put stream out-stream
        skip
          single-line        format "X({&max-width-p-x2})"        at {&P-S}
        skip
          ":"         format "X(1)"           at {&P-S}
          ":"         format "X(1)"           at {&P-C2-S}
          "Нефтепродукт"  format "X(12)" at center-field( {&P-C2-S}, {&P-C6-S}, 12)
          ":"         format "X(1)"           at {&P-C6-S}
        skip
          ":"         format "X(1)"           at {&P-S}
          ":"         format "X(1)"           at {&P-C2-S}
          single-line        format "X({&P-X1})"
          ":"         format "X(1)"           at {&P-C6-S}
        skip
          ":"         format "X(1)"           at {&P-S}
          ":"         format "X(1)"           at {&P-C2-S}
          "Объем,"    format "X(6)"           at center-field( {&P-C2-S}, {&P-C3-S}, 6)
          ":"         format "X(1)"           at {&P-C3-S}
          "t,"        format "X(2)"          at center-field( {&P-C3-S}, {&P-C4-S}, 2)
          ":"         format "X(1)"           at {&P-C4-S}
          "Плотность," format "X(10)"          at center-field( {&P-C4-S}, {&P-C5-S}, 10)
          ":"         format "X(1)"           at {&P-C5-S}
          "Масса,"    format "X(6)"           at center-field( {&P-C5-S}, {&P-C6-S}, 6)
          ":"         format "X(1)"           at {&P-C6-S}
        skip
          ":"         format "X(1)"           at {&P-S}
          ":"         format "X(1)"           at {&P-C2-S}
          "л"         format "X(1)"           at center-field( {&P-C2-S}, {&P-C3-S}, 1)
          ":"         format "X(1)"           at {&P-C3-S}
          "град.C"    format "X(6)"           at center-field( {&P-C3-S}, {&P-C4-S}, 6)
          ":"         format "X(1)"           at {&P-C4-S}
          "г/см.куб"  format "X(8)"           at center-field( {&P-C4-S}, {&P-C5-S}, 8)
          ":"         format "X(1)"           at {&P-C5-S}
          "кг"        format "X(2)"           at center-field( {&P-C5-S}, {&P-C6-S}, 2)
          ":"         format "X(1)"           at {&P-C6-S}
        skip
          ":"         format "X(1)"           at {&P-S}
          single-line format "X({&P-X0-P-X2})"
          ":"         format "X(1)"
      .
      /* ----E----- Шапка таблицы -------------------------- */

      /* ----S----- Таблица -------------------------------- */
      put stream out-stream
        skip
          ":"         format "X(1)"           at {&P-S}
          "По ТТН"    format "X(6)"           at {&P-S} + 2
          ":"         format "X(1)"           at {&P-C2-S}
          buf_doc-line.doc-qnty          format "zz,zz9.999"    at right-field( {&P-C3-S} - 2, 10)
          ":"         format "X(1)"           at {&P-C3-S}
          buf_doc-line.temperature       format "->>9.99"           at right-field( {&P-C4-S} - 1, 7)
          ":"         format "X(1)"           at {&P-C4-S}
          buf_doc-line.doc-density       format "9.9999999999"            at right-field( {&P-C5-S} - 2, 12)
          ":"         format "X(1)"           at {&P-C5-S}
          buf_doc-line.doc-qnty * buf_doc-line.doc-density
                                         format "zzz,zzz,zz9.999"  at right-field( {&P-C6-S} - 2, 15)
          ":"         format "X(1)"           at {&P-C6-S}
        skip
          ":"         format "X(1)"           at {&P-S}
          single-line format "X({&P-X0-P-X2})"
          ":"         format "X(1)"
        skip
          ":"         format "X(1)"           at {&P-S}
          single-line format "X({&P-X0-P-X2})"
          ":"         format "X(1)"
        skip
          ":"         format "X(1)"           at {&P-S}
          "По замеру в"    format "X(11)"     at {&P-S} + 2
          ":"         format "X(1)"           at {&P-C2-S}
          ":"         format "X(1)"           at {&P-C3-S}
          ":"         format "X(1)"           at {&P-C4-S}
          ":"         format "X(1)"           at {&P-C5-S}
          ":"         format "X(1)"           at {&P-C6-S}
        skip
          ":"         format "X(1)"           at {&P-S}
          "автоцистерне"    format "X(12)"    at {&P-S} + 2
          ":"         format "X(1)"           at {&P-C2-S}
      .
      
      if v-InfoSectionsTotal:TankVolTotal <> ?
      then put stream out-stream
          v-InfoSectionsTotal:TankVolTotal
                                      format "zz,zz9.999"    at right-field( {&P-C3-S} - 2, 10)
      .
      put stream out-stream
          ":"         format "X(1)"           at {&P-C3-S}
      .
      if v-InfoSectionsTotal:GetInfoSectionProp(1):TankTemp <> ?
      then put stream out-stream
          v-InfoSectionsTotal:GetInfoSectionProp(1):TankTemp
                                      format "->>9.99"           at right-field( {&P-C4-S} - 1, 7)
      .
      put stream out-stream
          ":"         format "X(1)"           at {&P-C4-S}
      .
      if v-InfoSectionsTotal:DocDensityAvg <> ? then
      put stream out-stream
          v-InfoSectionsTotal:DocDensityAvg
                                      format "9.9999999999"            at right-field( {&P-C5-S} - 2, 12)
      .
      put stream out-stream
          ":"         format "X(1)"           at {&P-C5-S}
      .
      if v-InfoSectionsTotal:TankWeightTotal <> ?
      then put stream out-stream
          v-InfoSectionsTotal:TankWeightTotal
                                      format "zzz,zzz,zz9.999"  at right-field( {&P-C6-S} - 2, 15)
      .
      put stream out-stream
          ":"         format "X(1)"           at {&P-C6-S}
      .
      put stream out-stream
          skip
          ":"         format "X(1)"           at {&P-S}
          single-line format "X({&P-X0-P-X2})"
          ":"         format "X(1)"
       skip.
    end.

    /* if lookup( varstfactpl, "auto-tank,inv" ) = 0 then do: */ /* Убрал по требованию Жуковой и Агафоновой */
      if parprint-water = yes then do:
        /* ---S----- Находим строки топливного документа до слива -------- */
        { rep/akt-topl.i rvs-line before }
        put stream out-stream
            ":"         format "X(1)"           at {&P-S}
            single-line format "X({&P-X0})"
            ":"         format "X(1)"
          skip
            ":"         format "X(1)"           at {&P-S}
            "По замеру в резервуаре"    format "X(22)"           at {&P-S} + 2
            ":"         format "X(1)"           at {&P-C2-S}
            ":"         format "X(1)"           at {&P-C3-S}
            ":"         format "X(1)"           at {&P-C4-S}
            ":"         format "X(1)"           at {&P-C5-S}
            ":"         format "X(1)"           at {&P-C6-S}
            ":"         format "X(1)"           at {&P-E}
          skip
            ":"         format "X(1)"           at {&P-S}
            "ДО слива"  format "X(8)"           at {&P-S} + 2
            ":"         format "X(1)"           at {&P-C2-S}
        .
        
        { rep/akt-topl.i print-field  buf_rvs-line_before.state-measure-qnty     "zz,zz9.999"      "{&P-C3-S}" 2 10 before }
        { rep/akt-topl.i print-field  buf_rvs-line_before.state-temperature      "->>9.99"         "{&P-C4-S}" 1  7 before }
        { rep/akt-topl.i print-field  buf_rvs-line_before.state-density          "9.9999999999"    "{&P-C5-S}" 2 12 before }
        { rep/akt-topl.i print-field  buf_rvs-line_before.state-measure-cli-qnty "zzz,zzz,zz9.999" "{&P-C6-S}" 2 15 before }
        v-water-qnty = buf_rvs-line_before.state-brutto-qnty - buf_rvs-line_before.state-measure-qnty .
        for first rvs-line-attr no-lock
              where rvs-line-attr.obj-code  = buf_rvs-line_before.obj-code
                and rvs-line-attr.obj-type  = buf_rvs-line_before.obj-type
                and rvs-line-attr.gds-code  = buf_rvs-line_before.gds-code
                and rvs-line-attr.pl-code   = buf_rvs-line_before.pl-code
                and rvs-line-attr.rvs-code  = buf_rvs-line_before.rvs-code
                and rvs-line-attr.attr-code = "pokmi-water-qnty"
        :
          v-water-qnty = decimal(rvs-line-attr.attr-value) .
        end .
        if v-water-qnty = ? then v-water-qnty = 0 . 
        { rep/akt-topl.i print-field  v-water-qnty "zzz,zzz,zz9.999" "{&P-E}"    2 15 before }
        { rep/akt-topl.i rvs-line-end before }
        /* ---E----- Находим строки топливного документа до слива -------- */

        /* ---S----- Находим строки топливного документа после слива -------- */
        { rep/akt-topl.i rvs-line after  }
        put stream out-stream
          skip
            ":"         format "X(1)"           at {&P-S}
            single-line format "X({&P-X0})"
            ":"         format "X(1)"
          skip
            ":"         format "X(1)"           at {&P-S}
            "По замеру в резервуаре"    format "X(22)"           at {&P-S} + 2
            ":"         format "X(1)"           at {&P-C2-S}
            ":"         format "X(1)"           at {&P-C3-S}
            ":"         format "X(1)"           at {&P-C4-S}
            ":"         format "X(1)"           at {&P-C5-S}
            ":"         format "X(1)"           at {&P-C6-S}
            ":"         format "X(1)"           at {&P-E}
          skip
            ":"         format "X(1)"           at {&P-S}
            "ПОСЛЕ слива"  format "X(11)"       at {&P-S} + 2
            ":"         format "X(1)"           at {&P-C2-S}
        .
        { rep/akt-topl.i print-field  buf_rvs-line_after.state-measure-qnty     "zz,zz9.999"      "{&P-C3-S}" 2 10 after }
        { rep/akt-topl.i print-field  buf_rvs-line_after.state-temperature      "->>9.99"         "{&P-C4-S}" 1  7 after }
        { rep/akt-topl.i print-field  buf_rvs-line_after.state-density          "9.9999999999"    "{&P-C5-S}" 2 12 after }
        { rep/akt-topl.i print-field  buf_rvs-line_after.state-measure-cli-qnty "zzz,zzz,zz9.999" "{&P-C6-S}" 2 15 after }
        v-water-qnty = buf_rvs-line_after.state-brutto-qnty - buf_rvs-line_after.state-measure-qnty .
        for first rvs-line-attr no-lock
              where rvs-line-attr.obj-code  = buf_rvs-line_after.obj-code
                and rvs-line-attr.obj-type  = buf_rvs-line_after.obj-type
                and rvs-line-attr.gds-code  = buf_rvs-line_after.gds-code
                and rvs-line-attr.pl-code   = buf_rvs-line_after.pl-code
                and rvs-line-attr.rvs-code  = buf_rvs-line_after.rvs-code
                and rvs-line-attr.attr-code = "pokmi-water-qnty"
        :
          v-water-qnty = decimal(rvs-line-attr.attr-value) .
        end .
        if v-water-qnty = ? then v-water-qnty = 0 .
        { rep/akt-topl.i print-field v-water-qnty "zzz,zzz,zz9.999" "{&P-E}"    2 15 after }

        { rep/akt-topl.i rvs-line-end after }
        /* ---E----- Находим строки топливного документа после слива -------- */

        put stream out-stream
          skip
            single-line        format "X({&max-width})"        at {&P-S}
        .
      end.
      else do:
        /* ---S----- Находим строки топливного документа до слива -------- */
        { rep/akt-topl.i rvs-line before }
        put stream out-stream
            ":"         format "X(1)"           at {&P-S}
            single-line format "X({&P-X0-P-X2})"
            ":"         format "X(1)"
          skip
            ":"         format "X(1)"           at {&P-S}
            "По замеру в резервуаре"    format "X(22)"           at {&P-S} + 2
            ":"         format "X(1)"           at {&P-C2-S}
            ":"         format "X(1)"           at {&P-C3-S}
            ":"         format "X(1)"           at {&P-C4-S}
            ":"         format "X(1)"           at {&P-C5-S}
            ":"         format "X(1)"           at {&P-C6-S}
          skip
            ":"         format "X(1)"           at {&P-S}
            "ДО слива"  format "X(8)"           at {&P-S} + 2
            ":"         format "X(1)"           at {&P-C2-S}
        .
        { rep/akt-topl.i print-field buf_rvs-line_before.state-measure-qnty     "zz,zz9.999"      "{&P-C3-S}" 2 10 before }
        { rep/akt-topl.i print-field buf_rvs-line_before.state-temperature      "->>9.99"         "{&P-C4-S}" 1  7 before }
        { rep/akt-topl.i print-field buf_rvs-line_before.state-density          "9.9999999999"    "{&P-C5-S}" 2 12 before }
        { rep/akt-topl.i print-field buf_rvs-line_before.state-measure-cli-qnty "zzz,zzz,zz9.999" "{&P-C6-S}" 2 15 before }
        { rep/akt-topl.i rvs-line-end before }
        /* ---E----- Находим строки топливного документа до слива -------- */

        /* ---S----- Находим строки топливного документа после слива -------- */
        { rep/akt-topl.i rvs-line after }

        put stream out-stream
          skip
            ":"         format "X(1)"           at {&P-S}
            single-line format "X({&P-X0-P-X2})"
            ":"         format "X(1)"
          skip
            ":"         format "X(1)"           at {&P-S}
            "По замеру в резервуаре"    format "X(22)"           at {&P-S} + 2
            ":"         format "X(1)"           at {&P-C2-S}
            ":"         format "X(1)"           at {&P-C3-S}
            ":"         format "X(1)"           at {&P-C4-S}
            ":"         format "X(1)"           at {&P-C5-S}
            ":"         format "X(1)"           at {&P-C6-S}
          skip
            ":"         format "X(1)"           at {&P-S}
            "ПОСЛЕ слива"  format "X(11)"       at {&P-S} + 2
            ":"         format "X(1)"           at {&P-C2-S}
        .
        { rep/akt-topl.i print-field buf_rvs-line_after.state-measure-qnty     "zz,zz9.999"      "{&P-C3-S}" 2 10 after }
        { rep/akt-topl.i print-field buf_rvs-line_after.state-temperature      "->>9.99"         "{&P-C4-S}" 1  7 after }
        { rep/akt-topl.i print-field buf_rvs-line_after.state-density          "9.9999999999"    "{&P-C5-S}" 2 12 after }
        { rep/akt-topl.i print-field buf_rvs-line_after.state-measure-cli-qnty "zzz,zzz,zz9.999" "{&P-C6-S}" 2 15 after }
        { rep/akt-topl.i rvs-line-end after }
        /* ---E----- Находим строки топливного документа после слива -------- */

        put stream out-stream
          skip
            single-line        format "X({&max-width-p-x2})"        at {&P-S}
        .

      end.
    /* end. */ /* if lookup( varstfactpl, "auto-tank,inv" ) = 0 then */
    /* ----E----- Таблица -------------------------------- */

    /* ----S----- Итог документа ------------------------- */
    put stream out-stream
      skip (2)
      space ({&left-margin}) "Погрешность измерений "
    .

    assign v-mass-pogresh = v-InfoSectionsTotal:TankWeightTotal * pogresh.
/*    if lookup( varstfactpl, "inv" ) > 0 then do:                                                                                 */
/*      /* assign v-mass-pogresh = v-tank-weight-dec * pogresh. */ /* вычисление по методу Тесленко Н.Ф. */                        */
/*      assign v-mass-pogresh = v-InfoSectionsTotal:TankVolTotal * buf_doc-line.doc-density * pogresh. /* по методу Жуковой С.А. */*/
/*      /* Кто еще? */                                                                                                             */
/*    end.                                                                                                                         */
/*    else do:                                                                                                                     */
/*      assign v-mass-pogresh = v-InfoSectionsTotal:TankVolTotal * buf_doc-line.doc-density * pogresh.                             */
/*    end.                                                                                                                         */
    if v-mass-pogresh = ? then assign v-mass-pogresh = 0 .
    put stream out-stream
      v-mass-pogresh        format "zzz,zzz,zz9.999"  at right-field( {&tab-stop3}, 15)   " кг"
      skip space ({&left-margin}) "Отличие составило "
    .
    if v-delta-mass = ? then assign v-delta-mass = 0 .
    /* Недостача без погрешности */
    if v-delta-mass > 0 then do:
      assign
        v-nedost    = yes
        v-delta-res = v-delta-mass - v-mass-pogresh  .
    end.
    /* Излишек без погрешности */
    else do:
      assign
        v-nedost    = no
        v-delta-res = - v-delta-mass - v-mass-pogresh .
    end.
    if v-delta-res  = ? then assign v-delta-res = 0 .

    if v-delta-mass < 0 then assign v-delta-mass = - v-delta-mass .
    put stream out-stream
      v-delta-mass          format "zzz,zzz,zz9.999"  at right-field( {&tab-stop3}, 15)
      " кг"
    .
    if v-delta-mass > v-mass-pogresh then do:
        put stream out-stream
          skip space ({&left-margin}) "Количество, превышающее погрешность "  v-delta-res  format "zzz,zzz,zz9.999"  at right-field( {&tab-stop3}, 15)   " кг"
        .
    end.

    put stream out-stream
      skip (2)
      space ({&left-margin}) "Оператор АЗС "
      v-operator   format "X(35)"   at ({&left-margin} + 25)
      " ________________ (подпись)"
      skip(1)
      space ({&left-margin}) "Менеджер АЗС "
      "________________"   format "X(35)"   at ({&left-margin} + 25)
      " ________________ (подпись)"
      skip(1)
      space ({&left-margin}) "Водитель автоцистерны _____________________________________ ________________ (фамилия, подпись)"
    .
    run print-footer in this-procedure (
        input buf_trn-doc.host-code
    ).
    /* ----E----- Итог документа ------------------------- */
    page stream out-stream.
    delete object v-InfoSectionsTotal.
end.
/* ---E----- Для каждой линии документа печатаем отдельный лист ---- */


output stream out-stream close.
{ gbl/stopwork.i }

if v-have-petrol = yes     /* А если нет ни одного топливного товара - молча вывалиться */
then do:
    { rep/q-print.i 4}
end.

end.

/* ========================================================================== */
procedure print-footer :
do
on error undo, return error
:
define input parameter p-host-code  as integer      no-undo.

    define variable v-main-boss     as character     no-undo.
    define variable v-main-buh      as character     no-undo.

    define buffer buf_clients       for ub.clients .
    define buffer buf_firm          for ub.firm .
    define buffer buf_sysconf       for ub.sysconf .

    find first buf_clients no-lock
        where buf_clients.obj-type = {&cmp}
        and buf_clients.obj-code = p-host-code
    .
    find first buf_firm no-lock
        where buf_firm.firm-code = buf_clients.obj-code
    .
    assign
        v-main-boss = buf_firm.director
        v-main-buh  = buf_firm.gen-acct
    .
    find first buf_sysconf no-lock
        where buf_sysconf.host-code = p-host-code
    .
    assign
        v-main-buh  = buf_sysconf.snr-accnt
    .
    put stream Out-stream
      skip (1)
      space ({&left-margin}) "Руководитель предприятия "
      v-main-boss   format "X(25)"   at ({&left-margin} + 35)
      " ________________ (подпись)"
      skip (1)
      space ({&left-margin}) "Гл. бухгалтер            "
      v-main-buh   format "X(25)"   at ({&left-margin} + 35)
      " ________________ (подпись)"
    .
end.
end procedure. /* print-footer */