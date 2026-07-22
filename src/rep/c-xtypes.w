/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Выбор типов документов для товарного отчета (реестра документов) по поставщикам в продажных ценах

Автор: Булгаков Андрей Николаевич
Дата создания: 07/24/06
Author: Andrew Bulgakoff
Creation date: 07/24/06

*/

define input parameter p-filter as character no-undo .

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Выбор типов документов для товарного отчета (реестра документов) по поставщикам в продажных ценах":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/r-page1.i  }
{ gbl/getcntxt.i def }

define variable parparentproc as widget-handle no-undo .

assign
  parparentproc = my-handle
.
{ gbl/getcntxt.i get }



&scop FRAME-NAME fr-D-xdt
&scop toggle     view-as toggle-box size-chars 40.00 by 1.00

define variable jndex as integer no-undo initial 0 .
define variable jj    as integer no-undo initial 0 .

define button   Btn_Cancel label "&Отмена"     size-chars 12.00 by 1.00 auto-end-key .
define button b-help       label "Помо&щь"     size-chars 12.00 by 1.00 .
define button {&Btn_Mark}  label "Отметить &*" size-chars 12.00 by 1.00 tooltip "Выбрать все типы документов" .
define button {&Btn_Save}  label "&Сохранить"  size-chars 12.00 by 1.00 auto-go .
define button   Btn_UnMark label "Сн&ять *"    size-chars 12.00 by 1.00 tooltip "Снять все отметки" .

define variable l-ie as logical no-undo initial yes label "Приход внешний"                      {&toggle} .
define variable l-ep as logical no-undo initial yes label "Возврат поставщику"                  {&toggle} .
define variable l-if as logical no-undo initial yes label "Приход межфирменный"                 {&toggle} .
define variable l-vf as logical no-undo initial yes label "Возврат поставщику между фирмами"    {&toggle} .
define variable l-iv as logical no-undo initial yes label "Приход внутренний"                   {&toggle} .
define variable l-em as logical no-undo initial yes label "Возврат внутренний"                  {&toggle} .
define variable l-we as logical no-undo initial yes label "Списание"                            {&toggle} .
define variable l-wm as logical no-undo initial yes label "Списание в производство"             {&toggle} .
define variable l-ef as logical no-undo initial yes label "Расход межфирменный"                 {&toggle} .
define variable l-rf as logical no-undo initial yes label "Возврат от покупателя между фирмами" {&toggle} .
define variable l-ev as logical no-undo initial yes label "Расход внутренний"                   {&toggle} .
define variable l-vt as logical no-undo initial yes label "Инвентаризация"                      {&toggle} .
define variable l-vp as logical no-undo initial yes label "Пересортица"                         {&toggle} .
define variable l-ot as logical no-undo initial yes label "Переоценка"                          {&toggle} .
define variable l-ee as logical no-undo initial yes label "Расход внешний"                      {&toggle} .
define variable l-re as logical no-undo initial yes label "Возврат от покупателя"               {&toggle} .
define variable l-es as logical no-undo initial yes label "Расход через ККМ"                    {&toggle} .
define variable l-rs as logical no-undo initial yes label "Возврат от покупателя через ККМ"     {&toggle} .

define rectangle r-rect-1 edge-pixels 3 graphic-edge no-fill size-chars 98.25 by 1.50 .

define frame {&FRAME-NAME}
  r-rect-1      at row  1.25 col  1.50
    Btn_Cancel  at row  1.50 col  2.50
  {&Btn_Save}   at row  1.50 col 14.50
  {&Btn_Mark}   at row  1.50 col 26.50
    Btn_UnMark  at row  1.50 col 38.50
  b-help   at row  1.50 col 86.75
  l-ie          at row  3.00 col  2.50
  l-ep          at row  4.25 col  2.50
  l-if          at row  3.00 col 52.50
  l-vf          at row  4.25 col 52.50
  l-iv          at row  5.50 col  2.50
  l-em          at row  6.75 col  2.50
  l-we          at row  8.00 col  2.50
  l-wm          at row  9.25 col  2.50
  l-ef          at row  5.50 col 52.50
  l-rf          at row  6.75 col 52.50
  l-ev          at row 10.50 col  2.50
  l-vt          at row 11.75 col  2.50
  l-vp          at row 13.00 col  2.50
  l-ot          at row 14.25 col  2.50 skip( 0.75 )
  "Реализация:" at row  9.25 col 52.50 fgcolor 4
  l-ee          at row 10.50 col 52.50
  l-re          at row 11.75 col 52.50
  l-es          at row 13.00 col 52.50
  l-rs          at row 14.25 col 52.50
