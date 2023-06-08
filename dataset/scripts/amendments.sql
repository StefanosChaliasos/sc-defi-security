CREATE TABLE RetroAnalysis (
    analysis_id             INTEGER PRIMARY KEY,
    vulnerable_contract_id  INTEGER NOT NULL,
    tool                    TEXT NOT NULL,
    is_bytecode             BOOLEAN NOT NULL,
    error                   BOOLEAN NOT NULL,
    total_findings          INTEGER NOT NULL,
    FOREIGN KEY (vulnerable_contract_id) REFERENCES VulnerableContract (vulnerable_contract_id)
);

CREATE Table RetroFindings (
    finding_id              INTEGER PRIMARY KEY,
    analysis_id             INTEGER NOT NULL,
    vulnerability_type_id   INTEGER NOT NULL,
    occurences              INTEGER NOT NULL,
    FOREIGN KEY (analysis_id) REFERENCES RetroAnalysis (analysis_id)
    FOREIGN KEY (vulnerability_type_id) REFERENCES SmartContractVulnerabilities (vulnerability_type_id)
);

CREATE Table SmartContractVulnerabilities (
    vulnerability_type_id   INTEGER PRIMARY KEY,
    vulnerability_type      TEXT NOT NULL,
    vuln_map_id             INTEGER NOT NULL,
    FOREIGN KEY (vuln_map_id) REFERENCES VulnerabilitiesMap (vuln_map_id)
);

CREATE Table VulnerabilitiesMap (
    vuln_map_id             INTEGER PRIMARY KEY,
    vuln_title              TEXT,
    category                TEXT
);

CREATE Table Tool (
    tool_id                 INTEGER PRIMARY KEY,
    tool_name               TEXT NOT NULL
);

CREATE Table ToolsVulnerabilities (
    tool_vuln_id            INTEGER PRIMARY KEY,
    tool_id                 INTEGER NOT NULL,
    vuln_map_id             INTEGER NOT NULL,
    FOREIGN KEY (tool_id) REFERENCES Tool (tool_id),
    FOREIGN KEY (vuln_map_id) REFERENCES VulnerabilitiesMap (vuln_map_id)
);

/* Add extra fields */
ALTER TABLE VulnerableContract ADD COLUMN is_proxy BOOLEAN DEFAULT 0;
ALTER TABLE VulnerableContract ADD COLUMN is_vyper BOOLEAN DEFAULT 0;
ALTER TABLE VulnerableContract ADD COLUMN has_source BOOLEAN DEFAULT 0;

/* Connect Cause table to VulnerabilitiesMap */
ALTER TABLE Cause ADD COLUMN vuln_map_id INTEGER REFERENCES VulnerabilitiesMap (vuln_map_id);


.mode csv
.import data/vuln_map.csv VulnerabilitiesMap
.import data/tools.csv Tool
