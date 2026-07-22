/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Товарный отчет (реестр документов) по поставщикам в продажных ценах (закладка № 2)

Автор: Булгаков Андрей Николаевич
Дата создания: 07/24/06
Author: Andrew Bulgakoff
Creation date: 07/24/06

*/

create widget-pool .

/* ********************  Preprocessor Definitions  ******************** */
&scop PROCEDURE-TYPE      SmartObject
&scop ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target
&scop FRAME-NAME          F-Main
&scop WINDOW-NAME         CURRENT-WINDOW
&scop ENABLED-OBJECTS     r-s-suppl SuppName Tog-Suppl r-s-bill# Btn_Columns
&scop DISPLAYED-OBJECTS   r-s-suppl SuppName Tog-Suppl r-s-bill# Tog-Excel

/* ***************************  Definitions  ************************** */
/* VSS Variable Definitions ---                                         */
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Товарный отчет (реестр документов) по поставщикам в продажных ценах (закладка № 2)":U.

/* Global, Shared, Preprocessor Definitions ---                         */
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

/* Local Variable Definitions ---                                       */
define variable State-Source as widget-handle no-undo .
define variable c-flt        as character     no-undo .

define new shared temp-table g#supplier no-undo
  field supp-type like ub.clients.obj-type
  field supp-code like ub.clients.obj-code
  field supp-name like ub.clients.obj-name

  index pi       is   unique primary supp-type supp-code
.

define buffer buf_usr-flt for ubflt.usr-flt .
define buffer bf_suppl    for ub.clients .

/* ***********************  Control Definitions  ********************** */
define button Btn_Columns label "Выбор типов документов" size-chars 28.75 by 1.00 tooltip "Выбор типов документов" .

define variable r-s-suppl as integer no-undo view-as radio-set vertical
  radio-buttons "все",       1,
                "Выборочно", 2  size-chars 12.00 by 2.17 .

define variable r-s-bill# as integer no-undo view-as radio-set vertical
  radio-buttons "Номер накладной поставщика", 1,
                "Номер накладной системы",    2  size-chars 30.00 by 2.17 .

define variable SuppName  as character no-undo view-as editor scrollbar-vertical size-chars 51.50 by 3.00
  tooltip "Список выбранных Поставщиков" initial {&all} .

define variable Tog-Suppl as logical   no-undo initial yes label "Раздельно по поставщикам"
  view-as toggle-box size-chars 38.25 by 1.00 .

define variable Tog-Excel  as logical   no-undo initial  no label "Только в Excel"
  view-as toggle-box size-chars 19.00 by 1.00 fgcolor 4 .

/* ************************  Frame Definitions  *********************** */
define frame {&FRAME-NAME}
  "Поставщики" at row  1.50 col  2.75 fgcolor 4
  SuppName     at row  2.50 col 15.50 no-label
  r-s-suppl    at row  2.50 col  2.75 no-label
  Tog-Suppl    at row  5.75 col  2.75
  "Накладные"  at row  7.25 col  2.75 fgcolor 4
  r-s-bill#    at row  8.25 col  2.75 no-label
  Btn_Columns  at row 17.50 col  3.00
  Tog-Excel    at row 17.50 col 51.38
with 1 down no-box keep-tab-order overlay side-labels no-underline three-d at col 1 row 1 scrollable .

/* ***************  Runtime Attributes and UIB Settings  ************** */
assign
  frame {&FRAME-NAME} :scrollable = no
  frame {&FRAME-NAME} :hidden     = yes
.
assign
  SuppName :read-only in frame {&FRAME-NAME} = yes
.

/* ************************* Included-Libraries *********************** */
{ src/adm/method/viewer.i }

