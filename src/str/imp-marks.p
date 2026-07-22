block-level on error undo, throw.
/*

$Revision: 616d42daa905, 1424, test $
$Author: SSlivenko $
$Date: Fri Jun 29 17:59:59 2018 +0300 $
$Workfile: imp-marks.p $
$Archive: str/imp-marks.p $

Импорт доп. БК, внеш. ПН, Документ назначения цены из текстового файла

Автор: Чернова Светлана Александровна
Дата создания: 11/21/06
Author: Svetlana Chernova
Creation date: 11/21/06

create2: Суслов Алексей Юрьевич
Дата создания: 09/20/05

create1 : Андрей Исаков 12.05.98

*/
using ibs.th.bge.egais.*. 

define input parameter parparentproc    as handle              no-undo.
define input parameter pardoc-code      like ub.trn-doc.doc-code  no-undo.
define input parameter p-mode as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: 616d42daa905, 1424, test $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Fri Jun 29 17:59:59 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: imp-marks.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/imp-marks.p $":U .
define variable vss-description as character no-undo init "Импорт доп. БК, внеш. ПН, Документ назначения цены из текстового файла".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

{ bge/egais-mark.i }
{ str/marks.i }
{ gbl/key-rec.i  }

define new shared stream inp.
define new shared stream err.
define new shared stream wrn.

define temp-table tt-marks
    field mark                as character            label "Марка"          format "X(100)"
    field alc-code            as character            LABEL "Алк. код"       FORMAT "X(20)"  
    field artic        as character
    field prod-type    as character
    field prod-code    as integer
    field obj-type     as character
    field obj-code     as integer   
    index pi as primary unique
        mark
.

define temp-table tt-alc-qnty
    field artic        as character
    field prod-type    as character
    field prod-code    as integer
    field alc-code as character
    field qnty as integer
    index pi as primary unique
        artic prod-type prod-code alc-code
.


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
define variable part-key-rec as character no-undo .
define variable free-part-key-rec as character no-undo .


define buffer buf_trn-doc for ub.trn-doc  .
define buffer buf2_trn-doc for ub.trn-doc  .
define buffer buf_doc-line for ub.doc-line .
define buffer buf_parts for ub.parts .
define buffer free_parts for ub.parts .
define buffer buf_prod-bc for ub.prod-bc .
define buffer buf_bar-code for ub.bar-code .
define buffer buf_goods for ub.goods .
define buffer buf_gen-attr for ub.gen-attr .
define buffer free_gen-attr for ub.gen-attr .



   SYSTEM-DIALOG GET-FILE InputFileName
                 TITLE   "Файл с акцизными марками"
                 FILTERS "Текстовый файл (*.txt)"   "*.txt",
                         "Все файлы (*.*)"          "*.*"
                 MUST-EXIST
                 USE-FILENAME
                 default-extension ".txt"
                 UPDATE varlog.
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



output stream err TO value (entry (1, InputFileName, ".") + ".err").
    
find first buf_trn-doc no-lock where buf_trn-doc.doc-code = pardoc-code .
    
