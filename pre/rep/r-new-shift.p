block-level on error undo, throw.
define input parameter parparentproc            as widget-handle           no-undo .
define input parameter p-parent-handle          as handle                  no-undo .
define input parameter p-log-handle             as handle                  no-undo .
define input parameter p-cont-handle            as handle                  no-undo .
define input parameter p-call-handle            as handle                  no-undo .
define input parameter p-rebh                   as handle                  no-undo .
define input parameter p-rdbh                   as handle                  no-undo .
define input parameter p-report-id              as character               no-undo .
define input parameter p-xsd-file               as character               no-undo .
define input parameter p-log-file-name          as character               no-undo .
define input parameter p-batch                  as integer                 no-undo .
define input parameter p-codex-id               as integer no-undo .
define input parameter p-ruleset-id             as integer no-undo .
define input parameter p-obj-code               like ub.clients.obj-code   no-undo .
define input parameter p-obj-type               like ub.clients.obj-type   no-undo .
define input parameter p-curr-abbr              like ub.currency.curr-abbr no-undo .
define input parameter p-base-code              like ub.currency.curr-code no-undo .
define input parameter p-line-of-page           as   integer               no-undo .
define input parameter p-weight                 as   logical               no-undo .
define input parameter xClassify                as   character             no-undo .
define input parameter xSortType                as   character             no-undo .
define input parameter xtog-level               as   logical               no-undo .
define input parameter xvar-level               as   integer               no-undo .
define input parameter tog-1                    as   logical               no-undo .
define input parameter tog-2                    as   logical               no-undo .
define input parameter tog-3                    as   logical               no-undo .
define input parameter tog-4                    as   logical               no-undo .
define input parameter tog-5                    as   logical               no-undo .
define input parameter tog-5-1                  as   logical               no-undo .
define input parameter tog-6                    as   logical               no-undo .
define input parameter tog-7                    as   logical               no-undo .
define input parameter tog-81                   as   logical               no-undo .
define input parameter tog-82                   as   logical               no-undo .
define input parameter tog-9                    as   logical               no-undo .
define input parameter tog-10                   as   logical               no-undo .
define input parameter tog-1-pump-one           as   logical               no-undo .
define input parameter tog-1-whole-gds          as   logical               no-undo .
define input parameter tog-1-out-pump-with-icnt as   logical               no-undo .
define input parameter tog-2-cp-grp             as   logical               no-undo .
define input parameter p-plain-txt              as   logical               no-undo .
define input parameter p-xls                    as   logical               no-undo .
define input parameter p-dir-name               as   character             no-undo .
define input-output parameter p-dataseth        as   handle                no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable tempcxml_v-num_ as integer no-undo .
define  temp-table temp-xml-tables no-undo
field order as integer
field tbl-name as character
field tbl-handle_ as handle
field table-handle_ as handle
field uniq-gate-rec as character
field gate-name as character
field gate-handle_ as handle
field is-parent as logical
index pi is unique primary
uniq-gate-rec
tbl-name
index iorder
order
index gr
uniq-gate-rec
index gh
gate-handle_
index iparent
is-parent
.
define  temp-table temp-xml-records no-undo
field tbl-name as character
field uniq-key-rec as character
index pi is unique primary
tbl-name
uniq-key-rec
.
define input parameter table      for temp-xml-tables .
define variable vss-revision    as character no-undo initial "$Revision: eaa8cb55810d, 3483, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: 2023/10/16 15:13:35 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-new-shift.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-new-shift.p $":U .
define variable vss-description as character no-undo initial "сменный отчет":U .
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared stream PrnLibStream.
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function breakstr returns character ( input        for-name    as character,
                                      input        line-length as integer,
                                      input-output line1       as character,
                                      input-output line2       as character ) :
  define variable ii as integer no-undo.
  if length( for-name ) > line-length then do:
    assign ii    = 1
           line1 = "":u
           line2 = "":u.
    if length( entry( ii, for-name , " ":u ) ) > line-length then do:
      assign line1 =       substring( for-name, 1, line-length     )
             line2 = trim( substring( for-name,    line-length + 1 ) ).
    end.                                                     else do:
      do while length( line1 + entry( ii, for-name, " ":u ) ) < ( line-length + 1 ) :
        assign line1 = line1 + entry( ii, for-name, " ":u ) + " ":u
               ii    = ii    + 1.
        if length( entry( ii, for-name, " ":u ) ) > line-length then do:
          assign line1 = line1 + substring( for-name, length( line1 ), line-length - length( line1 ) + 1 ).
        end.
      end.
      assign line2 = trim( substring( for-name, length( line1 ) ) ).
    end.
  end.                                else do:
    assign line1 = for-name
           line2 = "":u.
  end.
  return ( line1 ).
end function.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE NEW SHARED TEMP-TABLE treal-2 no-undo
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE NEW SHARED TEMP-TABLE treal-3 no-undo
FIELD grp-code-sheet as integer
FIELD cpay-code as integer
FIELD curr-code as integer
FIELD qnty1 as decimal
FIELD netto as decimal
FIELD out-name as character format "X(20)"
FIELD is-pay as logical
FIELD ii as integer
FIELD discnt-type   as integer
FIELD brutto as decimal
FIELD discount-sum as decimal
FIELD chk-qnty as int
INDEX pi IS UNIQUE PRIMARY
      grp-code-sheet
      cpay-code
      discnt-type
      curr-code
      is-pay DESCENDING
INDEX vi
      grp-code-sheet
      ii
.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE NEW SHARED TEMP-TABLE treal-4 no-undo
FIELD gds-code as integer
FIELD cpay-code as integer
FIELD curr-code as integer
FIELD qnty1 as decimal
FIELD netto as decimal
FIELD out-name as character format "X(20)"
FIELD is-pay as logical
FIELD discnt-type   as integer
FIELD brutto as decimal
FIELD discount-sum as decimal
FIELD chk-qnty as int
FIELD ii as integer
INDEX pi IS UNIQUE PRIMARY
      gds-code
      cpay-code
          discnt-type
      curr-code
      is-pay DESCENDING
INDEX vi
      gds-code
      ii
.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE NEW SHARED TEMP-TABLE treal-8 no-undo
FIELD gds-code as integer
FIELD cpay-code as integer
FIELD curr-code as integer
FIELD qnty1 as decimal
FIELD netto as decimal
FIELD netto-rubl as decimal
FIELD cli-type as character
FIELD cli-code as integer
INDEX pi IS  unique  primary
gds-code
cpay-code
curr-code
cli-type
cli-code
index  ipay cpay-code curr-code
index icli cli-type cli-code
.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE NEW SHARED TEMP-TABLE t-3 no-undo
FIELD grp-code-sheet like ub.goods.grp-code
FIELD grp-name like ub.gds-grp.node-name format "X(32)"
FIELD serv-name as char
FIELD qnty1-before as decimal FORMAT "->>>>9.99"
FIELD netto-before as decimal FORMAT "->>>>9.99"
FIELD qnty1-after as decimal FORMAT "->>>>9.99"
FIELD netto-after as decimal FORMAT "->>>>9.99"
FIELD lines as integer
INDEX pi IS UNIQUE primary
grp-code-sheet
INDEX gname
grp-name
INDEX sname
serv-name
.
DEFINE NEW SHARED TEMP-TABLE tincome-3 no-undo
FIELD grp-code-sheet as integer
FIELD doc-code  like ub.trn-doc.doc-code
FIELD supp-name like ub.clients.obj-name FORMAT "X(20)"
FIELD supp-type like ub.clients.obj-type
FIELD supp-code like ub.clients.obj-code FORMAT ">>>>>>>>9"
FIELD qnty1-in as decimal FORMAT "->>>>9.99"
FIELD netto-in as decimal FORMAT "->>>>>>>9.99"
FIELD is-fact as logical
FIELD ii as integer
INDEX pi IS UNIQUE PRIMARY
      grp-code-sheet
      doc-code
INDEX vi IS UNIQUE
      grp-code-sheet
      ii
.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-waitfram-action01         as character   no-undo .
define variable v-waitfram-action02         as character   no-undo .
define variable v-waitfram-action03         as character   no-undo .
define variable mWaitFramTextBeg            as character   no-undo.
define variable mWaitFramTextEnd            as character   no-undo.
define variable mWaitFramView               as logical     no-undo.
define variable mWaitProcEvent              as logical     no-undo init yes.
define variable mWaitFramInterval           as integer     no-undo init 1 .
define variable mWaitFramStop               as logical     no-undo.
define variable mWaitFramStopUser           as logical     no-undo.
define variable mWaitFramStopTimeOut        as logical     no-undo.
define variable mWaitFramStartProc          as datetime-tz no-undo.
define variable mWaitFramTimeOut            as decimal     no-undo init ?.
define button B-WaitFramStop auto-end-key
     label "Стоп"
     size 10 by 1 tooltip "Остоновить процесс".
define button B-viewProcInfo
     label "Информация"
     size 15 by 1 tooltip "Информация о процесс".
define frame waitfram
  v-waitfram-action01 format "x(72)" no-label skip
  v-waitfram-action02 format "x(72)" no-label skip
  v-waitfram-action03 format "x(72)" no-label skip
  B-viewProcInfo
  B-WaitFramStop at row 4 col 30
  with view-as dialog-box side-labels three-d cancel-button B-WaitFramStop
  .
define new global shared variable mBatchMode as logical no-undo init ?.
define variable mFramBachModHandle as handle no-undo.
mFramBachModHandle = frame waitfram:handle.
define variable mFameOldVis as logical no-undo.
define variable mVisCUrentVin as logical no-undo.
if session:batch-mode
then
   mBatchMode = yes.
if mBatchMode = ? then do:
  mVisCUrentVin = current-window:visible.
  mFameOldVis = mFramBachModHandle:visible.
  mFramBachModHandle:visible  = yes.
  mBatchMode = mFramBachModHandle:visible ne yes.
  mFramBachModHandle:visible = mFameOldVis.
  current-window:visible = mVisCUrentVin.
end.
 if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramBachModHandle:visible), "frameRepError").
  end.
on choose of B-WaitFramStop in frame waitfram
do:
  mWaitFramStop = yes.
  mWaitFramStopUser = yes.
end.
function waitfram-check-timeout returns logical():
   define variable vtime as int64 no-undo.
   if mWaitFramStopTimeOut
   then
      return yes.
   vtime = ( now - mWaitFramStartProc ) / 1000 .
   if     mWaitFramTimeOut ne ?
      and mWaitFramTimeOut ne 0
      and mWaitFramTimeOut lt vtime
   then do:
      mWaitFramStopTimeOut = yes.
   end.
   return mWaitFramStopTimeOut.
end.
procedure waitfram-hide :
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    pause 0 before-hide .
    if not mBatchMode then
      hide frame waitfram .
  if     not mWaitFramView
     and mWaitProcEvent
  then
    process events .
  end.
end procedure.
procedure waitfram-show :
  define input  parameter p-message as character no-undo .
  define variable v-left-margin as integer   no-undo .
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    if length(p-message) <= 70 then do:
      assign
        v-left-margin = integer((70 - length(p-message)) / 2)
      .
      assign
        v-left-margin = max(0, v-left-margin - (v-left-margin mod 5))
      .
      assign
        v-waitfram-action01 = " "
        v-waitfram-action02 = " "
                                 + fill(" ", v-left-margin)
                                 + p-message
        v-waitfram-action03 = " "
      .
    end.
    else do:
      define variable vRindex1 as integer no-undo.
      define variable vRindex2 as integer no-undo.
      vRindex1 = r-index(p-message," ",70).
      if vRindex1 = 0
      then
         vRindex1 = 70.
      if length(p-message)  <= vRindex1 + 70 then do:
        assign
          v-waitfram-action01 = " "
          v-waitfram-action02 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action03 = " " + substring(p-message,  vRindex1 + 1, 70      )
        .
      end.
      else do:
        vRindex2 = r-index(p-message," ",vRindex1 + 70).
        if vRindex2 <= vRindex1
        then
           vRindex2 = vRindex1 + 70.
        assign
          v-waitfram-action01 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action02 = " " + substring(p-message,  vRindex1 + 1, vRindex2 - vRindex1 )
          v-waitfram-action03 = " " + substring(p-message,  vRindex2 + 1, 70)
        .
      end.
    end.
    B-viewProcInfo:visible   in frame waitfram = no.
    B-viewProcInfo:sensitive in frame waitfram = no.
    B-WaitFramStop:visible   in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    B-WaitFramStop:sensitive in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    if  (   mWaitFramView
       or  mWaitProcEvent)
       and not mBatchMode
    then
       display
          v-waitfram-action01 skip
          v-waitfram-action02 skip
          v-waitfram-action03 skip
       with frame waitfram .
    if     mWaitFramView
       then do:
          if     mWaitFramInterval ne ?
             and not mBatchMode
          then
             wait-for go of frame waitfram pause mWaitFramInterval.
       end.
       else
          if     mWaitProcEvent
             and not mBatchMode
          then
             process events .
  end.
end procedure.
   procedure waitfram-show-this:
      define input  parameter iInterval as int64 no-undo.
      define variable vtime as int64 no-undo.
      vtime = ( now - mWaitFramStartProc  ) / 1000 .
      mWaitFramInterval = iInterval.
      run waitfram-show (substitute("&1&2 &3&4" ,
                                    mWaitFramTextBeg ,
                                    if vtime eq ? then "" else substitute (" Прошло: &1 сек" , string( vtime)),
                                    if mWaitFramTimeOut ne 0 and mWaitFramTimeOut ne ? then " из " + string(mWaitFramTimeOut) + " сек. " else "",
                                    mWaitFramTextEnd
                                   )
                        ).
   end.
   procedure WaitFramRunPause:
      define input  parameter iInterval as dec no-undo.
      define variable vStart  as datetime-tz no-undo.
      define variable vend    as datetime-tz no-undo.
      define variable vint as int64 no-undo.
      define variable vOk as logical no-undo.
      vStart = now.
      vend   = vStart.
      publish "WaitFramPause" (iInterval,output vOk).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and (   vint > 0
              or (    not vOk
                  and iInterval eq ?
                  )
              )
      then
         run waitfram-show-this (iInterval).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and vint > 0
      then do:
         run gbl/pause.p (vint * 1000).
      end.
      if iInterval ne ?
      then
         publish "WaitFramStop".
      waitfram-check-timeout().
   end.
   procedure WaitFramWaitFor:
      define input  parameter iInterval as dec no-undo.
      assign
         mWaitFramStartProc   = now
         mWaitFramStopUser    = no
         mWaitFramStopTimeOut = no
      .
      block-wait:
      do while not mWaitFramStop:
         run WaitFramRunPause (iInterval).
         if  waitfram-check-timeout()
         then do:
            leave block-wait.
         end.
      end.
      run waitfram-hide.
   end.
procedure waitfram-join :
  define input  parameter p-line-1  as character no-undo .
  define input  parameter p-line-2  as character no-undo .
  define input  parameter p-line-3  as character no-undo .
  define output parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-message = substring(p-line-1 + fill(' ', 70), 1, 70)
                + substring(p-line-2 + fill(' ', 70), 1, 70)
                + substring(p-line-3 + fill(' ', 70), 1, 70)
    .
  end.
end procedure.
function waitfram-join-function returns character
  (input p-line-1 as character
  ,input p-line-2 as character
  ,input p-line-3 as character
  ).
  define variable v-message as character no-undo .
  run waitfram-join in this-procedure
    (input  p-line-1
    ,input  p-line-2
    ,input  p-line-3
    ,output v-message
    ) .
  return v-message .
end function .
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table report-headert no-undo
field datetimeStart as datetime
field datetimeEnd as datetime
field report-name as character
field report-label as character
field report-id as character
field report-db-num as integer
field task-num as integer
index pi is unique primary
report-id
.
define  temp-table report-parameterst no-undo
field report-id as character
field parameter-name as character
field parameter-label as character
field parameter-value-type as character
field parameter-value as character
field parameter-index as integer
field parameter-des as character
index pi is unique primary
report-id
parameter-name
parameter-index
.
define  temp-table report-errorst no-undo
field report-id as character
field ErrNum as integer
field ErrCode as integer
field ErrSeverity as integer
field ErrMessage as character
index pi is unique primary
report-id
ErrNum.
define  temp-table report-destinationt no-undo
field report-id as character
field destination-id as character
field destination as character
field destination-details as character
index pi is unique primary
report-id
destination-id.
define new shared temp-table shiftt no-undo
field obj-type as character
field obj-code as integer
field obj-name as character
field obj-address as character
field obj-phone as character
field db-num as integer
field shift-date as date
field shift-num as integer
field shift-name as character
field base-code as integer
field curr-abbr as character
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
.
define new shared  temp-table shift-pgdst no-undo
field obj-type as character
field obj-code as integer
field shift-date as date
field shift-num as integer
field gds-code as integer
field gds-name as character
field start-state-qnty as decimal
field start-system-qnty as decimal
field start-state-qnty-2 as decimal
field start-system-qnty-2 as decimal
field end-state-qnty as decimal
field end-system-qnty as decimal
field end-state-qnty-2 as decimal
field end-system-qnty-2 as decimal
field in-qnty as decimal
field in-qnty-2 as decimal
field icnt-out-qnty as decimal
field end-price-sale as decimal
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
gds-code
.
define new shared  temp-table shift-pgds-int no-undo
field obj-type as character
field obj-code as integer
field shift-date as date
field shift-num as integer
field gds-code as integer
field doc-code as character
field cli-type-code as character
field cli-name as character
field fact-qnty as decimal
field fact-qnty-2 as decimal
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
gds-code
doc-code
.
define new shared  temp-table shift-pgds-outt no-undo
field obj-type as character
field obj-code as integer
field shift-date as date
field shift-num as integer
field gds-code as integer
field pay-code as integer
field curr-code as integer
field cp-type as integer
field out-name as character
field fact-qnty as decimal
field fact-qnty-2 as decimal
field fact-sum as decimal
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
gds-code
pay-code
curr-code
.
define new shared temp-table shift-grpt no-undo
field obj-type as character
field obj-code as integer
field shift-date as date
field shift-num as integer
field grp-code as integer
field full-grp-name as character
field start-qnty as decimal
field start-sum as decimal
field end-qnty as decimal
field end-sum as decimal
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
grp-code
.
define new shared temp-table shift-grp-int no-undo
field obj-type as character
field obj-code as integer
field shift-date as date
field shift-num as integer
field grp-code as integer
field doc-code as character
field cli-type-code as character
field cli-name as character
field fact-qnty as decimal
field fact-cost-sum as decimal
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
grp-code
doc-code
.
define new shared temp-table shift-grp-outt no-undo
field obj-type as character
field obj-code as integer
field shift-date as date
field shift-num as integer
field grp-code as integer
field pay-code as integer
field curr-code as integer
field cp-type as integer
field out-name as character
field fact-qnty as decimal
field fact-sum as decimal
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
grp-code
pay-code
curr-code
.
define dataset shift-1t
for shiftt, shift-pgdst, shift-pgds-int, shift-pgds-outt, shift-grpt, shift-grp-int, shift-grp-outt,
report-headert, report-parameterst, report-errorst
data-relation r1 for shiftt, shift-pgdst
relation-fields (obj-type, obj-type, obj-code, obj-code, shift-date, shift-date, shift-num, shift-num) nested
data-relation r2 for shiftt, shift-grpt
relation-fields (obj-type, obj-type, obj-code, obj-code, shift-date, shift-date, shift-num, shift-num) nested
data-relation r11 for shift-pgdst, shift-pgds-outt
relation-fields (obj-type, obj-type, obj-code, obj-code, shift-date, shift-date, shift-num, shift-num, gds-code, gds-code) nested
data-relation r12 for shift-pgdst, shift-pgds-int
relation-fields (obj-type, obj-type, obj-code, obj-code, shift-date, shift-date, shift-num, shift-num, gds-code, gds-code) nested
data-relation r21 for shift-grpt, shift-grp-outt
relation-fields (obj-type, obj-type, obj-code, obj-code, shift-date, shift-date, shift-num, shift-num, grp-code, grp-code) nested
data-relation r22 for shift-grpt, shift-grp-int
relation-fields (obj-type, obj-type, obj-code, obj-code, shift-date, shift-date, shift-num, shift-num, grp-code, grp-code) nested
data-relation rh1 for report-headert, report-parameterst
relation-fields (report-id, report-id) nested
data-relation rh2 for report-headert, report-errorst
relation-fields (report-id, report-id) nested
.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info26 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info26, p-tbl-name ).
    end.
    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info26, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info26, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
        .
      end.
    end.
    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info26, p-tbl-name ).
    end.
  end.
  return.
end procedure.
procedure gen-where-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character  no-undo.
  define input  parameter p-key-rec    as character  no-undo.
  define input  parameter p-key-handle as handle     no-undo .
  define input  parameter p-db-name    as character  no-undo .
  define input  parameter p-tt-handle  as handle     no-undo .
  define output parameter o-Where      as character  no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable vTable           as character no-undo.
    define variable bh_tbl-key       as handle    no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do:
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info26 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info26, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info26 ).
      end.
    end.
    assign
      vTable = entry( 1 , p-key-rec, chr(3) )
    .
    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info26, vTable, chr(10) ).
    end.
    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info26, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info26, v-inform, vTable ).
    end.
    assign
      o-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    if i-tablekey ne "" and i-tablekey ne ?
    then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tablekey )
      .
      create buffer bh_tbl-key for table v-full-tbl-name .
    end.
    if i-tableSerach ne "" and i-tableSerach ne ?
    then do:
      delete object bh_tbl-name no-error.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.
      define variable VfieldKeyTable as handle no-undo.
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
      if     bh_tbl-key ne ?
      then do:
         VfieldKeyTable = bh_tbl-key:buffer-field( v-field-name ) no-error.
         if VfieldKeyTable eq ?
         then next block_where.
      end.
      if v-full-tbl-name ne "" and v-full-tbl-name ne ?
      then
         o-where = substitute( "&1 &2 &3.&4 =", o-where, v-word-link,v-full-tbl-name, v-field-name ).
      else
         o-where = substitute( "&1 &2 &3 =", o-where, v-word-link, v-field-name ).
      if p-key-handle = ? then do:
        assign
          v-field-val = replace (entry( v-count-fld + 1 , p-key-rec, chr(3) ),chr(2) + chr(9) + chr (2),chr(3))
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          delete object bh_tbl-name.
          if     bh_tbl-key ne ?
          then
             delete object bh_tbl-key.
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info26, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.
      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        o-where = substitute( "&1 &2", o-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    delete object bh_tbl-name.
    if     bh_tbl-key ne ?
    then
       delete object bh_tbl-key.
    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info26, vTable ).
    end.
  end.
