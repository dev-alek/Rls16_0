using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.ref.sobj.sParamObj:
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def
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
method public void empty-obj-list ():
   for each obj-list :
      delete obj-list.
   end.
end.
method public logical can-find-obj-list ():
   return can-find (first obj-list no-lock).
end.
method public void get-obj-list (output table obj-list bind):
end.
method public void set-obj-list (input table obj-list bind):
end.
method public void create_obj-list (p-obj-type as char, p-obj-code as integer ):
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
define temp-table param-to-export no-undo
field param-code     as character
field param-sub-code as character
field param-type     as character
field param-value    as character
field param-comment  as character
index pi is unique primary  param-code     param-sub-code
.
method public void create-param-to-export
 ( p1 as character,
   p2 as character,
   p3 as character,
   p4 as character,
   p5 as character
  )
            :
 do
 on error undo, return error return-value
 :
  create  param-to-export.
  assign
     param-to-export.param-code     =  p1
     param-to-export.param-sub-code =  p2
     param-to-export.param-type     =  p3
     param-to-export.param-value    =  p4
     param-to-export.param-comment  =  p5
  .
 end.
end .
method public void get-param-to-export (output table param-to-export):
end.
method public void set-param-to-export (input table param-to-export):
end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table gds-list no-undo like ub.goods
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define    temp-table gds-list-hist no-undo
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
method public void empty-gds-list-hist ():
   for each gds-list-hist :
      delete gds-list-hist.
   end.
end.
method public void get-glob-gds-list-hist ():
end.
method public void set-glob-gds-list-hist ():
end.
method public void get-gds-list-hist (output table gds-list bind):
end.
method public void set-gds-list-hist (input table gds-list bind):
end.
method public character  get-gds-list-note ():
   define variable o-notes as character no-undo.
   define variable v-i as integer no-undo.
   for each gds-list-hist :
      v-i = v-i + 1 .
      o-notes = o-notes + chr(10) + gds-list-hist.hist-mode +  gds-list-hist.des .
      if v-i > 10
      then do:
         o-notes = o-notes + " ... " .
         leave.
      end.
   end.
end.
method public void empty-gds-list ():
   for each gds-list :
      delete gds-list.
   end.
end.
method public void get-glob-gds-list ():
end.
method public void set-glob-gds-list ():
end.
method public void get-gds-list (output table gds-list):
end.
method public void set-gds-list (input table gds-list):
   define variable ddd as integer no-undo.
   ddd = 1.
end.
method public int get-gds-list-count ():
   define variable vcount as integer no-undo.
   for each gds-list :
      vcount = vcount + 1 .
   end.
   return vcount.
end.
method public character  get-gds-list-one ():
   define variable vcount as integer no-undo.
   define buffer Buf_gds-list for gds-list.
   find first gds-list no-error.
   for each Buf_gds-list where recid(Buf_gds-list) ne recid(gds-list) :
      delete Buf_gds-list.
   end.
   return if available gds-list then gds-list.gds-name else ? .
end.
method public character  create-gds-list (iri-list as character ):
   define buffer buf_goods for goods.
   for each gds-list :
      delete gds-list.
   end.
   if iri-list <> ""
   then do:
      find first buf_goods where recid(buf_goods) = integer (iri-list) no-lock.
      buffer-copy buf_goods to gds-list no-error.
   end.
end.
   define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info6 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
method public character grplib-get-full-name (p-node-code as integer):
   define variable p-full-name as character no-undo.
   do:
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_gds-grp.node-name
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
return p-full-name.
end .
method public integer grplib-get-node-from-full-name (p-full-name as char):
   define variable p-node-code as integer  no-undo.
