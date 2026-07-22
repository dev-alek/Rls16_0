block-level on error undo, throw.
define input  parameter file-name as char no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: imp-fg4.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/imp-fg4.p $":U .
define variable vss-description as character no-undo init "Экспорт в файл для последующей закачки из него в приходный документ ".
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
define buffer buf_goods for ub.goods .
define stream txt-temp.
define stream imp.
define stream err.
define variable text-string        as    char no-undo .
define variable glog as logical no-undo .
define variable f-name     as character no-undo .
DEF VAR loc-ref-list      as    char no-undo .
define variable i-price         like doc-line.price-cli     no-undo.
DEF var impc as integer No-UNDO.
DEF var imp-save as integer No-UNDO.
DEF var i-qnty AS DEC NO-UNDO.
DEF var i-scale as char no-undo.
DEF var i-prod-bc as char no-undo.
DEF var i-artic as char no-undo.
DEF var i-prod-code like goods.prod-code  no-undo.
DEFINE VAR  N-param AS DEC NO-UNDO.
DEF var i-t1 as char no-undo.
DEF var i-t2 as char no-undo.
DEF var i-t3 as char no-undo.
system-dialog get-file f-name
    TITLE "Экспорт в файл для последующей загрузки в приходный документ"
  filters "Файл для экспорта (*.adb) " "*.adb"
  ask-overwrite
  save-as
  use-filename
  update glog
  default-extension "adb".
if not glog then return.
if trim(f-name) = "" then do:
     message "Не задан файл для экспорта". pause.
     return.
end.
input stream imp from value (file-name) .
repeat:
      text-string = "".
      IMPORT stream imp UNFORMATTED text-string NO-ERROR.
      if trim(text-string) = "" then leave.
      impc = impc + 1.
      if num-entries (text-string, ";") <> 24 then do:
        N-param = num-entries (text-string, ";").
        OUTPUT stream Err TO value ("Imp_Doc.err") append.
           put stream Err unformatted
             string(today, "99/99/9999") " "
             string(time, "HH:MM")
             " Неправильное число параметров в строке, должно быть 22, а у вас " N-param skip.
           export stream  Err text-string .
        output stream Err close.
        next.
      end.
      IF trim(ENTRY( 9, text-string, ";")) = "Article name" THEN NEXT.
      display
                 impc  label "Прочитано"
                 imp-save label "Сохранено"
                 i-artic format "x(10)" label "Артикул"
                 text-string format "x(40)" label "Строка файла"
         with frame ff view-as dialog-box
      title ": Импорт справочника товаров из файла".
      pause 0.
      IF trim(ENTRY( 9, text-string, ";")) = "" THEN DO:
           OUTPUT stream Err TO value ("Imp_Doc.err") append.
              put stream Err unformatted
                string(today, "99/99/9999") " "
                string(time, "HH:MM")
                " Не задан артикул товара, см. строку " impc skip.
              export stream  Err text-string .
           output stream Err close.
           next.
      end.
      i-t1 = ENTRY( 17, text-string, ";").
      REPEAT:
         IF INDEX(i-t1, " ") = 0 THEN LEAVE.
         i-t2 = SUBSTRING ( i-t1, 1 , INDEX(i-t1, " ") - 1).
         i-t3 = SUBSTRING ( i-t1, INDEX(i-t1, " ") + 1).
         i-t1 = i-t2 + i-t3.
      END.
      IF INDEX(i-t1, ",") <> 0 THEN DO:
        ASSIGN
          i-t2 = SUBSTRING ( i-t1, 1 , INDEX(i-t1, ",") - 1).
          i-t3 = SUBSTRING ( i-t1, INDEX(i-t1, ",") + 1).
          i-t1 = i-t2 + "." + i-t3.
      END.
      i-price = dec(i-t1).
      i-t1  = ENTRY( 18, text-string, ";").
      REPEAT:
         IF INDEX(i-t1, " ") = 0 THEN LEAVE.
         i-t2 = SUBSTRING ( i-t1, 1 , INDEX(i-t1, " ") - 1).
         i-t3 = SUBSTRING ( i-t1, INDEX(i-t1, " ") + 1).
         i-t1 = i-t2 + i-t3.
      END.
      IF INDEX(i-t1, ",") <> 0 THEN DO:
        ASSIGN
          i-t2 = SUBSTRING ( i-t1, 1 , INDEX(i-t1, ",") - 1).
          i-t3 = SUBSTRING ( i-t1, INDEX(i-t1, ",") + 1).
          i-t1 = i-t2 + "." + i-t3.
      END.
      i-qnty = dec(i-t1).
      assign
            i-artic = trim(ENTRY( 9, text-string, ";") + "-" + ENTRY( 10, text-string, ";"))
            i-prod-code = dec(ENTRY( 22, text-string, ";"))
            i-scale = ENTRY( 11, text-string, ";") + "/" + ENTRY( 13, text-string, ";")
            i-prod-bc = ENTRY( 19, text-string, ";")
      .
      DISP i-artic i-prod-bc i-price i-qnty (i-price / i-qnty). PAUSE.
      ASSIGN i-price = i-price / i-qnty.
      find first goods where
        goods.prod-type = "орг" and
        goods.prod-code = i-prod-code and
        goods.artic     = i-artic
      no-lock no-error.
      if not avail goods then do:
           OUTPUT stream Err TO value ("Imp_Doc.err") append.
              put stream Err unformatted
                string(today, "99/99/9999") " "
                string(time, "HH:MM")
                " Товар не найден в справочнике товаров, см. строку " impc skip.
              export stream  Err text-string .
           output stream Err close.
           next.
      end.
      if i-price <= 0 or i-price = ? then do:
           OUTPUT stream Err TO value ("Imp_Doc.err") append.
              put stream Err unformatted
                string(today, "99/99/9999") " "
                string(time, "HH:MM")
                " У товара нет цены, см. строку " impc skip.
              export stream  Err text-string .
           output stream Err close.
           next.
      end.
      OUTPUT stream txt-temp TO value (f-name) append.
      put stream txt-temp  unformatted
                  "SCALE:" +
                  trim(i-artic) + ";" + string(i-prod-code) + ";" +
                  trim(i-scale) + ";;" +
                  trim(i-prod-bc) + ";" +
                  trim(string(i-price)) + ";" +
                  trim(string(i-qnty)) + ";;;;;;;;;"
      skip.
      output stream txt-temp close.
      imp-save = imp-save + 1.
end.
input stream imp close.
message ("Экспорт из файла " + file-name + " закончен, прочитано " + string(impc) +
         ",  сохранено в файле " + string(imp-save)  + "строк" ) skip
         "Все строки из файла которые не удалось импортировать можно посмотреть в файле Imp_Doc.err "
view-as alert-box  INFORMATION.
