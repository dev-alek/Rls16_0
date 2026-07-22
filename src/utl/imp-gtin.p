block-level on error undo, throw.

/*------------------------------------------------------------------------
    File        : imp-gtin.p
    Purpose     : 

    Syntax      :

    Description : Для того, чтобы первоначально загрузить данные по GTIN требуется реализовать утилиту импорта.
ДОбавить ее в Сервис\Служебные программы.
В интерйевсе выбирается файл для загрузки.
Формат будет чуть позже.
Построчно определяем товар.
Если товар не найден или некорректные значения, то пишем в лог ошибку, запись отправляем в файл, с таким же названием, с расширением err. формат записи сохраняем.
В конце выдаем счетчик сколько было записей и сколько загружено.

    Author(s)   : SSlivenko
    Created     : Mon Jan 21 10:51:01 AST 2019
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

define input parameter parparentproc as handle no-undo .


define variable vss-revision    as character no-undo init "$Revision: 1eba0946c2d7, 3078, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: Пт авг 05 19:16:25 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: imp-gtin.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/imp-gtin.p $":U .
define variable vss-description as character no-undo init "Импорт gtin".

{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/getcntxt.i def }
{ gbl/thbj-def.i }
{ gbl/thbjattr.i }
{ gbl/objsrv.i }
define variable MarkType as ibs.th.str.marking.Types no-undo.
MarkType = ObjSrv:Env:Marking:Types.
define variable v-imp-file as character no-undo .
define variable v-err-file as character no-undo .
define variable v-log-file as character no-undo .
define variable v-s as character no-undo .
define variable v-log as logical no-undo .

DEFINE VARIABLE mExcelApplication AS COMPONENT-HANDLE NO-UNDO. /* ССЫЛКА НА ПРИЛОЖЕНИЕ */
DEFINE VARIABLE mWorkBook         AS COMPONENT-HANDLE NO-UNDO. /* ССЫЛКА НА РАБОЧУЮ КНИГУ */
DEFINE VARIABLE mWorkSheet        AS COMPONENT-HANDLE NO-UNDO. /* ССЫЛКА НА РАБОЧИЙ ЛИСТ */
DEFINE VARIABLE mMaxNoLine        AS INTEGER          INITIAL 10 NO-UNDO. /* Максимально пропусков */

DEFINE VARIABLE vLine   AS INTEGER   NO-UNDO.
DEFINE VARIABLE vChLine AS CHARACTER NO-UNDO.
DEFINE VARIABLE vCh     AS CHARACTER NO-UNDO.
DEFINE VARIABLE vNoLine AS INTEGER   NO-UNDO.

define variable v-num as character no-undo .
define variable v-b-code as character no-undo .
define variable v-gds-name as character no-undo .
define variable v-pack-gtin as character no-undo .
define variable v-mark-code as character no-undo .
define variable v-blok-b-code as character no-undo .
define variable v-blok-gtin as character no-undo .
define variable v-blok-mark-code as character no-undo .
define variable v-koef as character no-undo .

define variable v-bar-code as integer no-undo .
define variable v-bc-rid as recid no-undo .
define variable v-b-str as character no-undo .

define variable v-lines as integer no-undo .
define variable v-ok-lines as integer no-undo .

define buffer buf_bar-code for ub.bar-code .
define buffer blok_bar-code for ub.bar-code .
define buffer buf_prod-bc  for ub.prod-bc .
define buffer buf_prod-bc-attr for ub.prod-bc-attr.
define buffer buf_units    for ub.units .
define buffer buf_goods    for ub.goods .

define stream s-err .
define stream s-log .

define temp-table tt-gds-gtin
  field b-code as character
  field gds-name as character
  field pack-gtin as character
  field mark-code as character
  field blok-b-code as character
  field blok-gtin as character
  field blok-mark-code as character
  field koef as decimal
.

{ gbl/waitfram.i }

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

find first buf_units no-lock where buf_units.unit-name = "блок" no-error.
if not available buf_units
then do :
  find first buf_units no-lock where buf_units.long-name = "блок" no-error.
