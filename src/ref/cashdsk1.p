block-level on error undo, throw.
/*

$Revision: f3ea8f4d0bae, 3346, rls $
$Author: EShklyar $
$Date: 2023/05/19 13:37:10 $
$Workfile: cashdsk1.p $
$Archive: ref/cashdsk1.p $

Сохранение изменений в карточке кассы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/10/03
Author: Bakhtadze Natalya
Creation date: 12/10/03

Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

define input-output parameter p-doc-rec      as recid no-undo.
define input parameter p-mode                as character no-undo .
define input parameter p-db-num              like ub.cash-desk.db-num             no-undo .
define input parameter p-obj-code            like ub.cash-desk.obj-code           no-undo .
define input parameter p-pos-type            like ub.cash-desk.pos-type           no-undo .
define input parameter p-cash-num            like ub.cash-desk.cash-num           no-undo .
define input parameter p-autonomy            like ub.cash-desk.autonomy           no-undo .
define input parameter p-addr-path           like ub.cash-desk.addr-path          no-undo .
define input parameter p-cash-on             like ub.cash-desk.cash-on            no-undo .
define input parameter p-cash-os             like ub.cash-desk.cash-os            no-undo .
define input parameter p-is-del              like ub.cash-desk.is-del             no-undo .
define input parameter p-remote              like ub.cash-desk.remote             no-undo .
define input parameter p-version             like ub.cash-desk.version            no-undo .
define input parameter p-registration-code   like ub.cash-desk.registration-code  no-undo .
define input parameter p-serial-code         like ub.cash-desk.serial-code        no-undo .
define input parameter p-fr-type             as character no-undo .
/* вариант исполнения кассы: обычная, ТСО, мобильная.
   1,2,3 = вариант исполения, отличный от обычного
   0 = обычный вариант исполнения: в БД не пишем, если был записан - стираем. 
   "?" = "оставить прежнее значение"
*/
define input parameter p-device-kind         as integer no-undo .

define variable vss-revision    as character no-undo init "$Revision: f3ea8f4d0bae, 3346, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2023/05/19 13:37:10 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cashdsk1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/cashdsk1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке кассы".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/library.i }
{ gbl/clntattr.i }
{ gbl/tpsi-obj.i }
{ gbl/thbjattr.i }
{ gbl/cd-attr.i }
define variable v-db-num like ub.db.db-num no-undo .
define variable l-shift-on as logical no-undo .
define variable ans as logical no-undo .
define variable hnum as logical no-undo .
define variable b-hnum as logical no-undo .
define variable dflt-cd       as character      no-undo.
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
define variable conf-attr as character no-undo .
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable num-cd as integer no-undo .
define variable ii-num-cd as integer no-undo .
/*define variable v-dopi as integer no-undo .*/
define variable v-dopd as decimal no-undo  .
define variable v-dop-path as character no-undo .
define variable v-cd-list as character no-undo .
define variable v-is-tpsi-obj as logical no-undo .
define variable is-thpos as logical no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle
.

define buffer buf_cash-desk for ub.cash-desk.
define buffer buf_shop  for ub.shop.
define buffer buf_clients for ub.clients.
define buffer other_cash-desk for ub.cash-desk.
define buffer man_cash-desk for ub.cash-desk .
define buffer mar_cash-desk for ub.cash-desk.

define temp-table temp-cash-desk no-undo like ub.cash-desk
field tpsi-obj as logical
iNDEX pi is UNIQUE PRIMARY
db-num
obj-code
pos-type
cash-num
INDEX db-stat-type
db-num
cash-on
pos-type
INDEX i-auto
db-num
pos-type
autonomy
INDEX i-del
db-num
is-del
INDEX i-stat is UNIQUE
db-num
obj-code
pos-type
cash-on
cash-num
index iaddr
db-num
tpsi-obj
obj-code
addr-path
index iaddr2
addr-path
.


/* первая часть процедуры предполагает:
   1. здесь высветить message с текстом ошибки
   2. вернуть в return-value имя поля, на которое надо установить курсор в форме ввода
*/
if p-mode <> {&add-def}
AND p-mode <> {&update} then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр p-mode" p-mode
  view-as alert-box error .
  return error '':u.
end.

if LOOKUP(p-pos-type, {&cd-type-codes}) = 0 then do:
  message
  "Неверный тип кассы" p-pos-type
  view-as alert-box error .
  return error "pos-type":U.
end.

 v-db-num = ibs.th.gbl.gbl-var:g#db-num .

find first buf_clients no-lock where
          buf_clients.obj-code = p-obj-code
      AND buf_clients.obj-type = {&shop}  no-error .
if not avail buf_clients then dO:
  message
  "Не найден магазин с кодом" p-obj-code
  view-as alert-box error .
  return error "obj-code":U.
end.
if buf_clients.db-num <> v-db-num
or
v-db-num <> p-db-num
then do:
  message
  "Нельзя изменять запись КАССЫ в чужой БД" skip
  "Номер текущей БД" v-db-num "Номер БД кассы" p-db-num "Номер БД магазина" buf_clients.db-num
  view-as alert-box ERROR.
  undo, return error "db-num":U.
end.

{ gbl/objat.i
  {&shop}
  p-obj-code
  "'shift-on=request'"
  l-shift-on
}

