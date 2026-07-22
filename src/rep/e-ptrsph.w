/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Запуск отчета почасовой статистики продаж ТРК с детализацией по пистолетам (закладка № 2)

Автор: Уханов Дмитрий Юрьевич
Дата создания: 07/24/06
Author: Dmitry Ukhanov
Creation date: 07/24/06

*/

create widget-pool .

/* ********************  Preprocessor Definitions  ******************** */
&scop PROCEDURE-TYPE      SmartObject
&scop ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target
&scop FRAME-NAME          F-Main
&scop WINDOW-NAME         CURRENT-WINDOW
&scop toggle              view-as toggle-box size-chars 40.00 by 1.00

/* ***************************  Definitions  ************************** */
/* VSS Variable Definitions ---                                         */
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Запуск отчета почасовой статистики продаж ТРК с детализацией по пистолетам (закладка № 2)":U.

/* Global, Shared, Preprocessor Definitions ---                         */
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ cmp/r-page1.i  }
{ gbl/getcntxt.i def }

&scop ENABLED-OBJECTS   {&Btn_Mark} Btn_UnMark {&Btn_Save} use-column[ 1 ] use-column[ 2 ] use-column[ 3 ] use-column[ 4 ] use-column[ 5 ] use-column[ 6 ] use-column[ 7 ] use-column[ 8 ] use-column[ 9 ] use-column[ 10 ] use-column[ 11 ] use-column[ 12 ] use-column[ 13 ] use-column[ 14 ] use-column[ 15 ]
&scop DISPLAYED-OBJECTS Tog-Excel use-column[ 1 ] use-column[ 2 ] use-column[ 3 ] use-column[ 4 ] use-column[ 5 ] use-column[ 6 ] use-column[ 7 ] use-column[ 8 ] use-column[ 9 ] use-column[ 10 ] use-column[ 11 ] use-column[ 12 ] use-column[ 13 ] use-column[ 14 ] use-column[ 15 ]

/* Local Variable Definitions ---                                       */
define variable State-Source as widget-handle no-undo .
define variable c-flt        as character     no-undo .
define variable jndex        as integer       no-undo .
define variable jj           as integer       no-undo .
define variable r-flt        as recid         no-undo .

define buffer buf_usr-flt for ubflt.usr-flt .

/* ***********************  Control Definitions  ********************** */
define button {&Btn_Mark}   label "Отметить &*" size-chars 12.00 by 1.00 tooltip "Выбрать все типы документов" .
define button {&Btn_Save}   label "&Сохранить"  size-chars 12.00 by 1.00 tooltip "Сохранить настройки" .
define button   Btn_UnMark  label "Сн&ять *"    size-chars 12.00 by 1.00 tooltip "Снять все отметки" .

define variable Tog-Excel as logical no-undo initial no label "Только в E&xcel" {&toggle} fgcolor 4 .

define rectangle r-rect-1 edge-pixels 3 graphic-edge no-fill size-chars 91.00 by 1.50 .

/* ************************  Frame Definitions  *********************** */
define frame {&FRAME-NAME}
  r-rect-1         at row  1.25 col  1.50
  {&Btn_Save}      at row  1.50 col  2.50
  {&Btn_Mark}      at row  1.50 col 26.50
    Btn_UnMark     at row  1.50 col 38.50
  use-column[  1 ] at row  3.00 col  2.50 label "&Дата продажи"        {&toggle}
  use-column[  2 ] at row  4.25 col  2.50 label "&Время продажи"       {&toggle}
  use-column[  3 ] at row  5.50 col  2.50 label "&Код товара"          {&toggle}
  use-column[  4 ] at row  6.75 col  2.50 label "&Артикул товара"      {&toggle}
  use-column[  5 ] at row  8.00 col  2.50 label "&Наименование товара" {&toggle}
  use-column[  6 ] at row  9.25 col  2.50 label "Номер &ТРК"           {&toggle}
  use-column[  7 ] at row 10.50 col  2.50 label "Номер &пистолета"     {&toggle}
  use-column[  8 ] at row  3.00 col 42.50 label "Количество &чеков"    {&toggle}
  use-column[  9 ] at row  4.25 col 42.50 label "Количество, &л"       {&toggle}
  use-column[ 10 ] at row  5.50 col 42.50 label "Сумма прода&ж"        {&toggle}
  use-column[ 11 ] at row  6.75 col 42.50 label "Вид &оплаты"          {&toggle}
  use-column[ 12 ] at row  8.00 col 42.50 label "Номер &чека"          {&toggle}
  use-column[ 13 ] at row  9.25 col 42.50 label "Сухой &чек"           {&toggle}
  use-column[ 14 ] at row 10.50 col 42.50 label "№ заказа"             {&toggle}
  use-column[ 15 ] at row 11.75 col  2.50 label "№ кассы"              {&toggle}
  Tog-Excel        at row 18.50 col 38.50
