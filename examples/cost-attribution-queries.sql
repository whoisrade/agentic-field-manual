-- =============================================================================
-- Cost Attribution Queries for AI Systems
-- =============================================================================
--
-- These queries help you answer: "Where is our inference spend going?"
--
-- They assume a usage tracking table. Adapt the schema to your setup.
--
-- Key insight: Track cost per SUCCESSFUL OUTCOME, not cost per request.
-- A request that requires 3 retries costs 3x but produces 1 outcome.
--
-- =============================================================================


-- =============================================================================
-- SCHEMA (for reference)
-- =============================================================================

-- Assumes you have a table like this:
/*
CREATE TABLE ai_usage (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trace_id UUID NOT NULL,
    tenant_id VARCHAR(255) NOT NULL,
    user_id VARCHAR(255) NOT NULL,

    -- What happened
    request_type VARCHAR(50) NOT NULL,      -- 'chat', 'completion', 'embedding', 'agent'
    feature VARCHAR(100) NOT NULL,          -- 'document_qa', 'code_review', 'search', etc.
    model VARCHAR(100) NOT NULL,            -- 'gpt-4o', 'claude-3-opus', etc.

    -- Cost tracking
    input_tokens INT NOT NULL,
    output_tokens INT NOT NULL,
    cost_usd DECIMAL(10, 6) NOT NULL,

    -- Outcome tracking
    is_successful BOOLEAN NOT NULL,         -- Did this produce a usable result?
    is_retry BOOLEAN DEFAULT FALSE,         -- Was this a retry of a previous request?
    retry_count INT DEFAULT 0,

    -- Context
    trigger_type VARCHAR(50),               -- 'user_action', 'auto_save', 'regenerate', 'undo'
    session_id UUID,

    -- Timing
    latency_ms INT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for the queries below
CREATE INDEX idx_usage_tenant_date ON ai_usage (tenant_id, created_at);
CREATE INDEX idx_usage_feature_date ON ai_usage (feature, created_at);
CREATE INDEX idx_usage_trigger_date ON ai_usage (trigger_type, created_at);
CREATE INDEX idx_usage_trace ON ai_usage (trace_id);
*/


-- =============================================================================
-- 1. COST PER SUCCESSFUL OUTCOME BY FEATURE
-- =============================================================================
--
-- This is the most important metric. It tells you the TRUE cost of each feature,
-- including all retries and failed attempts.
--

WITH outcome_costs AS (
    SELECT
        feature,
        trace_id,
        SUM(cost_usd) as total_cost,
        MAX(is_successful::int) as had_success,
        COUNT(*) as request_count
    FROM ai_usage
    WHERE created_at >= NOW() - INTERVAL '7 days'
    GROUP BY feature, trace_id
)
SELECT
    feature,
    COUNT(DISTINCT trace_id) as total_outcomes,
    SUM(CASE WHEN had_success = 1 THEN 1 ELSE 0 END) as successful_outcomes,
    ROUND(AVG(CASE WHEN had_success = 1 THEN total_cost END)::numeric, 4) as avg_cost_per_success,
    ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY total_cost)::numeric, 4) as p50_cost,
    ROUND(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY total_cost)::numeric, 4) as p95_cost,
    ROUND(AVG(request_count)::numeric, 2) as avg_requests_per_outcome,
    SUM(total_cost) as total_spend
FROM outcome_costs
GROUP BY feature
ORDER BY total_spend DESC;


-- =============================================================================
-- 2. HIDDEN RECOMPUTE: COST BY TRIGGER TYPE
-- =============================================================================
--
-- This reveals the "free" buttons that are eating your margin.
-- A high-cost "undo" or "regenerate" trigger is a control surface problem.
--

SELECT
    trigger_type,
    COUNT(*) as request_count,
    SUM(cost_usd) as total_cost,
    ROUND(AVG(cost_usd)::numeric, 4) as avg_cost_per_request,
    ROUND(100.0 * SUM(cost_usd) / SUM(SUM(cost_usd)) OVER ()::numeric, 1) as pct_of_total_cost,
    SUM(CASE WHEN is_retry THEN 1 ELSE 0 END) as retry_count,
    ROUND(100.0 * SUM(CASE WHEN is_retry THEN 1 ELSE 0 END) / COUNT(*)::numeric, 1) as retry_rate
