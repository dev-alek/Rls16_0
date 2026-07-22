define temp-table tt-Cash-Param no-undo
field device   as integer   label "Тип устройства"  
field source   as integer   label "Источник"
field section  as character label "Группа/функция"
field fparam   as character label "Параметр"
field fvalue   as character label "Значение"
field fstatus  as integer   label "Обязательный"
field fname    as character label "Описание"
field NumLine_ as integer 
 
index device device source section fparam .