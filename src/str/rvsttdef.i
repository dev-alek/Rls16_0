/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определения временных таблиц для сверок

Автор: Уханов Дмитрий Юрьевич
Дата создания: 11/29/06
Author: Dmitry Ukhanov
Creation date: 11/29/06

create: Булгаков Андрей Николаевич

*/

&scop tt_total-list   'tt-param,tt-param-pump,tt-meas,tt-meas-file,tt-pump-nozzle,tt-pump-nozzle-file'
&scop temp-table_list {1}

&scop self-name tt-param
&if ( lookup( '{&self-name}',  ''                   ) = 0      or
      lookup( '{&self-name}',  '*'                  ) = 0 )    and
      lookup( '{&self-name}', '^{&temp-table_list}' ) = 0      or
                               '{&temp-table_list}'   = 'pars' or
                               '{&temp-table_list}'   = 'rvs'  or
      lookup( '{&self-name}',  '{&temp-table_list}' ) > 0      &then
  define temp-table tt-param no-undo
    field strfrfile as character /* revise.txt */
    field strasi    as character /* Agent Asm */
    field flddb     as character /* meas-file */
    index pi        as primary   unique strfrfile
    index asi strasi.
&endif

&scop self-name tt-param-pump
&if ( lookup( '{&self-name}',  ''                   ) = 0      or
      lookup( '{&self-name}',  '*'                  ) = 0 )    and
      lookup( '{&self-name}', '^{&temp-table_list}' ) = 0      or
                               '{&temp-table_list}'   = 'pars' or
                               '{&temp-table_list}'   = 'pump' or
      lookup( '{&self-name}',  '{&temp-table_list}' ) > 0      &then
  define temp-table tt-param-pump no-undo
    field strfrfile as character
    field meaning   as character
    index pi        as primary   unique strfrfile.
&endif

&scop self-name tt-meas
&if ( lookup( '{&self-name}',  ''                   ) = 0      or
      lookup( '{&self-name}',  '*'                  ) = 0 )    and
      lookup( '{&self-name}', '^{&temp-table_list}' ) = 0      or
                               '{&temp-table_list}'   = 'rvs'  or
                               '{&temp-table_list}'   = 'file' or
      lookup( '{&self-name}',  '{&temp-table_list}' ) > 0      &then
  define temp-table tt-meas no-undo like ub.place
    field measure-qnty like ub.rvs-line.measure-qnty
    field brutto-qnty like ub.rvs-line.brutto-qnty
    field measure-cli-qnty like ub.rvs-line.measure-cli-qnty
    field brutto-cli-qnty like ub.rvs-line.brutto-cli-qnty
    field density like ub.rvs-line.density
    field temperature like ub.rvs-line.temperature
    field level-total like ub.rvs-line.level-total
    field level-petrol like ub.rvs-line.level-petrol
    field level-water like ub.rvs-line.level-water
    field temp-layer1 like ub.rvs-line.temp-layer1
    field temp-layer2 like ub.rvs-line.temp-layer2
    field temp-layer3 like ub.rvs-line.temp-layer3
    field measure-tc-qnty like ub.rvs-line.measure-tc-qnty
    field brutto-tc-qnty like ub.rvs-line.brutto-tc-qnty
    field meas-vol-oil   as logical initial no
    field meas-vol-water as logical initial no
    field water-qnty     like ub.rvs-line.measure-qnty
    field vapor-density like ub.rvs-line.density
    field vapor-pressure as decimal format ">>9.9<":U
    field log-brutto as logical
    field temp-not-null as logical
    field t1-not-null as logical
    field t2-not-null as logical
    field t3-not-null as logical
    field is-error    as logical
    index pi        as primary   loc1.
&endif

&scop self-name tt-meas-file
&if ( lookup( '{&self-name}',  ''                   ) = 0      or
      lookup( '{&self-name}',  '*'                  ) = 0 )    and
      lookup( '{&self-name}', '^{&temp-table_list}' ) = 0      or
                               '{&temp-table_list}'   = 'rvs'  or
                               '{&temp-table_list}'   = 'file' or
      lookup( '{&self-name}',  '{&temp-table_list}' ) > 0      &then
  define temp-table tt-meas-file no-undo like tt-meas.
&endif

&scop self-name tt-pump-nozzle
&if ( lookup( '{&self-name}',  ''                   ) = 0      or
      lookup( '{&self-name}',  '*'                  ) = 0 )    and
      lookup( '{&self-name}', '^{&temp-table_list}' ) = 0      or
                               '{&temp-table_list}'   = 'pump' or
                               '{&temp-table_list}'   = 'file' or
      lookup( '{&self-name}',  '{&temp-table_list}' ) > 0      &then
  define temp-table tt-pump-nozzle no-undo like ub.pump-nozzle
    field gds-code    like ub.goods.gds-code
    field meas-el-cnt like ub.rvs-line-pump.meas-el-cnt
    field meas-am-cnt like ub.rvs-line-pump.meas-am-cnt
    field grade       as   character
    field meas-cf-cnt like ub.rvs-line-pump.meas-cf-cnt.
&endif

&scop self-name tt-pump-nozzle-file
&if ( lookup( '{&self-name}',  ''                   ) = 0      or
      lookup( '{&self-name}',  '*'                  ) = 0 )    and
      lookup( '{&self-name}', '^{&temp-table_list}' ) = 0      or
                               '{&temp-table_list}'   = 'pump' or
                               '{&temp-table_list}'   = 'file' or
      lookup( '{&self-name}',  '{&temp-table_list}' ) > 0      &then
  define temp-table tt-pump-nozzle-file no-undo like tt-pump-nozzle.
&endif

/* $Workfile$   E n d */
