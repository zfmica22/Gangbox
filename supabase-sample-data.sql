-- ============================================================
-- GANGBOX — OPTIONAL sample data
-- Run this AFTER supabase-setup.sql if you want a populated demo
-- (6 crew, 4 jobs, some history, 2 people clocked in right now).
-- Skip it entirely to start empty and add your real crew/jobs.
-- To remove the samples later: truncate entries, employees, sites
-- restart identity cascade;  (does not touch tasks/settings)
-- ============================================================

insert into employees (id, name, trade) values
 ('11111111-1111-4111-8111-111111111101', 'Mike Sullivan',  'Foreman'),
 ('11111111-1111-4111-8111-111111111102', 'Dave Russo',     'Carpenter'),
 ('11111111-1111-4111-8111-111111111103', 'Tyler Nguyen',   'Carpenter'),
 ('11111111-1111-4111-8111-111111111104', 'Carlos Mendez',  'Mason'),
 ('11111111-1111-4111-8111-111111111105', 'Jake Whitman',   'Laborer'),
 ('11111111-1111-4111-8111-111111111106', 'Sam Petrov',     'Finish Carpenter')
on conflict (id) do nothing;

insert into sites (id, name, customer, address, type, bill_rate) values
 ('22222222-2222-4222-8222-222222222201', 'Hilltop Custom Home',    'R. Delgado',    '42 Maple Ave, Ballston Lake',      'New Build',  95),
 ('22222222-2222-4222-8222-222222222202', 'Bryant Kitchen Remodel', 'Bryant Family', '118 Caroline St, Saratoga Springs', 'Remodel',    88),
 ('22222222-2222-4222-8222-222222222203', 'Lakeview Deck & Porch',  'S. Okafor',     '7 Lakeview Dr, Ballston Lake',      'Exterior',   80),
 ('22222222-2222-4222-8222-222222222204', 'Westcott Foundation',    'Westcott LLC',  '330 Rt 50, Burnt Hills',           'Foundation', 92)
on conflict (id) do nothing;

-- a little history (completed shifts over the last few days)
insert into entries (employee_id, site_id, clock_in, clock_out, task) values
 ('11111111-1111-4111-8111-111111111103','22222222-2222-4222-8222-222222222201', now() - interval '3 days 9 hours',  now() - interval '3 days 1 hour',  'Framing'),
 ('11111111-1111-4111-8111-111111111105','22222222-2222-4222-8222-222222222201', now() - interval '3 days 9 hours',  now() - interval '3 days 1 hour',  'Site Prep / Cleanup'),
 ('11111111-1111-4111-8111-111111111102','22222222-2222-4222-8222-222222222202', now() - interval '3 days 9 hours',  now() - interval '3 days 2 hours', 'Demo'),
 ('11111111-1111-4111-8111-111111111104','22222222-2222-4222-8222-222222222204', now() - interval '2 days 9 hours',  now() - interval '2 days 1 hour',  'Foundation / Concrete'),
 ('11111111-1111-4111-8111-111111111106','22222222-2222-4222-8222-222222222202', now() - interval '2 days 9 hours',  now() - interval '2 days 2 hours', 'Trim & Finish'),
 ('11111111-1111-4111-8111-111111111103','22222222-2222-4222-8222-222222222201', now() - interval '2 days 9 hours',  now() - interval '2 days 1 hour',  'Framing'),
 ('11111111-1111-4111-8111-111111111102','22222222-2222-4222-8222-222222222203', now() - interval '1 day 9 hours',   now() - interval '1 day 2 hours',  'Decking'),
 ('11111111-1111-4111-8111-111111111105','22222222-2222-4222-8222-222222222204', now() - interval '1 day 9 hours',   now() - interval '1 day 1 hour',   'Foundation / Concrete'),
 ('11111111-1111-4111-8111-111111111106','22222222-2222-4222-8222-222222222202', now() - interval '1 day 9 hours',   now() - interval '1 day 3 hours',  'Punch List');

-- two people on the clock right now (with a check-in pin)
insert into entries (employee_id, site_id, clock_in, clock_out, lat, lng, task) values
 ('11111111-1111-4111-8111-111111111101','22222222-2222-4222-8222-222222222201', now() - interval '3 hours', null, 42.9398, -73.8521, 'Framing'),
 ('11111111-1111-4111-8111-111111111102','22222222-2222-4222-8222-222222222202', now() - interval '2 hours', null, 43.0712, -73.7846, 'Trim & Finish');