end procedure.
procedure gen-hn-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character no-undo.
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  define variable v-full-tbl-name as character no-undo.
  define variable v-where         as character no-undo.
  define variable bh_tbl-name     as handle    no-undo.
  define variable vTable          as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile ):
      run gen-where-keyr-tab(i-tableSerach,
                             i-tablekey,
                             p-key-rec,
                             p-key-handle,
                             p-db-name,
                             p-tt-handle,
                             output v-where).
      if i-tableSerach ne "" and i-tableSerach ne ?
      then do:
         v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach ).
         create buffer bh_tbl-name for table v-full-tbl-name .
      end.
      else do:
         if p-tt-handle = ? then do:
            assign
               vTable = entry( 1 , p-key-rec, chr(3) )
            .
            v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable ).
            create buffer bh_tbl-name for table v-full-tbl-name .
         end.
         else do:
            create buffer bh_tbl-name for table p-tt-handle:table-handle .
         end.
      end.
      if p-tt-handle = ? then do:
         bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
      end.
      else do:
         bh_tbl-name:find-first( v-where ) no-error .
      end.
      o-hn = bh_tbl-name.
   end.
end procedure.
procedure gen-hn-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output o-hn).
end.
procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  define variable vHn as handle no-undo.
    run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output vHn).
    p-tbl-row = if vHn:available then vHn:rowid else ?.
    p-tbl-name =  vHn:table.
    delete object vHn no-error.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info26, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure.
procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info26 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info26 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info26, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info26, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info26, v-tbl-name ).
    end.
  end.
end procedure.
procedure gen-key-field :
  define input  parameter p-table      as character no-undo .
  define output parameter p-field-list as character no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-table = ?
      or p-table = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info26 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info26 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info26, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info26, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      v-delim-key  = "":U
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U ).
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
  end.
end procedure.
procedure get-gate-file-name :
define input parameter p-gate-rec as character no-undo .
define output  parameter p-gate-file-name as character no-undo .
define buffer buf_clob-data for ub.clob-data.
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
run gen-row-keyr in this-procedure ( input p-gate-rec
                                    ,input ?
                                    ,input "ub"
                                    ,input ?
                                    ,input no-lock
                                    ,output v-tbl-row
                                    ,output v-tbl-name) no-error.
if error-status:error then undo, return error substitute("&1 (get-gate-name) Несуществующий gate &2"
                                                        ,vss-include-info24
                                                        ,p-gate-rec).
find first buf_clob-data no-lock where
          rowid(buf_clob-data) = v-tbl-row no-error.
if not available buf_clob-data then do:
  if error-status:error then undo, return error substitute("&1 (get-gate-name) Несуществующий gate &2"
                                                          ,vss-include-info24
                                                          ,p-gate-rec).
end.
p-gate-file-name = buf_clob-data.file-name.
end procedure.
procedure get-gate-rec :
define input  parameter p-gate-name as character no-undo .
define output parameter p-gate-rec as character no-undo .
define buffer buf_clob-bind for ub.clob-bind.
define buffer buf_clob-data for ub.clob-data.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info24, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info24 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info24 )
:
    find first buf_clob-bind no-lock where
              buf_clob-bind.uniq-key-rec = p-gate-name
          and buf_clob-bind.field-name = '':U
          and buf_clob-bind.part-num = 1
          and buf_clob-bind.resource-type = 'gate':U
          no-error.
    if not available buf_clob-bind then do:
      undo, return error substitute("Неверная ссылка на XSD -файл &1 для gate"
                                      , p-gate-name
                                      ).
    end.
    find first buf_clob-data no-lock where
              buf_clob-data.db-num = buf_clob-bind.db-num
          and buf_clob-data.int64-i= buf_clob-bind.int64-id no-error.
    if not available buf_clob-data then do:
      undo, return error substitute("Не найден CLOB c ДБ &1 id &2 - файл &3"
                                      , buf_clob-bind.db-num
                                      , buf_clob-bind.int64-id
                                      , p-gate-name
                                      ).
    end.
    run gen-key-rec in this-procedure ( input 'clob-data':U
                              ,input buffer buf_clob-data:handle
                              ,output p-gate-rec).
end.
end procedure.
procedure get-gate-by-name :
define input  parameter p-gate-name as character no-undo .
define output parameter p-gate-rec as character no-undo .
define output parameter p-dsh as handle no-undo .
define input-output  parameter p-xmlh as handle no-undo .
define variable v-ii as integer   no-undo .
define variable glog as logical   no-undo .
define variable v-longchar as longchar no-undo .
define variable v-txmlh as handle no-undo .
define variable v-db-num as integer no-undo .
define variable v-int64-id as int64 no-undo .
define buffer buf_clob-bind for ub.clob-bind.
define buffer buf_clob-data for ub.clob-data.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info24, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info24 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info24 )
:
    find first buf_clob-bind no-lock where
              buf_clob-bind.uniq-key-rec = p-gate-name
          and buf_clob-bind.field-name = '':U
          and buf_clob-bind.part-num = 1
          and buf_clob-bind.resource-type = 'gate':U
          no-error.
    if not available buf_clob-bind then do:
      undo, return error substitute("Неверная ссылка на XSD -файл &1 для gate"
                                      , p-gate-name
                                      ).
    end.
    find first buf_clob-data no-lock where
              buf_clob-data.db-num = buf_clob-bind.db-num
          and buf_clob-data.int64-i= buf_clob-bind.int64-id no-error.
    if not available buf_clob-data then do:
      undo, return error substitute("Не найден CLOB c ДБ &1 id &2 - файл &3"
                                      , buf_clob-bind.db-num
                                      , buf_clob-bind.int64-id
                                      , p-gate-name
                                      ).
    end.
    assign
    v-longchar = buf_clob-data.cdata
    .
    run fix-schemalocation in this-procedure ( input-output v-longchar) no-error.
    if error-status :error then do:
      undo, return error substitute("Не удалось определить расположение составных частей схемы &1 (&2) из БД&3&4&3&5", p-gate-rec, buf_clob-data.file-name_, chr(10), error-status:get-message(1) , return-value ).
    end.
    create dataset p-dsh .
    glog = p-dsh:READ-XMLSCHEMA( "LONGCHAR"
                                  , v-longchar
                                  , ?
                                  , ?
                                  , ?
                                  ) no-error.
    v-longchar = '':U.
    if error-status :error
    or not glog
    then do:
      undo, return error substitute("Не удалось прочитать XML-схему &1 из БД:&2&3", p-gate-name, chr(10), error-status:get-message(1) ).
    end.
    if not valid-handle(p-xmlh)
    or not valid-handle(p-xmlh:buffer-field("tbl-name")) then do:
      create temp-table v-txmlh.
      v-txmlh:create-like(buffer temp-xml-tables:handle).
      v-txmlh:temp-table-prepare("temp-xml-tables").
      p-xmlh = v-txmlh:default-buffer-handle.
    end.
    run gen-key-rec in this-procedure ( input 'clob-data':U
                              ,input buffer buf_clob-data:handle
                              ,output p-gate-rec).
    do v-ii = 1 to p-dsh:num-buffers:
      p-xmlh:find-first(substitute(' where tbl-name = "&1"', p-dsh:get-buffer-handle(v-ii):name)) no-error.
      if not p-xmlh:available then do:
        p-xmlh:buffer-create().
        assign
        p-xmlh::tbl-name = p-dsh:get-buffer-handle(v-ii):name
        p-xmlh::tbl-handle_ = p-dsh:get-buffer-handle(v-ii)
        p-xmlh::table-handle_ = p-dsh:get-buffer-handle(v-ii):table-handle
        p-xmlh::gate-handle_ = p-dsh
        p-xmlh::uniq-gate-rec = p-gate-rec
        p-xmlh::gate-name = p-dsh:name
        p-xmlh::is-parent = not valid-handle(p-dsh:get-buffer-handle(v-ii):parent-relation)
        .
        if lookup(p-xmlh::tbl-name, "thheader,header_") > 0 then do:
          assign
          p-xmlh::order = -3.
        end.
      end.
    end.
end.
end procedure.
procedure get-gate-by-rec :
define input  parameter p-gate-rec as character no-undo .
define output parameter p-dsh as handle no-undo .
define input-output  parameter p-xmlh as handle no-undo .
define input-output parameter p-longchar  as longchar no-undo .
define variable v-ii as integer   no-undo .
define variable glog as logical   no-undo .
define variable v-rowid as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-longchar as longchar no-undo .
define variable v-txmlh as handle no-undo .
define buffer buf_clob-data for ub.clob-data.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info24, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info24 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info24 )
:
  run gen-row-keyr in this-procedure (
                                        input  p-gate-rec
                                        ,input  ?
                                        ,input  "ub"
                                        ,input  ?
                                        ,input  NO-LOCK
                                        ,output v-rowid
                                        ,output v-tbl-name   ) no-error.
    find first buf_clob-data no-lock where
              rowid(buf_clob-data) = v-rowid  no-error.
    if not available buf_clob-data then do:
      undo, return error substitute("Не найден CLOB  &1"
                                      , p-gate-rec
                                      ).
    end.
    assign
    v-longchar = buf_clob-data.cdata
    .
    run fix-schemalocation in this-procedure ( input-output v-longchar) no-error.
    if error-status :error then do:
      undo, return error substitute("Не удалось определить расположение составных частей схемы &1 (&2) из БД&3&4&3&5", p-gate-rec, buf_clob-data.file-name_, chr(10), error-status:get-message(1) , return-value ).
    end.
    create dataset p-dsh .
    glog = p-dsh:READ-XMLSCHEMA( "LONGCHAR"
                                  , v-longchar
                                  , ?
                                  , ?
                                  , ?
                                  ) no-error.
    define variable v-esm as character no-undo .
    v-esm = error-status:get-message(1) .
    if p-longchar <> ? then do:
      p-longchar = v-longchar.
    end.
    v-longchar = '':U.
    if error-status :error
    or not glog
    then do:
      undo, return error substitute("Не удалось прочитать XML-схему &1 (&2) из БД&3&4"
                                   , p-gate-rec
                                   , p-gate-rec
                                   , v-esm
                                   ).
    end.
    p-dsh:private-data = buf_clob-data.file-name_ + chr(4) + p-gate-rec.
    if not valid-handle(p-xmlh)
    or not valid-handle(p-xmlh:buffer-field("tbl-name")) then do:
      create temp-table v-txmlh.
      v-txmlh:create-like(buffer temp-xml-tables:handle).
      v-txmlh:temp-table-prepare("temp-xml-tables").
      p-xmlh = v-txmlh:default-buffer-handle.
    end.
    do v-ii = 1 to p-dsh:num-buffers:
      p-xmlh:find-first(substitute(' where tbl-name = "&1"', p-dsh:get-buffer-handle(v-ii):name)) no-error.
      if not p-xmlh:available then do:
        p-xmlh:buffer-create().
        assign
        p-xmlh::tbl-name = p-dsh:get-buffer-handle(v-ii):name
        p-xmlh::tbl-handle_ = p-dsh:get-buffer-handle(v-ii)
        p-xmlh::table-handle_ = p-dsh:get-buffer-handle(v-ii):table-handle
        p-xmlh::gate-handle_ = p-dsh
        p-xmlh::uniq-gate-rec = p-gate-rec
        p-xmlh::gate-name = p-dsh:name
        p-xmlh::is-parent = not valid-handle(p-dsh:get-buffer-handle(v-ii):parent-relation)
        .
        if lookup(p-xmlh::tbl-name, "thheader,header_") > 0 then do:
          assign
          p-xmlh::order = -3.
        end.
        p-xmlh:buffer-release().
      end.
    end.
end.
end procedure.
procedure get-gate-by-file :
define input  parameter p-schema-file-name as character no-undo .
define input  parameter p-gate-rec as character no-undo .
define output parameter p-dsh as handle no-undo .
define input-output  parameter p-xmlh as handle no-undo .
define variable v-ii as integer   no-undo .
define variable glog as logical   no-undo .
define variable v-rowid as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-longchar as longchar no-undo .
define variable v-txmlh as handle no-undo .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info24, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info24 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info24 )
:
    COPY-LOB
    FROM  FILE p-schema-file-name
    TO  OBJECT v-longchar
    no-convert
    NO-ERROR .
    if error-status :error then do:
        undo, return error substitute("Не удалось считать файл схемы &1 в память&2&3"
                                  , p-schema-file-name
                              , chr(10)
                              , error-status:get-message(1) ).
    end.
    run fix-schemalocation in this-procedure ( input-output v-longchar) no-error.
    if error-status :error then do:
      undo, return error substitute("Не удалось определить расположение составных частей схемы &1 (&2) из БД&3&4&3&5", p-gate-rec, p-schema-file-name, chr(10), error-status:get-message(1) , return-value ).
    end.
    create dataset p-dsh .
    glog = p-dsh:READ-XMLSCHEMA( "longchar"
                                  , v-longchar
                                  , ?
                                  , ?
                                  , ?
                                  ) no-error.
    v-longchar = ''.
    if error-status :error
    or not glog
    then do:
      undo, return error substitute("Не удалось прочитать XML-схему из файла &1&2&3"
                                   , p-schema-file-name
                                   ,chr(10)
                                   , error-status:get-message(1)
                                   ).
    end.
    if not valid-handle(p-xmlh)
    or not valid-handle(p-xmlh:buffer-field("tbl-name")) then do:
      create temp-table v-txmlh.
      v-txmlh:create-like(buffer temp-xml-tables:handle).
      v-txmlh:temp-table-prepare("temp-xml-tables").
      p-xmlh = v-txmlh:default-buffer-handle.
    end.
    do v-ii = 1 to p-dsh:num-buffers:
      p-xmlh:find-first(substitute(' where tbl-name = "&1" and  uniq-gate-rec = "&2" '
                                   ,p-dsh:get-buffer-handle(v-ii):name
                                   ,p-gate-rec
                                   )) no-error.
      if not p-xmlh:available then do:
        p-xmlh:buffer-create().
        assign
        p-xmlh::tbl-name = p-dsh:get-buffer-handle(v-ii):table
        p-xmlh::uniq-gate-rec = p-gate-rec
        p-xmlh::tbl-handle_ = p-dsh:get-buffer-handle(v-ii)
        p-xmlh::table-handle_ = p-dsh:get-buffer-handle(v-ii):table-handle
        p-xmlh::gate-handle_ = p-dsh
        p-xmlh::gate-name = p-dsh:name
        p-xmlh::is-parent = not valid-handle(p-dsh:get-buffer-handle(v-ii):parent-relation)
        .
        if lookup(p-xmlh::tbl-name, "thheader,header_") > 0 then do:
          assign
          p-xmlh::order = -3.
        end.
        p-xmlh:buffer-release().
      end.
    end.
end.
end procedure.
procedure gate-clear :
define input  parameter p-dsh as handle no-undo .
define input  parameter p-xmlh as handle no-undo .
define variable v-dsh as handle no-undo .
define variable v-th as handle no-undo .
  do
  on error undo, return error return-value
  :
    if valid-handle(p-dsh) then do:
      delete object p-dsh.
      v-dsh = p-dsh.
      p-dsh = ?.
    end.
    repeat while true:
      p-xmlh:find-first( substitute( " where gate-handle_ = &1 ", v-dsh)
                         , share-lock) no-error.
      if p-xmlh:available then do:
        assign
        v-th = p-xmlh:buffer-field("table-handle_"):buffer-value.
        if valid-handle(p-xmlh:buffer-field("table-handle_"))
        and valid-handle(v-th)
        and v-th:dynamic = yes
        then do:
          delete object p-xmlh:buffer-field("table-handle_"):buffer-value.
          p-xmlh:buffer-field("table-handle_"):buffer-value = ?.
        end.
        p-xmlh:buffer-delete().
      end.
      else do:
        leave.
      end.
    end.
    if p-xmlh:dynamic = yes
    and valid-handle(p-xmlh)
    then do:
      delete object p-xmlh:table-handle.
      p-xmlh = ?.
    end.
    v-dsh = ?.
  end.
end procedure.
procedure all-gates-clear :
define parameter buffer buf_temp-xml-tables for temp-xml-tables.
do
on error undo, return error
:
  for each buf_temp-xml-tables
  break
  by buf_temp-xml-tables.uniq-gate-rec
  on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-workfile )
  on endkey undo , return error substitute( "&1. endkey", vss-workfile )
  :
      if first-of(buf_temp-xml-tables.uniq-gate-rec) then do:
        delete object buf_temp-xml-tables.gate-handle_.
        buf_temp-xml-tables.gate-handle_ = ?.
      end.
      if valid-handle(buf_temp-xml-tables.table-handle_)
      and buf_temp-xml-tables.table-handle_:dynamic = no
      then do:
        delete object buf_temp-xml-tables.table-handle_.
        buf_temp-xml-tables.table-handle_ = ?.
      end.
      delete buf_temp-xml-tables.
  end.
end.
end procedure.
procedure fix-schemalocation :
define input-output  parameter p-longchar as longchar no-undo .
DEFINE VARIABLE hdoc AS HANDLE.
DEFINE VARIABLE hroot AS HANDLE.
DEFINE VARIABLE hnode-child AS HANDLE.
DEFINE VARIABLE hnode-attr AS HANDLE.
define variable v-jj as integer   no-undo .
define variable ok as logical   no-undo .
define variable v-path1                    as character                no-undo .
DEFINE VARIABLE v-full-path1               as character                no-undo .
DEFINE VARIABLE v-file-name1               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext1        as character                no-undo .
DEFINE VARIABLE v-file-name-ext1           as character                no-undo .
define variable v-schema-location          as character                no-undo .
do
on error undo, return error return-value
:
  CREATE X-DOCUMENT hdoc.
  CREATE X-noderef hroot.
  CREATE X-noderef hnode-child.
  CREATE X-noderef hnode-attr.
  hdoc:load("longchar", p-longchar, no) no-error.
  iF ERROR-STATUS:GET-MESSAGE(1) <> '' THEN message ERROR-STATUS:GET-MESSAGE(1) view-as alert-box .
  hdoc:get-document-element(hroot).
  _repeat:
  REPEAT v-jj = 1 TO hroot:NUM-CHILDREN:
    ok = hroot:GET-CHILD(hNode-Child, v-jj).
    if not ok then next.
    if hNode-Child:local-name = "include"
    then do:
      ok = hNode-Child:GET-ATTRIBUTE-NODE( hnode-attr, "schemaLocation" ).
        v-schema-location = hnode-attr:node-value.
        run gbl/filename.p (
                        input "exe/" + hnode-attr:node-value
                      ,output v-full-path1
                      ,output v-path1
                      ,output v-file-name1
                      ,output v-file-name-no-ext1
                      ,output v-file-name-ext1
                      ) no-error .
        if error-status :error then do:
          delete object hnode-attr.
          delete object hnode-child.
          delete object hroot.
          delete object hdoc.
          undo, return error substitute("Не удалось определить расположение схемы &1", v-schema-location).
        end.
      ok = hNode-Child:sET-ATTRIBUTE(  "schemaLocation", v-full-path1 ).
      leave  _repeat.
    end.
  END.
  hdoc:save("longchar", p-longchar).
  delete object hnode-attr.
  delete object hnode-child.
  delete object hroot.
  delete object hdoc.
end.
end procedure.
procedure gate-clb_fill-xml-tables :
define input parameter p-dsh as handle no-undo .
define input-output parameter p-xmlh as handle no-undo .
define variable v-ii as integer no-undo .
  do
  on error undo, return error
  :
    do v-ii = 1 to p-dsh:num-buffers:
      p-xmlh:find-first(substitute(' where tbl-name = "&1"', p-dsh:get-buffer-handle(v-ii):name)) no-error.
      if not p-xmlh:available then do:
        p-xmlh:buffer-create().
        assign
        p-xmlh::tbl-name = p-dsh:get-buffer-handle(v-ii):name
        p-xmlh::tbl-handle_ = p-dsh:get-buffer-handle(v-ii)
        p-xmlh::table-handle_ = p-dsh:get-buffer-handle(v-ii):table-handle
        p-xmlh::gate-handle_ = p-dsh
        p-xmlh::uniq-gate-rec = entry(2, p-dsh:private-data, chr(4))
        p-xmlh::gate-name = p-dsh:name
        p-xmlh::is-parent = not valid-handle(p-dsh:get-buffer-handle(v-ii):parent-relation)
        .
        if lookup(p-xmlh::tbl-name, "thheader,header_") > 0 then do:
          assign
          p-xmlh::order = -3.
        end.
        p-xmlh:buffer-release().
      end.
    end.
  end.
end procedure.
procedure all-gates-empty :
define buffer buf_temp-xml-tables for temp-xml-tables.
do
on error undo, return error
:
  for each buf_temp-xml-tables
  break
  by buf_temp-xml-tables.uniq-gate-rec
  on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-workfile )
  on endkey undo , return error substitute( "&1. endkey", vss-workfile )
  :
    if valid-handle(buf_temp-xml-tables.tbl-handle_) then do:
      buf_temp-xml-tables.tbl-handle_:empty-temp-table().
    end.
  end.
