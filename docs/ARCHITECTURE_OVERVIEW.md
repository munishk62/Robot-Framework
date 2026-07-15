# Environment-Agnostic Test Automation Framework Overview

This document provides a comprehensive overview of our Robot Framework test automation architecture designed for environment-agnostic testing across multiple deployment environments.

## 🎯 Problem Statement

WFM has a complex configurations across environments (Customers, QA boxes). Traditional testing approaches require:
- Hard-coded environment values in tests
- Separate test data files per environment  
- Manual updates when configurations change
- Test metadata to know which test executes on what environment
- Test maintenance overhead

## 🚀 Our Solution

We've built an environment-agnostic framework that separates test logic from environment data using:
1. **Data Seeder Strategy** - Automatically fetches environment configs from DB
2. **Data Provider Strategy** - Injects environment-specific data into tests at runtime
3. **Config-Aware Execution** - Runs only tests applicable to current environment

---

## High-Level Architecture Overview

```mermaid
---
config:
      theme: redux
---
graph TB
    subgraph "Pre-Execution Phase"
        A[Data Seeder] -->|Connects| B[Environment]
        B -->|Creates| C[config.json & constants.json]
    end
    
    subgraph "Test Execution Phase"
        D[executor.py] --> E[ConfigFilter.py]
        E --> |Filters| F[Environment-Agnostic Tests]
        F --> |Uses| G[Data Providers]
        G -->  H[Test Results]
    end
    
    C --> D
    
    style A fill:#e1f5fe
    style D fill:#f3e5f5
    style F fill:#e8f5e9
    style G fill:#fff3e0
```

**Key Benefits:**
- ✅ Write tests once, run anywhere
- ✅ Zero environment-specific code in tests
- ✅ Automatic config synchronization
- ✅ Selective test execution based on environment capabilities

---

## Detailed Execution Process Flow

```mermaid
sequenceDiagram
    participant T as Tester/CI
    participant S as Data Seeder
    participant DB as Environment DB
    participant E as Executor
    participant CF as ConfigFilter
    participant RT as Robot Tests
    participant DP as Data Providers
    participant R as Results
    
    T->>S: 1. Run env sync for QA28
    S->>DB: 2. Query configs & constants
    DB->>S: 3. Return environment data
    S->>S: 4. Generate config.json & constants.json
    
    T->>E: 5. Execute tests with --test-env QA28
    E->>CF: 6. Apply config filter
    CF->>CF: 7. Select tests enabled for QA28
    CF->>RT: 8. Run filtered tests
    RT->>DP: 9. For each test request test data
    DP->>DP: 10. Resolve constants & configs
    DP->>RT: 11. Inject environment-specific data
    RT->>R: 12. Generate test results
```

---

## Component Architecture

```mermaid
graph TB
    subgraph "Data Management Layer"
        subgraph "Data Seeder (env_config_sync)"
            DS[Data Seeder CLI]
            MD[Metadata Definitions]
            DB[DB Providers]
        end
        
        subgraph "Environment Data"
            CF[config.json]
            CN[constants.json]
            DC[db_connections.json]
        end
    end
    
    subgraph "Test Execution Layer"
        subgraph "Executor & Filtering"
            EX[executor.py]
            CFG[ConfigFilter.py]
        end
        
        subgraph "Robot Framework"
            RT[Robot Test Cases]
            KW[Keywords]
        end
    end
    
    subgraph "Data Provider Layer"
        subgraph "Auto-Discovery Provider"
            AD[Generic Provider]
            TM[JSON Templates]
        end
        
        subgraph "Custom Providers"
            CP[Domain-Specific Providers]
            BL[Business Logic]
        end
    end
    
    DS --> CF
    DS --> CN
    MD --> DS
    DB --> DS
    
    EX --> CFG
    CFG --> RT
    RT --> AD
    RT --> CP
    
    AD --> TM
    CP --> BL
    
    CF --> EX
    CN --> AD
    CN --> CP
    
    style DS fill:#e0f7fa
    style EX fill:#e8f5e9
    style AD fill:#fff3e0
    style CP fill:#fce4ec
```

---

## 📋 Data Provider Strategy Details

```mermaid
flowchart LR
    subgraph "Template System"
        BT[Base Templates]
        TO[Test Overrides]
        DO[Direct Overrides]
    end
    
    subgraph "Processing Pipeline"
        LP[Load Templates]
        AO[Apply Overrides]
        RC[Resolve Constants]
        PD[Process Dates]
        ID[Inject Data]
    end
    
    subgraph "Data Sources"
        CJ[config.json]
        CSJ[constants.json]
        ENV[Environment Variables]
    end
    
    BT --> LP
    TO --> AO
    DO --> AO
    LP --> AO
    AO --> RC
    RC --> PD
    PD --> ID
    
    CJ --> RC
    CSJ --> RC
    ENV --> RC
    
    style BT fill:#e3f2fd
    style CJ fill:#e8f5e9
    style RC fill:#fff3e0
```

### Two Provider Approaches:

