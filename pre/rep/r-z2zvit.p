block-level on error undo, throw.
define input parameter p-parent-proc         as   widget-handle           no-undo.
define input parameter pobj-code             like ub.clients.obj-code     no-undo.
define input parameter pobj-type             like ub.clients.obj-type     no-undo.
define input parameter p-base-type           like ub.currency.curr-abbr   no-undo.
define input parameter p-base-code           like ub.currency.curr-code   no-undo.
define input parameter p-can-print           as   logical                 no-undo.
define input parameter p-sort-type           as   character               no-undo.
define input parameter pshift-date           like ub.shift-obj.shift-date no-undo.
define input parameter pshift-num            like ub.shift-obj.shift-num  no-undo.
define input parameter p-previous-shift-date as   date                    no-undo.
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U.
define variable vss-author      as character no-undo initial "$Author: expertek $":U.
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
define variable vss-workfile    as character no-undo initial "$Workfile: r-z2zvit.p $":U.
define variable vss-archive     as character no-undo initial "$Archive: rep/r-z2zvit.p $":U.
define variable vss-description as character no-undo initial "сменный отчет АЗС (Украина)":U.
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE shared TEMP-TABLE treal-2 no-undo
FIELD gds-code as integer
FIELD cpay-code as integer
FIELD curr-code as integer
FIELD qnty1 as decimal
FIELD qnty2 as decimal
FIELD netto as decimal
FIELD brutto as decimal
FIELD discount-sum as decimal
FIELD chk-qnty as int
FIELD out-name as character format "X(18)"
FIELD is-pay as logical
FIELD ii as integer
field discnt-type as integer
INDEX pi IS
  primary
      gds-code
      cpay-code
      curr-code
      is-pay DESCENDING
INDEX vi
      gds-code
      cpay-code
      discnt-type
      ii
.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE shared TEMP-TABLE t-2 no-undo
FIELD gds-code like ub.goods.gds-code
FIELD main-code like ub.bar-code.b-code
FIELD artic like ub.goods.artic
FIELD prod-type like ub.goods.prod-type
FIELD prod-code like ub.goods.prod-code
FIELD qnty1-before as decimal FORMAT "->>>>9.99"
FIELD qnty2-before as decimal FORMAT "->>>>9.99"
FIELD qnty1-after as decimal FORMAT "->>>>9.99"
FIELD qnty2-after as decimal FORMAT "->>>>9.99"
FIELD last-price as decimal FORMAT ">>>>9.99"
FIELD gds-name like ub.goods.gds-name FORMAT "X(12)"
FIELD lines as integer
INDEX pi IS UNIQUE primary
gds-code
INDEX art IS UNIQUE
artic
prod-type
prod-code
INDEX pervakov IS UNIQUE
main-code
.
DEFINE shared TEMP-TABLE tincome-2 no-undo
FIELD gds-code as integer
FIELD supp-name like ub.clients.obj-name FORMAT "X(18)"
FIELD supp-type like ub.clients.obj-type
FIELD supp-code like ub.clients.obj-code FORMAT ">>>>>>>>9"
FIELD doc-code-trn  like ub.trn-doc.doc-code
FIELD doc-code  like ub.trn-doc.doc-code
FIELD qnty1 as decimal FORMAT "->>>>9.99"
FIELD qnty2 as decimal FORMAT "->>>>9.99"
FIELD qnty3 as decimal FORMAT "->>>>9.99"
FIELD density as decimal FORMAT "9.999"
FIELD temperature as decimal FORMAT ">9.99"
FIELD naturalloss as decimal FORMAT ">9.99"
FIELD is-fact as logical
FIELD ii as integer
INDEX pi IS UNIQUE PRIMARY
      gds-code
      doc-code-trn
      doc-code
      supp-code
INDEX vi IS UNIQUE
      gds-code
      ii
.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable gdsgrp_recids      as character no-undo.
define  shared variable fin-schet-recid    as character no-undo.
define  shared variable v-d-report-handle  as handle    no-undo .
define  shared temp-table g#customer no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define  shared temp-table g#cli no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define  shared temp-table tmp#grp no-undo
    field node-code like ub.gds-grp.node-code
    field grp-name like ub.gds-grp.node-name
    field lvl-num  like ub.gds-grp.lvl-num
    field is-term  like ub.gds-grp.is-term
    index pi is unique primary grp-name node-code
    index i-node-code    node-code
    index level-num   lvl-num  grp-name
    index is-term is-term  grp-name
    .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared temp-table gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define   shared  temp-table gds-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def
 shared
temp-table  obj-list no-undo
  field obj-type like ub.clients.obj-type
  field obj-code like ub.clients.obj-code
  field obj-name like ub.clients.obj-name
  field obj-id   as integer
  field db-num   as integer
  index pi is primary unique obj-id
  index ie1 obj-type obj-code
  index ie2 obj-name
.
procedure create_obj-list :
   define input parameter p-obj-type like ub.clients.obj-type no-undo .
   define input parameter p-obj-code like ub.clients.obj-code no-undo .
   do
   on error undo, return error return-value
   :
      define buffer cli-obj for ub.clients .
      define variable p-var as integer no-undo .
      define buffer buf_obj-list for obj-list .
      find last buf_obj-list  use-index pi no-error .
      if available buf_obj-list
      then
         p-var = buf_obj-list.obj-id + 1.
      else
         p-var = 1.
      find first cli-obj where
                cli-obj.obj-type = p-obj-type
            and cli-obj.obj-code = p-obj-code
      no-lock no-error.
      if available cli-obj
      then do:
         create buf_obj-list.
         assign
            buf_obj-list.obj-id   = p-var
            buf_obj-list.obj-code = cli-obj.obj-code
            buf_obj-list.obj-type = cli-obj.obj-type
            buf_obj-list.obj-name = cli-obj.obj-name
            buf_obj-list.db-num   = cli-obj.db-num
         .
      end.
   end.