input stream inp FROM value (InputFileName) .
extGdsObj = new ExtGds (true).

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
        v-gds-code = buf_goods.gds-code .
        if p-mode = "in"
        then do :
            find first buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code
                                              and buf_doc-line.artic    = buf_goods.artic
                                              and buf_doc-line.prod-type = buf_goods.prod-type
                                              and buf_doc-line.prod-code = buf_goods.prod-code no-error .
            if not available buf_doc-line
            then do :
                put stream err unformatted "В накладной нет товара (код " buf_goods.gds-code ") " buf_goods.gds-name " с доп. БК EAN13 " v-prod-bc skip "Следующие марки не загружены:" skip .
                v-ean = false .
                next file-line_ .
            end.
            find first buf_parts no-lock where buf_parts.obj-type   = buf_doc-line.obj-type
                                           and buf_parts.obj-code   = buf_doc-line.obj-code
                                           and buf_parts.artic      = buf_doc-line.artic
                                           and buf_parts.prod-type  = buf_doc-line.prod-type
                                           and buf_parts.prod-code  = buf_doc-line.prod-code
                                           and buf_parts.in-code    = pardoc-code
                                           and buf_parts.out-code   = pardoc-code
                                           no-error .
            if not available buf_parts
            then do :
                put stream err unformatted "Не найдена партия товара (код " buf_goods.gds-code ") " buf_goods.gds-name " с доп. БК EAN13 " v-prod-bc skip "Следующие марки не загружены:" skip .
                v-ean = false .
                next file-line_ .
            end.
            else do :
                if num-entries(buf_parts.alc-ref-ab-path) = 4 and trim(entry(3, buf_parts.alc-ref-ab-path)) = ""
                or num-entries(buf_parts.alc-ref-ab-path) <> 4
                then do :
                    put stream err unformatted "В партии товара (код " buf_goods.gds-code ") " buf_goods.gds-name " с доп. БК EAN13 " v-prod-bc " не указан алкогольный код" skip "Следующие марки не загружены:" skip .
                    v-ean = false .
                    next file-line_ .
                end.
            end.
        end.                               
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
            
            if p-mode = "in"
            then do :
                find first buf_gen-attr no-lock where buf_gen-attr.table-name = {&excise-mark}
                                                  and buf_gen-attr.attr-code = i-line no-error.
                if available buf_gen-attr
                then do :
                    put stream err unformatted "Марка " i-line " уже учтена в системе и привязана к партии " buf_gen-attr.p-key skip .
                    next file-line_ .
                end.
            end.    
            
            find first tt-marks no-lock where tt-marks.mark = i-line no-error.
            if available tt-marks
            then do :
                put stream err unformatted "В файле продублирована марка " i-line skip .
                next file-line_ .
            end.
            
            run ProcAlcCode  IN THIS-PROCEDURE (input i-line, output v-alc-code, output l-error, output v-error-lang ) no-error.
            
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
            
            if p-mode = "in"
            then do :            
                create tt-marks .
                assign
                    tt-marks.mark           = i-line
                    tt-marks.alc-code       = v-alc-code
                    tt-marks.artic          = buf_doc-line.artic
                    tt-marks.prod-type      = buf_doc-line.prod-type
                    tt-marks.prod-code      = buf_doc-line.prod-code
                    tt-marks.obj-type       = buf_doc-line.obj-type
                    tt-marks.obj-code       = buf_doc-line.obj-code
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
                        tt-alc-qnty.qnty        = 0
                    .
                end.
                tt-alc-qnty.qnty = tt-alc-qnty.qnty + 1 .
            end.
            if p-mode = "out"
            then do : 
                if not available buf_goods
                then
                find first buf_goods where buf_goods.gds-code = v-gds-code .
                create tt-marks .
                assign
                    tt-marks.mark           = i-line
                    tt-marks.alc-code       = v-alc-code
                    tt-marks.artic          = buf_goods.artic
                    tt-marks.prod-type      = buf_goods.prod-type
                    tt-marks.prod-code      = buf_goods.prod-code
                    tt-marks.obj-type       = buf_trn-doc.obj-type
                    tt-marks.obj-code       = buf_trn-doc.obj-code
                .
            end.
            
            v-col-marks-ok = v-col-marks-ok + 1 .         
            
        end.
    end.
end.

delete object extGdsObj no-error . 
put stream err unformatted skip .