if not p-is-del then do:

  if l-shift-on
  and lookup(p-pos-type, {&cd-type-IBM} + {&comma-char} +
                          {&cd-type-IBm-XML} + {&comma-char} +
                          {&cd-type-maria} + {&comma-char} +
                          {&cd-type-infokiosk} + {&comma-char} +
                          {&cd-type-NKT-IBM} + {&comma-char} +
                          {&cd-type-pricecheck-Servispl} + {&comma-char} +
                          {&cd-type-autotank} + {&comma-char} +
                          {&cd-type-IBS-TH}

                          ) = 0 then do:
    message
    substitute("Внимание! На объекте &1 требуется использование смен&2" +
               "эту опцию данный тип кассы &3 не поддерживает.&2&2"
               ,p-obj-code
               ,{&new-line}
               ,p-pos-type )
    view-as alert-box ERROR.
    undo, return error "pos-type":U.
  end.

  if p-remote = 1 and
  lookup(p-pos-type, {&cd-type-IBM} + {&comma-char} +
                     {&cd-type-IBm-XML} + {&comma-char} +
                     {&cd-type-maria}
                     ) = 0 then do:
    message
    substitute("УДАЛЕННОЙ кассой может быть только касса типа &1 &2 &3 &4"
               ,{&cd-type-IBM}
               ,{&cd-type-IBm-XML}
               ,{&cd-type-maria}
               )
    view-as alert-box error .
    undo, return error "remote":U.
  end.

  &scop autonomy-code string(p-autonomy)
  if {&cd-autonomy-name} = "":U then  do:
    message
    "Неверное значение АВТОНОМНОСТИ для кассы" p-autonomy
    view-as alert-box error .
    undo, return error "autonomy":U.
  end.

  if NOT (p-pos-type = {&cd-type-ibm-xml}
         OR
         p-pos-type = {&cd-type-ncr-gm}
         OR
         p-pos-type = {&cd-type-ncr-as-r}
         OR
         p-pos-type = {&cd-type-magia-xml}
         OR
         p-pos-type = {&cd-type-maria}
         OR
         p-pos-type = {&cd-type-Autotank}
         )
  and p-autonomy = integer({&cd-manager}) then do:
    message
    substitute("В настоящее время поддерживается работа с кассовым менеджером только для касс типа&1&2 &3 &4 &5 &6"
               , {&new-line}
               , {&cd-type-ibm-XML}
               , {&cd-type-ncr-gm}
               , {&cd-type-ncr-as-r}
               , {&cd-type-magia-xml}
               , {&cd-type-maria}
               , {&cd-type-Autotank}
               )
    view-as alert-box error .
    undo, return error "autonomy":U.
  end.

  if p-pos-type <> {&cd-type-ibm-XML}
  and p-pos-type <> {&cd-type-NCR-GM}
  and p-pos-type <> {&cd-type-NCR-AS-r}
  and p-pos-type <> {&cd-type-MAGIA-XML}
  and p-pos-type <> {&cd-type-MAria}
  and p-pos-type <> {&cd-type-Autotank}
  and p-autonomy = integer({&cd-slave}) then do:
    message
    substitute("В настоящее время поддерживается работа с подчиненными кассами только типа&1&2 &3 &4 &5 &6"
               ,{&new-line}
               ,{&cd-type-ibm-XML}
               ,{&cd-type-NCR-GM}
               ,{&cd-type-NCR-AS-R}
               ,{&cd-type-magia-XML}
               ,{&cd-type-maria}
               ,{&cd-type-Autotank} )
    view-as alert-box error .
    undo, return error "autonomy":U.
  end.

  if p-pos-type = {&cd-type-ibm-XML} then do:
    CASE p-autonomy:
      when integer({&cd-self}) then do:
        find first other_cash-desk no-lock where
                  other_cash-desk.db-num = p-db-num
              AND other_cash-desk.obj-code = p-obj-code
              AND other_cash-desk.pos-type = p-pos-type
              AND other_cash-desk.autonomy <> integer({&cd-self})
              and other_cash-desk.is-del = no
              no-error .
      end.
      otherwise do:
        find first other_cash-desk no-lock where
                  other_cash-desk.db-num = p-db-num
              AND other_cash-desk.obj-code = p-obj-code
              AND other_cash-desk.pos-type = p-pos-type
              AND other_cash-desk.autonomy = integer({&cd-self})
              and other_cash-desk.is-del = no
              no-error .
      end.
    END CASE.
    if available other_cash-desk then do:
      message
      substitute("На одном объекте не могут одновременно существовать кассы типа &1 автономные и подчиненные(под управлением кассового менеджера)"
                ,{&cd-type-IBM-XML})
      view-as alert-box error .
      undo, return error "autonomy":U.
    end.
  end.


  if (p-pos-type = {&cd-type-MAGIA-XML}
  or p-pos-type = {&cd-type-NCR-GM}
  or p-pos-type = {&cd-type-maria}
  or p-pos-type = {&cd-type-autotank}
  )
  AND p-autonomy = integer({&cd-self}) then do:
    message
    substitute("В настоящее время  работа с автономными кассами типа&1&2 &3 &4 &5&1" +
               "не поддерживается"
               ,{&new-line}
               ,{&cd-type-NCR-GM}
               ,{&cd-type-magia-XML}
               ,{&cd-type-maria}
               ,{&cd-type-autotank})
    view-as alert-box error .
    undo, return error "autonomy":U.

  end.
  if p-pos-type = {&cd-type-infokiosk}
  or p-pos-type = {&cd-type-pricecheck-Servispl}
  then do:
    find first buf_cash-desk no-lock where
              buf_cash-desk.db-num = p-db-num
          AND buf_cash-desk.obj-code = p-obj-code
          AND buf_cash-desk.pos-type = p-pos-type no-error .
    if available buf_cash-desk
    and p-mode = {&add-def}
    then do:
      message
      substitute("В магазине может быть только одна касса типа &1",  p-pos-type)
      view-as alert-box error .
      undo, return error "pos-type":U.
    end.
  end.


  if p-addr-path = ""
  and
  ( p-autonomy <> integer({&cd-manager})
    and p-pos-type <> {&cd-type-infokiosk}
    and p-pos-type <> {&cd-type-pricecheck-Servispl}
    and p-pos-type <> {&cd-type-r-keeper}
    and p-pos-type <> {&cd-type-IBS-TH}
    and p-pos-type <> {&cd-type-IBS-TH-MOB}
    and p-pos-type <> {&cd-type-Autotank}
  )
  then do:
    message
    "Не введен адрес-путь к КАССЕ"
    view-as alert-box ERROR .
    undo, return error "addr-path":U.
  end.

  if p-addr-path <> ""
  and (
     p-pos-type = {&cd-type-r-keeper}
  or p-pos-type = {&cd-type-infokiosk}
  or p-pos-type = {&cd-type-pricecheck-Servispl}
  or p-pos-type = {&cd-type-IBS-TH}
  or p-pos-type = {&cd-type-IBS-TH-MOB}
  or (p-pos-type = {&cd-type-autotank} and p-autonomy = integer({&cd-slave}))
  )
  then do:
    message
    substitute("Не надо вводить адрес-путь к КАССЕ типа &1&2все настройки задаются в ini-файле", p-pos-type, {&new-line})
    view-as alert-box ERROR .
    undo, return error "addr-path":U.

  end.
  if p-pos-type = {&cd-type-IBS-TH} then do:
    /*thpos!!!*/
    { gbl/conf-rd.i
    "'is-thpos'"
    "''"
    "''"
    0
    "''"
    "''"
    "''":U
    yes
    conf-par
    par-type
    no-error
    }
    if error-status:error then do:
      message
      substitute("Ошибка при чтении параметра is-thpos:&1&2&1&3"
                  , {&new-line}
                  , error-status:get-message(1)
                  , return-value )
      view-as alert-box error .
      undo, return error "pos-type":U.

    end.
    if par-type <> "L" then do:
      message
      "Неправильный тип параметра is-thpos (должно быть logical)."
      view-as alert-box error.
      undo, return error "pos-type":U.
    end.
    if conf-par <> string(yes) then do:
      message
      substitute("В данной БД не разрешена работа с кассами типа &1&2" +
                 "см параметр is-thpos"
                 , {&cd-type-ibs-th}
                 , {&new-line})
      view-as alert-box error .
      undo, return error "pos-type":U.
    end.
  end.


  define variable l-ipaddr as character no-undo .
  CASE p-pos-type:
    when {&cd-type-NCR-GM} or
    when {&cd-type-MAGIA-XML} then . /*ввовдим все что угодно*/

    when {&cd-type-IBM} or
    when {&cd-type-omron} or
    when {&cd-type-NKT-IBM} then do:
      /* 28/III-2019 разрешено вводить как ip-адрес, так и dns-имя
      IF NUm-entries(p-addr-path, ".") <> 4 then do:
        message
        "Для кассы типа" p-pos-type
        "надо ввести IP адрес кассы в формате NNN.NNN.NNN.NNN !"
        view-as alert-box ERROR .
        undo, return error "addr-path":U.
      end.
      */
    end.
    
    when {&cd-type-IBM-XML} then do:
      if p-autonomy = integer({&cd-manager})
      then do:
        if p-addr-path <> "":U then do:
          message
          "Для кассы типа" p-pos-type "являющейся кассовым менеджером" skip
          "не надо вводить ПУТЬ(АДРЕС) и протокол работы с кассой"
          view-as alert-box ERROR .
          undo, return error "addr-path":U.
       end.
      end.
      else do:
        if p-autonomy = integer({&cd-slave}) then do:
          if LOOKUP(entry(1, p-addr-path, {&delim-par}), "http,ftp,samba,SMTP":U) = 0 then do:
            message
            "Для подчиненной кассы типа" p-pos-type
            "надо ввести протокол работы с кассой - http,ftp,samba,SMTP!"
            view-as alert-box ERROR .
            undo, return error "addr-path":U.
          end.
        end.
        if p-autonomy = integer({&cd-self}) then do:
          if entry(1, p-addr-path, {&delim-par}) <>  "http":U then do:
            message
            "Для автономной кассы типа" p-pos-type
            "можно ввести только один протокол работы с кассой - http!"
            view-as alert-box ERROR .
            undo, return error "addr-path":U.
          end.
        end.
        /* 28/III-2019 разрешено вводить как ip-адрес, так и dns-имя
        IF NUm-entries(entry(2, p-addr-path, {&delim-par}), ".":U) <> 4 then do:
          message
          "Для кассы типа" p-pos-type
          "надо ввести IP адрес кассы в формате NNN.NNN.NNN.NNN !"
          view-as alert-box ERROR .
          undo, return error "addr-path":U.
        end.
        */
        l-ipaddr = entry(2, p-addr-path, {&delim-par}) .
        if num-entries(l-ipaddr, ":") <> 2 then do:
          message
          "Для автономной кассы типа" p-pos-type
          "надо указать IP адрес и порт в формате NNN.NNN.NNN.NNN:PPPP или DNS-имя кассы и порт в формате DNS:PPPP"
          view-as alert-box ERROR .
          undo, return error "addr-path":U.
        end.
        integer(  entry(2, l-ipaddr, ":")  ) no-error .
        if error-status:error then do:
          message
          "Для автономной кассы типа" p-pos-type
          "порт в IP адресе кассы должен быть цифровым!"
          view-as alert-box ERROR .
          undo, return error "addr-path":U.
        end.
      end.
    end.
    when {&cd-type-autotank} then do:
      if p-autonomy = integer({&cd-slave})
      then do:
        if p-addr-path <> "":U then do:
          message
          "Для подчиненной кассы типа" p-pos-type skip
          "не надо вводить ПУТЬ(АДРЕС) и протокол работы с кассой"
          view-as alert-box ERROR .
          undo, return error "addr-path":U.
       end.
      end.
      else do:
        if p-autonomy = integer({&cd-manager}) then do:
          if LOOKUP(entry(1, p-addr-path, {&delim-par}), "http,ftp,samba,SMTP":U) = 0 then do:
            message
            "Для кассового менеджера типа" p-pos-type
            "надо ввести протокол работы с кассой - http!"
            view-as alert-box ERROR .
            undo, return error "addr-path":U.
          end.
        end.
        /*
        IF NUm-entries(entry(2, p-addr-path, {&delim-par}), ".":U) <> 4 then do:
          message
          "Для кассы типа" p-pos-type
          "надо ввести IP адрес кассы в формате NNN.NNN.NNN.NNN !"
          view-as alert-box ERROR .
          undo, return error "addr-path":U.
        end.
        */
        l-ipaddr = entry(2, p-addr-path, {&delim-par}) .        
        if num-entries(l-ipaddr, ":") <> 2
        then do:
          message
          "Для кассового менеджера типа" p-pos-type
          "надо указать IP адрес и порт в формате NNN.NNN.NNN.NNN:PPPP или DNS-имя кассы и порт в формате DNS:PPPP"
          view-as alert-box ERROR .
          undo, return error "addr-path":U.
        end.
        integer(  entry(2, l-ipaddr, ":")  ) no-error .
        if error-status:error then do:
          message
          "Для кассового менеджера типа" p-pos-type
          "порт в IP адресе кассы должен быть цифровым"
          view-as alert-box ERROR .
          undo, return error "addr-path":U.
        end.
      end.
    end.
    when {&cd-type-ipc-servispl}
    or
    when {&cd-type-OMRON-NEW} then do:
      IF substr(p-addr-path, 2,2) <> ":\" then do:
        message
        "Для кассы типа" p-pos-type
        "надо ввести путь к кассе в формате X:\XXXXXX.... !"
        view-as alert-box ERROR .
        undo, return error "addr-path":U.
      end.
    end.
    when {&cd-type-maria} then do:
      if p-autonomy = integer({&cd-slave}) then do:
        if not can-find(first ub.cash-desk where
                            ub.cash-desk.obj-code = p-obj-code
                        and ub.cash-desk.pos-type  = p-pos-type
                        and ub.cash-desk.autonomy  = integer({&cd-manager})
                        and ub.cash-desk.is-del  = no
                        ) then do:
          message
          substitute("Нельзя добавить/изменить подчиненную кассу типа &1&2" +
                     "На объекте не определен кассовый менеджер этого типа"
                     , {&cd-type-maria}
                     , {&new-line})
          view-as alert-box error .
          undo, return error ''.
        end.
        if LOOKUP(entry(1, p-addr-path, {&delim-par}), "shared,local,remote,ftp":U) = 0 then do:
          message
          "Для кассы типа" p-pos-type
          "надо ввести протокол работы с кассой - shared,local,remote,ftp!"
          view-as alert-box ERROR .
          undo, return error "addr-path":U.
        end.
        assign
        v-dop-path = entry(2, p-addr-path, {&delim-par})
        .
        assign
        v-dopd = decimal(entry(3, p-addr-path, {&delim-par} ))
        no-error .
        if error-status:error
        or v-dopd <> round(v-dopd, 0)
        or v-dopd <= 0
        or string(v-dopd, '9999999999') <> entry(3, p-addr-path, {&delim-par})
        then do:
          message
          substitute("Для подчиненной кассы типа &1 заводской № кассы должен быть 10-значным числом с лидирующими нулями"
                    ,p-pos-type
                    ,{&new-line}
                    )
          view-as alert-box ERROR .
          undo, return error "cash-num":U.
        end.
        v-dopd = 0.
        if p-cash-num <> integer(substring(entry(3, p-addr-path, {&delim-par}), 7, 10)) then do:
            message
            substitute("Для подчиненной кассы типа &1, № кассы в IBS TH&2должен быть равен 4-ем последним цифрам заводского номера ЭККА"
                      ,p-pos-type
                      ,{&new-line}
                      )
            view-as alert-box ERROR .
            undo, return error "cash-num":U.
        end.
        CASE entry(1, p-addr-path, {&delim-par}):
          when 'local' then do:
            if not v-dop-path begins 'COM' then do:
              message
              substitute("Для кассы типа &1, работающей по протоколу &2&3" +
                        "адрес должен представлять из себя номер COM-порта!"
                        ,p-pos-type
                        ,entry(1, p-addr-path, {&delim-par})
                        , {&new-line}
                        )
              view-as alert-box ERROR .
              undo, return error "addr-path":U.
            end.
            for each other_cash-desk no-lock where
                    other_cash-desk.db-num = p-db-num
                and other_cash-desk.obj-code = p-obj-code
                and other_cash-desk.pos-type = p-pos-type:
              if p-mode <> {&add-def}
              and p-cash-num = other_cash-desk.cash-num then do:
                next.
              end.
              if other_cash-desk.autonomy = integer({&cd-manager}) then do:
                next.
              end.
              if entry(1, other_cash-desk.addr-path) = 'shared' then do:
                message
                substitute("На одном объекте не могут одновременно существовать кассы типа &1 подключенные как <LOCAL>  и <SHARED>"
                          ,{&cd-type-MARIA})
                view-as alert-box error .
                undo, return error "addr-path":U.
              end.
            end.

            integer(trim (v-dop-path, 'COM')) no-error .
            if error-status:error
            then do:
              message
              substitute("Для кассы типа &1, работающей по протоколу &2&3" +
                        "адрес должен представлять из себя номер COM-порта, записанный в виде COM[n],&3" +
                        "где n - номер порта"
                        ,p-pos-type
                        ,entry(1, p-addr-path, {&delim-par})
                        , {&new-line}
                        )
              view-as alert-box ERROR .
              undo, return error "addr-path":U.
            end.
          end.
          when 'remote' then do:
            if not v-dop-path begins 'COM' then do:
              message
              substitute("Для кассы типа &1, работающей по протоколу &2&3" +
                        "адрес должен начинаться с номера COM-порта!"
                        ,p-pos-type
                        ,entry(1, p-addr-path, {&delim-par})
                        , {&new-line}
                        )
              view-as alert-box ERROR .
              undo, return error "addr-path":U.
            end.
            integer(trim (entry(1, v-dop-path, '+'), 'COM1')) no-error .
            if error-status:error
            then do:
              message
              substitute("Для кассы типа &1, работающей по протоколу &2&3" +
                        "адрес должен начинаться с номера COM-порта, записанного в виде COM[n],&3" +
                        "где n - номер порта"
                        ,p-pos-type
                        ,entry(1, p-addr-path, {&delim-par})
                        , {&new-line}
                        )
              view-as alert-box ERROR .
              undo, return error "addr-path":U.
            end.
            if num-entries(v-dop-path, '+') <> 2 then do:
              message
              substitute("Для кассы типа &1, работающей по протоколу &2&3" +
                        "адрес должен включать номер модема, записанный в международном формате!"
                        ,p-pos-type
                        ,entry(1, p-addr-path, {&delim-par})
                        , {&new-line}
                        )
              view-as alert-box ERROR .
              undo, return error "addr-path":U.
            end.
            assign
            v-dopd = decimal(entry(2, v-dop-path, '+'))
            no-error .
            if error-status:error
            or v-dopd <> round(v-dopd, 0)
            or v-dopd <= 0 then do:
              message
              substitute("Для кассы типа &1, работающей по протоколу &2&3" +
                        "адрес должен включать номер модема, записанный в международном формате&3" +
                        " - знак '+' а далее только цифры!"
                        ,p-pos-type
                        ,entry(1, p-addr-path, {&delim-par})
                        , {&new-line}
                        )
              view-as alert-box ERROR .
              undo, return error "addr-path":U.

            end.
          end.
          when 'ftp' then do:
          end.
          when 'shared' then do:
            for each other_cash-desk no-lock where
                    other_cash-desk.db-num = p-db-num
                and other_cash-desk.obj-code = p-obj-code
                and other_cash-desk.pos-type = p-pos-type:
              if p-mode <> {&add-def}
              and p-cash-num = other_cash-desk.cash-num then do:
                next.
              end.
              if other_cash-desk.autonomy = integer({&cd-manager}) then do:
                next.
              end.
              if entry(1, other_cash-desk.addr-path) = 'local' then do:
                message
                substitute("На одном объекте не могут одновременно существовать кассы типа &1 подключенные как <LOCAL>  и <SHARED>"
                          ,{&cd-type-MARIA})
                view-as alert-box error .
                undo, return error "addr-path":U.
              end.
            end.
          end.

        END CASE.
      end.
      if p-autonomy = integer({&cd-manager}) then do:
        if p-addr-path <> '':U then do:
          message substitute("Для кассового менеджера типа &1 НЕ НУЖНО ВВОДИТЬ АДРЕС-ПУТЬ И/ИЛИ ЗАВОДСКОЙ # И/ИЛИ ПАРОЛЬ И/ИЛИ ПРОТОКОЛ", p-pos-type)
          view-as alert-box error .
          undo, return error "addr-path":U.
        end.
      end.
    end. /*{&cd-type-maria*/
  end CASE.
  if (p-pos-type = {&cd-type-IBM} or
      p-pos-type = {&cd-type-IBM-XML})
    and p-cash-os = "" then do:
    message
    "Неверный тип ОС кассы типа IBM!"
    view-as alert-box ERROR .
    undo, return error "cash-os":U.
  end.
  if (p-pos-type = {&cd-type-IBS-TH}
      or
      p-pos-type = {&cd-type-IBS-TH-MOB})
  and p-cash-os <> "WINDOWS" then do:
    message
    substitute("Неверный тип ОС кассы типа &1!", p-pos-type)
    view-as alert-box ERROR .
    undo, return error "cash-os":U.
  end.

  if (( p-cash-num <= 0 ) OR ( p-cash-num = ? ) )
  and p-autonomy <> integer({&cd-manager})
  then do:
    message
    "Номер кассы должен быть больше 0 !"
    view-as alert-box ERROR .
    undo, return error "cash-num":U.
  end.
  if (( p-cash-num <> 0 ) OR ( p-cash-num = ? ) )
  and p-autonomy = integer({&cd-manager})
  then do:
    message
    "Номер кассового менеджера должен = 0 !"
    view-as alert-box ERROR .
    undo, return error "cash-num":U.
  end.
  if p-cash-num > 999 and
  LOOKUP(p-pos-type, {&cd-type-IBM} + {&comma-char} + {&cd-type-IBM-XML}) > 0 then do:
    message
    substitute("Номер кассы типа &1 должен быть меньше < 999 ! ", p-pos-type)
    view-as alert-box ERROR .
    undo, return error "cash-num":U.
  end.
  if can-find( FIRST buf_cash-desk WHERE
                    buf_cash-desk.obj-code = p-obj-code
                AND buf_cash-desk.cash-num = p-cash-num
                AND (p-mode = {&add-def} or
                    recid(buf_cash-desk ) <> p-doc-rec )
              ) then do:
    message
    "В магазине с номером" p-obj-code skip
    "уже есть касса с номером" p-cash-num
    view-as alert-box ERROR .
    undo, return error "cash-num":U.
  end.
  if p-cash-num <> 0 then do:
    FIND FIRST buf_cash-desk WHERE
              buf_cash-desk.cash-num = p-cash-num
          AND buf_cash-desk.db-num = v-db-num
          AND (recid( buf_cash-desk ) <> p-doc-rec
          or
              p-mode = {&add-def}) NO-LOCK NO-ERROR.
    if available buf_cash-desk then do:
      message
      "Уже имеется касса с номером" buf_cash-desk.cash-num skip
      "в магазине" buf_cash-desk.obj-code skip
      "БД" v-db-num skip(1)
      "Продолжать ?"
      view-as alert-box WARNING buttons yes-no update ans .
      if NOT ans then do:
        undo, return error "":U.
      end.
    end.
  end.
  if p-addr-path <> "":U then do:
    find FIRST buf_cash-desk WHERE
              buf_cash-desk.addr-path = p-addr-path
          AND buf_cash-desk.db-num = p-db-num
          AND buf_cash-desk.is-del = no
          AND (p-mode = {&add-def}
              or
              recid( buf_cash-desk ) <> p-doc-rec) NO-LOCK NO-ERROR.
    IF AVAIL buf_cash-desk then do:
      ans = FALSE .
      message
      "Уже имеется касса с адресом " p-addr-path
      "Касса номер" buf_cash-desk.cash-num SKIP
      "магазин" buf_cash-desk.obj-code skip
      "БД" buf_cash-desk.db-num skip(1)
      "Продолжать ?"
      view-as alert-box WARNING buttons yes-no update ans .
      if NOT ans then do:
        undo, return error "":U.
      end.
      else do:
        if LOOKUP(p-pos-type, {&cd-type-IBM} + {&comma-char} + {&cd-type-IBM-XML} + {&comma-char} + {&cd-type-autotank}) > 0
        or
        LOOKUP(buf_cash-desk.pos-type, {&cd-type-IBM} + {&comma-char} + {&cd-type-IBM-XML} + {&comma-char} + {&cd-type-autotank}) > 0
        then do:
          FIND FIRST buf_shop NO-LOCK WHERE
                    buf_shop.obj-code = p-obj-code NO-ERROR.
          run adm/shattri.p (
              input "get":U
              ,input  {&cmp}
              ,input  buf_shop.host-code
              ,input  {&attr-get-chk}
              ,input  {&attr-get-chk_hnum} /*p-param-code*/
              ,output v-value-character
              ,output v-value-date
              ,output v-value-decimal
              ,output v-value-integer
              ,output v-value-logical
              ,output v-param-type
              ,INPUT-OUTPUT table-handle v-tth
              ) no-error .
          IF error-status:error then do:
            delete object v-tth.
            message
            substitute("Ошибка при получении опций закачки чеков НА ОБЪЕКТЕ &1&2:&3&4 &5"
                      , {&cmp}
                      , buf_shop.host-code
                      , {&new-line}
                      , error-status:get-message(1)
                      , return-value )
            view-as alert-box error .
            return error.
          end.
          delete object v-tth.
          hnum = v-value-logical.
          FIND FIRST buf_shop NO-LOCK WHERE
                  buf_shop.obj-code = buf_cash-desk.obj-code NO-ERROR.
          run adm/shattri.p (
              input "get":U
              ,input  {&cmp}
              ,input  buf_shop.host-code
              ,input  {&attr-get-chk}
              ,input  {&attr-get-chk_hnum} /*p-param-code*/
              ,output v-value-character
              ,output v-value-date
              ,output v-value-decimal
              ,output v-value-integer
              ,output v-value-logical
              ,output v-param-type
              ,INPUT-OUTPUT table-handle v-tth
              ) no-error .
          IF error-status:error then do:
            delete object v-tth.
            message
            substitute("Ошибка при получении опций закачки чеков НА ОБЪЕКТЕ &1&2:&3&4 &5"
                      , {&cmp}
                      , buf_shop.host-code
                      , {&new-line}
                      , error-status:get-message(1)
                      , return-value )
            view-as alert-box error .
            return error.
          end.
          delete object v-tth.
          b-hnum = v-value-logical.
          if (hnum or b-hnum) AND (p-obj-code > 999 OR  buf_cash-desk.obj-code > 999) then do:
            message
            "Касса типа IBM c адресом " buf_cash-desk.addr-path skip
            "не может работать  с магазинами, у которых номер больше 999!" skip
            "(параметр НОМЕР МАГАЗИНА ДЛЯ ЧЕКОВ БРАТЬ ИЗ СПУЛОВ для фирмы этого магазина установлен в YES)"
            view-as alert-box ERROR.
            undo, return error "add-path":U.
          end.
          if NOT hnum or not b-hnum then do:
            message
            substitute("Касса типа &1 c адресом &2 не может работать с магазином,&3" +
                      "пока параметр НОМЕР МАГАЗИНА ДЛЯ ЧЕКОВ БРАТЬ ИЗ СПУЛОВ для фирмы магазина &4 не установлен в YES!"
                      , p-pos-type
                      , buf_cash-desk.addr-path
                      , {&new-line}
                      , (if not hnum then p-obj-code else buf_cash-desk.obj-code)
                      )
            view-as alert-box ERROR.
            undo, return error "addr-path":U.
          end.
        end. /*p-pos-type = "IBM":U or buf_cash-desk.pos-type = "IBM":U*/
      end. /*ans = yes*/
    end. /*avail buf_cash-desk*/
  end. /*p-addr-path <> "":U*/
