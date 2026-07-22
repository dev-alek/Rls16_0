block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-kfsale.p $
$Archive: rep/r-kfsale.p $

Отчет Реализация топлива (Кедр)

Автор: Хныкин Павел Андреевич
Дата создания: 04/22/09
Author: Pavel Khnykin
Creation date: 04/22/09

*/
define input  parameter parparentproc as handle    no-undo .
define input  parameter p-is-schedule as logical   no-undo .
define input  parameter p-date-begin  as date      no-undo .
define input  parameter p-shift-begin as integer   no-undo .
define input  parameter p-date-end    as date      no-undo .
define input  parameter p-shift-end   as integer   no-undo .
define input  parameter p-report-dir  as character no-undo .
define input  parameter p-db-num      as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-kfsale.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-kfsale.p $":U .
define variable vss-description as character no-undo init "Отчет Реализация топлива (Кедр)".
{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/library.i      }
{ str/lib-trn.i      }
{ gbl/getcntxt.i def }
{ rep/r-sym.i        }
{ cmp/r-pril.i new   }
{ gbl/prn-lib.i      }
{ gbl/cur-time.i     }
{ gbl/paramls.i      }
define variable g#report-num  as integer    no-undo .
{ rep/kfsalexl.i     }
{ gbl/waitfram.i     }

define stream sout .
define stream in-stream.


define temp-table tt-obj-list no-undo
  field obj-type                like ub.clients.obj-type
  field obj-code                like ub.clients.obj-code
  field obj-name                like ub.clients.obj-name
  field shift-date-str          as character
  field report-name             as character
  field cre-report              as logical
index pi is primary unique
  obj-type
  obj-code
index name
  obj-name
index cre
  cre-report
.


define temp-table tt-gds no-undo like ub.goods
  field id      as integer
  field b-code  like ub.bar-code.b-code
index pi is primary unique
  id
  gds-code
index gds
  gds-code
index bcode
  b-code
.


define temp-table tt-report no-undo
  field obj-type                    like ub.rvs-line-pump.obj-type
  field obj-code                    like ub.rvs-line-pump.obj-code
  field pump-code                   like ub.rvs-line-pump.pump-code
  field gds-code                    like ub.rvs-line-pump.gds-code

  field obj-name                    as character  /* название АЗК     */
  field gds-name                    as character  /* название топлива */
  field end-state-el-cnt            as decimal    /*                  */
  field begin-state-el-cnt          as decimal    /*                  */
  field sale-state-el-cnt           as decimal    /*                  */
  field end-state-mh-cnt            as decimal    /*                  */
  field begin-state-mh-cnt          as decimal    /*                  */
  field sale-state-mh-cnt           as decimal    /*                  */
  field state-divergence            as decimal    /*                  */
  field sale-state                  as decimal    /*                  */
  field sale-techfuel               as decimal    /*                  */
  field sale-total                  as decimal    /*                  */
index pi is unique primary
  obj-type
  obj-code
  gds-code
  pump-code
.

define variable v-date                    as date      no-undo .
define variable v-time                    as integer   no-undo .
define variable v-line          as character no-undo .
define variable v-date-str      as character no-undo .
define variable v-obj-str       as character no-undo .
define variable v-yesterday     as date      no-undo .
define variable v-report-dir    as character no-undo .
define variable v-report-error  as character no-undo .
define variable v-message       as character no-undo .

&scop f-width 360

define frame f-doc
  sym1                          column-label ":!:!"     format "X(1)" space (0)
  tt-report.gds-name            column-label "Марка"    format "X(30)" space (0)
  sym2                          column-label ":!:!"     format "X(1)" space (0)
  tt-report.pump-code           column-label "ТРК "     format "99" space (0)
  sym3                          column-label ":!:!"     format "X(1)" space (0)
  tt-report.end-state-el-cnt    column-label "Конец пер" format "->>>>>>>>>>9.99" space (0)
  sym4                          column-label ":!:!" format "X(1)" space (0)
  tt-report.begin-state-el-cnt  column-label "Начало пер" format "->>>>>>>>>>9.99" space (0)
  sym5                          column-label ":!:!" format "X(1)" space (0)
  tt-report.sale-state-el-cnt   column-label "Р-йия" format "->>>>>>>>>>9.99" space (0)
  sym6                          column-label ":!:!" format "X(1)" space (0)
  tt-report.end-state-mh-cnt    column-label "Конец пер" format "->>>>>>>>>>9.99" space (0)
  sym7                          column-label ":!:!" format "X(1)" space (0)
  tt-report.begin-state-mh-cnt  column-label "Начало пер" format "->>>>>>>>>>9.99" space (0)
  sym8                          column-label ":!:!" format "X(1)" space (0)
  tt-report.sale-state-mh-cnt   column-label "Р-йия" format "->>>>>>>>>>9.99" space (0)
  sym9                          column-label ":!:!" format "X(1)" space (0)
  tt-report.state-divergence    column-label "Расхождение" format "->>>>>>>>>>9.99" space (0)
  sym10                         column-label ":!:!" format "X(1)" space (0)
  tt-report.sale-state          column-label "Реализация " format "->>>>>>>>>>9.99" space (0)
  sym11                         column-label ":!:!" format "X(1)" space (0)
  tt-report.sale-techfuel       column-label "Техпролив" format "->>>>>>>>>>9.99" space (0)
  sym12                         column-label ":!:!" format "X(1)" space (0)
  tt-report.sale-total          column-label "Итого р-ция" format "->>>>>>>>>>9.99" space (0)
  sym13                         column-label ":!:!" format "X(1)" space (0)
header

  string( "Страница " + string( PAGE-NUMBER( sout ), ">>>9" ) ) at 117 format "X(13)" skip
  v-line format "X(120)" at 1
with width {&DOS_CW} down stream-io .
form header
        v-line format "X(120)" at 1 SKIP
        "Продолжение - на следующей странице" at 1 SKIP
with frame BottomFrame width {&A4_CW} PAGE-BOTTOM NO-LABELS NO-BOX .


assign
  v-line = fill( "-" , 30 )
