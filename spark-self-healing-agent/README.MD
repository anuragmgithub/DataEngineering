## autonomous agent that:
- Reads Spark job failures from event logs
- Diagnoses root cause
- Applies safe configuration changes
- Retries jobs automatically
- Learns from outcomes
- Escalates when unsafe

❌ No code changes  
❌ No cluster autoscaling  
❌ No business logic inference  
❌ No unlimited retries  

```
spark-self-healing-agent/
├── agent/
├── parser/
├── classifier/
├── rules/
├── llm/
├── policy/
├── retry/
├── memory/
├── observability/
└── main.py
```

### How Spark + Airflow + Agent Work Together:  

Airflow DAG  
   ↓  
spark-submit  
   ↓  
Spark job fails  
   ↓  
Event logs written  
   ↓  
AI agent parses logs  
   ↓  
Agent proposes config change  
   ↓  
Airflow retries job with new config  

```
Rules Engine (80%)  
   ↓  
Heuristics & History (15%)  
   ↓  
LLM Reasoning (5%)  
```  