/* ************************  Control Triggers  ************************ */
on choose of Btn_Columns in frame {&FRAME-NAME} /* Выбор колонок для печати */
do:
  define variable v-part-2 as character no-undo .
  define variable v-part-3 as character no-undo .

  find first buf_usr-flt no-lock
    where buf_usr-flt.user-name  = v-cntxt-userid
      and buf_usr-flt.call-point = c-flt
    no-error .
  if available buf_usr-flt
  then do:
    assign
      v-part-2 = ( if num-entries( buf_usr-flt.list_, ";":U ) > 1 then entry( 2, buf_usr-flt.list_, ";":U ) else "":U )
      v-part-3 = ( if num-entries( buf_usr-flt.list_, ";":U ) > 2 then entry( 3, buf_usr-flt.list_, ";":U ) else "":U )
    .
  end. /* if available buf_usr-flt */
  else do: /* if not available buf_usr-flt */
    assign
      v-part-2 = string( input frame {&FRAME-NAME} Tog-Suppl, "yes/no":U )
      v-part-3 = string( input frame {&FRAME-NAME} r-s-bill#, "9":U      )
    .
  end. /* if not available buf_usr-flt */
  run rep/c-xtypes.w
    ( input "r-gdsrsl":U
    ) .
  find first buf_usr-flt no-lock
    where buf_usr-flt.user-name  = v-cntxt-userid
      and buf_usr-flt.call-point = c-flt
    no-error .
  if available buf_usr-flt
  then do:
    find first buf_usr-flt exclusive-lock
      where buf_usr-flt.user-name  = v-cntxt-userid
        and buf_usr-flt.call-point = c-flt .
    assign
      buf_usr-flt.list_ = buf_usr-flt.list_ + ";":U + v-part-2
                                            + ";":U + v-part-3
    .
  end. /* if available buf_usr-flt */
end.

on value-changed of r-s-bill# in frame {&FRAME-NAME}
do:
  assign
    r-s-bill#
  .
end.

on value-changed of r-s-suppl in frame {&FRAME-NAME}
do:
  define variable post-grp_recids as character no-undo .
  define variable jj              as integer   no-undo .

  assign
    r-s-suppl
  .
  for each g#supplier
  :
    delete g#supplier .
  end.
  case r-s-suppl :
    when 1
    then do:
      assign
        SuppName = {&all}
      .
      display
        SuppName
      with frame {&FRAME-NAME} .
    end.
    when 2
    then do:
      run ref/cli-all.w
        (  input my-handle
        ,  input "{&Btn_Select},{&Btn_Mark}"
        ,  input {&all}
        ,  input {&all}
        ,  input {&current}
        ,  input ?
        ,  input ",,,,,,no,,"
        ,  input ?
        , output post-grp_recids
        ) .
      if post-grp_recids = "":U
      then do:
        assign
          SuppName  = {&all}
          r-s-suppl = 1
        .
        display
          SuppName
          r-s-suppl
        with frame {&FRAME-NAME} .
      end.
      else do:
        assign
          SuppName = "":U
        .
        do jj = 1 to num-entries( post-grp_recids )
        :
          find first bf_suppl no-lock where
              recid( bf_suppl ) = integer( entry( jj, post-grp_recids ) ) .
          create g#supplier .
          assign
            g#supplier.supp-type =            bf_suppl.obj-type
            g#supplier.supp-code =            bf_suppl.obj-code
            g#supplier.supp-name =            bf_suppl.obj-name
            SuppName             = SuppName + bf_suppl.obj-name + {&new-line}
          .
        end.
        display
          SuppName
        with frame {&FRAME-NAME} .
      end.
    end.
  end case. /* r-s-suppl */
end.

/* ***************************  Main Block  *************************** */
{ gbl/personly.i }

/* If testing in the UIB, initialize the SmartObject. */
&if defined( UIB_IS_RUNNING ) <> 0 &then
  run dispatch in this-procedure
    ( input 'initialize':U
    ) .
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
  define variable l-ind as integer no-undo .
  define variable jndex as integer no-undo .

  run dispatch in this-procedure
    ( input 'initialize':U
    ) .
  assign
    c-flt = "r-gdsrsl":U
  .
  do l-ind = 1 to 18
  :
    assign
      use-column[ l-ind ] = no
    .
  end.

  find first buf_usr-flt no-lock
    where buf_usr-flt.user-name  = v-cntxt-userid
      and buf_usr-flt.call-point = c-flt no-error .
  if not available buf_usr-flt
  then do:
    run rep/c-xtypes.w
      ( input "r-gdsrsl":U
      ) .
  end.
  find first buf_usr-flt no-lock where
             buf_usr-flt.user-name  = v-cntxt-userid and
             buf_usr-flt.call-point = c-flt no-error .
  if available buf_usr-flt
  then do:
    find first buf_usr-flt exclusive-lock where
               buf_usr-flt.user-name  = v-cntxt-userid and
               buf_usr-flt.call-point = c-flt .
    do l-ind = 1 to num-entries( entry( 1, buf_usr-flt.list_, ";":U ) )
    :
      assign
        jndex = integer( entry( l-ind, entry( 1, buf_usr-flt.list_, ";":U ) ) )
      no-error .
      if error-status :error
      then do:
        next .
      end.
      if jndex >=  1 and
         jndex <= 18
      then do:
        assign
          use-column[ jndex ] = yes
        .
      end.
    end. /* do */
  end. /* if available buf_usr-flt */
  else do: /* if not available buf_usr-flt */
    create buf_usr-flt .
    assign
      buf_usr-flt.user-name  = v-cntxt-userid
      buf_usr-flt.call-point = c-flt
    .
    do l-ind = 1 to 18
    :
      if use-column[ l-ind ] = yes
      then do:
        assign
          buf_usr-flt.list_ = buf_usr-flt.list_ + ( if buf_usr-flt.list_ = "":U then "":U else {&comma-char} ) +
                              string( l-ind )
        .
      end.
    end.
    assign
      buf_usr-flt.list_ = buf_usr-flt.list_ + ";yes;2"
    .
  end. /* if not available buf_usr-flt */
  assign
    Tog-Suppl = ( if num-entries( buf_usr-flt.list_, ";":U ) > 1
                  then logical( entry( 2, buf_usr-flt.list_, ";":U ), "yes/no":U )
                  else yes )
    r-s-bill# = ( if num-entries( buf_usr-flt.list_, ";":U ) > 2
                  then integer( entry( 3, buf_usr-flt.list_, ";":U ) )
                  else 1   )
  .

  apply "VALUE-CHANGED":U to r-s-suppl in frame {&FRAME-NAME} .

  display
    SuppName
    Tog-Suppl
    r-s-bill#
  with frame {&FRAME-NAME} .
