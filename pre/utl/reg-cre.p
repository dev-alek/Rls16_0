block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: 4646375a716b, 518, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Fri Mar 11 18:41:18 2016 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: reg-cre.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/reg-cre.p $":U .
define variable vss-description as character no-undo init "Заполнение справочника регионов РФ".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define buffer buf_regions for regions.
on write  of ub.regions override do: end.
on delete of ub.regions override do: end.
do
on error undo, return error
:
  for each buf_regions exclusive-lock :
    delete buf_regions.
  end.
  create buf_regions.
  assign
    buf_regions.reg-code = 0
    buf_regions.reg-name = 'за пределами РФ':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 1
    buf_regions.reg-name = 'Республика Адыгея (Адыгея)':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 2
    buf_regions.reg-name = 'Республика Башкортостан':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 3
    buf_regions.reg-name = 'Республика Бурятия':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 4
    buf_regions.reg-name = 'Республика Алтай':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 5
    buf_regions.reg-name = 'Республика Дагестан':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 6
    buf_regions.reg-name = 'Республика Ингушетия':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 7
    buf_regions.reg-name = 'Кабардино-Балкарская Республика':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 8
    buf_regions.reg-name = 'Республика Калмыкия':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 9
    buf_regions.reg-name = 'Карачаево-Черкесская Республика':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 10
    buf_regions.reg-name = 'Республика Карелия':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 11
    buf_regions.reg-name = 'Республика Коми':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 12
    buf_regions.reg-name = 'Республика Марий Эл':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 13
    buf_regions.reg-name = 'Республика Мордовия':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 14
    buf_regions.reg-name = 'Республика Саха (Якутия)':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 15
    buf_regions.reg-name = 'Республика Северная Осетия - Алания':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 16
    buf_regions.reg-name = 'Республика Татарстан (Татарстан)':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 17
    buf_regions.reg-name = 'Республика Тыва':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 18
    buf_regions.reg-name = 'Удмуртская Республика':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 19
    buf_regions.reg-name = 'Республика Хакасия':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 20
    buf_regions.reg-name = 'Чеченская Республика':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 21
    buf_regions.reg-name = 'Чувашская Республика - Чувашия':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 22
    buf_regions.reg-name = 'Алтайский край':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 23
    buf_regions.reg-name = 'Краснодарский край':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 24
    buf_regions.reg-name = 'Красноярский край':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 25
    buf_regions.reg-name = 'Приморский край':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 26
    buf_regions.reg-name = 'Ставропольский край':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 27
    buf_regions.reg-name = 'Хабаровский край':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 28
    buf_regions.reg-name = 'Амурская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 29
    buf_regions.reg-name = 'Архангельская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 30
    buf_regions.reg-name = 'Астраханская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 31
    buf_regions.reg-name = 'Белгородская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 32
    buf_regions.reg-name = 'Брянская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 33
    buf_regions.reg-name = 'Владимирская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 34
    buf_regions.reg-name = 'Волгоградская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 35
    buf_regions.reg-name = 'Вологодская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 36
    buf_regions.reg-name = 'Воронежская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 37
    buf_regions.reg-name = 'Ивановская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 38
    buf_regions.reg-name = 'Иркутская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 39
    buf_regions.reg-name = 'Калининградская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 40
    buf_regions.reg-name = 'Калужская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 41
    buf_regions.reg-name = 'Камчатская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 42
    buf_regions.reg-name = 'Кемеровская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 43
    buf_regions.reg-name = 'Кировская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 44
    buf_regions.reg-name = 'Костромская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 45
    buf_regions.reg-name = 'Курганская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 46
    buf_regions.reg-name = 'Курская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 47
    buf_regions.reg-name = 'Ленинградская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 48
    buf_regions.reg-name = 'Липецкая область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 49
    buf_regions.reg-name = 'Магаданская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 50
    buf_regions.reg-name = 'Московская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 51
    buf_regions.reg-name = 'Мурманская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 52
    buf_regions.reg-name = 'Нижегородская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 53
    buf_regions.reg-name = 'Новгородская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 54
    buf_regions.reg-name = 'Новосибирская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 55
    buf_regions.reg-name = 'Омская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 56
    buf_regions.reg-name = 'Оренбургская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 57
    buf_regions.reg-name = 'Орловская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 58
    buf_regions.reg-name = 'Пензенская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 59
    buf_regions.reg-name = 'Пермская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 60
    buf_regions.reg-name = 'Псковская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 61
    buf_regions.reg-name = 'Ростовская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 62
    buf_regions.reg-name = 'Рязанская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 63
    buf_regions.reg-name = 'Самарская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 64
    buf_regions.reg-name = 'Саратовская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 65
    buf_regions.reg-name = 'Сахалинская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 66
    buf_regions.reg-name = 'Свердловская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 67
    buf_regions.reg-name = 'Смоленская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 68
    buf_regions.reg-name = 'Тамбовская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 69
    buf_regions.reg-name = 'Тверская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 70
    buf_regions.reg-name = 'Томская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 71
    buf_regions.reg-name = 'Тульская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 72
    buf_regions.reg-name = 'Тюменская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 73
    buf_regions.reg-name = 'Ульяновская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 74
    buf_regions.reg-name = 'Челябинская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 75
    buf_regions.reg-name = 'Читинская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 76
    buf_regions.reg-name = 'Ярославская область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 77
    buf_regions.reg-name = 'г. Москва':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 78
    buf_regions.reg-name = 'г. Санкт-Петербург':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 79
    buf_regions.reg-name = 'Еврейская автономная область':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 80
    buf_regions.reg-name = 'Агинский Бурятский автономный округ':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 81
    buf_regions.reg-name = 'Коми-Пермяцкий автономный округ':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 82
    buf_regions.reg-name = 'Корякский автономный округ':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 83
    buf_regions.reg-name = 'Ненецкий автономный округ':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 84
    buf_regions.reg-name = 'Таймырский (Долгано-Ненецкий) АО':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 85
    buf_regions.reg-name = 'Усть-Ордынский Бурятский АО':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 86
    buf_regions.reg-name = 'Ханты-Мансийский АО- Югра':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 87
    buf_regions.reg-name = 'Чукотский автономный округ':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 88
    buf_regions.reg-name = 'Эвенкийский автономный округ':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 89
    buf_regions.reg-name = 'Ямало-Ненецкий автономный округ':U
    buf_regions.status_  = 0
  .
  create buf_regions.
  assign
    buf_regions.reg-code = 91
    buf_regions.reg-name = 'Республика Крым':U
    buf_regions.status_  = 0
  .
      create buf_regions.
  assign
    buf_regions.reg-code = 92
    buf_regions.reg-name = 'г.Севастополь':U
    buf_regions.status_  = 0
  .
end.
