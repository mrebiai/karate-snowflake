Feature: SELECT V2
  Background:
    * json cliConfig = read('classpath:cli-config.json')
    * json snowflakeConfig = read('classpath:snowflake-config.json')
    * string jwtToken = snowflake.cli.generateJwtToken(cliConfig)
    * json restConfig = ({jwtToken, cliConfig, snowflakeConfig})

  Scenario: Select 1 cutter
    Given text statement =
    """
      SELECT SERIAL_NUMBER, CUTTER_TYPE
      FROM CUTTER
      WHERE SERIAL_NUMBER='MY_VECTOR'
    """
    And def response = snowflake.rest.runSql({...restConfig, statement})
    And table expectedData
      | SERIAL_NUMBER | CUTTER_TYPE |
      | "MY_VECTOR"   | "VECTOR"    |
    And match response.data == expectedData
  