FROM ai_usage
WHERE created_at >= NOW() - INTERVAL '7 days'
GROUP BY trigger_type
ORDER BY total_cost DESC;


-- =============================================================================
-- 3. COST TREND: DAILY SPEND BY MODEL
-- =============================================================================
--
-- Watch for cost drift. If costs are rising faster than usage, you have a problem.
--

SELECT
    DATE(created_at) as date,
    model,
    COUNT(*) as request_count,
    SUM(input_tokens) as total_input_tokens,
    SUM(output_tokens) as total_output_tokens,
    SUM(cost_usd) as total_cost,
    ROUND(AVG(cost_usd)::numeric, 4) as avg_cost_per_request,
    ROUND(AVG(latency_ms)::numeric, 0) as avg_latency_ms
FROM ai_usage
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY DATE(created_at), model
ORDER BY date DESC, total_cost DESC;


-- =============================================================================
-- 4. TENANT COST BREAKDOWN (for multi-tenant SaaS)
-- =============================================================================
--
-- Essential for understanding unit economics per customer.
-- Gross margin = Revenue - (Infrastructure + AI Costs)
--

SELECT
    tenant_id,
    COUNT(DISTINCT user_id) as active_users,
    COUNT(*) as total_requests,
    SUM(CASE WHEN is_successful THEN 1 ELSE 0 END) as successful_requests,
    SUM(cost_usd) as total_cost,
    ROUND(SUM(cost_usd) / NULLIF(COUNT(DISTINCT user_id), 0)::numeric, 2) as cost_per_user,
    ROUND(SUM(cost_usd) / NULLIF(SUM(CASE WHEN is_successful THEN 1 ELSE 0 END), 0)::numeric, 4) as cost_per_success
FROM ai_usage
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY tenant_id
ORDER BY total_cost DESC
LIMIT 100;


-- =============================================================================
-- 5. RETRY ANALYSIS: WHERE ARE RETRIES HAPPENING?
-- =============================================================================
--
-- High retry rates indicate reliability problems.
-- Retries cost money AND hurt latency.
--

SELECT
    feature,
    model,
    COUNT(*) as total_requests,
    SUM(CASE WHEN is_retry THEN 1 ELSE 0 END) as retry_requests,
    ROUND(100.0 * SUM(CASE WHEN is_retry THEN 1 ELSE 0 END) / COUNT(*)::numeric, 1) as retry_rate,
    ROUND(AVG(retry_count)::numeric, 2) as avg_retries_when_retrying,
    SUM(CASE WHEN is_retry THEN cost_usd ELSE 0 END) as retry_cost,
    ROUND(100.0 * SUM(CASE WHEN is_retry THEN cost_usd ELSE 0 END) / NULLIF(SUM(cost_usd), 0)::numeric, 1) as pct_cost_from_retries
FROM ai_usage
WHERE created_at >= NOW() - INTERVAL '7 days'
GROUP BY feature, model
HAVING COUNT(*) > 100  -- Only features with enough volume
ORDER BY retry_rate DESC;


-- =============================================================================
-- 6. MARGIN FRAGILITY: COST AT SCALE PROJECTION
-- =============================================================================
--
-- Project what happens to costs at 10x volume.
-- If cost per outcome increases with volume, you have fragility.
--