end.
define  shared temp-table X-init_obj-list no-undo
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
index pi is unique primary obj-type obj-code.
define variable p1 like ub.gds-obj.prod-type no-undo.
define variable p2 like ub.gds-obj.prod-code no-undo.
define variable p3 like ub.gds-obj.artic     no-undo.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable to-day       as date no-undo .
define   shared variable str1   as character  no-undo.
define   shared variable str2   as character  no-undo.
define   shared variable str3   as character  no-undo.
define   shared variable str4   as character  no-undo.
define   shared variable ReportNAme   as character  no-undo.
define   shared variable ReportProc   as character  no-undo.
define   shared variable ReportHeader as character  no-undo.
define   shared variable ReportPageWidth  as integer no-undo.
define   shared variable ReportPageHeight as integer no-undo.
define   shared variable ReportFontNum    as integer no-undo.
define   shared variable my-request as logical  init false no-undo.
define   shared variable v-delim as character no-undo .
define   shared variable v-sdate as character no-undo initial "/":U.
define   shared variable v-shortdate as character no-undo initial "dd/mm/yyyy":U .
define   shared variable my-handle  as handle no-undo .
define   shared variable parent-handle  as handle no-undo .
define   shared variable v-show-all-goods as logical  no-undo .
define   shared variable params-only      as logical   no-undo .
define   shared variable params-only-mode as character no-undo .
define   shared variable place-call       as character no-undo .
define   shared variable x-Goods-Editor   as character  no-undo .
define   shared variable x-Date-Alone     as date format "99/99/9999":u   no-undo .
define   shared variable x-Date-End       as date format "99/99/9999":u   no-undo .
define   shared variable x-Date-Start     as date format "99/99/9999":u   no-undo .
define   shared variable x-Shift-Alone    as integer format ">9":u         no-undo .
define   shared variable x-Shift-End      as integer format ">9":u         no-undo .
define   shared variable x-Shift-Start    as integer format ">9":u         no-undo .
define   shared variable x-SelectGood     as integer                      no-undo .
define   shared variable x-SelectObject   as character                          no-undo .
define   shared variable x-SET_PAY_TYPE   as integer  no-undo .
define   shared variable x-SET_val_TYPE   as integer  no-undo .
define   shared variable x-TOG-Shift      as logical  no-undo .
define   shared variable x-Radio-Task     as integer  no-undo .
define   shared variable x-TOG-Excel      as logical  no-undo .
define   shared variable x-TOG-list-hist  as logical  no-undo .
define   shared variable x-text-1 as character  no-undo .
define   shared variable x-text-2 as character  no-undo .
define   shared variable x-text-3 as character  no-undo .
define   shared variable x-text-4 as character  no-undo .
define   shared variable init-date-start  like x-date-start  no-undo .
define   shared variable init-date-end    like x-date-end    no-undo .
define   shared variable init-date-alone  like x-date-alone  no-undo .
define   shared variable init-shift-alone like x-shift-alone no-undo .
define   shared variable init-shift-start like x-shift-start no-undo .
define   shared variable init-shift-end   like x-shift-end   no-undo .
define   shared variable init-set_pay_type like x-set_pay_type   no-undo .
define   shared variable init-set_val_type like x-set_val_type   no-undo .
define   shared variable ref_date-start    as character   no-undo .
define   shared variable ref_date-end      as character   no-undo .
define   shared variable ref_date-alone    as character   no-undo .
define   shared work-table TDEDT  no-undo
  field id as char
  field name as character  format "x(40)"
  field n as character
  .
define variable tempstr as character  no-undo.
define variable b1-name as character  no-undo.
define variable b2-name as character  no-undo.
define variable source-str   as character no-undo .
define variable I#           as integer    no-undo.
define variable p-price-med  as decimal init 0 no-undo .
define   shared variable str-obj-type as character  no-undo.
define   shared variable str-obj-code as character  no-undo.
define   shared variable str-obj-name as character  no-undo.
define   shared variable str-obj      as character  no-undo.
define   shared variable link#        as logical  no-undo init false.
define   shared variable  Verify-Arc-ot      as logical  no-undo init false.
define   shared variable  Verify-Arc-stk     as logical  no-undo init false.
define   shared variable  Verify-Arc-supp    as logical  no-undo init false.
define   shared variable  Verify-Arc-hold    as logical  no-undo init false.
define   shared variable  Verify-Arc-aht     as logical  no-undo init false.
define   shared variable  Verify-send-check  as logical  no-undo init false.
define   shared variable  Verify-Arc-fin     as logical  no-undo init false.
define   shared variable  Verify-Arc-strong  as logical  no-undo init false.
define   shared variable  Show-Crsa         as logical  no-undo init false.
define   shared variable  Show-Cost         as logical  no-undo init false.
define   shared variable  Show-Sale         as logical  no-undo init false.
define   shared variable  Name-Sale-price   as character no-undo .
define   shared variable  Format-Folder     as logical no-undo .
define   shared variable  Print-List-Hist   as logical no-undo init false.
define   shared variable Make-Excel     as logical  no-undo init false.
define   shared variable Make-Excel-com as logical  no-undo init false.
define   shared stream ForExcel.
define   shared variable Use-column   as logical extent 256 no-undo .
define   shared variable right-column as logical extent 256 no-undo .
define shared  temp-table Sheetf no-undo
field Excel-Column-Lable as character
field Excel-Row-Heder    as integer
field Excel-Row-Title    as integer
field Sizes              as character
field Make-correct       as character
field Rights-column      as character
field MergeCellsH        as character
field MergeCellsV        as character
field sheet-num          as integer
field ColFormat          as character
field Bas-FIle           as character
field Bas-Params         as character
field Bas-Param-Add      as logical
field File-name          as character
field Silent-save        as logical
index pi as primary unique
      sheet-num
.
find first sheetf where sheet-num = 1 no-error.
define variable l-stroka as character no-undo .
define   shared  variable ch#ExcelApplication as com-handle no-undo .
define   shared  variable ch#Workbook         as com-handle no-undo .
define   shared  variable ch#Worksheet        as com-handle no-undo .
define   shared  variable Num#Str#            as integer no-undo.
define   shared  variable Number-List         as integer no-undo init 1.
define   shared  variable v-excel-file        as character no-undo .
define variable Col-name as character  extent 256.
define variable Col-format as character  extent 256.
define variable Col-Post-format as character  extent 256.
run proc-page0-assign in this-procedure .
procedure proc-page0-assign :
 do
 on error undo, return error return-value
 :
Assign
  Col-name[1] = 'A':U
  Col-name[2] = 'B':U
  Col-name[3] = 'C':U
  Col-name[4] = 'D':U
  Col-name[5] = 'E':U
  Col-name[6] = 'F':U
  Col-name[7] = 'G':U
  Col-name[8] = 'H':U
  Col-name[9] = 'I':U
  Col-name[10]= 'J':U
  Col-name[11]= 'K':U
  Col-name[12]= 'L':U
  Col-name[13]= 'M':U
  Col-name[14]= 'N':U
  Col-name[15]= 'O':U
  Col-name[16]= 'P':U
  Col-name[17]= 'Q':U
  Col-name[18]= 'R':U
  Col-name[19]= 'S':U
  Col-name[20]= 'T':U
  Col-name[21]= 'U':U
  Col-name[22]= 'V':U
  Col-name[23]= 'W':U
  Col-name[24]= 'X':U
  Col-name[25]= 'Y':U
  Col-name[26]= 'Z':U
  Col-name[27]= 'AA':U
  Col-name[28]= 'AB':U
  Col-name[29]= 'AC':U
  Col-name[30]= 'AD':U
  Col-name[31]= 'AE':U
  Col-name[32]= 'AF':U
  Col-name[33]= 'AG':U
  Col-name[34]= 'AH':U
  Col-name[35]= 'AI':U
  Col-name[36]= 'AJ':U
  Col-name[37]= 'AK':U
  Col-name[38]= 'AL':U
  Col-name[39]= 'AM':U
  Col-name[40]= 'AN':U
  Col-name[41]= 'AO':U
  Col-name[42]= 'AP':U
  Col-name[43]= 'AQ':U
  Col-name[44]= 'AR':U
  Col-name[45]= 'AS':U
  Col-name[46]= 'AT':U
  Col-name[47]= 'AU':U
  Col-name[48]= 'AV':U
  Col-name[49]= 'AW':U
  Col-name[50]= 'AX':U
  Col-name[51]= 'AY':U
  Col-name[52]= 'AZ':U
  Col-name[53]= 'BA':U
  Col-name[54]= 'BB':U
  Col-name[55]= 'BC':U
  Col-name[56]= 'BD':U
  Col-name[57]= 'BE':U
  Col-name[58]= 'BF':U
  Col-name[59]= 'BG':U
  Col-name[60]= 'BH':U
  Col-name[61]= 'BI':U
  Col-name[62]= 'BJ':U
  Col-name[63]= 'BK':U
  Col-name[64]= 'BL':U
  Col-name[65]= 'BM':U
  Col-name[66]= 'BN':U
  Col-name[67]= 'BO':U
  Col-name[68]= 'BP':U
  Col-name[69]= 'BQ':U
  Col-name[70]= 'BR':U
  Col-name[71]= 'BS':U
  Col-name[72]= 'BT':U
  Col-name[73]= 'BU':U
  Col-name[74]= 'BV':U
  Col-name[75]= 'BW':U
  Col-name[76]= 'BX':U
  Col-name[77]= 'BY':U
  Col-name[78]= 'BZ':U
  Col-name[79]= 'CA':U
  Col-name[80]= 'CB':U
  Col-name[81]= 'CC':U
  Col-name[82]= 'CD':U
  Col-name[83]= 'CE':U
  Col-name[84]= 'CF':U
  Col-name[85]= 'CG':U
  Col-name[86]= 'CH':U
  Col-name[87]= 'CI':U
  Col-name[88]= 'CJ':U
  Col-name[89]= 'CK':U
  Col-name[90]= 'CL':U
  Col-name[91]= 'CM':U
  Col-name[92]= 'CN':U
  Col-name[93]= 'CO':U
  Col-name[94]= 'CP':U
  Col-name[95]= 'CQ':U
  Col-name[96]= 'CR':U
  Col-name[97]= 'CS':U
  Col-name[98]= 'CT':U
  Col-name[99]= 'CU':U
  Col-name[100]= 'CV':U
