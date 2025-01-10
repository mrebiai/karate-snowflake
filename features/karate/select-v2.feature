Feature: SELECT
  Background:
    * url baseUrl
    * def jwt = snowflake.generateJwtToken(snowflakeCliConfig)
    * configure headers = snowflake.requestHeaders(jwt, projectName)
  Scenario: Select 1 cutter
    Given string statement = "SELECT SERIAL_NUMBER, CUTTER_TYPE FROM CUTTER WHERE SERIAL_NUMBER='MY_VECTOR'"
    And def response = snowflake.runSql({statement: statement, snowflakeConfig: snowflakeConfig})
    And table expectedData
      | SERIAL_NUMBER | CUTTER_TYPE |
      | "MY_VECTOR"   | "VECTOR"    |
    And match response.data == expectedData
  