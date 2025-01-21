Feature: Demo
  Background:
    * json cliConfig = read('classpath:cli-config.json')
    * json snowflakeConfigs = read('classpath:snowflake-config-map.json')
    * string jwtToken = snowflake.cli.generateJwtToken(cliConfig)

  Scenario Outline: Burger Factory
    Given string clientId = common.uuid() 
    And table inserts
      | table     | value       |
      | BREAD     | <bread>     |
      | VEGETABLE | <vegetable> |
      | MEAT      | <meat>      |
    And string statement = "INSERT INTO "+row.table+"(CLIENT_ID, VALUE) VALUES ('"+clientId+"','"+row.value+"')"
    And json responses = karate.map(inserts, (row) => karate.rest.runSql({...cliConfig, jwtToken: jwtToken, snowflakeConfig: snowflakeConfigs[row.table], statement: statement}).status)
    And match responses contains only "OK"
    
    When def dbtResponse = karate.exec("dbt run ...")
    And match dbtResponse == "OK"

    Then string selectStatement = "SELECT VALUE FROM BURGER WHERE CLIENT_ID='"+clientId+"'" 
    And json response = karate.rest.runSql({ ..cliConfig, snowflakeConfig: snowflakeConfigBurger, statement: selectStatement })
    And match response.data == [ { "VALUE" : "<output>" } ]

    Examples:
      | bread | vegetable | meat | output       |
      | 🍞    | 🍅        | 🥩   | 🍔           |
      | 🍞    | 🍅        | 🍗   | 🍔           |
      | 🍞    | 🍅        | 🐟   | 🍔           |
      | 🍞    | 🥕        | 🥩   | 🍞 + 🥕 + 🥩 |
  