Col-name[101]= 'CW':U
Col-name[102]= 'CX':U
Col-name[103]= 'CY':U
Col-name[104]= 'CZ':U
Col-name[105]= 'DA':U
Col-name[106]= 'DB':U
Col-name[107]= 'DC':U
Col-name[108]= 'DD':U
Col-name[109]= 'DE':U
Col-name[110]= 'DF':U
Col-name[111]= 'DG':U
Col-name[112]= 'DH':U
Col-name[113]= 'DI':U
Col-name[114]= 'DJ':U
Col-name[115]= 'DK':U
Col-name[116]= 'DL':U
Col-name[117]= 'DM':U
Col-name[118]= 'DN':U
Col-name[119]= 'DO':U
Col-name[120]= 'DP':U
Col-name[121]= 'DQ':U
Col-name[122]= 'DR':U
Col-name[123]= 'DS':U
Col-name[124]= 'DT':U
Col-name[125]= 'DU':U
Col-name[126]= 'DV':U
Col-name[127]= 'DW':U
Col-name[128]= 'DX':U
Col-name[129]= 'DY':U
Col-name[130]= 'DZ':U
Col-name[131]= 'EA':U
Col-name[132]= 'EB':U
Col-name[133]= 'EC':U
Col-name[134]= 'ED':U
Col-name[135]= 'EE':U
Col-name[136]= 'EF':U
Col-name[137]= 'EG':U
Col-name[138]= 'EH':U
Col-name[139]= 'EI':U
Col-name[140]= 'EJ':U
Col-name[141]= 'EK':U
Col-name[142]= 'EL':U
Col-name[143]= 'EM':U
Col-name[144]= 'EN':U
Col-name[145]= 'EO':U
Col-name[146]= 'EP':U
Col-name[147]= 'EQ':U
Col-name[148]= 'ER':U
Col-name[149]= 'ES':U
Col-name[150]= 'ET':U
Col-name[151]= 'EU':U
Col-name[152]= 'EV':U
Col-name[153]= 'EW':U
Col-name[154]= 'EX':U
Col-name[155]= 'EY':U
Col-name[156]= 'EZ':U
Col-name[157]= 'FA':U
.
assign
  Col-name[158]= 'FB':U
  Col-name[159]= 'FC':U
  Col-name[160]= 'FD':U
  Col-name[161]= 'FE':U
  Col-name[162]= 'FF':U
  Col-name[163]= 'FG':U
  Col-name[164]= 'FH':U
  Col-name[165]= 'FI':U
  Col-name[166]= 'FJ':U
  Col-name[167]= 'FK':U
  Col-name[168]= 'FL':U
  Col-name[169]= 'FM':U
  Col-name[170]= 'FN':U
  Col-name[171]= 'FO':U
  Col-name[172]= 'FP':U
  Col-name[173]= 'FQ':U
  Col-name[174]= 'FR':U
  Col-name[175]= 'FS':U
  Col-name[176]= 'FT':U
  Col-name[177]= 'FU':U
  Col-name[178]= 'FV':U
  Col-name[179]= 'FW':U
  Col-name[180]= 'FX':U
  Col-name[181]= 'FY':U
  Col-name[182]= 'FZ':U
  Col-name[183]= 'GA':U
  Col-name[184]= 'GB':U
  Col-name[185]= 'GC':U
  Col-name[186]= 'GD':U
  Col-name[187]= 'GE':U
  Col-name[188]= 'GF':U
  Col-name[189]= 'GG':U
  Col-name[190]= 'GH':U
  Col-name[191]= 'GI':U
  Col-name[192]= 'GJ':U
  Col-name[193]= 'GK':U
  Col-name[194]= 'GL':U
  Col-name[195]= 'GM':U
  Col-name[196]= 'GN':U
  Col-name[197]= 'GO':U
  Col-name[198]= 'GP':U
  Col-name[199]= 'GQ':U
  Col-name[200]=   'GR':U
  Col-name[201]=   'GS':U
  Col-name[202]=   'GT':U
  Col-name[203]=   'GU':U
  Col-name[204]=   'GV':U
  Col-name[205]=   'GW':U
  Col-name[206]=   'GX':U
  Col-name[207]=   'GY':U
  Col-name[208]=   'GZ':U
  Col-name[209]=   'HA':U
  Col-name[210]=   'HB':U
  Col-name[211]=   'HC':U
  Col-name[212]=   'HD':U
  Col-name[213]=   'HE':U
  Col-name[214]=   'HF':U
  Col-name[215]=   'HG':U
  Col-name[216]=   'HH':U
  Col-name[217]=   'HI':U
  Col-name[218]=   'HJ':U
  Col-name[219]=   'HK':U
  Col-name[220]=   'HL':U
  Col-name[221]=   'HM':U
  Col-name[222]=   'HN':U
  Col-name[223]=   'HO':U
  Col-name[224]=   'HP':U
  Col-name[225]=   'HQ':U
  Col-name[226]=   'HR':U
  Col-name[227]=   'HS':U
  Col-name[228]=   'HT':U
  Col-name[229]=   'HU':U
  Col-name[230]=   'HV':U
  Col-name[231]=   'HW':U
  Col-name[232]=   'HX':U
  Col-name[233]=   'HY':U
  Col-name[234]=   'HZ':U
  Col-name[235]=   'IA':U
  Col-name[236]=   'IB':U
  Col-name[237]=   'IC':U
  Col-name[238]=   'ID':U
  Col-name[239]=   'IE':U
  Col-name[240]=   'IF':U
  Col-name[241]=   'IG':U
  Col-name[242]=   'IH':U
  Col-name[243]=   'II':U
  Col-name[244]=   'IJ':U
  Col-name[245]=   'IK':U
  Col-name[246]=   'IL':U
  Col-name[247]=   'IM':U
  Col-name[248]=   'IN':U
  Col-name[249]=   'IO':U
  Col-name[250]=   'IP':U
  Col-name[251]=   'IQ':U
  Col-name[252]=   'IR':U
  Col-name[253]=   'IS':U
  Col-name[254]=   'IT':U
  Col-name[255]=   'IU':U
  Col-name[256]=   'IV':U
  .
 end.