save_:
for each tt-marks no-lock :
    if p-mode = "in"
    then do :
        find first buf_parts no-lock where buf_parts.obj-type   = tt-marks.obj-type
                                       and buf_parts.obj-code   = tt-marks.obj-code
                                       and buf_parts.artic      = tt-marks.artic
                                       and buf_parts.prod-type  = tt-marks.prod-type
                                       and buf_parts.prod-code  = tt-marks.prod-code
                                       and buf_parts.in-code    = pardoc-code
                                       and buf_parts.out-code   = pardoc-code
                                       no-error .
        if not available buf_parts
        then do :
            put stream err unformatted "Не найдена партия для привязки марки " tt-marks.mark skip .
            v-col-marks-ok = v-col-marks-ok - 1 .
            next save_ .
        end.
        
        if num-entries(buf_parts.alc-ref-ab-path) <> 4
        or (num-entries(buf_parts.alc-ref-ab-path) = 4 and trim(entry(3, buf_parts.alc-ref-ab-path)) = "")
        then do :
            put stream err unformatted "В партии не заполнен алкокод. Марка " tt-marks.mark skip .
            v-col-marks-ok = v-col-marks-ok - 1 .
            next save_ .
        end.
        
        if num-entries(buf_parts.alc-ref-ab-path) = 4 and entry(3, buf_parts.alc-ref-ab-path) <> tt-marks.alc-code
        then do :
            put stream err unformatted "Алкокод в партии " entry(3, buf_parts.alc-ref-ab-path) " не совпадает с алкокодом марки " tt-marks.alc-code " Марка " tt-marks.mark skip .
            v-col-marks-ok = v-col-marks-ok - 1 .
            next save_ .
        end.
        
        run gen-key-rec IN THIS-PROCEDURE (  input {&table_parts}
                                            ,input (buffer buf_parts:handle)
                                            ,output part-key-rec).
        create buf_gen-attr.   
        assign
            buf_gen-attr.table-name = {&excise-mark}
            buf_gen-attr.p-key      = part-key-rec
            buf_gen-attr.attr-code  = tt-marks.mark
            buf_gen-attr.whole-send-news = 0
        .  
    end.           
    
    if p-mode = "out"
    then do :
        for each buf_gen-attr no-lock where buf_gen-attr.table-name = {&excise-mark}
                                        and buf_gen-attr.attr-code  = tt-marks.mark 
                                        and num-entries(buf_gen-attr.p-key, {&delim-key}) > 8 :
            find first buf2_trn-doc no-lock where buf2_trn-doc.doc-code = entry(8, buf_gen-attr.p-key, {&delim-key}) no-error .
            if available buf2_trn-doc
            then do :
                if buf2_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
                then do :
                    put stream err unformatted "Марка " tt-marks.mark " уже учтена в другом расходе. Документ " buf2_trn-doc.doc-code skip .
                    v-col-marks-ok = v-col-marks-ok - 1 .
                    next save_ .
                end.
            end.                              
        end.
        find first buf_gen-attr no-lock where buf_gen-attr.table-name = {&excise-mark}
                                          and buf_gen-attr.attr-code  = tt-marks.mark
                                          and buf_gen-attr.p-key      = ("trn-doc" + {&delim-key} + pardoc-code)
                                          no-error .
        if not available buf_gen-attr
        then do :
            create buf_gen-attr .
            assign
                buf_gen-attr.table-name = {&excise-mark}
                buf_gen-attr.attr-code  = tt-marks.mark
                buf_gen-attr.p-key      = ("trn-doc" + {&delim-key} + pardoc-code)
                buf_gen-attr.attr-value = tt-marks.artic + {&delim-key} + tt-marks.prod-type + {&delim-key} + string(tt-marks.prod-code)
            .
        end.                                  