define variable v-ii as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-root-code as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_gds-grp       for ub.gds-grp.
do
on error undo, return error
:
  find first buf_gds-grp no-lock
      where buf_gds-grp.upper-code = 0
  no-error .
  if not available buf_gds-grp
  then do:
      undo, return error substitute("Не найдена корневая группа товаров (upper-code = 0)").
  end.
  else do:
    assign
    v-root-code = buf_gds-grp.node-code
    .
  end.
  v-upper-code = v-root-code.
  do v-ii = 1 to num-entries(p-full-name, chr(47)):
    assign
    v-entry = entry(v-ii, p-full-name, chr(47)).
    if v-entry = '' then leave.
    find first buf_gds-grp no-lock where
              buf_gds-grp.node-name = v-entry
          and buf_gds-grp.upper-code = v-upper-code
          no-error.
    if not available buf_gds-grp then do:
      undo, return error substitute("Не найдена подгруппа &1 в группе с вн. кодом &2", v-entry, v-upper-code).
    end.
    else do:
      p-node-code = buf_gds-grp.node-code.
      v-upper-code = buf_gds-grp.node-code.
    end.
  end.
end.
return p-node-code.
end .
define
temp-table tmp#grp no-undo
    field node-code like ub.gds-grp.node-code
    field grp-name like ub.gds-grp.node-name
    field lvl-num  like ub.gds-grp.lvl-num
    field is-term  like ub.gds-grp.is-term
    index pi is unique primary grp-name node-code
    index i-node-code    node-code
    index level-num   lvl-num  grp-name
    index is-term is-term  grp-name
    .
method public void empty-tmp#grp ():
   for each tmp#grp :
      delete tmp#grp.
   end.
end.
method public void get-glob-tmp#grp ():
end.
method public void set-glob-tmp#grp ():
end.
method public void get-tmp#grp (output table tmp#grp bind):
end.
method public void set-tmp#grp (input table tmp#grp bind):
end.
method public character  create_tmp#grp (gdsgrp_recids as char):
   define variable t-str as character no-undo.
define variable Grp_Name as character no-undo.
define buffer buf_gds-grp for gds-grp.
   for each  tmp#grp :
     delete tmp#grp.
   end.
   define variable v-ind as integer   no-undo .
   repeat v-ind = 1 to num-entries( gdsgrp_recids ):
      find first buf_gds-grp where recid ( buf_gds-grp ) = integer ( entry(v-ind,gdsgrp_recids )) no-lock.
          Grp_Name = grplib-get-full-name (  buf_gds-grp.node-code  ).
      if Grp_Name <> ? then  if length(t-str) <= 6000 then t-str = t-str + chr(10) + "     " + Grp_Name .
      create tmp#grp.
      assign tmp#grp.node-code = buf_gds-grp.node-code
             tmp#grp.grp-name = Grp_Name
             tmp#grp.is-term = buf_gds-grp.is-term
             tmp#grp.lvl-num = buf_gds-grp.lvl-num
      .
   end.
   return t-str.
end.
   define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define
temp-table g#cli no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
    .
method public void empty-g#cli ():
   for each g#cli :
      delete g#cli.
   end.
end.
method public void get-glob-g#cli ():
end.
method public void set-glob-g#cli ():
end.
method public void get-g#cli (output table tmp#grp bind):
end.
method public void set-g#cli (input table tmp#grp bind):
end.
method public character  create_g#cli (cli-grp_recids as char):
define buffer cli-prod for  ub.clients .
   for each g#cli :
       delete g#cli .
   end .
   define variable v-ind as integer   no-undo .
   do v-ind = 1 to num-entries( cli-grp_recids )
    :
        find cli-prod where recid( cli-prod ) = int( entry(v-ind, cli-grp_recids ) ) no-lock.
        create g#cli.
        assign
        g#cli.obj-type = cli-prod.obj-type
        g#cli.obj-code = cli-prod.obj-code
        g#cli.obj-name = cli-prod.obj-name.
    end.
end.
   method public character  Get_text_g#cli (output ocount as integer ):
      define variable oText as character no-undo.
   ocount = 0.
   for each g#cli no-lock:
      if length(oText) <= 6000 then oText = oText + chr(10) + "     " + g#cli.obj-name .
      ocount =  ocount + 1 .
   end.
   return oText.
