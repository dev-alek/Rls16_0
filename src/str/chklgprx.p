block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: chklgprx.p $
$Archive: str/chklgprx.p $

Экспорт товарных строк списка чеков в формате EXCEL

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/08/10
Author: Bakhtadze Natalya
Creation date: 07/08/10

*/


define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chklgprx.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/chklgprx.p $":U .
define variable vss-description as character no-undo init "Экспорт товарных строк списка чеков в формате EXCEL".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-page1.i new }
{ cmp/r-pril.i new }
define variable g#report-num as integer no-undo .
{ rep/opclexcl.i }
{ gbl/prtmpldf.i }
{ gbl/waitfram.i }
{ ref/gds-attr.i }
{ ref/gdsoattr.i }
{ ref/gdshattr.i }
{ str/bc-gnrt.i new bc }
{ gbl/usr-flt.i }
{ cmp/chk-list.i chk-list def shared }

&glob chk-list_name buf-chk-list



DEFINE VARIABLE iColumn                 AS INTEGER no-undo.
DEFINE VARIABLE ii as integer no-undo.
DEFINE VARIABLE vat-value like ub.doc-line.vat-pc no-undo .
DEFINE VARIABLE slt-value like ub.doc-line.slt-pc no-undo .
define variable v-rec as recid no-undo .
define variable jj as integer no-undo .
define variable jj-1 as integer no-undo .
define variable j-n as integer no-undo .
define variable f-value as character no-undo .
define variable f-value-1 as character no-undo .
define variable f-name as character no-undo .
define variable t-name as character no-undo .
define variable f-name-1 as character no-undo .
define variable f-n as character no-undo .
define variable V-LENGTH as integer no-undo .
define variable V-NUM-CLMN as integer no-undo .
define variable v-bc-ne as integer no-undo .
define variable v-pbc-ne as integer no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-f-name like ub.gds-prt.f-name no-undo .
define variable v-osn-frm as character no-undo .
define variable v-eng-frm as character no-undo .
define variable v-curr-r-b as character no-undo .
DEFINE VARIABLE bar-code-field-handle as HANDLE no-undo .
DEFINE VARIABLE prod-bc-field-handle as HANDLE no-undo .
define variable v-frm-set as logical no-undo .
define variable ii-excel as integer no-undo .
define variable ii-page as integer no-undo init 1.
define buffer buf_custom-labels for ub.custom-labels.
define buffer buf_usr-flt_custom-labels for usr-flt_custom-labels.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_gds-prt for ub.gds-prt.
define buffer buf_gds-obj for ub.gds-obj.
define buffer buf_filter for ubflt.filter.
define buffer buf_chk-list for chk-list.
define buffer buf-chk-list-hist for chk-list-hist.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_goods for ub.goods.
define buffer buf_clients for ub.clients.
define buffer buf1_sheetf for sheetf.
define buffer buf_sheetf for sheetf.

{ gbl/hostcode.i p-curr-obj-type p-curr-obj-code v-host-code }


{ gbl/curr-r-b.i v-curr-r-b }
{ str/chkgdsfi.i  }
{ str/chkdocfi.i  }
{ str/barcodfi.i }

{ ref/gdsreffi.i goo-doc gds-list buf_chk-list.obj-type buf_chk-list.obj-code anyl-xls }

FUNCTION get-function returns character(
                                        input p-f-name as character
                                       ,input p-format as character
                                       ,input p-excel as logical
):

