block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: alcdcl05.p $
$Archive: rep/alcdcl05.p $

Декларация о розничной продаже алкогольной продукции (Йошкар-Ола)

Автор: Хныкин Павел Андреевич
Дата создания: 03/17/08
Author: Pavel Khnykin
Creation date: 03/17/08

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: alcdcl05.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/alcdcl05.p $":U .
define variable vss-description as character no-undo init "Декларация о розничной продаже алкогольной продукции (Йошкар-Ола)".
{ cmp/vssrevis.i   }
{ cmp/str-glbl.i   }
{ cmp/library.i    }
{ cmp/r-pril.i new }
{ cmp/r-page1.i    }
{ gbl/waitfram.i   }
{ gbl/prn-lib.i    }
{ rep/r-sym.i      }
{ trg/factord.i    }
{ rep/ost-line.i   }
{ rep/lkp-font.i   }
{ gbl/clntattr.i   }
{ rep/fmtcli.i     }
{ gbl/paramls.i    }
define variable g#report-num  as integer    no-undo .
{ rep/alc05xl.i    }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get " " my-handle }
{ gbl/getsect.i def }

&scop reg-man 1
&scop rus-man 2
&scop imp-man 3
&scop lst-man "{&reg-man},{&rus-man},{&imp-man}":U
&scop lst-desc "Алкогольная продукция, произведенная в республике Марий Эл;Алкогольная продукция, произведенная в Российской федерации (за исключением алкогольной продукции, произведенной в Республике Марий Эл);Импортная алкогольная продукция"

define stream out-stream.

define temp-table tt-gds no-undo like ub.goods
  field alc-type-inner-code like ub.alc-type.alc-type-inner-code
  field create-user-db-num  like ub.alc-type.create-user-db-num
  field alc-type-code       like ub.alc-type.alc-type-code
  field alc-type-name       like ub.alc-type.alc-type-name
  field gds-man-type        as integer
index pi is primary unique
  gds-code
index alc-type
  alc-type-inner-code
  create-user-db-num
index alc-type-code
  alc-type-code
.

define temp-table tt-report no-undo
  field obj-type            like ub.clients.obj-type
  field obj-code            like ub.clients.obj-code
  field type                as integer
  field alc-type-code       like ub.alc-type.alc-type-code
  field alc-type-name       like ub.alc-type.alc-type-name
  field ost-begin-qnty      as decimal
  field ost-end-qnty        as decimal
  field pri-prod-qnty       as decimal
  field pri-opt-qnty        as decimal
  field pri-ret-qnty        as decimal
  field ras-sel-qnty        as decimal
  field ras-ret-qnty        as decimal
  field ras-spi-qnty        as decimal
  field ras-oth-qnty        as decimal
  field pri-tot-qnty        as decimal
  field ras-tot-qnty        as decimal
index pi is primary unique
  obj-type
  obj-code
  type
  alc-type-code
index oatc
  obj-type
  obj-code
  alc-type-code
index atc
  alc-type-code
.

define variable v-line                    as character  no-undo .
define variable v-par-val                 as character  no-undo .
define variable v-par-type                as character  no-undo .
define variable v-begin-date              as date       no-undo .
define variable v-end-date                as date       no-undo .
define variable v-host-code               like ub.clients.host-code  no-undo .
define variable v-host-code-2             like ub.clients.host-code  no-undo .
define variable v-alc-type-count          as integer   no-undo .
define variable v-str-npp                 as character no-undo .