end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def
temp-table  g#customer no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
method public void empty-g#customer  ():
   for each g#customer  :
      delete g#customer .
   end.
end.
method public logical can-find-g#customer  ():
   return can-find (first g#customer  no-lock).
end.
method public void get-g#customer  (output table obj-list bind):
end.
method public void set-g#customer  (input table obj-list bind):
end.
method public void create_g#customer  (p-obj-type as char, p-obj-code as integer,p-obj-Name as character  ):
   do
   on error undo, return error return-value
   :
      define buffer cli-obj for ub.clients .
      define variable p-var as integer no-undo .
      define buffer buf_g#customer for g#customer .
      find first buf_g#customer  where buf_g#customer.obj-type eq p-obj-type
                                   and buf_g#customer.obj-code eq p-obj-code
      no-error.
      if not available buf_g#customer
      then do:
         find first cli-obj where
                    cli-obj.obj-type = p-obj-type
                and cli-obj.obj-code = p-obj-code
         no-lock no-error.
         if available cli-obj
         then do:
            create buf_g#customer.
            assign
               buf_g#customer.obj-code = cli-obj.obj-code
               buf_g#customer.obj-type = cli-obj.obj-type
               buf_g#customer.obj-name = cli-obj.obj-name
            .
         end.
      end.
   end.
end.
   define public property  my-handle         as handle  no-undo
   get.
   set(iarg as handle):
      my-handle = iarg.
   end.
   define public property d-report-handle as handle  no-undo
   get. set.
   define public property parParentProc     as handle  no-undo
   get:
      return this-object:my-handle.
   end.
   set(iarg as handle):
      my-handle = iarg.
      setMyhandle().
   end.
   define public variable x-Date-Alone     as date format "99/99/9999":u   no-undo .
   define public variable x-Date-End       as date format "99/99/9999":u   no-undo .
   define public variable x-Date-Start     as date format "99/99/9999":u   no-undo .
   define public variable x-Shift-Alone    as integer format ">9":u         no-undo .
   define public variable x-Shift-End      as integer format ">9":u         no-undo .
   define public variable x-Shift-Start    as integer format ">9":u         no-undo .
   define public variable x-TOG-Shift      as logical  no-undo .
   define public variable x-Radio-Task     as integer  no-undo .
   define public variable x-SelectObject   as character                          no-undo .
   define public variable x-Goods-Editor   as character                          no-undo .
      define public variable x-SelectGood     as integer                      no-undo .
   define public variable x-SET_PAY_TYPE   as integer  no-undo .
   define public variable x-SET_val_TYPE   as integer  no-undo .
   define public variable my-cntxt-db-num        as integer   no-undo .
   define public variable my-cntxt-userid        as character no-undo .
   define public variable my-cntxt-level         as character no-undo .
   define public variable my-cntxt-host-code-obj as integer   no-undo .
   define public variable my-cntxt-obj-type      as character no-undo .
   define public variable my-cntxt-obj-code      as integer   no-undo .
   define public variable my-cntxt-db-num-obj    as integer   no-undo .
   define public variable my-cntxt-is-admin      as logical   no-undo .
   define public variable my-base-type           as character no-undo .
   define public variable my-base-code as integer   no-undo .
   define public variable my-g#report-num as integer   no-undo .
   define public variable my-g#gds-engl as logical   no-undo .
   define public variable my-v-exch-rate  as decimal   no-undo .
   define public variable my-v-exch-scale as decimal   no-undo .
   define public variable my-cntxt-host-name-obj as character no-undo .
   define public variable  Show-Crsa         as logical  no-undo init false.
   define public variable  Show-Cost         as logical  no-undo init false.
   define public variable  Show-Sale         as logical  no-undo init false.
   define public variable x-text-Obj   as character  no-undo .
   define public variable x-text-Goods as character  no-undo .
   define public variable x-text-Shift as character  no-undo .
   define public variable x-text-Curr  as character  no-undo .
   define public variable x-text-Cust  as character  no-undo .
   define public variable strShift   as character  no-undo.
   define public variable strGoods   as character  no-undo.
   define public variable strCurr    as character  no-undo.
   define public variable strObj     as character  no-undo.
   define public variable strCust    as character  no-undo.
   define public variable strSchet   as character  no-undo.
   define public variable  Print-List-Hist   as logical no-undo init false.
   define public variable Make-Excel     as logical  no-undo init false.
   define public variable Make-Excel-com as logical  no-undo init false.
   define public variable parent-handle  as handle no-undo .
   define public variable params-only-mode as character no-undo .
   define public variable place-call       as character no-undo .
   define public variable ReportProc as character no-undo.
   define public variable ReportName as character no-undo.
   define public variable ReportPageWidth  as integer no-undo.
   define public variable ReportPageHeight as integer no-undo.
   define public variable Use-column   as logical extent 256 no-undo .
   define public variable fin-schet-recid    as character no-undo.
   define public variable ReportHeader as character  no-undo.
   define public variable ch#ExcelApplication as com-handle no-undo .
   define public variable ch#Workbook         as com-handle no-undo .
   define public variable ch#Worksheet        as com-handle no-undo .
   define public variable Num#Str#            as integer no-undo.
   define public variable Number-List  as integer no-undo init 1.
   define public variable v-excel-file as character no-undo .
define   temp-table Sheetf no-undo
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
method public void get-Sheetf (output table Sheetf):
end.
method public void set-Sheetf (input table Sheetf):
end.
   define public property sheet-num as integer
   get:
      define variable vsheet-num as integer no-undo.
      define buffer buf_sheetf for sheetf.
      find last buf_sheetf no-error .
      if available buf_sheetf
      then
         vsheet-num = buf_sheetf.sheet-num.
      return vsheet-num.
   end.
   method private void setMyhandle():
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in my-handle
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
define variable base-type as character no-undo .
define variable base-code as integer   no-undo .
define variable g#report-num as integer   no-undo .
define variable g#gds-engl as logical   no-undo .
define variable vv-exch-rate  as decimal   no-undo .
define variable vv-exch-scale as decimal   no-undo .
define variable v-cntxt-host-name-obj as character no-undo .
if v-cntxt-level = 'object':U then do:
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run hostname in ibs.th.gbl.gbl-hndllib:g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-cntxt-host-code-obj
  ,output v-cntxt-host-name-obj
  )  .
