-- Diagnostic Queries for Agentic Systems
-- Run these queries to quickly assess system health
-- Adjust table/column names to match your schema

-- ============================================
-- SECTION 1: IMMEDIATE HEALTH CHECK (5 min)
-- ============================================

-- 1.1 Cost per outcome trend (last 7 days)
-- HEALTHY: Stable or declining
-- WARNING: Rising >10% week over week
-- CRITICAL: Rising >20% week over week

SELECT
    DATE_TRUNC('day', created_at) as day,
    COUNT(*) as total_requests,
    COUNT(DISTINCT CASE WHEN state = 'committed' THEN result_id END) as successful_outputs,
    SUM(cost_usd) as total_cost,
    SUM(cost_usd) / NULLIF(COUNT(DISTINCT CASE WHEN state = 'committed' THEN result_id END), 0) as cost_per_outcome
FROM inference_events
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY 1
ORDER BY 1;


-- 1.2 Hidden recompute ratio (last 7 days)
-- HEALTHY: <20%
-- WARNING: 20-40%
-- CRITICAL: >40%

SELECT
    DATE_TRUNC('day', created_at) as day,
    COUNT(*) as total,
    SUM(CASE WHEN trigger_type IN ('undo', 'retry', 'auto_save', 'system') THEN 1 ELSE 0 END) as hidden,
    ROUND(
        100.0 * SUM(CASE WHEN trigger_type IN ('undo', 'retry', 'auto_save', 'system') THEN 1 ELSE 0 END) / COUNT(*),
        1
    ) as hidden_ratio_pct
FROM inference_events
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY 1
ORDER BY 1;


-- 1.3 Missing decision records (last 24 hours)
-- HEALTHY: <5%
-- WARNING: 5-20%
-- CRITICAL: >20%

SELECT
    COUNT(*) as total_outputs,
    SUM(CASE WHEN trace_id IS NULL OR model_version IS NULL THEN 1 ELSE 0 END) as missing_provenance,
    ROUND(
        100.0 * SUM(CASE WHEN trace_id IS NULL OR model_version IS NULL THEN 1 ELSE 0 END) / COUNT(*),
        1
    ) as missing_pct
FROM inference_events
WHERE created_at > NOW() - INTERVAL '24 hours';


-- ============================================
-- SECTION 2: COST BREAKDOWN (10 min)
-- ============================================

-- 2.1 Cost by trigger type
-- Look for: undo, retry, auto_save dominating costs

SELECT
    trigger_type,
    COUNT(*) as count,
    SUM(cost_usd) as total_cost,
    ROUND(100.0 * SUM(cost_usd) / SUM(SUM(cost_usd)) OVER (), 1) as cost_pct,
    AVG(cost_usd) as avg_cost
FROM inference_events
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY 1
ORDER BY total_cost DESC;


-- 2.2 Cost by feature
-- Look for: One feature dominating costs unexpectedly

SELECT
    feature,
    COUNT(*) as requests,
    SUM(cost_usd) as total_cost,
    ROUND(100.0 * SUM(cost_usd) / SUM(SUM(cost_usd)) OVER (), 1) as cost_pct,
    SUM(cost_usd) / NULLIF(COUNT(DISTINCT CASE WHEN state = 'committed' THEN result_id END), 0) as cost_per_outcome
FROM inference_events
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY 1
ORDER BY total_cost DESC;


-- 2.3 Cost by user (top 20)
-- Look for: Single users driving disproportionate costs

SELECT
    user_id,
    COUNT(*) as requests,
    SUM(cost_usd) as total_cost,
    AVG(cost_usd) as avg_cost,
    MAX(cost_usd) as max_single_request
FROM inference_events
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY 1
ORDER BY total_cost DESC
LIMIT 20;


-- ============================================
-- SECTION 3: TOOL RELIABILITY (5 min)
-- ============================================

-- 3.1 Tool success rates
-- HEALTHY: >98%
-- WARNING: 95-98%
-- CRITICAL: <95%

SELECT
    tool_name,
    COUNT(*) as total_calls,
    SUM(CASE WHEN success = true THEN 1 ELSE 0 END) as successful,
    ROUND(100.0 * SUM(CASE WHEN success = true THEN 1 ELSE 0 END) / COUNT(*), 1) as success_rate_pct,
    AVG(latency_ms) as avg_latency_ms,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY latency_ms) as p95_latency_ms
FROM tool_calls
WHERE created_at > NOW() - INTERVAL '24 hours'
GROUP BY 1
ORDER BY success_rate_pct ASC;


-- 3.2 Retry rates by tool
-- Look for: High retry counts indicating flaky dependencies

