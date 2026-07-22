block-level on error undo, throw.
/*

$Revision: ac3ee8e28890, 1428, test $
$Author: ASMorozov $
$Date: Fri Jun 29 18:00:05 2018 +0300 $
$Workfile: imp-marks-temp.p $
$Archive: str/imp-marks-temp.p $

Импорт акцизных марок из файла во временную таблицу.

Автор: Морозов Александр Сергевич
Дата создания: 03/21/17
Author: Alexandr Morozov
Creation date: 03/21/17



*/
using ibs.th.bge.egais.*.
{ str/inv-marks-tt.i }


define output parameter table for tt-marks .
define output parameter table for tt-alc-qnty .
define input parameter pardoc-code      like ub.trn-doc.doc-code  no-undo.

define variable vss-revision    as character no-undo init "$Revision: ac3ee8e28890, 1428, test $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Fri Jun 29 18:00:05 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: imp-marks-temp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/imp-marks-temp.p $":U .
define variable vss-description as character no-undo init "Импорт акцизных марок из файла во временную таблицу.".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

{ bge/egais-mark.i }
{ str/marks.i } 

define stream inp.
define stream err.
define stream wrn.


define variable InputFileName  as character         no-undo.
define variable vartemp-ext as character no-undo.
define variable varlog      as logical   no-undo.

define variable varuser-action as character no-undo.
define variable varis-printed  as logical   no-undo.

define variable i-line      as character no-undo .
define variable v-ean       as logical no-undo .
define variable v-prod-bc   as character no-undo .

define variable v-col-ean   as integer no-undo initial 0 .
define variable v-col-ean-ok as integer no-undo initial 0 .
define variable v-col-marks as integer no-undo initial 0 .
define variable v-col-marks-ok as integer no-undo initial 0 .

define variable v-gds-code    like ub.goods.gds-code     no-undo .
define variable v-gds-name    as character    no-undo .
define variable v-alc-code    as character    no-undo .
define variable v-error-lang  as logical      no-undo .
define variable l-error         as logical   no-undo. /* Есть ли ошибки */
def    var      extGdsObj       as class     extgds.

define buffer buf_prod-bc for ub.prod-bc .
define buffer buf_bar-code for ub.bar-code .
define buffer buf_goods for ub.goods .
define buffer buf_doc-line for ub.doc-line.

   system-dialog get-file InputFileName
                 title   "Файл с акцизными марками"
                 filters "Текстовый файл (*.txt)"   "*.txt",
                         "Все файлы (*.*)"          "*.*"
                 must-exist
                 use-filename
                 default-extension ".txt"
                 update varlog.
   if not varlog then return error.

InputFileName = trim (string (InputFileName)) .
assign
vartemp-ext = entry (2, InputFileName, ".") no-error.
if error-status:error then do:
  message "Файл без расширения не может быть обработан. Переименуйте его."
          view-as alert-box error.
  return error.
end.

if entry (2, InputFileName, ".") = "err" then do:
  message "Файл с расширением '.err' не может быть обработан. Переименуйте его."
          view-as alert-box error.
  return error.
end.
if entry (2, InputFileName, ".") = "wrn" then do:
  message "Файл с расширением '.wrn' не может быть обработан. Переименуйте его."
          view-as alert-box error.
  return error.
end.

extGdsObj = new ExtGds (true).


output stream err TO value (entry (1, InputFileName, ".") + ".err").
    

    
input stream inp FROM value (InputFileName) .