WITH daily_stats AS (
    SELECT
        DATE(created_at) as date,
        COUNT(DISTINCT trace_id) as outcomes,
        SUM(cost_usd) as total_cost,
        SUM(cost_usd) / NULLIF(COUNT(DISTINCT trace_id), 0) as cost_per_outcome
    FROM ai_usage
    WHERE created_at >= NOW() - INTERVAL '30 days'
    GROUP BY DATE(created_at)
)
SELECT
    -- Current state
    ROUND(AVG(outcomes)::numeric, 0) as avg_daily_outcomes,
    ROUND(AVG(total_cost)::numeric, 2) as avg_daily_cost,
    ROUND(AVG(cost_per_outcome)::numeric, 4) as avg_cost_per_outcome,

    -- Trend (is cost per outcome increasing?)
    CORR(EXTRACT(EPOCH FROM date::timestamp), cost_per_outcome) as cost_trend_correlation,

    -- Projection at 10x
    ROUND(AVG(outcomes)::numeric * 10, 0) as projected_10x_outcomes,
    ROUND(AVG(total_cost)::numeric * 10, 2) as projected_10x_cost_linear,

    -- Warning flags
    CASE
        WHEN CORR(EXTRACT(EPOCH FROM date::timestamp), cost_per_outcome) > 0.3
        THEN 'WARNING: Cost per outcome trending UP'
        WHEN CORR(EXTRACT(EPOCH FROM date::timestamp), cost_per_outcome) < -0.3
        THEN 'GOOD: Cost per outcome trending DOWN'
        ELSE 'STABLE: Cost per outcome relatively flat'
    END as cost_trend_assessment
FROM daily_stats;


-- =============================================================================
-- 7. SESSION ANALYSIS: COST PER USER SESSION
-- =============================================================================
--
-- How much does it cost to serve a single user session?
-- Critical for understanding product economics.
--

SELECT
    session_id,
    tenant_id,
    user_id,
    MIN(created_at) as session_start,
    MAX(created_at) as session_end,
    EXTRACT(EPOCH FROM (MAX(created_at) - MIN(created_at))) / 60 as session_duration_minutes,
    COUNT(*) as request_count,
    SUM(cost_usd) as session_cost,
    COUNT(DISTINCT feature) as features_used,
    SUM(CASE WHEN trigger_type = 'regenerate' THEN 1 ELSE 0 END) as regenerate_count,
    SUM(CASE WHEN trigger_type = 'undo' THEN 1 ELSE 0 END) as undo_count
FROM ai_usage
WHERE created_at >= NOW() - INTERVAL '7 days'
  AND session_id IS NOT NULL
GROUP BY session_id, tenant_id, user_id
ORDER BY session_cost DESC
LIMIT 100;


-- =============================================================================
-- 8. ANOMALY DETECTION: UNUSUAL COST PATTERNS
-- =============================================================================
--
-- Find users or tenants with abnormal cost patterns.
-- Could indicate abuse, bugs, or inefficient usage patterns.
--

WITH user_stats AS (
    SELECT
        user_id,
        tenant_id,
        COUNT(*) as request_count,
        SUM(cost_usd) as total_cost,
        AVG(cost_usd) as avg_cost
    FROM ai_usage
    WHERE created_at >= NOW() - INTERVAL '24 hours'
    GROUP BY user_id, tenant_id
),
thresholds AS (
    SELECT
        AVG(total_cost) as avg_cost,
        STDDEV(total_cost) as stddev_cost,
        AVG(request_count) as avg_requests,
        STDDEV(request_count) as stddev_requests
    FROM user_stats
)
SELECT
    u.user_id,
    u.tenant_id,
    u.request_count,
    u.total_cost,
    ROUND((u.total_cost - t.avg_cost) / NULLIF(t.stddev_cost, 0)::numeric, 2) as cost_z_score,
    ROUND((u.request_count - t.avg_requests) / NULLIF(t.stddev_requests, 0)::numeric, 2) as request_z_score,
    CASE
        WHEN (u.total_cost - t.avg_cost) / NULLIF(t.stddev_cost, 0) > 3 THEN 'HIGH COST ANOMALY'
        WHEN (u.request_count - t.avg_requests) / NULLIF(t.stddev_requests, 0) > 3 THEN 'HIGH VOLUME ANOMALY'
        ELSE 'NORMAL'
    END as anomaly_type
FROM user_stats u
CROSS JOIN thresholds t
WHERE (u.total_cost - t.avg_cost) / NULLIF(t.stddev_cost, 0) > 2
   OR (u.request_count - t.avg_requests) / NULLIF(t.stddev_requests, 0) > 2
ORDER BY (u.total_cost - t.avg_cost) / NULLIF(t.stddev_cost, 0) DESC;