end.
end procedure.
define variable vss-include-info27 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable v-fmtcli-name          as character    no-undo.
define variable v-fmtcli-engl-name     as character    no-undo.
define variable v-fmtcli-addres        as character    no-undo.
define variable v-fmtcli-post-addres   as character    no-undo.
define variable v-fmtcli-full-addres   as character    no-undo.
define variable v-fmtcli-phone         as character    no-undo.
define variable v-fmtcli-inn           as character    no-undo.
define variable v-fmtcli-kpp           as character    no-undo.
define variable v-fmtcli-okpo          as character    no-undo.
define variable v-fmtcli-country       as character    no-undo.
define variable v-fmtcli-city          as character    no-undo.
define variable v-fmtcli-index         as character    no-undo.
define variable v-fmtcli-schet-exists  as logical      no-undo.
define variable v-fmtcli-bank-exists   as logical      no-undo.
define variable v-fmtcli-bank-r-schet  as character    no-undo.
define variable v-fmtcli-bank-c-schet  as character    no-undo.
define variable v-fmtcli-bank-bik      as character    no-undo.
define variable v-fmtcli-bank-name     as character    no-undo.
define variable v-fmtcli-bank-addres   as character    no-undo.
define variable v-fmtcli-bank-city     as character    no-undo.
procedure fmtcli-get-bank :
define input parameter p-host-code      as integer          no-undo.
define input parameter p-obj-type       as character        no-undo.
define input parameter p-obj-code       as integer          no-undo.
define input parameter p-curr-code      as integer          no-undo.
    define buffer buf_fin-schet     for ub.fin-schet.
    define buffer buf_fin-bank      for ub.fin-bank.
do
for buf_fin-schet
  , buf_fin-bank
on error undo, return error
:
    assign
        v-fmtcli-schet-exists       = no
        v-fmtcli-bank-exists        = no
        v-fmtcli-bank-r-schet       = "":U
        v-fmtcli-bank-c-schet       = "":U
        v-fmtcli-bank-bik           = "":U
        v-fmtcli-bank-name          = "":U
        v-fmtcli-bank-addres        = "":U
        v-fmtcli-bank-city          = "":U
    .
    search-for-schet:
    for each buf_fin-schet no-lock
       where buf_fin-schet.host-code = p-host-code
         and buf_fin-schet.cli-type  = p-obj-type
         and buf_fin-schet.cli-code  = p-obj-code
         and buf_fin-schet.curr-code = p-curr-code
    on error undo, return error
    :
        if buf_fin-schet.status_   = 'удал':U
        then do:
        end.
        else do:
            assign
                v-fmtcli-schet-exists   = yes
                v-fmtcli-bank-r-schet   = trim( buf_fin-schet.r-schet )
                v-fmtcli-bank-c-schet   = trim( buf_fin-schet.c-schet )
            .
            find first buf_fin-bank no-lock
                 where buf_fin-bank.host-code = p-host-code
                   and buf_fin-bank.code-bank = buf_fin-schet.code-bank
            no-error.
            if available buf_fin-bank
            then do:
                assign
                    v-fmtcli-bank-exists      = yes
                    v-fmtcli-bank-bik         = trim( buf_fin-bank.bik )
                    v-fmtcli-bank-name        = trim( buf_fin-bank.bank-name )
                    v-fmtcli-bank-addres      = trim(buf_fin-bank.addres)
                    v-fmtcli-bank-city      = trim(buf_fin-bank.bank-city)
                .
            end.
            else do:
                assign
                    v-fmtcli-bank-exists    = no
                    v-fmtcli-bank-bik       = "":U
                    v-fmtcli-bank-name      = "":U
                    v-fmtcli-bank-addres    = "":U
                    v-fmtcli-bank-city      = "":U
                .
            end.
            leave search-for-schet.
        end.
    end.
end.
end procedure.
procedure fmtcli-get-client :
define input parameter p-obj-type       as character    no-undo.
define input parameter p-obj-code       as integer      no-undo.
    define variable v-temp-fmtcli-address      as character     no-undo.
    define variable v-num-country-city    as integer      no-undo.
    define buffer buf_clients   for ub.clients.
    define buffer buf_firm      for ub.firm.
    define buffer buf_store     for ub.store.
    define buffer buf_shop      for ub.shop.
    define buffer buf_person    for ub.person.
do
for buf_clients
  , buf_firm
  , buf_store
  , buf_shop
  , buf_person
on error undo, return error
:
    assign
        v-fmtcli-name           = "":U
        v-fmtcli-addres         = "":U
        v-fmtcli-post-addres    = "":U
        v-fmtcli-full-addres    = "":U
        v-fmtcli-phone          = "":U
        v-fmtcli-inn            = "":U
        v-fmtcli-kpp            = "":U
        v-fmtcli-okpo           = "":U
        v-fmtcli-city           = "":U
        v-fmtcli-index          = "":U
        v-fmtcli-country        = "":U
    .
    find first buf_clients no-lock
         where buf_clients.obj-type = p-obj-type
           and buf_clients.obj-code = p-obj-code
    .
    assign
        v-fmtcli-name = buf_clients.obj-name
    .
    case buf_clients.obj-type:
       when 'орг':U
       then do:
            find first buf_firm no-lock
                 where buf_firm.firm-code = buf_clients.obj-code
                 no-error
            .
            if available buf_firm
            then do:
                assign
                    v-num-country-city = num-entries( buf_firm.city )
                    v-fmtcli-engl-name = buf_firm.engl-name
                .
                if v-num-country-city > 0
                then do:
                    assign
                        v-fmtcli-country    = trim( entry( 1, buf_firm.city ) )
                    .
                end.
                if v-num-country-city > 1
                then do:
                    assign
                        v-fmtcli-city       = trim( entry( 2, buf_firm.city ) )
                    .
                end.
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-full-addres
                    , input v-fmtcli-country
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-full-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-full-addres
                    , input v-fmtcli-city
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-full-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-full-addres
                    , input IF buf_firm.ind = 0 THEN "" ELSE string( buf_firm.ind )
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-full-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-post-addres
                    , input v-fmtcli-country
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-post-addres
                    , input v-fmtcli-city
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-post-addres
                    , input string( buf_firm.ind )
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input substring( buf_firm.addres1, 1, 50 )
                    , input buf_firm.addres2
                    , input " ":U
                    , input 50
                    , output v-temp-fmtcli-address
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-temp-fmtcli-address
                    , input substring( buf_firm.addres1, 51, 50 )
                    , input " ":U
                    , input 50
                    , output v-temp-fmtcli-address
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-temp-fmtcli-address
                    , input substring( buf_firm.addres1, 101, 50 )
                    , input " ":U
                    , input 50
                    , output v-temp-fmtcli-address
                ).
                assign
                    v-fmtcli-addres = v-temp-fmtcli-address
                .
                if buf_firm.addres1 <> ?
                then do:
                    run fmtcli-concatenate-strings in this-procedure (
                          input v-fmtcli-full-addres
                        , input v-fmtcli-addres
                        , input ", ":U
                        , input 0
                        , output v-fmtcli-full-addres
                    ).
                end.
                run fmtcli-concatenate-strings in this-procedure (
                      input substring( buf_firm.post-addr1, 1, 50 )
                    , input buf_firm.post-addr2
                    , input " ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-post-addres
                    , input substring( buf_firm.post-addr1, 51, 50 )
                    , input " ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-post-addres
                    , input substring( buf_firm.post-addr1, 101, 50 )
                    , input " ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                assign
                    v-fmtcli-phone         = buf_firm.phone
                    v-fmtcli-inn           = buf_firm.inn
                    v-fmtcli-kpp           = buf_firm.kpp
                    v-fmtcli-okpo          = buf_firm.okpo
                    v-fmtcli-index         = string( buf_firm.ind )
                .
            end.
       end.
       when 'маг':U
       then do:
            find first buf_shop no-lock
                 where buf_shop.obj-code = buf_clients.obj-code
            .
            if available buf_shop
            then do:
                run fmtcli-concatenate-strings in this-procedure (
                      input buf_shop.addres1
                    , input buf_shop.addres2
                    , input " ":U
                    , input 50
                    , output v-fmtcli-addres
                ).
                assign
                    v-fmtcli-full-addres = v-fmtcli-addres
                    v-fmtcli-post-addres = v-fmtcli-addres
                    v-fmtcli-phone       = buf_shop.phone
                    v-fmtcli-inn         = "":U
                    v-fmtcli-kpp         = "":U
                    v-fmtcli-okpo        = "":U
                    v-fmtcli-city        = "":U
                    v-fmtcli-index       = "":U
                .
            end.
       end.
       when 'скл':U
       then do:
            find first buf_store no-lock
                 where buf_store.obj-code = buf_clients.obj-code
            .
            if available buf_store
            then do:
                run fmtcli-concatenate-strings in this-procedure (
                      input buf_store.addres1
                    , input buf_store.addres2
                    , input " ":U
                    , input 50
                    , output v-fmtcli-addres
                ).
                assign
                    v-fmtcli-full-addres = v-fmtcli-addres
                    v-fmtcli-phone       = buf_store.phone
                    v-fmtcli-inn         = "":U
                    v-fmtcli-kpp         = "":U
                    v-fmtcli-okpo        = "":U
                    v-fmtcli-city        = "":U
                    v-fmtcli-index       = "":U
                .
            end.
       end.
       when 'чел':U
       then do:
            find first buf_person no-lock
                 where buf_person.psn-code = buf_clients.obj-code
            .
            if available buf_person
            then do:
                run fmtcli-concatenate-strings in this-procedure (
                      input ( if buf_person.ind = 0 or buf_person.ind = ?
                              then "":U
                              else string( buf_person.ind, "999999")
                              )
                    , input buf_person.city
                    , input ", ":U
                    , input 0
                    , output v-fmtcli-full-addres
                ).
                assign
                    v-fmtcli-addres = buf_person.address
                .
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-full-addres
                    , input v-fmtcli-addres
                    , input ", ":U
                    , input 0
                    , output v-fmtcli-full-addres
                ).
                assign
                    v-fmtcli-phone     = buf_person.phone1
                    v-fmtcli-inn       = buf_person.inn
                    v-fmtcli-kpp       = buf_person.kpp
                    v-fmtcli-okpo      = buf_person.okpo
                    v-fmtcli-city      = buf_person.city
                    v-fmtcli-index     = string( buf_person.ind )
                .
            end.
       end.
    end case.
end.
end procedure.
procedure fmtcli-concatenate-strings :
define input parameter p-string-1       as character        no-undo.
define input parameter p-string-2       as character        no-undo.
define input parameter p-delimiter      as character        no-undo.
define input parameter p-length         as integer          no-undo.
define output parameter p-out-string    as character        no-undo.
do
on error undo, return error
:
    assign
        p-out-string = ( if p-string-1 = ?
                         then "":U
                         else trim( p-string-1 ) )
    .
    assign
        p-out-string = p-out-string
                     + ( if p-out-string = "":U
                         or length( p-out-string ) = p-length
                         or p-string-2 = ?
                         or trim( p-string-2 ) = "":U
                         then "":U
                         else p-delimiter )
                     + ( if p-string-2 = ?
                         or trim( p-string-2 ) = "":U
                         then "":U
                         else trim( p-string-2 ) )
    .
end.
end procedure.
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure reprumpr_print-plain-text :
define input parameter p-dir-name as character no-undo .
define input parameter p-subdir-name as character no-undo .
define input parameter p-custom-name as character no-undo .
define input parameter p-disable-option as integer no-undo .
define input parameter p-font-number as integer no-undo .
define variable v-file-name as character no-undo .
define variable v-report-name as character no-undo .
define variable v-err-status as integer no-undo .
define variable v-err-mess as character no-undo .
v-file-name = p-dir-name + (if p-subdir-name <> ''
                            then (p-subdir-name + chr(47))
                            else '') +
              p-custom-name.
run prn-lib-get-report-name  in this-procedure (
                                                  input parParentProc
                                                  ,output v-report-name
                                                ).
os-copy
value(v-report-name)
value(v-file-name)
.
assign
v-err-status = os-error
.
if v-err-status <> 0 then do:
  run gbl/os-errnm.p ( input v-err-status
                      ,output v-err-mess).
  return error v-err-mess.
end.
else do:
  run cb_fill-report-destination in p-parent-handle (  input p-rdbh
                                                ,input p-report-id
                                                ,input 'text':U
                                                ,input v-file-name
                                                ,input string(p-disable-option) + chr(4) + string(p-font-number)
                                                ).
end.
end procedure.
procedure reprumpr_print-printer :
define input parameter p-font-number as integer no-undo .
define input parameter p-flags as integer no-undo .
define variable v-quest-print as logical no-undo .
define variable lok as logical no-undo .
define variable v-report-name as character no-undo .
run get-quest-print in parparentproc ( output v-quest-print) .
if not v-quest-print then do:
    .
  run prn-lib-get-report-name  in this-procedure (
                                                    input parParentProc
                                                   ,output v-report-name
                                                  ).
  run adecomm/_osprint.p
    (input  ?
    ,input  v-report-name
    ,input  p-font-number
    ,input  p-flags
    ,input  0
    ,input  0
    ,output lok
    ).
  if not lok then do:
  end.
end.
end procedure.
procedure reprumpr_print-xls :
define input parameter p-dir-name as character no-undo .
define input parameter p-subdir-name as character no-undo .
define input parameter p-custom-name as character no-undo .
define input parameter p-disable-option as integer no-undo .
define input parameter p-font-number as integer no-undo .
define variable v-file-name as character no-undo .
define variable v-report-name as character no-undo .
define buffer buf_sheetf for sheetf.
run prn-lib-get-report-name  in this-procedure (
                                                  input parParentProc
                                                 ,output v-report-name
                                                ).
v-file-name = p-dir-name +
             (if p-subdir-name <> ''
             then (p-subdir-name + chr(47))
             else '') +
             p-custom-name.
find first buf_sheetf where
         buf_sheetf.sheet-num = 1.
assign
buf_sheetf.file-name = v-file-name
buf_sheetf.silent-save = yes
.
release buf_sheetf.
run rep/runexcel.p ( input (v-report-name + ".txt")) no-error.
if error-status:error then do:
  return error return-value .
end.
else do:
  run cb_fill-report-destination in p-parent-handle (  input p-rdbh
                                                ,input p-report-id
                                                ,input 'excel':U
                                                ,input v-file-name
                                                ,input string(p-disable-option) + chr(4) + string(p-font-number)
                                                ).
end.
end procedure.
define            variable line                      as character no-undo .
define            variable rep-shift-store-name      as character no-undo.
define            variable rep-shift-for-mng         as character no-undo format "X(30)":U .
define            variable rep-shift-for-mng1        as character no-undo format "X(30)":U .
define            variable rep-shift-for-mng2        as character no-undo format "X(30)":U .
define            variable rep-shift-for-mng-next    as character no-undo format "X(30)":U .
define            variable rep-shift-for-mng-end     as character no-undo format "X(30)":U .
define            variable rep-shift-rol-mng-end     as character no-undo format "X(30)":U .
define            variable rep-shift-for-opers       as character no-undo.
define            variable rep-shift-for-opers1      as character no-undo format "X(44)":U .
define            variable rep-shift-for-opers2      as character no-undo format "X(44)":U .
define            variable rep-shift-first-oper      as logical   no-undo initial yes.
define            variable rep-shift-first-mngr      as logical   no-undo initial yes.
define            variable sheets                    as integer   no-undo.
define            variable v-previous-shift-date     as date      no-undo .
define            variable v-current-shift-date      as date      no-undo .
define            variable v-archive-ok              as logical   no-undo .
define            variable v-comment                 as character no-undo .
define            variable v-can-print               as logical   no-undo .
define            variable v-run-2-3-4               as logical   no-undo initial yes.
define            variable v-host-code               like ub.sysconf.host-code no-undo .
define            variable v-host-name               like ub.clients.obj-name no-undo .
define            variable p-z-number-list           as character no-undo.
define            variable p-z-number-item           as character no-undo.
define            variable v-param_prt-z-no          as character no-undo.
define            variable v-param_shft-qty          as character no-undo.
define            variable v-param_data-type         as character no-undo.
define new shared variable v-rep-shift-open-date     like ub.shift-obj.open-date no-undo.
define new shared variable v-rep-shift-open-time     like ub.shift-obj.open-time no-undo.
define new shared variable v-rep-shift-close-date    like ub.shift-obj.close-date no-undo.
define new shared variable v-rep-shift-close-time    like ub.shift-obj.close-time no-undo.
define new shared variable v-rep-shift-close         like ub.shift-obj.close-time no-undo.
define            variable v-count                   as integer   initial 0 no-undo .
define            variable v-ii                      as integer   no-undo .
define            variable v-str2                    as character no-undo .
define            variable v-write-xml-error         as logical   no-undo .
define            variable v-obj-address             as character no-undo .
define            variable v-obj-phone               as character no-undo .
define            variable v-report-name-html        as character no-undo .
define            variable v-report-name-html-list   as character no-undo .
define            variable v-report-name-html-result as character no-undo .
define            variable v-report-result           as logical   no-undo .
define            variable rep-shift-rol-mng         as character no-undo .
define            variable rep-shift-rol-oper        as character no-undo .
define            variable rep-shift-rol-mng2        as character no-undo .
define            variable rep-shift-rol-oper2       as character no-undo .
define            variable rep-shift-rol-mng-next    as character no-undo .
define            variable v-param-code              as integer   no-undo .
define            variable tog-list                  as character no-undo .
define            variable tog-last                  as character no-undo .
define            VARIABLE v-param                   as LOGICAL   no-undo .
define            VARIABLE v-one-shift               as LOGICAL   no-undo .
define buffer next-shift-obj     for ub.shift-obj.
define buffer previous-shift-obj for ub.shift-obj.
define buffer buf_goods          for ub.goods.
define buffer buf_shift          for shiftt.
define stream Out-Stream.
define stream OutStr-html.
define variable v-sort-list     as character no-undo .
define variable v-param-type    as character no-undo .
define variable v-tth           as handle    no-undo .
run adm/shattri.p (
    input "get":U
    ,input  ''
    ,input  0
    ,input  'report-glob':U
    ,input  'rep-shift-format':U
    ,output v-sort-list
    ,output v-value-date
    ,output v-value-decimal
    ,output v-param-code
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
if error-status:error then
do:
   delete object v-tth.
   message
      "Не найден или незаполнен параметр - Формат печати сменного отчета"
      view-as alert-box error .
   return .
end.
if tog-1 = true then
do:
   tog-list = "tog-1".
end.
if tog-2 = true then
do:
   tog-list = tog-list + ',' + "tog-2".
end.
if tog-3 = true then
do:
   tog-list = tog-list + ',' + "tog-3".
end.
if tog-4 = true then
do:
   tog-list = tog-list + ',' + "tog-4".
end.
if tog-5 = true then
do:
   tog-list = tog-list + ',' + "tog-5".
end.
if tog-5-1 = true then
do:
   tog-list = tog-list + ',' + "tog-5-1".
end.
if tog-7 = true then
do:
   tog-list = tog-list + ',' + "tog-7".
end.
if tog-81 = true then
do:
   tog-list = tog-list + ',' + "tog-81".
end.
if tog-9 = true then
do:
   tog-list = tog-list + ',' + "tog-9".
end.
if tog-10 = true then
do:
   tog-list = tog-list + ',' + "tog-10".
end.
if tog-list <> "" then
do:
   tog-last = entry(num-entries(tog-list),tog-list).
end.
if p-batch > 0 then
do:
   run get-userid in parparentproc ( output v-cntxt-userid).
   run get-db-num in parparentproc ( output v-cntxt-db-num).
end.
else
do:
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
end.
FIND FIRST ub.clients No-LOCK
   WHERE ub.clients.obj-type = p-obj-type
   AND ub.clients.obj-code = p-obj-code
   No-ERROR.
assign
   rep-shift-store-name = if available ub.clients
             then ub.clients.obj-name
             else (p-obj-type + string(p-obj-code))
   .
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  ,output v-host-name
  )  .
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input p-obj-type
  ,input p-obj-code
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
  if thbjattr_thbj-attr.prop-code = 'shft-qty'  then v-param_shft-qty = thbjattr_thbj-attr.property-value-character .
  if thbjattr_thbj-attr.prop-code = 'prt-z-no'  then v-param_prt-z-no = string(thbjattr_thbj-attr.property-value-logical) .
end.
if v-param_shft-qty = "" then v-param_shft-qty = "system" .
define temp-table temp-shift-obj no-undo like ub.shift-obj
   FIELD num as integer
   INDEX ii IS UNIQUE num
   .
RUN fmtcli-get-client IN THIS-PROCEDURE ( INPUT  p-obj-type
   , INPUT  p-obj-code
   ) .
assign
   v-obj-address = ( if v-fmtcli-index <> '':U then ( v-fmtcli-index ) else '':U )
                            + ( if v-fmtcli-full-addres <> '':U then ( v-fmtcli-full-addres ) else '':U )
   v-obj-phone   = ( if v-fmtcli-phone <> '':U then v-fmtcli-phone else '':U )
   .