end procedure.
define variable var-report-r-b as character no-undo .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
define variable sym1  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym2  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym3  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym4  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym5  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym6  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym7  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym8  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym9  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym10 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym11 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym12 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym13 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym14 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym15 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym16 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym17 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym18 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym19 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym20 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym21 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym22 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym23 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym24 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym25 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym26 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym27 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable temp1 as integer   no-undo.
define variable div# as char no-undo.
define variable fr as logical no-undo .
define variable fr0 as logical no-undo .
define variable tmp#stroka as character no-undo .
define variable tmp#stroka0 as character no-undo .
define variable v-bar-code    like ub.bar-code.b-code no-undo  .
define variable s-bar-code   as character format "x(9)" no-undo .
define temp-table tmp-gds no-undo
  field id as integer
  field name      as character  format "x(256)"
  field f-name    as character  format "x(256)"
  field node-code as integer
  field lvl       as integer
 index pi id
.
define variable NEW-vat        like ub.doc-line.vat-pc    no-undo.
define variable LAST-vat       like ub.doc-line.vat-pc    no-undo.
define variable  var-vat-pc    like ub.doc-line.vat-pc    no-undo.
define variable g-ll as integer no-undo .
define variable id as integer no-undo .
define temp-table temp-gds-list no-undo
  field gds-code  like ub.goods.gds-code
  field prod-code like ub.goods.prod-code
  field grp-name  like ub.goods.grp-name
  field gds-name  like ub.goods.gds-name
  field artic     like ub.goods.artic
  field vat-pc    as decimal
   index pi is primary unique gds-code ascending
   index i1 artic     ascending
   index i2 prod-code ascending
   index i3 grp-name  ascending
   index i33 gds-name  ascending
   index i4 vat-pc    ascending
   index i5 prod-code grp-name   ascending
   index i6 grp-name  prod-code   ascending
   .
define variable sum_1     as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable sum_2     as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable b1-sum_1  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable b1-sum_2  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable b2-sum_1  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable b2-sum_2  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable bi-sum_1  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable bi-sum_2  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable bo-sum_1  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable bo-sum_2  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
FUNCTION Int2Char RETURNS CHARACTER ( INPUT i-num AS INTEGER ) :   DEFINE VARIABLE v-str AS CHARACTER NO-UNDO.   RUN conv-int-to-char IN THIS-PROCEDURE ( INPUT i-num, OUTPUT v-str ) NO-ERROR.   RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE v-str ). END FUNCTION.      PROCEDURE conv-int-to-char :   DEFINE  INPUT PARAMETER p-num AS INTEGER   NO-UNDO.   DEFINE OUTPUT PARAMETER p-str AS CHARACTER NO-UNDO.   DO ON ERROR UNDO, RETURN ERROR :     ASSIGN p-str = TRIM( STRING( p-num, "->>>>>>>>>>>>":U ) ).   END.  END PROCEDURE.
FUNCTION addl-list RETURNS CHARACTER ( INPUT i-list  AS CHARACTER,                                        INPUT i-item  AS CHARACTER,                                        INPUT i-dlmtr AS CHARACTER  ) :   DEFINE VARIABLE v_out-list AS CHARACTER NO-UNDO.     RUN add-last-to-list IN THIS-PROCEDURE ( INPUT i-list, INPUT i-item, INPUT i-dlmtr, OUTPUT v_out-list ) NO-ERROR.   RETURN ( IF ERROR-STATUS :ERROR THEN i-list ELSE v_out-list ). END FUNCTION.      PROCEDURE add-last-to-list :   DEFINE  INPUT PARAMETER p-in-list    AS CHARACTER NO-UNDO.   DEFINE  INPUT PARAMETER p-added-item AS CHARACTER NO-UNDO.   DEFINE  INPUT PARAMETER p-delimiter  AS CHARACTER NO-UNDO.   DEFINE OUTPUT PARAMETER p-out-list   AS CHARACTER NO-UNDO.   DO ON ERROR UNDO, RETURN ERROR :     IF p-delimiter = "":U OR p-delimiter = ? THEN DO: ASSIGN p-delimiter = chr(44). END.     ASSIGN p-out-list = p-in-list + ( IF p-in-list = "":U THEN "":U ELSE p-delimiter ) + p-added-item.   END.  END PROCEDURE.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE create-treal-2.
DEFINE INPUT PARAMETER pgds-code like ub.goods.gds-code no-undo.
DEFINE INPUT PARAMETER pcpay-code like ub.cash-pay.cdpay-code no-undo.
DEFINE INPUT PARAMETER pcurr-code like ub.cash-pay.curr-code no-undo.
DEFINE INPUT PARAMETER pqnty1 as decimal no-undo.
DEFINE INPUT PARAMETER pqnty2 as decimal no-undo.
DEFINE INPUT PARAMETER pnetto as decimal no-undo.
DEFINE INPUT PARAMETER pout-name as character no-undo.
DEFINE INPUT PARAMETER pis-pay as logical no-undo.
DEFINE INPUT PARAMETER pii as integer no-undo.
_main:
DO ON ERROR UNDO _main, return error:
    create treal-2.
    assign
    treal-2.gds-code = pgds-code
    treal-2.cpay-code = pcpay-code
    treal-2.curr-code = pcurr-code
    treal-2.qnty1  =  pqnty1
    treal-2.qnty2  = pqnty2
    treal-2.netto = pnetto
    treal-2.out-name = pout-name
    treal-2.is-pay = pis-pay
    treal-2.ii = pii
    treal-2.discnt-type = -99
    no-error
    .
    if error-status:error then undo _main, return error.
END.
END PROCEDURE.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define shared stream PrnLibStream.
procedure prn-lib-prn-file :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-DIsabledoptions as integer no-undo .
  define variable v-report-name as character no-undo .
  define variable v-user-action as character no-undo .
  define variable v-printed     as logical   no-undo .
  define variable v-exist       as logical   no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run filenmln in g#library
  (input  v-report-name
  ,input  2
  ,output v-exist
  )  .
    if NOT v-exist then
    DO:
      Message
        "Нет заданий на печать ! "
        view-as alert-box .
      Return  .
    End.
    run gbl/prnfilen.w
      (input  ""
      ,input  p-DisabledOptions
      ,input  string(v-report-name )
      ,input  7
      ,output v-user-action
      ,output v-printed
      ) .
    if v-printed then
    do:
      return "YES" .
    end.
    else
    do:
      return "NO" .
    end.
  end.
end procedure.
procedure prn-lib-open-stream :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-page-size    as integer no-undo .
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-append       as logical no-undo .
  define variable v-report-name as character no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
    if p-is-stream then
    do:
      if p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
    if not p-is-stream then
    do:
      if p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
  end.
