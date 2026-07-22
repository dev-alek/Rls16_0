block-level on error undo, throw.
/*

$Revision: eb58aa57459c, 2002, rls $
$Author: EShklyar $
$Date: Wed Sep 18 21:01:08 2019 +0300 $
$Workfile: chkl-prx.p $
$Archive: str/chkl-prx.p $

Экспорт шапок чеков в формате EXCEL

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/08/10
Author: Bakhtadze Natalya
Creation date: 07/08/10

*/


define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .

define variable vss-revision    as character no-undo init "$Revision: eb58aa57459c, 2002, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Wed Sep 18 21:01:08 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chkl-prx.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/chkl-prx.p $":U .
define variable vss-description as character no-undo init "Экспорт шапок чеков в формате EXCEL".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-page1.i new }
{ cmp/r-pril.i new }
define variable g#report-num as integer no-undo .
{ rep/opclexcl.i }
{ gbl/prtmpldf.i }
{ gbl/waitfram.i }
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
define buffer buf2_usr-flt_custom-labels for usr-flt_custom-labels.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_filter for ubflt.filter.
define buffer buf_chk-list for chk-list.
define buffer buf-chk-list-hist for chk-list-hist.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_goods for ub.goods.
define buffer buf_clients for ub.clients.
define buffer buf1_sheetf for sheetf.
define buffer buf_sheetf for sheetf.
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
define variable par-l-mask  as logical no-undo .
define variable v-param-type as character no-undo .

{ gbl/hostcode.i p-curr-obj-type p-curr-obj-code v-host-code }

{ gbl/thbj-def.i }
{ gbl/curr-r-b.i v-curr-r-b }
{ str/chkdocfi.i  }

FUNCTION get-function returns character(
                                        input p-f-name as character
                                       ,input p-format as character
                                       ,input p-excel as logical
):

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
      and buf_custom-labels.call-point = {&uf-chkdocfi}
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
    case entry(1, entry(jj-1, entry(jj, ubflt.filter.Fields-sort), "{&delim-flt}":U), "."):
      when "function":U then do:
        assign
        t-name = ''
        f-n = entry(jj-1, entry(jj, ubflt.filter.Fields-sort), "{&delim-flt}":U)
        .
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
ReportName = "Список товарных чеков"
str1 = ''
sheetf.Excel-Column-Lable = ubflt.filter.Fields-sort-rus
sheetf.sizes = ubflt.filter.Where-ysl
.

run waitfram-show in this-procedure ("Экспорт в EXCEL. Ждите ...").
run rep/extitle.p (1).

run adm/shattri.p (
      input "get":U
    ,input  p-curr-obj-type
    ,input  p-curr-obj-code
    ,input  {&attr-dc-ref}
    ,input  {&attr-dc-ref_l-mask} /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output par-l-mask
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .

for each thbjattr_thbj-attr where
       thbjattr_thbj-attr.obj-type = p-curr-obj-type
   and thbjattr_thbj-attr.obj-code = p-curr-obj-code
   and thbjattr_thbj-attr.upper-prop-code = {&attr-dc-ref}
on error undo, return error return-value :
  case thbjattr_thbj-attr.prop-code:
    when {&attr-dc-ref_l-mask} then do:
      assign
      par-l-mask = thbjattr_thbj-attr.property-value-logical.
    end.
  end case.
end.

iColumn = 0.  /* Начинаем писать со второй строки, 1-я - заголовок */
FOR EACH buf_chk-list No-LOCK
BREAK
BY buf_chk-list.doc-code :
  if first-of(buf_chk-list.doc-code) then do:
    {&page-excel-block}.
  end.
  if available buf_chk-doc then do:
    release buf_chk-doc.
  end.
  find first buf_chk-doc no-lock where
            buf_chk-doc.doc-code = buf_chk-list.doc-code no-error.
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
    ii-excel = ii-excel + 1.
    CASE  v-dop1:
      when "function":U then do:
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
        if par-l-mask and entry(jj, f-name) = "chk-doc.src-d-card" then 
        f-value = substring(f-value,1,6) + "XXXXXX" + substring (f-value,13,4).
        
        {&PutExcel}
        string(f-value, substitute("X(&1)", entry(jj, ubflt.filter.Where-ysl)))
        (if jj < j-n
        then
        {&tabulation}
        else {&new-line})
        .
      end. /*when {&table_chk-doc} then do:*/
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
    join-tbl = 'Чек,Другое'
    tbl =  {&table_chk-doc} + {&comma-char} + "function"
    c-point =  "chkl-prx" + {&delim-par} +  "PRNT":u  + {&delim-par} + "Список чеков"
    fld = ""
    lab = ""
    spr = ""
    dim = '0'
    v-size = "":U
    v-format = "":U
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
    run prnfield-add in this-procedure('iColumn', '№', 'function.integer', 7, ">>>>>>9":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-format, input-output dim)  no-error.
  end.

end procedure. /* init-prn-template */