for each ub.shift-obj  no-lock
   where ub.shift-obj.obj-code   =  p-obj-code
   and ub.shift-obj.obj-type   =  p-obj-type
   and ub.shift-obj.shift-date >= X-date-Start
   and ub.shift-obj.shift-date <= X-date-End
   :
   if ub.shift-obj.shift-date = X-date-Start and ub.shift-obj.shift-num < X-Shift-Start then next .
   if ub.shift-obj.shift-date = X-date-End   and ub.shift-obj.shift-num > X-Shift-End then next .
   if ub.shift-obj.status_ <> 'зкр':U then
   do:
            if p-batch > 0 then do:      run write-log-and-file in p-log-handle (                 input 1                                          , input p-log-file-name                              , input 1                                          , input substitute("На объекте &1 смена &2 с датой начала &3&4"  +                                  "еще не закрыта!&4Сменный отчет сделать нельзя!"                                  , rep-shift-store-name                                 ,ub.shift-obj.shift-num                                 ,string(ub.shift-obj.shift-date,"99/99/9999")                                 , chr(10))).    end.    else do:       run write-to-log in p-log-handle ( input substitute("На объекте &1 смена &2 с датой начала &3&4"  +                                  "еще не закрыта!&4Сменный отчет сделать нельзя!"                                  , rep-shift-store-name                                 ,ub.shift-obj.shift-num                                 ,string(ub.shift-obj.shift-date,"99/99/9999")                                 , chr(10))).    end.
      if v-write-xml-error then
      do:
         run cb_write-report-error in p-parent-handle ( input p-rebh
                ,input p-report-id
                ,input ?
                ,input '3':U
                ,input substitute("На объекте &1 смена &2 с датой начала &3&4"  +                                  "еще не закрыта!&4Сменный отчет сделать нельзя!"                                  , rep-shift-store-name                                 ,ub.shift-obj.shift-num                                 ,string(ub.shift-obj.shift-date,"99/99/9999")                                 , chr(10))).
      end.
      RETURN.
   end.
   create temp-shift-obj .
   assign
      v-count = v-count + 1 .
   assign
      temp-shift-obj.num = v-count .
   buffer-copy ub.shift-obj to temp-shift-obj .
   if p-batch > 0
      then
   do:
      find first buf_shift where
         buf_shift.obj-type = p-obj-type
         and buf_shift.obj-code = p-obj-code
         and buf_shift.shift-date = x-date-end
         and buf_shift.shift-num = x-shift-end no-error.
      if not available buf_shift then
      do:
         create buf_shift.
         assign
            buf_shift.obj-type    = p-obj-type
            buf_shift.obj-code    = p-obj-code
            buf_shift.shift-date  = ub.shift-obj.shift-date
            buf_shift.shift-num   = ub.shift-obj.shift-num
            buf_shift.db-num      = ub.clients.db-num
            buf_shift.obj-name    = ub.clients.obj-name
            buf_shift.obj-address = v-obj-address
            buf_shift.obj-phone   = v-obj-phone
            buf_shift.db-num      = ub.clients.db-num
            buf_shift.shift-name  = ub.shift-obj.shift-name
            buf_shift.base-code   = p-base-code
            buf_shift.curr-abbr   = p-curr-abbr
            .
         release buf_shift.
      end.
            if p-batch > 0 then do:      run write-log-and-file in p-log-handle (                 input 1                                          , input p-log-file-name                              , input 1                                          , input substitute("&1&2 cмена &3 П.&4", p-obj-type, p-obj-code, string(x-date-end, "99/99/9999"), x-shift-end)).    end.    else do:       run write-to-log in p-log-handle ( input substitute("&1&2 cмена &3 П.&4", p-obj-type, p-obj-code, string(x-date-end, "99/99/9999"), x-shift-end)).    end.
   end.
   FOR EACH ub.shift-staff No-LOCK WHERE
      ub.shift-staff.obj-type   = p-obj-type AND
      ub.shift-staff.obj-code   = p-obj-code AND
      ub.shift-staff.shift-date = ub.shift-obj.shift-date AND
      ub.shift-staff.shift-num  = ub.shift-obj.shift-num AND
      ub.shift-staff.next-shift = no AND
      ub.shift-staff.staff-role = no and
      ub.shift-staff.psn-num    >= 0 :
      if lookup( chr(32) + ub.shift-staff.name, rep-shift-for-opers ) = 0 then
      do:
         assign
            rep-shift-for-opers = rep-shift-for-opers + (if rep-shift-for-opers > '' then chr(44) else "")  + ub.shift-staff.name
            .
      end.
   end.
   if rep-shift-for-opers > '' then
      assign
         rep-shift-for-opers1 = entry (1, rep-shift-for-opers, chr(44))
         rep-shift-rol-oper   = "Оператор"
              no-error.
   if num-entries (rep-shift-for-opers, chr(44)) >= 2 then
      assign
         rep-shift-for-opers2 = entry (2, rep-shift-for-opers, chr(44))
         rep-shift-rol-oper2  = "Оператор"
              no-error.
   FOR EACH ub.shift-staff No-LOCK WHERE
      ub.shift-staff.obj-type = p-obj-type AND
      ub.shift-staff.obj-code = p-obj-code AND
      ub.shift-staff.shift-date = temp-shift-obj.shift-date AND
      ub.shift-staff.shift-num  = temp-shift-obj.shift-num AND
      ub.shift-staff.next-shift = no AND
      ub.shift-staff.staff-role = yes and
      ub.shift-staff.psn-num    >= 0 :
      if lookup( chr(32) + ub.shift-staff.name, rep-shift-for-mng ) = 0 then
      do:
         assign
            rep-shift-for-mng = rep-shift-for-mng + (if rep-shift-for-mng > '' then chr(44) else "")  + ub.shift-staff.name
            .
      end.
   end.
   if rep-shift-for-mng > '' then
      assign
         rep-shift-for-mng1 = entry (1, rep-shift-for-mng, chr(44))
         rep-shift-rol-mng  = "Старший оператор"
              no-error.
   if num-entries (rep-shift-for-mng, chr(44)) >= 2 then
      assign
         rep-shift-for-mng2 = entry (2, rep-shift-for-mng, chr(44))
         rep-shift-rol-mng2 = "Старший оператор"
              no-error.
end.
rep-shift-for-opers =  breakstr(rep-shift-for-opers, 44, input-output rep-shift-for-opers1, input-output rep-shift-for-opers2).
find first temp-shift-obj where temp-shift-obj.num = 1 no-error .
if not available temp-shift-obj Then
DO:
       if p-batch > 0 then do:      run write-log-and-file in p-log-handle (                 input 1                                          , input p-log-file-name                              , input 1                                          , input substitute("На объекте &1 нет смены &2 с датой начала &3&4" +                                 "Исправьте запрашиваемые данные!"                                 , rep-shift-store-name                                 , X-shift-start                                 ,string(X-date-start,"99/99/9999")                                 , chr(10) )).    end.    else do:       run write-to-log in p-log-handle ( input substitute("На объекте &1 нет смены &2 с датой начала &3&4" +                                 "Исправьте запрашиваемые данные!"                                 , rep-shift-store-name                                 , X-shift-start                                 ,string(X-date-start,"99/99/9999")                                 , chr(10) )).    end.
   if v-write-xml-error then
   do:
      run cb_write-report-error in p-parent-handle ( input p-rebh
         ,input p-report-id
         ,input ?
         ,input '3':U
         ,input substitute("На объекте &1 нет смены &2 с датой начала &3&4" +                                 "Исправьте запрашиваемые данные!"                                 , rep-shift-store-name                                 , X-shift-start                                 ,string(X-date-start,"99/99/9999")                                 , chr(10) )).
   end.
   RETURN.
End.
assign
   x-date-Start          = temp-shift-obj.shift-date
   X-Shift-Start         = temp-shift-obj.shift-num
   v-rep-shift-open-date = temp-shift-obj.open-date
   v-rep-shift-open-time = temp-shift-obj.open-time
   .
find first temp-shift-obj  where temp-shift-obj.num = v-count no-error .
if available temp-shift-obj then
do:
   assign
      x-date-End             = temp-shift-obj.shift-date
      X-Shift-End            = temp-shift-obj.shift-num
      v-rep-shift-close-date = temp-shift-obj.close-date
      v-rep-shift-close-time = temp-shift-obj.open-time
      v-rep-shift-close      = temp-shift-obj.close-time
      .
end.
if x-shift-start = x-shift-end and x-date-start = x-date-end then v-one-shift = true .
else v-one-shift = false .
FIND first next-shift-obj NO-LOCK
   WHERE next-shift-obj.obj-type   = temp-shift-obj.obj-type
   and next-shift-obj.obj-code   = temp-shift-obj.obj-code
   and next-shift-obj.shift-date = temp-shift-obj.shift-date
   and next-shift-obj.shift-num  = temp-shift-obj.shift-num
   no-error .
FIND NEXT  next-shift-obj SHARE-LOCK WHERE next-shift-obj.obj-type = p-obj-type AND next-shift-obj.obj-code = p-obj-code use-index pi NO-ERROR.
FIND FIRST ub.shift-staff No-LOCK WHERE
   ub.shift-staff.obj-type   = p-obj-type AND
   ub.shift-staff.obj-code   = p-obj-code AND
   ub.shift-staff.shift-date = (if available next-shift-obj then next-shift-obj.shift-date else temp-shift-obj.shift-date) AND
   ub.shift-staff.shift-num  = (if available next-shift-obj then next-shift-obj.shift-num  else temp-shift-obj.shift-num) AND
   ub.shift-staff.next-shift = (if available next-shift-obj then no else yes) AND
   ub.shift-staff.staff-role = yes and
   ub.shift-staff.psn-num    >= 0 No-ERROR.
assign
   rep-shift-for-mng-next = if available ub.shift-staff then string(ub.shift-staff.name, "X(30)") else "".
rep-shift-rol-mng-next = "Старший оператор"
   .
run get-report-num in parParentProc (
   output p-report-id
   ).
v-report-name-html = session:temp-directory + "rpt" + string(p-report-id) + string(time) + ".html".
if v-param-code = 3 then v-param = yes.
else v-param = no .
if tog-1 = true then
do:
    run first-line-tog1-html in this-procedure (
        input v-report-name-html
        ).
    if v-param-code = 2 then
    do:
        run rep/r-new-shift1-2.p
            ( input parparentproc
            , input p-parent-handle
            , input p-log-handle
            , input p-cont-handle
            , input p-rebh
            , input v-report-name-html
            , input p-xsd-file
            , input p-log-file-name
            , input p-batch
            , input p-codex-id
            , input p-ruleset-id
            , input p-weight
            , input v-param_shft-qty
            , input p-obj-type
            , input p-obj-code
            , input p-z-number-list
            , input tog-1-pump-one
            , input tog-1-whole-gds
            , input tog-1-out-pump-with-icnt
            ) no-error.
    end.
    else
    do:
        if v-param-code = 3 then
        do:
            run rep/r-new-shift1-3.p
                ( input parparentproc
                , input p-parent-handle
                , input p-log-handle
                , input p-cont-handle
                , input p-rebh
                , input v-report-name-html
                , input p-xsd-file
                , input p-log-file-name
                , input p-batch
                , input p-codex-id
                , input p-ruleset-id
                , input p-weight
                , input v-param_shft-qty
                , input p-obj-type
                , input p-obj-code
                , input p-z-number-list
                , input tog-1-pump-one
                , input tog-1-whole-gds
                , input tog-1-out-pump-with-icnt
                ) no-error.
        end.
        else
        do:
            run rep/r-new-shift1.p
                ( input parparentproc
                , input p-parent-handle
                , input p-log-handle
                , input p-cont-handle
                , input p-rebh
                , input v-report-name-html
                , input p-xsd-file
                , input p-log-file-name
                , input p-batch
                , input p-codex-id
                , input p-ruleset-id
                , input p-weight
                , input v-param_shft-qty
                , input p-obj-type
                , input p-obj-code
                , input p-z-number-list
                , input tog-1-pump-one
                , input tog-1-whole-gds
                , input tog-1-out-pump-with-icnt
                ) no-error.
        end.
    end.
    if tog-last <> "tog-1" then
    do:
        output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' .
        put stream OutStr-html unformatted
            substitute (
            '
        </table>
        '
            , chr(123), chr(125)
            ).
        output stream OutStr-html close.
    end.
    else
        run last-line-tog-html in this-procedure (
            input v-report-name-html
            ).
end.
if tog-2 or tog-3 or tog-4  then
do:
   assign
      sheets = if tog-2 then 1000 else 0
      sheets = sheets + if tog-3 then 100 else 0
      sheets = sheets + if tog-4 then 10 else 0
      .
   if tog-3 then
   do:
      run rep/r-shftgr.p
         ( input p-obj-type
         ,input p-obj-code
         ,input X-date-Start
         ,input X-Shift-Start
         ,input xClassify
         ,input xSortType
         ,input xtog-level
         ,input xvar-level
         ) no-error.
   end.
   run rep/r-shftc2.p (
      INPUT p-obj-type
      ,INPUT p-obj-code
      ,INPUT X-date-start
      ,INPUT X-Shift-Start
      ,INPUT X-date-end
      ,INPUT X-Shift-end
      ,INPUT SHEETS
      ,INPUT tog-2
      ,INPUT tog-3
      ,INPUT tog-4
      ,INPUT tog-81
      ,INPUT (Xclassify = "totals":U)
      ,INPUT (x-selectgood = 2)
      ,INPUT p-batch
      ,INPUT v-param)
      no-error.
   if error-status:error then
   do:
      message error-status:error error-status:get-message(1)  view-as alert-box.
   end.
   FIND LAST  previous-shift-obj SHARE-LOCK WHERE
      previous-shift-obj.obj-type = p-obj-type AND
      previous-shift-obj.obj-code = p-obj-code AND
      ((previous-shift-obj.shift-date = X-date-start AND
      previous-shift-obj.shift-num < X-shift-start) OR
      previous-shift-obj.shift-date < X-date-start)
      use-index pi NO-ERROR.
   if available previous-shift-obj then
   do:
      assign
         v-previous-shift-date = previous-shift-obj.shift-date
         v-current-shift-date  = X-date-start
         .
      run rep/chk-ahz.p (
         input        p-obj-type
         ,input        p-obj-code
         ,input        yes
         ,input        yes
         ,input        no
         ,input        no
         ,input        (p-batch = integer('0':U))
         ,input        v-cntxt-db-num
         ,input        v-cntxt-userid
         ,input-output v-previous-shift-date
         ,input-output v-current-shift-date
         ,output       v-archive-ok
         ,output       v-comment
         ,output       v-can-print
         ) no-error .
      if error-status:error then
      do:
               if p-batch > 0 then do:      run write-log-and-file in p-log-handle (                 input 1                                          , input p-log-file-name                              , input 1                                          , input substitute("&1 &2 &3&4Ошибка при вызове программы chk-ahz.p&4&5&4&6"                                    ,vss-workfile                                    ,vss-revision                                    ,vss-description                                    ,chr(10)                                   ,error-status :get-message(1)                                    ,return-value )).    end.    else do:       run write-to-log in p-log-handle ( input substitute("&1 &2 &3&4Ошибка при вызове программы chk-ahz.p&4&5&4&6"                                    ,vss-workfile                                    ,vss-revision                                    ,vss-description                                    ,chr(10)                                   ,error-status :get-message(1)                                    ,return-value )).    end.
         if v-write-xml-error then
         do:
            run cb_write-report-error in p-parent-handle ( input p-rebh
               ,input p-report-id
               ,input ?
               ,input '3':U
               ,input substitute("&1 &2 &3&4Ошибка при вызове программы chk-ahz.p&4&5&4&6"                                    ,vss-workfile                                    ,vss-revision                                    ,vss-description                                    ,chr(10)                                   ,error-status :get-message(1)                                    ,return-value )).
         end.
         return error .
      end.
      if X-date-start < v-previous-shift-date
         or X-date-start > v-current-shift-date  then
      do:
               if p-batch > 0 then do:      run write-log-and-file in p-log-handle (                 input 1                                          , input p-log-file-name                              , input 1                                          , input substitute("Объект &1&2 Печать 2, 3 и 4 листа сменного отчета за выбранную дату невозможна&3"  +                                   "Отсутствуют подробные складские архивы&3"  +                                   "Возможные даты отчета: &4-&5&3&6&3"                                   ,p-obj-type                                    ,p-obj-code                                    , chr(10)                                   ,string(v-previous-shift-date, '99/99/9999':u)                                   ,string(v-current-shift-date, '99/99/9999':u)                                    ,v-comment)).    end.    else do:       run write-to-log in p-log-handle ( input substitute("Объект &1&2 Печать 2, 3 и 4 листа сменного отчета за выбранную дату невозможна&3"  +                                   "Отсутствуют подробные складские архивы&3"  +                                   "Возможные даты отчета: &4-&5&3&6&3"                                   ,p-obj-type                                    ,p-obj-code                                    , chr(10)                                   ,string(v-previous-shift-date, '99/99/9999':u)                                   ,string(v-current-shift-date, '99/99/9999':u)                                    ,v-comment)).    end.
         if v-write-xml-error then
         do:
            run cb_write-report-error in p-parent-handle ( input p-rebh
               ,input p-report-id
               ,input ?
               ,input '3':U
               ,input substitute("Объект &1&2 Печать 2, 3 и 4 листа сменного отчета за выбранную дату невозможна&3"  +                                   "Отсутствуют подробные складские архивы&3"  +                                   "Возможные даты отчета: &4-&5&3&6&3"                                   ,p-obj-type                                    ,p-obj-code                                    , chr(10)                                   ,string(v-previous-shift-date, '99/99/9999':u)                                   ,string(v-current-shift-date, '99/99/9999':u)                                    ,v-comment)).
         end.
         assign
            v-run-2-3-4 = no
            .
      end.
   end.
end.
if tog-2 = true then
do:
   run first-line-tog2-html in this-procedure (
      input v-report-name-html
      ).
   if v-param-code = 3 then
   do:
      run rep/r-new-shift2_3.p
         ( input parparentproc
         ,input p-parent-handle
         ,input p-log-handle
         ,input p-cont-handle
         ,input p-rebh
         ,input v-report-name-html
         ,input p-xsd-file
         ,input p-log-file-name
         ,input p-batch
         ,input p-codex-id
         ,input p-ruleset-id
         ,input p-obj-type
         ,input p-obj-code
         ,input p-z-number-list
         ,input v-previous-shift-date
         ,input tog-2-cp-grp
         ) no-error.
      if error-status:error then
      do:
             if p-batch > 0 then do:      run write-log-and-file in p-log-handle (                 input 1                                          , input p-log-file-name                              , input 1                                          , input substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6"                           ,vss-workfile                           ,vss-revision                           ,vss-description                           ,chr(10)                           , error-status:get-message(1)                           , return-value )).    end.    else do:       run write-to-log in p-log-handle ( input substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6"                           ,vss-workfile                           ,vss-revision                           ,vss-description                           ,chr(10)                           , error-status:get-message(1)                           , return-value )).    end.
      end.
   end.
   else
   do:
      run rep/r-new-shift2.p
         ( input parparentproc
         ,input p-parent-handle
         ,input p-log-handle
         ,input p-cont-handle
         ,input p-rebh
         ,input v-report-name-html
         ,input p-xsd-file
         ,input p-log-file-name
         ,input p-batch
         ,input p-codex-id
         ,input p-ruleset-id
         ,input p-obj-type
         ,input p-obj-code
         ,input p-z-number-list
         ,input v-previous-shift-date
         ,input tog-2-cp-grp
         ) no-error.
      if error-status:error then
      do:
             if p-batch > 0 then do:      run write-log-and-file in p-log-handle (                 input 1                                          , input p-log-file-name                              , input 1                                          , input substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6"                           ,vss-workfile                           ,vss-revision                           ,vss-description                           ,chr(10)                           , error-status:get-message(1)                           , return-value )).    end.    else do:       run write-to-log in p-log-handle ( input substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6"                           ,vss-workfile                           ,vss-revision                           ,vss-description                           ,chr(10)                           , error-status:get-message(1)                           , return-value )).    end.
      end.
   end.
   if tog-last <> "tog-2" then
   do:
      output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' .
      put stream OutStr-html unformatted
         substitute (
         '
        </table>
        '
         , chr(123), chr(125)
         ).
      output stream OutStr-html close.
   end.
   else
      run last-line-tog-html in this-procedure (
         input v-report-name-html
         ).
end.
if tog-3 = yes and v-run-2-3-4 = yes then
do:
   run first-line-tog3-html in this-procedure (
      input v-report-name-html
      ).
   if v-param-code = 3 then
   do:
      run rep/r-new-shift3_3.p (
         input parparentproc
         ,input p-parent-handle
         ,input p-log-handle
         ,input p-cont-handle
         ,input p-rebh
         ,input v-report-name-html
         ,input p-xsd-file
         ,input p-log-file-name
         ,input p-batch
         ,input p-codex-id
         ,input p-ruleset-id
         ,input p-obj-type
         ,input p-obj-code
         ,input p-z-number-list
         ,input xClassify
         ,input xSortType
         ,input xtog-level
         ,input xvar-level
         ,input v-previous-shift-date
         ,input v-param
         ) no-error.
      if error-status:error then
      do:
             if p-batch > 0 then do:      run write-log-and-file in p-log-handle (                 input 1                                          , input p-log-file-name                              , input 1                                          , input substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6"                           ,vss-workfile                           ,vss-revision                           ,vss-description                           ,chr(10)                           , error-status:get-message(1)                           , return-value )).    end.    else do:       run write-to-log in p-log-handle ( input substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6"                           ,vss-workfile                           ,vss-revision                           ,vss-description                           ,chr(10)                           , error-status:get-message(1)                           , return-value )).    end.
      end.
   end.
   else
   do:
      run rep/r-new-shift3.p (
         input parparentproc
         ,input p-parent-handle
         ,input p-log-handle
         ,input p-cont-handle
         ,input p-rebh
         ,input v-report-name-html
         ,input p-xsd-file
         ,input p-log-file-name
         ,input p-batch
         ,input p-codex-id
         ,input p-ruleset-id
         ,input p-obj-type
         ,input p-obj-code
         ,input p-z-number-list
         ,input xClassify
         ,input xSortType
         ,input xtog-level
         ,input xvar-level
         ,input v-previous-shift-date
         ) no-error.
      if error-status:error then
      do:
             if p-batch > 0 then do:      run write-log-and-file in p-log-handle (                 input 1                                          , input p-log-file-name                              , input 1                                          , input substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6"                           ,vss-workfile                           ,vss-revision                           ,vss-description                           ,chr(10)                           , error-status:get-message(1)                           , return-value )).    end.    else do:       run write-to-log in p-log-handle ( input substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6"                           ,vss-workfile                           ,vss-revision                           ,vss-description                           ,chr(10)                           , error-status:get-message(1)                           , return-value )).    end.
      end.
   end.
   if tog-last <> "tog-3" then
   do:
      output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' .
      put stream OutStr-html unformatted
         substitute (
         '
        </table>
        '
         , chr(123), chr(125)
         ).
      output stream OutStr-html close.
   end.
   else
      run last-line-tog-html in this-procedure (
         input v-report-name-html
         ).