with 1 down no-box keep-tab-order overlay side-labels no-underline three-d at col 1 row 1 scrollable .

/* ***************  Runtime Attributes and UIB Settings  ************** */
assign
  frame {&FRAME-NAME} :scrollable = no
  frame {&FRAME-NAME} :hidden     = yes
.

/* ************************* Included-Libraries *********************** */
{ src/adm/method/viewer.i }

/* ************************  Control Triggers  ************************ */
on choose of {&Btn_Mark} in frame {&FRAME-NAME} /* Отметить * */
  do:
    assign
      use-column[  1 ] = yes
      use-column[  2 ] = yes
      use-column[  3 ] = yes
      use-column[  4 ] = yes
      use-column[  5 ] = yes
      use-column[  6 ] = yes
      use-column[  7 ] = yes
      use-column[  8 ] = yes
      use-column[  9 ] = yes
      use-column[ 10 ] = yes
      use-column[ 11 ] = yes
      use-column[ 12 ] = yes
      use-column[ 13 ] = yes
      use-column[ 14 ] = yes
      use-column[ 15 ] = yes
      .
    display
      use-column[  1 ]
      use-column[  2 ]
      use-column[  3 ]
      use-column[  4 ]
      use-column[  5 ]
      use-column[  6 ]
      use-column[  7 ]
      use-column[  8 ]
      use-column[  9 ]
      use-column[ 10 ]
      use-column[ 11 ]
      use-column[ 12 ]
      use-column[ 13 ]
      use-column[ 14 ]
      use-column[ 15 ]
      with frame {&FRAME-NAME} .
  end.

on choose of Btn_UnMark in frame {&FRAME-NAME} /* Снять * */
  do:
    assign
      use-column[  1 ] = no
      use-column[  2 ] = no
      use-column[  3 ] = no
      use-column[  4 ] = no
      use-column[  5 ] = no
      use-column[  6 ] = no
      use-column[  7 ] = no
      use-column[  8 ] = no
      use-column[  9 ] = no
      use-column[ 10 ] = no
      use-column[ 11 ] = no
      use-column[ 12 ] = no
      use-column[ 13 ] = no
      use-column[ 14 ] = no
      use-column[ 15 ] = no
      .
    display
      use-column[  1 ]
      use-column[  2 ]
      use-column[  3 ]
      use-column[  4 ]
      use-column[  5 ]
      use-column[  6 ]
      use-column[  7 ]
      use-column[  8 ]
      use-column[  9 ]
      use-column[ 10 ]
      use-column[ 11 ]
      use-column[ 12 ]
      use-column[ 13 ]
      use-column[ 14 ]
      use-column[ 15 ]
      with frame {&FRAME-NAME} .
  end.

