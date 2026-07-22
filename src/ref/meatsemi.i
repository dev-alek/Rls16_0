/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/30/09
Author: Bakhtadze Natalya
Creation date: 07/30/09

*/

{ gbl/color.i }

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{2}" <> "proc" &then

define temp-table {1} no-undo
field group-name as character column-label "Группа" help "Полуфабрикаты, объединенные по массовой доле мясных ингредиентов в рецептуре"
format "X(15)" label "Группа"
view-as combo-box list-items "мясные", "мясосодержащие"  inner-lines 2 drop-down-list size-chars 20 by 1
/*
мясные, мясосодержащие;
*/

field kind-name as character column-label "Вид"
format "X(8)" label "Вид"
view-as combo-box list-items "кусковые", "рубленые", "в тесте"  inner-lines 3 drop-down-list size-chars 20  by 1
/*
виды кусковые; рубленые; в тесте;
*/

field subkind-name-1 as character column-label "Кости-мясо" help "Полуфабрикаты, объединенные по технологии изготовления"
format "X(11)" label "Кости-мясо"
view-as combo-box list-items "-" , "бескостные", "мясокостные"  inner-lines 3 drop-down-list  size-chars 20  by 1
/*
бескостные, мясокостные (кусковые полуфабрикаты);
*/

field subkind-name-2 as character column-label "Дискретность"  help "Полуфабрикаты, объединенные по технологии изготовления"
format "X(15)" label "Дискретность"
view-as combo-box list-items "-", "крупнокусковые", "порционные" , "мелкокусковые"  inner-lines 4 drop-down-list size-chars 20  by 1
/*
крупнокусковые, порционные, мелкокусковые (кусковые полуфабрикаты);
*/

field subkind-name-3 as character column-label "Фаршировка" help "Полуфабрикаты, объединенные по технологии изготовления"
format "X(15)" label "Фаршировка"
view-as combo-box list-items "-", "фаршированные", "нефаршированные"  inner-lines 3 drop-down-list size-chars 20  by 1
/*
фаршированные, нефаршированные;
*/

field subkind-name-4 as character column-label "Формовка" help "Полуфабрикаты, объединенные по технологии изготовления"
format "X(13)" label "Формовка"
view-as combo-box list-items "-", "формованные", "неформованные"  inner-lines 3 drop-down-list size-chars 20  by 1
/*
формованные, неформованные;
*/

field subkind-name-5 as character column-label "Панировка" help "Полуфабрикаты, объединенные по технологии изготовления"
format "X(14)" label "Панировка"
view-as combo-box list-items "-", "панированные", "непанированные"  inner-lines 3 drop-down-list size-chars 20  by 1
/*
панированные, непанированные;
*/


field subkind-name-6 as character column-label "Фасовка" help "Полуфабрикаты, объединенные по технологии изготовления"
format "X(10)" label "Фасовка"
view-as combo-box list-items "весовые", "фасованные"  inner-lines 2 drop-down-list size-chars 20  by 1
/*
весовые, фасованные;
мясной [мясосодержащий] фасованный полуфабрикат. Мясной [мясосодержащий] полуфабрикат, формование, взвешивание и укладку которого в потребительскую упаковку осуществляют в процессе его изготовления.
мясной [мясосодержащий] весовой полуфабрикат: Мясной [мясосодержащий] полуфабрикат, взвешивание и укладку которого в потребительскую упаковку осуществляют при реализации населению.
*/

