block-level on error undo, throw.
define input parameter p-tank-density as decimal    no-undo.
define input parameter p-dens-temp    as decimal    no-undo.
define input parameter p-tank-vol     as decimal    no-undo.
define input parameter p-tank-temp    as decimal    no-undo.
define input parameter p-fuel-type    as character  no-undo.
define output parameter p-tank-density-pomi  as decimal no-undo.
define output parameter p-tank-vol-pomi as decimal no-undo.
define temp-table tt-fueldt no-undo
  field temp as decimal
  field p1   as decimal
  field p2   as decimal
  field p3   as decimal
  field p4   as decimal
  field p5   as decimal
  field p6   as decimal
  field p7   as decimal
  field p8   as decimal
  field p9   as decimal
  field p10  as decimal
  field p11  as decimal
  field p12  as decimal
  field p13  as decimal
  field p14  as decimal
  field p15  as decimal
  field p16  as decimal
  field p17  as decimal
  field p18  as decimal
  index pi is primary temp
.
define temp-table tt-fuelvt no-undo
  field temp as decimal
  field p1   as decimal
  field p2   as decimal
  field p3   as decimal
  field p4   as decimal
  field p5   as decimal
  field p6   as decimal
  field p7   as decimal
  field p8   as decimal
  field p9   as decimal
  field p10  as decimal
  field p11  as decimal
  field p12  as decimal
  field p13  as decimal
  field p14  as decimal
  field p15  as decimal
  field p16  as decimal
  field p17  as decimal
  field p18  as decimal
  index pi is primary temp ascending
.
define temp-table tt-dieseldt no-undo
  field temp as decimal
  field p1   as decimal
  field p2   as decimal
  field p3   as decimal
  field p4   as decimal
  field p5   as decimal
  field p6   as decimal
  field p7   as decimal
  field p8   as decimal
  field p9   as decimal
  field p10  as decimal
  field p11  as decimal
  index pi is primary temp
.
define temp-table tt-dieselvt no-undo
  field temp as decimal
  field p1   as decimal
  field p2   as decimal
  field p3   as decimal
  field p4   as decimal
  field p5   as decimal
  field p6   as decimal
  field p7   as decimal
  field p8   as decimal
  field p9   as decimal
  field p10  as decimal
  field p11  as decimal
  index pi is primary temp ascending