end.
if not available buf_units
then do :
  message "В системе не найдена единица измерения 'блок'!" view-as alert-box error .
  return .
end.

do: /* A */
  { gbl/getcntxt.i get }
  
  define variable v-tth as handle no-undo.  
  define variable v-chg-bcod as logical no-undo.
  define variable v-value-character as character no-undo.
  define variable v-value-date as date no-undo.
  define variable v-value-decimal as decimal no-undo.
  define variable v-value-integer as INTEGER no-undo.
  define variable v-value-logical AS LOGICAL no-undo.
  define variable v-param-type as character no-undo.
  define buffer buf_goods-attr for goods-attr.
  assign v-tth = buffer thbjattr_thbj-attr:table-handle.

  FOR EACH thbjattr_thbj-attr:
      delete thbjattr_thbj-attr.
  end.

  run adm/shattri.p (
            input "get":U
          , input v-cntxt-obj-type
          , input v-cntxt-obj-code
          , input {&attr-gds-ref_obj}
          , input {&attr-gds-ref_obj_chg-bcod} /*p-param-code*/
          , output v-value-character
          , output v-value-date
          , output v-value-decimal
          , output v-value-integer
          , output v-value-logical
          , output v-param-type
          , INPUT-OUTPUT table-handle v-tth
          ) no-error .
  
   v-chg-bcod = v-value-logical.
   if v-cntxt-db-num = 0 then v-chg-bcod = no .
end. /* A */

if v-chg-bcod 
then do :
  message "Запрещена работа с доп. БК. Импорт невозможен." view-as alert-box .
  return .
end .

SYSTEM-DIALOG GET-FILE
  v-imp-file
  FILTERS "Файлы Excel *.xlsx,*.xls" "*.xlsx,*.xls",
          "Все файлы"  "*.*"
  MUST-EXIST
  TITLE "Выберите файл для импорта"
  USE-FILENAME
  UPDATE v-log.

if v-log <> true then do:
  return .
end.

run waitfram-show in this-procedure ( "ЖДИТЕ...") .


CREATE "Excel.Application":U mExcelApplication no-error.
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        undo, return error .
    end.
ASSIGN
    mExcelApplication:DisplayAlerts = NO
    mWorkbook                       = mExcelApplication:WorkBooks:Add(v-imp-file)
    mWorkSheet                      = mWorkbook:Sheets:Item(1)
.