field category-name as character  column-label "Категория" help "Полуфабрикаты, объединенные по массовой доле мышечной ткани в рецептуре"
format "X(11)" label "Категория"
view-as combo-box list-items "категория А", "категория Б", "категория В", "категория Г", "категория Д"  inner-lines 5 drop-down-list size-chars 20  by 1
/* категории

мясной полуфабрикат категории А: Мясной рубленый или кусковой полуфабрикат [полуфабрикат в тесте] с массовой долей мышечной ткани в рецептуре [в рецептуре начинки] 80,0% и более.

мясной полуфабрикат категории Б: Мясной рубленый или кусковой полуфабрикат [полуфабрикат в тесте] с массовой долей мышечной ткани в рецептуре [в рецептуре начинки] от 60,0% до 80,0%.

мясной [мясосодержащий] полуфабрикат категории В: Мясной [мясосодержащий] рубленый или кусковой полуфабрикат [полуфабрикат в тесте] с массовой долей мышечной ткани в рецептуре [в рецептуре начинки] от 40,0% до 60,0%.

мясной [мясосодержащий] полуфабрикат категории Г: Мясной [мясосодержащий] рубленый или кусковой полуфабрикат [полуфабрикат в тесте] с массовой долей мышечной ткани в рецептуре [в рецептуре начинки] от 20,0% до 40,0%.

мясной [мясосодержащий] полуфабрикат категории Д: Мясной [мясосодержащий] рубленый или кусковой полуфабрикат [полуфабрикат в тесте] с массовой долей мышечной ткани в рецептуре [в рецептуре начинки] менее 20,0%.

А, Б, В, Г, Д - мясные полуфабрикаты;

В, Г, Д - мясосодержащие полуфабрикаты;

мясной [мясосодержащий] полуфабрикат категории В: Мясной [мясосодержащий] рубленый или кусковой полуфабрикат [полуфабрикат в тесте] с массовой долей мышечной ткани в рецептуре [в рецептуре начинки] от 40,0% до 60,0%.

мясной [мясосодержащий] полуфабрикат категории Г: Мясной [мясосодержащий] рубленый или кусковой полуфабрикат [полуфабрикат в тесте] с массовой долей мышечной ткани в рецептуре [в рецептуре начинки] от 20,0% до 40,0%.

мясной [мясосодержащий] полуфабрикат категории Д: Мясной [мясосодержащий] рубленый или кусковой полуфабрикат [полуфабрикат в тесте] с массовой долей мышечной ткани в рецептуре [в рецептуре начинки] менее 20,0%.

*/

field termic-condition-name as character  column-label "Терм.!состояние" help "Полуфабрикаты, объединенные по термическому состоянию"
format "X(15)" label "Терм.состояние"
view-as combo-box list-items "охлажденные", "подмороженные", "замороженные"  inner-lines 3 drop-down-list size-chars 20  by 1
/*
охлажденные, подмороженные, замороженные.

мясной [мясосодержащий] охлажденный полуфабрикат: Мясной [мясосодержащий] полуфабрикат, реализуемый с температурой в толще продукта от минус 1 °С до плюс 6 °С.

мясной [мясосодержащий] подмороженный полуфабрикат: Мясной [мясосодержащий] полуфабрикат, реализуемый с температурой в толще продукта от минус 1 °С до минус 5 °С.

мясной [мясосодержащий] замороженный полуфабрикат: Мясной [мясосодержащий] полуфабрикат, реализуемый с температурой в толще продукта не выше минус 10 °С.
*/


field node-code as integer  column-label "Код"
format ">>>9" label "Код"
fgcolor RED_COLOR

field upper-node-code as integer
field subkind-name as character
field lvl-num as integer
index pi is unique primary
node-code
index iupper upper-node-code
index igroup group-name
index ikind kind-name
index isubkind subkind-name
index icategory category-name
index itermic termic-condition-name
.
&if "{2}" = "ds" &then

define dataset meat-semi-finished-ds for {1}.

&endif
&endif

&if "{2}" = "proc" &then

procedure meatsemi_fill-msf :
/*заполним таблицу из clob*/
define input parameter p-mode as character no-undo .
define parameter buffer buf_clob-bind for ub.clob-bind.
define buffer buf_clob-data for ub.clob-data.
define variable v-longchar as longchar no-undo .
define variable glog as logical no-undo .
case p-mode:
  when  {&update} then do:
   find first buf_clob-bind exclusive-lock where
            buf_clob-bind.resource-type = {&lob-res-ref}
       and buf_clob-bind.uniq-key-rec = "meat-semi-finished.xml"
       and buf_clob-bind.field-name = "" no-error.

  end.
  otherwise do:
    find first buf_clob-bind no-lock where
            buf_clob-bind.resource-type = {&lob-res-ref}
       and buf_clob-bind.uniq-key-rec = "meat-semi-finished.xml"
       and buf_clob-bind.field-name = "" no-error.
  end.
end case.
if available buf_clob-bind then do:
  find first buf_clob-data no-lock where
            buf_clob-data.db-num = buf_clob-bind.db-num
        and buf_clob-data.int64-id = buf_clob-bind.int64-id no-error.
  if available buf_clob-data then do:
    v-longchar = buf_clob-data.cdata.
    glog = DATASET meat-semi-finished-ds:HANDLE:read-XML("LONGCHAR"
                                                , v-longchar
                                                , "EMPTY" /*read-mode*/
                                                , ? /*schema-location*/
                                                , ? /*override-default-mapping*/
                                                , ? /*field-type-mapping*/
                                                , "loose" /*verify-schema-mode*/  )  no-error .
    if error-status:error
    or not glog then do:
      MESSAGE
      "НЕ удается прочитать из БД классификатор" skip
      ERROR-STATUS:GET-MESSAGE(1) SKIP
      RETURN-VALUE
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
    end.
  end.
end.
end procedure. /* fill-msf */

&endif



/* $Workfile$ e n d */