end.
if tog-4 = true then
do:
   run first-line-tog4-html in this-procedure (
      input v-report-name-html
      ).
   if v-param-code = 3 then
   do:
      run rep/r-new-shift4_3.p (
         input parparentproc
         ,input p-parent-handle
         ,input p-log-handle
         ,input p-cont-handle
         ,input p-rebh
         ,input v-report-name-html
         ,input p-xsd-file
         ,input p-log-file-name
         ,input p-batch
         ,input p-codex-id
         ,input p-ruleset-id
         ,input p-obj-type
         ,input p-obj-code
         ,input p-z-number-list
         ,input v-previous-shift-date
         ,input v-param) no-error.
      if error-status:error then
      do:
             if p-batch > 0 then do:      run write-log-and-file in p-log-handle (                 input 1                                          , input p-log-file-name                              , input 1                                          , input substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6"                           ,vss-workfile                           ,vss-revision                           ,vss-description                           ,chr(10)                           , error-status:get-message(1)                           , return-value )).    end.    else do:       run write-to-log in p-log-handle ( input substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6"                           ,vss-workfile                           ,vss-revision                           ,vss-description                           ,chr(10)                           , error-status:get-message(1)                           , return-value )).    end.
      end.
   end.
   else
   do:
      run rep/r-new-shift4.p (
         input parparentproc
         ,input p-parent-handle
         ,input p-log-handle
         ,input p-cont-handle
         ,input p-rebh
         ,input v-report-name-html
         ,input p-xsd-file
         ,input p-log-file-name
         ,input p-batch
         ,input p-codex-id
         ,input p-ruleset-id
         ,input p-obj-type
         ,input p-obj-code
         ,input p-z-number-list
         ,input v-previous-shift-date
         ,input v-param) no-error.
      if error-status:error then
      do:
             if p-batch > 0 then do:      run write-log-and-file in p-log-handle (                 input 1                                          , input p-log-file-name                              , input 1                                          , input substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6"                           ,vss-workfile                           ,vss-revision                           ,vss-description                           ,chr(10)                           , error-status:get-message(1)                           , return-value )).    end.    else do:       run write-to-log in p-log-handle ( input substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6"                           ,vss-workfile                           ,vss-revision                           ,vss-description                           ,chr(10)                           , error-status:get-message(1)                           , return-value )).    end.
      end.
   end.
   if tog-last <> "tog-4" then
   do:
      output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' .
      put stream OutStr-html unformatted
         substitute (
         '
        </table>
        '
         , chr(123), chr(125)
         ).
      output stream OutStr-html close.
   end.
   else
      run last-line-tog-html in this-procedure (
         input v-report-name-html
         ).
end.
if tog-5 = yes then
do:
   run first-line-tog5-html in this-procedure (
      input v-report-name-html
      ).
   run rep/r-new-shift5.p (
      input parparentproc
      ,input p-parent-handle
      ,input p-log-handle
      ,input p-cont-handle
      ,input p-rebh
      ,input v-report-name-html
      ,input p-xsd-file
      ,input p-log-file-name
      ,input p-batch
      ,input p-codex-id
      ,input p-ruleset-id
      ,input p-obj-type
      ,input p-obj-code
      ) no-error.
   if error-status:error then
   do:
          if p-batch > 0 then do:      run write-log-and-file in p-log-handle (                 input 1                                          , input p-log-file-name                              , input 1                                          , input substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6"                           ,vss-workfile                           ,vss-revision                           ,vss-description                           ,chr(10)                           , error-status:get-message(1)                           , return-value )).    end.    else do:       run write-to-log in p-log-handle ( input substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6"                           ,vss-workfile                           ,vss-revision                           ,vss-description                           ,chr(10)                           , error-status:get-message(1)                           , return-value )).    end.
   end.
   if tog-last <> "tog-5" then
   do:
      output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' .
      put stream OutStr-html unformatted
         substitute (
         '
        </table>
        '
         , chr(123), chr(125)
         ).
      output stream OutStr-html close.
   end.
   else
      run last-line-tog-html in this-procedure (
         input v-report-name-html
         ).
End.
if tog-5-1 = yes then
do:
   run first-line-tog5-1-html in this-procedure (
      input v-report-name-html
      ).
   run rep/r-new-shift5-1.p (
      input parparentproc
      ,input p-parent-handle
      ,input p-log-handle
      ,input p-cont-handle
      ,input p-rebh
      ,input p-rdbh
      ,input v-report-name-html
      ,input p-log-file-name
      ,input p-batch
      ,input p-codex-id
      ,input p-ruleset-id
      ,input p-obj-type
      ,input p-obj-code
      ) no-error.
   if error-status:error then
   do:
          if p-batch > 0 then do:      run write-log-and-file in p-log-handle (                 input 1                                          , input p-log-file-name                              , input 1                                          , input substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6"                           ,vss-workfile                           ,vss-revision                           ,vss-description                           ,chr(10)                           , error-status:get-message(1)                           , return-value )).    end.    else do:       run write-to-log in p-log-handle ( input substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6"                           ,vss-workfile                           ,vss-revision                           ,vss-description                           ,chr(10)                           , error-status:get-message(1)                           , return-value )).    end.
   end.
   if tog-last <> "tog-5-1" then
   do:
      output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' .
      put stream OutStr-html unformatted
         substitute (
         '
        </table>
        '
         , chr(123), chr(125)
         ).
      output stream OutStr-html close.
   end.
   else
      run last-line-tog-html5-1 in this-procedure (
         input v-report-name-html
         ).
End.
if tog-7 = yes then
DO:
   run first-line-tog7-html in this-procedure (
      input v-report-name-html
      ).
   run rep/r-new-shift7.p
      ( input parparentproc
      ,input p-parent-handle
      ,input p-log-handle
      ,input p-cont-handle
      ,input p-rebh
      ,input v-report-name-html
      ,input p-xsd-file
      ,input p-log-file-name
      ,input p-batch
      ,input p-codex-id
      ,input p-ruleset-id
      ,input p-obj-type
      ,input p-obj-code
      ,input v-previous-shift-date
      ) no-error.
   if error-status:error then
   do:
          if p-batch > 0 then do:      run write-log-and-file in p-log-handle (                 input 1                                          , input p-log-file-name                              , input 1                                          , input substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6"                           ,vss-workfile                           ,vss-revision                           ,vss-description                           ,chr(10)                           , error-status:get-message(1)                           , return-value )).    end.    else do:       run write-to-log in p-log-handle ( input substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6"                           ,vss-workfile                           ,vss-revision                           ,vss-description                           ,chr(10)                           , error-status:get-message(1)                           , return-value )).    end.
   end.
   if tog-last <> "tog-7" then
   do:
      output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' .
      put stream OutStr-html unformatted
         substitute (
         '
            </table>
            '
         , chr(123), chr(125)
         ).
      output stream OutStr-html close.
   end.
   else
      run last-line-tog-html in this-procedure (
         input v-report-name-html
         ).
End.
if tog-81 then
DO:
   run first-line-tog8-html in this-procedure (
      input v-report-name-html
      ).
   run rep/r-new-shift8.p
      (
      input parparentproc
      ,INPUT p-obj-type
      ,INPUT p-obj-code
      ,INPUT tog-82
      ,v-report-name-html
      ,v-report-result
      ) no-error .
   if tog-last <> "tog-81" then
   do:
      output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' .
      put stream OutStr-html unformatted
         substitute (
         '
<tbody><thead>
<tr><td colspan="7">«Частичный возврат» - это: </td></tr>
<tr><td colspan="7">«Частичный возврат» - возврат, который был проведен на недолитое топливо по транзакции на АРМ Кассира</td></tr>
<tr><td colspan="7">«Остальные возвраты» - это:</td></tr>
<tr><td colspan="7">«Полный по номеру чека» - полный возврат, который был проведен по номеру чека на АРМ Кассира</td></tr>
<tr><td colspan="7">«Частичный по номеру чека» - частичный возврат, который был проведен по номеру чека на АРМ Кассира</td></tr>
<tr><td colspan="7">«Полный по транзакции» - полный возврат, который был проведен по транзакции на АРМ Кассира</td></tr>
<tr><td colspan="7">«Сухой чек, созданный в ППО Trade House» - сухой возврат, который был проведен на АРМ Кассира</td></tr>
<tr><td colspan="7">«Сухой чек, проведенный на АРМ Кассира» - сухой возврат, который был проведен на АРМ Кассира</td></tr>
</thead>
</tbody>
</table>'
         , chr(123), chr(125)
         ).
      output stream OutStr-html close.
   end.
   else
      run last-line-tog-html81 in this-procedure (
         input v-report-name-html
         ).
   v-report-result = YES.
END.
if tog-9 then
DO:
   run first-line-tog9-html in this-procedure (
      input v-report-name-html
      ).
   run rep/r-new-shift9.p   (
      input parparentproc
      ,input p-parent-handle
      ,input p-log-handle
      ,input p-cont-handle
      ,input p-rebh
      ,input v-report-name-html
      ,input p-xsd-file
      ,input p-log-file-name
      ,input p-batch
      ,input p-codex-id
      ,input p-ruleset-id
      ,INPUT p-obj-type
      ,INPUT p-obj-code
      ,INPUT x-date-Start
      ,INPUT x-Shift-Start
      ,INPUT x-date-End
      ,INPUT x-Shift-End
      ,input tog-1-out-pump-with-icnt
      ) no-error .
   if error-status:error then
   do:
          if p-batch > 0 then do:      run write-log-and-file in p-log-handle (                 input 1                                          , input p-log-file-name                              , input 1                                          , input substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6"                           ,vss-workfile                           ,vss-revision                           ,vss-description                           ,chr(10)                           , error-status:get-message(1)                           , return-value )).    end.    else do:       run write-to-log in p-log-handle ( input substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6"                           ,vss-workfile                           ,vss-revision                           ,vss-description                           ,chr(10)                           , error-status:get-message(1)                           , return-value )).    end.
   end.
   if tog-last <> "tog-9" then
   do:
      output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' .
      put stream OutStr-html unformatted
         substitute (
         '
               </table>
        '
         , chr(123), chr(125)
         ).
      output stream OutStr-html close.
   end.
   else
      run last-line-tog-html in this-procedure (
         input v-report-name-html
         ).
End.
if tog-10 then
DO:
   run first-line-tog10-html in this-procedure (
      input v-report-name-html
      ).
   run rep/r-new-shift10.p   (
      input parparentproc
      ,input p-parent-handle
      ,input p-log-handle
      ,input p-cont-handle
      ,input p-rebh
      ,input v-report-name-html
      ,input p-xsd-file
      ,input p-log-file-name
      ,input p-batch
      ,input p-codex-id
      ,input p-ruleset-id
      ,INPUT p-obj-type
      ,INPUT p-obj-code
      ,INPUT x-date-Start
      ,INPUT x-Shift-Start
      ,INPUT x-date-End
      ,INPUT x-Shift-End
      ) no-error .
   if error-status:error then
   do:
          if p-batch > 0 then do:      run write-log-and-file in p-log-handle (                 input 1                                          , input p-log-file-name                              , input 1                                          , input substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6"                           ,vss-workfile                           ,vss-revision                           ,vss-description                           ,chr(10)                           , error-status:get-message(1)                           , return-value )).    end.    else do:       run write-to-log in p-log-handle ( input substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6"                           ,vss-workfile                           ,vss-revision                           ,vss-description                           ,chr(10)                           , error-status:get-message(1)                           , return-value )).    end.
   end.
   run last-line-tog-html in this-procedure (
      input v-report-name-html
      ).
End.
if p-batch = integer('0':U) then
do:
   define variable rep-password         as logical   no-undo .
   define variable excel-string      as character no-undo .
   define variable v-excel           as character no-undo .
   run adm/shattri.p (
      input "get":U
      ,input  ""
      ,input  0
      ,input  'report-glob':U
      ,input  'rep-password':U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output rep-password
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      )  .
   if rep-password then excel-string = "TRUE" .
   else excel-string = "FALSE" .
   run prn-lib-reportviewer in this-procedure (
      input parparentproc
      ,input v-report-name-html
      ,input "PASSWORD:" + excel-string
      ) .
   if error-status:error then
   do:
      message return-value view-as alert-box.
      return .
   end.
end.
procedure first-line-tog1-html :
   define input parameter v-report-name-html     as character no-undo .
   if v-param-code = 3 then
   do:
      output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' .
      put stream OutStr-html unformatted
         substitute(
         '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       width: 1400px; 
                   ~}
                   .class1 ~{
                       border-collapse: collapse;
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист1" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:50px"></td>
                        <td style="width:30px"></td>
                        <td style="width:30px"></td>
                        <td style="width:80px"></td>
                        <td style="width:80px"></td>
                        <td style="width:80px"></td>
                        <td style="width:60px"></td>
                        <td style="width:50px"></td>
                        <td style="width:60px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:65px"></td>
                        <td style="width:65px"></td>
                        <td style="width:65px"></td>
                        <td style="width:65px"></td>
                        <td style="width:65px"></td>
                        <td style="width:80px"></td>
                        <td style="width:60px"></td>
                      </tr>
                    <tr>
                      <td colspan="22"></td>
                    </tr>
                    <tr>
                      <td colspan="22" >&2</td>
                    </tr>
                    <tr>
                      <td colspan="22" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                    </tr>
                    <tr>
                      <td colspan="22" style="font-size:16px;font-weight:bold; text-align: center;">Часть №1 Движение нефтепродуктов по количеству</td>
                    </tr>'
         ,
         v-host-name,
         rep-shift-store-name
         ).
      if v-one-shift then
      do:
         put stream OutStr-html unformatted
            '<tr><td colspan="22">Смена: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + '</td></tr>' skip
            .
      end.
      else
      do:
         put stream OutStr-html unformatted
            '<tr><td colspan="22">Смены с: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + ' по ' + string(X-Shift-End) + ' от ' + String(x-date-end , "99.99.9999") + ' ' + String( v-rep-shift-close-time,"hh:mm") + '</td></tr>' skip
            .
      end.
      put stream OutStr-html unformatted
         '<tr>' skip
         '<td colspan="22"> Закрыта ' + string(v-rep-shift-close-date,"99.99.9999") + " " + string(v-rep-shift-close,"hh:mm") + '</td>' skip
         '</tr>' skip
         '<tr>' skip
         '<td colspan="22"> Старший смены: ' + rep-shift-for-mng1 + '</td>' skip
         '</tr>' skip
         '<tr>' skip
         '<td colspan="22"> Операторы: ' + rep-shift-for-opers1 + '</td>' skip
         '</tr>' skip
         '<tr>' skip
         '<td colspan="22"></td>' skip
         '</tr>' skip
         '</thead>' skip
         .
      output stream OutStr-html close.
   end.
   else
   do:
      if v-param-code = 2 then
      do:
         output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' .
         put stream OutStr-html unformatted
            substitute(
            '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       width: 1400px; 
                   ~}
                   .class1 ~{
                       border-collapse: collapse;
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист1" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:170px"></td>
                        <td style="width:30px"></td>
                        <td style="width:80px"></td>
                        <td style="width:80px"></td>
                        <td style="width:30px"></td>
                        <td style="width:80px"></td>
                        <td style="width:80px"></td>
                        <td style="width:80px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                      </tr>
                    <tr>
                      <td colspan="20"></td>
                    </tr>
                    <tr>  
                      <td colspan="5" style="border-bottom: 1px solid black; text-align: center;">&1</td>
                      <td colspan="15"></td>
                    </tr>
                    <tr>
                      <td colspan="5" style="font-size:10px; text-align: center;">наименование организации</td>
                      <td colspan="15"></td>
                    </tr>
                    <tr>
                      <td colspan="20" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ &2</td>
                    </tr>
                    <tr>
                      <td colspan="20" style="text-align: center;"> от &3 </td>
                    </tr>
                    <tr>
                      <td colspan="20"> Смены  с &4  по &5 </td>
                    </tr>
                    <tr>
                      <td colspan="20"> </td>
                    </tr>'
            ,
            v-host-name,
            string(ub.clients.obj-name),
            string(v-rep-shift-close-date,"99.99.9999"),
            string(X-Shift-Start) + ' от ' + String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm"),
            string(X-Shift-End) + ' от ' + String(v-rep-shift-close-date , "99.99.9999") + ' ' + String ( v-rep-shift-close-time,"hh:mm")
            ).
         put stream OutStr-html unformatted
            substitute (
            '<tr> 
            <td colspan="3" style="height:30px;"> Состав смены:</td>
            <td colspan="4" style="border-bottom: 1px solid black; text-align: center;">&1</td>
            <td></td>
            <td colspan="3" style="border-bottom: 1px solid black; text-align: center;">&2</td>
            <td></td>
            <td colspan="4" style="border-bottom: 1px solid black; text-align: center;">&3</td>
            <td></td>
            <td colspan="3" style="border-bottom: 1px solid black; text-align: center;">&4</td>
          </tr>
          <tr> 
            <td colspan="3"></td>
            <td colspan="4" style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td colspan="3" style="font-size:10px; text-align: center;">инициалы, фамилия</td>
            <td></td>
            <td colspan="4" style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td colspan="3" style="font-size:10px; text-align: center;">инициалы, фамилия</td>
          </tr>
          <tr> 
            <td colspan="3" style="height:30px;"></td>
            <td colspan="4" style="border-bottom: 1px solid black; text-align: center;">&5</td>
            <td></td>
            <td colspan="3" style="border-bottom: 1px solid black; text-align: center;">&6</td>
            <td></td>
            <td colspan="4" style="border-bottom: 1px solid black; text-align: center;">&7</td>
            <td></td>
            <td colspan="3" style="border-bottom: 1px solid black; text-align: center;">&8</td>
          </tr>
          <tr> 
            <td colspan="3"></td>
            <td colspan="4" style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td colspan="3" style="font-size:10px; text-align: center;">инициалы, фамилия</td>
            <td></td>
            <td colspan="4" style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td colspan="3" style="font-size:10px; text-align: center;">инициалы, фамилия</td>
          </tr>
          <tr>
            <td colspan="20" style="height:30px;"></td>
          </tr>
          </thead>'
            ,
            rep-shift-rol-mng,
            rep-shift-for-mng1,
            rep-shift-rol-mng2,
            rep-shift-for-mng2,
            rep-shift-rol-oper,
            rep-shift-for-opers1,
            rep-shift-rol-oper2,
            rep-shift-for-opers2
            ).
         output stream OutStr-html close.
      end.
      else
      do:
         output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' .
         put stream OutStr-html unformatted
            substitute(
            '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       width: 1400px; 
                   ~}
                   .class1 ~{
                       border-collapse: collapse;
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист1" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                      <tr class="set_columns">
                        <td style="width:170px"></td>
                        <td style="width:30px"></td>
                        <td style="width:80px"></td>
                        <td style="width:80px"></td>
                        <td style="width:30px"></td>
                        <td style="width:80px"></td>
                        <td style="width:80px"></td>
                        <td style="width:80px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                      </tr>
                    <tr>
                      <td colspan="21"></td>
                    </tr>
                    <tr>
                      <td colspan="21" >&2</td>
                    </tr>
                    <tr>
                      <td colspan="21" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                    </tr>
                    <tr>
                      <td colspan="21" style="font-size:16px;font-weight:bold; text-align: center;">Часть №1 Движение нефтепродуктов по количеству</td>
                    </tr>
                    <tr>
                      <td colspan="21"> Смены  с &3  по &4 </td>
                    </tr>
                    <tr>
                      <td colspan="21"> Закрыта &5 </td>
                    </tr>
                    <tr>
                      <td colspan="21"> Старший смены: &6 </td>
                    </tr>
                    <tr>
                      <td colspan="21"> Операторы: &7 </td>
                    </tr>
                    <tr>
                      <td colspan="21"></td>
                    </tr>
                    </thead>'
            ,
            v-host-name,
            rep-shift-store-name,
            string(X-Shift-Start) + ' от ' + String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm"),
            string(X-Shift-End) + ' от ' + String(v-rep-shift-close-date , "99.99.9999") + ' ' + String ( v-rep-shift-close-time,"hh:mm"),
            string(v-rep-shift-close-date,"99.99.9999"),
            rep-shift-for-mng1,
            rep-shift-for-opers1
            ).
         output stream OutStr-html close.
      end.
   end.
   assign
      v-report-result = yes.
