block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-shftrl.p $
$Archive: rep/r-shftrl.p $

Автор: Комаров Иван Сергеевич
Дата создания: 02/02/10
Author: Ivan Komarov
Creation date: 02/02/10

Автор1: Кочетков Михаил Юрьевич
Дата создания: 10/10/07

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-shftrl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-shftrl.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
{ rep/f-fdec.i   }
{ gbl/cur-time.i }
{ gbl/prn-lib.i  }
{ ref/grplib.i   }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ rep/r-sale.i   }

  DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.
  ASSIGN parParentProc =  my-handle .
  define variable g#report-num as integer no-undo .
  run get-report-num  in parparentproc (output  g#report-num).

  { gbl/getcntxt.i def }
  { gbl/getcntxt.i get }
  define variable v-cntxt-obj-name as character no-undo .

assign
  sheetf.Excel-Column-Lable = "№ смены" + "," + "Смена" + "," + "Дата" + "," + "Сумма реализации" + "," + "Сумма возврата" + "," + "Сумма реализации с учетом возврата"
  sheetf.Sizes              = "7,21,10,12,12,18"
  sheetf.ColFormat          = "2=@;3=dd/mm/yyyy;"
  Sheetf.make-correct       = "true,true,true,true,true,true"
.

define temp-table temp-shift-obj no-undo
  FIELD v-shift-num      as integer
  FIELD v-shift-date     as date
  FIELD v-shift-name     as character
  FIELD v-shift-name-num as character
  FIELD v-count          as integer
  FIELD v-str            as integer
  FIELD v-sum            as decimal
  FIELD v-sum-ret        as decimal
  FIELD v-sum-itog       as decimal
  FIELD v-sum-ret-itog   as decimal
  FIELD v-sum-all        as decimal
  FIELD v-obj-code       as integer
  FIELD v-obj-type       as character

  INDEX ii IS UNIQUE v-count
  INDEX ii1 IS UNIQUE v-shift-num v-shift-date v-obj-code v-obj-type
  .

define temp-table temp-gds no-undo
  FIELD prod-code as integer
  FIELD prod-type as character
  FIELD artic     as character
  INDEX ii IS UNIQUE artic prod-type prod-code
.

  define buffer buf_shift-obj   for ub.shift-obj .
  define buffer buf_trn-doc     for ub.trn-doc.
  define buffer buf_doc-line    for ub.doc-line.
  define buffer buf_gds-obj     for ub.gds-obj .
  define buffer buf_clients     for ub.clients.
/*  define buffer buf_host      for clients.*/

  define variable v-count       as integer   no-undo .
  define variable v-str         as integer   no-undo .
  define variable v-count-neg   as integer   no-undo .
  define variable CurrGrpName   as character no-undo .
  define variable ListGrpName   as character no-undo .
  define variable v-sum         as decimal   no-undo .
  define variable v-sum-ret-all as decimal   no-undo .
  define variable v-sum-all     as decimal   no-undo .
  define variable Line          as character no-undo .
  define variable v-host-code   as integer   no-undo .
  define variable Counter1      as integer   no-undo .
  define variable v-all-sum1    as decimal   no-undo .
  define variable v-all-sum2    as decimal   no-undo .
  define variable v-all-sum3    as decimal   no-undo .
  define variable v-sum-rubl    as decimal   no-undo .
  define variable v-sum-base    as decimal   no-undo .
  define variable tmp           as decimal   no-undo .

  assign  Line = fill( "-", 140 ) .

  assign  Counter1 = 0 .
  { rep/repfrm.i def }   /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 1 } /* Показать окно информации о текущем процессе */

  find first obj-list
       where obj-list.obj-type = v-cntxt-obj-type
         and obj-list.obj-code = v-cntxt-obj-code
         no-error .
       if available obj-list then do :
           assign v-cntxt-obj-name = obj-list.obj-name .
       end .

  for each obj-list no-lock :

        create temp-shift-obj .
        assign
          temp-shift-obj.v-shift-name = obj-list.obj-name
          v-count-neg                 = v-count-neg + 1
          temp-shift-obj.v-count      = - ( v-count-neg )
          v-str                       = v-str + 1
          temp-shift-obj.v-str        = v-str
          v-sum-all                   = 0
          v-sum-ret-all               = 0
        .

    /*  find first buf_shift-obj no-lock
        where buf_shift-obj.obj-type    = obj-list.obj-type
          and buf_shift-obj.obj-code    = obj-list.obj-code
          and buf_shift-obj.shift-date  = x-Date-Start
          and buf_shift-obj.shift-num   = x-Shift-Start
      no-error .
      if not available buf_shift-obj then do:
          message "Не найдена смена начала отчета." skip
                  "Дата:" string( x-Date-Start, "99/99/9999":U ) skip
                  "Порядок:" x-Shift-Start
          view-as alert-box error .
          return  .
      end.
      find first buf_shift-obj no-lock
        where buf_shift-obj.obj-type    = obj-list.obj-type
          and buf_shift-obj.obj-code    = obj-list.obj-code
          and buf_shift-obj.shift-date  = x-Date-End
          and buf_shift-obj.shift-num   = x-Shift-End
      no-error .
      if not available buf_shift-obj then do:
          message "Не найдена смена окончания отчета." skip
                  "Дата:" string( x-Date-End, "99/99/9999":U ) skip
                  "Порядок:" x-Shift-End
          view-as alert-box error .
          return .
      end.    */
      find first tmp#grp no-error .
      if not available tmp#grp then do:
        message "Не выбраны группы товаров." view-as alert-box error .
        return .
      end.

      { gbl/hostcode.i obj-list.obj-type obj-list.obj-code v-host-code }

      for each tmp#grp :  /* составляем список товаров */
      run grplib-get-full-name in this-procedure( input tmp#grp.node-code, output CurrGrpName ) .
        for each buf_gds-obj no-lock
          where buf_gds-obj.obj-type = obj-list.obj-type
            and buf_gds-obj.obj-code = obj-list.obj-code
            and buf_gds-obj.grp-name begins CurrGrpName
          use-index obj-grp :
          find first temp-gds
          where temp-gds.prod-code = buf_gds-obj.prod-code
            and temp-gds.prod-type = buf_gds-obj.prod-type
            and temp-gds.artic     = buf_gds-obj.artic
            no-error .
            if not available temp-gds then do :
              create temp-gds .
                    assign
                temp-gds.prod-code = buf_gds-obj.prod-code
                temp-gds.prod-type = buf_gds-obj.prod-type
                temp-gds.artic     = buf_gds-obj.artic
              .
            end .
        end.
      end.

      for each buf_shift-obj  no-lock /* составляем список смен */
        where buf_shift-obj.obj-code = obj-list.obj-code
          and buf_shift-obj.obj-type = obj-list.obj-type
      :
        assign v-count = v-count + 1 .
        if buf_shift-obj.shift-date < x-date-Start then next .
        if buf_shift-obj.shift-date = x-date-Start and buf_shift-obj.shift-num < x-Shift-Start then next .
        if buf_shift-obj.shift-date > x-date-End   then next.
        if buf_shift-obj.shift-date = x-date-End   and buf_shift-obj.shift-num > x-Shift-End then leave.

        assign Counter1 = Counter1 + 1.
        { rep/repfrm.i disp Counter1 }

        create temp-shift-obj .
        assign
          temp-shift-obj.v-obj-type   = obj-list.obj-type
          temp-shift-obj.v-obj-code   = obj-list.obj-code
          temp-shift-obj.v-count      = v-count
          temp-shift-obj.v-shift-date = buf_shift-obj.shift-date
          temp-shift-obj.v-shift-num  = buf_shift-obj.shift-num
          v-str = v-str + 1
          temp-shift-obj.v-str        = v-str
        .
        { str/shiftnam.i buf_shift-obj.obj-type buf_shift-obj.obj-code buf_shift-obj.shift-date buf_shift-obj.shift-num temp-shift-obj.v-shift-name temp-shift-obj.v-shift-name-num no-error }
        assign
          temp-shift-obj.v-shift-name = " " + temp-shift-obj.v-shift-name + "(" + string(buf_shift-obj.shift-num) + ")"
        .

        for each buf_trn-doc no-lock
          where buf_trn-doc.obj-code   = obj-list.obj-code
            and buf_trn-doc.obj-type   = obj-list.obj-type
            and buf_trn-doc.shift-date = buf_shift-obj.shift-date
            and buf_trn-doc.shift-num  = buf_shift-obj.shift-num
            and buf_trn-doc.status_    = {&fact}
          :
          if buf_trn-doc.ext-doc-type <> {&TDEDT_Ras_Vnesh_Kass} and buf_trn-doc.ext-doc-type <> {&TDEDT_Vozvrat_Vnesh_Kass} then next .
          for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code :
            find first temp-gds where temp-gds.prod-code = buf_doc-line.prod-code and temp-gds.prod-type = buf_doc-line.prod-type and temp-gds.artic = buf_doc-line.artic no-error .
            if available temp-gds then do:
              run r-sale in this-procedure ( input buf_doc-line.doc-code   , input buf_doc-line.artic   , input buf_doc-line.prod-type
                                      , input buf_doc-line.prod-code  , output tmp     , output tmp    , output tmp
                                      , output v-sum-base      , output v-sum-rubl   , output tmp    , output tmp
                                      , output tmp      , output tmp   , output tmp    , output tmp    , output tmp
                                      , output tmp      , output tmp   , output tmp    , output tmp    , output tmp ).

              if buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass} then assign temp-shift-obj.v-sum = temp-shift-obj.v-sum - v-sum-rubl .
              else  assign temp-shift-obj.v-sum-ret = temp-shift-obj.v-sum-ret + v-sum-rubl .
            end.
          end.
        end.
      end.
      for each temp-shift-obj
         where temp-shift-obj.v-obj-code = obj-list.obj-code
           and temp-shift-obj.v-obj-type = obj-list.obj-type
           no-lock :
           assign
            v-sum-all     = v-sum-all     + temp-shift-obj.v-sum
            v-sum-ret-all = v-sum-ret-all + temp-shift-obj.v-sum-ret
           .
      end.

      create temp-shift-obj .
        assign
          temp-shift-obj.v-shift-name = "Итого " + obj-list.obj-name
          v-count-neg = v-count-neg + 1
          temp-shift-obj.v-count      = - ( v-count-neg )
          v-str = v-str + 1
          temp-shift-obj.v-str           = v-str
          temp-shift-obj.v-sum-itog      = v-sum-all
          temp-shift-obj.v-sum-ret-itog  = v-sum-ret-all
          temp-shift-obj.v-sum-all       = temp-shift-obj.v-sum-itog - temp-shift-obj.v-sum-ret-itog
        .
  end.

  DEFINE FRAME shift
        sym1 column-label ":!:" format "X(1)" space(0)
        temp-shift-obj.v-count column-label "N смены" format ">>>>>>9" space(0)
        sym2 column-label ":!:" format "X(1)" space(0)
        temp-shift-obj.v-shift-name  column-label "Смена" format "x(15)" space(0)
        sym3 column-label ":!:" format "X(1)" space(0)
        temp-shift-obj.v-shift-date column-label " Дата " format "99.99.9999" space(0)
        sym4 column-label ":!:" format "X(1)" space(0)
        temp-shift-obj.v-sum        column-label "Сумма реализации" format "->>>>,>>>,>>>,>>>,>>9.99" space(0)
        sym5 column-label ":!:" format "X(1)" space(0)
        temp-shift-obj.v-sum-ret    column-label "Сумма возврата" format "->>>>,>>>,>>>,>>>,>>9.99" space(0)
        sym6 column-label ":!:" format "X(1)" space(0)
        v-sum  column-label "Сумма с учетом возврата" format "->>>>,>>>,>>>,>>>,>>9.99" space(0)
        sym7 column-label ":!:" format "X(1)" space(0)
    header
        string( "Дата печати : " + string(TODAY,"99.99.9999") +  " , " + string(TIME, "HH:MM") ) at 5 format "X(35)"
        string( "Страница " + string( PAGE-NUMBER( PrnLibStream ), ">>9" ) ) at 100 format "X(13)" skip
        Line format "X(111)" at 1
  with width {&A4_CW0} down stream-io.


  { cmp/open-out.i stream PrnLibStream " " }

  form header  Line format "X(111)" at 1  skip "Продолжение - на следующей странице" at 30  skip
  with frame Bottomframe width {&A4_CW0} page-bottom no-labels no-box .
  view stream PrnLibStream frame Bottomframe .

  str2 = replace(str2, "/" + {&new-line} + "     ", "/," ) .
  str4 = substring(str4, 1, index(str4, "объекта") + 7) + {&new-line} + replace(substring(str4, index(str4, {&new-line} + "     ") + 1), {&new-line} + "     ", "," ) .
  find first buf_clients no-lock where buf_clients.obj-type = {&cmp} and buf_clients.obj-code = v-host-code .
  assign
    ReportNAme   = " "
    ReportHeader = string( "Дата печати : " + string(TODAY,"99.99.9999") +  " , " + string(TIME, "HH:MM") )
    str1 = "Фирма: " + buf_clients.obj-name + ", " + "Объект: " + v-cntxt-obj-name
    str3 = str4
    str4 = "За период с " + string(x-date-Start,"99/99/9999") + " по " + string(x-date-End,"99/99/9999")
  .
  if length(str2) > 138 then str2 = string(substring(str2, 1, 135)) + "..." .
  if length(str3) > 126 then str3 = string(substring(str3, 1, 123)) + "..." .

  run rep/extitle.p (1) . /* Печать шапки */

  put stream PrnLibStream str1 format "X(100)" skip
                          str2 format "X(150)" skip
                          str3 format "X(150)" skip
                          str4 format "X(110)" skip
  .

  for each temp-shift-obj break by temp-shift-obj.v-str :
    assign
      v-sum = temp-shift-obj.v-sum - temp-shift-obj.v-sum-ret
      v-all-sum1 = v-all-sum1 + temp-shift-obj.v-sum
      v-all-sum2 = v-all-sum2 + temp-shift-obj.v-sum-ret
      v-all-sum3 = v-all-sum3 + v-sum
    .

    if temp-shift-obj.v-count > 0  then do :
      display stream PrnLibStream
        sym1 temp-shift-obj.v-count
        sym2 temp-shift-obj.v-shift-name
        sym3 temp-shift-obj.v-shift-date
        sym4 temp-shift-obj.v-sum
        sym5 temp-shift-obj.v-sum-ret
        sym6 v-sum
        sym7
      with frame shift.
      down stream PrnLibStream with frame shift .
      {&PutExcel}  string(temp-shift-obj.v-count) {&tabulation} temp-shift-obj.v-shift-name {&tabulation} temp-shift-obj.v-shift-date {&tabulation} excel-sum (temp-shift-obj.v-sum) {&tabulation}  excel-sum (temp-shift-obj.v-sum-ret) {&tabulation}  excel-sum (v-sum) {&new-line} .
    end.
    else do :
      if temp-shift-obj.v-shift-name begins "Итого " then do :
        display stream PrnLibStream
          sym1
          sym2 temp-shift-obj.v-shift-name
          sym3 temp-shift-obj.v-shift-date
          sym4 temp-shift-obj.v-sum-itog      @ temp-shift-obj.v-sum
          sym5 temp-shift-obj.v-sum-ret-itog  @ temp-shift-obj.v-sum-ret
          sym6 temp-shift-obj.v-sum-all       @ v-sum
          sym7
        with frame shift.
        down stream PrnLibStream with frame shift .
        {&PutExcel} {&tabulation} temp-shift-obj.v-shift-name {&tabulation} {&tabulation} excel-sum (temp-shift-obj.v-sum-itog) {&tabulation}  excel-sum (temp-shift-obj.v-sum-ret-itog) {&tabulation}  excel-sum (temp-shift-obj.v-sum-all) {&new-line} .
      end.
      else do :
        display stream PrnLibStream
          sym1
          sym2 temp-shift-obj.v-shift-name
          sym3
          sym4
          sym5
          sym6
          sym7
        with frame shift.
        down stream PrnLibStream with frame shift .
        {&PutExcel}  {&tabulation} temp-shift-obj.v-shift-name {&new-line} .
      end .
    end .
  end .
  put stream PrnLibStream Line format "X(111)" skip
    sym1 "ИТОГО" sym4 at 36 v-all-sum1 format  "->>>>,>>>,>>>,>>>,>>9.99" sym5 v-all-sum2  format  "->>>>,>>>,>>>,>>>,>>9.99" sym6 v-all-sum3  format  "->>>>,>>>,>>>,>>>,>>9.99" sym7
    skip Line format "X(111)" skip
  .

  {&PutExcel}  "ИТОГО"  {&tabulation} {&tabulation} {&tabulation} excel-sum (v-all-sum1) {&tabulation}  excel-sum (v-all-sum2) {&tabulation}  excel-sum (v-all-sum3) .

  {&CloseExcel}

  HIDE STREAM   PrnLibStream   FRAME shift .
  Output stream PrnLibStream   close .
  { rep/repfrm.i off }

  RUN prn-lib-prn-file in this-procedure (input parParentProc,input 0).