/*        find first free_gen-attr exclusive-lock where free_gen-attr.table-name = {&excise-mark}                        */
/*                                                  and free_gen-attr.attr-code  = tt-marks.mark                         */
/*                                                  and num-entries(free_gen-attr.p-key, {&delim-key}) > 8               */
/*                                                  and entry(8, free_gen-attr.p-key, {&delim-key}) = {&free-code}       */
/*                                                  no-error .                                                           */
/*        if not available free_gen-attr                                                                                 */
/*        then do :                                                                                                      */
/*            put stream err unformatted "Марка " tt-marks.mark " не найдена в свободной зоне" skip .                    */
/*            v-col-marks-ok = v-col-marks-ok - 1 .                                                                      */
/*            next save_ .                                                                                               */
/*        end.                                                                                                           */
/*        find first free_parts no-lock where free_parts.obj-type   = entry(2, free_gen-attr.p-key, {&delim-key})        */
/*                                       and free_parts.obj-code   = integer(entry(3, free_gen-attr.p-key, {&delim-key}))*/
/*                                       and free_parts.artic      = entry(4, free_gen-attr.p-key, {&delim-key})         */
/*                                       and free_parts.prod-type  = entry(5, free_gen-attr.p-key, {&delim-key})         */
/*                                       and free_parts.prod-code  = integer(entry(6, free_gen-attr.p-key, {&delim-key}))*/
/*                                       and free_parts.in-code    = entry(7, free_gen-attr.p-key, {&delim-key})         */
/*                                       and free_parts.out-code   = entry(8, free_gen-attr.p-key, {&delim-key})         */
/*                                       and free_parts.part-code  = entry(9, free_gen-attr.p-key, {&delim-key})         */
/*                                       no-error .                                                                      */
/*        if not available free_parts                                                                                    */
/*        then do :                                                                                                      */
/*            put stream err unformatted "Не найдена партия свободной зоны для марки " tt-marks.mark skip .              */
/*            v-col-marks-ok = v-col-marks-ok - 1 .                                                                      */
/*            next save_ .                                                                                               */
/*        end.                                                                                                           */
/*        find first buf_parts exclusive-lock where buf_parts.obj-type    = free_parts.obj-type                          */
/*                                              and buf_parts.obj-code    = free_parts.obj-code                          */
/*                                              and buf_parts.artic       = free_parts.artic                             */
/*                                              and buf_parts.prod-type   = free_parts.prod-type                         */
/*                                              and buf_parts.prod-code   = free_parts.prod-code                         */
/*                                              and buf_parts.in-code     = free_parts.in-code                           */
/*                                              and buf_parts.out-code    = pardoc-code                                  */
/*                                              no-error .                                                               */
    end.  
              
end.

put stream err unformatted skip .

if p-mode = "in"
then
for each tt-alc-qnty no-lock :
    find first buf_doc-line no-lock where buf_doc-line.doc-code = pardoc-code
                                      and buf_doc-line.artic    = tt-alc-qnty.artic
                                      and buf_doc-line.prod-type = tt-alc-qnty.prod-type
                                      and buf_doc-line.prod-code = tt-alc-qnty.prod-code no-error.
    if available buf_doc-line and buf_doc-line.fact-qnty <> tt-alc-qnty.qnty
    then do :
        put stream err unformatted
            "Не совпадает фактическое количество в строке накладной с количеством прочитанных марок. Артикул " buf_doc-line.artic
            ". Кол-во в накладной: " string(buf_doc-line.fact-qnty) "   Кол-во марок: " string(tt-alc-qnty.qnty)
            skip .
    end.                                  
end.

output stream err close.

if p-mode = "in"
then 
Message "Импорт завершен."
   skip "Прочитано кодов EAN13: " string(v-col-ean)
   skip "Прочитано марок: " string(v-col-marks)
   skip "Обработано кодов EAN13: " string(v-col-ean-ok)
   skip "Закачано марок: " string(v-col-marks-ok)
   skip(2) "Информация об ошибках находится в файле :" entry (1, InputFileName, ".") + ".err"
   view-as alert-box information .
   
if p-mode = "out"
then 
Message "Импорт завершен."
   skip "Прочитано кодов EAN13: " string(v-col-ean)
   skip "Прочитано марок: " string(v-col-marks)
   skip "Обработано кодов EAN13: " string(v-col-ean-ok)
   skip "Закачано марок: " string(v-col-marks-ok)
   skip(2) "Информация об ошибках находится в файле :" entry (1, InputFileName, ".") + ".err"
   skip(1) "Теперь заполните накладную. Закачанные марки будут привязаны к соответствующим партиям."
   view-as alert-box information .   
   
run gbl/prnfilen.w
    (input  "Ошибки"
    ,input  0
    ,input  entry (1, InputFileName, ".") + ".err"
    ,input  7
    ,output varuser-action
    ,output varis-printed
    ).