loopbl:
do vLine = 1 to 1000000:
  ASSIGN
    vChLine = STRING(vLine)
    v-gds-name    = ''
    v-b-code      = ''
    v-pack-gtin   = ''
    v-mark-code   = ''
    v-blok-b-code = ''
    v-blok-gtin   = ''
    v-blok-mark-code  = ''
    v-koef        = ''
  .
  
  v-num = mWorkSheet:Range("A" + vChLine):FORMULA NO-ERROR.  
  if v-num = ? then v-num = mWorkSheet:Range("A" + vChLine):VALUE NO-ERROR.
  
  integer(v-num) no-error .
  if error-status:error then next loopbl .
  
  v-gds-name = mWorkSheet:Range("B" + vChLine):FORMULA NO-ERROR.  
  if v-gds-name = ? then v-gds-name = mWorkSheet:Range("B" + vChLine):VALUE NO-ERROR. 
  
  v-b-code = mWorkSheet:Range("C" + vChLine):FORMULA NO-ERROR.  
  if v-b-code = ? then v-b-code = mWorkSheet:Range("C" + vChLine):VALUE NO-ERROR.
  
  v-pack-gtin = mWorkSheet:Range("D" + vChLine):FORMULA NO-ERROR.  
  if v-pack-gtin = ? then v-pack-gtin = mWorkSheet:Range("D" + vChLine):VALUE NO-ERROR.
  
  v-mark-code = mWorkSheet:Range("E" + vChLine):FORMULA NO-ERROR.  
  if v-mark-code = ? then v-mark-code = mWorkSheet:Range("E" + vChLine):VALUE NO-ERROR.
  
  v-blok-b-code = mWorkSheet:Range("F" + vChLine):FORMULA NO-ERROR.  
  if v-blok-b-code = ? then v-blok-b-code = mWorkSheet:Range("F" + vChLine):VALUE NO-ERROR.
  
  v-blok-gtin = mWorkSheet:Range("G" + vChLine):FORMULA NO-ERROR.  
  if v-blok-gtin = ? then v-blok-gtin = mWorkSheet:Range("G" + vChLine):VALUE NO-ERROR.
  
  v-blok-mark-code = mWorkSheet:Range("H" + vChLine):FORMULA NO-ERROR.  
  if v-blok-mark-code = ? then v-blok-mark-code = mWorkSheet:Range("H" + vChLine):VALUE NO-ERROR.
  
  v-koef = mWorkSheet:Range("I" + vChLine):FORMULA NO-ERROR.  
  if v-koef = ? then v-koef = mWorkSheet:Range("I" + vChLine):VALUE NO-ERROR.
  
  
  if length(v-gds-name) > 0
  or length(v-b-code) > 0
  or length(v-pack-gtin) > 0
  or length(v-mark-code) > 0
  or length(v-blok-b-code) > 0
  or length(v-blok-gtin) > 0
  or length(v-blok-mark-code) > 0
  or length(v-koef) > 0
  then do :
    vNoLine = 0 .
  end.
  else do :
    vNoLine = vNoLine + 1.
    IF vNoLine > mMaxNoLine THEN LEAVE loopbl. 
    ELSE NEXT loopbl. 
  end.
  
  create tt-gds-gtin .
  tt-gds-gtin.gds-name    = v-gds-name .
  tt-gds-gtin.b-code      = v-b-code no-error .
  tt-gds-gtin.pack-gtin   = v-pack-gtin .
  tt-gds-gtin.mark-code   = v-mark-code .
  tt-gds-gtin.blok-b-code = v-blok-b-code no-error .
  tt-gds-gtin.blok-gtin   = v-blok-gtin .
  tt-gds-gtin.blok-mark-code = v-blok-mark-code .
  tt-gds-gtin.koef        = decimal(v-koef) no-error .
  release tt-gds-gtin .
  
end.

v-lines = 0 .
v-ok-lines = 0 .
v-err-file = v-imp-file + ".err" .
v-log-file = v-imp-file + ".log" .
output stream s-err to value(v-err-file).
output stream s-log to value(v-log-file).