do on error undo , return error return-value
:

  { gbl/working.i }
  { gbl/getsect.i run "''" 0 {&attr-report-glob} }
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'ardecldt' then v-par-val =  string(thbjattr_thbj-attr.property-value-date,"99/99/9999") .
  end.

  find first obj-list no-lock no-error .
  if not available obj-list then do:
    message
      "Нет ни одного объекта для формирования отчета!"
    view-as alert-box error.
    return error return-value.
  end.
  { gbl/hostcode.i obj-list.obj-type obj-list.obj-code v-host-code }
  for each obj-list :
    { gbl/hostcode.i obj-list.obj-type obj-list.obj-code v-host-code-2 }
    if v-host-code <> v-host-code-2 then do:
      message
        "Отчет формируется только по объектам одной фирмы."
      view-as alert-box error.
      return error return-value.
    end.
  end.
  run get-report-num in my-handle (output g#report-num).
  { cmp/open-out.i stream out-stream " " {&LS_PS_A4} }
  put stream out-stream " " skip.
  run alc05xl-init in this-procedure.
  run clear-all in this-procedure .

  assign
    v-begin-date  = date(v-par-val)
    v-end-date    = x-Date-Alone
    v-line        = fill( "-" , 300 )
  .
  run waitfram-show in this-procedure ( "Поиск товаров по справочнику видов алкогольной продукции...":U ) .
  run find-alc-goods in this-procedure .
  run waitfram-show in this-procedure ( "Формирование отчета...":U ) .
  run fill-tt-report in this-procedure .
  run waitfram-show in this-procedure ( "Вывод отчета...":U ) .
  run print-header in this-procedure .
  run print-body in this-procedure .
  run print-footer in this-procedure .

  output stream out-stream close.
  {&CloseExcel}
  run clear-all in this-procedure .
  { gbl/stopwork.i }
  run waitfram-hide in this-procedure .
  run alc05xl-close in this-procedure .

  os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .
  os-rename
    value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
    value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
  .

  define variable v-user-action   as character no-undo .
  define variable v-printed       as logical   no-undo .
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

/* ===================================================================================================== */
procedure clear-all :

do
on error undo, return error return-value
:
  empty temp-table tt-gds.
  empty temp-table tt-report.
end.

end procedure. /* clear-all */

/* ===================================================================================================== */
procedure find-alc-goods :

do
on error undo, return error return-value
:

  define buffer buf_alc-type      for ub.alc-type.
  define buffer buf_alc-type-gds  for ub.alc-type-gds.
  define buffer buf_goods         for ub.goods.

  define variable v-gds-type as integer   no-undo .

  /* заполняем список алкогольных товаров */
  empty temp-table tt-gds.
  for each buf_alc-type no-lock
        where buf_alc-type.alc-type-status = 0
  :
    _gds:
    for each buf_alc-type-gds no-lock
          where buf_alc-type-gds.alc-type-inner-code = buf_alc-type.alc-type-inner-code
            AND buf_alc-type-gds.create-user-db-num  = buf_alc-type.create-user-db-num
      , first buf_goods no-lock
          where buf_goods.gds-code = buf_alc-type-gds.gds-code
    :
      run get-gds-man in this-procedure ( input   buf_goods.prod-type
                                        , input   buf_goods.prod-code
                                        , output  v-gds-type
                                        ) no-error .
      if error-status :error then do:
        message
          "Ошибка при определение территориальной принадлежности товара." skip
          return-value skip
          error-status :get-message(1) skip
          substitute( "Товар &1 - '&2' не включен в результирующий отчет!" , buf_goods.artic , buf_goods.gds-name )
        view-as alert-box error.
        next _gds.
      end.
      if v-gds-type = -1
      then do:
        message
          substitute( 'У производителя &1 &2 товара артикул: &3 - "&4"&5 не установлен атрибут производитель алкогольной продукции.'
                    , buf_goods.prod-type
                    , buf_goods.prod-code
                    , buf_goods.artic
                    , buf_goods.gds-name
                    , {&new-line}
                    )
        view-as alert-box error.
        next _gds.
      end.

      find first tt-gds no-lock where tt-gds.gds-code = buf_goods.gds-code no-error .
      if not available tt-gds then do:
        create tt-gds.
        buffer-copy buf_goods to tt-gds
        assign
          tt-gds.alc-type-inner-code = buf_alc-type.alc-type-inner-code
          tt-gds.create-user-db-num  = buf_alc-type.create-user-db-num
          tt-gds.alc-type-code       = buf_alc-type.alc-type-code
          tt-gds.alc-type-name       = buf_alc-type.alc-type-name
          tt-gds.gds-man-type        = v-gds-type
          v-alc-type-count           = v-alc-type-count + 1
        .
      end.
    end.
  end.

end.

end procedure. /* find-alc-goods */

/* ===================================================================================================== */
procedure get-gds-man :
  define input  parameter p-prod-type like ub.goods.prod-type no-undo .
  define input  parameter p-prod-code like ub.goods.prod-code no-undo .
  define output parameter p-gds-man   as integer   no-undo .

  define buffer buf_clients for ub.clients.

  define variable v-cli-local-str             as character no-undo .
  define variable v-cli-alc-producer-str      as character no-undo .
  define variable v-cli-foreign-producer-str  as character no-undo .
  define variable v-cli-local                 as logical   no-undo .
  define variable v-cli-alc-producer          as logical   no-undo .
  define variable v-cli-foreign-producer      as logical   no-undo .
  define variable v-attr-type                 as character no-undo .
do
on error undo, return error return-value
:
  find first buf_clients no-lock
    where buf_clients.obj-type = p-prod-type
      and buf_clients.obj-code = p-prod-code
  no-error .
  if available buf_clients
  then do:
    run clntattr-value in this-procedure ( input p-prod-type
                                         , input p-prod-code
                                         , input {&attr-cli-local}
                                         , output v-cli-local-str
                                         , output v-attr-type
                                         ) .
    run clntattr-value in this-procedure ( input p-prod-type
                                         , input p-prod-code
                                         , input {&attr-foreign-producer}
                                         , output v-cli-foreign-producer-str
                                         , output v-attr-type
                                         ) .
    assign
      v-cli-local             = logical(v-cli-local-str           )
      v-cli-foreign-producer  = logical(v-cli-foreign-producer-str)
    .

    if v-cli-local = yes and v-cli-foreign-producer = yes
    then do:
      return error substitute( "Для контрагента &1 &2 одновременно установлены атрибуты местный и импортный производитель!"
                             , p-prod-type
                             , p-prod-code
                             ) .
    end.

    if v-cli-local = yes
    then do:
      assign
        p-gds-man = {&reg-man}
      .
      return . /* --->>>--- */
    end.
    if v-cli-foreign-producer = yes
    then do:
      assign
        p-gds-man = {&imp-man}
      .
      return . /* --->>>--- */
    end.
    assign
      p-gds-man = {&rus-man}
    .
    return . /* --->>>--- */
  end.
  else do:
    return error substitute("Не найден производитель &1 &2" , p-prod-type , p-prod-code ). /* --->>>--- */
  end.

end.

end procedure. /* get-gds-man */

/* ===================================================================================================== */
procedure print-header :

do
on error undo, return error return-value
:
  define variable v-str-obj   as character no-undo .
  define variable v-str-date  as character no-undo .
  define variable v-license   as character no-undo .
  define variable v-month-list as character no-undo extent 12 initial
    ["январь"
    ,"февраль"
    ,"март"
    ,"апрель"
    ,"май"
    ,"июнь"
    ,"июль"
    ,"август"
    ,"сентябрь"
    ,"октябрь"
    ,"ноябрь"
    ,"декабрь"
    ] .

  run fmtcli-get-client in this-procedure
            ( input  {&cmp}
            , input  v-host-code
            ) .
  run get-sertificate in this-procedure ( input {&cmp}
                                        , input v-host-code
                                        , input v-end-date
                                        , output v-license
                                        ) .
  assign
    v-str-obj = substitute( '"&1", &2, &3 ', v-fmtcli-name , v-fmtcli-full-addres , v-fmtcli-inn )
    v-str-date = substitute( 'за &1 &2 года * ' , v-month-list[month( v-begin-date )] , year(v-begin-date) )
  .

  run alc05xl-write-cell-data in this-procedure ( input {&alc05xl-h_month}, input v-str-date ).
  run alc05xl-write-cell-data in this-procedure ( input {&alc05xl-h_object}, input v-str-obj ).
  run alc05xl-write-cell-data in this-procedure ( input {&alc05xl-h_license}, input v-license ).
end.

end procedure. /* print-header */

/* ===================================================================================================== */
procedure print-body :

  define variable v-list-count    as integer   no-undo .
  define variable v-gds-man-type  as integer   no-undo .
  define variable v-i             as integer   no-undo .

do
on error undo, return error return-value
:
  define variable v-ost-begin-qnty  as decimal   no-undo .
  define variable v-ost-end-qnty    as decimal   no-undo .
  define variable v-pri-prod-qnty   as decimal   no-undo .
  define variable v-pri-opt-qnty    as decimal   no-undo .
  define variable v-pri-ret-qnty    as decimal   no-undo .
  define variable v-ras-sel-qnty    as decimal   no-undo .
  define variable v-ras-ret-qnty    as decimal   no-undo .
  define variable v-ras-spi-qnty    as decimal   no-undo .
  define variable v-ras-oth-qnty    as decimal   no-undo .
  define variable v-pri-tot-qnty    as decimal   no-undo .
  define variable v-ras-tot-qnty    as decimal   no-undo .
  define variable v-b-i             as integer   no-undo .
  define variable v-s-i             as integer   no-undo .

  assign
    v-b-i = 1
    v-s-i = 0
  .

  for each tt-report
  :
    assign
      v-ost-begin-qnty  = v-ost-begin-qnty + tt-report.ost-begin-qnty
      v-ost-end-qnty    = v-ost-end-qnty   + tt-report.ost-end-qnty
      v-pri-prod-qnty   = v-pri-prod-qnty  + tt-report.pri-prod-qnty
      v-pri-opt-qnty    = v-pri-opt-qnty   + tt-report.pri-opt-qnty
      v-pri-ret-qnty    = v-pri-ret-qnty   + tt-report.pri-ret-qnty
      v-ras-sel-qnty    = v-ras-sel-qnty   + tt-report.ras-sel-qnty
      v-ras-ret-qnty    = v-ras-ret-qnty   + tt-report.ras-ret-qnty
      v-ras-spi-qnty    = v-ras-spi-qnty   + tt-report.ras-spi-qnty
      v-ras-oth-qnty    = v-ras-oth-qnty   + tt-report.ras-oth-qnty
      v-pri-tot-qnty    = v-pri-tot-qnty   + tt-report.pri-tot-qnty
      v-ras-tot-qnty    = v-ras-tot-qnty   + tt-report.ras-tot-qnty
    .
  end. /* for each tt-report */

  run alc05xl-sheet1-write-line-data in this-procedure
        ( input substitute("&1." , v-b-i , v-s-i )
        , input "Алкогольная продукция всего в том числе:"
        , input string(v-ost-begin-qnty)
        , input string(v-pri-tot-qnty  )
        , input string(v-pri-prod-qnty )
        , input string(v-pri-opt-qnty  )
        , input string(v-pri-ret-qnty  )
        , input string(v-ras-tot-qnty  )
        , input string(v-ras-sel-qnty  )
        , input string(v-ras-ret-qnty  )
        , input string(v-ras-spi-qnty  )
        , input string(v-ras-oth-qnty  )
        , input string(v-ost-end-qnty  )
        ).

  assign
    v-ost-begin-qnty  = 0
    v-ost-end-qnty    = 0
    v-pri-prod-qnty   = 0
    v-pri-opt-qnty    = 0
    v-pri-ret-qnty    = 0
    v-ras-sel-qnty    = 0
    v-ras-ret-qnty    = 0
    v-ras-spi-qnty    = 0
    v-ras-oth-qnty    = 0
    v-pri-tot-qnty    = 0
    v-ras-tot-qnty    = 0
  .

  for each tt-report
    break by tt-report.alc-type-code
  :
    assign
      v-ost-begin-qnty  = v-ost-begin-qnty + tt-report.ost-begin-qnty
      v-ost-end-qnty    = v-ost-end-qnty   + tt-report.ost-end-qnty
      v-pri-prod-qnty   = v-pri-prod-qnty  + tt-report.pri-prod-qnty
      v-pri-opt-qnty    = v-pri-opt-qnty   + tt-report.pri-opt-qnty
      v-pri-ret-qnty    = v-pri-ret-qnty   + tt-report.pri-ret-qnty
      v-ras-sel-qnty    = v-ras-sel-qnty   + tt-report.ras-sel-qnty
      v-ras-ret-qnty    = v-ras-ret-qnty   + tt-report.ras-ret-qnty
      v-ras-spi-qnty    = v-ras-spi-qnty   + tt-report.ras-spi-qnty
      v-ras-oth-qnty    = v-ras-oth-qnty   + tt-report.ras-oth-qnty
      v-pri-tot-qnty    = v-pri-tot-qnty   + tt-report.pri-tot-qnty
      v-ras-tot-qnty    = v-ras-tot-qnty   + tt-report.ras-tot-qnty
    .
    if last-of(tt-report.alc-type-code)
    then do:
      assign
        v-s-i = v-s-i + 1
      .
      run alc05xl-sheet1-write-line-data in this-procedure
            ( input substitute("&1.&2" , v-b-i , v-s-i )
            , input tt-report.alc-type-name
            , input string(v-ost-begin-qnty)
            , input string(v-pri-tot-qnty  )
            , input string(v-pri-prod-qnty )
            , input string(v-pri-opt-qnty  )
            , input string(v-pri-ret-qnty  )
            , input string(v-ras-tot-qnty  )
            , input string(v-ras-sel-qnty  )
            , input string(v-ras-ret-qnty  )
            , input string(v-ras-spi-qnty  )
            , input string(v-ras-oth-qnty  )
            , input string(v-ost-end-qnty  )
            ).
      assign
        v-ost-begin-qnty  = 0
        v-ost-end-qnty    = 0
        v-pri-prod-qnty   = 0
        v-pri-opt-qnty    = 0
        v-pri-ret-qnty    = 0
        v-ras-sel-qnty    = 0
        v-ras-ret-qnty    = 0
        v-ras-spi-qnty    = 0
        v-ras-oth-qnty    = 0
        v-pri-tot-qnty    = 0
        v-ras-tot-qnty    = 0
      .
    end.
  end. /* for each tt-report */

  assign
    v-list-count = num-entries({&lst-man})
    v-ost-begin-qnty  = 0
    v-ost-end-qnty    = 0
    v-pri-prod-qnty   = 0
    v-pri-opt-qnty    = 0
    v-pri-ret-qnty    = 0
    v-ras-sel-qnty    = 0
    v-ras-ret-qnty    = 0
    v-ras-spi-qnty    = 0
    v-ras-oth-qnty    = 0
    v-pri-tot-qnty    = 0
    v-ras-tot-qnty    = 0
  .

  do v-i = 1 to v-list-count :
    assign
      v-gds-man-type = integer( entry( v-i , {&lst-man} ) )
      v-b-i = v-b-i + 1
      v-s-i = 0
    .
    for each tt-report
      where tt-report.type = v-gds-man-type
    :
      assign
        v-ost-begin-qnty  = v-ost-begin-qnty + tt-report.ost-begin-qnty
        v-ost-end-qnty    = v-ost-end-qnty   + tt-report.ost-end-qnty
        v-pri-prod-qnty   = v-pri-prod-qnty  + tt-report.pri-prod-qnty
        v-pri-opt-qnty    = v-pri-opt-qnty   + tt-report.pri-opt-qnty
        v-pri-ret-qnty    = v-pri-ret-qnty   + tt-report.pri-ret-qnty
        v-ras-sel-qnty    = v-ras-sel-qnty   + tt-report.ras-sel-qnty
        v-ras-ret-qnty    = v-ras-ret-qnty   + tt-report.ras-ret-qnty
        v-ras-spi-qnty    = v-ras-spi-qnty   + tt-report.ras-spi-qnty
        v-ras-oth-qnty    = v-ras-oth-qnty   + tt-report.ras-oth-qnty
        v-pri-tot-qnty    = v-pri-tot-qnty   + tt-report.pri-tot-qnty
        v-ras-tot-qnty    = v-ras-tot-qnty   + tt-report.ras-tot-qnty
      .
    end. /* for each tt-report  */
    run alc05xl-sheet1-write-line-data in this-procedure
          ( input substitute("&1." , v-b-i )
          , input substitute( "&1 в том числе " , entry( v-i , {&lst-desc} , ';') )
          , input string(v-ost-begin-qnty)
          , input string(v-pri-tot-qnty  )
          , input string(v-pri-prod-qnty )
          , input string(v-pri-opt-qnty  )
          , input string(v-pri-ret-qnty  )
          , input string(v-ras-tot-qnty  )
          , input string(v-ras-sel-qnty  )
          , input string(v-ras-ret-qnty  )
          , input string(v-ras-spi-qnty  )
          , input string(v-ras-oth-qnty  )
          , input string(v-ost-end-qnty  )
          ).

    assign
      v-ost-begin-qnty  = 0
      v-ost-end-qnty    = 0
      v-pri-prod-qnty   = 0
      v-pri-opt-qnty    = 0
      v-pri-ret-qnty    = 0
      v-ras-sel-qnty    = 0
      v-ras-ret-qnty    = 0
      v-ras-spi-qnty    = 0
      v-ras-oth-qnty    = 0
      v-pri-tot-qnty    = 0
      v-ras-tot-qnty    = 0
    .

    for each tt-report
      where tt-report.type = v-gds-man-type
      break by tt-report.alc-type-code
    :
      assign
        v-ost-begin-qnty  = v-ost-begin-qnty + tt-report.ost-begin-qnty
        v-ost-end-qnty    = v-ost-end-qnty   + tt-report.ost-end-qnty
        v-pri-prod-qnty   = v-pri-prod-qnty  + tt-report.pri-prod-qnty
        v-pri-opt-qnty    = v-pri-opt-qnty   + tt-report.pri-opt-qnty
        v-pri-ret-qnty    = v-pri-ret-qnty   + tt-report.pri-ret-qnty
        v-ras-sel-qnty    = v-ras-sel-qnty   + tt-report.ras-sel-qnty
        v-ras-ret-qnty    = v-ras-ret-qnty   + tt-report.ras-ret-qnty
        v-ras-spi-qnty    = v-ras-spi-qnty   + tt-report.ras-spi-qnty
        v-ras-oth-qnty    = v-ras-oth-qnty   + tt-report.ras-oth-qnty
        v-pri-tot-qnty    = v-pri-tot-qnty   + tt-report.pri-tot-qnty
        v-ras-tot-qnty    = v-ras-tot-qnty   + tt-report.ras-tot-qnty
      .

      if last-of(tt-report.alc-type-code)
      then do:
        assign
          v-s-i = v-s-i + 1
        .

        run alc05xl-sheet1-write-line-data in this-procedure
              ( input substitute("&1.&2" , v-b-i , v-s-i )
              , input tt-report.alc-type-name
              , input string(v-ost-begin-qnty)
              , input string(v-pri-tot-qnty  )
              , input string(v-pri-prod-qnty )
              , input string(v-pri-opt-qnty  )
              , input string(v-pri-ret-qnty  )
              , input string(v-ras-tot-qnty  )
              , input string(v-ras-sel-qnty  )
              , input string(v-ras-ret-qnty  )
              , input string(v-ras-spi-qnty  )
              , input string(v-ras-oth-qnty  )
              , input string(v-ost-end-qnty  )
              ).

        assign
          v-ost-begin-qnty  = 0
          v-ost-end-qnty    = 0
          v-pri-prod-qnty   = 0
          v-pri-opt-qnty    = 0
          v-pri-ret-qnty    = 0
          v-ras-sel-qnty    = 0
          v-ras-ret-qnty    = 0
          v-ras-spi-qnty    = 0
          v-ras-oth-qnty    = 0
          v-pri-tot-qnty    = 0
          v-ras-tot-qnty    = 0
        .

      end.
    end. /* for each tt-report */

  end. /* do v-i = 1 to v-list-count */


end.

end procedure. /* print-body */

/* ===================================================================================================== */
procedure print-footer :

do
on error undo, return error return-value
:

end.

end procedure. /* print-footer */

/* ===================================================================================================== */
procedure fill-tt-report :

  define buffer buf_alc-type    for ub.alc-type.
  define buffer buf_ot-line     for ub.ot-line.
  define buffer buf_trn-doc     for ub.trn-doc.
  define buffer sch_trn-doc     for ub.trn-doc.
  define buffer buf_parts       for ub.parts.
  define buffer buf_obj-list    for obj-list.

  define variable v-fact-order-1      like ub.ot-line.fact-order no-undo .
  define variable v-fact-order-2      like ub.ot-line.fact-order no-undo .
  define variable v-fo-1              like ub.ot-line.fact-order no-undo .
  define variable v-fo-2              like ub.ot-line.fact-order no-undo .


  define variable var-x-store-code    like ub.clients.obj-code    no-undo.
  define variable var-x-store-type    like ub.clients.obj-type    no-undo.
  define variable var-x-date-start    like ub.stk-tot.Fact-date   no-undo.
  define variable var-x-date-endt     like ub.stk-tot.Fact-date   no-undo.
  define variable var-x-sum-type      like ub.stk-tot.sum-type    no-undo.
  define variable var-x-ost-sum-type  like ub.stk-tot.sum-type    no-undo.
  define variable var-x-cat-id        like ub.stk-tot.cat-id      no-undo.
  define variable var-xTog-obj        as   logical             no-undo.

  define variable var-Quantity        like ub.stk-tot.fact-qnty   initial ? no-undo.
  define variable var-Coast_R         like ub.stk-tot.sum-rubl    no-undo.
  define variable var-Coast_V         like ub.stk-tot.sum-rubl    no-undo.
  define variable var-VAT_R           like ub.stk-tot.sum-rubl    no-undo.
  define variable var-VAT_V           like ub.stk-tot.sum-rubl    no-undo.
  define variable var-Fact-order      like ub.stk-tot.Fact-order  no-undo.

  define variable var-x-artic         like ub.stk-line.artic        no-undo.
  define variable var-x-prod-code     like ub.stk-line.prod-code    no-undo.
  define variable var-x-prod-type     like ub.stk-line.prod-type    no-undo.

  define variable var-SLT_R           like ub.stk-tot.sum-rubl    no-undo.
  define variable var-SLT_V           like ub.stk-tot.sum-rubl    no-undo.

  define variable v-gds-prod-type   like ub.goods.prod-type no-undo .
  define variable v-gds-prod-code   like ub.goods.prod-code no-undo .
  define variable v-ot-line-qnty    as decimal   no-undo .
  define variable v-parts-line-qnty as decimal   no-undo .


  define variable v-ost-begin-qnty  as decimal   no-undo .
  define variable v-ost-end-qnty    as decimal   no-undo .
  define variable v-pri-prod-qnty   as decimal   no-undo .
  define variable v-pri-opt-qnty    as decimal   no-undo .
  define variable v-pri-ret-qnty    as decimal   no-undo .
  define variable v-ras-sel-qnty    as decimal   no-undo .
  define variable v-ras-ret-qnty    as decimal   no-undo .
  define variable v-ras-spi-qnty    as decimal   no-undo .
  define variable v-ras-oth-qnty    as decimal   no-undo .

  define variable v-gds-type        as integer   no-undo .
  define variable v-i               as integer   no-undo .
  define variable v-income-doc-code as character no-undo .

do
on error undo, return error return-value
:
  run day-begin-fact-order in this-procedure ( input v-begin-date
                                             , output v-fact-order-1
                                             ) no-error .
  if error-status:error then do:
    message error-status :get-message(1) view-as alert-box error .
    return error.
  end.
  run factord-end-day in this-procedure ( input v-end-date
                                        , output v-fact-order-2
                                        ) no-error .
  if error-status:error then do:
    message error-status :get-message(1) view-as alert-box error .
    return error.
  end.

  assign
    var-x-sum-type      = {&arh-cost}
    var-x-ost-sum-type  = {&arh-cost}
  .
  for each buf_alc-type no-lock
        where buf_alc-type.alc-type-status = 0
  break by buf_alc-type.alc-type-code
  :
    /* остатки на начало */
    _gds-ost:
    for each tt-gds no-lock
      where tt-gds.alc-type-code = buf_alc-type.alc-type-code ,
        each obj-list no-lock
    :
      assign
        var-x-store-code  = obj-list.obj-code
        var-x-store-type  = obj-list.obj-type
        var-x-artic       = tt-gds.artic
        var-x-prod-code   = tt-gds.prod-code
        var-x-prod-type   = tt-gds.prod-type
        var-x-cat-id      = {&root-cat-id}
        var-xTog-obj      = yes
      .
      /* остаток на начало */
      RUN ost-line  (
          input   var-x-store-code,
          input   var-x-store-type,
          INPUT   var-x-artic     ,
          INPUT   var-x-prod-code ,
          INPUT   var-x-prod-type ,
          input   no              ,
          input   v-fact-order-1  ,
          input   var-x-ost-sum-type  ,
          input   var-x-cat-id    ,
          input   var-xTog-obj    ,
          output  var-Quantity    ,
          output  var-Coast_R     ,
          output  var-Coast_V     ,
          output  var-VAT_R       ,
          output  var-VAT_V       ,
          output  var-SLT_R       ,
          output  var-SLT_V       ).
      assign
        v-ost-begin-qnty = ( var-Quantity * tt-gds.ms-base )
      .
      /* остаток на конец */
      RUN ost-line  (
          input   var-x-store-code,
          input   var-x-store-type,
          INPUT   var-x-artic     ,
          INPUT   var-x-prod-code ,
          INPUT   var-x-prod-type ,
          input   no              ,
          input   v-fact-order-2  ,
          input   var-x-ost-sum-type  ,
          input   var-x-cat-id    ,
          input   var-xTog-obj    ,
          output  var-Quantity    ,
          output  var-Coast_R     ,
          output  var-Coast_V     ,
          output  var-VAT_R       ,
          output  var-VAT_V       ,
          output  var-SLT_R       ,
          output  var-SLT_V       ).
      assign
        v-ost-end-qnty = ( var-Quantity * tt-gds.ms-base )
      .
      find first tt-report
        where tt-report.obj-type       = obj-list.obj-type
          and tt-report.obj-code       = obj-list.obj-code
          and tt-report.type           = tt-gds.gds-man-type
          and tt-report.alc-type-code  = buf_alc-type.alc-type-code
      no-error .
      if not available tt-report then do:
        create tt-report.
        assign
          tt-report.obj-type       = obj-list.obj-type
          tt-report.obj-code       = obj-list.obj-code
          tt-report.type           = tt-gds.gds-man-type
          tt-report.alc-type-code  = buf_alc-type.alc-type-code
          tt-report.alc-type-name  = buf_alc-type.alc-type-name
        .
      end.
      assign
        tt-report.ost-begin-qnty = tt-report.ost-begin-qnty + v-ost-begin-qnty
        tt-report.ost-end-qnty   = tt-report.ost-end-qnty   + v-ost-end-qnty
      .
    end. /* for each tt-gds no-lock  */

    /* собираем документы */
    _obj-list:
    for each obj-list no-lock
    :
      _tt-gds:
      for each tt-gds no-lock
        where tt-gds.alc-type-inner-code = buf_alc-type.alc-type-inner-code
          and tt-gds.create-user-db-num  = buf_alc-type.create-user-db-num
      :
        _buf_ot-line:
        for each buf_ot-line no-lock
          where buf_ot-line.artic        = tt-gds.artic
            and buf_ot-line.prod-code    = tt-gds.prod-code
            and buf_ot-line.prod-type    = tt-gds.prod-type
            and buf_ot-line.fact-order   <= v-fact-order-2  /* fact-order конца периода */
            and buf_ot-line.fact-order   >= v-fact-order-1  /* fact-order начала периода */
            and buf_ot-line.obj-code     = obj-list.obj-code
            and buf_ot-line.obj-type     = obj-list.obj-type
            and buf_ot-line.sum-type     = var-x-sum-type
        :
          find first buf_trn-doc no-lock
            where buf_trn-doc.doc-code = buf_ot-line.doc-code
          no-error .
          if not available buf_trn-doc then do:
            message
              vss-workfile vss-revision vss-description skip
              substitute( "Не найден складской документ &1.&2Документ не будет учтен в отчете." , buf_ot-line.doc-code , {&new-line} )
            view-as alert-box error .
            next _buf_ot-line.
          end.
          assign
            v-ot-line-qnty  = abs( buf_ot-line.fact-qnty * tt-gds.ms-base )
          .
          case buf_ot-line.ext-doc-type:
            /* это приход */
            when {&TDEDT_PRI_VNESH}  then do :
              if ( buf_trn-doc.cli-type = tt-gds.prod-type ) and
                 ( buf_trn-doc.cli-code = tt-gds.prod-code )
              then do:
                assign
                  v-pri-prod-qnty = v-pri-prod-qnty + v-ot-line-qnty
                .
              end.
              else do:
                assign
                  v-pri-opt-qnty = v-pri-opt-qnty + v-ot-line-qnty
                .
              end.
            end.
            when {&TDEDT_PRI_PEREM}     or
            when {&TDEDT_VOZVRAT_PEREM}
            then do :
              _buf_parts:
              for each buf_parts no-lock
                    where buf_parts.out-code  = buf_ot-line.doc-code
                      and buf_parts.obj-type  = buf_ot-line.obj-type
                      and buf_parts.obj-code  = buf_ot-line.obj-code
                      and buf_parts.artic     = buf_ot-line.artic
                      and buf_parts.prod-type = buf_ot-line.prod-type
                      and buf_parts.prod-code = buf_ot-line.prod-code
              :
                run find-income-doc-code in this-procedure ( input buf_parts.in-code
                                                           , input tt-gds.gds-code
                                                           , input buf_parts.part-code
                                                           , output v-income-doc-code
                                                           ).
                find first sch_trn-doc no-lock
                  where sch_trn-doc.doc-code = v-income-doc-code
                no-error .
                if not available sch_trn-doc then do:
                  message
                    substitute("Не могу найти накладную с номером: &1", buf_parts.in-code)
                  view-as alert-box error .
                  next _buf_parts.
                end.

                assign
                  v-parts-line-qnty = ( buf_parts.fact-qnty * tt-gds.ms-base )
                .

                /*
                  если партия из документа за отчетный период и по объекту из списка объектов
                  участвующих в формировании отчета, то пропускаем его, он учтется как внешний приход
                */
                if    sch_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
                  and sch_trn-doc.fact-date   >= v-begin-date
                  and sch_trn-doc.fact-date   <= v-end-date
                then do:
                  find first buf_obj-list no-lock
                    where buf_obj-list.obj-type = sch_trn-doc.obj-type
                      and buf_obj-list.obj-code = sch_trn-doc.obj-code
                  no-error .
                  if available buf_obj-list then do :
                    next _buf_parts.
                  end.
                end.

                if ( sch_trn-doc.cli-type = tt-gds.prod-type ) and
                   ( sch_trn-doc.cli-code = tt-gds.prod-code )
                then do:
                  assign
                    v-pri-prod-qnty = v-pri-prod-qnty + v-parts-line-qnty
                  .
                end.
                else do:
                  assign
                    v-pri-opt-qnty = v-pri-opt-qnty + v-parts-line-qnty
                  .
                end.
              end. /* for each buf_parts no-lock */

            end.
            /* расход */
            when {&TDEDT_RAS_VNESH}  then do :
              assign
                v-ras-oth-qnty = v-ras-oth-qnty + v-ot-line-qnty
              .
            end.
            when {&TDEDT_RAS_VNESH_KASS}  then do :
              assign
                v-ras-sel-qnty = v-ras-sel-qnty + v-ot-line-qnty
              .
            end.
            when {&TDEDT_VOZVRAT_VNESH}  or
            when {&TDEDT_VOZVRAT_VNESH_KASS}
            then do :
              assign
                v-pri-ret-qnty = v-pri-ret-qnty + v-ot-line-qnty
              .
            end.
            /* списание и возврат поставщику */
            when {&TDEDT_RAS_VNESH_VP} then do :
              assign
                v-ras-ret-qnty = v-ras-ret-qnty + v-ot-line-qnty
              .
            end.
            when {&TDEDT_SPI_VNESH}  then do :
              assign
                v-ras-spi-qnty = v-ras-spi-qnty + v-ot-line-qnty
              .
            end.
            when {&TDEDT_RAS_PEREM} then do :
              /* ищем документ внутреннего прихода */
              find first sch_trn-doc no-lock
                where sch_trn-doc.out-code = buf_trn-doc.doc-code
              no-error .

              if not available sch_trn-doc
              then do:
                message
                  "Не найден документ внутреннего прихода для документа " buf_trn-doc.doc-code
                view-as alert-box error.
              end.

              /* если перемещение на объект из списка и есть документ прихода в факте, то не учитываем его */
              find first buf_obj-list no-lock
                where buf_obj-list.obj-type = buf_trn-doc.cli-type
                  and buf_obj-list.obj-code = buf_trn-doc.cli-code
              no-error .
              if available buf_obj-list and
                 sch_trn-doc.status_ = {&fact}
              then do :
                next _buf_ot-line.
              end.

              assign
                v-ras-oth-qnty = v-ras-oth-qnty + v-ot-line-qnty
              .
            end.
            when {&tdedt_inv}       or
            when {&tdedt_peresort}  or
            when {&tdedt_pri_prvo}
            then do:
              assign
                v-ras-oth-qnty = v-ras-oth-qnty - buf_ot-line.fact-qnty * tt-gds.ms-base
              .
            end.
            otherwise do:
            end.
          end case.
        end. /* _buf_ot-line: */

        find first tt-report
          where tt-report.obj-type       = obj-list.obj-type
            and tt-report.obj-code       = obj-list.obj-code
            and tt-report.type           = tt-gds.gds-man-type
            and tt-report.alc-type-code  = buf_alc-type.alc-type-code
        no-error .
        if not available tt-report then do:
          create tt-report.
          assign
            tt-report.obj-type       = obj-list.obj-type
            tt-report.obj-code       = obj-list.obj-code
            tt-report.type           = tt-gds.gds-man-type
            tt-report.alc-type-code  = buf_alc-type.alc-type-code
          .
        end.
        assign
          tt-report.pri-prod-qnty   = tt-report.pri-prod-qnty + v-pri-prod-qnty
          tt-report.pri-opt-qnty    = tt-report.pri-opt-qnty  + v-pri-opt-qnty
          tt-report.pri-ret-qnty    = tt-report.pri-ret-qnty  + v-pri-ret-qnty
          tt-report.ras-sel-qnty    = tt-report.ras-sel-qnty  + v-ras-sel-qnty
          tt-report.ras-ret-qnty    = tt-report.ras-ret-qnty  + v-ras-ret-qnty
          tt-report.ras-spi-qnty    = tt-report.ras-spi-qnty  + v-ras-spi-qnty
          tt-report.ras-oth-qnty    = tt-report.ras-oth-qnty  + v-ras-oth-qnty

          tt-report.pri-tot-qnty    = tt-report.pri-tot-qnty  + v-pri-prod-qnty
                                                              + v-pri-opt-qnty
                                                              + v-pri-ret-qnty

          tt-report.ras-tot-qnty    = tt-report.ras-tot-qnty  + v-ras-sel-qnty
                                                              + v-ras-ret-qnty
                                                              + v-ras-spi-qnty
                                                              + v-ras-oth-qnty
          v-pri-prod-qnty = 0
          v-pri-opt-qnty  = 0
          v-pri-ret-qnty  = 0
          v-ras-sel-qnty  = 0
          v-ras-ret-qnty  = 0
          v-ras-spi-qnty  = 0
          v-ras-oth-qnty  = 0
        .
      end. /* _tt-gds: */
    end. /* _obj-list: */

  end. /* for each buf_alc-type */

  /* дополняем таблицу отчета до полной */
  define variable v-list-count    as integer   no-undo .
  define variable v-gds-man-type  as integer   no-undo .

  assign
    v-list-count = num-entries({&lst-man})
  .

  for each buf_alc-type no-lock
        where buf_alc-type.alc-type-status = 0 ,
      each obj-list
  :
    do v-i = 1 to v-list-count :
      assign
        v-gds-man-type = integer( entry(v-i , {&lst-man}) )
      .
      find first tt-report
        where tt-report.obj-type       = obj-list.obj-type
          and tt-report.obj-code       = obj-list.obj-code
          and tt-report.type           = v-gds-man-type
          and tt-report.alc-type-code  = buf_alc-type.alc-type-code
      no-error .
      if not available tt-report
      then do:
        create tt-report.
        assign
          tt-report.obj-type       = obj-list.obj-type
          tt-report.obj-code       = obj-list.obj-code
          tt-report.type           = v-gds-man-type
          tt-report.alc-type-code  = buf_alc-type.alc-type-code
          tt-report.alc-type-name  = buf_alc-type.alc-type-name
        .
      end.
    end.
  end.
end.

end procedure. /* fill-tt-report */

/* ===================================================================================================== */
procedure find-income-doc-code :
  define input  parameter p-in-code         like ub.parts.in-code    no-undo .
  define input  parameter p-gds-code        like ub.goods.gds-code   no-undo .
  define input  parameter p-part-code       like ub.parts.part-code  no-undo .
  define output parameter p-income-doc-code like ub.parts.in-code    no-undo .

define buffer buf_parts-attr        for ub.parts-attr .
define buffer buf_income_parts-attr for ub.parts-attr .


do on error undo, return error return-value :
  assign
    p-income-doc-code = ?
  .
  find first buf_parts-attr no-lock
    where buf_parts-attr.in-code   = p-in-code
      and buf_parts-attr.gds-code  = p-gds-code
      and buf_parts-attr.part-code = p-part-code
  no-error .
  if available buf_parts-attr then do:
    find first buf_income_parts-attr no-lock
      where buf_income_parts-attr.in-code   = buf_parts-attr.income-in-code
        and buf_income_parts-attr.gds-code  = buf_parts-attr.income-gds-code
        and buf_income_parts-attr.part-code = buf_parts-attr.income-part-code
      no-error .
    if available buf_income_parts-attr then do:
      assign
        p-income-doc-code = buf_parts-attr.income-in-code
      .
    end.
    else do:
      assign
        p-income-doc-code = ?
      .
    end.
  end.
  else do:
    assign
      p-income-doc-code = ?
    .
  end.
end. /* do */

end procedure. /* find-income-doc-code */

/* ===================================================================================================== */
procedure get-sertificate :
  define input  parameter p-obj-type    like ub.clients.obj-type no-undo .
  define input  parameter p-obj-code    like ub.clients.obj-code no-undo .
  define input  parameter p-date        as date                  no-undo .
  define output  parameter p-sertificate as character no-undo .

  define buffer buf_alc-sale-lic for ub.alc-sale-lic.

do
on error undo, return error return-value
:
  find first buf_alc-sale-lic no-lock
      where buf_alc-sale-lic.cli-type = p-obj-type
        and buf_alc-sale-lic.cli-code = p-obj-code
        and buf_alc-sale-lic.date-to  > p-date
  no-error .
  if available buf_alc-sale-lic then do:
      assign
        p-sertificate = substitute( "серия &1, № &2 от &3"
                                  , buf_alc-sale-lic.seria
                                  , buf_alc-sale-lic.number
                                  , string( buf_alc-sale-lic.date-get , "99.99.9999" )
                                  )
      .
  end.
  else do:
    assign
      p-sertificate = ""
    .
  end.
end.

end procedure. /* get-sertificate */