end procedure.
procedure prn-lib-open-exp :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-is-append    as logical no-undo .
  define output parameter p-ReportFileName as char init "report" no-undo.
  define output parameter p-process as logical no-undo .
  define variable glog as logical no-undo .
  do
    on error undo, return error
    :
    SYSTEM-DIALOG GET-FILE p-ReportFileName
      TITLE      "Укажите путь"
      FILTERS "Текстовый файл (*.txt)"   "*.txt"
      ASK-OVERWRITE
      CREATE-TEST-FILE
      SAVE-AS
      USE-FILENAME
      DEFAULT-EXTENSION "txt"
      UPDATE glog
      .
    if not glog then  return.
    p-ReportFileName = trim( string( p-ReportFileName ) ) .
    if p-is-stream then
    do:
      if p-is-append then
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    else
    do:
      if p-is-append then
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    p-process = yes.
  end.
end procedure.
procedure prn-lib-get-report-name :
  define input parameter parParentProc  as widget-handle no-undo.
  define output parameter p-report-name as character no-undo .
  p-report-name = ibs.th.gbl.gbl-inipar:prn-lib-get-report-name("rpt").
end procedure.
procedure prn-lib-reportviewer-report-name :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer-report-name(p-report-name-html) no-error.
end procedure.
procedure prn-lib-reportviewer :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  define input parameter p-param        as character no-undo .
  define variable v-excel           as character no-undo init 'TRUE' .
  define variable v-value-character as character no-undo .
  define variable v-value-integer   as character no-undo .
  define variable v-value-date      as date      no-undo .
  define variable v-value-decimal   as decimal   no-undo .
  define variable rep-excel         as logical   no-undo .
  define variable excel-string      as character no-undo .
  define variable v-param-type      as character no-undo .
  define variable v-tth             as handle    no-undo .
  run adm/shattri.p (
    input "get":U
    ,input  ""
    ,input  0
    ,input  'report-glob':U
    ,input  'rep-excel':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output rep-excel
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    )  .
  if rep-excel then v-excel = "TRUE" .
  else v-excel = "FALSE" .
  if p-param eq ""
  then
     p-param = "EXCEL:" + v-excel.
  else
     p-param = p-param + chr(4) + "EXCEL:" + v-excel .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer(p-report-name-html, p-param).
end procedure.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable pshift-date1           like ub.shift-obj.shift-date no-undo.
define variable pshift-num1            like ub.shift-obj.shift-num  no-undo.
assign
  pshift-date1 = pshift-date
  pshift-num1  = pshift-num
.
define variable pol1  as character no-undo.
define variable pol2  as character no-undo.
define variable pol3  as decimal   no-undo.
define variable pol4  as decimal   no-undo.
define variable pol5  as decimal   no-undo.
define variable pol6  as decimal   no-undo.
define variable pol7  as decimal   no-undo.
define variable pol8  as decimal   no-undo.
define variable pol9  as integer   no-undo.
define variable pol10 as decimal   no-undo.
define variable pol11 as decimal   no-undo.
define variable pol12 as decimal   no-undo.
define variable pol13 as decimal   no-undo.
define variable pol14 as decimal   no-undo.
define variable pol15 as decimal   no-undo.
define variable p-host-code       as integer   no-undo.
define variable v-param-shft-qty  as character no-undo.
define variable v-param-data-type as character no-undo.
define variable jndex             as integer   no-undo initial 0.
define variable o-pol2            as character no-undo.
define variable v_shift-name      as character no-undo.
define variable v_shift-name-num  as character no-undo.
define buffer bf_goods               for ub.goods.
define buffer bf_place               for ub.place.
define buffer control_rvs-doc        for ub.rvs-doc.
define buffer control_rvs-line-pump  for ub.rvs-line-pump.
define buffer current_rvs-doc        for ub.rvs-doc.
define buffer current_rvs-line       for ub.rvs-line.
define buffer current_rvs-line-pump  for ub.rvs-line-pump.
define buffer previous_rvs-doc       for ub.rvs-doc.
define buffer previous_rvs-line      for ub.rvs-line.
define buffer previous_rvs-line-pump for ub.rvs-line-pump.
define frame FRAME-2
                             space( 0 ) sym1  format "x(1)":U space( 0 )
  pol1  format "x(8)":U      space( 0 ) sym2  format "x(1)":U space( 2 )
  pol2  format "x(2)":U      space( 1 ) sym3  format "x(1)":U space( 3 )
  pol3  format ">>>>9":U     space( 2 ) sym4  format "x(1)":U space( 2 )
  pol4  format ">>9":U       space( 1 ) sym5  format "x(1)":U space( 1 )
  pol5  format ">>>9.99":U   space( 0 ) sym6  format "x(1)":U space( 1 )
  pol6  format ">>>>>9.99":U space( 1 ) sym7  format "x(1)":U space( 0 )
  pol7  format "->>>>9.99":U space( 0 ) sym8  format "x(1)":U space( 0 )
  pol8  format "->>>>9.99":U space( 0 ) sym9  format "x(1)":U space( 1 )
  pol9  format ">9":U        space( 0 ) sym10 format "x(1)":U space( 0 )
  pol10 format ">>>>>9.99":U space( 1 ) sym11 format "x(1)":U space( 1 )
  pol11 format ">>>>>9.99":U space( 1 ) sym12 format "x(1)":U space( 0 )
  pol12 format ">>9.99":U    space( 0 ) sym13 format "x(1)":U space( 0 )
  pol13 format ">>9.99":U    space( 0 ) sym14 format "x(1)":U space( 0 )
  pol14 format "->>>>9.99":U space( 0 ) sym15 format "x(1)":U space( 0 )
  pol15 format "->>>>9.99":U space( 0 ) sym16 format "x(1)":U space( 0 )
with width 232 down stream-io use-text no-labels no-box.
form header
  skip( 4 )
"----------------------------------------------------------------------------------------------------------------------------------------" skip
":        :             В - облік нафтопродуктів в резервуарах             :                 Г - робота лічильників ПРК                 :" skip
":        :----------------------------------------------------------------:------------------------------------------------------------:" skip
":  Марка :     : Висота зливу,мм :        :           :      різниця      :   : показання лічильника : відпущено за:       Розмір      :" skip
":  н/пр  :  №  :-----------------:  Трубо :Факт.залиш.:-------------------: № :----------------------: лічильником :    помилки ПРК    :" skip
":        :резер: загальна : води :провід,л: на кінець : надлишок: нестача :ПРК: на кінець: на початок:-------------:-------------------:" skip
":        :вуару:          :      :        :  зміни, л :    л    :    л    :   :  зміни, л:  зміни, л :   л  :   л  :    %    :    л    :" skip
":--------:-----:----------:------:--------:-----------:---------:---------:---:----------:-----------:------:------:---------:---------:" skip
":   3.1  : 3.2 :    3.3   :  3.4 :   3.5  :    3.6    :   3.7   :   3.8   :4.9:   4.10   :    4.11   : 4.12 : 4.13 :   4.14  :   4.15  :" skip
":--------:-----:----------:------:--------:-----------:---------:---------:---:----------:-----------:------:------:---------:---------:" skip
with frame TopFrame width 232 page-top no-labels no-box.
  procedure on-same-page :
    define input parameter p-line-number as integer no-undo .
    if p-line-number > page-size( PrnLibstream )
    then do:
      return .
    end.
    if line-counter( PrnLibstream ) + p-line-number > page-size( PrnLibstream )
    then do:
      page stream PrnLibstream .
    end.
  end procedure.