End procedure.
procedure first-line-tog2-html :
   define input parameter v-report-name-html     as character no-undo .
   if v-param-code = 1 and v-report-result = no then
   do:
      output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' .
      put stream OutStr-html unformatted
         substitute(
         '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       width: 1400px; 
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист2" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:70px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:60px"></td>
                        <td style="width:60px"></td>
                        <td style="width:80px"></td>
                        <td style="width:70px"></td>
                        <td style="width:90px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:30px"></td>
                        <td style="width:80px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:80px"></td>
                                             
                      </tr>
                    <tr>
                      <td colspan="16" >&2</td>
                    </tr>
                    <tr>
                      <td colspan="16" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                    </tr>
                    <tr>
                      <td colspan="16" style="font-size:16px;font-weight:bold; text-align: center;">Часть №2 Движение нефтепродуктов по количеству и суммам</td>
                    </tr>
                    </tr>'
                    ,
            v-host-name,
            rep-shift-store-name
            ).
       if v-one-shift then
       do:
          put stream OutStr-html unformatted
             '<tr><td colspan="16">Смена: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + '</td></tr>' skip
             .
       end.
       else
       do:
          put stream OutStr-html unformatted
             '<tr><td colspan="16">Смены с: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + ' по ' + string(X-Shift-End) + ' от ' + String(x-date-end , "99.99.9999") + ' ' + String( v-rep-shift-close-time,"hh:mm") + '</td></tr>' skip
             .
       end.
       put stream OutStr-html unformatted
          '<tr>' skip
          '<td colspan="16"> Закрыта ' + string(v-rep-shift-close-date,"99.99.9999") + " " + string(v-rep-shift-close,"hh:mm") + '</td>' skip
          '</tr>' skip
          '<tr>' skip
          '<td colspan="16"> Старший смены: ' + rep-shift-for-mng1 + '</td>' skip
          '</tr>' skip
          '<tr>' skip
          '<td colspan="16"> Операторы: ' + rep-shift-for-opers1 + '</td>' skip
          '</tr>' skip
          '<tr>' skip
          '<td colspan="16"></td>' skip
          '</tr>' skip
          '</thead>' skip
          .
       output stream OutStr-html close.
    end.
    if v-param-code = 2 and v-report-result = no then
    do:
        output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' .
        put stream OutStr-html unformatted
            substitute(
            '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       width: 1400px; 
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист2" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:70px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:60px"></td>
                        <td style="width:60px"></td>
                        <td style="width:80px"></td>
                        <td style="width:70px"></td>
                        <td style="width:90px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:30px"></td>
                        <td style="width:80px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:80px"></td>
                        <td style="width:60px"></td>
                        <td style="width:60px"></td>   
                    <tr>
                      <td colspan="18"></td>
                    </tr>
                    <tr>  
                      <td colspan="5" style="border-bottom: 1px solid black; text-align: center;">&1</td>
                      <td colspan="13"></td>
                    </tr>
                    <tr>
                      <td colspan="5" style="font-size:10px; text-align: center;">наименование организации</td>
                      <td colspan="13"></td>
                    </tr>
                    <tr>
                      <td colspan="18" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ &2</td>
                    </tr>
                    <tr>
                      <td colspan="18" style="text-align: center;"> от &3 </td>
                    </tr>
                    <tr>
                      <td colspan="18"> Смены  с &4  по &5 </td>
                    </tr>
                    <tr>
                      <td colspan="18"> </td>
                    </tr>'
         ,
         rep-shift-store-name,
         string(ub.clients.obj-name),
         string(v-rep-shift-close-date,"99.99.9999"),
         string(X-Shift-Start) + ' от ' + String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm"),
         string(X-Shift-End) + ' от ' + String(v-rep-shift-close-date , "99.99.9999") + ' ' + String ( v-rep-shift-close-time,"hh:mm")
         ).
      put stream OutStr-html unformatted
         substitute (
         '<tr> 
            <td colspan="3" style="height:30px;"> Состав смены:</td>
            <td colspan="3" style="border-bottom: 1px solid black; text-align: center;">&1</td>
            <td></td>
            <td colspan="3" style="border-bottom: 1px solid black; text-align: center;">&2</td>
            <td></td>
            <td colspan="3" style="border-bottom: 1px solid black; text-align: center;">&3</td>
            <td></td>
            <td colspan="3" style="border-bottom: 1px solid black; text-align: center;">&4</td>
          </tr>
          <tr> 
            <td colspan="3"></td>
            <td colspan="3" style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td colspan="3" style="font-size:10px; text-align: center;">инициалы, фамилия</td>
            <td></td>
            <td colspan="3" style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td colspan="3" style="font-size:10px; text-align: center;">инициалы, фамилия</td>
          </tr>
          <tr> 
            <td colspan="3" style="height:30px;"></td>
            <td colspan="3" style="border-bottom: 1px solid black; text-align: center;">&5</td>
            <td></td>
            <td colspan="3" style="border-bottom: 1px solid black; text-align: center;">&6</td>
            <td></td>
            <td colspan="3" style="border-bottom: 1px solid black; text-align: center;">&7</td>
            <td></td>
            <td colspan="3" style="border-bottom: 1px solid black; text-align: center;">&8</td>
          </tr>
          <tr> 
            <td colspan="3"></td>
            <td colspan="3" style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td colspan="3" style="font-size:10px; text-align: center;">инициалы, фамилия</td>
            <td></td>
            <td colspan="3" style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td colspan="3" style="font-size:10px; text-align: center;">инициалы, фамилия</td>
          </tr>
          <tr>
            <td colspan="18" style="height:30px;"></td>
          </tr>
          </thead>'
         ,
         rep-shift-rol-mng,
         rep-shift-for-mng1,
         rep-shift-rol-mng2,
         rep-shift-for-mng2,
         rep-shift-rol-oper,
         rep-shift-for-opers1,
         rep-shift-rol-oper2,
         rep-shift-for-opers2
            ).
        output stream OutStr-html close.
    end.
    if v-param-code = 3 then
    do:
        if v-report-result = no then
        do:
         output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' .
         put stream OutStr-html unformatted
            substitute(
            '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       width: 1400px; 
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист2" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:70px"></td>
                        <td style="width:50px"></td>
                        <td style="width:60px"></td>
                        <td style="width:110px"></td>
                        <td style="width:90px"></td>
                        <td style="width:80px"></td>
                        <td style="width:60px"></td>
                        <td style="width:40px"></td>
                        <td style="width:60px"></td>
                        <td style="width:110px"></td>
                        <td style="width:60px"></td>
                        <td style="width:80px"></td>
                        <td style="width:80px"></td>
                        <td style="width:70px"></td>
                        <td style="width:60px"></td>
                        <td style="width:70px"></td>                        
                        <td style="width:60px"></td>
                      </tr>
                    <tr>
                      <td colspan="17" > &2 </td>
                    </tr>
                    <tr>
                      <td colspan="17" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                    </tr>
                    <tr>
                      <td colspan="17" style="font-size:16px;font-weight:bold; text-align: center;">Часть №2 Движение нефтепродуктов по количеству и суммам</td>
                    </tr>'
                    ,v-host-name,
                    rep-shift-store-name) .
                           if v-one-shift then
       do:
          put stream OutStr-html unformatted
             '<tr><td colspan="16">Смена: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + '</td></tr>' skip
             .
       end.
       else
       do:
          put stream OutStr-html unformatted
             '<tr><td colspan="16">Смены с: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + ' по ' + string(X-Shift-End) + ' от ' + String(x-date-end , "99.99.9999") + ' ' + String( v-rep-shift-close-time,"hh:mm") + '</td></tr>' skip
             .
       end.
         put stream OutStr-html unformatted
            substitute('
                    <tr>
                      <td colspan="17"> Закрыта &5 </td>
                    </tr>
                    <tr>
                      <td colspan="17"> Старший смены: &6 </td>
                    </tr>
                    <tr>
                      <td colspan="17"> Операторы: &7 </td>
                    </tr>
                    <tr>
                    <td colspan="17" style="height:30px;"></td>
                    </tr>                    
                    </thead>'
            ,
            v-host-name,
            rep-shift-store-name,
            string(X-Shift-Start) + ' от ' + String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm"),
            string(X-Shift-End) + ' от ' + String(v-rep-shift-close-date , "99.99.9999") + ' ' + String ( v-rep-shift-close-time,"hh:mm"),
            string(v-rep-shift-close-date,"99.99.9999"),
            rep-shift-for-mng1,
            rep-shift-for-opers1
            ).
         output stream OutStr-html close.
      end.
      else
      do:
         output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' .
         put stream OutStr-html unformatted
            substitute(
            '       <table orientation="landscape" name="лист2" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:70px"></td>
                        <td style="width:50px"></td>
                        <td style="width:60px"></td>
                        <td style="width:110px"></td>
                        <td style="width:90px"></td>
                        <td style="width:80px"></td>
                        <td style="width:60px"></td>
                        <td style="width:40px"></td>
                        <td style="width:60px"></td>
                        <td style="width:110px"></td>
                        <td style="width:60px"></td>
                        <td style="width:80px"></td>
                        <td style="width:80px"></td>
                        <td style="width:70px"></td>
                        <td style="width:60px"></td>
                        <td style="width:70px"></td>                        
                        <td style="width:60px"></td>
                        <td style="width:60px"></td>
                      </tr>
                    <tr>
                      <td colspan="17" style="height:30px;"></td>
                    </tr>
                    <tr>
                      <td colspan="17" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                    </tr>
                    <tr>
                      <td colspan="17" style="font-size:16px;font-weight:bold; text-align: center;">Часть №2 Движение нефтепродуктов по количеству и суммам</td>
                    </tr>
                    <tr>
                      <td colspan="17" style="height:30px;"></td>
                    </tr>
                    </thead>'
            ,chr(123), chr(125)
            ).
         output stream OutStr-html close.
      end.
   end.
   if v-report-result = yes and v-param-code <> 3 then
   do:
      output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' .
      put stream OutStr-html unformatted
         substitute(
         '       <table orientation="landscape" name="лист2" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:70px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:60px"></td>
                        <td style="width:60px"></td>
                        <td style="width:80px"></td>
                        <td style="width:70px"></td>
                        <td style="width:90px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:30px"></td>
                        <td style="width:80px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:80px"></td>
                        <td style="width:60px"></td>
                 
                      </tr>
                    <tr>
                      <td colspan="17" style="height:30px;"></td>
                    </tr>
                    <tr>
                      <td colspan="17" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                    </tr>
                    <tr>
                      <td colspan="17" style="font-size:16px;font-weight:bold; text-align: center;">Часть №2 Движение нефтепродуктов по количеству и суммам</td>
                    </tr>
                    <tr>
                      <td colspan="17" style="height:30px;"></td>
                    </tr>                    
                    </thead>'
            ,chr(123), chr(125)
            ).
        output stream OutStr-html close.
    end.
    assign
        v-report-result = yes.
End procedure.
procedure first-line-tog3-html :
   define input parameter v-report-name-html     as character no-undo .
   if v-param-code = 1 and v-report-result = no then
   do:
      output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' .
      put stream OutStr-html unformatted
         substitute(
         '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       width: 1400px;
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист3" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:120px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:100px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:120px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                      </tr>
                      <tr>  
                        <td colspan="13" >&1</td>
                      </tr>
                      <tr>
                        <td colspan="13" >&2</td>
                      </tr>
                      <tr>
                        <td colspan="13" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                      </tr>
                      <tr>
                        <td colspan="13" style="font-size:16px;font-weight:bold; text-align: center;">Часть №3 Движение ТНП по количеству и суммам</td>
                      </tr>
                    </tr>'
         ,
         v-host-name,
         rep-shift-store-name
         ).
       if v-one-shift then
       do:
          put stream OutStr-html unformatted
             '<tr><td colspan="13">Смена: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + '</td></tr>' skip
             .
       end.
       else
       do:
          put stream OutStr-html unformatted
             '<tr><td colspan="13">Смены с: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + ' по ' + string(X-Shift-End) + ' от ' + String(x-date-end , "99.99.9999") + ' ' + String( v-rep-shift-close-time,"hh:mm") + '</td></tr>' skip
             .
       end.
       put stream OutStr-html unformatted
          '<tr>' skip
          '<td colspan="13"> Закрыта ' + string(v-rep-shift-close-date,"99.99.9999") + " " + string(v-rep-shift-close,"hh:mm") + '</td>' skip
          '</tr>' skip
          '<tr>' skip
          '<td colspan="13"> Старший смены: ' + rep-shift-for-mng1 + '</td>' skip
          '</tr>' skip
          '<tr>' skip
          '<td colspan="13"> Операторы: ' + rep-shift-for-opers1 + '</td>' skip
          '</tr>' skip
          '<tr>' skip
          '<td colspan="13"></td>' skip
          '</tr>' skip
          '</thead>' skip
          .
       output stream OutStr-html close.
    end.
    if v-param-code = 2 and v-report-result = no then
    do:
        output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' .
        put stream OutStr-html unformatted
            substitute(
            '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       width: 1400px; 
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист3" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:120px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:100px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:120px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                      </tr>
                    <tr>
                      <td colspan="13"></td>
                    </tr>
                    <tr>  
                      <td colspan="5" style="border-bottom: 1px solid black; text-align: center;">&1</td>
                      <td colspan="8"></td>
                    </tr>
                    <tr>
                      <td colspan="5" style="font-size:10px; text-align: center;">наименование организации</td>
                      <td colspan="8"></td>
                    </tr>
                    <tr>
                      <td colspan="13" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ &2</td>
                    </tr>
                    <tr>
                      <td colspan="13" style="text-align: center;"> от &3 </td>
                    </tr>
                    <tr>
                      <td colspan="13"> Смены  с &4  по &5 </td>
                    </tr>
                    <tr>
                      <td colspan="13"> </td>
                    </tr>'
         ,
         rep-shift-store-name,
         string(ub.clients.obj-name),
         string(v-rep-shift-close-date,"99.99.9999"),
         string(X-Shift-Start) + ' от ' + String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm"),
         string(X-Shift-End) + ' от ' + String(v-rep-shift-close-date , "99.99.9999") + ' ' + String ( v-rep-shift-close-time,"hh:mm")
         ).
      put stream OutStr-html unformatted
         substitute (
         '<tr> 
            <td colspan="4" style="height:30px;"> Состав смены:</td>
            <td colspan="4" style="border-bottom: 1px solid black; text-align: center;">&1</td>
            <td></td>
            <td colspan="4" style="border-bottom: 1px solid black; text-align: center;">&2</td>
          </tr>
          <tr> 
            <td colspan="4"></td>
            <td colspan="4" style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td colspan="4" style="font-size:10px; text-align: center;">инициалы, фамилия</td>
          <tr> 
            <td colspan="4" style="height:30px;"></td>
            <td colspan="4" style="border-bottom: 1px solid black; text-align: center;">&3</td>
            <td></td>
            <td colspan="4" style="border-bottom: 1px solid black; text-align: center;">&4</td>
          </tr>
          <tr> 
            <td colspan="4"></td>
            <td colspan="4" style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td colspan="4" style="font-size:10px; text-align: center;">инициалы, фамилия</td>
          </tr>
          <tr>
            <td colspan="13" style="height:30px;"></td>
          </tr>      
          </thead>'
         ,
         rep-shift-rol-mng,
         rep-shift-for-mng1,
         rep-shift-rol-oper,
         rep-shift-for-opers1
         ).
      output stream OutStr-html close.
   end.
   if v-param-code = 3 then
   do:
      if v-report-result = no then
      do:
         output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' .
         put stream OutStr-html unformatted
            substitute(
            '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       width: 1400px;
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист3" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:120px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:120px"></td>
                        <td style="width:50px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:120px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                      </tr>
                      <tr>  
                        <td colspan="15" >&1</td>
                      </tr>
                      <tr>
                        <td colspan="15" >&2</td>
                      </tr>
                      <tr>
                        <td colspan="15" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                      </tr>
                      <tr>
                        <td colspan="15" style="font-size:16px;font-weight:bold; text-align: center;">Часть №3 Движение ТНП по количеству и суммам</td>
                      </tr>
                      <tr>
                        <td colspan="15"> Смены  с &3  по &4 </td>
                      </tr>
                      <tr>
                        <td colspan="15"> Закрыта &5 </td>
                      </tr>
                      <tr>
                        <td colspan="15"> Старший смены: &6 </td>
                      </tr>
                      <tr>
                        <td colspan="15"> Операторы: &7 </td>
                      </tr>
                      <tr>
                        <td colspan="15" style="height:30px;"></td>
                      </tr>      
                      </thead>'
            ,
            v-host-name,
            rep-shift-store-name,
            string(X-Shift-Start) + ' от ' + String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm"),
            string(X-Shift-End) + ' от ' + String(v-rep-shift-close-date , "99.99.9999") + ' ' + String ( v-rep-shift-close-time,"hh:mm"),
            string(v-rep-shift-close-date,"99.99.9999"),
            rep-shift-for-mng1,
            rep-shift-for-opers1
            ).
         output stream OutStr-html close.
      end.
      else
      do:
         output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' .
         put stream OutStr-html unformatted
            substitute(
            '<table orientation="landscape" name="лист3" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:120px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:120px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:120px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                      </tr>
                      <tr>
                        <td colspan="15" style="height:30px;"></td>
                      </tr>       
                      <tr>
                        <td colspan="15" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                      </tr>
                      <tr>
                        <td colspan="15" style="font-size:16px;font-weight:bold; text-align: center;">Часть №3 Движение ТНП по количеству и суммам</td>
                      </tr>
                      <tr>
                        <td colspan="15" style="height:30px;"></td>
                      </tr>       
                      </thead>'
            ,chr(123), chr(125)
            ).
         output stream OutStr-html close.
      end.
   end.
   if v-report-result = yes and v-param-code <> 3 then
   do:
      output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' .
      put stream OutStr-html unformatted
         substitute(
         '<table orientation="landscape" name="лист3" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:120px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:120px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:120px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                      </tr>
                      <tr>
                        <td colspan="16" style="height:30px;"></td>
                      </tr>       
                      <tr>
                        <td colspan="16" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                      </tr>
                      <tr>
                        <td colspan="16" style="font-size:16px;font-weight:bold; text-align: center;">Часть №3 Движение ТНП по количеству и суммам</td>
                      </tr>
                      <tr>
                        <td colspan="16" style="height:30px;"></td>
                      </tr>       
                      </thead>'
         ,chr(123), chr(125)
         ).
      output stream OutStr-html close.
   end.
   assign
      v-report-result = yes.
End procedure.
procedure first-line-tog4-html :
   define input parameter v-report-name-html     as character no-undo .
   if v-param-code <> 2 and v-report-result = no then
   do:
      output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' .
      put stream OutStr-html unformatted
         substitute(
         '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       width: 1200px; 
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист4" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:180px"></td>
                        <td style="width:140px"></td>
                        <td style="width:180px"></td>
                        <td style="width:180px"></td>
                        <td style="width:140px"></td>
                        <td style="width:180px"></td>
                      </tr>
                       <tr>  
                        <td colspan="6" >&1</td>
                      </tr>
                      <tr>
                        <td colspan="6" >&2</td>
                      </tr>
                      <tr>
                        <td colspan="6" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                      </tr>
                      <tr>
                        <td colspan="6" style="font-size:16px;font-weight:bold; text-align: center;">Часть №4 Реализация услуг</td>
                    </tr>'
         ,
         v-host-name,
         rep-shift-store-name
         ).
       if v-one-shift then
       do:
          put stream OutStr-html unformatted
             '<tr><td colspan="6">Смена: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + '</td></tr>' skip
             .
       end.
       else
       do:
          put stream OutStr-html unformatted
             '<tr><td colspan="6">Смены с: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + ' по ' + string(X-Shift-End) + ' от ' + String(x-date-end , "99.99.9999") + ' ' + String( v-rep-shift-close-time,"hh:mm") + '</td></tr>' skip
             .
       end.
       put stream OutStr-html unformatted
          '<tr>' skip
          '<td colspan="6"> Закрыта ' + string(v-rep-shift-close-date,"99.99.9999") + " " + string(v-rep-shift-close,"hh:mm") + '</td>' skip
          '</tr>' skip
          '<tr>' skip
          '<td colspan="6"> Старший смены: ' + rep-shift-for-mng1 + '</td>' skip
          '</tr>' skip
          '<tr>' skip
          '<td colspan="6"> Операторы: ' + rep-shift-for-opers1 + '</td>' skip
          '</tr>' skip
          '<tr>' skip
          '<td colspan="6"></td>' skip
          '</tr>' skip
          '</thead>' skip
          .
       output stream OutStr-html close.
    end.
    if v-param-code = 2 and v-report-result = no then
    do:
        if v-param-code = 2 and v-report-result = no then
        do:
            output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' .
            put stream OutStr-html unformatted
                substitute(
                '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       width: 1200px; 
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист4" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:180px"></td>
                        <td style="width:140px"></td>
                        <td style="width:180px"></td>
                        <td style="width:180px"></td>
                        <td style="width:140px"></td>
                        <td style="width:180px"></td>
                      </tr>
                    <tr>
                      <td colspan="6"></td>
                    </tr>
                    <tr>  
                      <td colspan="3" style="border-bottom: 1px solid black; text-align: center;">&1</td>
                      <td colspan="3"></td>
                    </tr>
                    <tr>
                      <td colspan="3" style="font-size:10px; text-align: center;">наименование организации</td>
                      <td colspan="3"></td>
                    </tr>
                    <tr>
                      <td colspan="6" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ &2</td>
                    </tr>
                    <tr>
                      <td colspan="6" style="text-align: center;"> от &3 </td>
                    </tr>
                    <tr>
                      <td colspan="6"> Смены  с &4  по &5 </td>
                    </tr>
                    <tr>
                      <td colspan="6"> </td>
                    </tr>'
            ,
            rep-shift-store-name,
            string(ub.clients.obj-name),
            string(v-rep-shift-close-date,"99.99.9999"),
            string(X-Shift-Start) + ' от ' + String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm"),
            string(X-Shift-End) + ' от ' + String(v-rep-shift-close-date , "99.99.9999") + ' ' + String ( v-rep-shift-close-time,"hh:mm")
            ).
         put stream OutStr-html unformatted
            substitute (
            '<tr> 
            <td style="height:30px;"> Состав смены:</td>
            <td colspan="2" style="border-bottom: 1px solid black; text-align: center;">&1</td>
            <td></td>
            <td colspan="2" style="border-bottom: 1px solid black; text-align: center;">&2</td>
          </tr>
          <tr> 
            <td></td>
            <td colspan="2" style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td colspan="2" style="font-size:10px; text-align: center;">инициалы, фамилия</td>
          <tr> 
            <td style="height:30px;"></td>
            <td colspan="2" style="border-bottom: 1px solid black; text-align: center;">&3</td>
            <td></td>
            <td colspan="2" style="border-bottom: 1px solid black; text-align: center;">&4</td>
          </tr>
          <tr> 
            <td></td>
            <td colspan="2" style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td colspan="2" style="font-size:10px; text-align: center;">инициалы, фамилия</td>
          </tr>
          <tr>
            <td colspan="6" style="height:30px;"></td>
          </tr>       
          </thead>'
            ,
            rep-shift-rol-mng,
            rep-shift-for-mng1,
            rep-shift-rol-oper,
            rep-shift-for-opers1
            ).
         output stream OutStr-html close.
      end.
   end.
   if v-report-result = yes then
   do:
      output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' .
      put stream OutStr-html unformatted
         substitute(
         '        <table orientation="landscape" name="лист4" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:180px"></td>
                        <td style="width:140px"></td>
                        <td style="width:180px"></td>
                        <td style="width:180px"></td>
                        <td style="width:140px"></td>
                        <td style="width:180px"></td>
                      </tr>
                      <tr>
                        <td colspan="6" style="height:30px;"></td>
                      </tr>                          
                      <tr>
                        <td colspan="6" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                      </tr>
                      <tr>
                        <td colspan="6" style="font-size:16px;font-weight:bold; text-align: center;">Часть №4 Реализация услуг</td>
                      </tr>
                      <tr>
                        <td colspan="6" style="height:30px;"></td>
                      </tr>       
                      </thead>'
         ,chr(123), chr(125)
         ).
      output stream OutStr-html close.
   end.
   assign
      v-report-result = yes.