on choose of {&Btn_Save} in frame {&FRAME-NAME} /* Сохранить */
do:
  assign
    jndex = 0
  .

  find first buf_usr-flt no-lock where
             buf_usr-flt.user-name  = v-cntxt-userid and
             buf_usr-flt.call-point = c-flt no-error .
  if not available buf_usr-flt
  then do:
    create buf_usr-flt .
    assign
      buf_usr-flt.user-name  = v-cntxt-userid
      buf_usr-flt.call-point = c-flt
    .
  end.
  assign
    r-flt = recid( buf_usr-flt )
  .
  find first buf_usr-flt exclusive-lock where
      recid( buf_usr-flt ) = r-flt .
    assign
      buf_usr-flt.list_ = '':U
      .
    do jj = 1 to 15
      :
      assign
        buf_usr-flt.list_ = buf_usr-flt.list_ + ( if use-column[ jj ] = yes then '+':U else '-':U )
        .
      if use-column[ jj ] = yes
        then 
      do:
        assign
          jndex = jndex + 1
          .
      end.
    end.
    release buf_usr-flt no-error .
    if error-status :error
      then 
    do:
      message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
        error-status :get-message(1) skip
        return-value skip
        'Ошибка  release'
        view-as alert-box error .
    end.
    if jndex = 0
      then 
    do:
      message 'Не выбрано ни одно поле для печати.' view-as alert-box error .
      return no-apply .
    end.
  end.

{ gbl/hot-key.i {&Btn_Save} }
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
{ gbl/personly.i }
{ gbl/getcntxt.i get " " my-handle }

/* If testing in the UIB, initialize the SmartObject. */
&if defined( UIB_IS_RUNNING ) <> 0 &then
  run local-initialize in this-procedure .
&endif

/* **********************  Internal Procedures  *********************** */
procedure disable_UI :
  hide frame {&FRAME-NAME} no-pause .
  if this-procedure :persistent
  then do:
    delete procedure this-procedure .
  end.
end procedure. /* disable_UI */

procedure local-initialize :
  run dispatch in this-procedure
    ( input 'initialize':U
    ) .
  /*хотя программа расчета уже новая запускается фильтр остаивм старый НЕ МЕНЯТЬ ЗНАЧЕНИЕ c-flt!!!!!*/
  assign
    c-flt = 'r-ptrsph':U
    jj    = 0
    .
  do jndex = 1 to 15
    :
    assign
      use-column[ jndex ] = no
    .
  end.

  find first buf_usr-flt no-lock where
             buf_usr-flt.user-name  = v-cntxt-userid and
             buf_usr-flt.call-point = c-flt no-error .
  if available buf_usr-flt
  then do:
    find first buf_usr-flt exclusive-lock where
               buf_usr-flt.user-name  = v-cntxt-userid and
               buf_usr-flt.call-point = c-flt .
    do jndex = 1 to length( buf_usr-flt.list_ )
    :
      if substring( buf_usr-flt.list_, jndex, 1 ) = '+':U
      then do:
        assign
          use-column[ jndex ] = yes
          jj                  = jj + 1
        .
      end.
    end. /* do */
    if length( buf_usr-flt.list_ ) < 15
      then 
    do:
      do jndex = length( buf_usr-flt.list_ ) + 1 to 15
        :
        assign
          use-column[ jndex ] = yes
          jj                  = jj + 1
        .
      end. /* do */
    end.
  end. /* if available buf_usr-flt */
  else 
  do: /* if not available buf_usr-flt */
    do jndex = 1 to 15
      :
      if use-column[ jndex ] = yes
      then do:
        assign
          jj = jj + 1
        .
      end.
    end.

    create buf_usr-flt .
    assign
      buf_usr-flt.user-name  = v-cntxt-userid
      buf_usr-flt.call-point = c-flt
      buf_usr-flt.list_      = '':U
      .
    do jndex = 1 to 15
      :
      assign
        buf_usr-flt.list_ = buf_usr-flt.list_ + ( if use-column[ jndex ] = yes then '+':U else '-':U )
      .
    end.
  end. /* if not available buf_usr-flt */
  if jj = 0
  then do:
    apply "CHOOSE":U to {&Btn_Mark} in frame {&FRAME-NAME} .
  end.
  display
    use-column[  1 ]
    use-column[  2 ]
    use-column[  3 ]
    use-column[  4 ]
    use-column[  5 ]
    use-column[  6 ]
    use-column[  7 ]
    use-column[  8 ]
    use-column[  9 ]
    use-column[ 10 ]
    use-column[ 11 ]
    use-column[ 12 ]
    use-column[ 13 ]
    use-column[ 14 ]    
    use-column[ 15 ]
    with frame {&FRAME-NAME} .