function excel-format-dec-to-char returns char (input p-dec as decimal ).
  if num-entries(string(p-dec), '.') = 2
    then return( entry(1, string(p-dec), '.') + v-delim + entry(2, string(p-dec), '.')) .
    else return( string(p-dec)) .
end function.
function format-point-to-comma returns char (input orig as char ) .
define variable rtext as character no-undo .
define variable strt as integer no-undo .
define variable leng as integer no-undo .
assign rtext = orig .
repeat:
  strt =  index(rtext,'.').
  if strt = 0 then leave.
  leng = 1.
  substring(rtext,strt,leng,"character") = v-delim .
end.
return rtext.
end function.
function format-excel-text returns char ( input start-text as char ) :
def var  i    as int no-undo.
def var  ch   as char no-undo.
def var  n    as int no-undo.
def var  ipos as int no-undo.
  n = num-entries(trim(start-text), chr(10)) - 1 .
  do i = 1 to n :
    ipos = index( start-text, chr(10)).
    if ipos > 0 then
      substr( start-text, ipos, 1 ) = ' '.
  end.
  n = num-entries(trim(start-text), chr(13)) - 1 .
  do i = 1 to n :
    ipos = index( start-text, chr(13)).
    if ipos > 0 then
      substr( start-text, ipos, 1 ) = ' '.
  end.
  if index( start-text, '"' ) = 0 then
    start-text =  '="'   + trim( start-text) + '"'   .
    else do:
      n = num-entries(trim(start-text), '"') - 1.
      do i = 1 to n :
        ch = ch + entry(i,trim(start-text), '"' ) + '""'.
      end.
      ch = ch + entry(num-entries(trim(start-text), '"'),trim(start-text), '"' ).
      start-text = '="'  + ch  + '"' .
    end.
  return start-text.
end.
function excel-sum returns char (input p-dec as decimal ).
  return(format-excel-text(excel-format-dec-to-char(round(p-dec,2)))) .
end function.
function excel-qnty returns char (input p-dec as decimal ).
  return(format-excel-text(excel-format-dec-to-char(round(p-dec,3)))) .
end function.
function format-excel-text-macr returns char ( input start-text as char ) :
def var  i    as int no-undo.
def var  ch   as char no-undo.
def var  n    as int no-undo.
def var  ipos as int no-undo.
  n = num-entries(trim(start-text), chr(10)) - 1 .
  do i = 1 to n :
    ipos = index( start-text, chr(10)).
    if ipos > 0 then
      substring( start-text, ipos , 1 ) = ' '.
  end.
  n = num-entries(trim(start-text), chr(13)) - 1 .
  do i = 1 to n :
    ipos = index( start-text, chr(13)).
    if ipos > 0 then
      substring( start-text, ipos, 1 ) = ' '.
  end.
  if index( start-text, '"' ) = 0 then
    start-text =  '"'   + trim( start-text) + '"'   .
    else do:
      n = num-entries(trim(start-text), '"') - 1.
      do i = 1 to n :
        ch = ch + entry(i,trim(start-text), '"' ) + '""'.
      end.
      ch = ch + entry(num-entries(trim(start-text), '"'),trim(start-text), '"' ).
      start-text = '"'  + ch  + '"' .
    end.
  n = num-entries(trim(start-text), chr(10)) - 1 .
  do i = 1 to n :
    ipos = index( start-text, chr(10)).
    if ipos > 0 then
      substring( start-text, ipos , 1 ) = ' '.
  end.
    if num-entries(trim(start-text), chr(10)) > 1 then  message num-entries(trim(start-text), chr(10)) start-text.
  return start-text.
end.
define buffer end_shift-obj      for ub.shift-obj .
define buffer previous-shift-obj for ub.shift-obj.
define variable fo      as decimal no-undo init 0.
define variable prev-fo as decimal no-undo init 0.
define variable moving  as logical no-undo init yes.
find first end_shift-obj share-lock
  where end_shift-obj.obj-type   = pobj-type
    and end_shift-obj.obj-code   = pobj-code
    and end_shift-obj.shift-date = pshift-date1
    and end_shift-obj.shift-num  = pshift-num1
    no-error.
if not available end_shift-obj then do:
  message
    vss-workfile vss-revision vss-description skip
    substitute("Не найдена смена с порядковым номером &1 от &2 для объекта &3 &4", pshift-num1, pshift-date1, pobj-type, pobj-code ) skip
    view-as alert-box error .
  return error.
end.
else do:
  assign
    fo = end_shift-obj.fact-order
  .
end.
find last previous-shift-obj share-lock
  where previous-shift-obj.obj-type = pobj-type
    and previous-shift-obj.obj-code = pobj-code
    and (( previous-shift-obj.shift-date = pshift-date
           and previous-shift-obj.shift-num < pshift-num
         )
         or previous-shift-obj.shift-date < pshift-date
        )
    use-index pi no-error.
if available previous-shift-obj then do:
    assign
      prev-fo = previous-shift-obj.fact-order
    .
end.
  define   temp-table tt-zz2 no-undo
    field gds-code    like ub.goods.gds-code
    field b-code      like ub.bar-code.b-code
    field artic       like ub.goods.artic
    field prod-type   like ub.goods.prod-type
    field prod-code   like ub.goods.prod-code
    field gds-name    like ub.goods.gds-name          format "x(8)":U
    field reservoir   like ub.place.loc1              format "x(2)":U
    field level-total as   decimal                    format ">>>>9":U     decimals 10
    field level-water as   decimal                    format ">>9":U       decimals 10
    field pipe-line   as   decimal                    format ">>>9.99":U   decimals 10
    field shift-qnty  as   decimal                    format ">>>>>9.99":U decimals 10
    field differ-qnty as   decimal                    format "->>>>9.99":U decimals 10
    field pump-code   like ub.rvs-line-pump.pump-code
    field shift-stop  as   decimal                    format ">>>>>9.99":U decimals 10
    field shift-start as   decimal                    format ">>>>>9.99":U decimals 10
    field mh-real     as   decimal                    format ">>9.99":U    decimals 10
    field mh-total    as   decimal                    format ">>9.99":U    decimals 10
    field delta-prc   as   decimal                    format "->>>>9.99":U decimals 10
    field delta-qnty  as   decimal                    format "->>>>9.99":U decimals 10
    field pl-code     like ub.rvs-line.pl-code
    field order       as   integer                    format "->>>>>>>>>9":U
    index gds-code    is   unique primary gds-code                     pl-code pump-code
    index artic       is   unique         artic    prod-type prod-code pl-code pump-code
    index gds-order   is   unique         gds-code                             order
    index pl-order    is   unique         gds-code                     pl-code order.
define buffer bf_zz2 for tt-zz2.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  pobj-type
  ,input  pobj-code
  ,output p-host-code
  ) no-error .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_shiftnam in g#lib-trn3
  (
     input pobj-type
  ,  input pobj-code
  ,  input pshift-date
  ,  input pshift-num
  , output v_shift-name
  , output v_shift-name-num
  )        no-error .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input pobj-type
  ,input pobj-code
  ,input 'report-obj':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'shft-qty'  then v-param-shft-qty  = thbjattr_thbj-attr.property-value-character .
  end.
  if lookup( v-param-shft-qty, "system,state":U ) = 0 then do:
     assign  v-param-shft-qty = "system":U.
  end.
