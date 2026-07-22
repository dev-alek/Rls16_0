block-level on error undo, throw.
/*
$Revision: 2d6430604525, 1301, rls $
$Author: EShklyar $
$Date: Tue Apr 10 12:04:11 2018 +0300 $
$Workfile: bge-sf.p $
$Archive: bge/bge-sf.p $

Экспорт во Внешнюю Бухгалтерию счетов-фактур

Автор: Хныкин Павел Андреевич
Дата создания: 10/09/07
Author: Pavel Khnykin
Creation date: 10/09/07

*/

DEFINE INPUT  PARAMETER parparentproc        AS WIDGET-HANDLE        NO-UNDO.
define input parameter p-date-from      as date       no-undo. /* начало периода экспорта */
define input parameter p-date-to        as date       no-undo. /* конец  периода экспорта */
define input parameter p-range          as integer    no-undo. /* Диапазон: 1 - глобально, 2 - по списку фирм */
define input parameter p-obj-list       as character  no-undo. /* Список фирм для p-range = 2 */
define input parameter hedt             as handle     no-undo.
define input parameter hcnt             as handle     no-undo.

define variable vss-revision    as character no-undo init "$Revision: 2d6430604525, 1301, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$date: 18.08.03 18:20 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bge-sf.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/bge-sf.p $":U .
define variable vss-description as character no-undo init "Экспорт во Внешнюю Бухгалтерию счетов-фактур".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i  }
{ gbl/temphost.i }
{ bge/bgelib.i   }
{ trg/factord.i  }

