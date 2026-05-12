import { createClient } from '@supabase/supabase-js';


// Initialize database client
const supabaseUrl = 'https://obztcqxikyshowrtzkzf.databasepad.com';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImNiMTMyZGZmLWI4ZmUtNGY1Ny05NDQzLWNlOGVjYmYyMmIwYyJ9.eyJwcm9qZWN0SWQiOiJvYnp0Y3F4aWt5c2hvd3J0emt6ZiIsInJvbGUiOiJhbm9uIiwiaWF0IjoxNzc4NDg0NTQwLCJleHAiOjIwOTM4NDQ1NDAsImlzcyI6ImZhbW91cy5kYXRhYmFzZXBhZCIsImF1ZCI6ImZhbW91cy5jbGllbnRzIn0.1ntOOjBPT7B3lU2eu1gDkshMttEb6lNzOPoodHtuGxo';
const supabase = createClient(supabaseUrl, supabaseKey);


export { supabase };