with view-as dialog-box keep-tab-order side-labels no-underline three-d scrollable
     title "Выбор типов документов для печати"
     default-button {&Btn_Save} cancel-button Btn_Cancel
.

assign
  Btn_UnMark :hidden in frame {&FRAME-NAME} = yes
.

on window-close of frame {&FRAME-NAME}
do:
  apply "END-ERROR":U to self .
end.

on choose of {&Btn_Mark} in frame {&FRAME-NAME} /* Отметить * */
do:
  assign
    l-ie = yes
    l-ep = yes
    l-if = yes
    l-vf = yes
    l-iv = yes
    l-em = yes
    l-we = yes
    l-wm = yes
    l-ef = yes
    l-rf = yes
    l-ev = yes
    l-vt = yes
    l-vp = yes
    l-ot = yes
    l-ee = yes
    l-re = yes
    l-es = yes
    l-rs = yes
  .
  display
    l-ie
    l-ep
    l-if
    l-vf
    l-iv
    l-em
    l-we
    l-wm
    l-ef
    l-rf
    l-ev
    l-vt
    l-vp
    l-ot
    l-ee
    l-re
    l-es
    l-rs
  with frame {&FRAME-NAME} .
end.

on choose of Btn_UnMark in frame {&FRAME-NAME} /* Снять * */
do:
  assign
    l-ie = no
    l-ep = no
    l-if = no
    l-vf = no
    l-iv = no
    l-em = no
    l-we = no
    l-wm = no
    l-ef = no
    l-rf = no
    l-ev = no
    l-vt = no
    l-vp = no
    l-ot = no
    l-ee = no
    l-re = no
    l-es = no
    l-rs = no
  .
  display
    l-ie
    l-ep
    l-if
    l-vf
    l-iv
    l-em
    l-we
    l-wm
    l-ef
    l-rf
    l-ev
    l-vt
    l-vp
    l-ot
    l-ee
    l-re
    l-es
    l-rs
  with frame {&FRAME-NAME} .
end.

on choose of {&Btn_Save} in frame {&FRAME-NAME} /* Сохранить */
do:
  define variable r-flt as recid     no-undo .
  define variable v-tog as character no-undo .
  define variable v-num as character no-undo .

  define buffer buf_usr-flt for ubflt.usr-flt .

  assign
    jndex = 0
  .
  run eq-frame in this-procedure .

  find first buf_usr-flt no-lock
    where buf_usr-flt.user-name  = v-cntxt-userid
      and buf_usr-flt.call-point = p-filter
    no-error .
  if available buf_usr-flt
  then do:
    assign
      v-tog = ( if num-entries( buf_usr-flt.list_, ";":U ) > 1 then entry( 2, buf_usr-flt.list_, ";":U ) else "":U )
      v-num = ( if num-entries( buf_usr-flt.list_, ";":U ) > 2 then entry( 3, buf_usr-flt.list_, ";":U ) else "":U )
    .
  end.
  else do:
    create buf_usr-flt .
    assign
      buf_usr-flt.user-name    = v-cntxt-userid
      buf_usr-flt.call-point   = p-filter
    .
    assign
      v-tog = "yes":U
      v-num = "2":U
    .
  end.
  assign
    r-flt = recid( buf_usr-flt )
  .
  find first buf_usr-flt exclusive-lock where
      recid( buf_usr-flt ) = r-flt .
  assign
    buf_usr-flt.list_ = "":U
  .
  do jj = 1 to 18
  :
    if use-column[ jj ] = yes
    then do:
      assign
        buf_usr-flt.list_ = buf_usr-flt.list_ + ( if buf_usr-flt.list_ = "":U then "":U else {&comma-char} ) +
                            string( jj )
        jndex             = jndex             + 1
      .
    end.
  end.
  assign
    buf_usr-flt.list_ = buf_usr-flt.list_ + ";":U + v-tog
                                          + ";":U + v-num
  .
  release buf_usr-flt no-error .
  if error-status :error
  then do:
    message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
            error-status :get-message(1) skip
            return-value skip
            "Ошибка  release"
    view-as alert-box error .
  end.
  if jndex = 0
  then do:
    message "Не выбран ни один тип документа." view-as alert-box error .
    return no-apply .
  end.
