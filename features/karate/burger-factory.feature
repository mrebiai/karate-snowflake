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
    And string insertStatement = "INSERT INTO <table>(CLIENT_ID, VALUE) VALUES ('"+clientId+"','<value>')"
    And def callInserts = function(row) { return karate.runSql({ statement: insertStatement, snowflakeConfig: snowflakeConfig}).responseStatus }
    And def responses = karate.map(insertStatements, callInserts)
    And match responses contains only 200
    
    When def dbtResponse = karate.exec("dbt run ...")
    And match dbtResponse == "OK"

    Then string selectStatement = "SELECT VALUE FROM BURGER WHERE CLIENT_ID='"+clientId+"'" 
    And karate.runSql({ statement: selectStatement, snowflakeConfig: snowflakeConfigBurger })

    Examples:
      | bread | vegetable | meat | output       |
      | 🍞    | 🍅        | 🥩   | 🍔           |
      | 🍞    | 🍅        | 🍗   | 🍔           |
      | 🍞    | 🍅        | 🐟   | 🍔           |
      | 🍞    | 🥕        | 🥩   | 🍞 + 🥕 + 🥩 |
  