.

form with frame f-doc.


do
on error undo, return error return-value
:
  run cur-time in this-procedure ( output v-date
                                 , output v-time
                                 ) .
  /* дата для тестировани date("06/03/2009") */
  assign
    v-yesterday = v-date - 1
  .
  run write-log in this-procedure ( input substitute("Запуск отчета 'Реализация топлива' для БД &1 " , p-db-num ) ) .
  run clear-tt in this-procedure .
  run write-log in this-procedure ( input "Расчет данных для отчета":U  ) .
  run fill-tt in this-procedure .
  run write-log in this-procedure ( input "Вывод отчета в Excel":U  ) .
  run print-report in this-procedure ( output v-report-error ).
  run clear-tt in this-procedure .
  run write-log in this-procedure ( input "Формирование отчета завершено":U  ) .
  if v-report-error <> "" and v-report-error <> ?
  then do:
    return error substitute( "&1", v-report-error).
  end.
end.

/* ========================================================================= */
procedure print-report :
  define output parameter p-error-message as character no-undo .
do
on error undo, return error return-value
:
  if p-is-schedule = yes
  then do:
    run print-schedule in this-procedure ( output p-error-message).
  end.
  else do:
    run print-no-schedule in this-procedure .
  end.
end.

end procedure. /* print-report */


/* ========================================================================= */
procedure print-no-schedule :