end procedure. /* local-initialize */

procedure my-report :
  define variable jndex as integer no-undo .

  do
  on error undo, leave
  on stop  undo, leave
  :
    apply "CHOOSE":U to {&Btn_Save} in frame {&FRAME-NAME} .
    if available buf_usr-flt
    then do:
      assign
        r-flt = recid( buf_usr-flt )
      .
    end.
    else do: /* if not available buf_usr-flt */
      find first buf_usr-flt no-lock where
                 buf_usr-flt.user-name  = v-cntxt-userid and
                 buf_usr-flt.call-point = c-flt no-error .
    end. /* if not available buf_usr-flt */
    if available buf_usr-flt
    then do:
      assign
        r-flt = recid( buf_usr-flt )
      .
    end.
    else do: /* if not available buf_usr-flt */
      create buf_usr-flt .
      assign
        buf_usr-flt.user-name  = v-cntxt-userid
        buf_usr-flt.call-point = c-flt
      .
      assign
        r-flt = recid( buf_usr-flt )
      .
    end. /* if not available buf_usr-flt */
    find first buf_usr-flt exclusive-lock where
        recid( buf_usr-flt ) = r-flt .
    assign
      buf_usr-flt.list_ = '':U
      .
    do jndex = 1 to 15
      :
      assign
        buf_usr-flt.list_ = buf_usr-flt.list_ + ( if use-column[ jndex ] = yes then '+':U else '-':U )
      .
    end.

    find first obj-list no-lock .
    run rep/r-ptrsp2.p
      ( input my-handle
      , input obj-list.obj-type
      , input obj-list.obj-code
      ) no-error .
    if error-status :error
    then do:
      message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
              'Ошибка выполнения отчета' skip( 0 )
              return-value skip( 0 )
              error-status :get-message( 1 ) skip( 1 )
      view-as alert-box error .
    end.
  end. /* do */
  if error-status :error
  then do:
    message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
            'Ошибка выполнения отчета' skip( 0 )
            return-value skip( 0 )
            error-status :get-message( 1 ) skip( 1 )
    view-as alert-box error .
  end.
end procedure. /* my-report */

procedure my-var :
  assign frame {&FRAME-NAME}
    Tog-Excel
    use-column[  1 ]
    use-column[  2 ]
    use-column[  3 ]
    use-column[  4 ]
    use-column[  5 ]
    use-column[  6 ]
    use-column[  7 ]
    use-column[  8 ]
    use-column[  9 ]
    use-column[ 10 ]
    use-column[ 11 ]
    use-column[ 12 ]
    use-column[ 13 ]
    use-column[ 14 ]    
    use-column[ 15 ]
    .
  /* строки в которых содержатся выбранные объекты */
  assign
    STR-obj-type = '':U
    STR-obj-code = '':U
    STR-obj-name = '':U
    STR-obj      = '':U
  .
  for each obj-list no-lock
  :
    assign
      STR-obj-type = STR-obj-type +         obj-list.obj-type   + {&comma-char}
      STR-obj-code = STR-obj-code + string( obj-list.obj-code ) + {&comma-char}
      STR-obj-name = STR-obj-name +         obj-list.obj-name   + {&comma-char}
      STR-obj      = STR-obj      +         obj-list.obj-type   + '#':U
                                  + string( obj-list.obj-code ) + {&comma-char}
    .
  end. /* for each obj-list */
  assign
    ReportName   = 'Почасовая статистика продаж ТРК с детализацией по пистолетам':U
    ReportHeader = '':U
  .
end procedure. /* my-var */

procedure state-changed :
  define input parameter p-issuer-hdl as handle    no-undo .
  define input parameter p-state      as character no-undo .

  case p-state : /* Object instance CASEs can go here to replace standard behavior or add new cases. */
    when 'link-changed':U
    then do:
      run my-var in this-procedure .
    end.
  end case. /* p-state */
end procedure. /* state-changed */