find first current_rvs-doc no-lock where
           current_rvs-doc.obj-type   = pobj-type    and
           current_rvs-doc.obj-code   = pobj-code    and
           current_rvs-doc.shift-date = pshift-date  and
           current_rvs-doc.shift-num  = pshift-num   and
           current_rvs-doc.status_    = 'факт':U      and
           current_rvs-doc.rvs-type   = 'смена':U no-error.
if not available current_rvs-doc then do:
  message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
          "Не найдена сверка типа" '"' + 'смена':U + '"' skip( 0 )
          "Объект:" pobj-type   pobj-code        skip( 0 )
          "Смена"   pshift-date v_shift-name-num skip( 1 )
  view-as alert-box error.
  return error.
end.
if available previous-shift-obj then do:
  find first previous_rvs-doc no-lock where
             previous_rvs-doc.obj-type   = pobj-type                     and
             previous_rvs-doc.obj-code   = pobj-code                     and
             previous_rvs-doc.shift-date = previous-shift-obj.shift-date and
             previous_rvs-doc.shift-num  = previous-shift-obj.shift-num  and
             previous_rvs-doc.status_    = 'факт':U                       and
             previous_rvs-doc.rvs-type   = 'смена':U                  no-error.
end.
for each current_rvs-line no-lock where
         current_rvs-line.rvs-code = current_rvs-doc.rvs-code and
         current_rvs-line.obj-type = current_rvs-doc.obj-type and
         current_rvs-line.obj-code = current_rvs-doc.obj-code
break by current_rvs-line.gds-code
      by current_rvs-line.pl-code
:
  find first bf_goods no-lock where
             bf_goods.gds-code = current_rvs-line.gds-code no-error.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  bf_goods.gds-code
  ,input  ?
  ,output v-bar-code
  )  .
  find first bf_place no-lock where
             bf_place.obj-code = current_rvs-line.obj-code and
             bf_place.obj-type = current_rvs-line.obj-type and
             bf_place.pl-code  = current_rvs-line.pl-code  no-error.
  if available previous_rvs-doc then do:
    find first previous_rvs-line no-lock where
               previous_rvs-line.rvs-code = previous_rvs-doc.rvs-code and
               previous_rvs-line.obj-code = current_rvs-line.obj-code and
               previous_rvs-line.obj-type = current_rvs-line.obj-type and
               previous_rvs-line.pl-code  = current_rvs-line.pl-code  and
               previous_rvs-line.gds-code = current_rvs-line.gds-code no-error.
  end.
  for each current_rvs-line-pump no-lock where
           current_rvs-line-pump.rvs-code = current_rvs-line.rvs-code and
           current_rvs-line-pump.obj-code = current_rvs-line.obj-code and
           current_rvs-line-pump.obj-type = current_rvs-line.obj-type and
           current_rvs-line-pump.pl-code  = current_rvs-line.pl-code  and
           current_rvs-line-pump.gds-code = current_rvs-line.gds-code
  break by current_rvs-line-pump.pump-code
        by current_rvs-line-pump.nozzle-code
  :
    if first-of( current_rvs-line-pump.pump-code ) then do:
      assign pol10 = 0
             pol11 = 0
             pol12 = 0
             pol14 = 0
             pol15 = 0.
    end.
    assign pol10 = pol10 + current_rvs-line-pump.state-mh-cnt.
    if available previous_rvs-doc then do:
      find first previous_rvs-line-pump no-lock where
                 previous_rvs-line-pump.rvs-code    = previous_rvs-doc.rvs-code         and
                 previous_rvs-line-pump.obj-code    = current_rvs-line.obj-code         and
                 previous_rvs-line-pump.obj-type    = current_rvs-line.obj-type         and
                 previous_rvs-line-pump.pl-code     = current_rvs-line.pl-code          and
                 previous_rvs-line-pump.gds-code    = current_rvs-line.gds-code         and
                 previous_rvs-line-pump.pump-code   = current_rvs-line-pump.pump-code   and
                 previous_rvs-line-pump.nozzle-code = current_rvs-line-pump.nozzle-code no-error.
      if available previous_rvs-line-pump then do:
        assign pol11 = pol11 + previous_rvs-line-pump.state-mh-cnt.
      end.
    end.
    if not available previous_rvs-doc       or
       not available previous_rvs-line-pump then do:
      for each  control_rvs-doc no-lock where
                control_rvs-doc.obj-type          = current_rvs-doc.obj-type          and
                control_rvs-doc.obj-code          = current_rvs-doc.obj-code          and
                control_rvs-doc.shift-date        = current_rvs-doc.shift-date        and
                control_rvs-doc.shift-num         = current_rvs-doc.shift-num         and
                control_rvs-doc.status_           = 'факт':U                           and
                control_rvs-doc.rvs-type          = 'контроль':U
        , first control_rvs-line-pump no-lock where
                control_rvs-line-pump.rvs-code    = control_rvs-doc.rvs-code          and
                control_rvs-line-pump.gds-code    = current_rvs-line.gds-code         and
                control_rvs-line-pump.obj-code    = current_rvs-line.obj-code         and
                control_rvs-line-pump.obj-type    = current_rvs-line.obj-type         and
                control_rvs-line-pump.pl-code     = current_rvs-line.pl-code          and
                control_rvs-line-pump.pump-code   = current_rvs-line-pump.pump-code   and
                control_rvs-line-pump.nozzle-code = current_rvs-line-pump.nozzle-code
             by control_rvs-doc.fact-order        :
        assign pol11 = pol11 + control_rvs-line-pump.state-mh-cnt.
        leave.
      end.
    end.
    if last-of( current_rvs-line-pump.pump-code ) then do:
      assign pol12 = pol10 - pol11
             pol14 = 0
             pol15 = 0.
      find first tt-zz2 where
                 tt-zz2.gds-code  = current_rvs-line-pump.gds-code  and
                 tt-zz2.pl-code   = current_rvs-line-pump.pl-code   and
                 tt-zz2.pump-code = current_rvs-line-pump.pump-code no-error.
      if not available tt-zz2 then do:
        assign jndex = jndex + 1.
        create tt-zz2.
        assign tt-zz2.gds-code  = bf_goods.gds-code
               tt-zz2.artic     = bf_goods.artic
               tt-zz2.prod-type = bf_goods.prod-type
               tt-zz2.prod-code = bf_goods.prod-code
               tt-zz2.gds-name  = bf_goods.gds-name
               tt-zz2.b-code    = v-bar-code
               tt-zz2.reservoir = ( if available bf_place then trim( bf_place.loc1 ) else "??" )
               tt-zz2.pl-code   = current_rvs-line-pump.pl-code
               tt-zz2.pump-code = current_rvs-line-pump.pump-code
               tt-zz2.order     = jndex.
      end.
      assign tt-zz2.shift-stop  = pol10
             tt-zz2.shift-start = pol11
             tt-zz2.mh-real     = pol12.
    end.
  end.