for each tt-gds-gtin no-lock :
  v-lines = v-lines + 1 .
  
  do trans :
    find first buf_prod-bc no-lock where buf_prod-bc.b-str = tt-gds-gtin.b-code no-error.
    if not available buf_prod-bc
    then do :
      export stream s-err delimiter ";" tt-gds-gtin .
      put stream s-log unformatted "Не найден доп. код " tt-gds-gtin.b-code skip skip .
      next .
    end.
    find first buf_bar-code no-lock where buf_bar-code.b-code = buf_prod-bc.b-code no-error .
    if not available buf_bar-code
    then do :
      export stream s-err delimiter ";" tt-gds-gtin .
      put stream s-log unformatted "Не найден собственный бар-код для штрих-кода " tt-gds-gtin.b-code skip skip .
      next .
    end.
    find first buf_goods no-lock where buf_goods.gds-code = buf_bar-code.gds-code no-error.
    if not available buf_goods
    then do :
      export stream s-err delimiter ";" tt-gds-gtin .
      put stream s-log unformatted "Не найден товар с бар-кодом " string(buf_bar-code.b-code) " . Штрих-код - " tt-gds-gtin.b-code skip skip .
      next .
    end.
    
    find first goods-attr exclusive-lock where goods-attr.gds-code = buf_goods.gds-code
                                          and goods-attr.attr-code = {&attr-mark-type}
                                          no-error.
    if not available goods-attr
    then do :
      create goods-attr .
      assign
        goods-attr.gds-code = buf_goods.gds-code
        goods-attr.attr-code = {&attr-mark-type}
      .
    end.
    assign goods-attr.attr-value =  MarkType:tabak:nameprop.
    
    v-bar-code = buf_bar-code.b-code .
    
    
    v-b-str = tt-gds-gtin.pack-gtin .
    
    if trim(v-b-str) > ""
    then do : 
      run trg/prod-bc2.p (
                          input parparentproc
                        ,input yes /*p-silent*/
                        ,input no /*dif-pdbc*/
                        ,input yes /*pbc-veto*/
                        ,input no /*send-ref*/
                        ,input {&gtin} /*p-cdrg-type*/
                        ,input '' /*ean-type*/
                        ,buffer buf_goods
                        ,input v-bar-code
                        ,input no /*требует маркировки*/
                        ,input-output v-b-str
                        ,output v-bc-rid
                    ) no-error .
      if error-status :error
      or v-bc-rid = ?
      then do :
        export stream s-err delimiter ";" tt-gds-gtin .
        put stream s-log unformatted return-value skip skip .
        undo, next .
      end.
    end.  
    
    v-b-str = tt-gds-gtin.mark-code .
    
    if trim(v-b-str) > ""
    then do :
      find first buf_prod-bc no-lock where buf_prod-bc.b-code = v-bar-code
                                       and buf_prod-bc.b-str = v-b-str
                                       no-error.
      if available buf_prod-bc
      then do :
        if buf_prod-bc.bc-on-type = {&gtin}
        then do :
          export stream s-err delimiter ";" tt-gds-gtin .
          put stream s-log unformatted "В системе уже есть код " v-b-str ", который является GTIN'ом. Его нельзя сделать маркированным." skip skip .
          undo, next .
        end.
        find first buf_prod-bc-attr exclusive-lock where buf_prod-bc-attr.b-str = buf_prod-bc.b-str
                                                     and buf_prod-bc-attr.b-code = buf_prod-bc.b-code
                                                     and buf_prod-bc-attr.attr-code = {&mark}
                                                     no-error .
        if not available buf_prod-bc-attr
        then do :
          create buf_prod-bc-attr.
          assign
            buf_prod-bc-attr.b-str  = buf_prod-bc.b-str
            buf_prod-bc-attr.b-code = buf_prod-bc.b-code 
            buf_prod-bc-attr.attr-code = {&mark}
          .
        end.
        buf_prod-bc-attr.attr-value = "yes" .
      end.
      else do :                                 
        run trg/prod-bc2.p (
                            input parparentproc
                          ,input yes /*p-silent*/
                          ,input no /*dif-pdbc*/
                          ,input yes /*pbc-veto*/
                          ,input no /*send-ref*/
                          ,input '' /*p-cdrg-type*/
                          ,input '' /*ean-type*/
                          ,buffer buf_goods
                          ,input v-bar-code
                          ,input yes /*требует маркировки*/
                          ,input-output v-b-str
                          ,output v-bc-rid
                      ) no-error .
        if error-status :error
        or v-bc-rid = ?
        then do :
          export stream s-err delimiter ";" tt-gds-gtin .
          put stream s-log unformatted return-value skip skip .
          undo, next .
        end.
      end.
    end.
    
    if trim(tt-gds-gtin.blok-b-code) > ""
    or trim(tt-gds-gtin.blok-gtin) > ""
    or trim(tt-gds-gtin.blok-mark-code) > ""
    then do :
      integer(tt-gds-gtin.blok-b-code) no-error .
      if not error-status:error
      then do :
        find first bar-code no-lock where bar-code.b-code = integer(tt-gds-gtin.blok-b-code) no-error.
        if available bar-code
        then do :
          if bar-code.gds-code <> buf_goods.gds-code
          then do :
            export stream s-err delimiter ";" tt-gds-gtin .
            put stream s-log unformatted "Уже есть бар-код " string(tt-gds-gtin.blok-b-code) " для товара с кодом " string(bar-code.gds-code) skip skip .
            undo, next .
          end.
          if  bar-code.unit-cli = buf_units.unit-name
          and bar-code.cli-base-rate = tt-gds-gtin.koef
          then do :
            find first blok_bar-code no-lock where recid(blok_bar-code) = recid(bar-code) no-error .
          end.
        end.
      end.
      
      if not available blok_bar-code
      then do :
        find first prod-bc no-lock where prod-bc.b-str = tt-gds-gtin.blok-b-code no-error.
        if available prod-bc
        then do :
          find first blok_bar-code no-lock where blok_bar-code.b-code = prod-bc.b-code
                                             and blok_bar-code.gds-code = buf_goods.gds-code
                                             and blok_bar-code.unit-cli = buf_units.unit-name
                                             and blok_bar-code.cli-base-rate = tt-gds-gtin.koef
                                             no-error .
        end.
      end.
      
      if not available blok_bar-code
      then do :
        find first blok_bar-code no-lock where blok_bar-code.gds-code = buf_goods.gds-code
                                           and blok_bar-code.unit-cli = buf_units.unit-name
                                           and blok_bar-code.cli-base-rate = tt-gds-gtin.koef
                                           no-error .
      end.
      
      if not available blok_bar-code
      then do :
        find first blok_bar-code no-lock where blok_bar-code.gds-code = buf_goods.gds-code
                                           and blok_bar-code.unit-cli = buf_units.unit-name
                                           no-error .
        if available blok_bar-code and blok_bar-code.cli-base-rate <> tt-gds-gtin.koef     
        then do :
          export stream s-err delimiter ";" tt-gds-gtin .
          put stream s-log unformatted "Товар " string(buf_goods.gds-code) "  " buf_goods.gds-name " . Коэффициент для блока в файле не равен коэффициенту в TH." skip skip .
          undo, next .
        end.                              
      end.
      
      
      if not available blok_bar-code
      then do :
        find gds-prt no-lock where gds-prt.node-code = buf_bar-code.node-code .
        
        run ref/barcode1.p (
                           input {&add-def}
                          ,input yes /*p-silent*/
                          ,input 0
                          ,input buf_goods.gds-code
                          ,input gds-prt.node-code
                          ,input buf_bar-code.part-code
                          ,input buf_bar-code.in-code
                          ,input buf_units.unit-name
                          ,input tt-gds-gtin.koef
                          ,output v-bc-rid) no-error.
        if error-status :error
        then do :
          export stream s-err delimiter ";" tt-gds-gtin .
          put stream s-log unformatted return-value skip skip .
          undo, next .
        end.  
        
        find first blok_bar-code no-lock where recid(blok_bar-code) = v-bc-rid no-error .
        if not available blok_bar-code
        then do :
          export stream s-err delimiter ";" tt-gds-gtin .
          put stream s-log unformatted return-value skip skip .
          undo, next .
        end.
      end.  
      
      v-bar-code = blok_bar-code.b-code .
      v-b-str = tt-gds-gtin.blok-b-code .
      
      if trim(v-b-str) > ""
      then do :
        run trg/prod-bc2.p (
                            input parparentproc
                          ,input yes /*p-silent*/
                          ,input no /*dif-pdbc*/
                          ,input yes /*pbc-veto*/
                          ,input no /*send-ref*/
                          ,input '' /*p-cdrg-type*/
                          ,input '' /*ean-type*/
                          ,buffer buf_goods
                          ,input v-bar-code
                          ,input no /*требует маркировки*/
                          ,input-output v-b-str
                          ,output v-bc-rid
                      ) no-error .
        if error-status :error
        or v-bc-rid = ?
        then do :
          export stream s-err delimiter ";" tt-gds-gtin .
          put stream s-log unformatted return-value skip skip .
          undo, next .
        end.
      end.
      
      v-b-str = tt-gds-gtin.blok-gtin .
      
      if trim(v-b-str) > ""
      then do :
        find first prod-bc no-lock where prod-bc.b-str = v-b-str no-error .
        if available prod-bc
        then do :
          find first bar-code no-lock where bar-code.b-code = prod-bc.b-code no-error.
          if not available bar-code
          then do :
            export stream s-err delimiter ";" tt-gds-gtin .
            put stream s-log unformatted return-value skip skip .
            undo, next .
          end.
          if bar-code.gds-code <> buf_goods.gds-code
          then do :
            export stream s-err delimiter ";" tt-gds-gtin .
            put stream s-log unformatted "Товар " string(buf_goods.gds-code) "  " buf_goods.gds-name " уже есть доп. код " v-b-str " и он относится к другому товару - " string(bar-code.gds-code) skip skip .
            undo, next .
          end.
          if prod-bc.bc-on-type <> {&gtin}
          then do :
            export stream s-err delimiter ";" tt-gds-gtin .
            put stream s-log unformatted "Товар " string(buf_goods.gds-code) "  " buf_goods.gds-name " уже есть доп. код " v-b-str " и его тип не GTIN" skip skip .
            undo, next .
          end.
        end.
        else do :
          run trg/prod-bc2.p (
                              input parparentproc
                            ,input yes /*p-silent*/
                            ,input no /*dif-pdbc*/
                            ,input yes /*pbc-veto*/
                            ,input no /*send-ref*/
                            ,input {&gtin} /*p-cdrg-type*/
                            ,input '' /*ean-type*/
                            ,buffer buf_goods
                            ,input v-bar-code
                            ,input no /*требует маркировки*/
                            ,input-output v-b-str
                            ,output v-bc-rid
                        ) no-error .
          if error-status :error
          or v-bc-rid = ?
          then do :
            export stream s-err delimiter ";" tt-gds-gtin .
            put stream s-log unformatted return-value skip skip .
            undo, next .
          end.
        end.
      end.  
      
      v-b-str = tt-gds-gtin.blok-mark-code .
      
      if trim(v-b-str) > ""
      then do :
        find first buf_prod-bc no-lock where buf_prod-bc.b-code = v-bar-code
                                         and buf_prod-bc.b-str = v-b-str
                                         no-error.
        if available buf_prod-bc
        then do :
          find first buf_prod-bc-attr exclusive-lock where buf_prod-bc-attr.b-str = buf_prod-bc.b-str
                                                       and buf_prod-bc-attr.b-code = buf_prod-bc.b-code
                                                       and buf_prod-bc-attr.attr-code = {&mark}
                                                       no-error .
          if not available buf_prod-bc-attr
          then do :
            create buf_prod-bc-attr.
            assign
              buf_prod-bc-attr.b-str  = buf_prod-bc.b-str
              buf_prod-bc-attr.b-code = buf_prod-bc.b-code 
              buf_prod-bc-attr.attr-code = {&mark}
            .
          end.
          buf_prod-bc-attr.attr-value = "yes" .
        end.
        else do :
          run trg/prod-bc2.p (
                              input parparentproc
                            ,input yes /*p-silent*/
                            ,input no /*dif-pdbc*/
                            ,input yes /*pbc-veto*/
                            ,input no /*send-ref*/
                            ,input '' /*p-cdrg-type*/
                            ,input '' /*ean-type*/
                            ,buffer buf_goods
                            ,input v-bar-code
                            ,input yes /*требует маркировки*/
                            ,input-output v-b-str
                            ,output v-bc-rid
                        ) no-error .
          if error-status :error
          or v-bc-rid = ?
          then do :
            export stream s-err delimiter ";" tt-gds-gtin .
            put stream s-log unformatted return-value skip skip .
            undo, next .
          end.
        end.
      end.
    end.
    
    v-ok-lines = v-ok-lines + 1 .
    
  end. /* trans */
end.

output stream s-err close .
output stream s-log close .

run waitfram-hide in this-procedure .

message "Готово. Обработано " string(v-lines) " строк. Загружено " string(v-ok-lines) "." skip 
        "Незагруженные коды в файле " v-err-file skip
        "Ошибки в файле " v-log-file view-as alert-box information .