-- =============================================================================
-- 9. EXECUTIVE DASHBOARD: KEY METRICS
-- =============================================================================
--
-- The numbers your CFO wants to see.
--

SELECT
    -- Volume
    COUNT(*) as total_requests_7d,
    COUNT(DISTINCT trace_id) as total_outcomes_7d,
    COUNT(DISTINCT user_id) as active_users_7d,
    COUNT(DISTINCT tenant_id) as active_tenants_7d,

    -- Cost
    ROUND(SUM(cost_usd)::numeric, 2) as total_cost_7d,
    ROUND(SUM(cost_usd) / 7::numeric, 2) as avg_daily_cost,
    ROUND(SUM(cost_usd) / NULLIF(COUNT(DISTINCT user_id), 0)::numeric, 2) as cost_per_user_7d,

    -- Efficiency
    ROUND(SUM(cost_usd) / NULLIF(COUNT(DISTINCT trace_id), 0)::numeric, 4) as cost_per_outcome,
    ROUND(100.0 * SUM(CASE WHEN is_successful THEN 1 ELSE 0 END) / COUNT(*)::numeric, 1) as success_rate,
    ROUND(100.0 * SUM(CASE WHEN is_retry THEN 1 ELSE 0 END) / COUNT(*)::numeric, 1) as retry_rate,

    -- Performance
    ROUND(AVG(latency_ms)::numeric, 0) as avg_latency_ms,
    ROUND(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY latency_ms)::numeric, 0) as p95_latency_ms

FROM ai_usage
WHERE created_at >= NOW() - INTERVAL '7 days';


-- =============================================================================
-- 10. WEEK-OVER-WEEK COMPARISON
-- =============================================================================
--
-- Are things getting better or worse?
--

WITH weekly_stats AS (
    SELECT
        CASE
            WHEN created_at >= NOW() - INTERVAL '7 days' THEN 'this_week'
            ELSE 'last_week'
        END as period,
        COUNT(*) as requests,
        COUNT(DISTINCT trace_id) as outcomes,
        SUM(cost_usd) as total_cost,
        SUM(cost_usd) / NULLIF(COUNT(DISTINCT trace_id), 0) as cost_per_outcome,
        100.0 * SUM(CASE WHEN is_successful THEN 1 ELSE 0 END) / COUNT(*) as success_rate
    FROM ai_usage
    WHERE created_at >= NOW() - INTERVAL '14 days'
    GROUP BY
        CASE
            WHEN created_at >= NOW() - INTERVAL '7 days' THEN 'this_week'
            ELSE 'last_week'
        END
)
SELECT
    this.requests as this_week_requests,
    last.requests as last_week_requests,
    ROUND(100.0 * (this.requests - last.requests) / NULLIF(last.requests, 0)::numeric, 1) as request_change_pct,

    ROUND(this.total_cost::numeric, 2) as this_week_cost,
    ROUND(last.total_cost::numeric, 2) as last_week_cost,
    ROUND(100.0 * (this.total_cost - last.total_cost) / NULLIF(last.total_cost, 0)::numeric, 1) as cost_change_pct,

    ROUND(this.cost_per_outcome::numeric, 4) as this_week_cpo,
    ROUND(last.cost_per_outcome::numeric, 4) as last_week_cpo,
    ROUND(100.0 * (this.cost_per_outcome - last.cost_per_outcome) / NULLIF(last.cost_per_outcome, 0)::numeric, 1) as cpo_change_pct,

    -- Interpretation
    CASE
        WHEN this.cost_per_outcome > last.cost_per_outcome * 1.1 THEN 'WARNING: COST EFFICIENCY DEGRADING'
        WHEN this.cost_per_outcome < last.cost_per_outcome * 0.9 THEN 'GOOD: COST EFFICIENCY IMPROVING'
        ELSE 'STABLE: COST EFFICIENCY FLAT'
    END as efficiency_trend
FROM
    (SELECT * FROM weekly_stats WHERE period = 'this_week') this,
    (SELECT * FROM weekly_stats WHERE period = 'last_week') last;