End procedure.
procedure first-line-tog5-html :
   define input parameter v-report-name-html     as character no-undo .
   if v-param-code <> 2 and v-report-result = no then
   do:
      output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' .
      put stream OutStr-html unformatted
         substitute(
         '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       table-layout: fixed;
                       width: 1200px; 
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист5" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:160px"></td>
                        <td style="width:140px"></td>
                        <td style="width:140px"></td>
                        <td style="width:140px"></td>
                        <td style="width:140px"></td>
                        <td style="width:140px"></td>
                        <td style="width:140px"></td>
                      </tr>
                       <tr>  
                        <td colspan="7" >&1</td>
                      </tr>
                      <tr>
                        <td colspan="7" >&2</td>
                      </tr>
                      <tr>
                        <td colspan="7" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                      </tr>
                      <tr>
                        <td colspan="7" style="font-size:16px;font-weight:bold; text-align: center;">Часть №5 Движение материальных ценностей</td>
                      </tr>
                    </tr>'
         ,
         v-host-name,
         rep-shift-store-name
         ).
       if v-one-shift then
       do:
          put stream OutStr-html unformatted
             '<tr><td colspan="7">Смена: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + '</td></tr>' skip
             .
       end.
       else
       do:
          put stream OutStr-html unformatted
             '<tr><td colspan="7">Смены с: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + ' по ' + string(X-Shift-End) + ' от ' + String(x-date-end , "99.99.9999") + ' ' + String( v-rep-shift-close-time,"hh:mm") + '</td></tr>' skip
             .
       end.
       put stream OutStr-html unformatted
          '<tr>' skip
          '<td colspan="7"> Закрыта ' + string(v-rep-shift-close-date,"99.99.9999") + " " + string(v-rep-shift-close,"hh:mm") + '</td>' skip
          '</tr>' skip
          '<tr>' skip
          '<td colspan="7"> Старший смены: ' + rep-shift-for-mng1 + '</td>' skip
          '</tr>' skip
          '<tr>' skip
          '<td colspan="7"> Операторы: ' + rep-shift-for-opers1 + '</td>' skip
          '</tr>' skip
          '<tr>' skip
          '<td colspan="7"></td>' skip
          '</tr>' skip
          '</thead>' skip
          .
       output stream OutStr-html close.
    end.
    if v-param-code = 2 and v-report-result = no then
    do:
        output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' .
        put stream OutStr-html unformatted
            substitute(
            '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       table-layout: fixed;
                       width: 1200px; 
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист5" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:160px"></td>
                        <td style="width:140px"></td>
                        <td style="width:140px"></td>
                        <td style="width:140px"></td>
                        <td style="width:140px"></td>
                        <td style="width:140px"></td>
                        <td style="width:140px"></td>
                      </tr>
                    <tr>
                      <td colspan="7"></td>
                    </tr>
                    <tr>  
                      <td colspan="3" style="border-bottom: 1px solid black; text-align: center;">&1</td>
                      <td colspan="4"></td>
                    </tr>
                    <tr>
                      <td colspan="3" style="font-size:10px; text-align: center;">наименование организации</td>
                      <td colspan="4"></td>
                    </tr>
                    <tr>
                      <td colspan="7" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ &2</td>
                    </tr>
                    <tr>
                      <td colspan="7" style="text-align: center;"> от &3 </td>
                    </tr>
                    <tr>
                      <td colspan="7"> Смены  с &4  по &5 </td>
                    </tr>
                    <tr>
                      <td colspan="7"> </td>
                    </tr>'
         ,
         rep-shift-store-name,
         string(ub.clients.obj-name),
         string(v-rep-shift-close-date,"99.99.9999"),
         string(X-Shift-Start) + ' от ' + String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm"),
         string(X-Shift-End) + ' от ' + String(v-rep-shift-close-date , "99.99.9999") + ' ' + String ( v-rep-shift-close-time,"hh:mm")
         ).
      put stream OutStr-html unformatted
         substitute (
         '<tr> 
            <td colspan="2" style="height:30px;"> Состав смены:</td>
            <td colspan="2" style="border-bottom: 1px solid black; text-align: center;">&1</td>
            <td></td>
            <td colspan="2" style="border-bottom: 1px solid black; text-align: center;">&2</td>
          </tr>
          <tr> 
            <td colspan="2"></td>
            <td colspan="2" style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td colspan="2" style="font-size:10px; text-align: center;">инициалы, фамилия</td>
          <tr> 
            <td colspan="2" style="height:30px;"></td>
            <td colspan="2" style="border-bottom: 1px solid black; text-align: center;">&3</td>
            <td></td>
            <td colspan="2" style="border-bottom: 1px solid black; text-align: center;">&4</td>
          </tr>
          <tr> 
            <td colspan="2"></td>
            <td colspan="2" style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td colspan="2" style="font-size:10px; text-align: center;">инициалы, фамилия</td>
          </tr>
          <tr>
            <td colspan="7" style="height:30px;"></td>
          </tr>       
          </thead>'
         ,
         rep-shift-rol-mng,
         rep-shift-for-mng1,
         rep-shift-rol-oper,
         rep-shift-for-opers1
         ).
      output stream OutStr-html close.
   end.
   if v-report-result = yes then
   do:
      output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' .
      put stream OutStr-html unformatted
         substitute(
         '       <table orientation="landscape" name="лист5" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:160px"></td>
                        <td style="width:140px"></td>
                        <td style="width:140px"></td>
                        <td style="width:140px"></td>
                        <td style="width:140px"></td>
                        <td style="width:140px"></td>
                        <td style="width:140px"></td>
                      </tr>
                      <tr>
                        <td colspan="7" style="height:30px;"></td>
                      </tr>                             
                      <tr>
                        <td colspan="7" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                      </tr>
                      <tr>
                        <td colspan="7" style="font-size:16px;font-weight:bold; text-align: center;">Часть №5 Движение материальных ценностей</td>
                      </tr>
                      <tr>
                        <td colspan="7" style="height:30px;"></td>
                      </tr>       
                      </thead>'
         ,       chr(123), chr(125)
         ).
      output stream OutStr-html close.
   end.
   assign
      v-report-result = yes.
End procedure.
procedure first-line-tog5-1-html :
   define input parameter v-report-name-html     as character no-undo .
   if v-param-code <> 2 and v-report-result = no then
   do:
      output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' .
      put stream OutStr-html unformatted
         substitute(
         '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       table-layout: fixed;
                       width: 1200px; 
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист5" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:150px"></td>
                        <td style="width:150px"></td>
                        <td style="width:150px"></td>
                        <td style="width:150px"></td>
                        <td style="width:150px"></td>
                        <td style="width:150px"></td>
                        <td style="width:150px"></td>
                        <td style="width:150px"></td>
                        <td style="width:150px"></td>
                      </tr>
                       <tr>  
                        <td colspan="7" >&1</td>
                      </tr>
                      <tr>
                        <td colspan="7" >&2</td>
                      </tr>
                      <tr>
                        <td colspan="7" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                      </tr>
                      <tr>
                        <td colspan="7" style="font-size:16px;font-weight:bold; text-align: center;">Часть №5 Движение денежных средств</td>
                      </tr>
                      <tr>
                       <td colspan="7" style="height:30px;"></td>
                      </tr>       
                      </thead>'
         ,
         v-host-name,
         rep-shift-store-name
         ).
       if v-one-shift then
       do:
          put stream OutStr-html unformatted
             '<thead><tr><td colspan="7">Смена: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + '</td></tr>' skip
             .
       end.
       else
       do:
          put stream OutStr-html unformatted
             '<tr><td colspan="7">Смены с: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + ' по ' + string(X-Shift-End) + ' от ' + String(x-date-end , "99.99.9999") + ' ' + String( v-rep-shift-close-time,"hh:mm") + '</td></tr></thead>' skip
             .
       end.
       put stream OutStr-html unformatted
          '<thead>' skip
          '<tr>' skip
          '<td colspan="7"> Закрыта ' + string(v-rep-shift-close-date,"99.99.9999") + " " + string(v-rep-shift-close,"hh:mm") + '</td>' skip
          '</tr>' skip
          '<tr>' skip
          '<td colspan="7"> Старший смены: ' + rep-shift-for-mng1 + '</td>' skip
          '</tr>' skip
          '<tr>' skip
          '<td colspan="7"> Операторы: ' + rep-shift-for-opers1 + '</td>' skip
          '</tr>' skip
          '<tr>' skip
          '<td colspan="7"></td>' skip
          '</tr>' skip
          '</thead>' skip
          .
       output stream OutStr-html close.
    end.
    if v-param-code = 2 and v-report-result = no then
    do:
        output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' .
        put stream OutStr-html unformatted
            substitute(
            '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       table-layout: fixed;
                       width: 1200px; 
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист5" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:150px"></td>
                        <td style="width:150px"></td>
                        <td style="width:150px"></td>
                        <td style="width:150px"></td>
                        <td style="width:150px"></td>
                        <td style="width:150px"></td>
                        <td style="width:150px"></td>
                      </tr>
                    <tr>
                      <td colspan="7"></td>
                    </tr>
                    <tr>  
                      <td colspan="3" style="border-bottom: 1px solid black; text-align: center;">&1</td>
                      <td colspan="4"></td>
                    </tr>
                    <tr>
                      <td colspan="3" style="font-size:10px; text-align: center;">наименование организации</td>
                      <td colspan="4"></td>
                    </tr>
                    <tr>
                      <td colspan="7" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ &2</td>
                    </tr>
                    <tr>
                      <td colspan="7" style="text-align: center;"> от &3 </td>
                    </tr>
                    <tr>
                      <td colspan="7"> Смена  с &4  по &5 </td>
                    </tr>
                    <tr>
                      <td colspan="7"> </td>
                    </tr>'
         ,
         rep-shift-store-name,
         string(ub.clients.obj-name),
         string(v-rep-shift-close-date,"99.99.9999"),
         string(X-Shift-Start) + ' от ' + String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm"),
         string(X-Shift-End) + ' от ' + String(v-rep-shift-close-date , "99.99.9999") + ' ' + String ( v-rep-shift-close-time,"hh:mm")
         ).
      put stream OutStr-html unformatted
         substitute (
         '<tr> 
            <td colspan="2" style="height:30px;"> Состав смены:</td>
            <td colspan="2" style="border-bottom: 1px solid black; text-align: center;">&1</td>
            <td></td>
            <td colspan="2" style="border-bottom: 1px solid black; text-align: center;">&2</td>
          </tr>
          <tr> 
            <td colspan="2"></td>
            <td colspan="2" style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td colspan="2" style="font-size:10px; text-align: center;">инициалы, фамилия</td>
          <tr> 
            <td colspan="2" style="height:30px;"></td>
            <td colspan="2" style="border-bottom: 1px solid black; text-align: center;">&3</td>
            <td></td>
            <td colspan="2" style="border-bottom: 1px solid black; text-align: center;">&4</td>
          </tr>
          <tr> 
            <td colspan="2"></td>
            <td colspan="2" style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td colspan="2" style="font-size:10px; text-align: center;">инициалы, фамилия</td>
          </tr>
          <tr>
            <td colspan="7" style="height:30px;"></td>
          </tr>       
          </thead>'
         ,
         rep-shift-rol-mng,
         rep-shift-for-mng1,
         rep-shift-rol-oper,
         rep-shift-for-opers1
         ).
      output stream OutStr-html close.
   end.
   if v-report-result = yes then
   do:
      output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' .
      put stream OutStr-html unformatted
         substitute(
         '       <table orientation="landscape" name="лист5" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:150px"></td>
                        <td style="width:150px"></td>
                        <td style="width:150px"></td>
                        <td style="width:150px"></td>
                        <td style="width:150px"></td>
                        <td style="width:150px"></td>
                        <td style="width:150px"></td>
                      </tr>
                      <tr>
                        <td colspan="7" style="height:30px;"></td>
                      </tr>                             
                      <tr>
                        <td colspan="7" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                      </tr>
                      <tr>
                        <td colspan="7" style="font-size:16px;font-weight:bold; text-align: center;">Часть №5 Движение денежных средств</td>
                      </tr>
                      <tr>
                        <td colspan="7" style="height:30px;"></td>
                      </tr>       
                      </thead>'
         ,       chr(123), chr(125)
         ).
      output stream OutStr-html close.
   end.
   assign
      v-report-result = yes.
End procedure.
procedure first-line-tog7-html :
   define input parameter v-report-name-html     as character no-undo .
   if v-param-code <> 2 and v-report-result = no then
   do:
      output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' .
      put stream OutStr-html unformatted
         substitute(
         '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       table-layout: fixed;
                       width:1200px; 
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист7" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                        <td style="width:150px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                      </tr>
                       <tr>  
                        <td colspan="5" >&1</td>
                      </tr>
                      <tr>
                        <td colspan="5" >&2</td>
                      </tr>
                      <tr>
                        <td colspan="5" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                      </tr>
                      <tr>
                        <td colspan="5" style="font-size:16px;font-weight:bold; text-align: center;">Часть №7 Погрешности объемомеров ТРК</td>
                    </tr>'
         ,
         v-host-name,
         rep-shift-store-name
         ).
       if v-one-shift then
       do:
          put stream OutStr-html unformatted
             '<tr><td colspan="5">Смена: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + '</td></tr>' skip
             .
       end.
       else
       do:
          put stream OutStr-html unformatted
             '<tr><td colspan="5">Смены с: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + ' по ' + string(X-Shift-End) + ' от ' + String(x-date-end , "99.99.9999") + ' ' + String( v-rep-shift-close-time,"hh:mm") + '</td></tr>' skip
             .
       end.
       put stream OutStr-html unformatted
          '<tr>' skip
          '<td colspan="5"> Закрыта ' + string(v-rep-shift-close-date,"99.99.9999") + " " + string(v-rep-shift-close,"hh:mm") + '</td>' skip
          '</tr>' skip
          '<tr>' skip
          '<td colspan="5"> Старший смены: ' + rep-shift-for-mng1 + '</td>' skip
          '</tr>' skip
          '<tr>' skip
          '<td colspan="5"> Операторы: ' + rep-shift-for-opers1 + '</td>' skip
          '</tr>' skip
          '<tr>' skip
          '<td colspan="5"></td>' skip
          '</tr>' skip
          '</thead>' skip
          .
       output stream OutStr-html close.
    end.
    if v-param-code = 2 and v-report-result = no then
    do:
        output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' .
        put stream OutStr-html unformatted
            substitute(
            '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       table-layout: fixed;
                       width:1200px; 
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист7" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                        <td style="width:150px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                      </tr>
                    <tr>
                      <td colspan="5"></td>
                    </tr>
                    <tr>  
                      <td colspan="2" style="border-bottom: 1px solid black; text-align: center;">&1</td>
                      <td colspan="3"></td>
                    </tr>
                    <tr>
                      <td colspan="2" style="font-size:10px; text-align: center;">наименование организации</td>
                      <td colspan="3"></td>
                    </tr>
                    <tr>
                      <td colspan="5" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ &2</td>
                    </tr>
                    <tr>
                      <td colspan="5" style="text-align: center;"> от &3 </td>
                    </tr>
                    <tr>
                      <td colspan="5"> Смены  с &4  по &5 </td>
                    </tr>
                    <tr>
                      <td colspan="5"> </td>
                    </tr>'
         ,
         rep-shift-store-name,
         string(ub.clients.obj-name),
         string(v-rep-shift-close-date,"99.99.9999"),
         string(X-Shift-Start) + ' от ' + String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm"),
         string(X-Shift-End) + ' от ' + String(v-rep-shift-close-date , "99.99.9999") + ' ' + String ( v-rep-shift-close-time,"hh:mm")
         ).
      put stream OutStr-html unformatted
         substitute (
         '<tr> 
            <td colspan="2" style="height:30px;"> Состав смены:</td>
            <td style="border-bottom: 1px solid black; text-align: center;">&1</td>
            <td></td>
            <td style="border-bottom: 1px solid black; text-align: center;">&2</td>
          </tr>
          <tr> 
            <td colspan="2"></td>
            <td style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td style="font-size:10px; text-align: center;">инициалы, фамилия</td>
          <tr> 
            <td colspan="2" style="height:30px;"></td>
            <td style="border-bottom: 1px solid black; text-align: center;">&3</td>
            <td></td>
            <td style="border-bottom: 1px solid black; text-align: center;">&4</td>
          </tr>
          <tr> 
            <td colspan="2"></td>
            <td style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td style="font-size:10px; text-align: center;">инициалы, фамилия</td>
          </tr>
          <tr>
            <td colspan="5" style="height:30px;"></td>
          </tr>       
          </thead>'
         ,
         rep-shift-rol-mng,
         rep-shift-for-mng1,
         rep-shift-rol-oper,
         rep-shift-for-opers1
         ).
      output stream OutStr-html close.
   end.
   if v-report-result = yes then
   do:
      output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' .
      put stream OutStr-html unformatted
         substitute(
         '       <table orientation="landscape" name="лист7" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                        <td style="width:150px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                      </tr>
                      <tr>
                        <td colspan="5" style="height:30px;"></td>
                      </tr>                          
                      <tr>
                        <td colspan="5" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                      </tr>
                      <tr>
                        <td colspan="5" style="font-size:16px;font-weight:bold; text-align: center;">Часть №7 Погрешности объемомеров ТРК</td>
                      </tr>
                      <tr>
                        <td colspan="5" style="height:30px;"></td>
                      </tr>       
                      </thead>'
         , chr(123), chr(125)
         ).
      output stream OutStr-html close.
   end.
   assign
      v-report-result = yes.
End procedure.
procedure first-line-tog8-html :
   define input parameter v-report-name-html     as character no-undo .
   if v-report-result = no then
   do:
      output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' .
      put stream OutStr-html unformatted
         substitute(
         '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       table-layout: fixed;
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист8" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
      <tr class="set_columns">
      <td style="width:250px"></td>
      <td style="width:150px"></td>
      <td style="width:50px"></td>
      <td style="width:100px"></td>
      <td style="width:150px"></td>
      <td style="width:50px"></td>
      <td style="width:100px"></td>
      <td style="width:100px"></td>
      <td style="width:100px"></td>
      <td style="width:100px"></td>
      <td style="width:100px"></td>
      </tr>
                       <tr>  
                        <td colspan="11" >&1</td>
                      </tr>
                      <tr>
                        <td colspan="11" >&2</td>
                      </tr>
                      <tr>
                        <td colspan="11" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                      </tr>
                      <tr>
                        <td colspan="11" style="font-size:16px;font-weight:bold; text-align: center;">Часть №8. Возвраты по сопутствующим товарам и топливу</td>
                    </tr>'
         ,
         v-host-name,
         rep-shift-store-name
         ).
      if v-one-shift then
      do:
         put stream OutStr-html unformatted
            '<tr><td colspan="11">Смена: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + '</td></tr>' skip
            .
      end.
      else
      do:
         put stream OutStr-html unformatted
            '<tr><td colspan="11">Смены с: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + ' по ' + string(X-Shift-End) + ' от ' + String(x-date-end , "99.99.9999") + ' ' + String( v-rep-shift-close-time,"hh:mm") + '</td></tr>' skip
            .
      end.
      put stream OutStr-html unformatted
         '<tr>' skip
         '<td colspan="11"> Закрыта ' + string(v-rep-shift-close-date,"99.99.9999") + " " + string(v-rep-shift-close,"hh:mm") + '</td>' skip
         '</tr>' skip
         '<tr>' skip
         '<td colspan="11"> Старший смены: ' + rep-shift-for-mng1 + '</td>' skip
         '</tr>' skip
         '<tr>' skip
         '<td colspan="11"> Операторы: ' + rep-shift-for-opers1 + '</td>' skip
         '</tr>' skip
         '<tr>' skip
         '<td colspan="11"></td>' skip
         '</tr>' skip
         '</thead>' skip
         .
      output stream OutStr-html close.
   end.
   else
   do:
      output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' .
      put stream OutStr-html unformatted
         substitute(
         '       <table orientation="landscape" name="лист8" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
      <tr class="set_columns">
      <td style="width:250px"></td>
      <td style="width:150px"></td>
      <td style="width:50px"></td>
      <td style="width:100px"></td>
      <td style="width:150px"></td>
      <td style="width:50px"></td>
      <td style="width:100px"></td>
      <td style="width:100px"></td>
      <td style="width:100px"></td>
      <td style="width:100px"></td>
      <td style="width:100px"></td>
      </tr>
                      <tr>
                        <td colspan="10" style="height:30px;"></td>
                      </tr>                          
                      <tr>
                        <td colspan="10" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                      </tr>
                      <tr>
                        <td colspan="10" style="font-size:16px;font-weight:bold; text-align: center;">Часть №8. Возвраты по сопутствующим товарам и топливу</td>
                      </tr>
                      <tr>
                        <td colspan="10" style="height:30px;"></td>
                      </tr>       
                      </thead>'
         , chr(123), chr(125)
         ).
      output stream OutStr-html close.
   end.
   assign
      v-report-result = yes.
