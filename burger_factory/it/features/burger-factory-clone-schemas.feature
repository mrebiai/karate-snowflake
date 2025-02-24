Feature: Demo - Clone Schemas
  Background:
    * json cliConfig = snowflake.cliConfigFromEnv
    * string jwt = snowflake.cli.generateJwt(cliConfig)
    * json restConfig = ({jwt, cliConfig, snowflakeConfig: snowflakeConfigs.BREAD})
    * string clientId = "😋_"+base.random.uuid()
    * def genStatement = (table, value) => "INSERT INTO "+table+"(CLIENT_ID, VALUE) VALUES ('"+clientId+"','"+value+"')"
    * json cloneResult = cloneSnowflakeConfigs(restConfig)
    * configure afterScenario = function(){ dropSnowflakeConfigs(restConfig, cloneResult.snowflakeConfigs) }

  Scenario Outline: Burger Factory - <bread> + <vegetable> + <meat> = <output>
    Given table inserts
      | table       | value         | config                                 |
      | "BREAD"     | "<bread>"     | cloneResult.snowflakeConfigs.BREAD     |
      | "VEGETABLE" | "<vegetable>" | cloneResult.snowflakeConfigs.VEGETABLE |
      | "MEAT"      | "<meat>"      | cloneResult.snowflakeConfigs.MEAT      |
    And json responses = karate.map(inserts, (row) => snowflake.rest.runSql({...restConfig, snowflakeConfig: row.config, statement: genStatement(row.table, row.value)}).status)
    And match each responses == "OK"

    * string cmd = cloneResult.dbtPrefix+" dbt run"
    When string dbtConsoleOutput = karate.exec("bash -c '"+cmd+"'")
    And match dbtConsoleOutput contains "Completed successfully"

    Then string selectStatement = "SELECT VALUE FROM BURGER WHERE CLIENT_ID='"+clientId+"'"
    And json response = snowflake.rest.runSql({...restConfig, snowflakeConfig: cloneResult.snowflakeConfigs.BURGER, statement: selectStatement })
    And match response.data == [ { "VALUE" : "<output>" } ]

    Examples:
      | bread | vegetable | meat | output       |
      | 🍞    | 🍅        | 🥩   | 🍔           |
      | 🍞    | 🍅        | 🍗   | 🍔           |
      | 🍞    | 🍅        | 🐟   | 🍔           |
      | 🍞    | 🥕        | 🥩   | 🍞 + 🥕 + 🥩 |
