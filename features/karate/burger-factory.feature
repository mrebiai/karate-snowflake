Feature: Demo
  Background:
    * url baseUrl
    * def jwt = snowflake.generateJwtToken(snowflakeCliConfig)
    * configure headers = snowflake.requestHeaders(jwt, projectName)

  Scenario Outline: Burger Factory
    Given string clientId = common.uuid() 
    And table inserts
      | snowflakeConfig          | table     | value       |
      | snowflakeConfigBread     | BREAD     | <bread>     |
      | snowflakeConfigVegetable | VEGETABLE | <vegetable> |
      | snowflakeConfigMeat      | MEAT      | <meat>      |
    And def callInsert = function(row) { return karate.runSql({ statement: "INSERT INTO "+row.table+"(CLIENT_ID, VALUE) VALUES ('"+clientId+"','"+row.value+"')", snowflakeConfig: row.snowflakeConfig}).responseStatus }
    And def responses = karate.map(inserts, callInserts)
    And match responses contains only 200
    
    When def dbtResponse = karate.exec("dbt run ...")
    And match dbtResponse == "OK"

    Then string selectStatement = "SELECT VALUE FROM BURGER WHERE CLIENT_ID='"+clientId+"'" 
    And def response = karate.runSql({ statement: selectStatement, snowflakeConfig: snowflakeConfigBurger })
    And match response.data == [ { "VALUE" : "<output>" } ]

    Examples:
      | bread | vegetable | meat | output       |
      | 🍞    | 🍅        | 🥩   | 🍔           |
      | 🍞    | 🍅        | 🍗   | 🍔           |
      | 🍞    | 🍅        | 🐟   | 🍔           |
      | 🍞    | 🥕        | 🥩   | 🍞 + 🥕 + 🥩 |
  