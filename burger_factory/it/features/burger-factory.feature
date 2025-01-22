Feature: Demo
  Background:
    * json cliConfig = snowflake.cliConfigFromEnv
    * string jwtToken = snowflake.cli.generateJwtToken(cliConfig)
    * json restConfig = ({...cliConfig, jwtToken: jwtToken}) 
    * string clientId = "😋_"+lectra.uuid()
    * def genStatement = (table, value) => "INSERT INTO "+table+"(CLIENT_ID, VALUE) VALUES ('"+clientId+"','"+value+"')"

  Scenario Outline: Burger Factory - <bread> + <vegetable> + <meat> = <output>
    Given table inserts
      | table       | value         | config                     |
      | "BREAD"     | "<bread>"     | snowflakeConfigs.BREAD     |
      | "VEGETABLE" | "<vegetable>" | snowflakeConfigs.VEGETABLE |
      | "MEAT"      | "<meat>"      | snowflakeConfigs.MEAT      |
    And json responses = karate.map(inserts, (row) => snowflake.rest.runSql({...restConfig, snowflakeConfig: row.config, statement: genStatement(row.table, row.value)}).status)
    And match each responses == "OK"

    When string dbtConsoleOutput = karate.exec("dbt run")
    And match dbtConsoleOutput contains "Completed successfully"

    Then string selectStatement = "SELECT VALUE FROM BURGER WHERE CLIENT_ID='"+clientId+"'"
    And json response = snowflake.rest.runSql({...restConfig, snowflakeConfig: snowflakeConfigs.BURGER, statement: selectStatement })
    And match response.data == [ { "VALUE" : "<output>" } ]

    Examples:
      | bread | vegetable | meat | output       |
      | 🍞    | 🍅        | 🥩   | 🍔           |
      | 🍞    | 🍅        | 🍗   | 🍔           |
      | 🍞    | 🍅        | 🐟   | 🍔           |
      | 🍞    | 🥕        | 🥩   | 🍞 + 🥕 + 🥩 |