define variable main-b-code like ub.bar-code.b-code no-undo .
define variable bar_code as character no-undo .
define variable bar_bar_code as character no-undo .
define variable price-sale as decimal no-undo .
define variable for-road as decimal no-undo .
define variable for-excise as decimal no-undo .
define variable v-doc-num as character no-undo .
define buffer buf_bar-code for ub.bar-code.


  do
  on error undo, return error
  :
    CASE p-f-name:
      when "iColumn":U then do:
        if p-excel then do:
           return replace(string(iColumn, p-format), {&comma-char}, '').
        end.
        else do:
        return string(iColumn, p-format).
      end.
      end.
      when "price-sale":U then do:
        /*получим главный код товара*/
        find first buf_bar-code no-lock where
                  buf_bar-code.b-code = buf_chk-gds.b-code no-error.
        if not available buf_bar-code then do:
          return string({&question-mark}, p-format).
        end.
        { gbl/gdsbcode.i buf_bar-code.gds-code ? main-b-code }
        { gbl/bcodeprc.i
          buf_chk-list.obj-type
          buf_chk-list.obj-code
          buf_chk-gds.b-code
          main-b-code
          0
          v-doc-num
          price-sale
          for-road
          for-excise
          no-error
        }
        if p-excel then do:
          return replace(string(price-sale, p-format), {&comma-char}, "").
        end.
        else do:
        return string(price-sale, p-format).
      end.
      end.
      when "node-name":U then do:
        return string(v-f-name, p-format).
      end.
    END CASE.
  end.

end FUNCTION. /* get-function */


if not valid-handle(my-handle) then do:
  assign
  my-handle = parparentproc.
end.
for each buf_usr-flt_custom-labels:
  delete buf_usr-flt_custom-labels.
end.
for each  buf_custom-labels no-lock where
          buf_custom-labels.call-type = {&add-fields}
      and buf_custom-labels.call-point = {&uf-chkgdsfi}
     :
  create buf_usr-flt_custom-labels.
  buffer-copy buf_custom-labels to buf_usr-flt_custom-labels.
end.
for each  buf_custom-labels no-lock where
          buf_custom-labels.call-type = {&add-fields}
      and buf_custom-labels.call-point = {&uf-chkdocfi}
     :
  create buf_usr-flt_custom-labels.
  buffer-copy buf_custom-labels to buf_usr-flt_custom-labels.
end.
for each  buf_custom-labels no-lock where
          buf_custom-labels.call-type = {&add-fields}
      and buf_custom-labels.call-point = {&uf-gdsreffi}
     :
  create buf_usr-flt_custom-labels.
  buffer-copy buf_custom-labels to buf_usr-flt_custom-labels.
end.
for each  buf_custom-labels no-lock where
          buf_custom-labels.call-type = {&add-fields}
      and buf_custom-labels.call-point = {&uf-barcodfi}
     :
  create buf_usr-flt_custom-labels.
  buffer-copy buf_custom-labels to buf_usr-flt_custom-labels.
end.

run init-prn-template in this-procedure .
run gbl/prntput.p (c-point, output v-rec).
run gbl/prntmpl.w (
                input parparentproc
              , input "":U /*bttn*/
              , input c-point
              , input Tbl
              , input join-tbl
              , input Fld
              , input Lab
              , input Spr
              , input v-size
              , input v-format
              , input Dim
              , input-output v-rec
              , OUTPUT V-LENGTH
              , OUTPUT V-NUM-CLMN
            ).
if v-rec = ? then return.
find first ubflt.filter no-lock where
           recid(ubflt.filter) = v-rec no-error .
if not avail ubflt.filter then return.

