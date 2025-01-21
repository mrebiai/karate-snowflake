Feature: SELECT V1
  Background:
    * url "https://<SNOWFLAKE_ACCOUNT>.snowflakecomputing.com/api/v2"
    * string jwtToken = karate.exec("snow connection generate-jwt --silent --account <SNOWFLAKE_ACCOUNT> --user <SNOWFLAKE_USER> --private-key-file <SNOWFLAKE_USER_PEM>")
    * header Content-Type = "application/json"
    * header Accept = "application/json"
    * header Authorization = "Bearer " + jwtToken
    * header User-Agent = "<MY_APP_IT>"
    * header X-Snowflake-Authorization-Token-Type = "KEYPAIR_JWT"

  Scenario: Select 1 cutter
    Given path "statements"
    And text payload =
        """
        {
          "statement": "SELECT SERIAL_NUMBER, CUTTER_TYPE FROM CUTTER WHERE SERIAL_NUMBER='MY_VECTOR'",
          "timeout": 60,
          "role": "<SNOWFLAKE_ROLE>",
          "warehouse": "<SNOWFLAKE_WAREHOUSE>",
          "database": "<SNOWFLAKE_DATABASE>",
          "schema": "<SNOWFLAKE_SCHEMA>"
        }
        """
    When request payload
    And method post
    Then status 200
    And match response.resultSetMetaData.numRows == 1
    And match response.resultSetMetaData.rowType[0].name == "SERIAL_NUMBER"
    And match response.resultSetMetaData.rowType[1].name == "CUTTER_TYPE"
    And match response.data[0][0] == "MY_VECTOR"
    And match response.data[0][1] == "VECTOR"
    