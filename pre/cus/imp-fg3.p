block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input  parameter file-name as char no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: imp-fg3.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/imp-fg3.p $":U .
define variable vss-description as character no-undo init "Импорт в ДНЦ  ".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define buffer buf_goods for ub.goods .
define stream imp.
define stream err.
define variable text-string        as    char no-undo .
define variable i-doc-num       like   price-doc-forming.pdf-id no-undo .
DEF VAR loc-ref-list      as    char no-undo .
define variable i-price         like doc-line.price-cli     no-undo.
define variable i-d-pcnt        like price-doc-forming-gds.d-pcnt      no-undo.
DEF var impc as integer No-UNDO.
DEF var imp-save as integer No-UNDO.
DEF var i-artic as char no-undo.
DEF var i-prod-code like goods.prod-code no-undo.
DEFINE VAR  N-param AS DEC NO-UNDO.
DEF VAR i-t1 AS CHAR NO-UNDO.
DEF VAR i-t2 AS CHAR NO-UNDO.
DEF VAR i-t3 AS CHAR NO-UNDO.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
run str/pdfnew.w ( input parParentProc
                  , 'all'
                   , v-cntxt-obj-type
                   , v-cntxt-obj-code
                   ,  ?
                   ,?
                   ,"b-sel":U
                   ,input-output loc-ref-list).
if loc-ref-list  = '':U
or loc-ref-list  = ?
then do:
  message "Документ назначения цены не выбран."
          view-as alert-box error.
  return error.
end.
find price-doc-forming where recid (price-doc-forming) = integer(entry(1, loc-ref-list)) no-error .
if not available price-doc-forming then do:
  message
  substitute("ДНЦ с recid &1 не найден", integer(entry(1, loc-ref-list)))
  view-as alert-box .
  return .
end.
if price-doc-forming.stts <> 0 then do:
      message "Статус ДНЦ должен быть 'новый'."
              view-as alert-box error.
      return error.
end.
i-doc-num = price-doc-forming.pdf-id.
input stream imp from value (file-name) .
repeat:
      text-string = "".
      IMPORT stream imp UNFORMATTED text-string NO-ERROR.
      if trim(text-string) = "" then leave.
      impc = impc + 1.
      if num-entries (text-string, ";") <> 24 then do:
        N-param = num-entries (text-string, ";").
        OUTPUT stream Err TO value ("Imp_Price.err") append.
           put stream Err unformatted
             string(today, "99/99/9999") " "
             string(time, "HH:MM")
             " Неправильное число параметров в строке, должно быть 22, а у вас " N-param skip.
           export stream  Err text-string .
        output stream Err close.
        next.
      end.
      IF trim(ENTRY( 9, text-string, ";")) = "Article name" THEN NEXT.
      assign
            i-artic = trim(ENTRY( 9, text-string, ";") + "-" + ENTRY( 10, text-string, ";"))
            i-prod-code = dec(ENTRY( 22, text-string, ";")).
      i-t1 = ENTRY( 20, text-string, ";").
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
      ASSIGN i-price = dec(i-t1).
      display
                 impc  label "Прочитано"
                 imp-save label "Сохранено"
                 i-artic format "x(10)" label "Артикул"
                 text-string format "x(40)" label "Строка файла"
         with frame ff view-as dialog-box
      title ": Импорт справочника товаров из файла".
      pause 0.
      find first goods where
        goods.prod-type = "орг" and
        goods.prod-code = i-prod-code and
        goods.artic = i-artic
      no-lock no-error.
      if not avail goods then do:
           OUTPUT stream Err TO value ("Imp_Price.err") append.
              put stream Err unformatted
                string(today, "99/99/9999") " "
                string(time, "HH:MM")
                " Товар не найден в справочнике товаров, см. строку " impc skip.
              export stream  Err text-string .
           output stream Err close.
           next.
      end.
      find first bar-code where bar-code.gds-code = goods.gds-code no-lock no-error.
      if not avail bar-code then do:
           OUTPUT stream Err TO value ("Imp_Price.err") append.
              put stream Err unformatted
                string(today, "99/99/9999") " "
                string(time, "HH:MM")
                " У товара нет собственного Бар-Кода, см. строку " impc skip.
              export stream  Err text-string .
           output stream Err close.
           next.
      end.
      if i-price <= 0 or i-price = ? then do:
           OUTPUT stream Err TO value ("Imp_Price.err") append.
              put stream Err unformatted
                string(today, "99/99/9999") " "
                string(time, "HH:MM")
                " У товара нет цены, см. строку " impc skip.
              export stream  Err text-string .
           output stream Err close.
           next.
      end.
      find price-doc-forming-gds where
          price-doc-forming-gds.pdf-id    = i-doc-num         and
          price-doc-forming-gds.b-code     = bar-code.b-code no-error.
      if available price-doc-forming-gds then do:
              next.
      end.
      else do:
        create price-doc-forming-gds.
        assign
          price-doc-forming-gds.pdf-id     = i-doc-num
          price-doc-forming-gds.b-code      = bar-code.b-code
          price-doc-forming-gds.artic       = goods.artic
          price-doc-forming-gds.prod-type   = goods.prod-type
          price-doc-forming-gds.prod-code   = goods.prod-code
          price-doc-forming-gds.calc-method = 'Отсутствует':U
          imp-save               = imp-save + 1
price-doc-forming-gds.plt-db-num   =    price-doc-forming.plt-db-num
price-doc-forming-gds.plt-id    =     price-doc-forming.plt-id
        .
      end.
      assign
        price-doc-forming-gds.price-sale-doc = i-price
        price-doc-forming-gds.price-sale-rubl = i-price
        price-doc-forming-gds.price-sale-base = i-price
        price-doc-forming-gds.d-pcnt     = i-d-pcnt
      .
end.
input stream imp close.
message ("Импорт из файла " + file-name + " закончен, прочитано " + string(impc) +
         ",  создано строк в ДНЦ " + string(imp-save) ) skip
         "Все строки из файла которые не удалось импортировать можно посмотреть в файле Imp_Price.err "
view-as alert-box  INFORMATION.