/*перекодируем*/
do jj = 1 to num-entries(ubflt.filter.Fields-sort):
  assign
  f-name-1 = "":U
  v-frm-set = no
  .
  do jj-1 = 1 to num-entries(entry(jj, ubflt.filter.Fields-sort), "{&delim-flt}":U):
    if (entry(2, entry(jj-1, entry(jj, ubflt.filter.Fields-sort), "{&delim-flt}":U), ".") = "artic"
        or
        entry(2, entry(jj-1, entry(jj, ubflt.filter.Fields-sort), "{&delim-flt}":U), ".") = "b-str")
    and lookup(string(jj) + "=@":U, v-eng-frm) = 0
    then
    assign
    v-osn-frm = v-osn-frm + (if v-osn-frm = "":U then "":U else ";") + string(jj) + "=0":U
    v-eng-frm = v-eng-frm + (if v-eng-frm = "":U then "":U else ";") + string(jj) + "=@":U
    sheetf.colformat = v-osn-frm + {&delim-par} + v-eng-frm
    v-frm-set = yes
    .
    case entry(1, entry(jj-1, entry(jj, ubflt.filter.Fields-sort), "{&delim-flt}":U), "."):
      when "function":U then do:
        assign
        t-name = ''
        f-n = entry(jj-1, entry(jj, ubflt.filter.Fields-sort), "{&delim-flt}":U)
        .
        if entry(2, entry(jj-1, entry(jj, ubflt.filter.Fields-sort), "{&delim-flt}":U), ".") = 'gdsbcode-graphic':U
        then do:
          assign
          v-osn-frm = v-osn-frm + (if v-osn-frm = "":U then "":U else ";") + string(jj) + "=0":U
          v-eng-frm = v-eng-frm + (if v-eng-frm = "":U then "":U else ";") + string(jj) + "=@":U
          v-frm-set = yes
          .
          assign
          sheetf.colformat = v-osn-frm + {&delim-par} + v-eng-frm
          Sheetf.Bas-File = "exe/anyl-xls.bas"
          Sheetf.Bas-Params = Sheetf.Bas-Params +
                              (if Sheetf.Bas-Params = '':U
                               then '':U
                               else {&delim-par}) + string(jj) /*номер колонки в которой лежит баркод для графики*/
          .
        end.
      end.
      otherwise do:
        assign
        f-n = entry(2, entry(jj-1, entry(jj, ubflt.filter.Fields-sort), "{&delim-flt}":U), ".")
        t-name = entry(1, entry(jj-1, entry(jj, ubflt.filter.Fields-sort), "{&delim-flt}":U), ".")
        .
      end.
    END CASE.
    assign
    f-name-1 = f-name-1 + (if f-name-1 = "":U then "":U else "{&delim-flt}":U) + (if t-name <> '':U then (t-name + ".") else '') + f-n
    .
    if v-frm-set = no then do:
      assign
      v-osn-frm = v-osn-frm + (if v-osn-frm = "":U then "":U else ";") + string(jj) + "=" +
                  prnfield_get-fformat(entry(jj, ubflt.filter.lst-cend)
                             ,entry(jj, ubflt.filter.where-ysl-rus, {&delim-par}))
      .
    end.
  end. /*jj-1*/
  assign
  f-name = f-name + (if f-name = "":U then "":U else {&comma-char}) + f-name-1
  .