.
do:
  def var str as char.
  define variable file-fuel         as character no-undo.
  define variable file-vol          as character no-undo.
  define variable v-density-list1   as character no-undo.
  define variable v-density-list2   as character no-undo.
  define variable v-density-20-list as character no-undo.
  define variable v-vol-list1   as character no-undo.
  define variable v-vol-list2   as character no-undo.
  define variable v-coef-vol    as decimal   no-undo.
  define variable x1        as decimal   no-undo init ?.
  define variable x2        as decimal   no-undo init ?.
  define variable v-temp1   as decimal   no-undo init ?.
  define variable v-temp2   as decimal   no-undo init ?.
  define variable ii        as integer   no-undo.
  define stream str-fueldt.
  define stream str-fuelvt.
  define stream outstream.
  output stream outstream to value ("rdcdnst.log") append.
  assign
    file-fuel = search ('cmp/petrldt.txt') when p-fuel-type = "petrol"
    file-fuel = search ('cmp/dsldt.txt') when p-fuel-type = "diesel-sum" or p-fuel-type = "diesel-wint"
    file-vol = search ('cmp/petrlvt.txt') when p-fuel-type = "petrol"
    file-vol = search ('cmp/dslvt.txt') when p-fuel-type = "diesel-sum" or p-fuel-type = "diesel-wint"
  .
  if file-fuel = ? or file-vol = ? then do:
    undo, return error "Не найдены файлы с таблицами привидения плотности и объема".
  end.
  input stream str-fueldt from value(file-fuel).
  input stream str-fuelvt from value(file-vol).
  if p-fuel-type matches "*diesel*" then do:
    repeat :
      create tt-dieseldt no-error.
      import stream str-fueldt delimiter ";" tt-dieseldt.
    end.
    for each tt-dieseldt where tt-dieseldt.p1 = 0  and tt-dieseldt.temp = 0:
      delete tt-dieseldt.
    end.
    find first tt-dieseldt where tt-dieseldt.temp = 20 no-error.
    if not available tt-dieseldt then  undo, return error "Не верная таблица приведения плотности".
    assign
      v-density-20-list = string (tt-dieseldt.p1)
      v-density-20-list = v-density-20-list + "," + string (tt-dieseldt.p2)
      v-density-20-list = v-density-20-list + "," + string (tt-dieseldt.p3)
      v-density-20-list = v-density-20-list + "," + string (tt-dieseldt.p4)
      v-density-20-list = v-density-20-list + "," + string (tt-dieseldt.p5)
      v-density-20-list = v-density-20-list + "," + string (tt-dieseldt.p6)
      v-density-20-list = v-density-20-list + "," + string (tt-dieseldt.p7)
      v-density-20-list = v-density-20-list + "," + string (tt-dieseldt.p8)
      v-density-20-list = v-density-20-list + "," + string (tt-dieseldt.p9)
      v-density-20-list = v-density-20-list + "," + string (tt-dieseldt.p10)
      v-density-20-list = v-density-20-list + "," + string (tt-dieseldt.p11)
    .
    find first tt-dieseldt where tt-dieseldt.temp = p-dens-temp use-index pi no-error.
    if not available tt-dieseldt then do:
      find first tt-dieseldt where tt-dieseldt.temp > p-dens-temp use-index pi no-error.
    end.
    if not available tt-dieseldt then  undo, return error "Температура измерений за допустимыми пределами".
    assign
      v-temp2 = tt-dieseldt.temp
      v-density-list2 = string (tt-dieseldt.p1)
      v-density-list2 = v-density-list2 + "," + string (tt-dieseldt.p2)
      v-density-list2 = v-density-list2 + "," + string (tt-dieseldt.p3)
      v-density-list2 = v-density-list2 + "," + string (tt-dieseldt.p4)
      v-density-list2 = v-density-list2 + "," + string (tt-dieseldt.p5)
      v-density-list2 = v-density-list2 + "," + string (tt-dieseldt.p6)
      v-density-list2 = v-density-list2 + "," + string (tt-dieseldt.p7)
      v-density-list2 = v-density-list2 + "," + string (tt-dieseldt.p8)
      v-density-list2 = v-density-list2 + "," + string (tt-dieseldt.p9)
      v-density-list2 = v-density-list2 + "," + string (tt-dieseldt.p10)
      v-density-list2 = v-density-list2 + "," + string (tt-dieseldt.p11)
    .
    if tt-dieseldt.temp <> p-dens-temp then do:
      find prev tt-dieseldt where tt-dieseldt.temp < p-dens-temp use-index pi no-error.
    end.
    if not available tt-dieseldt then  undo, return error "Температура измерений за допустимыми пределами".
    assign
      v-temp1 = tt-dieseldt.temp
      v-density-list1 = string (tt-dieseldt.p1)
      v-density-list1 = v-density-list1 + "," + string (tt-dieseldt.p2)
      v-density-list1 = v-density-list1 + "," + string (tt-dieseldt.p3)
      v-density-list1 = v-density-list1 + "," + string (tt-dieseldt.p4)
      v-density-list1 = v-density-list1 + "," + string (tt-dieseldt.p5)
      v-density-list1 = v-density-list1 + "," + string (tt-dieseldt.p6)
      v-density-list1 = v-density-list1 + "," + string (tt-dieseldt.p7)
      v-density-list1 = v-density-list1 + "," + string (tt-dieseldt.p8)
      v-density-list1 = v-density-list1 + "," + string (tt-dieseldt.p9)
      v-density-list1 = v-density-list1 + "," + string (tt-dieseldt.p10)
      v-density-list1 = v-density-list1 + "," + string (tt-dieseldt.p11)
    .
  end.
  else do:
    repeat :
      create tt-fueldt no-error.
      import stream str-fueldt delimiter ";" tt-fueldt.
    end.
    for each tt-fueldt where tt-fueldt.p1 = 0  and tt-fueldt.temp = 0:
      delete tt-fueldt.
    end.
    find first tt-fueldt where tt-fueldt.temp = 20 no-error.
    if not available tt-fueldt then  undo, return error "Не верная таблица приведения плотности".
    assign
      v-density-20-list = string (tt-fueldt.p1)
      v-density-20-list = v-density-20-list + "," + string (tt-fueldt.p2)
      v-density-20-list = v-density-20-list + "," + string (tt-fueldt.p3)
      v-density-20-list = v-density-20-list + "," + string (tt-fueldt.p4)
      v-density-20-list = v-density-20-list + "," + string (tt-fueldt.p5)
      v-density-20-list = v-density-20-list + "," + string (tt-fueldt.p6)
      v-density-20-list = v-density-20-list + "," + string (tt-fueldt.p7)
      v-density-20-list = v-density-20-list + "," + string (tt-fueldt.p8)
      v-density-20-list = v-density-20-list + "," + string (tt-fueldt.p9)
      v-density-20-list = v-density-20-list + "," + string (tt-fueldt.p10)
      v-density-20-list = v-density-20-list + "," + string (tt-fueldt.p11)
      v-density-20-list = v-density-20-list + "," + string (tt-fueldt.p12)
      v-density-20-list = v-density-20-list + "," + string (tt-fueldt.p13)
      v-density-20-list = v-density-20-list + "," + string (tt-fueldt.p14)
      v-density-20-list = v-density-20-list + "," + string (tt-fueldt.p15)
      v-density-20-list = v-density-20-list + "," + string (tt-fueldt.p16)
      v-density-20-list = v-density-20-list + "," + string (tt-fueldt.p17)
      v-density-20-list = v-density-20-list + "," + string (tt-fueldt.p18)
    .
    find first tt-fueldt where tt-fueldt.temp = p-dens-temp use-index pi no-error.
    if not available tt-fueldt then do:
      find first tt-fueldt where tt-fueldt.temp > p-dens-temp use-index pi no-error.
    end.
    if not available tt-fueldt then  undo, return error "Температура измерений за допустимыми пределами".
    assign
      v-temp2 = tt-fueldt.temp
      v-density-list2 = string (tt-fueldt.p1)
      v-density-list2 = v-density-list2 + "," + string (tt-fueldt.p2)
      v-density-list2 = v-density-list2 + "," + string (tt-fueldt.p3)
      v-density-list2 = v-density-list2 + "," + string (tt-fueldt.p4)
      v-density-list2 = v-density-list2 + "," + string (tt-fueldt.p5)
      v-density-list2 = v-density-list2 + "," + string (tt-fueldt.p6)
      v-density-list2 = v-density-list2 + "," + string (tt-fueldt.p7)
      v-density-list2 = v-density-list2 + "," + string (tt-fueldt.p8)
      v-density-list2 = v-density-list2 + "," + string (tt-fueldt.p9)
      v-density-list2 = v-density-list2 + "," + string (tt-fueldt.p10)
      v-density-list2 = v-density-list2 + "," + string (tt-fueldt.p11)
      v-density-list2 = v-density-list2 + "," + string (tt-fueldt.p12)
      v-density-list2 = v-density-list2 + "," + string (tt-fueldt.p13)
      v-density-list2 = v-density-list2 + "," + string (tt-fueldt.p14)
      v-density-list2 = v-density-list2 + "," + string (tt-fueldt.p15)
      v-density-list2 = v-density-list2 + "," + string (tt-fueldt.p16)
      v-density-list2 = v-density-list2 + "," + string (tt-fueldt.p17)
      v-density-list2 = v-density-list2 + "," + string (tt-fueldt.p18)
    .
    if tt-fueldt.temp <> p-dens-temp then do:
      find prev tt-fueldt where tt-fueldt.temp < p-dens-temp use-index pi no-error.
    end.
    if not available tt-fueldt then  undo, return error "Температура измерений за допустимым пределами".
    assign
      v-temp1 = tt-fueldt.temp
      v-density-list1 = string (tt-fueldt.p1)
      v-density-list1 = v-density-list1 + "," + string (tt-fueldt.p2)
      v-density-list1 = v-density-list1 + "," + string (tt-fueldt.p3)
      v-density-list1 = v-density-list1 + "," + string (tt-fueldt.p4)
      v-density-list1 = v-density-list1 + "," + string (tt-fueldt.p5)
      v-density-list1 = v-density-list1 + "," + string (tt-fueldt.p6)
      v-density-list1 = v-density-list1 + "," + string (tt-fueldt.p7)
      v-density-list1 = v-density-list1 + "," + string (tt-fueldt.p8)
      v-density-list1 = v-density-list1 + "," + string (tt-fueldt.p9)
      v-density-list1 = v-density-list1 + "," + string (tt-fueldt.p10)
      v-density-list1 = v-density-list1 + "," + string (tt-fueldt.p11)
      v-density-list1 = v-density-list1 + "," + string (tt-fueldt.p12)
      v-density-list1 = v-density-list1 + "," + string (tt-fueldt.p13)
      v-density-list1 = v-density-list1 + "," + string (tt-fueldt.p14)
      v-density-list1 = v-density-list1 + "," + string (tt-fueldt.p15)
      v-density-list1 = v-density-list1 + "," + string (tt-fueldt.p16)
      v-density-list1 = v-density-list1 + "," + string (tt-fueldt.p17)
      v-density-list1 = v-density-list1 + "," + string (tt-fueldt.p18)
    .
  end.
  ii = num-entries (v-density-20-list) .
  if p-tank-density > decimal (entry (ii, v-density-20-list)) or p-tank-density < decimal (entry(1, v-density-20-list))
      then  undo, return error substitute ("Измеренная плотность вышла за допустимый диапазон &1:&2", decimal (entry(1, v-density-20-list)), decimal (entry (ii, v-density-20-list))).
  _fordenslist:
  do ii = 1 to num-entries (v-density-20-list) :
    if p-tank-density >=  decimal (entry(ii, v-density-20-list)) and p-tank-density <=  decimal (entry(ii + 1, v-density-20-list))
    then do:
      leave _fordenslist.
    end.
  end.
  assign
    x1 = decimal (entry(ii, v-density-list1)) +
        (p-tank-density - decimal (entry(ii, v-density-20-list))) * (decimal (entry(ii + 1, v-density-list1)) - decimal (entry(ii, v-density-list1))) / 10
    x2 = decimal (entry(ii, v-density-list2)) +
        (p-tank-density - decimal (entry(ii, v-density-20-list))) * (decimal (entry(ii + 1, v-density-list2)) - decimal (entry(ii, v-density-list2))) / 10
    p-tank-density-pomi = (x1 + x2) / 2
  .
  put stream outstream unformatted "начало" skip.
  put stream outstream unformatted v-temp1 " - " v-density-list1 skip v-temp2 " - " v-density-list2 skip "область: " x1 " - " x2 skip "приведенная плотность: " p-tank-density-pomi skip.
  if p-fuel-type matches "*diesel*" then do:
   repeat :
      create tt-dieselvt no-error.
      import stream str-fuelvt delimiter ";" tt-dieselvt.
    end.
    for each tt-dieselvt where tt-dieselvt.p1 = 0  and tt-dieselvt.temp = 0:
      delete tt-dieselvt.
    end.
    find first tt-dieselvt where tt-dieselvt.temp = p-tank-temp no-error.
    if not available tt-dieselvt then do:
      find first tt-dieselvt where tt-dieselvt.temp > p-tank-temp use-index pi no-error.
    end.
    if not available tt-dieselvt then  undo, return error "Температура измерений объема за допустимыми пределами".
    assign
      v-temp2 = tt-dieselvt.temp
      v-vol-list2 = string (tt-dieselvt.p1)
      v-vol-list2 = v-vol-list2 + "," + string (tt-dieselvt.p2)
      v-vol-list2 = v-vol-list2 + "," + string (tt-dieselvt.p3)
      v-vol-list2 = v-vol-list2 + "," + string (tt-dieselvt.p4)
      v-vol-list2 = v-vol-list2 + "," + string (tt-dieselvt.p5)
      v-vol-list2 = v-vol-list2 + "," + string (tt-dieselvt.p6)
      v-vol-list2 = v-vol-list2 + "," + string (tt-dieselvt.p7)
      v-vol-list2 = v-vol-list2 + "," + string (tt-dieselvt.p8)
      v-vol-list2 = v-vol-list2 + "," + string (tt-dieselvt.p9)
      v-vol-list2 = v-vol-list2 + "," + string (tt-dieselvt.p10)
      v-vol-list2 = v-vol-list2 + "," + string (tt-dieselvt.p11)
    .
    if tt-dieselvt.temp <> p-tank-temp then do:
      find prev tt-dieselvt where tt-dieselvt.temp < p-tank-temp use-index pi no-error.
    end.
    if not available tt-dieselvt then  undo, return error "Температура измерений объема за допустимыми пределами".
    assign
      v-temp1 = tt-dieselvt.temp
      v-vol-list1 = string (tt-dieselvt.p1)
      v-vol-list1 = v-vol-list1 + "," + string (tt-dieselvt.p2)
      v-vol-list1 = v-vol-list1 + "," + string (tt-dieselvt.p3)
      v-vol-list1 = v-vol-list1 + "," + string (tt-dieselvt.p4)
      v-vol-list1 = v-vol-list1 + "," + string (tt-dieselvt.p5)
      v-vol-list1 = v-vol-list1 + "," + string (tt-dieselvt.p6)
      v-vol-list1 = v-vol-list1 + "," + string (tt-dieselvt.p7)
      v-vol-list1 = v-vol-list1 + "," + string (tt-dieselvt.p8)
      v-vol-list1 = v-vol-list1 + "," + string (tt-dieselvt.p9)
      v-vol-list1 = v-vol-list1 + "," + string (tt-dieselvt.p10)
      v-vol-list1 = v-vol-list1 + "," + string (tt-dieselvt.p11)
    .
  end.
  else do:
    repeat :
      create tt-fuelvt no-error.
      import stream str-fuelvt delimiter ";" tt-fuelvt.
    end.
    for each tt-fuelvt where tt-fuelvt.p1 = 0  and tt-fuelvt.temp = 0:
      delete tt-fuelvt.
    end.
    find first tt-fuelvt where tt-fuelvt.temp = p-tank-temp no-error.
    if not available tt-fuelvt then do:
      find first tt-fuelvt where tt-fuelvt.temp > p-tank-temp use-index pi no-error.
    end.
    if not available tt-fuelvt then  undo, return error "Температура измерений объема за допустимыми пределами".
    assign
      v-temp2 = tt-fuelvt.temp
      v-vol-list2 = string (tt-fuelvt.p1)
      v-vol-list2 = v-vol-list2 + "," + string (tt-fuelvt.p2)
      v-vol-list2 = v-vol-list2 + "," + string (tt-fuelvt.p3)
      v-vol-list2 = v-vol-list2 + "," + string (tt-fuelvt.p4)
      v-vol-list2 = v-vol-list2 + "," + string (tt-fuelvt.p5)
      v-vol-list2 = v-vol-list2 + "," + string (tt-fuelvt.p6)
      v-vol-list2 = v-vol-list2 + "," + string (tt-fuelvt.p7)
      v-vol-list2 = v-vol-list2 + "," + string (tt-fuelvt.p8)
      v-vol-list2 = v-vol-list2 + "," + string (tt-fuelvt.p9)
      v-vol-list2 = v-vol-list2 + "," + string (tt-fuelvt.p10)
      v-vol-list2 = v-vol-list2 + "," + string (tt-fuelvt.p11)
      v-vol-list2 = v-vol-list2 + "," + string (tt-fuelvt.p12)
      v-vol-list2 = v-vol-list2 + "," + string (tt-fuelvt.p13)
      v-vol-list2 = v-vol-list2 + "," + string (tt-fuelvt.p14)
      v-vol-list2 = v-vol-list2 + "," + string (tt-fuelvt.p15)
      v-vol-list2 = v-vol-list2 + "," + string (tt-fuelvt.p16)
      v-vol-list2 = v-vol-list2 + "," + string (tt-fuelvt.p17)
      v-vol-list2 = v-vol-list2 + "," + string (tt-fuelvt.p18)
    .
    if tt-fuelvt.temp <> p-tank-temp then do:
      find prev tt-fuelvt where tt-fuelvt.temp < p-tank-temp use-index pi no-error.
    end.
    if not available tt-fuelvt then  undo, return error "Температура измерений объема за допустимыми пределами".
    assign
      v-temp1 = tt-fuelvt.temp
      v-vol-list1 = string (tt-fuelvt.p1)
      v-vol-list1 = v-vol-list1 + "," + string (tt-fuelvt.p2)
      v-vol-list1 = v-vol-list1 + "," + string (tt-fuelvt.p3)
      v-vol-list1 = v-vol-list1 + "," + string (tt-fuelvt.p4)
      v-vol-list1 = v-vol-list1 + "," + string (tt-fuelvt.p5)
      v-vol-list1 = v-vol-list1 + "," + string (tt-fuelvt.p6)
      v-vol-list1 = v-vol-list1 + "," + string (tt-fuelvt.p7)
      v-vol-list1 = v-vol-list1 + "," + string (tt-fuelvt.p8)
      v-vol-list1 = v-vol-list1 + "," + string (tt-fuelvt.p9)
      v-vol-list1 = v-vol-list1 + "," + string (tt-fuelvt.p10)
      v-vol-list1 = v-vol-list1 + "," + string (tt-fuelvt.p11)
      v-vol-list1 = v-vol-list1 + "," + string (tt-fuelvt.p12)
      v-vol-list1 = v-vol-list1 + "," + string (tt-fuelvt.p13)
      v-vol-list1 = v-vol-list1 + "," + string (tt-fuelvt.p14)
      v-vol-list1 = v-vol-list1 + "," + string (tt-fuelvt.p15)
      v-vol-list1 = v-vol-list1 + "," + string (tt-fuelvt.p16)
      v-vol-list1 = v-vol-list1 + "," + string (tt-fuelvt.p17)
      v-vol-list1 = v-vol-list1 + "," + string (tt-fuelvt.p18)
    .
  end.
  ii = num-entries (v-density-20-list) .
  if p-tank-density-pomi > decimal (entry (ii, v-density-20-list)) or p-tank-density-pomi < decimal (entry(1, v-density-20-list))
  then do:
    message substitute ("Не возможно выполнить приведение объема, т.к. приведенная плотность вышла за допустимый диапазон &1:&2", decimal (entry(1, v-density-20-list)), decimal (entry (ii, v-density-20-list))) view-as alert-box information.
    p-tank-vol-pomi = ? .
  end.
  else do:
    _forvollist:
    do ii = 1 to num-entries (v-density-20-list) :
      if p-tank-density-pomi >=  decimal (entry(ii, v-density-20-list)) and p-tank-density-pomi <=  decimal (entry(ii + 1, v-density-20-list))
      then do:
        leave _forvollist.
      end.
    end.
    assign
      x1 = decimal (entry(ii, v-vol-list1)) +
          (p-tank-density - decimal (entry(ii, v-density-20-list))) * (decimal (entry(ii + 1, v-vol-list1)) - decimal (entry(ii, v-vol-list1))) / 10
      x2 = decimal (entry(ii, v-vol-list2)) +
          (p-tank-density - decimal (entry(ii, v-density-20-list))) * (decimal (entry(ii + 1, v-vol-list2)) - decimal (entry(ii, v-vol-list2))) / 10
      v-coef-vol = (x1 + x2) / 2
    .
  end.
  assign
    p-tank-density-pomi = p-tank-density-pomi / 1000
    p-tank-vol-pomi = v-coef-vol * p-tank-vol when v-coef-vol <> ? and v-coef-vol <> 0
  .
  put stream outstream unformatted v-temp1 " - " v-vol-list1 skip v-temp2 " - " v-vol-list2 skip "область: " x1 " - " x2 skip "коэф. " v-coef-vol " прив. объем " p-tank-vol-pomi skip.
  put stream outstream unformatted "конец" skip.
  output stream outstream close.
  input stream str-fueldt close.
  input stream str-fuelvt close.
end.