end.

/* вторая часть процедуры добавляет к первому предположению:
   3. вернуть в return-value текст ошибки вместо имени поля
*/
_MAIN:
DO ON ERROR UNDO, RETURN ERROR return-value
ON STOP UNDO, RETURN ERROR return-value :
  if p-autonomy <> integer({&cd-manager})
  and (p-mode = {&add-def} or p-is-del = no)
  then  do:
    /*лицензионность!!!*/
    { gbl/conf-rd.i
    "'num-cd'"
    "''"
    "''"
    0
    "''"
    "''"
    "''":U
    yes
    conf-par
    par-type
    no-error
    }
    if error-status:error then undo _main, return error return-value .
    if par-type <> "I" then do:
      message
      "Неправильный тип параметра num-cd (должно быть integer)."
      view-as alert-box error.
      undo _main, return error "":U.
    end.
    assign
    num-cd = integer(conf-par)
    no-error .
    if error-status:error then do:
      message
      substitute("Неправильное значение параметра num-cd:&1 (должно быть integer).", conf-par)
      view-as alert-box error.
      undo _main, return error "":U.
    end.
    for each buf_cash-desk no-lock where
            buf_cash-desk.db-num = v-db-num:
      if buf_cash-desk.autonomy = integer({&cd-manager})
      or buf_cash-desk.is-del = yes
      or buf_cash-desk.pos-type = {&cd-type-infokiosk}
      or buf_cash-desk.pos-type = {&cd-type-pricecheck-Servispl}
      then next.
      find first temp-cash-desk where
               temp-cash-desk.db-num = buf_cash-desk.db-num
           and temp-cash-desk.obj-code = buf_cash-desk.obj-code
           and temp-cash-desk.cash-num = buf_cash-desk.cash-num
           and temp-cash-desk.pos-type = buf_cash-desk.pos-type no-error .
      if not available temp-cash-desk then do:
        create temp-cash-desk.
        buffer-copy
        buf_cash-desk to temp-cash-desk
        .
       if buf_cash-desk.pos-type = {&cd-type-ncr-gm}
        or buf_cash-desk.pos-type = {&cd-type-ncr-as-r} then do:
          assign
          temp-cash-desk.addr-path = string(buf_cash-desk.cash-num).
        end.
      end.
        if temp-cash-desk.cash-on then do:
        assign
        ii-num-cd = ii-num-cd + 1
        .
        end.
    end.
    if p-mode = {&add-def} then do:
      if not p-is-del then do:
        create temp-cash-desk.
        assign
        temp-cash-desk.db-num = p-db-num
        temp-cash-desk.obj-code = p-obj-code
        temp-cash-desk.cash-num = p-cash-num
        temp-cash-desk.pos-type  = p-pos-type
        temp-cash-desk.addr-path = p-addr-path
        temp-cash-desk.cash-on   = p-cash-on
        temp-cash-desk.cash-os   = p-cash-os
        temp-cash-desk.remote    = p-remote
        temp-cash-desk.version   = p-version
        temp-cash-desk.autonomy  = p-autonomy
        temp-cash-desk.is-del    = p-is-del
        .
        if temp-cash-desk.cash-on then do:
        assign
        ii-num-cd = ii-num-cd + 1
        .
        end.
      end.
    end.
    for each temp-cash-desk
    where temp-cash-desk.db-num  = v-db-num
    break
    by temp-cash-desk.obj-code:
      if first-of(temp-cash-desk.obj-code) then do:
        v-is-tpsi-obj = no.
        run is-tpsi-object in this-procedure (
                                              input {&shop}
                                            ,input temp-cash-desk.obj-code
                                            ,output v-is-tpsi-obj ).
      end.
      if v-is-tpsi-obj then
      temp-cash-desk.tpsi-obj = yes.
    end.
    for each temp-cash-desk where
    temp-cash-desk.db-num  = v-db-num
    and  temp-cash-desk.tpsi-obj = yes
    break
    by temp-cash-desk.addr-path
    :
      if temp-cash-desk.addr-path <> '':U then do:
        if first-of(temp-cash-desk.addr-path) then do:
        end.
        else do:
          ii-num-cd = ii-num-cd - 1.
        end.
      end. /*if temp-cash-desk.addr-path <> '':U then do:*/
    end.
    if ii-num-cd > num-cd
    then do:
      message
      substitute("Превышено максимальное количество включенных касс в БД: &1", num-cd)
      view-as alert-box error .
      undo _main, return error substitute("Превышено максимальное количество включенных касс в БД: &1", num-cd).
    end.
  end. /*if p-autonomy <> integer({&cd-manager})*/
  if p-pos-type = {&cd-type-maria}
  then do:
    if p-autonomy = integer({&cd-slave}) then
    find first man_cash-desk exclusive-lock where
              man_cash-desk.obj-code = p-obj-code
          and man_cash-desk.pos-type = p-pos-type
          and man_cash-desk.autonomy = integer({&cd-manager}) .
    for each mar_cash-desk where
             mar_cash-desk.obj-code = p-obj-code
          and mar_cash-desk.pos-type = p-pos-type
          and mar_cash-desk.autonomy = integer({&cd-slave})
          and mar_cash-desk.is-del   = no:
      if mar_cash-desk.cash-num = p-cash-num then next.
      assign
      v-cd-list = v-cd-list + (if v-cd-list = '':U then '':U else {&comma-char}) + string(mar_cash-desk.cash-num).
    end.
  end.
  if p-pos-type = {&cd-type-ibs-th} then do:
    if p-fr-type = ''
    or p-fr-type = ?
    or lookup(p-fr-type, {&fr-type-codes}) = 0 then do:
      message
      "Не задан или неверный тип ФР"
      view-as alert-box error .
      undo, return error 'fr-type'.
    end.
    if p-serial-code = "" then do:
      message
      "Не задан серийный номер"
      view-as alert-box error .
      undo, return error 'serial-code'.
    end.
    if trim(p-serial-code, "0123456789") <> '' then do:
      message
      "Серийный номер может включать только цифры!"
      view-as alert-box error .
      undo, return error 'serial-code'.
    end.
  end.
  if p-mode = {&add-def} then do:
    create ub.cash-desk.
    assign
    ub.cash-desk.db-num = p-db-num
    ub.cash-desk.obj-code = p-obj-code
    ub.cash-desk.cash-num = p-cash-num
    ub.cash-desk.pos-type = p-pos-type
    p-doc-rec = recid(ub.cash-desk)
    .
  end.
  else do:
    FIND FIRST ub.cash-desk where
              recid(ub.cash-desk) = p-doc-rec No-ERROR.
    if not available ub.cash-desk then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись КАССА - p-doc-rec" p-doc-rec
      view-as alert-box error .
      undo, return error '':u.
    end.
    if ub.cash-desk.db-num <> p-db-num
    OR ub.cash-desk.obj-code <> p-obj-code
    OR ub.cash-desk.cash-num <> p-cash-num
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Для уже имеющейся записи нельзя изменить"
      "номер БД, номер магазина, номер кассы" skip
      view-as alert-box ERROR.
      undo, return error '':U.
    end.
    else if ub.cash-desk.pos-type <> p-pos-type
    then do:
       define buffer buf_cash-desk-attr for ub.cash-desk-attr.
       for each buf_cash-desk-attr where buf_cash-desk-attr.db-num   eq ub.cash-desk.db-num 
                                     and buf_cash-desk-attr.obj-code eq ub.cash-desk.obj-code
                                     and buf_cash-desk-attr.cash-num eq ub.cash-desk.cash-num
                                     and buf_cash-desk-attr.pos-type eq ub.cash-desk.pos-type
       exclusive-lock:
          buf_cash-desk-attr.pos-type = p-pos-type.
       end.
       /* проверка что такой кассы нет тут не нужна смотри выше */
       ub.cash-desk.pos-type = p-pos-type.
    end.
  end.
  assign
  ub.cash-desk.addr-path = p-addr-path
  ub.cash-desk.cash-on   = (if p-is-del then no else p-cash-on)
  ub.cash-desk.cash-os   = p-cash-os
  ub.cash-desk.remote    = p-remote
  ub.cash-desk.version   = p-version
  ub.cash-desk.autonomy  = p-autonomy
  ub.cash-desk.is-del    = (if p-is-del then not ub.cash-desk.is-del else no)
  ub.cash-desk.registration-code = p-registration-code
  ub.cash-desk.serial-code = p-serial-code
  ub.cash-desk.fr-type = p-fr-type
  ub.cash-desk.device-kind = p-device-kind
  .
  if p-is-del = no
  then
  assign
  v-cd-list = v-cd-list + (if v-cd-list = '':U then '':U else {&comma-char}) +
             string(ub.cash-desk.cash-num).
  if p-pos-type = {&cd-type-maria} then do:
    if p-autonomy = integer({&cd-manager}) then do:
      ub.cash-desk.addr-path = v-cd-list.
    end.
    else do:
      man_cash-desk.addr-path = v-cd-list.
    end.
  end.

  release ub.cash-desk no-error.
  if error-status:error then do:
    message
    vss-workfile vss-revision vss-description skip
    "Ошибка при сохранении записи КАССЫ" skip
    ERROR-STATUS:GET-NUMBER(1) skip
    view-as alert-box .
    undo, return error "":U.
  end.
  if p-pos-type = {&cd-type-ibs-th}
  and p-mode = {&add-def}
  then do:
    /*заполним атрибутами-параметрами*/
    FOR EACH thbjattr_thbj-attr:
      delete thbjattr_thbj-attr.
    end.

    run adm/shattri.p (
                  input "init":U
                , input {&shop}
                , input p-obj-code
                , input {&attr-cd-type-ibs-th}
                , input "":U
                , output v-value-character
                , output v-value-date
                , output v-value-decimal
                , output v-value-integer
                , output v-value-logical
                , output v-param-type
                , INPUT-OUTPUT TABLE-handle v-tth
                ) no-error .
   if error-status:error then do:
     message
     vss-workfile vss-revision vss-description skip
     "Ошибка при получении настроек кассы по умолчанию"
     error-status:get-message(1) skip
     return-value
     view-as alert-box .
     undo, return error ''.
   end.
    for each thbjattr_thbj-attr
    break
    by thbjattr_thbj-attr.upper-prop-code
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
    :
     if thbjattr_thbj-attr.upper-prop-code <> {&attr-cd-type-IBS-TH}
     then do:
       run update-cda in this-procedure ( buffer thbjattr_thbj-attr) no-error .
       if error-status:error then do:
          message
          vss-workfile vss-revision vss-description skip
          "Ошибка при записи настроек кассы по умолчанию"
          error-status:get-message(1) skip
          return-value
          view-as alert-box .
          undo, return error ''.
       end.
     end.
    end.
  end.