#### 1. Auto-Discovery Provider (Recommended for New Entities)
```mermaid
graph LR
    A[Create Folder] --> B[Add base_templates.json]
    B --> C[Optional: entity_config.json]
    C --> D[Auto-Generated Keywords]
    D --> E[Use in Tests]
    
    style A fill:#e8f5e9
    style D fill:#fff3e0
```

**Example:**
```
test_data/entities/schedule/
├── base_templates.json     # Required
├── entity_config.json      # Optional
└── overrides/              # Optional
```

#### 2. Domain-Specific Providers (For Complex Logic)
```mermaid
graph LR
    A[Create Provider Class] --> B[Extend BaseProvider]
    B --> C[Implement Logic]
    C --> D[Register Provider]
    D --> E[Create Keywords]
    
    style A fill:#fce4ec
    style C fill:#fff3e0
```

---

## 🔧 Configuration-Aware Test Execution

```mermaid
flowchart TD
    subgraph "Test Tagging Strategy"
        T1[Test Case 1<br/>Tags: config:holiday_hrs]
        T2[Test Case 2<br/>Tags: config:rta]
        T3[Test Case 3<br/>Tags: smoke]
    end
    
    subgraph "Environment Config"
        EC[config.json<br/>enabled_configs: holiday_hrs]
    end
    
    subgraph "ConfigFilter Processing"
        CF[ConfigFilter.py<br/>Pre-run Modifier]
    end
    
    subgraph "Test Selection"
        R1[✅ Test Case 1 - INCLUDED]
        R2[❌ Test Case 2 - SKIPPED]
        R3[✅ Test Case 3 - INCLUDED]
    end
    
    T1 --> CF
    T2 --> CF
    T3 --> CF
    EC --> CF
    CF --> R1
    CF --> R2
    CF --> R3
    
    style R1 fill:#c8e6c9
    style R2 fill:#ffcdd2
    style R3 fill:#c8e6c9
```

---

## 🛠️ Quick Start Guide

### For New Testers
We recommend going through details & [contribution](CONTRIBUTING.md)

#### 1. Get Environment Specific Data
```bash
# Add DB connection details
# Edit: test_data/environments/db_connections.json

# Run data seeder
python -m dev_utils.env_config_sync.cli --env NEW_ENV
```

#### 2. Add New Test Data Entity (Zero Code!)
```bash
# Create folder structure
mkdir test_data/entities/my_entity

# Add templates [Just a sample]
echo '{"default": {"field1": "value1"}}' > base_templates.json
```

#### 3. Use in Robot Tests
```robotframework
*** Test Cases ***
My Test
    ${data}=    Get My Entity Data    field1=custom_value
    # Use ${data} in your test
```

#### 4. Run Tests
```bash
python executor.py tests/web/ --test-env QA28
```

### For Complex Scenarios

#### Create Custom Provider
```python
class MyProvider(BaseDataProvider):
    def get_my_data(self, **overrides):
        # Custom business logic
        return processed_data
```

---


## 🔍 Troubleshooting

### Common Issues and Solutions

| Issue | Solution |
|-------|----------|
| Environment not found | Check `test_data/environments/{ENV_NAME}/` exists |
| Config not resolved | Run data seeder: `python -m dev_utils.env_config_sync.cli --env {ENV}` |
| Test skipped unexpectedly | Check `config.json` has required config in `enabled_configs` |
| Data provider not found | Verify template folder exists with `base_templates.json` |

### Debug Commands
```bash
# Check environment data
cat test_data/environments/QA28/config.json

# Dry run tests
python executor.py tests/web/ --test-env QA28 --dry-run

# Verbose data seeder
python -m dev_utils.env_config_sync.cli --env QA28 --verbose
```

---

## 🎯 Best Practices

1. **Environment Setup**
   - Always run data seeder before test execution
   - Keep DB credentials secure and use environment variables
   - Use meaningful environment names

2. **Test Data Management**
   - Prefer auto-discovery provider for simple entities
   - Use custom providers only for complex business logic
   - Keep templates simple and reusable
   - Use logical constants instead of hard-coded values

3. **Test Design**
   - Tag tests with required configurations
   - Write environment-agnostic test logic
   - Use descriptive template names
   - Document complex data transformations

4. **Maintenance**
   - Regularly sync environment configurations
   - Review and update templates as business logic changes
   - Monitor test execution logs for data-related issues

---
## Limitations

- Environment sync util only supports DB for now. API based support can be added but enabling API access of environments will require additional security measures & setup steps (enable authtoken)
- Environment specific locator is not supported. Engineering should be fixing these.
- No support for globalization keys sync. A test strategy for handling localization and internationalization is needed.

---

## Related Documentation

- [Data Provider Strategy](TEST_DATA_PROVIDER_STRATEGY.md)  
- [Simplified Provider Guide](SIMPLIFIED_DATA_PROVIDER_GUIDE.md)
- [Data Seeder Utility](TEST_DATA_SEEDER_UTILITY.md)
- [Config-Aware Execution](CONFIG_AWARE_TEST_EXECUTION.md)

---

*This framework enables true environment-agnostic testing by separating test logic from environment data, making it easy to scale across multiple environments while maintaining test consistency and reliability.*