End procedure.
procedure first-line-tog9-html :
   define input parameter v-report-name-html     as character no-undo .
   if v-param-code <> 2 and v-report-result = no then
   do:
      output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' .
      put stream OutStr-html unformatted
         substitute(
         '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       table-layout: fixed;
                       width: 1200px; 
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист9" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:150px"></td>
                        <td style="width:40px"></td>
                        <td style="width:40px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                      </tr>
                       <tr>  
                        <td colspan="13" >&1</td>
                      </tr>
                      <tr>
                        <td colspan="13" >&2</td>
                      </tr>
                      <tr>
                        <td colspan="13" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                      </tr>
                      <tr>
                        <td colspan="13" style="font-size:16px;font-weight:bold; text-align: center;">Часть №9 Сбросы, переливы и переводы транзакций</td>
                      </tr>'
         ,
         v-host-name,
         rep-shift-store-name
         ).
      if v-one-shift then
      do:
         put stream OutStr-html unformatted
            '<tr><td colspan="13">Смена: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + '</td></tr>' skip
            .
      end.
      else
      do:
         put stream OutStr-html unformatted
            '<tr><td colspan="13">Смены с: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + ' по ' + string(X-Shift-End) + ' от ' + String(x-date-end , "99.99.9999") + ' ' + String( v-rep-shift-close-time,"hh:mm") + '</td></tr>' skip
            .
      end.
      put stream OutStr-html unformatted
         '<tr>' skip
         '<td colspan="13"> Закрыта ' + string(v-rep-shift-close-date,"99.99.9999") + " " + string(v-rep-shift-close,"hh:mm") + '</td>' skip
         '</tr>' skip
         '<tr>' skip
         '<td colspan="13"> Старший смены: ' + rep-shift-for-mng1 + '</td>' skip
         '</tr>' skip
         '<tr>' skip
         '<td colspan="13"> Операторы: ' + rep-shift-for-opers1 + '</td>' skip
         '</tr>' skip
         '<tr>' skip
         '<td colspan="13"></td>' skip
         '</tr>' skip
         '</thead>' skip
         .
      output stream OutStr-html close.
   end.
   if v-param-code = 2 and v-report-result = no then
   do:
      output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' .
      put stream OutStr-html unformatted
         substitute(
         '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       table-layout: fixed;
                       width:1200px; 
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист9" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:150px"></td>
                        <td style="width:40px"></td>
                        <td style="width:40px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                      </tr>
                    <tr>
                      <td colspan="13"></td>
                    </tr>
                    <tr>  
                      <td colspan="5" style="border-bottom: 1px solid black; text-align: center;">&1</td>
                      <td colspan="8"></td>
                    </tr>
                    <tr>
                      <td colspan="5" style="font-size:10px; text-align: center;">наименование организации</td>
                      <td colspan="8"></td>
                    </tr>
                    <tr>
                      <td colspan="13" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ &2</td>
                    </tr>
                    <tr>
                      <td colspan="13" style="text-align: center;"> от &3 </td>
                    </tr>
                    <tr>
                      <td colspan="13"> Смены  с &4  по &5 </td>
                    </tr>
                    <tr>
                      <td colspan="13"> </td>
                    </tr>'
         ,
         rep-shift-store-name,
         string(ub.clients.obj-name),
         string(v-rep-shift-close-date,"99.99.9999"),
         string(X-Shift-Start) + ' от ' + String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm"),
         string(X-Shift-End) + ' от ' + String(v-rep-shift-close-date , "99.99.9999") + ' ' + String ( v-rep-shift-close-time,"hh:mm")
         ).
      put stream OutStr-html unformatted
         substitute (
         '<tr> 
            <td colspan="4" style="height:30px;"> Состав смены:</td>
            <td colspan="4" style="border-bottom: 1px solid black; text-align: center;">&1</td>
            <td></td>
            <td colspan="4" style="border-bottom: 1px solid black; text-align: center;">&2</td>
          </tr>
          <tr> 
            <td colspan="4"></td>
            <td colspan="4" style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td colspan="4" style="font-size:10px; text-align: center;">инициалы, фамилия</td>
          <tr> 
            <td colspan="4" style="height:30px;"></td>
            <td colspan="4" style="border-bottom: 1px solid black; text-align: center;">&3</td>
            <td></td>
            <td colspan="4" style="border-bottom: 1px solid black; text-align: center;">&4</td>
          </tr>
          <tr> 
            <td colspan="4"></td>
            <td colspan="4" style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td colspan="4" style="font-size:10px; text-align: center;">инициалы, фамилия</td>
          </tr>
          <tr>
            <td colspan="13" style="height:30px;"></td>
          </tr>       
          </thead>'
         ,
         rep-shift-rol-mng,
         rep-shift-for-mng1,
         rep-shift-rol-oper,
         rep-shift-for-opers1
         ).
      output stream OutStr-html close.
   end.
   if v-report-result = yes then
   do:
      output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' .
      put stream OutStr-html unformatted
         substitute(
         '       <table orientation="landscape" name="лист9" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:150px"></td>
                        <td style="width:40px"></td>
                        <td style="width:40px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                      </tr>
                      <tr>
                        <td colspan="13" style="height:30px;"></td>
                      </tr>                            
                      <tr>
                        <td colspan="13" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                      </tr>
                      <tr>
                        <td colspan="13" style="font-size:16px;font-weight:bold; text-align: center;">Часть №9 Сбросы, переливы и переводы транзакций</td>
                      </tr>
                      <tr>
                        <td colspan="13" style="height:30px;"></td>
                      </tr>       
                      </thead>'
         ,   chr(123), chr(125)
         ).
      output stream OutStr-html close.
   end.
   assign
      v-report-result = yes.
End procedure.
procedure first-line-tog10-html :
   define input parameter v-report-name-html     as character no-undo .
   if v-report-result = no then
   do:
      output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' .
      put stream OutStr-html unformatted
         substitute(
         '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       table-layout: fixed;
                       width:1200px; 
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист10" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:150px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                      </tr>
                       <tr>  
                        <td colspan="8" >&1</td>
                      </tr>
                      <tr>
                        <td colspan="8" >&2</td>
                      </tr>
                      <tr>
                        <td colspan="8" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                      </tr>
                      <tr>
                        <td colspan="8" style="font-size:16px;font-weight:bold; text-align: center;">Часть №10 Топливо по типам платежей</td>
                    </tr>'
         ,
         v-host-name,
         rep-shift-store-name
         ).
       if v-one-shift then
       do:
          put stream OutStr-html unformatted
             '<tr><td colspan="8">Смена: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + '</td></tr>' skip
             .
       end.
       else
       do:
          put stream OutStr-html unformatted
             '<tr><td colspan="8">Смены с: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + ' по ' + string(X-Shift-End) + ' от ' + String(x-date-end , "99.99.9999") + ' ' + String( v-rep-shift-close-time,"hh:mm") + '</td></tr>' skip
             .
       end.
       put stream OutStr-html unformatted
          '<tr>' skip
          '<td colspan="8"> Закрыта ' + string(v-rep-shift-close-date,"99.99.9999") + " " + string(v-rep-shift-close,"hh:mm") + '</td>' skip
          '</tr>' skip
          '<tr>' skip
          '<td colspan="8"> Старший смены: ' + rep-shift-for-mng1 + '</td>' skip
          '</tr>' skip
          '<tr>' skip
          '<td colspan="8"> Операторы: ' + rep-shift-for-opers1 + '</td>' skip
          '</tr>' skip
          '<tr>' skip
          '<td colspan="8"></td>' skip
          '</tr>' skip
          '</thead>' skip
          .
       output stream OutStr-html close.
    end.
    if v-param-code = 2 and v-report-result = no then
    do:
        output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' .
        put stream OutStr-html unformatted
            substitute(
            '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       table-layout: fixed;
                       width:1200px; 
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист10" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:150px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                      </tr>
                    <tr>
                      <td colspan="8"></td>
                    </tr>
                    <tr>  
                      <td colspan="4" style="border-bottom: 1px solid black; text-align: center;">&1</td>
                      <td colspan="4"></td>
                    </tr>
                    <tr>
                      <td colspan="4" style="font-size:10px; text-align: center;">наименование организации</td>
                      <td colspan="4"></td>
                    </tr>
                    <tr>
                      <td colspan="8" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ &2</td>
                    </tr>
                    <tr>
                      <td colspan="8" style="text-align: center;"> от &3 </td>
                    </tr>
                    <tr>
                      <td colspan="8"> Смены  с &4  по &5 </td>
                    </tr>
                    <tr>
                      <td colspan="8"> </td>
                    </tr>'
         ,
         rep-shift-store-name,
         string(ub.clients.obj-name),
         string(v-rep-shift-close-date,"99.99.9999"),
         string(X-Shift-Start) + ' от ' + String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm"),
         string(X-Shift-End) + ' от ' + String(v-rep-shift-close-date , "99.99.9999") + ' ' + String ( v-rep-shift-close-time,"hh:mm")
         ).
      put stream OutStr-html unformatted
         substitute (
         '<tr> 
            <td colspan="3" style="height:30px;"> Состав смены:</td>
            <td colspan="2" style="border-bottom: 1px solid black; text-align: center;">&1</td>
            <td></td>
            <td colspan="2" style="border-bottom: 1px solid black; text-align: center;">&2</td>
          </tr>
          <tr> 
            <td colspan="3"></td>
            <td colspan="2" style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td colspan="2" style="font-size:10px; text-align: center;">инициалы, фамилия</td>
          <tr> 
            <td colspan="3" style="height:30px;"></td>
            <td colspan="2" style="border-bottom: 1px solid black; text-align: center;">&3</td>
            <td></td>
            <td colspan="2" style="border-bottom: 1px solid black; text-align: center;">&4</td>
          </tr>
          <tr> 
            <td colspan="3"></td>
            <td colspan="2" style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td colspan="2" style="font-size:10px; text-align: center;">инициалы, фамилия</td>
          </tr>
          <tr>
            <td colspan="8" style="height:30px;"></td>
          </tr>       
          </thead>'
         ,
         rep-shift-rol-mng,
         rep-shift-for-mng1,
         rep-shift-rol-oper,
         rep-shift-for-opers1
         ).
      output stream OutStr-html close.
   end.
   if v-report-result = yes then
   do:
      output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' .
      put stream OutStr-html unformatted
         substitute(
         '       <table orientation="landscape" name="лист10" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:150px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                      </tr>
                      <tr>
                      <td colspan="8" style="height:30px;"></td>
                      </tr>       
                      <tr>
                        <td colspan="8" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                      </tr>
                      <tr>
                        <td colspan="8" style="font-size:16px;font-weight:bold; text-align: center;">Часть №10 Топливо по типам платежей</td>
                      </tr>
                      <tr>
                      <td colspan="8" style="height:30px;"></td>
                      </tr>       
                      </thead>'
         ,       chr(123), chr(125)
         ).
      output stream OutStr-html close.
   end.
   assign
      v-report-result = yes.
End procedure.
procedure last-line-tog-html :
   define input parameter v-report-name-html     as character no-undo .
   find first temp-shift-obj  where temp-shift-obj.num = v-count no-error .
   if available temp-shift-obj then
   do:
      assign
         x-date-End             = temp-shift-obj.shift-date
         X-Shift-End            = temp-shift-obj.shift-num
         v-rep-shift-close-date = temp-shift-obj.close-date
         v-rep-shift-close-time = temp-shift-obj.close-time
         .
   end.
   FIND FIRST ub.shift-staff No-LOCK WHERE
      ub.shift-staff.obj-type   = p-obj-type AND
      ub.shift-staff.obj-code   = p-obj-code AND
      ub.shift-staff.shift-date = x-date-End AND
      ub.shift-staff.shift-num  = X-Shift-End AND
      ub.shift-staff.staff-role = yes and
      ub.shift-staff.psn-num    >= 0 No-ERROR.
   assign
      rep-shift-for-mng-end = if available ub.shift-staff then string(ub.shift-staff.name, "X(30)") else "".
   rep-shift-rol-mng-end = "Старший оператор"
      .
   if v-param-code = 1 then
   do:
      output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' .
      put stream OutStr-html unformatted
         substitute (
         '
              <tfoot>
                  <tr> <!--Подвал-->
                    <td colspan="8" style="height:30px;"></td>
                  </tr>
                    <tr> 
                    <td colspan="8" style="height:30px;"> СМЕНУ СДАЛ:  &1  __________________</td>
                  </tr>
                  <tr> 
                    <td colspan="8"> СМЕНУ ПРИНЯЛ: </td>
                  </tr>
            </tfoot>
        </table>
        '
         ,
         rep-shift-for-mng-next
         ).
      put stream OutStr-html unformatted
         substitute (
         '
        </body>
        </html>
        '
         , chr(123), chr(125)
         ).
      output stream OutStr-html close.
   end.
   else
   do:
      output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' .
      put stream OutStr-html unformatted
         substitute (
         '
              <tfoot>
                  <tr> <!--Подвал-->
                    <td colspan="8"></td>
                  </tr>
                    <tr> 
                    <td colspan="2" style="height:30px;"> Отчет составил и смену сдал:</td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;">&1</td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;"></td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;">&2</td>
                  </tr>
                  <tr> 
                    <td colspan="2"></td>
                    <td></td>
                    <td style="font-size:10px; text-align: center;">должность</td>
                    <td></td>
                    <td style="font-size:10px; text-align: center;">подпись</td>
                    <td></td>
                    <td style="font-size:10px; text-align: center;">расшифровка подписи</td>
                  </tr>
                    <tr> 
                    <td colspan="2" style="height:30px;"> Смену принял:</td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;">&3</td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;"></td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;">&4</td>
                  </tr>
                  <tr> 
                    <td colspan="2"></td>
                    <td></td>
                    <td style="font-size:10px;  text-align: center;">должность</td>
                    <td></td>
                    <td style="font-size:10px;  text-align: center;">подпись</td>
                    <td></td>
                    <td style="font-size:10px; text-align: center;">расшифровка подписи</td>
                  </tr>
                    <tr>
                    <td colspan="2" style="height:30px;"> Отчет проверил:</td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;"></td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;"></td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;"></td>
                  </tr>
                  <tr> 
                    <td colspan="2"></td>
                    <td></td>
                    <td style="font-size:10px; text-align: center;">должность</td>
                    <td></td>
                    <td style="font-size:10px; text-align: center;">подпись</td>
                    <td></td>
                    <td style="font-size:10px; text-align: center;">расшифровка подписи</td>
                  </tr>
        
            </tfoot>
        </table>
        '
         ,
         rep-shift-rol-mng-end,
         rep-shift-for-mng-end,
         rep-shift-rol-mng-next,
         rep-shift-for-mng-next
         ).
      output stream OutStr-html close.
   end.
End procedure.
procedure last-line-tog-html81 :
   define input parameter v-report-name-html     as character no-undo .
   find first temp-shift-obj  where temp-shift-obj.num = v-count no-error .
   if available temp-shift-obj then
   do:
      assign
         x-date-End             = temp-shift-obj.shift-date
         X-Shift-End            = temp-shift-obj.shift-num
         v-rep-shift-close-date = temp-shift-obj.close-date
         v-rep-shift-close-time = temp-shift-obj.close-time
         .
   end.
   FIND FIRST ub.shift-staff No-LOCK WHERE
      ub.shift-staff.obj-type   = p-obj-type AND
      ub.shift-staff.obj-code   = p-obj-code AND
      ub.shift-staff.shift-date = x-date-End AND
      ub.shift-staff.shift-num  = X-Shift-End AND
      ub.shift-staff.staff-role = yes and
      ub.shift-staff.psn-num    >= 0 No-ERROR.
   assign
      rep-shift-for-mng-end = if available ub.shift-staff then string(ub.shift-staff.name, "X(30)") else "".
   rep-shift-rol-mng-end = "Старший оператор"
      .
   if v-param-code = 1 then
   do:
      output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' .
      put stream OutStr-html unformatted
         substitute (
         '
              <tfoot>
                  <tr> <!--Подвал-->
                    <td colspan="8" style="height:30px;"></td>
                  </tr>
                    <tr> 
                    <td colspan="8" style="height:30px;"> СМЕНУ СДАЛ:  &1  __________________</td>
                  </tr>
                  <tr> 
                    <td colspan="8"> СМЕНУ ПРИНЯЛ: </td>
                  </tr>
            </tfoot>
            
        </table>
        '
         ,
         rep-shift-for-mng-next
         ).
      put stream OutStr-html unformatted
         substitute (
         '
        </body>
        </html>
        '
         , chr(123), chr(125)
         ).
      output stream OutStr-html close.
   end.
   else
   do:
      output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' .
      put stream OutStr-html unformatted
         substitute (
         '
              <tfoot>
                  <tr> <!--Подвал-->
                    <td colspan="8"></td>
                  </tr>
                    <tr> 
                    <td colspan="2" style="height:30px;"> Отчет составил и смену сдал:</td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;">&1</td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;"></td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;">&2</td>
                  </tr>
                  <tr> 
                    <td colspan="2"></td>
                    <td></td>
                    <td style="font-size:10px; text-align: center;">должность</td>
                    <td></td>
                    <td style="font-size:10px; text-align: center;">подпись</td>
                    <td></td>
                    <td style="font-size:10px; text-align: center;">расшифровка подписи</td>
                  </tr>
                    <tr> 
                    <td colspan="2" style="height:30px;"> Смену принял:</td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;">&3</td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;"></td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;">&4</td>
                  </tr>
                  <tr> 
                    <td colspan="2"></td>
                    <td></td>
                    <td style="font-size:10px;  text-align: center;">должность</td>
                    <td></td>
                    <td style="font-size:10px;  text-align: center;">подпись</td>
                    <td></td>
                    <td style="font-size:10px; text-align: center;">расшифровка подписи</td>
                  </tr>
                    <tr>
                    <td colspan="2" style="height:30px;"> Отчет проверил:</td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;"></td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;"></td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;"></td>
                  </tr>
                  <tr> 
                    <td colspan="2"></td>
                    <td></td>
                    <td style="font-size:10px; text-align: center;">должность</td>
                    <td></td>
                    <td style="font-size:10px; text-align: center;">подпись</td>
                    <td></td>
                    <td style="font-size:10px; text-align: center;">расшифровка подписи</td>
                  </tr>
        <tr><td colspan="7">«Частичный возврат» - это: </td></tr>
<tr><td colspan="7">«Частичный возврат» - возврат, который был проведен на недолитое топливо по транзакции на АРМ Кассира</td></tr>
<tr><td colspan="7">«Остальные возвраты» - это:</td></tr>
<tr><td colspan="7">«Полный по номеру чека» - полный возврат, который был проведен по номеру чека на АРМ Кассира</td></tr>
<tr><td colspan="7">«Частичный по номеру чека» - частичный возврат, который был проведен по номеру чека на АРМ Кассира</td></tr>
<tr><td colspan="7">«Полный по транзакции» - полный возврат, который был проведен по транзакции на АРМ Кассира</td></tr>
<tr><td colspan="7">«Сухой чек, созданный в ППО Trade House» - сухой возврат, который был проведен на АРМ Кассира</td></tr>
<tr><td colspan="7">«Сухой чек, проведенный на АРМ Кассира» - сухой возврат, который был проведен на АРМ Кассира</td></tr>

        
            </tfoot>
            
            
        </table>
        '
         ,
         rep-shift-rol-mng-end,
         rep-shift-for-mng-end,
         rep-shift-rol-mng-next,
         rep-shift-for-mng-next
         ).
      output stream OutStr-html close.
   end.
End procedure.
procedure last-line-tog-html5-1 :
   define input parameter v-report-name-html     as character no-undo .
   find first temp-shift-obj  where temp-shift-obj.num = v-count no-error .
   if available temp-shift-obj then
   do:
      assign
         x-date-End             = temp-shift-obj.shift-date
         X-Shift-End            = temp-shift-obj.shift-num
         v-rep-shift-close-date = temp-shift-obj.close-date
         v-rep-shift-close-time = temp-shift-obj.close-time
         .
   end.
   FIND FIRST ub.shift-staff No-LOCK WHERE
      ub.shift-staff.obj-type   = p-obj-type AND
      ub.shift-staff.obj-code   = p-obj-code AND
      ub.shift-staff.shift-date = x-date-End AND
      ub.shift-staff.shift-num  = X-Shift-End AND
      ub.shift-staff.staff-role = yes and
      ub.shift-staff.psn-num    >= 0 No-ERROR.
   assign
      rep-shift-for-mng-end = if available ub.shift-staff then string(ub.shift-staff.name, "X(30)") else "".
   rep-shift-rol-mng-end = "Старший оператор"
      .
   if v-param-code = 1 then
   do:
      output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' .
      put stream OutStr-html unformatted
         substitute (
         '
              
                  <tr> <!--Подвал-->
                    <td colspan="7" style="height:30px;"></td>
                  </tr>
                    <tr> 
                    <td colspan="7" style="height:30px;"> СМЕНУ СДАЛ:  &1  __________________</td>
                  </tr>
                  <tr> 
                    <td colspan="7"> СМЕНУ ПРИНЯЛ: </td>
                  </tr>
            </tfoot>
        </table>
        '
         ,
         rep-shift-for-mng-next
         ).
      put stream OutStr-html unformatted
         substitute (
         '
        </body>
        </html>
        '
         , chr(123), chr(125)
         ).
      output stream OutStr-html close.
   end.
   else
   do:
      output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' .
      put stream OutStr-html unformatted
         substitute (
         '
              
                  <tr> <!--Подвал-->
                    <td colspan="9"></td>
                  </tr>
                    <tr> 
                    <td colspan="2" style="height:30px;"> Отчет составил и смену сдал:</td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;">&1</td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;"></td>
                    <td></td>
                    <td colspan="2" style="border-bottom: 1px solid black; text-align: center;">&2</td>
                  </tr>
                  <tr> 
                    <td colspan="2"></td>
                    <td></td>
                    <td style="font-size:10px; text-align: center;">должность</td>
                    <td></td>
                    <td style="font-size:10px; text-align: center;">подпись</td>
                    <td></td>
                    <td colspan="2" style="font-size:10px; text-align: center;">расшифровка подписи</td>
                  </tr>
                    <tr> 
                    <td colspan="2" style="height:30px;"> Смену принял:</td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;">&3</td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;"></td>
                    <td></td>
                    <td colspan="2" style="border-bottom: 1px solid black; text-align: center;">&4</td>
                  </tr>
                  <tr> 
                    <td colspan="2"></td>
                    <td></td>
                    <td style="font-size:10px;  text-align: center;">должность</td>
                    <td></td>
                    <td style="font-size:10px;  text-align: center;">подпись</td>
                    <td></td>
                    <td colspan="2" style="font-size:10px; text-align: center;">расшифровка подписи</td>
                  </tr>
                    <tr>
                    <td colspan="2" style="height:30px;"> Отчет проверил:</td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;"></td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;"></td>
                    <td></td>
                    <td colspan="2" style="border-bottom: 1px solid black; text-align: center;"></td>
                  </tr>
                  <tr> 
                    <td colspan="2"></td>
                    <td></td>
                    <td style="font-size:10px; text-align: center;">должность</td>
                    <td></td>
                    <td style="font-size:10px; text-align: center;">подпись</td>
                    <td></td>
                    <td colspan="2" style="font-size:10px; text-align: center;">расшифровка подписи</td>
                  </tr>
        
            </tfoot>
        </table>
        '
         ,
         rep-shift-rol-mng-end,
         rep-shift-for-mng-end,
         rep-shift-rol-mng-next,
         rep-shift-for-mng-next
         ).
      output stream OutStr-html close.
   end.
End procedure.