end. /* jj */
assign
sheetf.colformat = v-osn-frm + {&delim-par} + v-eng-frm
.
assign
j-n = num-entries(f-name)
.
Sheetf.Bas-Params = string(5) + {&delim-par} + Sheetf.Bas-Params.
Make-excel = yes.
run get-report-num  in parParentProc(output g#report-num).
find first buf1_sheetf no-lock where
          buf1_sheetf.sheet-num = 1 or buf1_sheetf.sheet-num = 0.

&scop   page-excel-block  if ii-excel > 32000 then do:                                    ~
                           {&pageExcel}                                               ~
                           find first buf_sheetf where                                ~
                                     buf_sheetf.sheet-num = ii-page + 1 no-error.     ~
                           if not available buf_sheetf then do:                       ~
                             create buf_sheetf.                                       ~
                           end.                                                       ~
                           buffer-copy buf1_sheetf except sheet-num                   ~
                           to buf_sheetf                                              ~
                           assign                                                     ~
                           buf_sheetf.sheet-num = ii-page + 1                         ~
                           .                                                          ~
                           run rep/extitle.p (ii-page) .                                   ~
                           assign                                                     ~
                           ii-page = ii-page + 1                                      ~
                           ii-excel = 0                                               ~
                           .                                                          ~
                         end



if Make-Excel then
RUN OpenForExcel in this-procedure .


FOR EACH sheetf where sheetf.sheet-num > 1:
  delete sheetf.
end.

FIND FIRST sheetf where
           sheetf.sheet-num = 1 No-ERROR.


assign
ReportName = "Список товарных строк чека"
str1 = ''
sheetf.Excel-Column-Lable = ubflt.filter.Fields-sort-rus
sheetf.sizes = ubflt.filter.Where-ysl
.

run waitfram-show in this-procedure ("Экспорт в EXCEL. Ждите ...").
run rep/extitle.p (1).


iColumn = 0.  /* Начинаем писать со второй строки, 1-я - заголовок */
FOR EACH buf_chk-list No-LOCK,
    each buf_chk-gds no-lock where
        buf_chk-gds.doc-code = buf_chk-list.doc-code
BREAK
BY buf_chk-list.doc-code :
  if first-of(buf_chk-list.doc-code) then do:
    {&page-excel-block}.
  end.
  find first buf_chk-doc no-lock where
            buf_chk-doc.doc-code = buf_chk-list.doc-code no-error.
  FIND FIRST buf_bar-code No-LOCK WHERE
              buf_bar-code.b-code = buf_chk-gds.b-code NO-ERROR.
  IF AVAIL buf_bar-code then do:
    FIND FIRST buf_goods NO-LOCK WHERE
                buf_goods.gds-code = buf_bar-code.gds-code NO-ERROR.

    FIND FIRST  buf_clients NO-LOCK WHERE
                buf_clients.obj-type = buf_goods.prod-type AND
                buf_clients.obj-code = buf_goods.prod-code NO-ERROR.
    FIND FIRST buf_gds-prt No-LOCK where
                buf_gds-prt.upper-code = buf_goods.prt-root NO-ERROR.
    if available buf_gds-prt then do:
      assign
      v-f-name = buf_gds-prt.f-name.
    end.
    else do:
      v-f-name = "!!!Неизвестная шкала".
    end.
    find first buf_gds-obj no-lock where
              buf_gds-obj.gds-code = buf_goods.gds-code
         and buf_gds-obj.obj-type = buf_chk-list.obj-type
         and buf_gds-obj.obj-code = buf_chk-list.obj-code no-error .
  end.
  else do:
    assign
    v-bc-ne = v-bc-ne + 1.
    release buf_goods.
    release buf_clients.
    release buf_gds-prt.
  end.
  if (iColumn modulo 10) = 0 then
    run waitfram-show in this-procedure ("Экспортировано в EXCEL строк : " + string (iColumn)).
  assign
  iColumn = iColumn + 1
  v-osn-frm = "":U
  v-eng-frm = "":U
 .
  define variable v-dop0 as character no-undo .
  define variable v-dop1 as character no-undo .
  define variable v-dop2 as character no-undo .
  do jj = 1 to j-n:
    assign
    f-value = "":U
    v-dop0 = entry(jj, f-name)
    v-dop1 = entry(1, v-dop0, ".")
    v-dop2 = entry(2, v-dop0, ".")
    .
    CASE  v-dop1:
      when "function":U then do:
         ii-excel = ii-excel + 1.
        {&PutExcel}
        get-function( input substr(v-dop0 ,10 )
                     ,input entry(jj, ubflt.filter.Where-ysl-rus, {&delim-par})
                     ,input yes /*p-excel*/
                     )
        (if jj < j-n
        then
        {&tabulation}
        else {&new-line})
        .
      end.
      when {&table_bar-code} then do:
        if index(v-dop0, "{&delim-flt}":U) > 0 then do:
          do jj-1 = 1 to num-entries(v-dop0, "{&delim-flt}":U):
            assign
            f-value-1 = "":U.
            run barcodfi in this-procedure (
                             buffer buf_bar-code
                            ,INPUT entry(jj-1, v-dop0, "{&delim-flt}":U)
                            ,input yes /*p-excel*/
                            ,INPUT-OUTPUT f-value-1
                            )  NO-ERROR .
            assign
            f-value = f-value + (if f-value = "":U then "":U else {&space-char}) + f-value-1
            .
          end.
        end. /*if index(v-dop0, "{&delim-flt}":U) > 0 then do:*/
        else do:
          run barcodfi in this-procedure (
                           buffer buf_bar-code
                          ,INPUT entry(jj, f-name)
                          ,input yes /*p-excel*/
                          ,INPUT-OUTPUT f-value
                          )  NO-ERROR .
        end. /*else if index(v-dop0, "{&delim-flt}":U) > 0 then do:*/
        ii-excel = ii-excel + 1.
        {&PutExcel}
        string(f-value, substitute("X(&1)", entry(jj, ubflt.filter.Where-ysl)))
        (if jj < j-n
        then
        {&tabulation}
        else {&new-line})
        .
      end.
      when {&table_chk-doc} then do:
        if index(v-dop0, "{&delim-flt}":U) > 0 then do:
          do jj-1 = 1 to num-entries(v-dop0, "{&delim-flt}":U):
            assign
            f-value-1 = "":U.
            run chkdocfi in this-procedure (
                             buffer buf_chk-doc
                            ,INPUT entry(jj-1, v-dop0, "{&delim-flt}":U)
                            ,input yes /*p-excel*/
                            ,INPUT-OUTPUT f-value-1
                            )  NO-ERROR .
            assign
            f-value = f-value + (if f-value = "":U then "":U else {&space-char}) + f-value-1
            .
          end.
        end. /*if index(v-dop0, "{&delim-flt}":U) > 0 then do:*/
        else do:
          run chkdocfi in this-procedure (
                           buffer buf_chk-doc
                          ,INPUT entry(jj, f-name)
                          ,input yes /*p-excel*/
                          ,INPUT-OUTPUT f-value
                          )  NO-ERROR .
        end. /*else if index(v-dop0, "{&delim-flt}":U) > 0 then do:*/
         ii-excel = ii-excel + 1.
        {&PutExcel}
        string(f-value, substitute("X(&1)", entry(jj, ubflt.filter.Where-ysl)))
        (if jj < j-n
        then
        {&tabulation}
        else {&new-line})
        .
      end.
      when {&table_goods} then do:
        if index(v-dop0, "{&delim-flt}":U) > 0 then do:
          do jj-1 = 1 to num-entries(v-dop0, "{&delim-flt}":U):
            assign
            f-value-1 = "":U.
            run gds-ref-fi in this-procedure (
                             buffer buf_goods
                            ,buffer buf_gds-obj
                            ,input buf_chk-list.obj-type
                            ,input buf_chk-list.obj-code
                            ,INPUT entry(jj-1, entry(jj, f-name), "{&delim-flt}":U)
                            ,input yes /*p-excel*/
                            ,INPUT-OUTPUT f-value-1
                            )  NO-ERROR .
            assign
            f-value = f-value + (if f-value = "":U then "":U else {&space-char}) + f-value-1
            .
          end.
        end. /*if index(v-dop0, "{&delim-flt}":U) > 0 then do:*/
        else do:
          run gds-ref-fi in this-procedure (
                           buffer buf_goods
                          ,buffer buf_gds-obj
                          ,input buf_chk-list.obj-type
                          ,input buf_chk-list.obj-code
                          ,INPUT v-dop0
                          ,input yes /*p-excel*/
                          ,INPUT-OUTPUT f-value
                          )  NO-ERROR .
        end. /*else if index(v-dop0, "{&delim-flt}":U) > 0 then do:*/
        ii-excel = ii-excel + 1.
        {&PutExcel}
        if v-dop0 = "artic" then {&delim-par} else "":U
        string(f-value, substitute("X(&1)", entry(jj, ubflt.filter.Where-ysl)))
        (if jj < j-n
        then
        {&tabulation}
        else {&new-line})
        .
      end. /*      when goods */
      otherwise do: /*chk-gds6*/
        if index(v-dop0, "{&delim-flt}":U) > 0 then do:
          do jj-1 = 1 to num-entries(v-dop0, "{&delim-flt}":U):
            assign
            f-value-1 = "":U.
            run chkgdsfi in this-procedure (
                            buffer buf_chk-gds
                            ,INPUT entry(jj-1, v-dop0, "{&delim-flt}":U)
                            ,input yes /*p-excel*/
                            ,INPUT-OUTPUT f-value-1
                            )  NO-ERROR .
            assign
            f-value = f-value + (if f-value = "":U then "":U else {&space-char}) + f-value-1
            .
          end.
        end. /*if index(v-dop0, "{&delim-flt}":U) > 0 then do:*/
        else do:
          run chkgdsfi in this-procedure (
                           buffer buf_chk-gds
                          ,INPUT entry(jj, f-name)
                          ,input yes /*p-excel*/
                          ,INPUT-OUTPUT f-value
                          )  NO-ERROR .
        end. /*else if index(v-dop0, "{&delim-flt}":U) > 0 then do:*/
        ii-excel = ii-excel + 1.
        {&PutExcel}
        if v-dop0 = "artic" then {&delim-par} else "":U
        string(f-value, substitute("X(&1)", entry(jj, ubflt.filter.Where-ysl)))
        (if jj < j-n
        then
        {&tabulation}
        else {&new-line})
        .
      end. /*otherwise do:*/
    END CASE.
  end. /*do jj = 1 to j-n:*/
END.

{&pageExcel}

find first buf_sheetf where
          buf_sheetf.sheet-num = ii-page + 1 no-error.
if not available buf_sheetf then do:
  create buf_sheetf.
  assign
  buf_sheetf.sheet-num = ii-page + 1
  buf_sheetf.Excel-Column-Lable =  "№ п/п,Действие,Записей,итого,Множество"
  buf_sheetf.sizes = "9,9,9,12,155"
  .
  release buf_sheetf.                                     ~
end.
assign
ii-page = ii-page + 1
ii-excel = 0
.
run rep/extitle.p ( input ii-page) .
run waitfram-show in this-procedure ("Экспорт в EXCEL истории").
for each buf-chk-list-hist:
  {&PutExcel}
  (if buf-chk-list-hist.line = 0
   then string(buf-chk-list-hist.id, ">>>>>>>>9")
   else '':U)
  {&tabulation}
  (if buf-chk-list-hist.item_ <> '':U
   then buf-chk-list-hist.hist-mode
   else '':U)  {&tabulation}
   (if buf-chk-list-hist.item_ <> '':U
   then string(buf-chk-list-hist.num-add, "->>>>>>>>9")
   else '':U)  {&tabulation}
  (if buf-chk-list-hist.item_ <> '':U
  then string(buf-chk-list-hist.num-recs, ">>>>>>>>9")
  else '':U)  {&tabulation}
  buf-chk-list-hist.des
  skip.
end.
run waitfram-hide in this-procedure .

{&CloseExcel}
run waitfram-hide in this-procedure .
/*непосредственно открытие Excel*/
if Make-Excel then do:
   run rep/runexcel.p (
                   string( session:temp-directory +
                         {&DF_Name} +
                         string( g#report-num ) + ".txt":U )
                 ) .
end.

if Make-Excel then
RUN CLoseForExcel in this-procedure .

procedure init-prn-template :
define variable na                   as integer            no-undo .
DEFINE VARIABLE vtooltip             as character           no-undo.
DEFINE VARIABLE vlabel               as character           no-undo .
DEFINE VARIABLE vtype                as character           no-undo .
DEFINE VARIABLE vformat              as character           no-undo .
DEFINE VARIABLE vuser-can-edit       as character           no-undo .
DEFINE VARIABLE voutput-display      as character           no-undo .
DEFINE VARIABLE vother               as character           no-undo .


  do
  on error undo, return error
  :
    assign
    join-tbl = 'Строка чека,Чек,Товар,Баркод,Другое'
    tbl = {&table_chk-gds} + {&comma-char} +
          {&table_chk-doc} + {&comma-char} +
          {&table_goods} + {&comma-char} +
          {&table_bar-code} + {&comma-char} +
          "function"
    c-point =  "chklgprx" + {&delim-par} +  "PRNT":u  + {&delim-par} + "Товарные строки списка чеков"
    fld = ""
    lab = ""
    spr = ""
    dim = '0'
    v-size = "":U
    v-format = "":U
    .
   for each buf_usr-flt_custom-labels where
           buf_usr-flt_custom-labels.call-type = {&add-fields}
       and buf_usr-flt_custom-labels.call-point = {&uf-chkgdsfi}
       and buf_usr-flt_custom-labels.tbl-name = {&table_chk-gds}
   by buf_usr-flt_custom-labels.custom-label
       :

      run prnfield-add in this-procedure(input buf_usr-flt_custom-labels.fld-name
                                        ,input buf_usr-flt_custom-labels.custom-label
                                        ,input (if buf_usr-flt_custom-labels.custom-view-func <> ''
                                                then substitute("attr.&1", buf_usr-flt_custom-labels.fld-data-type)
                                                else '')
                                        ,input integer(buf_usr-flt_custom-labels.widget-width)
                                        ,input buf_usr-flt_custom-labels.custom-format
                                        ,input-output fld
                                        ,input-output lab
                                        ,input-output spr
                                        ,input-output v-size
                                        ,input-output v-format
                                        ,input-output dim)  no-error.
    end.
    assign
    fld = fld
    lab = lab
    dim = dim + {&comma-char}
    .
    for each buf_usr-flt_custom-labels where
           buf_usr-flt_custom-labels.call-type = {&add-fields}
       and buf_usr-flt_custom-labels.call-point = {&uf-chkdocfi}
       and buf_usr-flt_custom-labels.tbl-name = {&table_chk-doc}
    by buf_usr-flt_custom-labels.custom-label
       :

      run prnfield-add in this-procedure(input buf_usr-flt_custom-labels.fld-name
                                        ,input buf_usr-flt_custom-labels.custom-label
                                        ,input (if buf_usr-flt_custom-labels.custom-view-func <> ''
                                                then substitute("attr.&1", buf_usr-flt_custom-labels.fld-data-type)
                                                else '')
                                        ,input integer(buf_usr-flt_custom-labels.widget-width)
                                        ,input buf_usr-flt_custom-labels.custom-format
                                        ,input-output fld
                                        ,input-output lab
                                        ,input-output spr
                                        ,input-output v-size
                                        ,input-output v-format
                                        ,input-output dim)  no-error.
    end.
    assign
    fld = fld
    lab = lab
    dim = dim + {&comma-char}
    .
    for each buf_usr-flt_custom-labels where
           buf_usr-flt_custom-labels.call-type = {&add-fields}
       and buf_usr-flt_custom-labels.call-point = {&uf-gdsreffi}
       and buf_usr-flt_custom-labels.tbl-name = {&table_goods}
    by buf_usr-flt_custom-labels.custom-label
       :

      run prnfield-add in this-procedure(input buf_usr-flt_custom-labels.fld-name
                                        ,input buf_usr-flt_custom-labels.custom-label
                                        ,input (if buf_usr-flt_custom-labels.custom-view-func <> ''
                                                then substitute("attr.&1", buf_usr-flt_custom-labels.fld-data-type)
                                                else '')
                                        ,input integer(buf_usr-flt_custom-labels.widget-width)
                                        ,input buf_usr-flt_custom-labels.custom-format
                                        ,input-output fld
                                        ,input-output lab
                                        ,input-output spr
                                        ,input-output v-size
                                        ,input-output v-format
                                        ,input-output dim)  no-error.
    end.
    assign
    fld = fld
    lab = lab
    dim = dim + {&comma-char}
    .
    for each buf_usr-flt_custom-labels where
           buf_usr-flt_custom-labels.call-type = {&add-fields}
       and buf_usr-flt_custom-labels.call-point = {&uf-barcodfi}
       and buf_usr-flt_custom-labels.tbl-name = {&table_bar-code}
    by buf_usr-flt_custom-labels.custom-label
       :

      run prnfield-add in this-procedure(input buf_usr-flt_custom-labels.fld-name
                                        ,input buf_usr-flt_custom-labels.custom-label
                                        ,input (if buf_usr-flt_custom-labels.custom-view-func <> ''
                                                then substitute("attr.&1", buf_usr-flt_custom-labels.fld-data-type)
                                                else '')
                                        ,input integer(buf_usr-flt_custom-labels.widget-width)
                                        ,input buf_usr-flt_custom-labels.custom-format
                                        ,input-output fld
                                        ,input-output lab
                                        ,input-output spr
                                        ,input-output v-size
                                        ,input-output v-format
                                        ,input-output dim)  no-error.
    end.
    assign
    fld = fld
    lab = lab
    dim = dim + {&comma-char}
    .
    run prnfield-add in this-procedure('iColumn', '№', 'function.integer', 7, ">>>>>>9":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-format, input-output dim)  no-error.
    /*
    run prnfield-add in this-procedure('price-sale', 'Цена', 'function.decimal', 6, ">>>,>>9.99":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-format, input-output dim)  no-error.
    */

  end.

end procedure. /* init-prn-template */