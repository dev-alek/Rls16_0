block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Утилита добавления настроек объектов TH

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/08/08
Author: Bakhtadze Natalya
Creation date: 07/08/08

*/

define input parameter p-forced as logical no-undo .
define input parameter p-read-only as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Утилита добавления настроек объектов TH".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/waitfram.i }
{ gbl/thbjattr.i fix }
{ gbl/thbjattr.i }
{ gbl/cd-attr.i }


define variable v-check as logical no-undo .

define variable v-force as logical no-undo .
define variable v-mes   as character no-undo .
define buffer buf_thbj-attr for ub.thbj-attr.



run waitfram-show in this-procedure ("Реинициализация конфигурации настроек объектов TH").
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if not p-forced then do:
    run check-thbj-version in this-procedure ( output v-check).
  end.
  if v-check
  or p-forced
  then do:
     if v-check
     and p-read-only then do:
        return error substitute("&1 &2 &3&4До начала работы с данной БД (режим RO) необходимо произвести вход в ОСНОВНУЮ БД!!!"
                                ,vss-workfile
                                ,vss-revision
                                ,vss-description
                                ,{&new-line}).
     end.

    run str/diallog.w ( input ?
                , input this-procedure
                , input ('update-thbj-attr':U + {&delim-par} +
                        "1" + {&delim-par} +
                        "1" + {&delim-par} +
                        "1" + {&delim-par} +
                        "1" + {&delim-par} +
                        "yes")
                , input ''
                , input yes /*p-auto-go*/
                , input 'Прервать'
                , input 'Обновлeние логической структуры параметров объектов IBS TH') no-error .
    if error-status:error then do:
      message
      substitute("Ошибка обновлeнии логической структуры параметров объектов IBS TH&1&2&1&3"
                   , {&new-line}
                   , error-status:get-message(1)
                   , return-value )
      view-as alert-box error .
      undo, return error .
    end.
    find first buf_thbj-attr share-lock where
              buf_thbj-attr.upper-prop-code = ''
         and  buf_thbj-attr.prop-code = ''
         and buf_thbj-attr.obj-type = ''
         and buf_thbj-attr.obj-code = 0 no-error.
    if not available buf_thbj-attr then do:
      if g#db-num = 0 then do:
        create buf_thbj-attr.
      end.
    end.
    if available buf_thbj-attr
    and g#db-num = 0 then do:
      assign
      buf_thbj-attr.property-value-character = {&thbj-revision}
      .
    end.
  end. /*if v-check*/
end. /*doe*/

run waitfram-hide in this-procedure .


procedure update-thbj-attr :
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
define variable v-label as character no-undo .
define variable v-user-can-edit as logical no-undo .
define variable v-output-display as logical   no-undo . /* виден в браузере                       */
define variable v-other          as character no-undo . /* еще чего - нибудь                      */
define variable v-prop-list      as character no-undo . /*список членов секции*/
define variable v-prop-type-list as character no-undo . /*список типов членов секции*/
define variable v-prop-label-list as character no-undo . /*список лейблов членов секции*/
define variable v-global          as logical no-undo .   /*может ли быть задан в глобальном контексте*/
define variable v-host           as logical no-undo .    /*может ли быть задан в контексте фирмы*/
define variable v-shop           as logical no-undo .    /*может ли быть задан в контексте маг*/
define variable v-store          as logical no-undo .    /*может ли быть задан в контексте склад*/
define variable v-db             as logical no-undo .    /*может ли быть задан в контексте БД*/

define variable v-upper-code as character no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
define variable v-ii as integer no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .

define buffer buf_clients for ub.clients.
define buffer buf_sysconf for ub.sysconf.