do
on error undo, return error return-value
:
  run get-report-num in parparentproc (output g#report-num).
  { cmp/open-out.i stream sout " " {&LS_PS_A4} }
  put stream sout unformatted "Отчет формируется только в Excel." skip.
  output stream sout close.

  run kfsalexl-init in this-procedure.

  for each tt-obj-list
  :
    run kfsalexl-write-cell-data in this-procedure ( input {&kfsalexl-h_date} , input tt-obj-list.shift-date-str ).
    run kfsalexl-write-cell-data in this-procedure ( input {&kfsalexl-h_obj}  , input tt-obj-list.obj-name       ).

    for each tt-gds
    , each tt-report
      where tt-report.obj-type = tt-obj-list.obj-type
        and tt-report.obj-code = tt-obj-list.obj-code
        and tt-report.gds-code = tt-gds.gds-code
    by tt-gds.id descending
    by tt-report.pump-code
    :
      run kfsalexl-sheet1-write-line-data in this-procedure
            ( input tt-report.gds-name
            , input tt-report.pump-code
            , input tt-report.end-state-el-cnt
            , input tt-report.begin-state-el-cnt
            , input tt-report.sale-state-el-cnt
            , input tt-report.end-state-mh-cnt
            , input tt-report.begin-state-mh-cnt
            , input tt-report.sale-state-mh-cnt
            , input tt-report.state-divergence
            , input tt-report.sale-state
            , input tt-report.sale-techfuel
            , input tt-report.sale-total
            ).
    end . /* for each buf_tt-report */
  end. /* for each tt-obj-list */

  run kfsalexl-close in this-procedure.
  os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .
  os-rename
    value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
    value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
  .

  define variable v-user-action   as character no-undo .
  define variable v-printed       as logical   no-undo .
  define variable ReportFontNum   as integer   no-undo .
  run gbl/prnfilen.w
      (input  ""
      ,input  20
      ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
      ,input  ReportFontNum
      ,output v-user-action
      ,output v-printed
      ) .
  os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .

end.

end procedure. /* print-no-schedule */


/* ========================================================================= */
procedure print-schedule :
  define output parameter p-error-message as character no-undo .

  define buffer buf_temp-param for temp-param .

  define variable v-filename              as character    no-undo .
  define variable v-obj-dir               as character    no-undo .
  define variable v-report-filename       as character    no-undo .
  define variable v-home-dir-filename     as character    no-undo .
  define variable v-error-num             as integer      no-undo .
  define variable v-template-file-name    as character    no-undo .
  define variable v-vb-file-name          as character    no-undo .
  define variable v-data-header-filename  as character    no-undo .
  define variable v-data-filename         as character    no-undo .
  define variable v-excel-file-name       as character    no-undo .
  define variable v-obj-errors            as character    no-undo .
  define variable v-err-message           as character    no-undo .
  define variable v-os-err-str            as character    no-undo .

do for buf_temp-param
on error undo, return error return-value
:
  assign
    v-report-dir  = trim( replace( p-report-dir, '/' , '\' ) , '\' )
  .
  _obj-cycle:
  for each tt-obj-list
    where tt-obj-list.cre-report = yes
  by tt-obj-list.obj-type
  by tt-obj-list.obj-code
  :
    assign
      v-message = substitute( "Сохранение отчета по объекту &1" , tt-obj-list.obj-name )
    .

    run waitfram-show in this-procedure ( input v-message ) .
    run write-log in this-procedure (input v-message) .
    run paramls-clear in this-procedure .
    run kfsalexl-init in this-procedure.
    run kfsalexl-write-cell-data in this-procedure ( input {&kfsalexl-h_date} , input tt-obj-list.shift-date-str ).
    run kfsalexl-write-cell-data in this-procedure ( input {&kfsalexl-h_obj}  , input tt-obj-list.obj-name       ).

    for each tt-gds
    , each tt-report
      where tt-report.obj-type = tt-obj-list.obj-type
        and tt-report.obj-code = tt-obj-list.obj-code
        and tt-report.gds-code = tt-gds.gds-code
    by tt-gds.id descending
    by tt-report.pump-code
    :
      run kfsalexl-sheet1-write-line-data in this-procedure
            ( input tt-report.gds-name
            , input tt-report.pump-code
            , input tt-report.end-state-el-cnt
            , input tt-report.begin-state-el-cnt
            , input tt-report.sale-state-el-cnt
            , input tt-report.end-state-mh-cnt
            , input tt-report.begin-state-mh-cnt
            , input tt-report.sale-state-mh-cnt
            , input tt-report.state-divergence
            , input tt-report.sale-state
            , input tt-report.sale-techfuel
            , input tt-report.sale-total
            ).
    end . /* for each buf_tt-report */
    run kfsalexl-close in this-procedure.
    assign
      v-filename          = string( session:temp-directory ) + {&DF_Name} + string( g#report-num )
      v-obj-dir           = v-report-dir + '/' + tt-obj-list.obj-name
      v-excel-file-name   = string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".xls"
      v-home-dir-filename = v-obj-dir +  "/" + tt-obj-list.report-name + ".xls"
    .

    os-rename
      value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
      value( v-filename + ".txl" )
    .
    assign
      v-filename = search( v-filename + ".txl" )
    .
    if v-filename = "" or v-filename = ?
    then do:
      assign
        v-obj-errors  = v-obj-errors  + substitute( "Не найден файл &1 для формирования Excel-файла по объекту &2 &3&4&4"
                                                  , string( session:temp-directory ) + {&DF_Name} + string( g#report-num )
                                                  , tt-obj-list.obj-type
                                                  , tt-obj-list.obj-code
                                                  , {&new-line}
                                                  )
        v-err-message = v-err-message + v-obj-errors
      .
      next _obj-cycle.
    end.

    input stream in-stream from value( v-filename ).
    import stream in-stream v-template-file-name   no-error .
    import stream in-stream v-vb-file-name         no-error .
    import stream in-stream v-data-header-filename no-error .
    import stream in-stream v-data-filename        no-error .
    input stream in-stream close.
    if search( v-template-file-name ) = ?
    then do:
      assign
        v-obj-errors  = v-obj-errors  + substitute( "Не найден шаблон Excel для вывода данных.&2Указан файл шаблона:&1&2&2"
                                                  , v-template-file-name
                                                  , {&new-line}
                                                  )
        v-err-message = v-err-message + v-obj-errors
      .
    end.
    if search( v-vb-file-name ) = ?
    then do:
      assign
        v-obj-errors  = v-obj-errors  + substitute( "Не найден текст программы заполнения шаблона Excel.&3Файл шаблона:&1&3Указан файл программы:&2&3&3"
                                                  , v-template-file-name
                                                  , v-vb-file-name
                                                  , {&new-line}
                                                  )
        v-err-message = v-err-message + v-obj-errors
      .
    end.
    if v-data-header-filename <> "":U
    and search( v-data-header-filename ) = ?
    then do:
      assign
        v-obj-errors  = v-obj-errors  + substitute( "Не найден файл шапки.&3Файл шаблона:&1&3Указан файл шапки:&2&3&3"
                                                  , v-template-file-name
                                                  , v-data-header-filename
                                                  , {&new-line}
                                                  )
        v-err-message = v-err-message + v-obj-errors
      .
    end.
    if v-data-filename <> "":U
    and search( v-data-filename )   = ?
    then do:
      assign
        v-obj-errors  = v-obj-errors  + substitute( "Не найден файл строк данных.&3Файл шаблона:&1&3Указан файл строк данных:&2&3&3"
                                                  , v-template-file-name
                                                  , v-data-filename
                                                  , {&new-line}
                                                  )
        v-err-message = v-err-message + v-obj-errors
      .
    end.

    create buf_temp-param.
    assign
      v-template-file-name = search( v-template-file-name )
      file-info :file-name = v-template-file-name
      v-template-file-name = file-info :full-pathname
      v-vb-file-name       = search( v-vb-file-name )
      file-info :file-name = v-vb-file-name
      v-vb-file-name       = file-info :full-pathname
    .

    if v-template-file-name = ? or v-template-file-name = "":U
    then do:
      next _obj-cycle.
    end.
    run paramls-write in this-procedure ( input {&paramls-template}
                                        , input {&paramls-template-file-name}
                                        , input v-template-file-name
                                        ).
    run paramls-write in this-procedure ( input {&paramls-template}
                                        , input {&paramls-vb-file-name}
                                        , input v-vb-file-name
                                        ).
    run paramls-write in this-procedure ( input {&paramls-data}
                                        , input {&paramls-data-header-filename}
                                        , input v-data-header-filename
                                        ).
    run paramls-write in this-procedure ( input {&paramls-data}
                                        , input {&paramls-data-filename}
                                        , input v-data-filename
                                        ).
    run paramls-write in this-procedure ( input {&paramls-saveas}
                                        , input {&paramls-excel-file-name}
                                        , input v-excel-file-name
                                        ).
    run paramls-write in this-procedure ( input {&paramls-file}
                                        , input {&paramls-file-no-open}
                                        , input "yes":U
                                        ).

    run gbl/macroxlt.p ( input-output table buf_temp-param ) no-error.
    if error-status :error
    then do:
      assign
        v-obj-errors  = v-obj-errors  + substitute( "&1&2&3&4Ошибка создания файла Excel.&4&5&4&6&4&7&4&8&4&4"
                                                  , vss-workfile
                                                  , vss-revision
                                                  , vss-description
                                                  , {&new-line}
                                                  , return-value
                                                  , trim(error-status :get-message(1))
                                                  , trim(error-status :get-message(2))
                                                  , trim(error-status :get-message(3))
                                                  )
        v-err-message = v-err-message + v-obj-errors
      .
    end.

    run gbl/del-file.p ( input v-filename ) no-error .
    if error-status :error
    then do:
      assign
        v-obj-errors  = v-obj-errors  + substitute( "Ошибка удаления файла &1: &2 &3&3"
                                                  , v-filename
                                                  , return-value
                                                  , {&new-line}
                                                  )
        v-err-message = v-err-message + v-obj-errors
      .
    end.

    run gbl/dir-cre.p ( input v-obj-dir ) no-error  .
    if error-status :error
    then do:
      assign
        v-obj-errors  = v-obj-errors  + substitute( "Ошибка создания директории &1: &2&4&3&4&4"
                                                  , v-filename
                                                  , return-value
                                                  , trim(error-status :get-message(1))
                                                  , {&new-line}
                                                  )
        v-err-message = v-err-message + v-obj-errors
      .
    end.

    run gbl/del-file.p ( input v-home-dir-filename ) no-error .
    if error-status :error
    then do:
      assign
        v-obj-errors  = v-obj-errors  + substitute( "Ошибка удаления файла &1: &2 &3&3"
                                                  , v-home-dir-filename
                                                  , return-value
                                                  , {&new-line}
                                                  )
        v-err-message = v-err-message + v-obj-errors
      .
    end.

    run gbl/ren-file.p ( input v-excel-file-name
                   , input v-home-dir-filename
                   ) no-error .
    if error-status :error
    then do:
      assign
        v-obj-errors  = v-obj-errors  + substitute( "Ошибка перемещения файла &1 -> &2: &3&4&4"
                                                  , v-excel-file-name
                                                  , v-home-dir-filename
                                                  , return-value
                                                  , {&new-line}
                                                  )
        v-err-message = v-err-message + v-obj-errors
      .
    end.
    run write-log in this-procedure ( input v-obj-errors ) .
    assign
      v-obj-errors = ''
    .

  end. /* for each tt-obj-list */
  run waitfram-hide in this-procedure .
  assign
    p-error-message = v-err-message
  .
end.

end procedure. /* print-schedule */


/* ========================================================================= */
procedure print-debug-tt-report :

do
on error undo, return error return-value
:


output stream sout to "c:\rep.txt".
for each tt-obj-list
:
  run kfsalexl-write-cell-data in this-procedure ( input {&kfsalexl-h_date} , input tt-obj-list.shift-date-str ).
  run kfsalexl-write-cell-data in this-procedure ( input {&kfsalexl-h_obj}  , input tt-obj-list.obj-name       ).

  for each tt-report
    where tt-report.obj-type = tt-obj-list.obj-type
      and tt-report.obj-code = tt-obj-list.obj-code
  :
    display stream sout
      sym1
      tt-report.gds-name
      sym2
      tt-report.pump-code
      sym3
      tt-report.end-state-el-cnt
      sym4
      tt-report.begin-state-el-cnt
      sym5
      tt-report.sale-state-el-cnt
      sym6
      tt-report.end-state-mh-cnt
      sym7
      tt-report.begin-state-mh-cnt
      sym8
      tt-report.sale-state-mh-cnt
      sym9
      tt-report.state-divergence
      sym10
      tt-report.sale-state
      sym11
      tt-report.sale-techfuel
      sym12
      tt-report.sale-total
      sym13
    with frame f-doc.
    down stream sout with frame f-doc.
    run kfsalexl-sheet1-write-line-data in this-procedure
          ( input tt-report.gds-name
          , input tt-report.pump-code
          , input tt-report.end-state-el-cnt
          , input tt-report.begin-state-el-cnt
          , input tt-report.sale-state-el-cnt
          , input tt-report.end-state-mh-cnt
          , input tt-report.begin-state-mh-cnt
          , input tt-report.sale-state-mh-cnt
          , input tt-report.state-divergence
          , input tt-report.sale-state
          , input tt-report.sale-techfuel
          , input tt-report.sale-total
          ).
  end . /* for each buf_tt-report */
end. /* for each tt-obj-list */
output stream sout close.
end.

end procedure. /* print-debug-tt-report */


/* ========================================================================= */
procedure clear-tt :

do
on error undo, return error return-value
:
  empty temp-table tt-report.
  empty temp-table tt-obj-list.
  empty temp-table tt-gds.
end.

end procedure. /* clear-tt */


/* ========================================================================= */
procedure fill-tt :
do
on error undo, return error return-value
:
  run fill-tt-obj-list in this-procedure .
  run fill-tt-gds in this-procedure .
  run fill-tt-report in this-procedure .
end.

end procedure. /* fill-tt */


/* ========================================================================= */
procedure fill-tt-obj-list :
  define buffer buf_clients     for ub.clients.
  define buffer buf_db          for ub.db.
  define buffer buf_tt-obj-list for tt-obj-list.

  define variable v-cur-db-num  as integer   no-undo .

do for buf_clients
     , buf_tt-obj-list
on error undo, return error return-value
:
  if p-is-schedule = no
  then do:
    { gbl/getcntxt.i get }
    find first buf_clients no-lock
      where buf_clients.obj-type = v-cntxt-obj-type
        and buf_clients.obj-code = v-cntxt-obj-code
    no-error .
    if not available buf_clients
    then do:
      message
        "Не найден текущий объект" skip
      view-as alert-box information.
      undo, return error.
    end.
    create buf_tt-obj-list .
    assign
      buf_tt-obj-list.obj-type = buf_clients.obj-type
      buf_tt-obj-list.obj-code = buf_clients.obj-code
      buf_tt-obj-list.obj-name = buf_clients.obj-name
    .
  end.
  else do:
    assign
      v-cur-db-num = p-db-num
    .
    _cli-cycle:
    for each buf_clients no-lock
      where buf_clients.obj-type = {&shop}
        and buf_clients.stts = 0
    :
      /* для удаленки только объекты удаленки */
      if v-cur-db-num <> 0 and buf_clients.db-num <> v-cur-db-num
      then do:
        run write-log in this-procedure ( input substitute( 'Объект &1 &2 - "&3" УБД &4 текущая БД &5.':u
                                                          , buf_clients.obj-type
                                                          , buf_clients.obj-code
                                                          , buf_clients.obj-name
                                                          , buf_clients.db-num
                                                          , v-cur-db-num
                                                          )
                                        ) .
        next _cli-cycle.
      end.
      /* проверяем что с объекта ходят чеки */
      find first buf_db no-lock
        where buf_db.db-num = buf_clients.db-num
      no-error .
      if buf_db.send-check = no
      then do:
        run write-log in this-procedure ( input substitute( 'Чеки с объекта &1 &2 - "&3" БД &4 не отсылаются. Объект исключен из списка.':u
                                                          , buf_clients.obj-type
                                                          , buf_clients.obj-code
                                                          , buf_clients.obj-name
                                                          , buf_clients.db-num
                                                          )
                                        ) .
        next _cli-cycle.
      end.
      find first buf_tt-obj-list
        where buf_tt-obj-list.obj-type = buf_clients.obj-type
          and buf_tt-obj-list.obj-code = buf_clients.obj-code
      no-error.
      if not available buf_tt-obj-list
      then do:
        create buf_tt-obj-list .
        assign
          buf_tt-obj-list.obj-type = buf_clients.obj-type
          buf_tt-obj-list.obj-code = buf_clients.obj-code
          buf_tt-obj-list.obj-name = buf_clients.obj-name
        .
      end. /* if not available buf_tt-obj-list */
    end. /* for each buf_clients no-lock  */
  end. /* if p-is-schedule = yes */
end.

end procedure. /* fill-tt-obj-list */


/* ========================================================================= */
procedure fill-tt-gds :

  define buffer buf_prod-bc   for ub.prod-bc.
  define buffer buf_bar-code  for ub.bar-code.
  define buffer buf_goods     for ub.goods.
  define buffer buf_tt-gds    for tt-gds.

  define variable v-sort-list as character no-undo .
  define variable v-sort-type as character no-undo .
  define variable v-i         as integer   no-undo .
  define variable v-str       as character no-undo .
  define variable v-is-petrol as logical   no-undo .
  define variable v-is-pieces as logical   no-undo .
  
  define variable v-param-type as character no-undo .
  define variable v-value-date as date no-undo .
  define variable v-value-decimal as decimal no-undo .
  define variable v-value-integer as INTEGER no-undo .
  define variable v-value-logical AS LOGICAL no-undo .
  define variable v-tth as handle no-undo .

do for buf_prod-bc
     , buf_bar-code
     , buf_goods
     , buf_tt-gds
on error undo, return error return-value
:
  
  run adm/shattri.p (
      input "get":U
      ,input '' /*p-obj-type*/
      ,input 0 /*p-obj-code*/
      ,input {&attr-report-glob}
      ,input {&attr-report-glob_rep-sort} /*p-param-code*/
      ,output v-sort-list
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
                    ) no-error.
                    
  if error-status:error or v-sort-list = "":U
  then do:
    undo , return error "Параметр rep-sort не найден, либо не заполнен.":U .
  end.

  _rep-sort-cycle:
  do v-i = 1 to num-entries(v-sort-list)
  :
    assign
      v-str = entry( v-i , v-sort-list)
    .
    _gds-cycle:
    for each buf_goods no-lock
      where buf_goods.artic = v-str
    :
      { str/is-petrl.i
              buf_goods.artic
              buf_goods.prod-type
              buf_goods.prod-code
              v-is-petrol
              v-is-pieces
      }
      if v-is-petrol  = yes
      and v-is-pieces = no
      then do:
        find first buf_tt-gds
          where buf_tt-gds.gds-code = buf_goods.gds-code
        no-error .
        if not available buf_tt-gds
        then do:
          /* для топлива по идее код один */
          find first buf_bar-code no-lock where buf_bar-code.gds-code = buf_goods.gds-code no-error .
          create buf_tt-gds.
          buffer-copy buf_goods to buf_tt-gds
          assign
            buf_tt-gds.id     = v-i
            buf_tt-gds.b-code = buf_bar-code.b-code
          .
          next _rep-sort-cycle.
        end.

      end.
    end. /* _gds-cycle: */
  end.
end.
end procedure. /* fill-tt-gds-list */


/* ========================================================================= */
procedure fill-tt-report :
  define buffer buf_tt-obj-list             for tt-obj-list.
  define buffer buf_tt-gds                  for tt-gds.
  define buffer buf_tt-report               for tt-report.
  define buffer buf_shift-obj_previous      for ub.shift-obj.
  define buffer buf_shift-obj_begin         for ub.shift-obj.
  define buffer buf_shift-obj_end           for ub.shift-obj.
  define buffer buf_rvs-doc                 for ub.rvs-doc.
  define buffer buf_rvs-doc_previous        for ub.rvs-doc.
  define buffer buf_rvs-doc_begin           for ub.rvs-doc.
  define buffer buf_rvs-doc_end             for ub.rvs-doc.
  define buffer buf_rvs-line-pump_previous  for ub.rvs-line-pump.
  define buffer buf_rvs-line-pump_begin     for ub.rvs-line-pump.
  define buffer buf_rvs-line-pump_end       for ub.rvs-line-pump.
  define buffer buf_chk-doc                 for ub.chk-doc.
  define buffer buf_chk-gds                 for ub.chk-gds.


  define variable v-date                    as date      no-undo .
  define variable v-time                    as integer   no-undo .
  define variable v-begin-date              as date      no-undo .
  define variable v-end-date                as date      no-undo .
  define variable v-prev-state-measure-qnty as decimal   no-undo .
  define variable v-prev-shift-exist        as logical   no-undo .
  define variable v-varshift-name-begin     as character no-undo .
  define variable v-varshift-name-end       as character no-undo .
  define variable v-varshift-name-num-begin as character no-undo .
  define variable v-varshift-name-num-end   as character no-undo .
  define variable v-rcpt-tech-refuell       as integer   no-undo .
  define variable v-pump                    as integer   no-undo .
  define variable v-qnty                    as decimal   no-undo .


do for buf_tt-obj-list
     , buf_tt-gds
     , buf_tt-report
     , buf_shift-obj_begin
     , buf_shift-obj_end
     , buf_rvs-doc
     , buf_shift-obj_previous
     , buf_rvs-doc_begin
     , buf_rvs-doc_end
     , buf_rvs-doc_previous
     , buf_rvs-line-pump_previous
     , buf_rvs-line-pump_begin
     , buf_rvs-line-pump_end
     , buf_chk-doc
     , buf_chk-gds
on error undo, return error return-value
:
  /* дата начала и конца отчета */
  assign
/*    v-begin-date = date ( month(v-date) , 1 , year(v-date) )*/
/*    v-end-date   = v-date*/
    v-rcpt-tech-refuell = integer({&rcpt-tech-refuell})
  .
  _obj-list:
  for each buf_tt-obj-list
  :
    if p-is-schedule = yes
    then do:
    /* диапазон - все смены за вчера */
      find first buf_shift-obj_begin no-lock
        where buf_shift-obj_begin.obj-type    = buf_tt-obj-list.obj-type
          and buf_shift-obj_begin.obj-code    = buf_tt-obj-list.obj-code
          and buf_shift-obj_begin.shift-date  = v-yesterday
          and buf_shift-obj_begin.status_     = {&sht-closed}
      use-index pi /* чтобы точно бралась первая смена за дату */
      no-error .
      if not available buf_shift-obj_begin then do:
        run proc-message in this-procedure ( input substitute( "По объекту &1 &2 не найдена первая закрытая смена на дату &3"
                                                             , buf_tt-obj-list.obj-type
                                                             , buf_tt-obj-list.obj-code
                                                             , string(v-yesterday,"99/99/9999")
                                                             )
                                           ) .
        next _obj-list.
      end.

      find last buf_shift-obj_end no-lock
        where buf_shift-obj_end.obj-type    = buf_tt-obj-list.obj-type
          and buf_shift-obj_end.obj-code    = buf_tt-obj-list.obj-code
          and buf_shift-obj_end.shift-date  = v-yesterday
          and buf_shift-obj_end.status_     = {&sht-closed}
      use-index pi /* чтобы точно бралась последняя смена за дату */
      no-error .
      if not available buf_shift-obj_end then do:
        run proc-message in this-procedure ( input substitute( "По объекту &1 &2 не найдена последняя закрытая смена на дату &3"
                                                             , buf_tt-obj-list.obj-type
                                                             , buf_tt-obj-list.obj-code
                                                             , string(v-yesterday,"99/99/9999")
                                                             )
                                           ) .
        next _obj-list.
      end.

      assign
        v-message = substitute( "Расчет отчета 'Реализация топлива' за прошедшие сутки по объекту &1 "
                              , buf_tt-obj-list.obj-name
                              )
      .
    end.
    else do:
      find first buf_shift-obj_begin no-lock
        where buf_shift-obj_begin.obj-type    = buf_tt-obj-list.obj-type
          and buf_shift-obj_begin.obj-code    = buf_tt-obj-list.obj-code
          and buf_shift-obj_begin.shift-date  = p-date-begin
          and buf_shift-obj_begin.shift-num   = p-shift-begin
          and buf_shift-obj_begin.status_     = {&sht-closed}
      no-error .
      if not available buf_shift-obj_begin then do:
        undo, return error substitute( "Не найдена смена начала отчета.&1Дата:&2"
                                    , {&new-line}
                                    , string( p-date-begin, "99/99/9999":U )
                                    ).
      end.

      find last buf_shift-obj_end no-lock
        where buf_shift-obj_end.obj-type    = buf_tt-obj-list.obj-type
          and buf_shift-obj_end.obj-code    = buf_tt-obj-list.obj-code
          and buf_shift-obj_end.shift-date  = p-date-end
          and buf_shift-obj_end.shift-num   = p-shift-end
          and buf_shift-obj_end.status_     = {&sht-closed}
      no-error .
      if not available buf_shift-obj_end then do:
        undo, return error substitute( "Не найдена смена конца отчета.&1Дата:&2"
                                    , {&new-line}
                                    , string( p-date-end, "99/99/9999":U )
                                    ).
      end.
      assign
        v-message = substitute( "Расчет по сменам с &1 &2 по &3 &4"
                              , string( p-date-begin , "99/99/9999")
                              , p-shift-begin
                              , string( p-date-end , "99/99/9999" )
                              , p-shift-end
                              )
      .
    end.

    /* находим последнюю смену до начала отчета */
    find last buf_shift-obj_previous no-lock
      where buf_shift-obj_previous.obj-type = buf_tt-obj-list.obj-type
        and buf_shift-obj_previous.obj-code = buf_tt-obj-list.obj-code
        and ((    buf_shift-obj_previous.shift-date = buf_shift-obj_begin.shift-date
              and buf_shift-obj_previous.shift-num  < buf_shift-obj_begin.shift-num
             )
             or buf_shift-obj_previous.shift-date < buf_shift-obj_begin.shift-date
            )
    use-index pi no-error.

    if available buf_shift-obj_previous
    then do:
      find first buf_rvs-doc_previous no-lock
        where buf_rvs-doc_previous.obj-type   = buf_tt-obj-list.obj-type
          and buf_rvs-doc_previous.obj-code   = buf_tt-obj-list.obj-code
          and buf_rvs-doc_previous.shift-date = buf_shift-obj_previous.shift-date
          and buf_rvs-doc_previous.shift-num  = buf_shift-obj_previous.shift-num
          and buf_rvs-doc_previous.status_    = {&fact}
          and buf_rvs-doc_previous.rvs-type   = {&rvs-shift}
      no-error.
      if not available buf_rvs-doc_previous
      then do:
        assign
          v-prev-shift-exist = no
        .
      end.
      else do:
        assign
          v-prev-shift-exist = yes
        .
      end.
    end.
    else do:
      assign
        v-prev-shift-exist = no
      .
    end.

    run waitfram-show in this-procedure ( input v-message ) .
    { str/shiftnam.i
      buf_shift-obj_begin.obj-type
      buf_shift-obj_begin.obj-code
      buf_shift-obj_begin.shift-date
      buf_shift-obj_begin.shift-num
      v-varshift-name-begin
      v-varshift-name-num-begin
      no-error
    }
    { str/shiftnam.i
      buf_shift-obj_end.obj-type
      buf_shift-obj_end.obj-code
      buf_shift-obj_end.shift-date
      buf_shift-obj_end.shift-num
      v-varshift-name-end
      v-varshift-name-num-end
      no-error
    }
    assign
      buf_tt-obj-list.shift-date-str  = substitute( "Смены с: &1 от &2 &3 по: &4 от &5 &6 закрыта &7 &8"
                                                  , string( v-varshift-name-begin                         )
                                                  , string( buf_shift-obj_begin.open-date , "99/99/9999"  )
                                                  , string( buf_shift-obj_begin.open-time , "hh:mm"       )
                                                  , string( v-varshift-name-end                           )
                                                  , string( buf_shift-obj_end.open-date , "99/99/9999"    )
                                                  , string( buf_shift-obj_end.open-time , "hh:mm"         )
                                                  , string( buf_shift-obj_end.close-date,"99/99/9999"     )
                                                  , string( buf_shift-obj_end.close-time,"hh:mm"          )
                                                  )

      buf_tt-obj-list.report-name     = substitute( "Реализация&1_&2_&3-&4-&5"
                                                  , string(year(v-yesterday)  , "9999")
                                                  , string(month(v-yesterday) , "99"  )
                                                  , string(day(v-yesterday)   , "99"  )
                                                  , v-varshift-name-num-begin
                                                  , v-varshift-name-end
                                                  )
      buf_tt-obj-list.cre-report      = yes
    .

    find first buf_rvs-doc_end no-lock
      where buf_rvs-doc_end.obj-type   = buf_tt-obj-list.obj-type
        and buf_rvs-doc_end.obj-code   = buf_tt-obj-list.obj-code
        and buf_rvs-doc_end.shift-date = buf_shift-obj_end.shift-date
        and buf_rvs-doc_end.shift-num  = buf_shift-obj_end.shift-num
        and buf_rvs-doc_end.status_    = {&fact}
        and buf_rvs-doc_end.rvs-type   = {&rvs-shift}
    no-error.
    if not available buf_rvs-doc_end
    then do:
      run proc-message in this-procedure ( input substitute( "Для объекта &1 &2 не найдена сменная сверка для смены &3 &4"
                                                           , buf_tt-obj-list.obj-type
                                                           , buf_tt-obj-list.obj-code
                                                           , buf_shift-obj_end.shift-date
                                                           , buf_shift-obj_end.shift-num
                                                           )
                                         ) .
      next _obj-list.
    end.

    if v-prev-shift-exist = yes
    then do:
      for each buf_rvs-line-pump_previous no-lock
        where buf_rvs-line-pump_previous.rvs-code = buf_rvs-doc_previous.rvs-code
      , first buf_tt-gds
          where buf_tt-gds.gds-code = buf_rvs-line-pump_previous.gds-code
      :
        find first buf_tt-report
          where buf_tt-report.obj-type  = buf_rvs-line-pump_previous.obj-type
            and buf_tt-report.obj-code  = buf_rvs-line-pump_previous.obj-code
            and buf_tt-report.gds-code  = buf_rvs-line-pump_previous.gds-code
            and buf_tt-report.pump-code = buf_rvs-line-pump_previous.pump-code
        no-error .
        if not available buf_tt-report
        then do:
          create buf_tt-report.
          assign
            buf_tt-report.obj-type  = buf_rvs-line-pump_previous.obj-type
            buf_tt-report.obj-code  = buf_rvs-line-pump_previous.obj-code
            buf_tt-report.gds-code  = buf_rvs-line-pump_previous.gds-code
            buf_tt-report.pump-code = buf_rvs-line-pump_previous.pump-code
            buf_tt-report.gds-name  = buf_tt-gds.gds-name
          .
        end.
        assign
          buf_tt-report.begin-state-el-cnt = buf_tt-report.begin-state-el-cnt + buf_rvs-line-pump_previous.state-el-cnt
          buf_tt-report.begin-state-mh-cnt = buf_tt-report.begin-state-mh-cnt + buf_rvs-line-pump_previous.state-mh-cnt
        .
      end.
    end.
    else do:
    /* предыдущей сменной сверки нет, используем первую  */
      find first buf_rvs-doc_begin no-lock
        where buf_rvs-doc_begin.obj-type   = buf_tt-obj-list.obj-type
          and buf_rvs-doc_begin.obj-code   = buf_tt-obj-list.obj-code
          and buf_rvs-doc_begin.shift-date = buf_shift-obj_begin.shift-date
          and buf_rvs-doc_begin.shift-num  = buf_shift-obj_begin.shift-num
          and buf_rvs-doc_begin.status_    = {&fact}
          and buf_rvs-doc_begin.rvs-type   = {&rvs-shift}
      no-error.
      if not available buf_rvs-doc_begin
      then do:
        run proc-message in this-procedure ( input substitute( "Для объекта &1 &2 не найдена сменная сверка для смены &3 &4"
                                                            , buf_tt-obj-list.obj-type
                                                            , buf_tt-obj-list.obj-code
                                                            , buf_shift-obj_begin.shift-date
                                                            , buf_shift-obj_begin.shift-num
                                                            )
                                          ) .
        next _obj-list.
      end.
      for each buf_rvs-line-pump_begin no-lock
        where buf_rvs-line-pump_begin.rvs-code = buf_rvs-doc_begin.rvs-code
      , first buf_tt-gds
          where buf_tt-gds.gds-code = buf_rvs-line-pump_begin.gds-code
      :
        find first buf_tt-report
          where buf_tt-report.obj-type  = buf_rvs-line-pump_begin.obj-type
            and buf_tt-report.obj-code  = buf_rvs-line-pump_begin.obj-code
            and buf_tt-report.gds-code  = buf_rvs-line-pump_begin.gds-code
            and buf_tt-report.pump-code = buf_rvs-line-pump_begin.pump-code
        no-error .
        if not available buf_tt-report
        then do:
          create buf_tt-report.
          assign
            buf_tt-report.obj-type        = buf_rvs-line-pump_begin.obj-type
            buf_tt-report.obj-code        = buf_rvs-line-pump_begin.obj-code
            buf_tt-report.gds-code        = buf_rvs-line-pump_begin.gds-code
            buf_tt-report.pump-code       = buf_rvs-line-pump_begin.pump-code
            buf_tt-report.gds-name        = buf_tt-gds.gds-name
          .
        end.
        assign
          buf_tt-report.begin-state-el-cnt = buf_tt-report.begin-state-el-cnt + buf_rvs-line-pump_begin.state-el-cnt
          buf_tt-report.begin-state-mh-cnt = buf_tt-report.begin-state-mh-cnt + buf_rvs-line-pump_begin.state-mh-cnt
        .
      end.
    end.

    for each buf_rvs-line-pump_end no-lock
      where buf_rvs-line-pump_end.rvs-code = buf_rvs-doc_end.rvs-code
    , first buf_tt-gds
        where buf_tt-gds.gds-code = buf_rvs-line-pump_end.gds-code
    :
      find first buf_tt-report
        where buf_tt-report.obj-type  = buf_rvs-line-pump_end.obj-type
          and buf_tt-report.obj-code  = buf_rvs-line-pump_end.obj-code
          and buf_tt-report.gds-code  = buf_rvs-line-pump_end.gds-code
          and buf_tt-report.pump-code = buf_rvs-line-pump_end.pump-code
      no-error .
      if not available buf_tt-report
      then do:
        create buf_tt-report.
        assign
          buf_tt-report.obj-type  = buf_rvs-line-pump_end.obj-type
          buf_tt-report.obj-code  = buf_rvs-line-pump_end.obj-code
          buf_tt-report.gds-code  = buf_rvs-line-pump_end.gds-code
          buf_tt-report.pump-code = buf_rvs-line-pump_end.pump-code
          buf_tt-report.gds-name  = buf_tt-gds.gds-name
        .
      end.
      assign
        buf_tt-report.end-state-el-cnt = buf_tt-report.end-state-el-cnt + buf_rvs-line-pump_end.state-el-cnt
        buf_tt-report.end-state-mh-cnt = buf_tt-report.end-state-mh-cnt + buf_rvs-line-pump_end.state-mh-cnt
      .
    end.

    /* собираем техпролив */
    _chk-doc-cycle:
    for each buf_chk-doc no-lock
      where buf_chk-doc.obj-type    = buf_tt-obj-list.obj-type
        and buf_chk-doc.obj-code    = buf_tt-obj-list.obj-code
        and buf_chk-doc.shift-date >= buf_shift-obj_begin.shift-date
        and buf_chk-doc.shift-date <= buf_shift-obj_end.shift-date

    :
      if buf_chk-doc.shift-date = buf_shift-obj_begin.shift-date and
         buf_chk-doc.shift-num < buf_shift-obj_begin.shift-num
      then do:
        next _chk-doc-cycle.
      end.
      if buf_chk-doc.shift-date = buf_shift-obj_end.shift-date and
         buf_chk-doc.shift-num > buf_shift-obj_end.shift-num
      then do:
        next _chk-doc-cycle.
      end.
      if buf_chk-doc.chk-type <> v-rcpt-tech-refuell
      then do:
        next _chk-doc-cycle.
      end.

      _chk-gds-cycle:
      for each buf_chk-gds no-lock
        where buf_chk-gds.doc-code = buf_chk-doc.doc-code
      , first buf_tt-gds no-lock
          where buf_tt-gds.b-code = buf_chk-gds.b-code
      :
        assign
          v-pump = buf_chk-gds.pump
          v-qnty = buf_chk-gds.doc-qnty
        .
        find first buf_tt-report
          where buf_tt-report.obj-type  = buf_tt-obj-list.obj-type
            and buf_tt-report.obj-code  = buf_tt-obj-list.obj-code
            and buf_tt-report.gds-code  = buf_tt-gds.gds-code
            and buf_tt-report.pump-code = v-pump
        no-error .
        if not available buf_tt-report
        then do:
          create buf_tt-report.
          assign
            buf_tt-report.obj-type  = buf_tt-obj-list.obj-type
            buf_tt-report.obj-code  = buf_tt-obj-list.obj-code
            buf_tt-report.gds-code  = buf_tt-gds.gds-code
            buf_tt-report.pump-code = v-pump
            buf_tt-report.gds-name  = buf_tt-gds.gds-name
          .
        end.
        assign
          buf_tt-report.sale-techfuel = buf_tt-report.sale-techfuel + v-qnty
        .
      end. /* _chk-gds-cycle: */

    end. /* _chk-doc-cycle */
  end. /* _obj-list: */
  run waitfram-hide in this-procedure .

  for each buf_tt-report
  :
    assign
      buf_tt-report.sale-state-el-cnt = buf_tt-report.end-state-el-cnt  - buf_tt-report.begin-state-el-cnt
      buf_tt-report.sale-state-mh-cnt = buf_tt-report.end-state-mh-cnt  - buf_tt-report.begin-state-mh-cnt
      buf_tt-report.state-divergence  = buf_tt-report.sale-state-mh-cnt - buf_tt-report.sale-state-el-cnt
      buf_tt-report.sale-state        = buf_tt-report.sale-state-mh-cnt
      buf_tt-report.sale-total        = buf_tt-report.sale-state
    .
  end.

end.
end procedure. /* fill-tt-report */

/* ========================================================================= */
procedure write-log :
  define input  parameter p-str as character no-undo .
do
on error undo, return error return-value
:
  if p-str = ''
  then do:
    return . /* --->>>--- */
  end.
  if p-is-schedule = yes
  then do:
    if parparentproc :get-signature("write-to-log") <> "":u
    then do:
      run write-to-log in parparentproc ( input p-str ) .
    end.
    /* в файл */
    assign
      p-str = substitute("&1 &2&3", cur-time-string-sec() , p-str, {&new-line})
      p-str = replace(p-str, ({&new-line} + {&carriage-return}), {&new-line} )
      p-str = replace(p-str, ({&carriage-return} + {&new-line}), {&new-line} )
      p-str = replace(p-str, {&new-line}, ({&carriage-return} + {&new-line}) )
    .
    run gbl/fileapnd.p
      ( input "r-kfsale.log"
       ,input p-str
       ,input 10 /* время ожинания освобождения файла */
      ) no-error .
    if error-status:error then do:
      return error return-value .
    end.
  end.
end.

end procedure. /* write-log */

/* ========================================================================= */
/*
процедура вывода сообщений
для автоматического режима вывод сообщений идет в лог
*/
procedure proc-message :
  define input  parameter p-message as character no-undo .
do
on error undo, return error return-value
:
  if p-is-schedule = yes
  then do:
    run write-log in this-procedure ( input p-message ) .
  end.
  else do:
    message
      p-message
    view-as alert-box information.
  end.
end.

end procedure. /* proc-message */