block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-ordrcv.p $
$Archive: rep/r-ordrcv.p $

График поставок (расчет отчета)

Автор: Комаров Иван Сергеевич
Дата создания: 10/07/10
Author: Ivan Komarov
Creation date: 10/07/10

*/

define input parameter parParentProc  as widget-handle no-undo.
define input parameter p-det-rcv      as logical       no-undo.
define input parameter p-sort-by-name as logical       no-undo.
define input parameter p-radpost      as integer       no-undo.
define input parameter p-postname     as character     no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-ordrcv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-ordrcv.p $":U .
define variable vss-description as character no-undo init "График поставок".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ cmp/r-pril.i new }
{ rep/r-sym.i    }
{ rep/f-fdec.i   }
{ gbl/prn-lib.i  }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ gbl/paramls.i  }
{ cmp/trg-def.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

def SHARED temp-table g#post-f NO-UNDO
  field obj-type like ub.clients.obj-type
  field obj-code like ub.clients.obj-code
  field obj-name like ub.clients.obj-name
  field grp-code like ub.clients.grp-code
  field grp-name like ub.clients.grp-name
  field lvl-num  like ub.cli-grp.lvl-num
  INDEX pi IS UNIQUE PRIMARY obj-type obj-code
  INDEX p1  obj-name
  .

define temp-table temp-ord-rcv no-undo
  FIELD obj-type         as character
  FIELD obj-code         as integer
  FIELD doc-code         as character
  FIELD post-code        as integer
  FIELD post-name        as character
  FIELD rcv-code         as character
  FIELD rcv-status       as character
  FIELD ship-date        as date
  INDEX pi is primary obj-type obj-code doc-code
  .

define buffer buf_clients      for ub.clients .
define buffer buf_obj-list     for obj-list .

define variable Counter1          as integer   no-undo .
define variable v-user-action     as character no-undo .
define variable v-printed         as logical   no-undo .
define variable disabledoptions   as integer   no-undo .
define variable v-orient-page     as character no-undo .

define variable v-file-name       as character no-undo .
define variable v-file-name-ind   as integer   no-undo .
define variable v-line            as character no-undo .
define variable g#report-num      as integer   no-undo .

define stream  out-stream .

run get-report-num  in parparentproc (output  g#report-num).

   assign
      v-line  = fill( "-" , 96 )
   .

  { cmp/open-out.i stream out-stream  " " }

  find first obj-list.
  if not available obj-list then do :
    message
      "Не выбран объект!"
    view-as alert-box error.
    return.
  end.
  for each sheetf :
      delete sheetf.
  end.

  if p-det-rcv then do: /*показываем поставки*/
    put stream out-stream  reportname  at 40 format "x(20)" skip
                          trim(str1)  format "x(75)" skip
                          trim(str2)  format "x(75)" skip
                          trim(str3)  format "x(75)" skip
                          trim(str4)  format "x(200)" skip
                          ReportHeader format "x(200)" .
    define frame ord-rcv
            sym1                    column-label ":!:" format "X(1)"  space(0)
            temp-ord-rcv.post-code  column-label "    Код    " format "999999999" space(0)
            sym2                    column-label ":!:" format "X(1)"  space(0)
            temp-ord-rcv.post-name  column-label "Наименование поставщика" format "X(40)" space(0)
            sym3                    column-label ":!:" format "X(1)"  space(0)
            temp-ord-rcv.rcv-code   column-label "  Поставка  " format "99999999999" space(0)
            sym4                    column-label ":!:" format "X(1)"  space(0)
            temp-ord-rcv.rcv-status column-label " Статус ! поставки " format "X(14)" space(0)
            sym5                    column-label ":!:" format "X(1)"  space(0)
            temp-ord-rcv.ship-date  column-label " Заказ от... " format "99/99/9999" space(0)
            sym6                    column-label ":!:" format "X(1)"  space(0)
    header
    string( "Страница " + string( PAGE-NUMBER( out-stream ), ">>>9" ) ) at 80 format "X(13)"
    v-line format "X(96)" at 1
    with width {&DOS_CW} down stream-io use-text NO-BOX.
    VIEW stream Out-stream FRAME ord-rcv .
    FORM with FRAME ord-rcv .
  end.
  else do: /*НЕ показываем поставки*/
    put stream out-stream  reportname  at 30 format "x(20)" skip
                          trim(str1)  format "x(75)" skip
                          trim(str2)  format "x(75)" skip
                          trim(str3)  format "x(75)" skip
                          trim(str4)  format "x(200)" skip
                          ReportHeader format "x(200)" .
    define frame ord
            sym1                    column-label ":!:" format "X(1)"  space(0)
            temp-ord-rcv.post-code  column-label "    Код    " format "999999999" space(0)
            sym2                    column-label ":!:" format "X(1)"  space(0)
            temp-ord-rcv.post-name  column-label "Наименование поставщика" format "X(40)" space(0)
            sym3                    column-label ":!:" format "X(1)"  space(0)
            temp-ord-rcv.ship-date  column-label " Заказ от... " format "99/99/9999" space(0)
            sym4                    column-label ":!:" format "X(1)"  space(0)
    header
    string( "Страница " + string( PAGE-NUMBER( out-stream ), ">>>9" ) ) at 55 format "X(13)"
    v-line format "X(68)" at 1
    with width {&DOS_CW} down stream-io use-text NO-BOX.
    VIEW stream Out-stream FRAME ord .
    FORM with FRAME ord .
  end.

{ gbl/working.i }

  assign  Counter1 = 0 .
  { rep/repfrm.i def }   /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 1 } /* Показать окно информации о текущем процессе */

  create sheetf.
  assign sheetf.sheet-num = 1.
  if p-det-rcv then do:
    assign
      sheetf.Excel-Column-Lable = "Код,Наименование поставщика,Поставка,Статус поставки,Заказ от..."
      sheetf.Sizes  = "9,40,11,14,10"
      Sheetf.ColFOrmat   = "1=@;2=@;3=@;4=@;5=dd/mm/yyyy"
    .
  end.
  else do:
    assign
      sheetf.Excel-Column-Lable = "Код,Наименование поставщика,Заказ от..."
      sheetf.Sizes  = "9,40,10"
      Sheetf.ColFOrmat   = "1=@;2=@;3=dd/mm/yyyy"
    .
  end.

   run rep/extitle.p ( input 1).

   run report-exec in this-procedure.
   run text-report in this-procedure.
   run excel-report in this-procedure.

  { rep/repfrm.i off }
  { gbl/stopwork.i }

  output stream out-stream close.
  {&CloseExcel}
  DisabledOptions = 8.
  ReportFontNum = 7.

  run gbl/prnfilen.w
    ( input  ""
    , input  DisabledOptions
    ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
    , input  ReportFontNum
    ,output v-user-action
    ,output v-printed
  ) .

 /*--------------------------------------*/
procedure report-exec :
  define buffer buf_ord-doc     for ub.ord-doc.
  define buffer buf_ord-doc-rcv for ub.ord-doc-rcv.

  for each obj-list no-lock :
     if p-postname = {&all} then do :  /*все поставщики */
        for each buf_ord-doc no-lock
            where buf_ord-doc.obj-type    = obj-list.obj-type
              and buf_ord-doc.obj-code    = obj-list.obj-code
              and buf_ord-doc.ship-date   = x-date-start
              and buf_ord-doc.doc-type    <> {&O-O}
              :
                {rep\r-ordrcv.i}
        end.
     end.
     else do: /*выбранные поставщики */
        for each g#post-f :
            for each buf_ord-doc no-lock
                where buf_ord-doc.obj-type    = obj-list.obj-type
                  and buf_ord-doc.obj-code    = obj-list.obj-code
                  and buf_ord-doc.ship-date   = x-date-start
                  and buf_ord-doc.cli-type    = g#post-f.obj-type
                  and buf_ord-doc.cli-code    = g#post-f.obj-code
                  and buf_ord-doc.doc-type    <> {&O-O}
                  :
                    {rep\r-ordrcv.i}
            end.
        end.
     end.
  end.
end procedure . /*report-exec*/

/*--------------------------------------*/
procedure text-report :
    define variable v-flag as logical no-undo.
    for each temp-ord-rcv
      break
      by (if p-sort-by-name then temp-ord-rcv.post-name else "" )
      by temp-ord-rcv.post-code
      :
        assign v-flag = yes.
        if p-det-rcv then do: /*показываем поставки*/
          display stream Out-stream
          sym1 sym2 sym3 sym4 sym5 sym6
          temp-ord-rcv.post-code
          temp-ord-rcv.post-name
          temp-ord-rcv.rcv-code
          temp-ord-rcv.rcv-status
          temp-ord-rcv.ship-date
          with frame ord-rcv .
          down stream Out-stream 1 with frame ord-rcv .
        end.
        else do: /*НЕ показываем поставки*/
          display stream Out-stream
          sym1 sym2 sym3 sym4
          temp-ord-rcv.post-code
          temp-ord-rcv.post-name
          temp-ord-rcv.ship-date
          with frame ord .
          down stream Out-stream 1 with frame ord .
        end.

    end.
    if v-flag then do:
      if p-det-rcv then do:
        put stream out-stream  v-line format "x(96)".
      end.
      else do:
        put stream out-stream  v-line format "x(68)".
      end.
    end.
end procedure . /*text-report*/

/*--------------------------------------*/
procedure excel-report :
    for each temp-ord-rcv
      break
      by (if p-sort-by-name then temp-ord-rcv.post-name else "" )
      by temp-ord-rcv.post-code
      :
        if p-det-rcv then do: /*показываем поставки*/
          {&PutExcel}
          temp-ord-rcv.post-code  {&tabulation}
          temp-ord-rcv.post-name  {&tabulation}
          temp-ord-rcv.rcv-code   {&tabulation}
          temp-ord-rcv.rcv-status {&tabulation}
          temp-ord-rcv.ship-date  {&new-line}
          .
        end.
        else do: /*НЕ показываем поставки*/
          {&PutExcel}
          temp-ord-rcv.post-code  {&tabulation}
          temp-ord-rcv.post-name  {&tabulation}
          temp-ord-rcv.ship-date  {&new-line}
          .
        end.
    end.
end procedure . /*excel-report*/