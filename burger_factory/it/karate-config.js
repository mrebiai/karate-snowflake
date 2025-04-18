function fn() {


    const snowflakeConfig = snowflake.snowflakeConfigFromEnv;
    const sourceSchema = java.lang.System.getenv("SNOWFLAKE_SCHEMA_SOURCE");
    const schema = java.lang.System.getenv("SNOWFLAKE_SCHEMA");
    const snowflakeConfigSource = {...snowflake.snowflakeConfigFromEnv, schema: sourceSchema};
    const genSnowflakeConfigs = (postfix) => {
        const toAdd = postfix !== undefined ? "_"+postfix : "";
        return { 
        "BREAD": {...snowflakeConfigSource, schema: snowflakeConfigSource.schema+toAdd},
        "VEGETABLE": {...snowflakeConfigSource, schema: snowflakeConfigSource.schema+toAdd},
        "MEAT": {...snowflakeConfigSource, schema: snowflakeConfigSource.schema+toAdd},
        "BURGER": {...snowflakeConfig, schema: snowflakeConfig.schema+toAdd}
        };
    };

    const cloneSnowflakeConfigs = (restConfig) => {
        const postfix = base.random.uuid().toUpperCase().replaceAll("-","_");
        const clone1 = snowflake.rest.cloneSchema({...restConfig, "schemaToClone": snowflakeConfigSource.schema, "schemaToCreate": snowflakeConfigSource.schema+"_"+postfix}).status;
        const clone2 = snowflake.rest.cloneSchema({...restConfig, "schemaToClone": snowflakeConfig.schema, "schemaToCreate": snowflakeConfig.schema+"_"+postfix}).status;
        if (clone1 !== "OK" || clone2 !== "OK") {
            karate.fail("cloneSnowflakeConfigs failed");
        }
        return { snowflakeConfigs: genSnowflakeConfigs(postfix), env: { "SNOWFLAKE_SCHEMA_SOURCE": sourceSchema+"_"+postfix, "SNOWFLAKE_SCHEMA": schema+"_"+postfix}};
    };

    const dropSnowflakeConfigs = (restConfig, snowflakeConfigs) => {
        const dropResults = karate.map(Object.keys(snowflakeConfigs), (key) => snowflake.rest.dropSchema({...restConfig, "schemaToDrop": snowflakeConfigs[key].schema}).status);
        if (dropResults.some(result => result.status !== "OK")) {
            karate.fail("dropSnowflakeConfigs failed");
        }
    };
    
    return {
        "projectName": "burger_factory",
        "snowflakeConfigs": genSnowflakeConfigs(),
        "cloneSnowflakeConfigs": cloneSnowflakeConfigs,
        "dropSnowflakeConfigs": dropSnowflakeConfigs
    }
}