# Supabase Experiments

1. Create a project at Supabase and copy the project URL and anon key.
2. Run `schema.sql` in the Supabase SQL Editor.
3. Enable Authentication providers, Storage, and Realtime in the dashboard.
4. Add `@supabase/supabase-js` to a frontend or uncomment the import in `index.html`.

The schema covers PostgreSQL data types, primary/foreign keys, constraints, relationships, views, indexes, CRUD, Row Level Security, authenticated-user policies, roles, and a realtime messages table. The client page documents the authentication, CRUD, Storage, Edge Function, REST API, and realtime client patterns without embedding project credentials.

REST examples use `/rest/v1/products` with `apikey` and `Authorization: Bearer <token>` headers. Edge Functions can be created with `supabase functions new hello`, deployed with `supabase functions deploy hello`, and connected to this database using the server client.