end procedure. /* local-initialize */

procedure my-report :
  define variable l-ind as integer no-undo .

  do
  on error undo, leave
  on stop  undo, leave
  :
    if not available buf_usr-flt
    then do:
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
        do l-ind = 1 to 18
        :
          if use-column[ l-ind ] = yes
          then do:
            assign
              buf_usr-flt.list_ = buf_usr-flt.list_ + ( if buf_usr-flt.list_ = "":U then "":U else {&comma-char} ) +
                                  string( l-ind )
            .
          end.
        end.
        assign
          buf_usr-flt.list_ = buf_usr-flt.list_ + ";yes;2"
        .
      end. /* if not available buf_usr-flt */
    end. /* if not available buf_usr-flt */
    find first buf_usr-flt exclusive-lock where
               buf_usr-flt.user-name  = v-cntxt-userid and
               buf_usr-flt.call-point = c-flt .
    if num-entries( buf_usr-flt.list_, ";":U ) > 1
    then do:
      assign
        entry( 2, buf_usr-flt.list_, ";":U ) = string( Tog-Suppl, "yes/no":U )
      .
    end.
    else do:
      assign
        buf_usr-flt.list_ = buf_usr-flt.list_ + ";":U + "yes":U
      .
    end.
    if num-entries( buf_usr-flt.list_, ";":U ) > 2
    then do:
      assign
        entry( 3, buf_usr-flt.list_, ";":U ) = string( r-s-bill#, "9":U )
      .
    end.
    else do:
      assign
        buf_usr-flt.list_ = buf_usr-flt.list_ + ";":U + "2":U
      .
    end.

    find first obj-list no-lock .
    run rep/r-gdsrsl.p
      ( input my-handle
      , input obj-list.obj-type
      , input obj-list.obj-code
      , input Tog-Suppl
      , input r-s-bill#
      , input ( r-s-suppl = 1 )
      ) no-error .
    if error-status :error
    then do:
      message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
              "Ошибка выполнения отчета" skip( 0 )
              return-value skip( 0 )
              error-status :get-message( 1 ) skip( 1 )
      view-as alert-box error .
    end.
  end. /* do */
  if error-status :error
  then do:
    message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
            "Ошибка выполнения отчета" skip( 0 )
            return-value skip( 0 )
            error-status :get-message( 1 ) skip( 1 )
    view-as alert-box error .
  end.
end procedure. /* my-report */

procedure my-var :
  assign frame {&FRAME-NAME} SuppName
                             Tog-Excel
                             Tog-Suppl
                             r-s-suppl
                             r-s-bill#
  .
  /* строки в которых содержатся выбранные объекты */
  assign
    STR-obj-type = "":U
    STR-obj-code = "":U
    STR-obj-name = "":U
    STR-obj      = "":U
  .
  for each obj-list no-lock
  :
    assign
      STR-obj-type = STR-obj-type + obj-list.obj-type + ","
      STR-obj-code = STR-obj-code + string( obj-list.obj-code ) + ","
      STR-obj-name = STR-obj-name + obj-list.obj-name + ","
      STR-obj      = STR-obj      + obj-list.obj-type + "#" + string( obj-list.obj-code ) + ","
    .
  end. /* for each obj-list */
  assign
    ReportName   = "Товарный отчет (реестр документов) по поставщикам в продажных ценах"
    ReportHeader = "":U
  .
end procedure. /* my-var */

procedure state-changed :
  define input parameter p-issuer-hdl as handle    no-undo .
  define input parameter p-state      as character no-undo .

  case p-state : /* Object instance CASEs can go here to replace standard behavior or add new cases. */
    when "link-changed":U
    then do:
      run my-var in this-procedure .
    end.
  end case. /* p-state */
end procedure. /* state-changed */