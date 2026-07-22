block-level on error undo, throw.
using ibs.th.bge.egais.*.
define temp-table tt-marks
    field exciseMark   as character label "Марка"    format "X(150)"
    field alc-code     as character label "Алк. код" format "X(20)"
    field artic        as character label "Артикл"   format "X(20)"
    field prod-type    as character
    field prod-code    as integer
    field gds-code     as integer
    field doc-code     as character
    field partID       as character
    field refB         as character
    field rowid-part   as rowid
    field line-num     as integer
    field isCurr       as logical
    index pi as primary unique
        exciseMark
.
define temp-table tt-alc-qnty
    field artic        as character label "Артикл"   format "X(20)"
    field prod-type    as character
    field prod-code    as integer
    field gds-code     as integer
    field alc-code     as character label "Алк. код" format "X(20)"
    field qnty         as integer   label "Кол."
    field isCurr       as logical
    index pi as primary unique
        artic prod-type prod-code alc-code
.
define output parameter table for tt-marks .
define output parameter table for tt-alc-qnty .
define input parameter pardoc-code      like ub.trn-doc.doc-code  no-undo.
define variable vss-revision    as character no-undo init "$Revision: ac3ee8e28890, 1428, test $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Fri Jun 29 18:00:05 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: imp-marks-temp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/imp-marks-temp.p $":U .
define variable vss-description as character no-undo init "Импорт акцизных марок из файла во временную таблицу.".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION Base2Int64 RETURNS INT64 ( INPUT i-hex AS CHARACTER, INPUT i-base AS INTEGER ) :
  DEFINE VARIABLE j_num AS INT64 NO-UNDO.
  RUN conv-base-to-int64 IN THIS-PROCEDURE ( INPUT i-hex, INPUT i-base, OUTPUT j_num ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE j_num ).
END FUNCTION.
PROCEDURE conv-base-to-int64 :
  DEFINE  INPUT PARAMETER p-num  AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-base AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-int  AS INT64     NO-UNDO.
  DEFINE VARIABLE v_list AS CHARACTER NO-UNDO INITIAL '':U.
  DEFINE VARIABLE jj     AS INTEGER   NO-UNDO.
  DEFINE VARIABLE j_sign AS INT64   NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    IF p-base > 60 THEN DO:
      ASSIGN p-int = ?.
      UNDO, RETURN ERROR.
    END.
    ASSIGN v_list = '0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,':U +
                    'Б,Г,Д,Ё,Ж,З,И,Й,Л,П,У,Ф,Ц,Ч,Ш,Щ,Ъ,Ы,Ь,Э,Ю,Я,@,$':U
           v_list = SUBSTRING( v_list, 1, p-base * 2 - 1 )
           p-num  = TRIM( p-num ).
    IF SUBSTRING( p-num, 1, 1 ) = "-" THEN DO:
        ASSIGN j_sign = -1
               p-num  = SUBSTRING( p-num, 2 ).
    END.                              ELSE DO: ASSIGN j_sign = 1. END.
    DO jj = 1 TO LENGTH( p-num ) :
      ASSIGN p-int = p-int * p-base + LOOKUP( SUBSTRING( p-num, jj, 1 ), v_list ) - 1.
    END.
    ASSIGN p-int = j_sign * p-int.
  END.
END PROCEDURE.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE ProcAlcCode :
  define input  parameter p-mark-alc as character  no-undo .
  define output parameter p-alc-code as character  no-undo initial ''.
  define output parameter p-error as logical no-undo initial no.
  define output parameter p-error-lang as logical no-undo initial no.
  define variable v-kol              as integer    no-undo .
  define variable v-alc-code as character no-undo .
  define variable v-result as character no-undo .
  define variable ii as integer no-undo .
  DEFINE VARIABLE v_list AS CHARACTER NO-UNDO INITIAL '':U.
  ASSIGN
    v_list = '0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,':U .
  v-alc-code = SUBSTRing (p-mark-alc, 8, 12) .
  do ii = 1 to length (v-alc-code):
    if LOOKUP( SUBSTRING( v-alc-code, ii, 1 ), v_list )  < 1 then
    do:
      p-error-lang = yes .
      leave .
    end.
  end.
  p-alc-code = string (Base2Int64 (v-alc-code, 36) ) no-error.
  if (Base2Int64 (v-alc-code, 36) ) < 0 then
  do:
    p-error = yes.
  end.
  else
  do:
    if length(p-alc-code) < 20 then
    do:
      p-alc-code = fill('0', 19 - length(p-alc-code)) + p-alc-code.
    end.
  end.
END PROCEDURE.
PROCEDURE ProcFindGds  :
  define input  parameter p-alc-code as character  no-undo .
  define output parameter p-gds-code as integer    no-undo .
  define buffer x_ext-classif        for ub.ext-classif .
      find first X_ext-classif no-lock where X_ext-classif.classif-subject = 'goods':U
                                               and X_ext-classif.classif-name = 'exp-esys-gds-code':U
                                               AND X_ext-classif.db-num = 0
                                               and X_ext-classif.CharKey_One = p-alc-code
                                               no-error.
      if available x_ext-classif then p-gds-code = X_ext-classif.Key#_One.
END PROCEDURE.
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
define variable l-error         as logical   no-undo.
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
