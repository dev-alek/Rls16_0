define temp-table tt-place no-undo
  field loc1          as character  label "№ резервуара"
  field locint        as integer    label "№ резервуара"           init ?
  field pl-code       as integer    label "Код резервуара"
  field gds-code      as integer    label "Код продукта"
  field gds-name      as character  label "НАИМЕНОВАНИЕ ПРОДУКТА"
  field level-total   as decimal    label "Общий уровень (см)"
  field level-water   as decimal    label "Уровень воды (см)"
  field total-vol     as decimal    label "Общий объем (л)"
  field avrg-temp     as decimal    label "Средняя Т"
  field t1            as decimal    label "T1"
  field t2            as decimal    label "T2"
  field t3            as decimal    label "T3"
  field density       as decimal    label "Плотность (кг/л)"
  field mass          as decimal    label "Масса (кг)"
  field vapor-density as decimal    label "Плотность СУГ (кг/л)"
  field vapor-pressure as decimal   label "Давление СУГ (мПа)"
  field volume_water  as decimal
  field is-error      as logical
  field error-message as character
  index pi as unique
    loc1
  index locint as primary locint loc1
  
.