SELECT
    tool_name,
    COUNT(*) as total_calls,
    AVG(retries) as avg_retries,
    MAX(retries) as max_retries,
    SUM(CASE WHEN retries > 0 THEN 1 ELSE 0 END) as calls_with_retries,
    ROUND(100.0 * SUM(CASE WHEN retries > 0 THEN 1 ELSE 0 END) / COUNT(*), 1) as retry_rate_pct
FROM tool_calls
WHERE created_at > NOW() - INTERVAL '24 hours'
GROUP BY 1
ORDER BY avg_retries DESC;


-- ============================================
-- SECTION 4: LATENCY (5 min)
-- ============================================

-- 4.1 Latency percentiles by endpoint
-- Track p50, p95, p99 for user-facing endpoints

SELECT
    endpoint,
    COUNT(*) as requests,
    ROUND(AVG(latency_ms)) as avg_ms,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY latency_ms)) as p50_ms,
    ROUND(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY latency_ms)) as p95_ms,
    ROUND(PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY latency_ms)) as p99_ms
FROM inference_events
WHERE created_at > NOW() - INTERVAL '24 hours'
GROUP BY 1
ORDER BY p95_ms DESC;


-- 4.2 Latency trend (hourly)
-- Look for: Degradation over time, spikes at specific hours

SELECT
    DATE_TRUNC('hour', created_at) as hour,
    COUNT(*) as requests,
    ROUND(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY latency_ms)) as p95_ms
FROM inference_events
WHERE created_at > NOW() - INTERVAL '48 hours'
GROUP BY 1
ORDER BY 1;


-- ============================================
-- SECTION 5: TOKEN USAGE (5 min)
-- ============================================

-- 5.1 Token usage trend
-- Look for: Rising input tokens (context bloat)

SELECT
    DATE_TRUNC('day', created_at) as day,
    AVG(input_tokens) as avg_input,
    AVG(output_tokens) as avg_output,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY input_tokens) as p95_input,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY output_tokens) as p95_output
FROM inference_events
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY 1
ORDER BY 1;


-- 5.2 Token usage by model version
-- Compare efficiency across model versions

SELECT
    model_version,
    COUNT(*) as requests,
    AVG(input_tokens) as avg_input,
    AVG(output_tokens) as avg_output,
    AVG(cost_usd) as avg_cost
FROM inference_events
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY 1
ORDER BY requests DESC;


-- ============================================
-- SECTION 6: QUICK HEALTH SUMMARY
-- ============================================

-- Run this for a one-line health check

SELECT
    -- Cost health
    CASE 
        WHEN (
            SELECT SUM(cost_usd) / NULLIF(COUNT(DISTINCT CASE WHEN state = 'committed' THEN result_id END), 0)
            FROM inference_events WHERE created_at > NOW() - INTERVAL '1 day'
        ) > 1.2 * (
            SELECT SUM(cost_usd) / NULLIF(COUNT(DISTINCT CASE WHEN state = 'committed' THEN result_id END), 0)
            FROM inference_events WHERE created_at BETWEEN NOW() - INTERVAL '8 days' AND NOW() - INTERVAL '7 days'
        )
        THEN 'CRITICAL'
        WHEN (
            SELECT SUM(cost_usd) / NULLIF(COUNT(DISTINCT CASE WHEN state = 'committed' THEN result_id END), 0)
            FROM inference_events WHERE created_at > NOW() - INTERVAL '1 day'
        ) > 1.1 * (
            SELECT SUM(cost_usd) / NULLIF(COUNT(DISTINCT CASE WHEN state = 'committed' THEN result_id END), 0)
            FROM inference_events WHERE created_at BETWEEN NOW() - INTERVAL '8 days' AND NOW() - INTERVAL '7 days'
        )
        THEN 'WARNING'
        ELSE 'HEALTHY'
    END as cost_status,
    
    -- Recompute health
    CASE
        WHEN (
            SELECT 100.0 * SUM(CASE WHEN trigger_type IN ('undo', 'retry', 'auto_save') THEN 1 ELSE 0 END) / COUNT(*)
            FROM inference_events WHERE created_at > NOW() - INTERVAL '1 day'
        ) > 40 THEN 'CRITICAL'
        WHEN (
            SELECT 100.0 * SUM(CASE WHEN trigger_type IN ('undo', 'retry', 'auto_save') THEN 1 ELSE 0 END) / COUNT(*)
            FROM inference_events WHERE created_at > NOW() - INTERVAL '1 day'
        ) > 20 THEN 'WARNING'
        ELSE 'HEALTHY'
    END as recompute_status,
    
    -- Current timestamp for reference
    NOW() as checked_at;