end.

{ gbl/hot-key.i {&Btn_Save} }
{ gbl/hot-key.i b-help }
{ gbl/hot-key.i {&Btn_Mark} }

if valid-handle( active-window ) and
   frame {&FRAME-NAME} :parent = ?
then do:
   frame {&FRAME-NAME} :parent = active-window .
end.

if current-window :window-state = window-minimized
then do:
   current-window :window-state = window-normal .
end.

/* ***************************  Main Block  *************************** */
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
{ gbl/app_help.i }
Main-Block:
do on error   undo Main-Block, leave Main-Block
   on end-key undo Main-Block, leave Main-Block
:
  run UI-On in this-procedure .

  wait-for go of frame {&FRAME-NAME} .
end. /* Main-Block */
hide frame {&FRAME-NAME} no-pause .

procedure UI-On :
  do jj = 1 to 18
  :
    if use-column[ jj ] = yes
    then do:
      assign
        jndex = jndex + 1
      .
    end.
  end.
  if jndex = 0
  then do:
    apply "CHOOSE":U to {&Btn_Mark} in frame {&FRAME-NAME} .
  end.
  else do:
    assign
      l-ie = use-column[  1 ]
      l-ep = use-column[  2 ]
      l-if = use-column[  3 ]
      l-vf = use-column[  4 ]
      l-iv = use-column[  5 ]
      l-em = use-column[  6 ]
      l-we = use-column[  7 ]
      l-wm = use-column[  8 ]
      l-ef = use-column[  9 ]
      l-rf = use-column[ 10 ]
      l-ev = use-column[ 11 ]
      l-vt = use-column[ 12 ]
      l-vp = use-column[ 13 ]
      l-ot = use-column[ 14 ]
      l-ee = use-column[ 15 ]
      l-re = use-column[ 16 ]
      l-es = use-column[ 17 ]
      l-rs = use-column[ 18 ]
    .
  end.
  display
    l-ie
    l-ep
    l-if
    l-vf
    l-iv
    l-em
    l-we
    l-wm
    l-ef
    l-rf
    l-ev
    l-vt
    l-vp
    l-ot
    l-ee
    l-re
    l-es
    l-rs
  with frame {&FRAME-NAME} .
  enable
    l-ie
    l-ep
    l-if
    l-vf
    l-iv
    l-em
    l-we
    l-wm
    l-ef
    l-rf
    l-ev
    l-vt
    l-vp
    l-ot
    l-ee
    l-re
    l-es
    l-rs
      Btn_Cancel
    {&Btn_Save}
    {&Btn_Mark}
      Btn_UnMark
    b-help
  with frame {&FRAME-NAME} .
end procedure. /* UI-On */

procedure eq-frame :
  assign frame {&FRAME-NAME}
    l-ie
    l-ep
    l-if
    l-vf
    l-iv
    l-em
    l-we
    l-wm
    l-ef
    l-rf
    l-ev
    l-vt
    l-vp
    l-ot
    l-ee
    l-re
    l-es
    l-rs
  .
  assign
    use-column[  1 ] = l-ie
    use-column[  2 ] = l-ep
    use-column[  3 ] = l-if
    use-column[  4 ] = l-vf
    use-column[  5 ] = l-iv
    use-column[  6 ] = l-em
    use-column[  7 ] = l-we
    use-column[  8 ] = l-wm
    use-column[  9 ] = l-ef
    use-column[ 10 ] = l-rf
    use-column[ 11 ] = l-ev
    use-column[ 12 ] = l-vt
    use-column[ 13 ] = l-vp
    use-column[ 14 ] = l-ot
    use-column[ 15 ] = l-ee
    use-column[ 16 ] = l-re
    use-column[ 17 ] = l-es
    use-column[ 18 ] = l-rs
  .
end procedure. /* eq-frame */