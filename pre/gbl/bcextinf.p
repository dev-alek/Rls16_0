block-level on error undo, throw.
define input  parameter p-bcode-type as character no-undo .
define input  parameter p-b-str      as character no-undo .
define output parameter p-info       as character no-undo .
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: bcextinf.p $":U .
def var vss-archive     as character no-undo init "$Archive: gbl/bcextinf.p $":U .
def var vss-description as character no-undo init "Вернуть расширенную информацию о бар-коде".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
do
on error undo, return error return-value
:
  if p-bcode-type <> 'EAN13':U then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "p-bcode-type" p-bcode-type skip
      view-as alert-box error .
    undo, return error .
  end.
  if p-bcode-type = "EAN13" then do:
    if length(p-b-str) <> 13 then do:
      return .
    end.
    assign
      p-info = 'EAN13 | ':u
    .
    define variable v-ind             as integer   no-undo .
    define variable v-char-ind        as integer   no-undo .
    define variable v-check-sum       as integer   no-undo .
    define variable v-check-sum-digit as character no-undo .
    define variable v-ind-mult        as integer   no-undo extent 12
      INIT [1, 3, 1, 3, 1, 3, 1, 3, 1, 3, 1, 3 ] .
    define variable v-check-sum-dig   as character no-undo extent 10
      INIT ['0':U, '9':U, '8':U, '7':U, '6':U, '5':U, '4':U, '3':U, '2':U, '1':U] .
    assign
      v-check-sum = 0
    .
    do v-ind = 1 to 12
    :
      assign
        v-char-ind = index('0123456789':U, substring( p-b-str, v-ind, 1)) - 1
      .
      if v-char-ind >= 0
      and v-check-sum >= 0
      then do:
        assign
          v-check-sum = v-check-sum
                      + v-char-ind * v-ind-mult[v-ind]
        .
      end.
      else do:
        assign
          v-check-sum = -1
        .
      end.
    end.
    if v-check-sum > 0 then do:
      assign
        v-check-sum-digit = v-check-sum-dig[ v-check-sum mod 10 + 1]
      .
    end.
    if v-check-sum-digit = substring(p-b-str, 13, 1) then do:
      assign
        p-info = p-info + "Контр. сумма ПРАВИЛЬНАЯ | "
      .
    end.
    else do:
      assign
        p-info = p-info + "Контр. сумма ОШИБКА     | "
      .
    end.
    case substring(p-b-str, 1, 2) :
      when '00':U then do: assign p-info = p-info + "США и Канада"             . end.
      when '01':U then do: assign p-info = p-info + "США и Канада"             . end.
      when '02':U then do: assign p-info = p-info + "США и Канада"             . end.
      when '03':U then do: assign p-info = p-info + "США и Канада"             . end.
      when '04':U then do: assign p-info = p-info + "США и Канада"             . end.
      when '05':U then do: assign p-info = p-info + "США и Канада"             . end.
      when '06':U then do: assign p-info = p-info + "США и Канада"             . end.
      when '07':U then do: assign p-info = p-info + "США и Канада"             . end.
      when '08':U then do: assign p-info = p-info + "США и Канада"             . end.
      when '09':U then do: assign p-info = p-info + "США и Канада"             . end.
      when '10':U then do: assign p-info = p-info + "США и Канада"             . end.
      when '11':U then do: assign p-info = p-info + "США и Канада"             . end.
      when '12':U then do: assign p-info = p-info + "США и Канада"             . end.
      when '13':U then do: assign p-info = p-info + "США и Канада"             . end.
      when '20':U then do: assign p-info = p-info + "Внутренняя нумерация"     . end.
      when '21':U then do: assign p-info = p-info + "Внутренняя нумерация"     . end.
      when '22':U then do: assign p-info = p-info + "Внутренняя нумерация"     . end.
      when '23':U then do: assign p-info = p-info + "Внутренняя нумерация"     . end.
      when '24':U then do: assign p-info = p-info + "Внутренняя нумерация"     . end.
      when '25':U then do: assign p-info = p-info + "Внутренняя нумерация"     . end.
      when '26':U then do: assign p-info = p-info + "Внутренняя нумерация"     . end.
      when '27':U then do: assign p-info = p-info + "Внутренняя нумерация"     . end.
      when '28':U then do: assign p-info = p-info + "Внутренняя нумерация"     . end.
      when '29':U then do: assign p-info = p-info + "Внутренняя нумерация"     . end.
      when '30':U then do: assign p-info = p-info + "Франция"                  . end.
      when '31':U then do: assign p-info = p-info + "Франция"                  . end.
      when '32':U then do: assign p-info = p-info + "Франция"                  . end.
      when '33':U then do: assign p-info = p-info + "Франция"                  . end.
      when '34':U then do: assign p-info = p-info + "Франция"                  . end.
      when '35':U then do: assign p-info = p-info + "Франция"                  . end.
      when '36':U then do: assign p-info = p-info + "Франция"                  . end.
      when '37':U then do: assign p-info = p-info + "Франция"                  . end.
      when '40':U then do: assign p-info = p-info + "Германия"                 . end.
      when '41':U then do: assign p-info = p-info + "Германия"                 . end.
      when '42':U then do: assign p-info = p-info + "Германия"                 . end.
      when '43':U then do: assign p-info = p-info + "Германия"                 . end.
      when '44':U then do: assign p-info = p-info + "Германия"                 . end.
      when '45':U then do: assign p-info = p-info + "Япония"                   . end.
      when '46':U then do: assign p-info = p-info + "РОССИЯ"                   . end.
      when '49':U then do: assign p-info = p-info + "Япония"                   . end.
      when '50':U then do: assign p-info = p-info + "Великобритания"           . end.
      when '54':U then do: assign p-info = p-info + "Бельгия, Люксембург"      . end.
      when '57':U then do: assign p-info = p-info + "Дания"                    . end.
      when '64':U then do: assign p-info = p-info + "Финляндия"                . end.
      when '70':U then do: assign p-info = p-info + "Норвегия"                 . end.
      when '73':U then do: assign p-info = p-info + "Швеция"                   . end.
      when '76':U then do: assign p-info = p-info + "Швейцария"                . end.
      when '80':U then do: assign p-info = p-info + "Италия"                   . end.
      when '81':U then do: assign p-info = p-info + "Италия"                   . end.
      when '82':U then do: assign p-info = p-info + "Италия"                   . end.
      when '83':U then do: assign p-info = p-info + "Италия"                   . end.
      when '84':U then do: assign p-info = p-info + "Испания"                  . end.
      when '87':U then do: assign p-info = p-info + "Нидерланды"               . end.
      when '90':U then do: assign p-info = p-info + "Австрия"                  . end.
      when '91':U then do: assign p-info = p-info + "Австрия"                  . end.
      when '93':U then do: assign p-info = p-info + "Австралия"                . end.
      when '94':U then do: assign p-info = p-info + "Новая Зеландия"           . end.
      when '99':U then do: assign p-info = p-info + "Купоны"                   . end.
      otherwise do:
        case substring(p-b-str, 1, 3) :
          when '380':U then do: assign p-info = p-info + "Болгария"                     . end.
          when '383':U then do: assign p-info = p-info + "Словения"                     . end.
          when '385':U then do: assign p-info = p-info + "Хорватия"                     . end.
          when '387':U then do: assign p-info = p-info + "Босния-Герцеговина"           . end.
          when '470':U then do: assign p-info = p-info + "Япония"                       . end.
          when '471':U then do: assign p-info = p-info + "Тайвань"                      . end.
          when '472':U then do: assign p-info = p-info + "Япония"                       . end.
          when '473':U then do: assign p-info = p-info + "Япония"                       . end.
          when '474':U then do: assign p-info = p-info + "Эстония"                      . end.
          when '475':U then do: assign p-info = p-info + "Латвия"                       . end.
          when '476':U then do: assign p-info = p-info + "Азербайджан"                  . end.
          when '477':U then do: assign p-info = p-info + "Литва"                        . end.
          when '478':U then do: assign p-info = p-info + "Узбекистан"                   . end.
          when '479':U then do: assign p-info = p-info + "Шри-Ланка"                    . end.
          when '480':U then do: assign p-info = p-info + "Филиппины"                    . end.
          when '481':U then do: assign p-info = p-info + "Беларусь"                     . end.
          when '482':U then do: assign p-info = p-info + "Украина"                      . end.
          when '483':U then do: assign p-info = p-info + "Япония"                       . end.
          when '484':U then do: assign p-info = p-info + "Молдова"                      . end.
          when '485':U then do: assign p-info = p-info + "Армения"                      . end.
          when '486':U then do: assign p-info = p-info + "Грузия"                       . end.
          when '487':U then do: assign p-info = p-info + "Казахстан"                    . end.
          when '488':U then do: assign p-info = p-info + "Япония"                       . end.
          when '489':U then do: assign p-info = p-info + "Гонконг"                      . end.
          when '520':U then do: assign p-info = p-info + "Греция"                       . end.
          when '528':U then do: assign p-info = p-info + "Ливан"                        . end.
          when '529':U then do: assign p-info = p-info + "Кипр"                         . end.
          when '531':U then do: assign p-info = p-info + "Македония"                    . end.
          when '535':U then do: assign p-info = p-info + "Мальта"                       . end.
          when '539':U then do: assign p-info = p-info + "Ирландия"                     . end.
          when '560':U then do: assign p-info = p-info + "Португалия"                   . end.
          when '569':U then do: assign p-info = p-info + "Исландия"                     . end.
          when '590':U then do: assign p-info = p-info + "Польша"                       . end.
          when '594':U then do: assign p-info = p-info + "Румыния"                      . end.
          when '599':U then do: assign p-info = p-info + "Венгрия"                      . end.
          when '600':U then do: assign p-info = p-info + "Южная Африка"                 . end.
          when '601':U then do: assign p-info = p-info + "Южная Африка"                 . end.
          when '609':U then do: assign p-info = p-info + "Маврикий"                     . end.
          when '611':U then do: assign p-info = p-info + "Марокко"                      . end.
          when '613':U then do: assign p-info = p-info + "Алжир"                        . end.
          when '616':U then do: assign p-info = p-info + "Кения"                        . end.
          when '619':U then do: assign p-info = p-info + "Тунис"                        . end.
          when '621':U then do: assign p-info = p-info + "Сирия"                        . end.
          when '622':U then do: assign p-info = p-info + "Египет"                       . end.
          when '625':U then do: assign p-info = p-info + "Иордания"                     . end.
          when '626':U then do: assign p-info = p-info + "Иран"                         . end.
          when '628':U then do: assign p-info = p-info + "Саудовская Аравия"            . end.
          when '690':U then do: assign p-info = p-info + "Китай"                        . end.
          when '691':U then do: assign p-info = p-info + "Китай"                        . end.
          when '692':U then do: assign p-info = p-info + "Китай"                        . end.
          when '693':U then do: assign p-info = p-info + "Китай"                        . end.
          when '729':U then do: assign p-info = p-info + "Израиль"                      . end.
          when '740':U then do: assign p-info = p-info + "Гватемала"                    . end.
          when '741':U then do: assign p-info = p-info + "Сальвадор"                    . end.
          when '742':U then do: assign p-info = p-info + "Гондурас"                     . end.
          when '743':U then do: assign p-info = p-info + "Никарагуа"                    . end.
          when '744':U then do: assign p-info = p-info + "Коста-Рика"                   . end.
          when '745':U then do: assign p-info = p-info + "Панама"                       . end.
          when '746':U then do: assign p-info = p-info + "Доминиканская Республика"     . end.
          when '750':U then do: assign p-info = p-info + "Мексика"                      . end.
          when '759':U then do: assign p-info = p-info + "Венесуэла"                    . end.
          when '770':U then do: assign p-info = p-info + "Колумбия"                     . end.
          when '773':U then do: assign p-info = p-info + "Уругвай"                      . end.
          when '775':U then do: assign p-info = p-info + "Перу"                         . end.
          when '777':U then do: assign p-info = p-info + "Боливия"                      . end.
          when '779':U then do: assign p-info = p-info + "Аргентина"                    . end.
          when '780':U then do: assign p-info = p-info + "Чили"                         . end.
          when '784':U then do: assign p-info = p-info + "Парагвай"                     . end.
          when '786':U then do: assign p-info = p-info + "Эквадор"                      . end.
          when '789':U then do: assign p-info = p-info + "Бразилия"                     . end.
          when '850':U then do: assign p-info = p-info + "Куба"                         . end.
          when '858':U then do: assign p-info = p-info + "Словакия"                     . end.
          when '859':U then do: assign p-info = p-info + "Чехия"                        . end.
          when '860':U then do: assign p-info = p-info + "Югославия"                    . end.
          when '867':U then do: assign p-info = p-info + "Северная Корея"               . end.
          when '869':U then do: assign p-info = p-info + "Турция"                       . end.
          when '880':U then do: assign p-info = p-info + "Южная Корея"                  . end.
          when '885':U then do: assign p-info = p-info + "Таиланд"                      . end.
          when '888':U then do: assign p-info = p-info + "Сингапур"                     . end.
          when '890':U then do: assign p-info = p-info + "Индия"                        . end.
          when '893':U then do: assign p-info = p-info + "Вьетнам"                      . end.
          when '899':U then do: assign p-info = p-info + "Индонезия"                    . end.
          when '955':U then do: assign p-info = p-info + "Малайзия"                     . end.
          when '958':U then do: assign p-info = p-info + "Макао"                        . end.
          when '977':U then do: assign p-info = p-info + "Периодические издания, пресса". end.
          when '978':U then do: assign p-info = p-info + "Книги"                        . end.
          when '979':U then do: assign p-info = p-info + "Книги"                        . end.
          when '980':U then do: assign p-info = p-info + "Возвратные квитанции"         . end.
          when '981':U then do: assign p-info = p-info + "Валютные купоны"              . end.
          when '982':U then do: assign p-info = p-info + "Валютные купоны"              . end.
          otherwise do:
            assign p-info = p-info + "НЕИЗВЕСТНЫЙ ПРЕФИКС" .
          end.
        end.
      end.
    end.
  end.
end.
