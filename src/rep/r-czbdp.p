block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-czbdp.p $
$Archive: rep/r-czbdp.p $

Служебная записка о выдаче денежных средств

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 08/11/04 11:28

*/

define input parameter  parParentProc as WIDGET-HANDLE    no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-czbdp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-czbdp.p $":U .
define variable vss-description as character no-undo init "Служебная записка о выдаче денежных средств".
define variable g#report-num as integer no-undo .

define variable glob-page as integer no-undo .

{ cmp/vssrevis.i   }
{ cmp/trg-def.i    }
{ cmp/r-page1.i    }
{ cmp/r-pril.i     }
{ gbl/prn-lib.i    }
{ rep/r-sym.i      }
{ rep/r-gl.i       }
{ rep/f-fdec.i     }
{ gbl/cur-time.i   }
{ gbl/paramls.i    }
{ cmp/showinf.i    }
{ gbl/waitfram.i   }
{ gbl/thbjattr.i   }
{ rep/p-fmt.i      }
{ trg/factord.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
 do
 on error undo, return error return-value
 :

define variable date_string     as      char    no-undo.
define variable for-time as char.

x-date-start = x-date-alone .

define temp-table temp-t no-undo
field cli-name as character
field cli-type as character
field cli-code as integer
field obj-type as character
field obj-code as integer
field sum-p    as decimal   /* закрытые платежи за вчера */
field sum-fo   as decimal   /* закрытые платежи за вчера */
field sum-op   as decimal   /* открытые платежи за сегодня */
index pi
      obj-type
      obj-code
      cli-name
      cli-type
      cli-code
      .
define temp-table temp-obj no-undo like clients
field nn as integer
field sum-obj as decimal
field sum-obj-arh as decimal
.

define variable sum-ostatok-start as decimal no-undo init 0.
define variable sum-plan-pri      as decimal no-undo init 0 .
define variable sum-proch         as decimal no-undo init 0 .
define variable sum-proch-ras         as decimal no-undo init 0 .
define variable all-summ-dec-razd-1 as decimal no-undo init 0 .
define variable all-summ-dec-razd-2 as decimal no-undo init 0 .
define variable all-summ-dec-razd-3 as decimal no-undo init 0 .

define temp-table temp-cli no-undo like clients
field summ as decimal
.

define variable v-file-name as character no-undo .
define variable v-ind       as integer   no-undo .
define variable num#col#    as integer no-undo .
define variable C-c    as integer no-undo .
define variable C-str  as character no-undo .
define variable str--1 as character Format "x(60)" no-undo.
define variable str--2 as integer no-undo .
define variable C-i    as integer no-undo .
define variable p-var  as integer no-undo .
define variable var-1  as integer no-undo .
define variable var-2  as integer no-undo .



define variable num-ln as integer   no-undo .
define variable i as int no-undo.
define variable j as int no-undo.
define variable Counter1 as integer init 0  no-undo .

define variable LineBuf       as char    no-undo.
define variable Line       as char    no-undo.
define variable UndLine    as char    no-undo.

define variable     Lines_Counter as   int  init 0  no-undo.
define variable     Tmp_Counter   as   int  init 0  no-undo.
define variable fact-order-2 as decimal no-undo .
define variable v-host-code as integer no-undo .
define variable v-obj-code as integer no-undo .
define variable v-obj-type as character no-undo .
define variable v-curr as integer no-undo .
define variable var-calc-page as integer no-undo .
define variable var-page as integer no-undo .
define buffer buf_clients  for clients .
define buffer buf_contract for contract.
define buffer b1_beznal_arh-fin for arh-fin-doc-contr-schet-obj.
define buffer b2_beznal_arh-fin for arh-fin-doc-contr-schet-obj.
define buffer b1_nal_arh-fin    for arh-fin-doc-contr-s-nal-obj.
define buffer b2_nal_arh-fin    for arh-fin-doc-contr-s-nal-obj.
define buffer b3_nal_arh-fin    for arh-fin-doc-contr-s-nal-obj.
define buffer b4_nal_arh-fin    for arh-fin-doc-contr-s-nal-obj.
/* FO */
define buffer b1_arh-fin-ob-obj for arh-fin-ob-contr-obj.
define buffer b2_arh-fin-ob-obj for arh-fin-ob-contr-obj.

define buffer buf_fin-doc for fin-doc.
define variable v-summ-obj as decimal no-undo init 0.
define variable v-vvdec as decimal no-undo .

/* на вчера */
run factord-end-day in this-procedure (input x-date-alone  , output  fact-order-2 ) .
run get-report-num in parParentProc(output g#report-num ) .

v-host-code  = v-cntxt-host-code-obj.
v-obj-type   = v-cntxt-obj-type .
v-obj-code   = v-cntxt-obj-code .




if x-SET_val_TYPE = 1 then v-curr = 0 .
   else do:
     { gbl/basecode.i v-host-code v-curr }
   end.

define stream  macr_excel .


DEFINE FRAME prt-frame
  HEADER  date_string AT 5 format "X(35)"
          string( "Страница " ) format "X(9)" AT 50 PAGE-NUMBER( PrnLibStream) AT 70 FORMAT ">>>>9" SKIP
          Line format "X(116)" AT 1
          with width {&DOS_CW_2} down stream-io use-text
          .

    Line = fill("-", 146).
    date_string = cur-time-print() .


/* создаем временный файл */
run gbl/_tmpfile.p ( "wb", ".txt", output v-file-name) .
output stream macr_excel to value(v-file-name)   .
v-ind = 1    .
num#str# = 0 .

    run prn-lib-open-stream in this-procedure (
       input parParentProc
      ,input {&LS_PS_A4}
      ,input yes /*p-is-stream*/
      ,input no /*p-append*/
      ).

    PUT  STREAM PrnLibStream reportname + " на " + string(x-date-alone, "99/99/9999")
         format "x(116)" SKIP .

    FORM HEADER
        Line format "X(146)" AT 1 SKIP
        "Продолжение - на следующей странице" AT 1
        date_string AT 50 format "X(35)"
        string( "Страница " ) format "X(9)" AT 90 PAGE-NUMBER( PrnLibStream) AT 100 FORMAT ">>>>9"
        with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .

    VIEW  STREAM PrnLibStream FRAME BottomFrame .

    FORM with FRAME prt-frame  .
    run waitfram-show in this-procedure ("Ждите печатаю...").

    run print-title in this-procedure .
    run make-tt in this-procedure .


    define variable i-page as integer no-undo .

    repeat i-page = 1 to glob-page :
        if i-page > 1 then
           Page  STREAM PrnLibStream .

        run print-1-razd in this-procedure .
        run print-2-razd in this-procedure .
        run print-3-razd in this-procedure .

        run print-ll in this-procedure .
        run print-cli in this-procedure ( input "Итого к выдаче" ,
                        input  "sum-obj-arh":U )
                      .
        run print-ll in this-procedure .
        run print-cli in this-procedure ( input "Плановый остаток на конец дня" ,
                        input  "sum-ost":U )
                      .


    end.



    HIDE  STREAM PrnLibStream FRAME BottomFrame .
    HIDE  STREAM PrnLibStream FRAME CheckList.
    output STREAM PrnLibStream CLOSE.
    output stream macr_excel  close .

    run paramls-write in this-procedure
      (input "file"
      ,input string(v-ind)
      ,input v-file-name
      ) .

    run paramls-write in this-procedure
        (input "charcol"
        ,input ""
        ,input "1"
        ) .

    run end-proc in this-procedure .
    run waitfram-hide in this-procedure .
    run prn-lib-prn-file in this-procedure (
        input parParentProc
       ,input 8
        ).

end.


procedure print-title :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define variable l-ii  as integer no-undo .
define variable l-jj  as integer no-undo .
define variable l-len as integer no-undo .
define variable l-m   as integer no-undo .

      num#str# = num#str# + 1 .
      num#col# =  1 .

      run macr_excel_char_with_format in this-procedure ( reportname + " на " + string(x-date-alone, "99/99/9999") , num#str# , num#col#  ).
      run macr_cell_format in this-procedure
          ( 12       ,    /* p-size   */
            true     ,    /* p-bold   */
            false    ,    /* p-italic */
            ?        ,    /* p-color  */
            num#str# ,    /* p-row    */
            num#col# ,    /* p-col    */
            ?        ,    /* p-row-2  */
            ?         ) . /* p-col-2  */



&scop var-print-n    do l-ii = 1 to num-entries( ~{&var-str-n} , "~{&new-line}"  )    :  ~
      l-len = length (entry( l-ii , ~{&var-str-n}  , "~{&new-line}")) .                 ~
      l-m = integer( l-len / 220 ) + 1 .                                                ~
      do l-jj = 1 to  l-m  :                                                            ~
          num#str# = num#str# + 1 .                                                     ~
          run macr_excel_char_with_format in this-procedure (                           ~
              substring(entry( l-ii , ~{&var-str-n}  , "~{&new-line}") , (( 220 * l-jj ) - 219 )  , 220 )  , num#str# , num#col# ) .~
          PUT  STREAM PrnLibStream ~
          substring(entry( l-ii , ~{&var-str-n}  , "~{&new-line}") , (( 220 * l-jj ) - 219 )  , 220 )   ~
          format "x(220)" SKIP .~
      end.                                                                                                       ~
  end.
 /*
&scop var-str-n  str1
{&var-print-n }

&scop var-str-n  str2
{&var-print-n }

&scop var-str-n  reportheader
{&var-print-n }

if can-find (first g#customer) then do:
      &scop var-str-n  "Поставщики :"
      {&var-print-n }
end.
for each  g#customer   :
    &scop var-str-n  g#customer.obj-name
    {&var-print-n }
end. /* for each */
*/

num#str# = num#str# + 1.
num#col# = 1.

 end. /* do */
end procedure. /* print-title */



procedure print-1-razd :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define variable str as character no-undo .
define variable v-dec as decimal no-undo .
define variable num#at as integer no-undo .
define variable p-value    as character no-undo .
define variable p-type     as character no-undo .
run print-ll  in this-procedure .

  assign
    num#str# = num#str# + 1
    num#col# =  2
    num#at   =  30
  .

  for each temp-obj   where temp-obj.nn = i-page
      on error undo, return error :
      str  = /* temp-obj.obj-name .  */ temp-obj.obj-type + " " + string(temp-obj.obj-code) .
      run macr_excel_char_with_format in this-procedure ( str , num#str# , num#col#  ).
      put stream prnlibstream unformatted p-fmt-align-string(str , 12 , 'right':U ) + "|"  at num#at format "x(13)" .
      num#col# = num#col# +  1 .
      num#at   = num#at + 13 .
  end. /* for each */
  run macr_cell_format in this-procedure
      ( 10    ,      /* p-size     */
        true  ,      /* p-bold     */
        true  ,      /* p-italic   */
        33    ,         /* p-color-bg */
        num#str# ,      /* p-row      */
        1 ,              /* p-col      */
        num#str# ,       /* p-row-2    */
        num#col#  ) .    /* p-col-2    */

put stream prnlibstream   unformatted skip .

  run print-ll in this-procedure  .
  run print-h in this-procedure  ( input "Остаток на нач.дня в кассах" ,
                input   {&attr-fin-plan_fin-ostatok-start})
                .
  run print-h in this-procedure  ( input  "План прихода" ,
                input   {&attr-fin-plan_fin-plan-pri})
                .
  run print-h in this-procedure  ( input  "Прочие доходы" ,
                input  {&attr-fin-plan_fin-proch})
                .
  run print-h in this-procedure  ( input "Прочие расходы" ,
                input  {&attr-fin-plan_fin-proch-ras})
                .
  run print-ll in this-procedure  .

  run print-cli in this-procedure  ( input "Итого к распределению" ,
                  input  "sum-obj":U )
                .
  run print-ll in this-procedure  .


 end. /* do */
end procedure. /* print-1-razd */


procedure make-tt :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :


if not can-find( first g#customer ) then do:
   run waitfram-show in this-procedure ("Подготовка списка Поставщиков...").
   for each buf_clients no-lock where
            (buf_clients.obj-type = {&cmp} or
             buf_clients.obj-type = {&prs} )
            :
            if
            (buf_clients.obj-type = {&cmp} and
             buf_clients.obj-code = v-host-code ) then next.

            create g#customer.
            BUFFER-COPY buf_clients to g#customer.
   end. /* for each */
end.
run waitfram-show in this-procedure ("Подготовка списка Объектов...").

for each obj-list
    on error undo, return error :
    var-calc-page = var-calc-page + 1 .
    create temp-obj.
    buffer-copy obj-list to temp-obj
    assign
      temp-obj.nn = truncate ( var-calc-page / 12.1 , 0 ) + 1
      glob-page   = temp-obj.nn
    .
end. /* for each */

run waitfram-show in this-procedure ("Проход по архивам...").


    for each g#customer :
        for each buf_contract no-lock where
            buf_contract.host-code = v-host-code and
            buf_contract.cli-type  = g#customer.obj-type   and
            buf_contract.cli-code  = g#customer.obj-code
            :
               run proc-body in this-procedure  (input buf_contract.contract-code ) .
        end. /* for each */

        run proc-body-cli in this-procedure    . /* без контракта     */
        /* run proc-body-plat in this-procedure   .  */ /* открытые платежи */

        if not can-find(first temp-cli where temp-cli.obj-type = g#customer.obj-type   and
                                             temp-cli.obj-code = g#customer.obj-code ) then do:
            if can-find(first temp-t where temp-t.cli-type = g#customer.obj-type   and
                                           temp-t.cli-code = g#customer.obj-code ) then do:
                create temp-cli.
                BUFFER-COPY g#customer to temp-cli
                assign
                  temp-cli.summ = v-summ-obj.
                .
                v-summ-obj = 0 .
            end.
        end.
       run waitfram-show in this-procedure ("Обработан поставщик: " + g#customer.obj-name ).
    end. /* g#customer */

    run waitfram-show in this-procedure ("Подготовка к печати" ).
 end. /* do */
end procedure. /* make-tt */


procedure print-h :
  do
  on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
define input parameter p-str as character no-undo .
define input parameter p-prop-code as character no-undo .
define variable v-dec  as decimal no-undo init 0 .
define variable num#at as integer no-undo .
define variable p-type     as character no-undo .
define variable v-value-character like ub.thbj-attr.property-value-character no-undo .
define variable v-value-date    like ub.thbj-attr.property-value-date no-undo .
define variable v-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define variable v-value-logical like ub.thbj-attr.property-value-logical no-undo .
define variable v-value-integer like ub.thbj-attr.property-value-integer no-undo .
define variable v-type     as character no-undo .
define variable v-found as decimal no-undo .


assign
  num#str# = num#str# + 1
  num#col# =  1
  num#at   = 30
.

run macr_excel_char_with_format in this-procedure ( p-str , num#str# , num#col#  ) .
put stream prnlibstream  unformatted p-str  at 1.

num#col# = num#col# + 1 .

  for each temp-obj  where temp-obj.nn = i-page
      on error undo, return error :
      run thbjattr_value in this-procedure  (
          input   temp-obj.obj-type ,
          input   temp-obj.obj-code ,
          input   p-prop-code       ,
          input   {&attr-fin-plan}  ,
          output  v-value-character ,
          output  v-value-date      ,
          output  v-value-decimal   ,
          output  v-value-integer   ,
          output  v-value-logical   ,
          output  v-type            ,
          output  v-found
          )
          .
      temp-obj.sum-obj = temp-obj.sum-obj + v-value-decimal .
      define variable v-temp-dec as decimal no-undo .
      case p-prop-code :
        when {&attr-fin-plan_fin-ostatok-start} then do:
          sum-ostatok-start = sum-ostatok-start + v-value-decimal.
          v-temp-dec        = sum-ostatok-start .
        end.
        when {&attr-fin-plan_fin-plan-pri} then do:
          sum-plan-pri = sum-plan-pri +  v-value-decimal .
          v-temp-dec   = sum-plan-pri .
        end.
        when {&attr-fin-plan_fin-proch} then do:
          sum-proch   = sum-proch +  v-value-decimal .
          v-temp-dec  = sum-proch .
        end.
        when {&attr-fin-plan_fin-proch-ras} then do:
          sum-proch-ras   = sum-proch-ras +  v-value-decimal .
          v-temp-dec  = sum-proch-ras .
        end.

        otherwise do:
           v-temp-dec  = 0 .
        end.
      end case.

      run macr_excel_dec in this-procedure ( v-value-decimal , num#str# , num#col#  ).
      put stream prnlibstream   unformatted v-value-decimal at num#at  format "->>>>>>>>9.99" .
      num#col# = num#col# +  1  .
      num#at   = num#at   +  13 .
  end. /* for each */

  run print-itog-col in this-procedure ( v-temp-dec , num#at ) .
  put stream prnlibstream unformatted skip.
  end. /* do */
end procedure. /* print-h */


procedure print-cli :
  do
  on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
define input parameter p-str as character no-undo .
define input parameter p-dec as character no-undo .
define variable num#at as integer no-undo .
define variable v-dec  as decimal no-undo .

assign
  num#str# = num#str# + 1
  num#col# =  1
  num#at   = 30
.

run macr_excel_char_with_format in this-procedure ( p-str , num#str# , num#col#  ) .
put stream prnlibstream  unformatted p-str  at 1.

num#col# = num#col# + 1 .

  for each temp-obj  where temp-obj.nn = i-page
      on error undo, return error :
      case p-dec :
          when "sum-obj" then do:
            v-dec = temp-obj.sum-obj.
            all-summ-dec-razd-1 = all-summ-dec-razd-1  + v-dec .
          end.
          when "sum-obj-arh" then do:
            v-dec = temp-obj.sum-obj-arh .
            all-summ-dec-razd-2 = all-summ-dec-razd-2  + v-dec .
          end.
          when "sum-ost" then do:
              v-dec =  temp-obj.sum-obj - temp-obj.sum-obj-arh .
              all-summ-dec-razd-3 = all-summ-dec-razd-3  + v-dec .
          end.
      end case.

      run macr_excel_dec in this-procedure ( v-dec , num#str# , num#col#  ).
      put stream prnlibstream   unformatted v-dec at num#at  format "->>>>>>>>9.99" .
      num#col# = num#col# +  1  .
      num#at   = num#at   +  13 .
  end. /* for each */

  if i-page = glob-page then do:
      case p-dec :
          when "sum-obj" then do:
              run macr_excel_dec in this-procedure ( all-summ-dec-razd-1 , num#str# , num#col#  ).
              put stream prnlibstream   unformatted all-summ-dec-razd-1 at num#at  format "->>>>>>>>9.99" .
           end.
          when "sum-obj-arh" then do:
              run macr_excel_dec in this-procedure ( all-summ-dec-razd-2 , num#str# , num#col#  ).
              put stream prnlibstream   unformatted all-summ-dec-razd-2 at num#at  format "->>>>>>>>9.99" .
           end.
          when "sum-ost" then do:
              run macr_excel_dec in this-procedure ( all-summ-dec-razd-3 , num#str# , num#col#  ).
              put stream prnlibstream   unformatted all-summ-dec-razd-3 at num#at  format "->>>>>>>>9.99" .
           end.

       end case.
      num#col# = num#col# +  1  .
      num#at   = num#at   +  13 .
  end.

  put stream prnlibstream unformatted skip.
  end. /* do */
end procedure. /* print-h */



 procedure print-ll :
  do
  on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
define variable num#at as integer no-undo .
define variable str as character no-undo .
  assign
    num#at   =  30
  .
  for each temp-obj where temp-obj.nn = i-page :
      str  = "------------+".
      put stream prnlibstream unformatted str at num#at format "x(13)" .
      num#at   = num#at + 13 .
  end. /* for each */

  if i-page = glob-page then do:
     put stream prnlibstream unformatted str at num#at format "x(13)" .
  end.
  end. /* do */
 end procedure. /* print-ll */



procedure print-itog-col :
do
on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
define input parameter v-summa as decimal no-undo .
define input parameter v-at as integer no-undo .
    if i-page = glob-page then do:
        run macr_excel_dec in this-procedure ( v-summa , num#str# , num#col#  ).
        put stream prnlibstream   unformatted v-summa at  v-at  format "->>>>>>>>9.99" .
    end.
end. /* do */
end procedure. /* print-itog-col */

procedure print-2-razd :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define variable str as character no-undo .
define variable v-dec as decimal no-undo .
define variable num#at as integer no-undo .
define variable p-value    as character no-undo .
define variable p-type     as character no-undo .
run print-ll in this-procedure .
  assign
    num#str# = num#str# + 1
    num#col# =  1
    num#at   =  1
    str      = "ПЛАН ВЫПЛАТ"
  .

  run macr_excel_char_with_format in this-procedure ( str , num#str# , num#col#  ).
  put stream prnlibstream unformatted str  at num#at format "x(13)" .

  assign
    num#col# =  2
    num#at   =  30
  .
  for each temp-obj   where temp-obj.nn = i-page
      on error undo, return error :
      str  = temp-obj.obj-name .
      run macr_excel_char_with_format in this-procedure ( str , num#str# , num#col#  ).
      put stream prnlibstream unformatted p-fmt-align-string(str , 12 , 'right':U ) + "|"  at num#at format "x(13)" .
      num#col# = num#col# +  1 .
      num#at   = num#at + 13 .
  end. /* for each */

  if i-page = glob-page then do:
    str =  "ИТОГО по пост.".
    run macr_excel_char_with_format in this-procedure ( str , num#str# , num#col#  ).
    put stream prnlibstream unformatted str  at num#at format "x(13)" .
  end.

  run macr_cell_format in this-procedure
      ( 10    ,      /* p-size     */
        true  ,      /* p-bold     */
        true  ,      /* p-italic   */
        40    ,         /* p-color-bg */
        num#str# ,      /* p-row      */
        1 ,              /* p-col      */
        num#str# ,       /* p-row-2    */
        num#col#  ) .    /* p-col-2    */

put stream prnlibstream   unformatted skip .

  run print-ll in this-procedure .

 end. /* do */
end procedure. /* print-1-razd */

procedure print-3-razd :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define variable str as character no-undo .
define variable v-dec as decimal no-undo .
define variable num#at as integer no-undo .
define variable p-value    as character no-undo .
define variable p-type     as character no-undo .


 for each  temp-cli
     on error undo, return error  with FRAME prt-frame :

     /* Название поставщика */
      assign
        num#str# = num#str# + 1
        num#col# =  1
        num#at   =  1
        .
      str = temp-cli.obj-name .
      run macr_excel_char_with_format in this-procedure ( str , num#str# , num#col#  ).
      put stream prnlibstream unformatted str  at num#at format "x(29)" .
      assign
        num#col# =  2
        num#at   =  30
      .

          for each temp-obj where temp-obj.nn = i-page
              on error undo, return error :
              for each temp-t where
                       temp-t.cli-type = temp-cli.obj-type and
                       temp-t.cli-code = temp-cli.obj-code and
                       temp-t.obj-type = temp-obj.obj-type and
                       temp-t.obj-code = temp-obj.obj-code :
                  /*
                  message
                  temp-t.cli-type skip
                  temp-t.cli-code skip
                  "-" skip
                  temp-t.obj-type skip
                  temp-t.obj-code skip
                  "-" skip
                  "Сумма ЗФО " temp-t.sum-fo  skip
                  "Сумма ЗП  " temp-t.sum-p   skip
                  "Сумма ОП  " temp-t.sum-op  skip
                  .
                   */
                v-dec =  temp-t.sum-fo - temp-t.sum-p + temp-t.sum-op .
                temp-obj.sum-obj-arh = temp-obj.sum-obj-arh + v-dec .

                run macr_excel_dec in this-procedure ( v-dec , num#str# , num#col#  ).
                put stream prnlibstream unformatted v-dec  at num#at format "->>>>>>>>9.99" .
              end. /* for each */
              num#col# = num#col# +  1 .
              num#at   = num#at + 13 .
          end. /* for each */
     /* Итого по поставщику */
      if i-page = glob-page then do:
        v-dec =  temp-cli.summ .
        run macr_excel_dec in this-procedure ( v-dec , num#str# , num#col#  ).
        put stream prnlibstream unformatted v-dec  at num#at format "->>>>>>>>9.99" .
      end.
      /* DOWN STREAM PrnLibStream 1 with FRAME prt-frame. */
 end. /* for each */



 end. /* do */
end procedure. /* print-1-razd */



procedure proc-body :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input parameter par-contract-code as integer no-undo .
      for each temp-obj :
      /* Посчитаем закрытые ФО по архиву */
                    find last b1_arh-fin-ob-obj no-lock      where
                        b1_arh-fin-ob-obj.host-code           = v-host-code                and
                        b1_arh-fin-ob-obj.obj-type            = temp-obj.obj-type          and
                        b1_arh-fin-ob-obj.obj-code            = temp-obj.obj-code          and
                        b1_arh-fin-ob-obj.contract-code       = par-contract-code          and
                        b1_arh-fin-ob-obj.fin-ext-doc-type    = {&expense}                 and
                        b1_arh-fin-ob-obj.calc-curr-code      = v-curr                     and
                        b1_arh-fin-ob-obj.sum-type            = "":U                       and
                        b1_arh-fin-ob-obj.fact-order         <= fact-order-2               and
                        b1_arh-fin-ob-obj.cli-type            = {&cmp}                     and
                        b1_arh-fin-ob-obj.cli-code            = v-host-code

                        use-index pi no-error .

                        if available b1_arh-fin-ob-obj then do:
                          find first temp-t where
                                      temp-t.cli-type = g#customer.obj-type and
                                      temp-t.cli-code = g#customer.obj-code and
                                      temp-t.obj-type = temp-obj.obj-type and
                                      temp-t.obj-code = temp-obj.obj-code  no-error .
                              if not available temp-t then
                                create temp-t.
                                  assign
                                      temp-t.cli-type = g#customer.obj-type
                                      temp-t.cli-code = g#customer.obj-code
                                      temp-t.obj-type = temp-obj.obj-type
                                      temp-t.obj-code = temp-obj.obj-code
                                      temp-t.sum-fo   = temp-t.sum-fo  + b1_arh-fin-ob-obj.expense
                                      v-summ-obj      = v-summ-obj     + b1_arh-fin-ob-obj.expense
                                  .
                        end.

                    find last b2_arh-fin-ob-obj no-lock      where
                        b2_arh-fin-ob-obj.host-code           = v-host-code                and
                        b2_arh-fin-ob-obj.obj-type            = temp-obj.obj-type          and
                        b2_arh-fin-ob-obj.obj-code            = temp-obj.obj-code          and
                        b2_arh-fin-ob-obj.contract-code       = par-contract-code          and
                        b2_arh-fin-ob-obj.fin-ext-doc-type    = {&income}                  and
                        b2_arh-fin-ob-obj.calc-curr-code      = v-curr                     and
                        b2_arh-fin-ob-obj.sum-type            = "":U                       and
                        b2_arh-fin-ob-obj.cli-type            = {&cmp}                     and
                        b2_arh-fin-ob-obj.cli-code            = v-host-code                and
                        b2_arh-fin-ob-obj.fact-order         <= fact-order-2
                        use-index pi no-error .
                        if available b2_arh-fin-ob-obj then do:
                          find first temp-t where
                                      temp-t.cli-type = g#customer.obj-type and
                                      temp-t.cli-code = g#customer.obj-code and
                                      temp-t.obj-type = temp-obj.obj-type and
                                      temp-t.obj-code = temp-obj.obj-code  no-error .
                              if not available temp-t then
                                create temp-t.
                                  assign
                                      temp-t.cli-type = g#customer.obj-type
                                      temp-t.cli-code = g#customer.obj-code
                                      temp-t.obj-type = temp-obj.obj-type
                                      temp-t.obj-code = temp-obj.obj-code
                                      temp-t.sum-fo   = temp-t.sum-fo  - b2_arh-fin-ob-obj.income
                                      v-summ-obj      = v-summ-obj     - b2_arh-fin-ob-obj.income
                                  .
                        end.

/*-----------------------------------------------------------------------------------------------------------------------*/
              /* Посчитаем закрытые платежи по архиву */
                    find last b1_beznal_arh-fin no-lock      where
                        b1_beznal_arh-fin.host-code           = v-host-code                and
                        b1_beznal_arh-fin.obj-type            = temp-obj.obj-type          and
                        b1_beznal_arh-fin.obj-code            = temp-obj.obj-code          and
                        b1_beznal_arh-fin.contract-code       = par-contract-code and
                        b1_beznal_arh-fin.code-schet          = 0                          and
                        b1_beznal_arh-fin.fin-ext-doc-type    = {&FDEDT_Expense_Cashless}  and /*рпп*/
                        b1_beznal_arh-fin.calc-curr-code      = v-curr                     and
                        b1_beznal_arh-fin.sum-type            = "sum-contract":U           and
                        b1_beznal_arh-fin.cli-type            = {&cmp}                     and
                        b1_beznal_arh-fin.cli-code            = v-host-code                and
                        b1_beznal_arh-fin.fact-order         <= fact-order-2
                        use-index pi no-error .
                        if available b1_beznal_arh-fin then do:
                          find first temp-t where
                                      temp-t.cli-type = g#customer.obj-type and
                                      temp-t.cli-code = g#customer.obj-code and
                                      temp-t.obj-type = temp-obj.obj-type and
                                      temp-t.obj-code = temp-obj.obj-code  no-error .
                              if not available temp-t then
                                create temp-t.
                                  assign
                                      temp-t.cli-type = g#customer.obj-type
                                      temp-t.cli-code = g#customer.obj-code
                                      temp-t.obj-type = temp-obj.obj-type
                                      temp-t.obj-code = temp-obj.obj-code
                                      temp-t.sum-p      = temp-t.sum-p  + b1_beznal_arh-fin.expense
                                      v-summ-obj        = v-summ-obj  - b1_beznal_arh-fin.expense
                                  .
                                  /*
                                  message temp-t.cli-type  skip
                                          temp-t.cli-code  skip
                                          "-1"              skip
                                          temp-t.obj-type  skip
                                          temp-t.obj-code  skip
                                          b1_beznal_arh-fin.expense
                                          b1_beznal_arh-fin.income
                                          .
                                    */


                        end.

                    find last b2_beznal_arh-fin no-lock      where
                        b2_beznal_arh-fin.host-code           = v-host-code                and
                        b2_beznal_arh-fin.obj-type            = temp-obj.obj-type          and
                        b2_beznal_arh-fin.obj-code            = temp-obj.obj-code          and
                        b2_beznal_arh-fin.contract-code       = par-contract-code and
                        b2_beznal_arh-fin.code-schet          = 0                          and
                        b2_beznal_arh-fin.fin-ext-doc-type    = {&FDEDT_Income_Cashless}   and /*ппп*/
                        b2_beznal_arh-fin.calc-curr-code      = v-curr                     and
                        b2_beznal_arh-fin.sum-type            = "sum-contract":U           and
                        b2_beznal_arh-fin.cli-type            = {&cmp}                     and
                        b2_beznal_arh-fin.cli-code            = v-host-code                and
                        b2_beznal_arh-fin.fact-order         <= fact-order-2
                        use-index pi no-error .
                        if available b2_beznal_arh-fin then do:
                          find first temp-t where
                                      temp-t.cli-type = g#customer.obj-type and
                                      temp-t.cli-code = g#customer.obj-code and
                                      temp-t.obj-type = temp-obj.obj-type   and
                                      temp-t.obj-code = temp-obj.obj-code  no-error .

                              if not available temp-t then
                                create temp-t.
                                  assign
                                      temp-t.cli-type = g#customer.obj-type
                                      temp-t.cli-code = g#customer.obj-code
                                      temp-t.obj-type = temp-obj.obj-type
                                      temp-t.obj-code = temp-obj.obj-code
                                      temp-t.sum-p      = temp-t.sum-p  - b2_beznal_arh-fin.income
                                      v-summ-obj      = v-summ-obj    + b2_beznal_arh-fin.income
                                  .
                        end.

  /*---------------------------------------------------------------*/
                    find last b1_nal_arh-fin no-lock      where
                        b1_nal_arh-fin.host-code           = v-host-code                and
                        b1_nal_arh-fin.obj-type            = temp-obj.obj-type          and
                        b1_nal_arh-fin.obj-code            = temp-obj.obj-code          and
                        b1_nal_arh-fin.contract-code       = par-contract-code and
                        b1_nal_arh-fin.fin-code-acc        = 0                          and
                        b1_nal_arh-fin.curr-code           = 0                          and
                        b1_nal_arh-fin.fin-ext-doc-type    = {&FDEDT_Expense_Cash}      and
                        b1_nal_arh-fin.calc-curr-code      = v-curr                     and
                        b1_nal_arh-fin.sum-type            = "sum-contract":U           and
                        b1_nal_arh-fin.cli-type            = {&cmp}                     and
                        b1_nal_arh-fin.cli-code            = v-host-code                and
                        b1_nal_arh-fin.fact-order         <= fact-order-2
                        use-index pi no-error .
                        if available b1_nal_arh-fin then do:
                          find first temp-t where
                                      temp-t.cli-type = g#customer.obj-type and
                                      temp-t.cli-code = g#customer.obj-code and
                                      temp-t.obj-type = temp-obj.obj-type and
                                      temp-t.obj-code = temp-obj.obj-code  no-error .
                              if not available temp-t then
                                create temp-t.
                                  assign
                                      temp-t.cli-type = g#customer.obj-type
                                      temp-t.cli-code = g#customer.obj-code
                                      temp-t.obj-type = temp-obj.obj-type
                                      temp-t.obj-code = temp-obj.obj-code
                                      temp-t.sum-p      = temp-t.sum-p  + b1_nal_arh-fin.expense
                                      v-summ-obj      = v-summ-obj  - b1_nal_arh-fin.expense
                                  .
                        end.

                    find last b2_nal_arh-fin no-lock      where
                        b2_nal_arh-fin.host-code           = v-host-code                and
                        b2_nal_arh-fin.obj-type            = temp-obj.obj-type          and
                        b2_nal_arh-fin.obj-code            = temp-obj.obj-code          and
                        b2_nal_arh-fin.contract-code       = par-contract-code          and
                        b2_nal_arh-fin.fin-code-acc        = 0                          and
                        b2_nal_arh-fin.curr-code           = 0                          and
                        b2_nal_arh-fin.fin-ext-doc-type    = {&FDEDT_Income_Cash}       and
                        b2_nal_arh-fin.calc-curr-code      = v-curr                     and
                        b2_nal_arh-fin.sum-type            = "sum-contract":U           and
                        b2_nal_arh-fin.cli-type            = {&cmp}                     and
                        b2_nal_arh-fin.cli-code            = v-host-code                and
                        b2_nal_arh-fin.fact-order         <= fact-order-2
                        use-index pi no-error .
                        if available b2_nal_arh-fin then do:
                          find first temp-t where
                                      temp-t.cli-type = g#customer.obj-type and
                                      temp-t.cli-code = g#customer.obj-code and
                                      temp-t.obj-type = temp-obj.obj-type   and
                                      temp-t.obj-code = temp-obj.obj-code  no-error .

                              if not available temp-t then
                                create temp-t.
                                  assign
                                      temp-t.cli-type = g#customer.obj-type
                                      temp-t.cli-code = g#customer.obj-code
                                      temp-t.obj-type = temp-obj.obj-type
                                      temp-t.obj-code = temp-obj.obj-code
                                      temp-t.sum-p      = temp-t.sum-p  - b2_nal_arh-fin.income
                                      v-summ-obj      = v-summ-obj  + b2_nal_arh-fin.income
                                  .
                        end.

  /*---------------------------------------------------------------*/
                    find last b3_nal_arh-fin no-lock      where
                        b3_nal_arh-fin.host-code           = v-host-code                and
                        b3_nal_arh-fin.obj-type            = temp-obj.obj-type          and
                        b3_nal_arh-fin.obj-code            = temp-obj.obj-code          and
                        b3_nal_arh-fin.contract-code       = par-contract-code and
                        b3_nal_arh-fin.fin-code-acc        = 0                          and
                        b3_nal_arh-fin.curr-code           = 0                          and
                        b3_nal_arh-fin.fin-ext-doc-type    = {&FDEDT_Expense_Payoff}    and
                        b3_nal_arh-fin.calc-curr-code      = v-curr                     and
                        b3_nal_arh-fin.sum-type            = "sum-contract":U           and
                        b3_nal_arh-fin.cli-type            = {&cmp}                     and
                        b3_nal_arh-fin.cli-code            = v-host-code                and

                        b3_nal_arh-fin.fact-order         <= fact-order-2
                        use-index pi no-error .
                        if available b3_nal_arh-fin then do:
                          find first temp-t where
                                      temp-t.cli-type = g#customer.obj-type and
                                      temp-t.cli-code = g#customer.obj-code and
                                      temp-t.obj-type = temp-obj.obj-type and
                                      temp-t.obj-code = temp-obj.obj-code  no-error .
                              if not available temp-t then
                                create temp-t.
                                  assign
                                      temp-t.cli-type = g#customer.obj-type
                                      temp-t.cli-code = g#customer.obj-code
                                      temp-t.obj-type = temp-obj.obj-type
                                      temp-t.obj-code = temp-obj.obj-code
                                      temp-t.sum-p      = temp-t.sum-p  + b3_nal_arh-fin.expense
                                      v-summ-obj      = v-summ-obj  - b3_nal_arh-fin.expense
                                  .
                        end.

                    find last b4_nal_arh-fin no-lock      where
                        b4_nal_arh-fin.host-code           = v-host-code                and
                        b4_nal_arh-fin.obj-type            = temp-obj.obj-type          and
                        b4_nal_arh-fin.obj-code            = temp-obj.obj-code          and
                        b4_nal_arh-fin.contract-code       = par-contract-code and
                        b4_nal_arh-fin.fin-code-acc        = 0                          and
                        b4_nal_arh-fin.curr-code           = 0                          and
                        b4_nal_arh-fin.fin-ext-doc-type    = {&FDEDT_Income_Payoff}     and
                        b4_nal_arh-fin.calc-curr-code      = v-curr                     and
                        b4_nal_arh-fin.sum-type            = "sum-contract":U           and
                        b4_nal_arh-fin.cli-type            = {&cmp}                     and
                        b4_nal_arh-fin.cli-code            = v-host-code                and
                        b4_nal_arh-fin.fact-order         <= fact-order-2
                        use-index pi no-error .
                        if available b4_nal_arh-fin then do:
                          find first temp-t where
                                      temp-t.cli-type = g#customer.obj-type and
                                      temp-t.cli-code = g#customer.obj-code and
                                      temp-t.obj-type = temp-obj.obj-type   and
                                      temp-t.obj-code = temp-obj.obj-code  no-error .

                              if not available temp-t then
                                create temp-t.
                                  assign
                                      temp-t.cli-type = g#customer.obj-type
                                      temp-t.cli-code = g#customer.obj-code
                                      temp-t.obj-type = temp-obj.obj-type
                                      temp-t.obj-code = temp-obj.obj-code
                                      temp-t.sum-p      = temp-t.sum-p  - b4_nal_arh-fin.income
                                      v-summ-obj      = v-summ-obj  + b4_nal_arh-fin.income
                                  .

                        end.
/*-----------------------------------------------------------------------------------------------------------------------*/
      end.  /* for each */
 end. /* do */
end procedure. /* proc-body */



procedure proc-body-plat :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :

  /* по открытым платежам */
for each temp-obj :
  for each buf_fin-doc no-lock
      where
      buf_fin-doc.host-code = v-host-code                and
      buf_fin-doc.obj-type  = temp-obj.obj-type          and
      buf_fin-doc.obj-code  = temp-obj.obj-code          and
      buf_fin-doc.status_    <> {&fin-fact}              and
      buf_fin-doc.doc-date  = x-date-alone               and
     (
      (
        buf_fin-doc.receiver-type  = g#customer.obj-type        and
        buf_fin-doc.receiver-code  = g#customer.obj-code        )
        or
      (
        buf_fin-doc.payer-type = g#customer.obj-type        and
        buf_fin-doc.payer-code = g#customer.obj-code        )
        )

        :
        find first temp-t where
                    temp-t.cli-type = g#customer.obj-type and
                    temp-t.cli-code = g#customer.obj-code and
                    temp-t.obj-type = temp-obj.obj-type   and
                    temp-t.obj-code = temp-obj.obj-code  no-error .

            if not available temp-t then
              create temp-t.
                assign
                    temp-t.cli-type = g#customer.obj-type
                    temp-t.cli-code = g#customer.obj-code
                    temp-t.obj-type = temp-obj.obj-type
                    temp-t.obj-code = temp-obj.obj-code
                .
              v-vvdec = (if v-curr = 0 then buf_fin-doc.sum-rubl else buf_fin-doc.sum-base ).
               /*message buf_fin-doc.fin-ext-doc-type  buf_fin-doc.sum-rubl. */
            if  buf_fin-doc.fin-ext-doc-type    = {&FDEDT_Income_Payoff} or
                buf_fin-doc.fin-ext-doc-type    = {&FDEDT_Income_Cash} or
                buf_fin-doc.fin-ext-doc-type    = {&FDEDT_Income_CashLess}
              then do:
                    temp-t.sum-op    = temp-t.sum-op  + v-vvdec.
                    v-summ-obj       = v-summ-obj     + v-vvdec.
            end.
            else do:
                    temp-t.sum-op    = temp-t.sum-op - v-vvdec .
                    v-summ-obj       = v-summ-obj    - v-vvdec .
            end.
  end. /* for each */
end. /* temp-obj */

 end. /* do */
end procedure. /* proc-body-plat */

procedure proc-body-cli :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
      for each temp-obj :
      /* Посчитаем закрытые ФО по архиву */
                    find last b1_arh-fin-ob-obj no-lock      where
                        b1_arh-fin-ob-obj.host-code           = v-host-code                and
                        b1_arh-fin-ob-obj.obj-type            = temp-obj.obj-type          and
                        b1_arh-fin-ob-obj.obj-code            = temp-obj.obj-code          and
                        b1_arh-fin-ob-obj.contract-code       = 0                          and
                        b1_arh-fin-ob-obj.cli-type            = g#customer.obj-type        and
                        b1_arh-fin-ob-obj.cli-code            = g#customer.obj-code        and
                        b1_arh-fin-ob-obj.fin-ext-doc-type    = {&expense}                 and
                        b1_arh-fin-ob-obj.calc-curr-code      = v-curr                     and
                        b1_arh-fin-ob-obj.sum-type            = "":U                       and
                        b1_arh-fin-ob-obj.fact-order         <= fact-order-2
                        use-index pi no-error .

                        if available b1_arh-fin-ob-obj then do:
                          find first temp-t where
                                      temp-t.cli-type = g#customer.obj-type and
                                      temp-t.cli-code = g#customer.obj-code and
                                      temp-t.obj-type = temp-obj.obj-type   and
                                      temp-t.obj-code = temp-obj.obj-code  no-error .
                              if not available temp-t then
                                create temp-t.
                                  assign
                                      temp-t.cli-type = g#customer.obj-type
                                      temp-t.cli-code = g#customer.obj-code
                                      temp-t.obj-type = temp-obj.obj-type
                                      temp-t.obj-code = temp-obj.obj-code
                                      temp-t.sum-fo   = temp-t.sum-fo  + b1_arh-fin-ob-obj.income
                                      v-summ-obj      = v-summ-obj     + b1_arh-fin-ob-obj.income                                  .
                        end.

                    find last b2_arh-fin-ob-obj no-lock      where
                        b2_arh-fin-ob-obj.host-code           = v-host-code                and
                        b2_arh-fin-ob-obj.obj-type            = temp-obj.obj-type          and
                        b2_arh-fin-ob-obj.obj-code            = temp-obj.obj-code          and
                        b2_arh-fin-ob-obj.contract-code       = 0                          and
                        b2_arh-fin-ob-obj.cli-type            = g#customer.obj-type        and
                        b2_arh-fin-ob-obj.cli-code            = g#customer.obj-code        and
                        b2_arh-fin-ob-obj.fin-ext-doc-type    = {&income}                  and
                        b2_arh-fin-ob-obj.calc-curr-code      = v-curr                     and
                        b2_arh-fin-ob-obj.sum-type            = "":U                       and
                        b2_arh-fin-ob-obj.fact-order         <= fact-order-2
                        use-index pi no-error .
                        if available b2_arh-fin-ob-obj then do:
                          find first temp-t where
                                      temp-t.cli-type = g#customer.obj-type and
                                      temp-t.cli-code = g#customer.obj-code and
                                      temp-t.obj-type = temp-obj.obj-type and
                                      temp-t.obj-code = temp-obj.obj-code  no-error .
                              if not available temp-t then
                                create temp-t.
                                  assign
                                      temp-t.cli-type = g#customer.obj-type
                                      temp-t.cli-code = g#customer.obj-code
                                      temp-t.obj-type = temp-obj.obj-type
                                      temp-t.obj-code = temp-obj.obj-code
                                      temp-t.sum-fo   = temp-t.sum-fo  - b2_arh-fin-ob-obj.expense
                                      v-summ-obj      = v-summ-obj     - b2_arh-fin-ob-obj.expense
                                  .
                        end.

/*-----------------------------------------------------------------------------------------------------------------------*/
              /* Посчитаем закрытые платежи по архиву */
                    find last b1_beznal_arh-fin no-lock      where
                        b1_beznal_arh-fin.host-code           = v-host-code                and
                        b1_beznal_arh-fin.obj-type            = temp-obj.obj-type          and
                        b1_beznal_arh-fin.obj-code            = temp-obj.obj-code          and
                        b1_beznal_arh-fin.code-schet          = 0                          and
                        b1_beznal_arh-fin.contract-code       = 0                          and
                        b1_beznal_arh-fin.cli-type            = g#customer.obj-type        and
                        b1_beznal_arh-fin.cli-code            = g#customer.obj-code        and
                        b1_beznal_arh-fin.fin-ext-doc-type    = {&FDEDT_Expense_Cashless}  and /*рпп*/
                        b1_beznal_arh-fin.calc-curr-code      = v-curr                     and
                        b1_beznal_arh-fin.sum-type            = "sum-contract":U           and
                        b1_beznal_arh-fin.fact-order         <= fact-order-2
                        use-index pi no-error .
                        if available b1_beznal_arh-fin then do:
                          find first temp-t where
                                      temp-t.cli-type = g#customer.obj-type and
                                      temp-t.cli-code = g#customer.obj-code and
                                      temp-t.obj-type = temp-obj.obj-type and
                                      temp-t.obj-code = temp-obj.obj-code  no-error .
                              if not available temp-t then
                                create temp-t.
                                  assign
                                      temp-t.cli-type = g#customer.obj-type
                                      temp-t.cli-code = g#customer.obj-code
                                      temp-t.obj-type = temp-obj.obj-type
                                      temp-t.obj-code = temp-obj.obj-code
                                      temp-t.sum-p      = temp-t.sum-p  + b1_beznal_arh-fin.income
                                      v-summ-obj        = v-summ-obj    - b1_beznal_arh-fin.income
                                  .
                                  /*
                                  message temp-t.cli-type  skip
                                          temp-t.cli-code  skip
                                          "-1"              skip
                                          temp-t.obj-type  skip
                                          temp-t.obj-code  skip
                                          b1_beznal_arh-fin.expense
                                          b1_beznal_arh-fin.income
                                          .
                                    */


                        end.

                    find last b2_beznal_arh-fin no-lock      where
                        b2_beznal_arh-fin.host-code           = v-host-code                and
                        b2_beznal_arh-fin.obj-type            = temp-obj.obj-type          and
                        b2_beznal_arh-fin.obj-code            = temp-obj.obj-code          and
                        b2_beznal_arh-fin.code-schet          = 0                          and
                        b2_beznal_arh-fin.contract-code       = 0                          and
                        b2_beznal_arh-fin.cli-type            = g#customer.obj-type        and
                        b2_beznal_arh-fin.cli-code            = g#customer.obj-code        and
                        b2_beznal_arh-fin.fin-ext-doc-type    = {&FDEDT_Income_Cashless}   and /*ппп*/
                        b2_beznal_arh-fin.calc-curr-code      = v-curr                     and
                        b2_beznal_arh-fin.sum-type            = "sum-contract":U           and
                        b2_beznal_arh-fin.fact-order         <= fact-order-2
                        use-index pi no-error .
                        if available b2_beznal_arh-fin then do:
                          find first temp-t where
                                      temp-t.cli-type = g#customer.obj-type and
                                      temp-t.cli-code = g#customer.obj-code and
                                      temp-t.obj-type = temp-obj.obj-type   and
                                      temp-t.obj-code = temp-obj.obj-code  no-error .

                              if not available temp-t then
                                create temp-t.
                                  assign
                                      temp-t.cli-type = g#customer.obj-type
                                      temp-t.cli-code = g#customer.obj-code
                                      temp-t.obj-type = temp-obj.obj-type
                                      temp-t.obj-code = temp-obj.obj-code
                                      temp-t.sum-p      = temp-t.sum-p  - b2_beznal_arh-fin.expense
                                      v-summ-obj        = v-summ-obj    + b2_beznal_arh-fin.expense
                                  .
                        end.

  /*---------------------------------------------------------------*/
                    find last b1_nal_arh-fin no-lock      where
                        b1_nal_arh-fin.host-code           = v-host-code                and
                        b1_nal_arh-fin.obj-type            = temp-obj.obj-type          and
                        b1_nal_arh-fin.obj-code            = temp-obj.obj-code          and
                        b1_nal_arh-fin.fin-code-acc        = 0                          and
                        b1_nal_arh-fin.curr-code           = 0                          and
                        b1_nal_arh-fin.contract-code       = 0                          and
                        b1_nal_arh-fin.cli-type            = g#customer.obj-type        and
                        b1_nal_arh-fin.cli-code            = g#customer.obj-code        and
                        b1_nal_arh-fin.fin-ext-doc-type    = {&FDEDT_Expense_Cash}      and
                        b1_nal_arh-fin.calc-curr-code      = v-curr                     and
                        b1_nal_arh-fin.sum-type            = "sum-contract":U           and
                        b1_nal_arh-fin.fact-order         <= fact-order-2
                        use-index pi no-error .
                        if available b1_nal_arh-fin then do:
                          find first temp-t where
                                      temp-t.cli-type = g#customer.obj-type and
                                      temp-t.cli-code = g#customer.obj-code and
                                      temp-t.obj-type = temp-obj.obj-type and
                                      temp-t.obj-code = temp-obj.obj-code  no-error .
                              if not available temp-t then
                                create temp-t.
                                  assign
                                      temp-t.cli-type = g#customer.obj-type
                                      temp-t.cli-code = g#customer.obj-code
                                      temp-t.obj-type = temp-obj.obj-type
                                      temp-t.obj-code = temp-obj.obj-code
                                      temp-t.sum-p      = temp-t.sum-p  + b1_nal_arh-fin.income
                                      v-summ-obj      = v-summ-obj  - b1_nal_arh-fin.income
                                  .
                        end.

                    find last b2_nal_arh-fin no-lock      where
                        b2_nal_arh-fin.host-code           = v-host-code                and
                        b2_nal_arh-fin.obj-type            = temp-obj.obj-type          and
                        b2_nal_arh-fin.obj-code            = temp-obj.obj-code          and
                        b2_nal_arh-fin.fin-code-acc        = 0                          and
                        b2_nal_arh-fin.curr-code           = 0                          and
                        b2_nal_arh-fin.contract-code       = 0                          and
                        b2_nal_arh-fin.cli-type            = g#customer.obj-type        and
                        b2_nal_arh-fin.cli-code            = g#customer.obj-code        and
                        b2_nal_arh-fin.fin-ext-doc-type    = {&FDEDT_Income_Cash}       and
                        b2_nal_arh-fin.calc-curr-code      = v-curr                     and
                        b2_nal_arh-fin.sum-type            = "sum-contract":U           and
                        b2_nal_arh-fin.fact-order         <= fact-order-2
                        use-index pi no-error .
                        if available b2_nal_arh-fin then do:
                          find first temp-t where
                                      temp-t.cli-type = g#customer.obj-type and
                                      temp-t.cli-code = g#customer.obj-code and
                                      temp-t.obj-type = temp-obj.obj-type   and
                                      temp-t.obj-code = temp-obj.obj-code  no-error .

                              if not available temp-t then
                                create temp-t.
                                  assign
                                      temp-t.cli-type = g#customer.obj-type
                                      temp-t.cli-code = g#customer.obj-code
                                      temp-t.obj-type = temp-obj.obj-type
                                      temp-t.obj-code = temp-obj.obj-code
                                      temp-t.sum-p      = temp-t.sum-p  - b2_nal_arh-fin.expense
                                      v-summ-obj      = v-summ-obj  + b2_nal_arh-fin.expense
                                  .
                        end.

  /*---------------------------------------------------------------*/
                    find last b3_nal_arh-fin no-lock      where
                        b3_nal_arh-fin.host-code           = v-host-code                and
                        b3_nal_arh-fin.obj-type            = temp-obj.obj-type          and
                        b3_nal_arh-fin.obj-code            = temp-obj.obj-code          and
                        b3_nal_arh-fin.fin-code-acc        = 0                          and
                        b3_nal_arh-fin.curr-code           = 0                          and
                        b3_nal_arh-fin.contract-code       = 0                          and
                        b3_nal_arh-fin.cli-type            = g#customer.obj-type        and
                        b3_nal_arh-fin.cli-code            = g#customer.obj-code        and

                        b3_nal_arh-fin.fin-ext-doc-type    = {&FDEDT_Expense_Payoff}    and
                        b3_nal_arh-fin.calc-curr-code      = v-curr                     and
                        b3_nal_arh-fin.sum-type            = "sum-contract":U           and
                        b3_nal_arh-fin.fact-order         <= fact-order-2
                        use-index pi no-error .
                        if available b3_nal_arh-fin then do:
                          find first temp-t where
                                      temp-t.cli-type = g#customer.obj-type and
                                      temp-t.cli-code = g#customer.obj-code and
                                      temp-t.obj-type = temp-obj.obj-type and
                                      temp-t.obj-code = temp-obj.obj-code  no-error .
                              if not available temp-t then
                                create temp-t.
                                  assign
                                      temp-t.cli-type = g#customer.obj-type
                                      temp-t.cli-code = g#customer.obj-code
                                      temp-t.obj-type = temp-obj.obj-type
                                      temp-t.obj-code = temp-obj.obj-code
                                      temp-t.sum-p      = temp-t.sum-p  + b3_nal_arh-fin.income
                                      v-summ-obj      = v-summ-obj  - b3_nal_arh-fin.income
                                  .
                        end.

                    find last b4_nal_arh-fin no-lock      where
                        b4_nal_arh-fin.host-code           = v-host-code                and
                        b4_nal_arh-fin.obj-type            = temp-obj.obj-type          and
                        b4_nal_arh-fin.obj-code            = temp-obj.obj-code          and

                        b4_nal_arh-fin.contract-code       = 0                          and
                        b4_nal_arh-fin.cli-type            = g#customer.obj-type        and
                        b4_nal_arh-fin.cli-code            = g#customer.obj-code        and

                        b4_nal_arh-fin.fin-code-acc        = 0                          and
                        b4_nal_arh-fin.curr-code           = 0                          and
                        b4_nal_arh-fin.fin-ext-doc-type    = {&FDEDT_Income_Payoff}     and
                        b4_nal_arh-fin.calc-curr-code      = v-curr                     and
                        b4_nal_arh-fin.sum-type            = "sum-contract":U           and
                        b4_nal_arh-fin.fact-order         <= fact-order-2
                        use-index pi no-error .
                        if available b4_nal_arh-fin then do:
                          find first temp-t where
                                      temp-t.cli-type = g#customer.obj-type and
                                      temp-t.cli-code = g#customer.obj-code and
                                      temp-t.obj-type = temp-obj.obj-type   and
                                      temp-t.obj-code = temp-obj.obj-code  no-error .

                              if not available temp-t then
                                create temp-t.
                                  assign
                                      temp-t.cli-type = g#customer.obj-type
                                      temp-t.cli-code = g#customer.obj-code
                                      temp-t.obj-type = temp-obj.obj-type
                                      temp-t.obj-code = temp-obj.obj-code
                                      temp-t.sum-p      = temp-t.sum-p  - b4_nal_arh-fin.expense
                                      v-summ-obj      = v-summ-obj  + b4_nal_arh-fin.expense
                                  .

                        end.
/*-----------------------------------------------------------------------------------------------------------------------*/
   end.
 end. /* do */
end procedure. /* proc-body */

{ rep/r-libmcr.i macr_excel  }