main-block:
do
on error undo, return error
:
  do v-ii = 1 to num-entries({&thbjattr-list}):
    v-upper-code = entry(v-ii, {&thbjattr-list}) .
    if v-upper-code <> {&attr-cd-type-IBS-TH} then next.
    run thbjattr_code in this-procedure (
                                           input  v-upper-code
                                          ,input  '' /*p-code           */
                                          ,output v-label
                                          ,output v-user-can-edit
                                          ,output v-output-display
                                          ,output v-other
                                          ,output v-prop-list
                                          ,output v-prop-type-list
                                          ,output v-prop-label-list
                                          ,output v-global
                                          ,output v-host
                                          ,output v-shop
                                          ,output v-store
                                          ,output v-db
                                          ) no-error.
    if error-status:error then do:
      undo main-block, return error substitute("Ошибка при определении свойств параметра &1", v-upper-code).
    end.
    if g#db-num > 0 then do:
      assign
      v-global = no
      v-host = no
      .
    end.
    case v-global:
      when yes then do:
        run adm/shattri.p (
            input "init":U
          , input '':U /*p-obj-type*/
          , input 0 /*p-obj-code*/
          , input v-upper-code
          , input "":U
          , output v-value-character
          , output v-value-date
          , output v-value-decimal
          , output v-value-integer
          , output v-value-logical
          , output v-param-type
          , INPUT-OUTPUT table-handle v-tth
          ) no-error .
        if error-status:error then do:
          undo main-block, return error substitute("Ошибка при определении значений глобального параметра &1", v-upper-code).
        end.
        run check-if-exists in this-procedure ( input '', input 0, input p-log-handle ) no-error.
        if error-status:error then do:
          undo main-block, return error substitute("Ошибка при проверке наличия в БД глобального параметра &1", v-upper-code).
        end.
      end. /*when yes v-global then do:*/
      otherwise do:
        case v-host:
          when yes then do:
            for each buf_sysconf no-lock
            on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
            on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
            on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
            :
              run adm/shattri.p (
                  input "init":U
                , input {&cmp} /*p-obj-type*/
                , input buf_sysconf.host-code /*p-obj-code*/
                , input v-upper-code
                , input "":U
                , output v-value-character
                , output v-value-date
                , output v-value-decimal
                , output v-value-integer
                , output v-value-logical
                , output v-param-type
                , INPUT-OUTPUT table-handle v-tth
                ) no-error .
              if error-status:error then do:
                undo main-block, return error substitute("Ошибка при определении значений параметра &1 по фирме &2", v-upper-code, buf_sysconf.host-code).
              end.
              run check-if-exists in this-procedure ( input {&cmp}, input buf_sysconf.host-code, input p-log-handle) no-error.
              if error-status:error then do:
                undo main-block, return error substitute("Ошибка при проверке наличия в БД параметра &1 по фирме &2", v-upper-code, buf_sysconf.host-code).
              end.
            end. /*for each buf_sysconf no-lock*/
          end. /*when yes then do:*/
          otherwise do:
            case v-shop :
              when yes then do:
                for each buf_clients no-lock where buf_clients.obj-type = {&shop}
                and (g#db-num = 0 or buf_clients.db-num = g#db-num)
                on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
                on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
                on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
                :
                  run adm/shattri.p (
                      input "init":U
                    , input buf_clients.obj-type /*p-obj-type*/
                    , input buf_clients.obj-code /*p-obj-code*/
                    , input v-upper-code
                    , input "":U
                    , output v-value-character
                    , output v-value-date
                    , output v-value-decimal
                    , output v-value-integer
                    , output v-value-logical
                    , output v-param-type
                    , INPUT-OUTPUT table-handle v-tth
                    ) no-error .
                  if error-status:error then do:
                    undo main-block, return error substitute("Ошибка при определении значений параметра &1 по &2&3", v-upper-code, buf_clients.obj-type, buf_clients.obj-code).
                  end.
                  run check-if-exists in this-procedure ( input buf_clients.obj-type, buf_clients.obj-code, input p-log-handle) no-error.
                  if error-status:error then do:
                    undo main-block, return error substitute("Ошибка при проверке наличия в БД параметра &1 по &2&3", v-upper-code, buf_clients.obj-type, buf_clients.obj-code).
                  end.
                end. /*for each buf_clients no-lock where buf_clients.obj-type = {&shop}*/
              end.
            end. /*              case v-shop :*/
            case v-store :
              when yes then do:
                for each buf_clients no-lock where buf_clients.obj-type = {&stock}
                and (g#db-num = 0 or buf_clients.db-num = g#db-num)
                on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
                on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
                on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
                :
                  run adm/shattri.p (
                      input "init":U
                    , input buf_clients.obj-type /*p-obj-type*/
                    , input buf_clients.obj-code /*p-obj-code*/
                    , input v-upper-code
                    , input "":U
                    , output v-value-character
                    , output v-value-date
                    , output v-value-decimal
                    , output v-value-integer
                    , output v-value-logical
                    , output v-param-type
                    , INPUT-OUTPUT table-handle v-tth
                    ) no-error .
                  if error-status:error then do:
                    undo main-block, return error substitute("Ошибка при определении значений параметра &1 по &2&3", v-upper-code, buf_clients.obj-type, buf_clients.obj-code).
                  end.
                  run check-if-exists in this-procedure ( input buf_clients.obj-type, buf_clients.obj-code, input p-log-handle)  no-error.
                  if error-status:error then do:
                    undo main-block, return error substitute("Ошибка при проверке наличия в БД параметра &1 по &2&3", v-upper-code, buf_clients.obj-type, buf_clients.obj-code).
                  end.
                end. /*for each buf_clients no-lock where buf_clients.obj-type = {&stock}*/
              end. /*when yes then do:*/
            end case. /*              case v-store */
          end. /*otherwise do: v-host <> yes*/
        end case. /*case v-host then do:*/
      end. /*otherwsie v-global <> ye */
    end case. /*case v-global:*/
  end. /*do v-ii = 1 to num-entries({&thbjattr-list}):*/
end.

end procedure. /* update-thbj-attr */


procedure check-if-exists :
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-log-hanlde as handle no-undo .
define variable log-file-name as character no-undo .


define variable v-label          as character no-undo . /* лэйбл атрибута                         */
define variable v-user-can-edit  as logical   no-undo . /* пользователь может изменять в браузере */
define variable v-output-display as logical   no-undo . /* виден в браузере                       */
define variable v-other          as character no-undo . /* еще чего - нибудь                      */
define variable v-prop-list      as character no-undo . /*список членов секции*/
define variable v-prop-type-list as character no-undo . /*список типов членов секции*/
define variable v-prop-label-list as character no-undo . /*список лейблов членов секции*/
define variable v-global          as logical no-undo .   /*может ли быть задан в глобальном контексте*/
define variable v-host           as logical no-undo .    /*может ли быть задан в контексте фирмы*/
define variable v-shop           as logical no-undo .    /*может ли быть задан в контексте маг*/
define variable v-store          as logical no-undo .    /*может ли быть задан в контексте склад*/
define variable v-db             as logical no-undo .    /*может ли быть задан в контексте БД8*/
define variable v-ii as integer no-undo .
define variable v-copy-2cda as logical no-undo .
define variable v-news as logical no-undo .
define variable v-from-gbd as logical no-undo .
define variable v-from-ubd as logical no-undo .
define variable v-db-num as integer no-undo .

define buffer buf_thbjattr_thbj-attr for thbjattr_thbj-attr.
define buffer buf_thbj-attr for ub.thbj-attr.
define buffer buf_Cash-desk for ub.cash-desk.
define buffer buf_cash-desk-attr for ub.cash-desk-attr.

&glob display-message  run write-log-and-file in p-log-handle ( ~
          input 1 ~
        , input log-file-name ~
        , input 1 ~
        , input ~{&my-message~} ~
                                      )



main-block:
do
on error undo, return error
:
  if p-obj-type = "" and g#db-num > 0 then return ''.
  if p-obj-type = {&cmp} and g#db-num > 0 then return ''.
  if p-obj-type = {&db} and p-obj-code <> g#db-num and g#db-num <> 0 then return ''.
  if p-obj-type = {&shop}
  or p-obj-type = {&stock} then do:
    { gbl/objdbnum.i  p-obj-type p-obj-code v-db-num }
    if v-db-num <> g#db-num  and g#db-num <> 0 then  return ''.
  end.
  for each buf_thbjattr_thbj-attr
  break
  by buf_thbjattr_thbj-attr.upper-prop-code
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    output to ll.txt append.
    export buf_thbjattr_thbj-attr.
    output close.
    if first-of(buf_thbjattr_thbj-attr.upper-prop-code) then do:
      find first buf_thbj-attr no-lock where
                buf_thbj-attr.obj-type = p-obj-type
            and buf_thbj-attr.obj-code = p-obj-code
            and buf_thbj-attr.upper-prop-code = buf_thbjattr_thbj-attr.upper-prop-code
            and buf_thbj-attr.prop-code = '' no-error.
      if not available buf_thbj-attr then do:
        create buf_thbj-attr.
        assign
        buf_thbj-attr.obj-type = p-obj-type
        buf_thbj-attr.obj-code = p-obj-code
        buf_thbj-attr.upper-prop-code = buf_thbjattr_thbj-attr.upper-prop-code
        buf_thbj-attr.prop-code = ''
        .
      end.
      /*найдем на кассу надо ли переносить*/
      v-other = ''.
      v-copy-2cda = no.
      run thbjattr_code in this-procedure (
                                            input  buf_thbjattr_thbj-attr.upper-prop-code
                                            ,input  '' /*p-code           */
                                            ,output v-label
                                            ,output v-user-can-edit
                                            ,output v-output-display
                                            ,output v-other
                                            ,output v-prop-list
                                            ,output v-prop-type-list
                                            ,output v-prop-label-list
                                            ,output v-global
                                            ,output v-host
                                            ,output v-shop
                                            ,output v-store
                                            ,output v-db
                                            ) no-error.

        do v-ii = 1 to num-entries(v-other, {&slash-char}):
          if entry(1, entry(v-ii, v-other, {&slash-char}), "=":U) = "copy-2cda":U then do:
            assign
            v-copy-2cda = logical(entry(2, entry(v-ii, v-other, {&slash-char}), "=":U))
            .
            leave.
          end.
        end. /*v-ii*/
        if v-copy-2cda = yes then do:
          assign
          v-news = no
          v-from-ubd = no
          v-from-gbd = no
          .
          /*а теперь проверим этот атрибут кассы заводится в УБД/ГБД и где мы*/
          run cd-attr-news  in this-procedure (
                                                input buf_thbjattr_thbj-attr.upper-prop-code
                                              ,input buf_thbjattr_thbj-attr.prop-code
                                              ,output v-news
                                              ,output v-from-gbd
                                              ,output v-from-ubd ) no-error.
          if g#db-num > 0
          and not v-from-ubd then v-copy-2cda = no.
          if g#db-num = 0
          and not v-from-gbd then v-copy-2cda = no.
      end.
    end. /*if first-of(buf_thbjattr_thbj-attr.upper-prop-code) then do:*/
    find first buf_thbj-attr no-lock where
               buf_thbj-attr.obj-type = p-obj-type
           and buf_thbj-attr.obj-code = p-obj-code
           and buf_thbj-attr.upper-prop-code = buf_thbjattr_thbj-attr.upper-prop-code
           and buf_thbj-attr.prop-code = buf_thbjattr_thbj-attr.prop-code no-error.
    if not available buf_thbj-attr then do:
      create buf_thbj-attr.
      buffer-copy buf_thbjattr_thbj-attr
      except obj-type obj-code
      to buf_thbj-attr
      assign
      buf_thbj-attr.obj-type = p-obj-type
      buf_thbj-attr.obj-code = p-obj-code
      .
    end.
    if v-copy-2cda then do:
      for each buf_cash-desk no-lock where
              buf_cash-desk.pos-type = entry(1, buf_thbj-attr.upper-prop-code, "_")
      on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
      on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
      :


        find first buf_cash-desk-attr no-lock where
                  buf_cash-desk-attr.db-num = buf_Cash-desk.db-num
              and buf_cash-desk-attr.obj-code = buf_Cash-desk.obj-code
              and buf_cash-desk-attr.pos-type = buf_Cash-desk.pos-type
              and buf_cash-desk-attr.cash-num = buf_Cash-desk.cash-num
              and buf_cash-desk-attr.upper-attr-code = buf_thbjattr_thbj-attr.upper-prop-code
              and buf_cash-desk-attr.attr-code = buf_thbjattr_thbj-attr.prop-code no-error.
        if not available buf_cash-desk-attr then do:
          create buf_cash-desk-attr.
          assign
          buf_cash-desk-attr.db-num = buf_Cash-desk.db-num
          buf_cash-desk-attr.pos-type = buf_Cash-desk.pos-type
          buf_cash-desk-attr.obj-code = buf_Cash-desk.obj-code
          buf_cash-desk-attr.cash-num = buf_Cash-desk.cash-num
          buf_cash-desk-attr.attr-code = buf_thbjattr_thbj-attr.prop-code
          buf_cash-desk-attr.upper-attr-code = buf_thbjattr_thbj-attr.upper-prop-code
          buf_cash-desk-attr.attr-value-character = buf_thbjattr_thbj-attr.property-value-character
          buf_cash-desk-attr.attr-value-date = buf_thbjattr_thbj-attr.property-value-date
          buf_cash-desk-attr.attr-value-decimal = buf_thbjattr_thbj-attr.property-value-decimal
          buf_cash-desk-attr.attr-value-integer = buf_thbjattr_thbj-attr.property-value-integer
          buf_cash-desk-attr.attr-value-logical = buf_thbjattr_thbj-attr.property-value-logical
          buf_cash-desk-attr.attr-value-type = buf_thbjattr_thbj-attr.prop-value-type
          .
        end.
      end.
    end.
  end.
end.

end procedure. /* check-if-exists */