do
on error undo, return error
:

  define variable g#db-num as integer   no-undo .
  run get-db-num  in parParentProc ( output g#db-num ).

&scoped-define version-string "15.0 " + replace( vss-revision + vss-date, "$", " " )
&scoped-define parameters-amount 7

    define variable v-xml-file-name     as character            no-undo. /* имя файла вывода */
    define variable v-log-file-name     as character            no-undo. /* имя log-файла */
    define variable v-list-file-name    as character            no-undo. /* имя log-файла */
    define variable v-xml-file-number   as integer              no-undo.
    define variable v-log-string        as character            no-undo. /* имя log-файла */
    define variable v-fact-order-from   like ub.stk-tot.fact-order no-undo.
    define variable v-fact-order-to     like ub.stk-tot.fact-order no-undo.
    define variable v-docs-exists       as logical              no-undo.
    define variable v-obj-counter       as integer              no-undo.
    define variable v-db-num            as integer              no-undo.
    define variable v-cancel            as logical              no-undo.
    define variable v-space-available   as logical              no-undo.
    define variable v-parameter-list    as character            no-undo.

    define variable v-obj-type as character no-undo .
    define variable v-obj-code as integer   no-undo .
    define variable v-host-code as integer   no-undo .
    define variable v-host-str  as character no-undo init "" .

    run init-temphost.
    assign v-log-string = " по всем фирмам" .
    case p-range:
      when 2 then do:     /* Экспорт по списку фирм */
        for each temp-host :
          delete temp-host.
        end.
        do v-obj-counter = 1 to num-entries ( p-obj-list ) / 2  :
          create temp-host.
          assign temp-host.host-code = integer( entry( v-obj-counter * 2, p-obj-list ) ) no-error .
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip "Ошибка чтения списка фирм" skip return-value
              skip trim(error-status :get-message(1)) trim(error-status :get-message(2)) trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
          end.
        end.
        assign v-log-string = " по фирмам: " + p-obj-list .
    end.
    when 3 then do:     /* Экспорт по списку объектов --> фирм */
      for each temp-host :
        delete temp-host.
      end.
      do v-obj-counter = 1 to num-entries ( p-obj-list ) / 2 :
        v-obj-type = entry( (v-obj-counter * 2 ) - 1 , p-obj-list )     .
        v-obj-code = integer( entry( v-obj-counter * 2, p-obj-list ) )  .

        { gbl/hostcode.i  v-obj-type v-obj-code v-host-code }

        if not can-find ( first temp-host where temp-host.host-code = v-host-code) then do:
          v-host-str = v-host-str + "," + string(v-host-code).
          create temp-host.
          assign temp-host.host-code = v-host-code no-error .
          if error-status :error  then do:
            message
              vss-workfile vss-revision vss-description skip "Ошибка чтения списка фирм" skip return-value
              skip trim(error-status :get-message(1)) trim(error-status :get-message(2)) trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
          end.
        end.
      end.
      assign v-log-string = " по фирмам: " + v-host-str .
    end.
  end case.

  run bgelib-filename in this-procedure ( input "s-f", output v-xml-file-name, output v-log-file-name, output v-list-file-name ).
  run gbl/waitfrsp.w ( input substring( v-xml-file-name, 1, 1 ), input {&bgelib_minimum-free-mbytes}, output v-cancel ) .
  if v-cancel = yes then undo, return error .

  run bgelib-write-log in this-procedure ( input v-log-file-name, input 1, input "&DLine" ).
  run bgelib-write-log in this-procedure ( input v-log-file-name, input 1, input substitute( "Начало выгрузки в файл &1"
                                , replace( v-xml-file-name, "/", "\" ) + {&bgelib-temp-extension} ) ).
  run bgelib-write-log in this-procedure ( input v-log-file-name, input 1,
          input substitute( "................с параметрами: Дата с: &1, дата по: &2", p-date-from, p-date-to ) ).
  run bgelib-write-log in this-procedure ( input v-log-file-name, input 1,
          input substitute( "................с параметрами: ... &1: &2",v-log-string )).
  assign
    v-parameter-list         =  substitute( "&1,&2,&3,&4,&5,&6,&7,&8,&9"
                                               , {&parameters-amount}
                                               , "docName"          , "schet-fact":U
                                               , "version"          , replace({&version-string},',','')
                                               , "exportDate"       , string( today,          "99/99/9999" )
                                               , "exportTime"       , string( time,           "HH:MM:SS"   )
                                              )
                                  + substitute( ",&1,&2,&3,&4,&5,&6"
                                               , "baseNum"          , g#db-num
                                               , "dateFrom"         , string( p-date-from,    "99/99/9999" )
                                               , "dateto"           , string( p-date-to,      "99/99/9999" )
                                              ) .

    run bgelib-write-header in this-procedure (
          input yes
        , input v-xml-file-name
        , input v-list-file-name
        , input 1                                           /* p-file-number   */
        , input no                                          /* p-have-prev     */
        , input ""                                          /* p-prev-filename */
        , input p-obj-list
        , input ""
        , input v-parameter-list
    ).
object-of-list:
    for each temp-host :
      run export-docs-by-host (input temp-host.host-code, input v-xml-file-name, input v-log-file-name, input v-list-file-name
            , input v-xml-file-number, output v-xml-file-name, output v-xml-file-number ) no-error.
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip "Ошибка экспорта счетов-фактур по фирме"
          skip "Код фирмы:" temp-host.host-code  skip return-value
          skip trim(error-status :get-message(1)) trim(error-status :get-message(2)) trim(error-status :get-message(3))
        view-as alert-box error.
        next object-of-list.
      end.
    end.
    run bgelib-write-footer in this-procedure ( input yes, input v-xml-file-name, input v-list-file-name, input no, input "" ).
    run bgelib-write-log in this-procedure ( input v-log-file-name, input 1
        , input substitute( "Данные выгружены в файл &1", replace( v-xml-file-name, "/", "\" ) + "xml" ) ).
    run bgelib-write-log in this-procedure ( input v-log-file-name, input 1, input "&DLine" ).
end.

/*==========================================================================*/
procedure export-docs-by-host :
  do on error undo, return error :
    define input parameter p-host-code              as integer      no-undo.
    define input parameter p-xml-file-name          as character    no-undo.
    define input parameter p-log-file-name          as character    no-undo.
    define input parameter p-list-file-name         as character    no-undo.
    define input parameter p-xml-file-number        as integer      no-undo.
    define output parameter p-new-xml-file-name     as character    no-undo.
    define output parameter p-new-xml-file-number   as integer      no-undo.

    define buffer buf_schet-fact-doc  for ub.schet-fact-doc.
    define buffer buf_schet-fact-line for ub.schet-fact-line.

    assign
      p-new-xml-file-name     = p-xml-file-name
      p-new-xml-file-number   = p-xml-file-number
    .
    run bgelib-write-edt( hEDT, 1, string("Фирма :") + string( p-host-code ) ).

    run day-begin-fact-order in this-procedure ( input  p-date-from, output v-fact-order-from ) no-error .
    run factord-end-day      in this-procedure ( input  p-date-to  ,output v-fact-order-to    ) no-error .

    find first buf_schet-fact-doc no-lock
      where buf_schet-fact-doc.host-code = p-host-code
        AND buf_schet-fact-doc.fact-order >= v-fact-order-from
        AND buf_schet-fact-doc.fact-order <= v-fact-order-to
        AND buf_schet-fact-doc.status_ = {&fact}
    no-error .
    if not available buf_schet-fact-doc then do:
      run bgelib-write-edt( hEDT, 4, "В заданном диапазоне дат нет закрытых документов").
      return .
    end.

    run bgelib-show-cnt(hCNT).
/*---E----- Границы fact-order для дат dFrom - dto --------*/
    run bge/sfdocop.p (
                  input parparentproc
                , input p-host-code
                , input "Выгрузка счетов-фактур"
                , input v-fact-order-from
                , input v-fact-order-to
                , input p-obj-list
                , input v-parameter-list
                , input p-xml-file-name
                , input p-log-file-name
                , input p-list-file-name
                , input p-xml-file-number
                , input hEDT
                , input hCNT
                , output p-new-xml-file-name
                , output p-new-xml-file-number
            ) no-error.
    if error-status :error then run bgelib-write-edt( hEDT, 1, string(return-value)).
    assign
      p-xml-file-name     = p-new-xml-file-name
      p-xml-file-number   = p-new-xml-file-number
    .
    run bgelib-show-cnt(hCNT).
  end.
end procedure. /* export-docs-by-host */