end. /*doe*/

procedure update-cda :
define parameter buffer buf_thbjattr_thbj-attr for thbjattr_thbj-attr.
define buffer buf_cash-desk-attr for ub.cash-desk-attr.
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:
  find first   buf_cash-desk-attr share-lock where
        buf_cash-desk-attr.db-num = p-db-num
    and buf_cash-desk-attr.obj-code = p-obj-code
    and buf_cash-desk-attr.pos-type = p-pos-type
    and buf_cash-desk-attr.cash-num = p-cash-num
    and buf_cash-desk-attr.upper-attr-code = buf_thbjattr_thbj-attr.upper-prop-code
  and buf_cash-desk-attr.attr-code = buf_thbjattr_thbj-attr.prop-code
  no-error.
  if not available buf_Cash-desk-attr then do:
    create buf_cash-desk-attr.
    assign
    buf_cash-desk-attr.db-num = p-db-num
    buf_cash-desk-attr.obj-code = p-obj-code
    buf_cash-desk-attr.pos-type = p-pos-type
    buf_cash-desk-attr.cash-num = p-cash-num
    buf_cash-desk-attr.upper-attr-code = buf_thbjattr_thbj-attr.upper-prop-code
    buf_cash-desk-attr.attr-code = buf_thbjattr_thbj-attr.prop-code
    .
  end.
  assign
  buf_cash-desk-attr.attr-value-character = buf_thbjattr_thbj-attr.property-value-character
  buf_cash-desk-attr.attr-value-date = buf_thbjattr_thbj-attr.property-value-date
  buf_cash-desk-attr.attr-value-decimal = buf_thbjattr_thbj-attr.property-value-decimal
  buf_cash-desk-attr.attr-value-integer = buf_thbjattr_thbj-attr.property-value-integer
  buf_cash-desk-attr.attr-value-logical = buf_thbjattr_thbj-attr.property-value-logical
  buf_cash-desk-attr.attr-value-type = buf_thbjattr_thbj-attr.prop-value-type
  .
  release buf_cash-desk-attr no-error.

  if error-status:error then do:
    undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
  end.
end.

end procedure. /* update-cda */