end.
for each tt-zz2 no-lock
break by tt-zz2.gds-code
      by tt-zz2.pl-code
      by tt-zz2.pump-code
:
  if first-of( tt-zz2.pl-code ) then do:
    assign pol13 = 0.
  end.
  assign pol13 = pol13 + tt-zz2.mh-real.
  if last-of( tt-zz2.pl-code ) then do:
    find first current_rvs-line no-lock where
               current_rvs-line.rvs-code = current_rvs-doc.rvs-code and
               current_rvs-line.obj-type = current_rvs-doc.obj-type and
               current_rvs-line.obj-code = current_rvs-doc.obj-code and
               current_rvs-line.pl-code  = tt-zz2.pl-code           and
               current_rvs-line.gds-code = tt-zz2.gds-code          no-error.
    find first bf_zz2 where
               bf_zz2.gds-code = tt-zz2.gds-code and
               bf_zz2.pl-code  = tt-zz2.pl-code  use-index pl-order no-error.
    assign bf_zz2.mh-total    = pol13
           bf_zz2.level-total = current_rvs-line.state-level-total * 10
           bf_zz2.level-water = current_rvs-line.state-level-water * 10
           bf_zz2.pipe-line   = current_rvs-line.state-add-qnty
           bf_zz2.shift-qnty  = ( if v-param-shft-qty = "state":U then current_rvs-line.state-measure-qnty
                                                                  else current_rvs-line.system-qnty        )
           pol13              = 0.
  end.
  if last-of( tt-zz2.gds-code ) then do:
    find first current_rvs-line no-lock where
               current_rvs-line.rvs-code = current_rvs-doc.rvs-code and
               current_rvs-line.obj-type = current_rvs-doc.obj-type and
               current_rvs-line.obj-code = current_rvs-doc.obj-code and
               current_rvs-line.pl-code  = tt-zz2.pl-code           and
               current_rvs-line.gds-code = tt-zz2.gds-code          no-error.
    find first bf_zz2 where
               bf_zz2.gds-code = tt-zz2.gds-code use-index gds-order no-error.
    assign bf_zz2.differ-qnty = ( if v-param-shft-qty = "state":U then current_rvs-line.state-measure-qnty
                                                                  else current_rvs-line.system-qnty        )
                              - current_rvs-line.system-qnty.
  end.
end.
assign pol1  = "":U
       pol2  = "":U
       pol3  = 0
       pol4  = 0
       pol5  = 0
       pol6  = 0
       pol7  = 0
       pol8  = 0
       pol9  = 0
       pol10 = 0
       pol11 = 0
       pol12 = 0
       pol13 = 0
       pol14 = 0
       pol15 = 0.
if p-can-print = yes then do:
  view stream PrnLibStream frame TopFrame.
  for each tt-zz2 no-lock
  break by tt-zz2.gds-code
        by tt-zz2.pl-code
        by tt-zz2.pump-code
  :
    assign pol1  = tt-zz2.gds-name
           pol2  = tt-zz2.reservoir
           pol3  = tt-zz2.level-total
           pol4  = tt-zz2.level-water
           pol5  = tt-zz2.pipe-line
           pol6  = tt-zz2.shift-qnty
           pol7  = ( if tt-zz2.differ-qnty > 0 then tt-zz2.differ-qnty else 0 )
           pol8  = ( if tt-zz2.differ-qnty < 0 then tt-zz2.differ-qnty else 0 )
           pol9  = tt-zz2.pump-code
           pol10 = tt-zz2.shift-stop
           pol11 = tt-zz2.shift-start
           pol12 = tt-zz2.mh-real
           pol13 = tt-zz2.mh-total
           pol14 = tt-zz2.delta-prc
           pol15 = tt-zz2.delta-qnty.
    display stream PrnLibStream sym1
                                sym9
                                sym10
                                sym11
                                sym12
                                sym13
                                sym14
                                sym15
                                sym16
    with frame FRAME-2.
    if first-of( tt-zz2.gds-code ) then do:
      assign o-pol2 = pol2.
      display stream PrnLibStream pol1                sym2
                                  pol2                sym3
                                  pol3 when pol3 <> ? sym4
                                  pol4 when pol4 <> ? sym5
                                  pol5 when pol5 <> ? sym6
                                  pol6                sym7
                                  pol7 when pol7 >  0 sym8
                                  pol8 when pol8 <  0 sym9
      with frame FRAME-2.
        if Make-Excel then  put   stream ForExcel unformatted pol1  CHR(9)
                    pol2  CHR(9).
          if pol3 <> ? then do:
        if Make-Excel then  put   stream ForExcel unformatted pol3  CHR(9).
          end.
          else do:
        if Make-Excel then  put   stream ForExcel unformatted       CHR(9).
          end.
          if pol4 <> ? then do:
        if Make-Excel then  put   stream ForExcel unformatted pol4  CHR(9).
          end.
          else do:
        if Make-Excel then  put   stream ForExcel unformatted       CHR(9).
          end.
          if pol5 <> ? then do:
        if Make-Excel then  put   stream ForExcel unformatted pol5  CHR(9).
          end.
          else do:
        if Make-Excel then  put   stream ForExcel unformatted       CHR(9).
          end.
        if Make-Excel then  put   stream ForExcel unformatted pol6  CHR(9).
          if pol7  > 0 then do:
        if Make-Excel then  put   stream ForExcel unformatted pol7  CHR(9).
          end.
          else do:
        if Make-Excel then  put   stream ForExcel unformatted       CHR(9).
          end.
          if pol8 <  0 then do:
        if Make-Excel then  put   stream ForExcel unformatted pol8  CHR(9).
          end.
          else do:
        if Make-Excel then  put   stream ForExcel unformatted       CHR(9).
          end.
    end.
    else do:
      if Make-Excel then  put   stream ForExcel unformatted       CHR(9).
        if pol12 <> 0 then do:
      if Make-Excel then  put   stream ForExcel unformatted pol2  CHR(9).
        end.
        else do:
      if Make-Excel then  put   stream ForExcel unformatted       CHR(9).
        end.
      if Make-Excel then  put   stream ForExcel unformatted       CHR(9)
                        CHR(9)
                        CHR(9)
                        CHR(9)
                        CHR(9)
                        CHR(9).
    end.
    display stream PrnLibStream pol2  when pol2  <> o-pol2
                                sym2  when pol2  <> o-pol2
                                sym3  when pol2  <> o-pol2
                                pol9
                                pol10
                                pol11
                                pol12 when pol12 <> 0
                                pol13
                                pol14
                                pol15
    with frame FRAME-2.
    down stream PrnLibStream with frame FRAME-2.
    if Make-Excel then  put   stream ForExcel unformatted pol9  CHR(9)
                pol10 CHR(9)
                pol11 CHR(9).
      if pol12 <> 0 then do:
    if Make-Excel then  put   stream ForExcel unformatted pol12 CHR(9).
      end.
      else do:
    if Make-Excel then  put   stream ForExcel unformatted       CHR(9).
      end.
    if Make-Excel then  put   stream ForExcel unformatted pol13 CHR(9)
                pol14 CHR(9)
                pol15 chr(10).
    if last( tt-zz2.gds-code ) then do:
      put stream PrnLibStream unformatted
        "----------------------------------------------------------------------------------------------------------------------------------------" skip.
    end.
  end.
end.