end.
if v-cntxt-level = 'firm':U then do:
  find first ub.clients no-lock where
             ub.clients.obj-type = 'орг':U and
             ub.clients.obj-code = v-cntxt-host-code-obj no-error .
if error-status :error then v-cntxt-host-name-obj = ? .
   else v-cntxt-host-name-obj = ub.clients.obj-name.
end.
if v-cntxt-level = 'object':U
or v-cntxt-level = 'firm':U
then do:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run basecode in ibs.th.gbl.gbl-hndllib:g#library
  (input  v-cntxt-host-code-obj
  ,output base-code
  )  .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run exchrate in ibs.th.gbl.gbl-hndllib:g#library
  (input  base-code
  ,input  today
  ,output vv-exch-rate
  ,output vv-exch-scale
  ,output base-type
  )  .
end.
run get-report-num in my-handle ( output g#report-num ).
run get-gds-engl in my-handle ( output g#gds-engl ) .
      assign
         my-cntxt-db-num = v-cntxt-db-num
         my-cntxt-userid = v-cntxt-userid
         my-cntxt-level = v-cntxt-level
         my-cntxt-host-code-obj = v-cntxt-host-code-obj
         my-cntxt-obj-type = v-cntxt-obj-type
         my-cntxt-obj-code = v-cntxt-obj-code
         my-cntxt-db-num-obj = v-cntxt-db-num-obj
         my-cntxt-is-admin = v-cntxt-is-admin
         my-base-type  = base-type
         my-base-code = base-code
         my-g#report-num = g#report-num
         my-g#gds-engl = g#gds-engl
         my-v-exch-rate = vv-exch-rate
         my-v-exch-scale = vv-exch-scale
         my-cntxt-host-name-obj = v-cntxt-host-name-obj
      .
   end method.
   method public logical  avail_obj-list (iobj-type as character ,iobj-code as integer ):
      define buffer obj-list for obj-list.
      return can-find (first obj-list where obj-list.obj-type = iobj-type
                                        and obj-list.obj-code = iobj-code).
   end method.
   method public character get-obj-List-text():
      define variable otext as character no-undo.
      define buffer cli-obj   for ub.clients .
      for each Obj-list :
          find cli-obj where cli-obj.obj-type = obj-list.obj-type  and
                             cli-obj.obj-code = obj-list.obj-code no-lock .
          if length(otext) <= 6000
          then
             otext = otext + chr(10) + "     " + cli-obj.obj-name  + ' ' + obj-list.obj-type.
      end.
      return otext.
   end method.
   method public integer  get-count-gds-list():
      define variable lns-cnt as integer no-undo.
      for each gds-list :
         lns-cnt = lns-cnt + 1 .
      end.
      return lns-cnt.
   end method.
   method public character get-custumer-text():
      define variable oStr as character no-undo.
      block-cust:
      for each g#customer:
         if length (oStr) >= 10000
         then do:
            oStr = oStr + '...' .
            leave block-cust.
         end.
         else oStr = oStr + chr(10) + "     " + g#customer.obj-name .
      end.
      return oStr.
   end method.
   method public void  CheckAndUpNameObjList():
      define variable L#obj-code like obj-list.obj-code no-undo.
      define variable l#obj-type like obj-list.obj-type no-undo.
      define buffer obj-list   for obj-list .
      define buffer o-clients  for ub.clients.
      assign
         L#obj-code=0
         l#obj-type=""
      .
      for each obj-list  by obj-list.obj-code by obj-list.obj-type :
         if obj-list.obj-code = L#obj-code and
            obj-list.obj-type = l#obj-type then  do:
            delete obj-list.
         end.
         else do:
            find first  o-clients where
                     o-clients.obj-code = obj-list.obj-code and
                     o-clients.obj-type = obj-list.obj-type  no-lock no-error .
            assign
               obj-list.obj-name = if avail o-clients then  o-clients.obj-name else ""
               l#obj-code = obj-list.obj-code
               l#obj-type = obj-list.obj-type
            .
         end.
      end.
   end method.
   method public character  get-s-notes():
      define variable v-i as integer   no-undo .
      define variable s-notes as character no-undo.
      for each gds-list-hist :
         v-i = v-i + 1 .
         s-notes = s-notes + chr(10) + gds-list-hist.hist-mode +  gds-list-hist.des .
         if v-i > 10 then do:
            s-notes = s-notes + " ... " .
            leave.
         end.
      end.
   end method.
   method public void make-6-gds-list () :
      define buffer buf-goods for ub.goods.
      if X-SelectGood = 7 then do:
         for each gds-list  :
            delete gds-list.
         end.
         for each g#cli no-lock :
            for each tmp#grp no-lock :
               for each buf-goods where
                  buf-goods.prod-type = g#cli.obj-type and
                  buf-goods.prod-code = g#cli.obj-code and
                  ( trim(buf-goods.grp-name)  begins trim(tmp#grp.grp-name) )
               no-lock :
                  if not can-find(first gds-list where gds-list.gds-code= buf-goods.gds-code)
                  then  do:
                     create gds-list.
                     buffer-copy buf-goods to gds-list  no-error  .
                  end.
               end.
            end.
         end.
      end.
   end method.
   constructor public sParamObj (  ):
      super ().
   end constructor.
   destructor public sParamObj ( ):
   end destructor.
end class.
