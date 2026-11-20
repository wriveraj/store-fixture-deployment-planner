-- 7-Day Deployment Calendar with buffer check: does the fixture behind each reset
-- come back to the DC at least a day before it goes out again?
-- The retrieval is the one for the allocation's source deployment. A reset with no
-- source deployment has no retrieval to check, and an overdue retrieval is called
-- out even when its scheduled date would have left enough buffer.
SELECT dc.deployment_date, l.location_name, c.item_name, c.fixture_family,
       pa.reset_lead, pa.priority, dc.buffer_gap_hrs,
       CASE WHEN dc.is_confirmed THEN 'Confirmed' ELSE 'Planned' END AS deployment_status,
       rs.scheduled_date AS retrieval_date,
       CASE WHEN rs.scheduled_date IS NULL                  THEN 'No Retrieval Scheduled'
            WHEN rs.status = 'Overdue'                      THEN 'Retrieval Overdue'
            WHEN dc.deployment_date - rs.scheduled_date < 1 THEN 'Buffer Gap Risk'
            ELSE 'Buffer OK' END AS buffer_status
FROM store_ops.deployment_calendar dc
JOIN store_ops.catalog c   ON dc.item_id = c.item_id
JOIN store_ops.locations l ON dc.location_id = l.location_id
LEFT JOIN store_ops.pre_allocations pa    ON dc.allocation_id = pa.allocation_id
LEFT JOIN store_ops.retrieval_schedule rs ON rs.deployment_id = pa.source_deployment_id
WHERE c.item_type = 'Fixture'
ORDER BY dc.deployment_date, l.location_name, c.item_name;