file-line_:
repeat :
    import stream  inp unformatted i-line no-error.
    i-line = trim(i-line) .
    if length(i-line) = 13
    then do :
        v-ean = true.
        v-prod-bc = i-line .
        v-gds-code = 0 .
        v-col-ean = v-col-ean + 1 .
        find first buf_prod-bc no-lock where buf_prod-bc.b-str = v-prod-bc no-error.
        if not available buf_prod-bc
        then do :
            put stream err unformatted "Не найден доп. бар-код EAN13 " v-prod-bc skip "Следующие марки не загружены:" skip .
            v-ean = false .
            next file-line_ .
        end.
        find first buf_bar-code no-lock where buf_bar-code.b-code = buf_prod-bc.b-code no-error.
        if not available buf_bar-code
        then do :
            put stream err unformatted "Не найден бар-код для кода EAN13 " v-prod-bc skip "Следующие марки не загружены:" skip .
            v-ean = false .
            next file-line_ .
        end.
        find first buf_goods no-lock where buf_goods.gds-code = buf_bar-code.gds-code no-error.
        if not available buf_goods
        then do :
            put stream err unformatted "Не найден товар для кода EAN13 " v-prod-bc skip "Следующие марки не загружены:" skip .
            v-ean = false .
            next file-line_ .
        end.
        
        find first buf_doc-line no-lock where buf_doc-line.doc-code = pardoc-code
                                          and buf_doc-line.artic    = buf_goods.artic
                                          and buf_doc-line.prod-type = buf_goods.prod-type
                                          and buf_doc-line.prod-code = buf_goods.prod-code no-error .
        if not available buf_doc-line
        then do :
            put stream err unformatted "В документе нет товара (код " buf_goods.gds-code ") " buf_goods.gds-name " с доп. БК EAN13 " v-prod-bc skip "Следующие марки не загружены:" skip .
            v-ean = false .
            next file-line_ .
        end.                               

        
        v-gds-code = buf_goods.gds-code .
        v-col-ean-ok = v-col-ean-ok + 1 .
    end.
    else do :
        v-col-marks = v-col-marks + 1 .
        if not v-ean
        then do :
            put stream err unformatted i-line skip .
            next file-line_ .
        end.
        else do :
            
            find first tt-marks no-lock where tt-marks.exciseMark = i-line no-error.
            if available tt-marks
            then do :
                put stream err unformatted "В файле продублирована марка " i-line skip .
                next file-line_ .
            end.
            
            run ProcAlcCode  in THIS-PROCEDURE (input i-line, output v-alc-code, output l-error, output v-error-lang ) no-error.
            
            if v-error-lang
            then do:
              put stream err unformatted
                "Некорректная акцизная марка, акцизная марка содержит недопустимые символы или русские буквы.  " i-line
                skip .
              v-alc-code = "".
              l-error = yes .
              next file-line_ .
            end.
            
            extGdsObj:OpenQueryExtGds(v-gds-code, v-alc-code).
            if extGdsObj:NumBundles = 0
            then do :
                put stream err unformatted "Нет связки товара (код " string(v-gds-code) ") с алкокодом " v-alc-code ". Марка " i-line skip .
                next file-line_ .
            end.
            
            find first buf_goods where buf_goods.gds-code = v-gds-code.
            
            find first buf_doc-line no-lock where buf_doc-line.doc-code = pardoc-code
                                          and buf_doc-line.artic    = buf_goods.artic
                                          and buf_doc-line.prod-type = buf_goods.prod-type
                                          and buf_doc-line.prod-code = buf_goods.prod-code no-error .
            
            create tt-marks .
            assign
                tt-marks.exciseMark     = i-line
                tt-marks.alc-code       = v-alc-code
                tt-marks.artic          = buf_goods.artic
                tt-marks.prod-type      = buf_goods.prod-type
                tt-marks.prod-code      = buf_goods.prod-code
                tt-marks.gds-code       = buf_goods.gds-code
                tt-marks.isCurr         = false
                tt-marks.doc-code       = buf_doc-line.doc-code 
                tt-marks.line-num       = buf_doc-line.line-num
            .
            
            find first tt-alc-qnty exclusive-lock where tt-alc-qnty.artic       = tt-marks.artic
                                                    and tt-alc-qnty.prod-type   = tt-marks.prod-type
                                                    and tt-alc-qnty.prod-code   = tt-marks.prod-code
                                                    and tt-alc-qnty.alc-code    = tt-marks.alc-code no-error.
            if not available tt-alc-qnty
            then do :
                create tt-alc-qnty .
                assign
                    tt-alc-qnty.artic       = tt-marks.artic
                    tt-alc-qnty.prod-type   = tt-marks.prod-type
                    tt-alc-qnty.prod-code   = tt-marks.prod-code
                    tt-alc-qnty.alc-code    = tt-marks.alc-code
                    tt-alc-qnty.gds-code    = tt-marks.gds-code
                    tt-alc-qnty.qnty        = 0
                .
            end.
            tt-alc-qnty.qnty = tt-alc-qnty.qnty + 1 .
            
            v-col-marks-ok = v-col-marks-ok + 1 .         
            
                                           
        end.
    end.
end.

put stream err unformatted skip .
put stream err unformatted skip .
output stream err close.

message "Импорт завершен."
   skip "Прочитано кодов EAN13: " string(v-col-ean)
   skip "Прочитано марок: " string(v-col-marks)
   skip "Обработано кодов EAN13: " string(v-col-ean-ok)
   skip "Закачано марок: " string(v-col-marks-ok)
   skip(2) "Информация об ошибках находится в файле :" entry (1, InputFileName, ".") + ".err"
   view-as alert-box information .
   
/*run gbl/prnfilen.w                                */
/*    (input  "Ошибки"                              */
/*    ,input  0                                     */
/*    ,input  entry (1, InputFileName, ".") + ".err"*/
/*    ,input  7                                     */
/*    ,output varuser-action                        */
/*    ,output varis-printed                         */
/*    ).                                            */

